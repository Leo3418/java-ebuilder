package org.gentoo.java.ebuilder.portage;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.math.BigInteger;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import org.gentoo.java.ebuilder.Config;

/**
 * Parses portage tree and collects information needed for generating ebuilds.
 *
 * @author fordfrog
 */
public class PortageParser {

    /**
     * Cache version.
     */
    public static final String CACHE_VERSION = "1.1";
    /**
     * Current ant utilities eclass name.
     */
    private static final String ECLASS_ANT_TASKS = "ant-tasks";
    /**
     * Current java optional package eclass name.
     */
    private static final String ECLASS_JAVA_PKG_OPT = "java-pkg-opt-2";
    /**
     * Pattern for parsing ebuild file name.
     */
    private static final Pattern PATTERN_EBUILD_NAME = Pattern.compile(
            "^(\\S+?)-([^-]+)(?:-(r\\d+))?\\.ebuild$");
    /**
     * Pattern for parsing SLOT with bash substring.
     */
    private static final Pattern PATTERN_SLOT_SUBSTRING = Pattern.compile(
            "^\\$\\{PV:(\\d+):(\\d+)\\}$");
    /**
     * Pattern for parsing version component range in SLOT.
     */
    private static final Pattern PATTERN_SLOT_VERSION_COMPOPONENT_RANGE
            = Pattern.compile(
                    "^\\$\\(get_version_component_range (\\d+)-(\\d+)\\)$");
    /**
     * Pattern for checking whether the line contains variable declaration. It
     * does not handle correctly variables spread across several lines but we
     * most probably do not care about these.
     */
    private static final Pattern PATTERN_VARIABLE = Pattern.compile(
            "^(\\S+?)=(.*)$");

    /**
     * Parses ebuild name into map. Keys are:
     * <dl>
     * <dt>name</dt>
     * <dd>ebuild name</dd>
     * <dt>version</dt>
     * <dd>ebuild version</dd>
     * <dt>suffix</dt>
     * <dd>ebuild version suffix (-r)</dd>
     * </dl>
     * If suffix is not present in ebuild name, it is not put into the map
     * aswell.
     *
     * @param name ebuild file name
     *
     * @return map of parsed values
     *
     * @throws IllegalArgumentException Thrown if the ebuild file name is not
     *                                  valid or it cannot be parsed.
     */
    public static Map<String, String> parseEbuildName(final String name) {
        final Matcher matcher = PATTERN_EBUILD_NAME.matcher(name);

        if (!matcher.matches()) {
            throw new IllegalArgumentException("Ebuild file name is not valid "
                    + "or parser does not support this ebuild name format");
        }

        final Map<String, String> result = new HashMap<>(3);
        result.put("name", matcher.group(1));
        result.put("version", matcher.group(2));

        if (matcher.groupCount() > 2) {
            result.put("suffix", matcher.group(3));
        }

        return result;
    }

    /**
     * List of cache items. This list is populated during parsing the tree.
     */
    private final List<CacheItem> cacheItems = new ArrayList<>(40_000);
    /**
     * Used for cellecting counts of java eclasses.
     */
    private final Map<String, Integer> eclassesCounts = new HashMap<>(10);
    /**
     * Path to directory for new ebuild metadata cache files.
     */
    private Path ebuildMetadataDir;
    /**
     * Number of processed categories. Updated during parsing the tree.
     */
    private int processedCategories;
    /**
     * Number of processed ebuilds. Updated during parsing the tree.
     */
    private int processedEbuilds;
    /**
     * Number of processed packages. Updated during parsing the tree.
     */
    private int processedPackages;

    /**
     * Parses portage tree at specified path and create ebuild cache at
     * ~/.java-ebuilder/cache.
     *
     * @param config application configuration
     */
    public void parseTree(final Config config) {
        final long startTimestamp = System.currentTimeMillis();
        cacheItems.clear();
        processedCategories = 0;
        processedPackages = 0;
        processedEbuilds = 0;
        eclassesCounts.clear();

        ebuildMetadataDir = config.getEbuildMetadataDir();

        for (Path portageTree : config.getPortageTree()) {
            config.getStdoutWriter().println("Parsing portage tree @ "
                    + portageTree + " ...");
            parseCategories(portageTree);
        }

        final long endTimestamp = System.currentTimeMillis();

        config.getStdoutWriter().print(MessageFormat.format(
                "Parsed {0} categories {1} packages {2} ebuilds in {3}ms and "
                + "found {4} java ebuilds",
                processedCategories, processedPackages, processedEbuilds,
                endTimestamp - startTimestamp, cacheItems.size()));

        final List<String> sortedEclasses
                = new ArrayList<>(eclassesCounts.keySet());
        Collections.sort(sortedEclasses);

        config.getStdoutWriter().print((" (used java eclasses: "));

        for (int i = 0; i < sortedEclasses.size(); i++) {
            if (i > 0) {
                config.getStdoutWriter().print(", ");
            }

            final String eclass = sortedEclasses.get(i);

            config.getStdoutWriter().print(eclass);
            config.getStdoutWriter().print(" = ");
            config.getStdoutWriter().print(eclassesCounts.get(eclass));
        }

        config.getStdoutWriter().println(")");

        config.getStdoutWriter().print("Writing cache file...");
        writeCacheFile(config);
        config.getStdoutWriter().println("done");
    }

    /**
     * Increases counter for each eclass from the list.
     *
     * @param eclasses list of eclasses
     */
    private void countEclasses(final List<String> eclasses) {
        eclasses.forEach((eclass) -> {
            final Integer count = eclassesCounts.get(eclass);

            if (count == null) {
                eclassesCounts.put(eclass, 1);
            } else {
                eclassesCounts.put(eclass, count + 1);
            }
        });
    }

    /**
     * Extracts the most important java eclass from ebuild inherit line.
     *
     * @param inheritLine ebuild inherit line
     *
     * @return list of inherited java eclasses or null
     */
    private List<String> getJavaInheritEclasses(final String inheritLine) {
        final String[] lines
                = inheritLine.replaceAll("^inherit\\s+", "").split("\\s+");

        return Arrays.stream(lines).
                filter((line) -> line.startsWith("java-")
                || ECLASS_ANT_TASKS.equals(line)).
                collect(Collectors.toList());
    }

    /**
     * Parses categories in the portage tree root.
     *
     * @param treePath portage tree path
     */
    private void parseCategories(final Path treePath) {
        final File[] categories = treePath.toFile().listFiles(
                (final File pathname) -> pathname.isDirectory());

        for (final File category : categories) {
            parseCategory(category);
            processedCategories++;
        }
    }

    /**
     * Parses category and its packages.
     *
     * @param category category path
     */
    private void parseCategory(final File category) {
        final File[] packages = category.listFiles(
                (final File pathname) -> pathname.isDirectory());

        for (final File pkg : packages) {
            parsePackage(pkg);
            processedPackages++;
        }
    }

    /**
     * Parses single ebuild.
     *
     * @param ebuild ebuild path
     */
    private void parseEbuild(final File ebuild) {
        final String filename = ebuild.getName().replaceAll("\\.ebuild$", "");
        final String category
                = ebuild.getParentFile().getParentFile().getName();
        final String pkg = ebuild.getParentFile().getName();
        final String version = filename.substring(pkg.length() + 1);
        final Map<String, String> variables = new HashMap<>(20);
        final Path portageTree =
                Paths.get(ebuild.getParent(), "..", "..").normalize();
        final Path ebuildMetadata = portageTree.resolve(Paths.get(
                "metadata", "md5-cache", category, filename));
        List<String> eclasses = null;
        String slot = "0";
        String useFlag = null;
        String mavenId = null;
        String groupId = null;
        String artifactId = null;
        String mavenVersion = null;
        List<String> mavenProvide = new ArrayList<>();

        boolean readingMultiLineMavenProvide = false;
        try (final BufferedReader reader = new BufferedReader(
                new InputStreamReader(Files.newInputStream(ebuild.toPath(),
                        StandardOpenOption.READ)))) {
            String line = reader.readLine();

            while (line != null) {
                line = line.trim();

                if (!line.isEmpty()) {
                    final int pos = line.indexOf('#');

                    if (pos != -1) {
                        line = line.substring(0, pos).trim();
                    }
                }

                if (!line.isEmpty()) {
                    // Check if a multi-line MAVEN_PROVIDES declaration is
                    // being read
                    if (readingMultiLineMavenProvide) {
                        if (!line.startsWith("\"")) {
                            // Line contains an artifact ID
                            mavenProvide.add(line.replace("\"", ""));
                        }
                        if (line.contains("\"")) {
                            // Closing double quote
                            readingMultiLineMavenProvide = false;
                        }
                    } else {
                        // Check if the line contains variable declaration
                        final Matcher matcher = PATTERN_VARIABLE.matcher(line);

                        if (matcher.matches()) {
                            variables.put(matcher.group(1),
                                    matcher.group(2).replaceAll("(^\"|\"$)", ""));
                        }

                        if (line.startsWith("inherit ")) {
                            eclasses = getJavaInheritEclasses(line);

                            if (eclasses == null || eclasses.isEmpty()) {
                                return;
                            }
                        } else if (line.startsWith("SLOT=")) {
                            slot = line.substring("SLOT=".length()).replace(
                                    "\"", "").replaceAll("/.*", "");
                        } else if (line.startsWith("JAVA_PKG_OPT_USE=")) {
                            useFlag = line.substring("JAVA_PKG_OPT_USE=".length()).
                                    replace("\"", "");
                        } else if (line.startsWith("MAVEN_ID=")) {
                            mavenId = line.substring("MAVEN_ID=".length()).
                                    replace("\"", "");
                        } else if (line.startsWith("MAVEN_PROVIDES=")) {
                            boolean atMostOneDoubleQuote =
                                    line.indexOf("\"") == line.lastIndexOf("\"");
                            line = line.substring("MAVEN_PROVIDES=".length());
                            if (!atMostOneDoubleQuote || !line.endsWith("\"")) {
                                // Line contains an artifact ID
                                mavenProvide.addAll(Arrays.asList(
                                        line.replace("\"", "").split(" ")));
                            }
                            if (atMostOneDoubleQuote && line.contains("\"")) {
                                // Only one double quote -- multi-line declaration
                                readingMultiLineMavenProvide = true;
                            }
                        }
                    }
                }

                line = reader.readLine();
            }
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to read ebuild", ex);
        }

        if (eclasses == null) {
            return;
        }

        if (eclasses.contains(ECLASS_JAVA_PKG_OPT) && useFlag == null) {
            useFlag = "java";
        }

        final String pv;
        final int pos = version.indexOf('-');

        if (pos == -1) {
            pv = version;
        } else {
            pv = version.substring(0, pos);
        }

        if (Files.exists(ebuildMetadata)) {
            slot = processSlot(slot, ebuildMetadata);
        }
        else {
            final String metadataRelativePath =
                    ebuild.getParentFile().getAbsolutePath().substring(1);
            final Path generatedEbuildMetadata = ebuildMetadataDir.resolve(
                    metadataRelativePath + "-" + version);
            /*
             * If the metadata is up-to-date, then it does not need to be
             * regenerated. There are two ways of checking this:
             * 1. Depend on egencache's cache validity check
             * 2. Read the MD5 checksum in the metadata and compare it with the
             *    corresponding ebuild's MD5. The metadata is outdated if and
             *    only if the checksums do not match
             * The former approach has significant overhead that causes very
             * long program runtime because it unconditionally creates a new
             * egencache process even if the metadata is up-to-date. The latter
             * way is more preferable since reading, computing and comparing
             * MD5 checksums are very fast operations.
             */
            if (ebuildMetadataCacheMiss(generatedEbuildMetadata, ebuild)) {
                generateEbuildMetadata(portageTree, category + "/" + pkg);
            }
            slot = processSlot(slot, generatedEbuildMetadata);
        }

        if (mavenId != null) {
            mavenId = mavenId.replaceAll("\\$(\\{PN\\}|PN)", pkg).
                    replaceAll("\\$(\\{PV\\}|PV)", pv);

            final String[] parts = mavenId.split(":");

            if (parts[0].isEmpty()) {
                groupId = pkg;
            } else {
                groupId = parts[0];
            }

            if (parts.length > 1) {
                artifactId = parts[1];
            } else {
                artifactId = pkg;
            }

            if (parts.length > 2) {
                mavenVersion = parts[2];
            } else {
                mavenVersion = version;
            }
        }

        cacheItems.add(new CacheItem(category, pkg, version, slot, useFlag,
                groupId, artifactId, mavenVersion, eclasses));

        for (String providedId: mavenProvide) {
            // Allow declarations like MAVEN_PROVIDES="groupId:${PN}:${PV}"
            providedId = providedId.replaceAll("\\$(\\{PN\\}|PN)", pkg).
                    replaceAll("\\$(\\{PV\\}|PV)", pv);
            final String[] parts = providedId.split(":");
            cacheItems.add(new CacheItem(category, pkg, version, slot, useFlag,
                    parts[0], parts[1], parts[2], eclasses));
        }
        countEclasses(eclasses);
    }

    /**
     * Parses package and its ebuilds.
     *
     * @param pkg package path
     */
    private void parsePackage(final File pkg) {
        final File[] ebuilds = pkg.listFiles(
                (final File pathname) -> pathname.isFile()
                && pathname.getName().endsWith(".ebuild"));

        if (ebuilds == null) {
            return;
        }

        for (final File ebuild : ebuilds) {
            parseEbuild(ebuild);
            processedEbuilds++;
        }
    }

    /**
     * Returns the MD5 checksum for a file.
     *
     * @param file file whose MD5 checksum is queried
     *
     * @return MD5 checksum in hex string with all letters in lower case
     */
    private String getMD5Checksum(final File file) {
        final MessageDigest messageDigest;
        try {
            messageDigest = MessageDigest.getInstance("MD5");
        } catch (final NoSuchAlgorithmException ex) {
            throw new AssertionError("MD5 is an algorithm provided by every "
                    + "implementation of Java but is not available here", ex);
        }

        try (final InputStream ebuildStream = new FileInputStream(file)) {
            final byte[] buf = new byte[4096];
            int bytesRead;
            while ((bytesRead = ebuildStream.read(buf)) > 0) {
                messageDigest.update(buf, 0, bytesRead);
            }
        } catch (final FileNotFoundException ex) {
            throw new RuntimeException("Could not find file " + file, ex);
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to read file " + file, ex);
        }

        final byte[] rawChecksum = messageDigest.digest();
        return new BigInteger(1, rawChecksum).toString(16);
    }

    /**
     * Returns whether a metadata cache file for an ebuild is outdated. If the
     * specified metadata cache file path does not point to an existing file,
     * then the cache will be regarded as outdated.
     *
     * @param metadata metadata cache file path
     * @param ebuild   ebuild concerned by the metadata cache file
     *
     * @return whether there is a cache miss for the ebuild with the cache
     */
    private boolean ebuildMetadataCacheMiss(final Path metadata,
            final File ebuild) {
        if (!Files.exists(metadata)) {
            return true;
        }

        final List<String> metadataEntries;
        try {
            metadataEntries = Files.readAllLines(metadata);
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to read ebuild metadata "
                    + metadata, ex);
        }

        final String checksumLinePrefix = "_md5_=";
        String expectedChecksum = null;
        // As of Portage 3.0.20, the MD5 checksum is in the last line of
        // the metadata file, so read backwards for performance
        for (int i = metadataEntries.size() - 1;
             expectedChecksum == null && i >= 0; i--) {
            final String metadataEntry = metadataEntries.get(i);
            if (metadataEntry.startsWith(checksumLinePrefix)) {
                expectedChecksum =
                        metadataEntry.substring(checksumLinePrefix.length());
            }
        }

        final String actualChecksum = getMD5Checksum(ebuild);
        // actualChecksum guaranteed to be non-null
        return !actualChecksum.equals(expectedChecksum);
    }

    /**
     * Returns the name of an ebuild repository.
     *
     * @param portageTree ebuild repository path
     *
     * @return name of the ebuild repository
     */
    private String getPortageTreeRepoName(final Path portageTree) {
        final Path repoNamePath = portageTree.resolve(Paths.get(
                "profiles", "repo_name"));
        try {
            return Files.lines(repoNamePath).findFirst().orElseThrow(() ->
                    new IllegalStateException(repoNamePath + " seems to be an "
                            + "empty file, could not read repository name "
                            + "from it"));
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to read repository name from "
                    + repoNamePath, ex);
        }
    }

    /**
     * Returns a list of lines for an ebuild repository entry in
     * {@code /etc/portage/repos.conf}.
     *
     * @param portageTree ebuild repository path
     *
     * @return list of lines for the repository in Portage config
     */
    private List<String> getReposConfContents(final Path portageTree) {
        final String repoName = getPortageTreeRepoName(portageTree);
        final List<String> contents = new ArrayList<>(2);
        contents.add("[" + repoName + "]");
        contents.add("location = " + portageTree);
        return contents;
    }

    /**
     * Generates metadata cache for all ebuilds for the specified atom.
     * {@code atom} will be passed to {@code egencache(1)} as the
     * {@code [ATOM]} argument of its {@code --update} option.
     *
     * @param portageTree path to the repository containing the ebuilds for the
     *                    specified atom
     * @param atom        atom of the package
     */
    private void generateEbuildMetadata(final Path portageTree,
            final String atom) {
        // Create a fake repos.conf file for the ebuild repository
        final Path egencacheTempDir;
        try {
            egencacheTempDir = Files.createTempDirectory("egencache");
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to create temporary directory "
                    + "for egencache", ex);
        }
        final Path portageConfigRoot = egencacheTempDir.resolve(Paths.get(
                "etc", "portage"));
        portageConfigRoot.toFile().mkdirs();
        final Path reposConf = portageConfigRoot.resolve("repos.conf");
        try {
            Files.write(reposConf, getReposConfContents(portageTree));
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to write to repo config file "
                    + reposConf, ex);
        }

        // Create the destination directory of metadata cache files if needed
        final File ebuildMetadataDirFile = ebuildMetadataDir.toFile();
        if (!ebuildMetadataDirFile.exists()) {
            ebuildMetadataDirFile.mkdirs();
        }

        // Call egencache
        final ProcessBuilder processBuilder = new ProcessBuilder(
                "egencache",
                "--cache-dir=" + ebuildMetadataDir,
                "--config-root=" + egencacheTempDir,
                "--external-cache-only",
                "--repo=" + getPortageTreeRepoName(portageTree),
                // Tolerate any ebuild without manifest because only the
                // ebuild itself is needed to generate metadata cache
                "--strict-manifests", "n",
                "--update",
                atom
        );
        final Process process;
        try {
            process = processBuilder.start();
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to run egencache command", ex);
        }
        try {
            final int timeoutSeconds = 60;
            if (!process.waitFor(timeoutSeconds, TimeUnit.SECONDS)) {
                throw new RuntimeException("egencache command did not finish "
                        + "within " + timeoutSeconds + " seconds");
            }
        } catch (final InterruptedException ex) {
            throw new RuntimeException("egencache command had not finished "
                    + "before the thread waiting for it was interrupted");
        }
        if (process.exitValue() != 0) {
            try (final BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getErrorStream()))) {
                StringBuilder stderrBuilder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    stderrBuilder.append(System.lineSeparator()).append(line);
                }
                throw new RuntimeException("Failed to run egencache command: "
                        + stderrBuilder);
            } catch (final IOException ex) {
                throw new RuntimeException(
                        "Failed to read egencache command error output", ex);
            }
        }
    }

    /**
     * Processes various instructions in SLOT string.
     *
     * @param slot           SLOT string
     * @param ebuildMetadata path to the metadata of the Gentoo package
     *
     * @return processed SLOT string
     */
    private String processSlot(final String slot,
            final Path ebuildMetadata) {
        //final metadata = new File(ebuildMetadata.toString());
        String result = slot;
        try (final BufferedReader reader = new BufferedReader(
                new InputStreamReader(Files.newInputStream(ebuildMetadata,
                        StandardOpenOption.READ)))) {
            String line = reader.readLine();
            while (line != null) {
                line = line.trim();

                if (!line.isEmpty()) {
                    if (line.startsWith("SLOT=")) {
                        result = line.substring("SLOT=".length()).replace(
                                "\"", "").replaceAll("/.*", "");
                    }

                line = reader.readLine();
                }
            }
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to read ebuild", ex);
        }
        return result;
    }

    /**
     * Processes various instructions in SLOT string.
     *
     * @param slot      SLOT string
     * @param pv        PV variable
     * @param variables map of collected variables and their values
     *
     * @return processed SLOT string
     */
    private String processSlot(final String slot, final String pv,
            final Map<String, String> variables) {
        String result = slot.replaceAll("\\$(\\{PV\\}|PV)", pv);

        if (result.indexOf('$') != -1) {
            for (final Map.Entry<String, String> variable
                    : variables.entrySet()) {
                result = result.
                        replace("$" + variable.getKey(), variable.getValue()).
                        replace("${" + variable.getKey() + '}',
                                variable.getValue());
            }
        }

        if (result.indexOf('$') != -1) {
            final Matcher matcher = PATTERN_SLOT_SUBSTRING.matcher(result);

            if (matcher.matches()) {
                final int start = Integer.parseInt(matcher.group(1), 10);
                final int length = Integer.parseInt(matcher.group(2), 10);
                result = pv.substring(start, start + length);
            }
        }

        if (result.indexOf('$') != -1) {
            final Matcher matcher
                    = PATTERN_SLOT_VERSION_COMPOPONENT_RANGE.matcher(result);

            if (matcher.matches()) {
                final int start = Integer.parseInt(matcher.group(1), 10);
                final int end = Integer.parseInt(matcher.group(2), 10);
                final String[] parts = pv.split("\\.");
                final StringBuilder sbResult = new StringBuilder(10);

                for (int i = start; i <= end; i++) {
                    if (sbResult.length() > 0) {
                        sbResult.append('.');
                    }

                    sbResult.append(i <= parts.length ? parts[i - 1] : '0');
                }

                result = sbResult.toString();
            }
        }

        return result;
    }

    /**
     * Writes cache items to the cache file.
     *
     * @param config application configuration
     */
    private void writeCacheFile(final Config config) {
        final File cacheDir = config.getCacheFile().getParent().toFile();

        if (!cacheDir.exists()) {
            cacheDir.mkdirs();
        }

        cacheItems.sort((
                final CacheItem o1,
                final CacheItem o2) -> {
            if (o1.getCategory().compareTo(o2.getCategory()) != 0) {
                return o1.getCategory().compareTo(o2.getCategory());
            } else if (o1.getPkg().compareTo(o2.getPkg()) != 0) {
                return o1.getPkg().compareTo(o2.getPkg());
            } else {
                return o1.getVersion().compareTo(o2.getVersion());
            }
        });

        try (final OutputStreamWriter writer = new OutputStreamWriter(
                Files.newOutputStream(config.getCacheFile(),
                        StandardOpenOption.CREATE, StandardOpenOption.WRITE,
                        StandardOpenOption.TRUNCATE_EXISTING),
                Charset.forName("UTF-8"))) {
            writer.write(CACHE_VERSION);
            writer.write("\n#category:pkg:version:slot:useFlag:groupId:"
                    + "artifactId:mavenVersion:javaEclass\n");

            for (final CacheItem cacheItem : cacheItems) {
                writer.write(cacheItem.getCategory());
                writer.write(':');
                writer.write(cacheItem.getPkg());
                writer.write(':');
                writer.write(cacheItem.getVersion());
                writer.write(':');
                writer.write(cacheItem.getSlot());
                writer.write(':');
                writer.write(cacheItem.getUseFlag() == null
                        ? "" : cacheItem.getUseFlag());
                writer.write(':');
                writer.write(cacheItem.getGroupId() == null
                        ? "" : cacheItem.getGroupId());
                writer.write(':');
                writer.write(cacheItem.getArtifactId() == null
                        ? "" : cacheItem.getArtifactId());
                writer.write(':');
                writer.write(cacheItem.getMavenVersion() == null
                        ? "" : cacheItem.getMavenVersion());
                writer.write(':');

                if (cacheItem.getJavaEclasses() != null
                        && !cacheItem.getJavaEclasses().isEmpty()) {
                    writer.write(String.join(",", cacheItem.getJavaEclasses()));
                }

                writer.write('\n');
            }
        } catch (final IOException ex) {
            throw new RuntimeException("Failed to write cache file @ "
                    + config.getCacheFile(), ex);
        }
    }
}

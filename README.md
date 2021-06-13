# java-ebuilder

java-ebuilder is a tool from the [Gentoo Java Project][gentoo-java] for
semi-automatic creation of ebuilds from Maven artifacts based on their
`pom.xml`.

[gentoo-java]: https://wiki.gentoo.org/wiki/Project:Java

## Installation

java-ebuilder is available in the Gentoo repository as
[`app-portage/java-ebuilder`][gentoo-repo-pkg].  It can be installed with

```console
# emerge --ask app-portage/java-ebuilder
```

[gentoo-repo-pkg]: https://packages.gentoo.org/packages/app-portage/java-ebuilder

## Usage

1. Edit `/etc/java-ebuilder.conf` and add the coordinates
   (`groupId:artifactId:version`) of artifacts whose ebuild is needed to
   `MAVEN_ARTS`.  Coordinates should be separated by space.

2. Run the command

   ```console
   # movl build
   ```

   to generate the ebuilds.  After the program exits normally, an ebuild
   repository containing those ebuilds can be found under the path set by
   `MAVEN_OVERLAY_DIR` in `/etc/java-ebuilder.conf`.

3. To start over, run

   ```console
   # movl clean
   ```

## Testing

java-ebuilder currently comes with a system test suite which verifies the
correctness of its behavior by comparing the ebuilds it generates with expected
output pre-defined by the developers.

### Running the Test Suite

There are several ways to run the system test suite:

- Run `mvn test` to ensure java-ebuilder has been built and the compiled files
  are up to date before running the test suite.

- Run `mvn exec:exec@ebuild-tests` to skip building java-ebuilder and run the
  test suite directly.

- Enter the `tests` directory and run the `ebuild-tests.sh` script, which
  allows customizing test execution with command-line arguments to the script
  and environment variables.  Please refer to the output of `./ebuild-tests.sh
  --help` for information pertaining to supported command-line options, and the
  `ebuild-tests.sh` script and files under `tests/scripts` for details
  regarding the environment variables.

### Test Cases

A test case is defined by these things:

- A value for `MAVEN_ARTS`; in other words, the coordinates of Maven artifacts
  to test.

- A list of ebuilds to check and the expected ebuilds themselves for the
  specified Maven artifacts.

A test case is represented by a file containing definitions of `MAVEN_ARTS` and
the list of ebuilds to check.  The latter should be specified by a variable
called `EBUILD_PATHS`.  The file should be written in Bash syntax.

Here is an example test case file for `com.google.guava:guava:30.1.1-jre`:

```bash
# Test ebuild generation for Guava
MAVEN_ARTS="com.google.guava:guava:30.1.1-jre"
EBUILD_PATHS="app-maven/guava/guava-30.1.1.ebuild"
```

Here is an example test case file for testing multiple Maven artifacts and
checking multiple ebuilds:

```bash
MAVEN_ARTS="\
    org.apache.commons:commons-collections4:4.4 \
    org.apache.commons:commons-lang3:3.12.0 \
"
EBUILD_PATHS="\
    app-maven/commons-collections4/commons-collections4-4.4.ebuild \
    dev-java/commons-lang3/commons-lang3-3.12.0.ebuild \
"
```

#### Paths

By default, the system test scans test case files under
`tests/resources/ebuild-tests/test-cases` and runs each of them individually,
in a way that swapping the order of the test cases would not affect the test
results.

Each path declared in the `EBUILD_PATHS` variable of every test case should be
a valid file path relative to the
`tests/resources/ebuild-tests/expected-ebuilds/default` directory.

#### Overriding Default Behavior of Test Cases

##### Additional ebuild Repositories

If extra ebuild repositories need to be used to run a test case, they can be
added through a `local` `TEST_REPOS` variable in the test case file.  Each
repository is defined by the name of the directory containing it under
`tests/resources/repos`.  Repository definitions should be separated by white
space.  For example:

```bash
MAVEN_ARTS="com.google.guava:guava:30.1.1-jre"
EBUILD_PATHS="app-maven/guava/guava-30.1.1.ebuild"
# Add a repository stored in tests/resources/repos/guava
local TEST_REPOS="guava"
```

##### Path to Expected ebuilds

The base directory for paths under `EBUILD_PATHS` definitions can be changed on
a case-by-case basis by defining the new base directory path in a `local`
`EXPECTED_EBUILDS_SUBDIR` variable in the test case file.  The value for this
variable should be the name of a directory under
`tests/resources/ebuild-tests/expected-ebuilds`.  For example:

```bash
MAVEN_ARTS="com.google.guava:guava:30.1.1-jre"
EBUILD_PATHS="app-maven/guava/guava-30.1.1.ebuild"
# Resolve ebuild paths relative to
# tests/resources/ebuild-tests/expected-ebuilds/guava
local EXPECTED_EBUILDS_SUBDIR="guava"
```

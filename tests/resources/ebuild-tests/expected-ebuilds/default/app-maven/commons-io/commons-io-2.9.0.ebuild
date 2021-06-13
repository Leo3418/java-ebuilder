# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/commons-io-2.9.0.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/commons-io/commons-io/2.9.0/commons-io-2.9.0-sources.jar --binjar-uri https://repo1.maven.org/maven2/commons-io/commons-io/2.9.0/commons-io-2.9.0.jar --slot 0 --keywords "~amd64" --ebuild commons-io-2.9.0.ebuild

EAPI=7

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="commons-io:commons-io:2.9.0"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="The Apache Commons IO library contains utility classes, stream implementations, file filters, file comparators, endian transformation classes, and much more."
HOMEPAGE="https://commons.apache.org/proper/commons-io/"
SRC_URI="https://repo1.maven.org/maven2/${PN}/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/${PN}/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=virtual/jdk-1.8:*
"

RDEPEND="
	>=virtual/jre-1.8:*
"

BDEPEND="app-arch/unzip"

S="${WORKDIR}"

JAVA_ENCODING="iso-8859-1"

JAVA_SRC_DIR="src/main/java"
JAVA_RESOURCE_DIRS=(
	""
)
JAVA_BINJAR_FILENAME="${P}-bin.jar"

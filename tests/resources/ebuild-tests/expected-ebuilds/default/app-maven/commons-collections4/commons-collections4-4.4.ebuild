# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/commons-collections4-4.4.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/org/apache/commons/commons-collections4/4.4/commons-collections4-4.4-sources.jar --binjar-uri https://repo1.maven.org/maven2/org/apache/commons/commons-collections4/4.4/commons-collections4-4.4.jar --slot 0 --keywords "~amd64" --ebuild commons-collections4-4.4.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="org.apache.commons:commons-collections4:4.4"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="The Apache Commons Collections package contains types that extend and augment the Java Collections Framework."
HOMEPAGE="https://commons.apache.org/proper/commons-collections/"
SRC_URI="https://repo1.maven.org/maven2/org/apache/commons/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/org/apache/commons/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
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

JAVA_SRC_DIR="src/main/java"
JAVA_RESOURCE_DIRS=(
	""
)
JAVA_BINJAR_FILENAME="${P}-bin.jar"

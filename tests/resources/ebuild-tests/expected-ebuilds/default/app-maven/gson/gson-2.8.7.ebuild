# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/gson-2.8.7.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/com/google/code/gson/gson/2.8.7/gson-2.8.7-sources.jar --binjar-uri https://repo1.maven.org/maven2/com/google/code/gson/gson/2.8.7/gson-2.8.7.jar --slot 0 --keywords "~amd64" --ebuild gson-2.8.7.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="com.google.code.gson:gson:2.8.7"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Gson JSON library"
HOMEPAGE="https://github.com/google/gson/gson"
SRC_URI="https://repo1.maven.org/maven2/com/google/code/${PN}/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/com/google/code/${PN}/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
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
JAVA_BINJAR_FILENAME="${P}-bin.jar"

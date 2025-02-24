# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/h2-1.4.200.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200-sources.jar --binjar-uri https://repo1.maven.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200.jar --slot 0 --keywords "~amd64" --ebuild h2-1.4.200.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="com.h2database:h2:1.4.200"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="H2 Database Engine"
HOMEPAGE="https://h2database.com"
SRC_URI="https://repo1.maven.org/maven2/com/${PN}database/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/com/${PN}database/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
LICENSE="|| ( MPL-1.1 EPL-1.0 )"
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

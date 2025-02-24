# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/okhttp-4.9.1.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/4.9.1/okhttp-4.9.1-sources.jar --binjar-uri https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/4.9.1/okhttp-4.9.1.jar --slot 0 --keywords "~amd64" --ebuild okhttp-4.9.1.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="com.squareup.okhttp3:okhttp:4.9.1"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Square’s meticulous HTTP client for Java and Kotlin."
HOMEPAGE="https://square.github.io/okhttp/"
SRC_URI="https://repo1.maven.org/maven2/com/squareup/${PN}3/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/com/squareup/${PN}3/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: /tmp/java-ebuilder/poms/${P}.pom
# com.squareup.okio:okio:2.8.0 -> >=dev-java/okio-2.8.0:0
# org.jetbrains.kotlin:kotlin-stdlib:1.4.10 -> >=dev-java/kotlin-common-bin-1.4.32:1.4

CDEPEND="
	>=app-maven/okio-2.8.0:0
	>=dev-java/kotlin-common-bin-1.4.32:1.4
"

DEPEND="
	>=virtual/jdk-1.8:*
	!binary? ( ${CDEPEND} )
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CDEPEND}"

BDEPEND="app-arch/unzip"

S="${WORKDIR}"

JAVA_GENTOO_CLASSPATH="okio,kotlin-common-bin-1.4"
JAVA_SRC_DIR="src/main/java"
JAVA_BINJAR_FILENAME="${P}-bin.jar"

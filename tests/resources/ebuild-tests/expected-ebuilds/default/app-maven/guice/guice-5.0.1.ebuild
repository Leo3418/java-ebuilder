# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/guice-5.0.1.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/com/google/inject/guice/5.0.1/guice-5.0.1-sources.jar --binjar-uri https://repo1.maven.org/maven2/com/google/inject/guice/5.0.1/guice-5.0.1.jar --slot 0 --keywords "~amd64" --ebuild guice-5.0.1.ebuild

EAPI=7

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="com.google.inject:guice:5.0.1"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Guice is a lightweight dependency injection framework for Java 6 and above"
HOMEPAGE="https://github.com/google/guice/guice"
SRC_URI="https://repo1.maven.org/maven2/com/google/inject/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/com/google/inject/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: /tmp/java-ebuilder/poms/${P}.pom
# aopalliance:aopalliance:1.0 -> >=dev-java/aopalliance-1.0:1
# com.google.guava:guava:30.1-jre -> >=dev-java/guava-30.1:0
# javax.inject:javax.inject:1 -> >=dev-java/javax-inject-1:0
# org.ow2.asm:asm:9.1 -> >=dev-java/asm-9.1:9

CDEPEND="
	>=dev-java/aopalliance-1.0:1
	>=dev-java/asm-9.1:9
	>=dev-java/guava-30.1:0
	>=dev-java/javax-inject-1:0
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

JAVA_GENTOO_CLASSPATH="aopalliance-1,guava,javax-inject,asm-9"
JAVA_SRC_DIR="src"
JAVA_BINJAR_FILENAME="${P}-bin.jar"

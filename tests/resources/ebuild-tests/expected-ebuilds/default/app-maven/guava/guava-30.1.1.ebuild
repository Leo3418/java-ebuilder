# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/guava-30.1.1-jre.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/com/google/guava/guava/30.1.1-jre/guava-30.1.1-jre-sources.jar --binjar-uri https://repo1.maven.org/maven2/com/google/guava/guava/30.1.1-jre/guava-30.1.1-jre.jar --slot 0 --keywords "~amd64" --ebuild guava-30.1.1.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="com.google.guava:guava:30.1.1-jre"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Guava is a suite of core and expanded libraries that include utility classes, Google's collections, I/O classes, and much more."
HOMEPAGE="https://github.com/google/guava/guava"
SRC_URI="https://repo1.maven.org/maven2/com/google/${PN}/${PN}/${PV}-jre/${P}-jre-sources.jar -> ${P}-sources.jar
	https://repo1.maven.org/maven2/com/google/${PN}/${PN}/${PV}-jre/${P}-jre.jar -> ${P}-bin.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: /tmp/java-ebuilder/poms/${P}-jre.pom
# com.google.code.findbugs:jsr305:3.0.2 -> >=dev-java/jsr305-3.0.2:0
# com.google.errorprone:error_prone_annotations:2.5.1 -> >=dev-java/error-2.5.1:prone_annotations
# com.google.guava:failureaccess:1.0.1 -> >=app-maven/failureaccess-1.0.1:0
# com.google.guava:listenablefuture:9999.0-empty-to-avoid-conflict-with-guava -> >=app-maven/listenablefuture-9999.0:0
# com.google.j2objc:j2objc-annotations:1.3 -> >=dev-java/j2objc-annotations-1.3:0
# org.checkerframework:checker-qual:3.8.0 -> >=app-maven/checker-qual-3.8.0:0

CDEPEND="
	>=app-maven/checker-qual-3.8.0:0
	>=app-maven/failureaccess-1.0.1:0
	>=app-maven/listenablefuture-9999.0:0
	>=dev-java/error-2.5.1:prone_annotations
	>=dev-java/j2objc-annotations-1.3:0
	>=dev-java/jsr305-3.0.2:0
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

JAVA_GENTOO_CLASSPATH="jsr305,error-prone_annotations,failureaccess,listenablefuture,j2objc-annotations,checker-qual"
JAVA_SRC_DIR="src"
JAVA_BINJAR_FILENAME="${P}-bin.jar"

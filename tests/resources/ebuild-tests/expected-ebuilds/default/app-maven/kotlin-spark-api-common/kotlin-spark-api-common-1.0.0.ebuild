# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/kotlin-spark-api-common-1.0.0-preview2.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/org/jetbrains/kotlinx/spark/kotlin-spark-api-common/1.0.0-preview2/kotlin-spark-api-common-1.0.0-preview2-sources.jar --binjar-uri https://repo1.maven.org/maven2/org/jetbrains/kotlinx/spark/kotlin-spark-api-common/1.0.0-preview2/kotlin-spark-api-common-1.0.0-preview2.jar --slot 0 --keywords "~amd64" --ebuild kotlin-spark-api-common-1.0.0.ebuild

EAPI=7

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="org.jetbrains.kotlinx.spark:kotlin-spark-api-common:1.0.0-preview2"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Kotlin API for Apache Spark: common parts"
HOMEPAGE="http://maven.apache.org/kotlin-spark-api-common"
SRC_URI="https://repo1.maven.org/maven2/org/jetbrains/kotlinx/spark/${PN}/${PV}-preview2/${P}-preview2-sources.jar -> ${P}-sources.jar
	https://repo1.maven.org/maven2/org/jetbrains/kotlinx/spark/${PN}/${PV}-preview2/${P}-preview2.jar -> ${P}-bin.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: /tmp/java-ebuilder/poms/${P}-preview2.pom
# org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.4.21 -> >=app-maven/kotlin-stdlib-jdk8-1.4.21:0

CDEPEND="
	>=app-maven/kotlin-stdlib-jdk8-1.4.21:0
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

JAVA_GENTOO_CLASSPATH="kotlin-stdlib-jdk8"
JAVA_SRC_DIR="src/main/java"
JAVA_BINJAR_FILENAME="${P}-bin.jar"

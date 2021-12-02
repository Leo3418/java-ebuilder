# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/spring-webmvc-5.3.8.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/org/springframework/spring-webmvc/5.3.8/spring-webmvc-5.3.8-sources.jar --binjar-uri https://repo1.maven.org/maven2/org/springframework/spring-webmvc/5.3.8/spring-webmvc-5.3.8.jar --slot 0 --keywords "~amd64" --ebuild spring-webmvc-5.3.8.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="org.springframework:spring-webmvc:5.3.8"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Spring Web MVC"
HOMEPAGE="https://github.com/spring-projects/spring-framework"
SRC_URI="https://repo1.maven.org/maven2/org/springframework/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/org/springframework/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: /tmp/java-ebuilder/poms/${P}.pom
# org.springframework:spring-aop:5.3.8 -> >=app-maven/spring-aop-5.3.8:0
# org.springframework:spring-beans:5.3.8 -> >=app-maven/spring-beans-5.3.8:0
# org.springframework:spring-context:5.3.8 -> >=app-maven/spring-context-5.3.8:0
# org.springframework:spring-core:5.3.8 -> >=app-maven/spring-core-5.3.8:0
# org.springframework:spring-expression:5.3.8 -> >=app-maven/spring-expression-5.3.8:0
# org.springframework:spring-web:5.3.8 -> >=app-maven/spring-web-5.3.8:0

CDEPEND="
	>=app-maven/spring-aop-5.3.8:0
	>=app-maven/spring-beans-5.3.8:0
	>=app-maven/spring-context-5.3.8:0
	>=app-maven/spring-core-5.3.8:0
	>=app-maven/spring-expression-5.3.8:0
	>=app-maven/spring-web-5.3.8:0
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

JAVA_GENTOO_CLASSPATH="spring-aop,spring-beans,spring-context,spring-core,spring-expression,spring-web"
JAVA_SRC_DIR="src/main/java"
JAVA_BINJAR_FILENAME="${P}-bin.jar"

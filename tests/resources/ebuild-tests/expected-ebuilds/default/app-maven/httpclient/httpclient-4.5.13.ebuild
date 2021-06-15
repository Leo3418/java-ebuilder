# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/httpclient-4.5.13.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13-sources.jar --binjar-uri https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.13/httpclient-4.5.13.jar --slot 0 --keywords "~amd64" --ebuild httpclient-4.5.13.ebuild

EAPI=7

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="org.apache.httpcomponents:httpclient:4.5.13"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Apache HttpComponents Client"
HOMEPAGE="http://hc.apache.org/httpcomponents-client"
SRC_URI="https://repo1.maven.org/maven2/org/apache/httpcomponents/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/org/apache/httpcomponents/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: /tmp/java-ebuilder/poms/${P}.pom
# commons-codec:commons-codec:1.11 -> >=dev-java/commons-codec-1.15:0
# commons-logging:commons-logging:1.2 -> >=dev-java/commons-logging-1.2:0
# org.apache.httpcomponents:httpcore:4.4.13 -> >=app-maven/httpcore-4.4.13:0

CDEPEND="
	>=app-maven/httpcore-4.4.13:0
	>=dev-java/commons-codec-1.15:0
	>=dev-java/commons-logging-1.2:0
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

JAVA_GENTOO_CLASSPATH="commons-codec,commons-logging,httpcore"
JAVA_SRC_DIR="src/main/java"
JAVA_BINJAR_FILENAME="${P}-bin.jar"

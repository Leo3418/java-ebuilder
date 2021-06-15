# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom /tmp/java-ebuilder/poms/clojure-1.10.3.pom --from-maven-central --download-uri https://repo1.maven.org/maven2/org/clojure/clojure/1.10.3/clojure-1.10.3-sources.jar --binjar-uri https://repo1.maven.org/maven2/org/clojure/clojure/1.10.3/clojure-1.10.3.jar --slot 0 --keywords "~amd64" --ebuild clojure-1.10.3.ebuild

EAPI=7

JAVA_PKG_IUSE="doc source test binary"
MAVEN_ID="org.clojure:clojure:1.10.3"
JAVA_TESTING_FRAMEWORKS="pkgdiff"

inherit java-pkg-2 java-pkg-simple java-pkg-maven

DESCRIPTION="Clojure core environment and runtime library."
HOMEPAGE="http://clojure.org/"
SRC_URI="https://repo1.maven.org/maven2/org/${PN}/${PN}/${PV}/${P}-sources.jar
	https://repo1.maven.org/maven2/org/${PN}/${PN}/${PV}/${P}.jar -> ${P}-bin.jar"
LICENSE="EPL-1.0"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: /tmp/java-ebuilder/poms/${P}.pom
# org.clojure:core.specs.alpha:0.2.56 -> >=dev-java/core-specs-alpha-0.2.56:0.2
# org.clojure:spec.alpha:0.2.194 -> >=dev-java/spec-alpha-0.2.194:0.2

CDEPEND="
	>=dev-java/core-specs-alpha-0.2.56:0.2
	>=dev-java/spec-alpha-0.2.194:0.2
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

JAVA_GENTOO_CLASSPATH="core-specs-alpha-0.2,spec-alpha-0.2"
JAVA_SRC_DIR="src/main/java"
JAVA_BINJAR_FILENAME="${P}-bin.jar"

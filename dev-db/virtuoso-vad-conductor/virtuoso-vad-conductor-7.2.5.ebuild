# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit virtuoso

DESCRIPTION="ODBC driver for OpenLink Virtuoso Open-Source Edition"

KEYWORDS="~amd64 ~arm ppc ppc64 x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="
	>=dev-libs/openssl-0.9.7i:0
	>=dev-db/virtuoso-server-7.2.5
"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${PN}-7.2.5-am_config_header.patch" )

VOS_EXTRACT="
	binsrc/yacutia
	binsrc/installer
	binsrc/vad
	binsrc/samples/demo
	docsrc/images/ui
	docsrc/vsp/doc
"

src_configure() {
	myconf+="
		--disable-static
		--without-iodbc
	"

	virtuoso_src_configure
}

src_compile() {
	emake -j1
}

src_install() {
	default_src_install

	# Remove libtool files
	find "${ED}" -name '*.la' -delete
}

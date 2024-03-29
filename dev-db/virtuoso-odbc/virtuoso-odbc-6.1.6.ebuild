# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/virtuoso-odbc/virtuoso-odbc-6.1.6.ebuild,v 1.6 2014/03/07 03:28:28 creffett Exp $

EAPI=7

inherit virtuoso

DESCRIPTION="ODBC driver for OpenLink Virtuoso Open-Source Edition"

KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="
	>=dev-libs/openssl-1.1.0:0
"
DEPEND="${RDEPEND}"

DOCS=( AUTHORS ChangeLog CREDITS INSTALL NEWS README )

PATCHES=(
	"${FILESDIR}/${PN}-6.1.6-am_config_header.patch"
	"${FILESDIR}/virtuoso-opensource-build-against-openssl-1.1.0.patch"
)

VOS_EXTRACT="
	libsrc/Dk
	libsrc/Thread
	libsrc/odbcsdk
	libsrc/util
	binsrc/driver
"

src_configure() {
	myconf+="
		--disable-static
		--without-iodbc
	"

	virtuoso_src_configure
}

src_install() {
	default_src_install

	# Remove libtool files
	find "${ED}" -name '*.la' -delete
	# and unrelated documentation files.
	find "${ED}"/usr/share/doc/virtuoso -delete
}

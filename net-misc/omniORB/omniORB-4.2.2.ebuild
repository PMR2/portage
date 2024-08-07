# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit python-utils-r1

MY_P="${P/_p/-}"
DESCRIPTION="A robust, high-performance CORBA 2 ORB"
HOMEPAGE="http://omniorb.sourceforge.net/"
SRC_URI="https://dist.physiomeproject.org/distfiles/${MY_P}.tar.bz2"

LICENSE="LGPL-2 GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 ~sparc x86"
IUSE="doc ipv6 ssl"

RDEPEND="dev-lang/python:2.7
	ssl? ( dev-libs/openssl:0= )"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	# The OPTC(XX)FLAGS variables aren't present in these files, but we
	# will set them when we call emake.
	sed \
		-e 's/^CXXDEBUGFLAGS.*/CXXDEBUGFLAGS = $(OPTCXXFLAGS)/' \
		-e 's/^CDEBUGFLAGS.*/CDEBUGFLAGS = $(OPTCFLAGS)/' \
		-i mk/beforeauto.mk.in mk/platforms/i586_linux_2.0*.mk || \
		die 'failed to switch CFLAGS variables in the makefile includes'

	# The out-of-source build is suggested by upstream.
	mkdir build || die 'failed to create build directory'

	# Manually create the python2.7 wrapper, as this version is the only one
	# that is usable for the CellML API.
	export EPYTHON="python2.7"
	export PYTHON="${EPREFIX}/usr/bin/python2.7"
	_python_wrapper_setup
}

src_configure() {
	cd build || die 'failed to change into the build directory'

	ECONF_SOURCE=".." econf \
				--disable-static \
				--with-omniORB-config=/etc/omniorb/omniORB.cfg \
				--with-omniNames-logdir=/var/log/omniORB \
				--libdir="/usr/$(get_libdir)" \
				$(use_enable ipv6) \
				$(use_with ssl openssl "/usr")
}

src_compile() {
	cd build || die 'failed to change into the build directory'
	emake OPTCFLAGS="${CFLAGS} -std=gnu89" OPTCXXFLAGS="${CXXFLAGS} -std=c++14"
}

src_install() {
	cd build || die 'failed to change into the build directory'
	default

	rm "${ED}/usr/bin/omniidlrun.py" || \
		die 'failed to remove redundant omniidlrun.py'

	cd "${S}" || die "failed to change into the ${S} directory"

	dodoc CREDITS doc/*.html ReleaseNotes.txt update.log
	dodoc -r doc/omniORB

	if use doc; then
		dodoc doc/*.pdf
	fi

	cat <<- EOF > "${T}/90omniORB"
		PATH="/usr/share/omniORB/bin/scripts"
		OMNIORB_CONFIG="/etc/omniorb/omniORB.cfg"
	EOF
	doenvd "${T}/90omniORB"
	doinitd "${FILESDIR}"/omniNames

	cp "sample.cfg" "${T}/omniORB.cfg" || die
	cat <<- EOF >> "${T}/omniORB.cfg"
		# resolve the omniNames running on localhost
		InitRef = NameService=corbaname::localhost
	EOF
	insinto /etc/omniorb
	doins "${T}"/omniORB.cfg

	keepdir /var/log/omniORB

	python_optimize
	python_fix_shebang "${ED}"/usr/bin/omniidl
}

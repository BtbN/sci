# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools bash-completion eutils

DESCRIPTION="Votca coarse-graining engine"
HOMEPAGE="http://www.votca.org"
SRC_URI="http://votca.googlecode.com/files/${PF}.tar.gz
	http://www.votca.org/downloads/${PF}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="-boost static"

RDEPEND="dev-libs/expat
	boost? ( >=dev-libs/boost-1.33.1 )
	=sci-libs/votca-tools-${PV}
	>sci-chemistry/gromacs-4.0.5
	dev-lang/perl
	app-shells/bash"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/"${PF}"-aclocal.patch

	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	local myconf="--disable-la-files"

	myconf="${myconf} $(use_with boost)"
	myconf="${myconf} $(use_enable static all-static)"

	econf ${myconf} || die "econf failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc README NOTICE CHANGELOG

	sed -n -e 's/^export //' -e '/^CSGSHARE/p' \
		"${D}"/usr/share/votca/rc/csg.rc.bash >> "${T}/80${PN}"
	doenvd "${T}/80${PN}"

	#from votca-tools
	if [ -f /usr/share/votca/completion.bash ]; then
		cat /usr/share/votca/completion.bash > "${T}/completion.bash"
		cat "${D}"/usr/share/votca/rc/csg-completion.bash >> "${T}/completion.bash"
	    dobashcompletion "${T}"/completion.bash ${PN}
	fi
	rm -f "${D}"/usr/share/votca/rc/*
}

pkg_postinst() {
	env-update
	elog
	elog "Please read and cite:"
	elog "VOTCA, J. Chem. Theory Comput. 5, 3211 (2009). "
	elog "http://dx.doi.org/10.1021/ct900369w"
	elog
}

pkg_postrm() {
	env-update
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit flag-o-matic autotools

GIT_TAG=
GIT_HASH=

DESCRIPTION="A curses-based IM client"
HOMEPAGE="http://barnowl.mit.edu/"
if [ -n "${GIT_TAG}" ] ; then
	SRC_URI="https://github.com/barnowl/barnowl/tarball/${PN}-${GIT_TAG}
			   -> ${P}-git.tar.gz"
else
	SRC_URI="http://barnowl.mit.edu/dist/${P}-src.tgz"
fi

SLOT="0"
LICENSE="DB LGPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="+zephyr irc jabber twitter wordwrap"

COMMON_DEPEND="dev-lang/perl
			   dev-libs/openssl
			   dev-libs/glib
			   sys-libs/ncurses[unicode]
			   dev-perl/PAR
			   dev-perl/Class-Accessor
			   zephyr? ( net-im/zephyr )"
DEPEND="${COMMON_DEPEND}
		dev-util/pkgconfig
		app-arch/zip"
RDEPEND="${COMMON_DEPEND}
		 jabber? ( dev-perl/Net-DNS
				   dev-perl/Authen-SASL
				   dev-perl/IO-Socket-SSL
				   dev-perl/Digest-SHA1 )
		 twitter? ( dev-perl/HTML-Parser
					dev-perl/Net-Twitter-Lite )
		 irc? ( dev-perl/Net-IRC )
		 wordwrap? ( dev-perl/text-autoformat )"

if [ -n "${GIT_HASH}" ] ; then
	S="${WORKDIR}/barnowl-barnowl-${GIT_HASH}"
else
	S="${WORKDIR}/${P}-src"
fi

src_prepare() {
	use jabber || \
		sed -i -e '/^MODULES =/s/Jabber//'   perl/modules/Makefile.am
	use irc || \
		sed -i -e '/^MODULES =/s/IRC//'      perl/modules/Makefile.am
	use wordwrap || \
		sed -i -e '/^MODULES =/s/WordWrap//' perl/modules/Makefile.am
	use twitter || \
		sed -i -e '/^MODULES =/s/Twitter//'  perl/modules/Makefile.am
	eautoreconf
}

src_configure() {
	append-cppflags -D_GNU_SOURCE
	econf --docdir="/usr/share/doc/${PF}" \
		--without-stack-protector \
		--without-krb4 \
		$(use_with zephyr)
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"

	dodoc AUTHORS ChangeLog || die
}

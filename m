From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 29 Sep 2014 08:59:09 +0000
Subject: Re: [PATCH v4 6/8] asm-generic/io.h: Implement generic {read,write}s*()
Message-Id: <20140929085908.GI12506@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="j+MD90OnwjQyWNYt"
List-Id: <linux-ia64.vger.kernel.org>
References: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
 <1407925738-26170-7-git-send-email-thierry.reding@gmail.com>
 <CAMuHMdW4emoma3nRUGna985tE17yPh5pNjMb-jxe5yc5UVr=cw@mail.gmail.com>
In-Reply-To: <CAMuHMdW4emoma3nRUGna985tE17yPh5pNjMb-jxe5yc5UVr=cw@mail.gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Linux-Arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, the arch/x86 maintainers <x86@kernel.org>, Stephen Boyd <sboyd@codeaurora.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-serial@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Sam Ravnborg <sam@ravnborg.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>


--j+MD90OnwjQyWNYt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 29, 2014 at 10:54:34AM +0200, Geert Uytterhoeven wrote:
> On Wed, Aug 13, 2014 at 12:28 PM, Thierry Reding
> <thierry.reding@gmail.com> wrote:
> > #ifndef memset_io
> > -#define memset_io(a, b, c)     memset(__io_virt(a), (b), (c))
> > +#define memset_io memset_io
> > +static inline void memset_io(void __iomem *addr, int value, size_t siz=
e)
> > +{
> > +       memset(__io_virt(addr), value, size);
> > +}
> >  #endif
>=20
> xtensa/allmodconfig:
>=20
> include/asm-generic/io.h:820:2: error: implicit declaration of
> function 'memset' [-Werror=3Dimplicit-function-declaration]
> include/asm-generic/io.h:829:2: error: implicit declaration of
> function 'memcpy' [-Werror=3Dimplicit-function-declaration]
> arch/xtensa/include/asm/string.h:110:14: error: conflicting types for 'me=
mset'
> arch/xtensa/include/asm/string.h:113:14: error: conflicting types for 'me=
mcpy'
>=20
> http://kisskb.ellerman.id.au/kisskb/buildresult/12028900/

I think this can be fixed by including linux/string.h for memset() and
memcpy() in include/asm-generic/io.h.

Thanks,
Thierry

--j+MD90OnwjQyWNYt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUKR9cAAoJEN0jrNd/PrOhASUP/RvBIHM071cnw1PJ7yxsJ3L9
Ye2u9bLq3ieMzN64dyKlZ0WDnlL0Zqian8oSeGFdff3yRUHaL54OA/U7AuOFX6D5
PWltAOtP0gdrxIllmD+5mAORzTq+/4nE90FsKYKaF00CLdHe03PrrNCSoQL8AjKM
LOLlyM7FK0zSpu8fX888PxFSbmWRrtvN5pRgW6FuDg7CFB6ngMguZ8Ez8vGlQBJp
a/9c4FKxzJSxnmyKsV9jXSfLMTGNach+gtU99i86nTiDCoJvmx8C8nLOr9eCYmet
YgpAiyZY0lDR5TZu9PmDum5UwQWD/0GUU5nSa98GrevvLk+TRVIbKCXVpxeos7Pb
d872N+plfgUX4Pyy3RotpRvvwdNckKiPS+T6uYL/7oAlu/zuuOQ+XFNs7UGw9a0Z
rVOkIUdud+hVuS//oqzu3z2SRPItcT00d7TZDcGcQdFNx8uIYi1df0elBVYYrgGN
EWe+AWDuBvwBRFWz6w8TQpsRjzs44OP3FfEKtOAqzhyjVNuVZaH7yBNiVILdpzop
/iLGFJ4mQk0wV3w/Sszf+LFV7RRq7cjbwbp4fqKRCKQmcSpJ5xnA71ONHiACQ61h
H0jJjja1A2/0lTM2N27vWT70y2lUay60FG2Y6k5uD9LfsQB0GamL90u4wgpiH8zm
nDA3G2WCAde4Al0seiYx
=bajY
-----END PGP SIGNATURE-----

--j+MD90OnwjQyWNYt--

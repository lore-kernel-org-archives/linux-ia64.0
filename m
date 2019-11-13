From: Aleksa Sarai <cyphar@cyphar.com>
Date: Wed, 13 Nov 2019 02:35:37 +0000
Subject: Re: [PATCH v15 7/9] open: introduce openat2(2) syscall
Message-Id: <20191113023537.epcgw5u2fdbinnyj@yavin.dot.cyphar.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ohhoiky5cv3wybqd"
List-Id: <linux-ia64.vger.kernel.org>
References: <20191105090553.6350-1-cyphar@cyphar.com>
 <20191105090553.6350-8-cyphar@cyphar.com>
 <20191113022906.GD26530@ZenIV.linux.org.uk>
In-Reply-To: <20191113022906.GD26530@ZenIV.linux.org.uk>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Alexei Starovoitov <ast@kernel.org>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-kselftest@vger.kernel.org, sparclinux@vger.kernel.org, Jiri Olsa <jolsa@redhat.com>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Tycho Andersen <tycho@tycho.ws>, Aleksa Sarai <asarai@suse.de>, Shuah Khan <shuah@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>, linuxppc-dev@lists.ozlabs.org, linux-m68k@lists.linux-m68k.org, Andy Lutomirski <luto@kernel.org>, Shuah Khan <skha>


--ohhoiky5cv3wybqd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2019-11-13, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Tue, Nov 05, 2019 at 08:05:51PM +1100, Aleksa Sarai wrote:
> > +/*
> > + * Arguments for how openat2(2) should open the target path. If @resol=
ve is
> > + * zero, then openat2(2) operates very similarly to openat(2).
> > + *
> > + * However, unlike openat(2), unknown bits in @flags result in -EINVAL=
 rather
> > + * than being silently ignored. @mode must be zero unless one of {O_CR=
EAT,
> > + * O_TMPFILE} are set, and @upgrade_mask must be zero unless O_PATH is=
 set.
> > + *
> > + * @flags: O_* flags.
> > + * @mode: O_CREAT/O_TMPFILE file mode.
> > + * @upgrade_mask: UPGRADE_* flags (to restrict O_PATH re-opening).
>=20
> ???

Sorry, that was left over from a previous revision (where the magic-link
re-opening restrictions were part of this series).

> > + * @resolve: RESOLVE_* flags.
> > + */
> > +struct open_how {
> > +	__aligned_u64 flags;
> > +	__u16 mode;
> > +	__u16 __padding[3]; /* must be zeroed */
> > +	__aligned_u64 resolve;
> > +};


--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--ohhoiky5cv3wybqd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQSxZm6dtfE8gxLLfYqdlLljIbnQEgUCXctr9QAKCRCdlLljIbnQ
Ej91AQDSESPrMbumo+B1bVc2FthUOUuONyqVLG0aRmu7PQjnOgD7BOxMC9suhDip
ayqrtLJhXKxmKpbFt69x0a97Rx8tGQ8=
=4v0x
-----END PGP SIGNATURE-----

--ohhoiky5cv3wybqd--

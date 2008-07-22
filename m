From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 22 Jul 2008 10:36:35 +0000
Subject: Re: [PATCH] Make u64 long long on all architectures (was: the
Message-Id: <1216722995.8357.4.camel@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-zzXwhI2BCaAafcumruBA"
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com>
	 <20080704104634.GA31634@digi.com>
	 <20080704111540.ddffd241.akpm@linux-foundation.org>
	 <alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	 <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	 <20080704132716.f1e12554.akpm@linux-foundation.org>
	 <20080704204252.GM14894@parisc-linux.org>
	 <20080704150100.1f7b8a65.akpm@linux-foundation.org>
	 <20080705020350.GN14894@parisc-linux.org>
	 <20080722030506.206a2cc2.akpm@linux-foundation.org>
In-Reply-To: <20080722030506.206a2cc2.akpm@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>


--=-zzXwhI2BCaAafcumruBA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-07-22 at 03:05 -0700, Andrew Morton wrote:
> On Fri, 4 Jul 2008 20:03:51 -0600 Matthew Wilcox <matthew@wil.cx> wrote:
>=20
> > [PATCH] Make u64 long long on all architectures
> >=20
> > It is currently awkward to print a u64 type.  Some architectures use
> > unsigned long while others use unsigned long long.  Since unsigned long
> > long is 64-bit for all existing Linux architectures, change those that
> > use long to use long long.  Note that this applies only within the
> > kernel.  If u64 is being used in a C++ method definition, the symbol
> > mangling would change.
> >=20
> > Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> >=20
> > diff --git a/include/asm-generic/int-l64.h b/include/asm-generic/int-l6=
4.h
> > index 2af9b75..32f07bd 100644
> > --- a/include/asm-generic/int-l64.h
> > +++ b/include/asm-generic/int-l64.h
> > @@ -23,8 +23,13 @@ typedef unsigned short __u16;
> >  typedef __signed__ int __s32;
> >  typedef unsigned int __u32;
> > =20
> > +#ifdef __KERNEL__
> > +typedef __signed__ long long __s64;
> > +typedef unsigned long long __u64;
> > +#else
> >  typedef __signed__ long __s64;
> >  typedef unsigned long __u64;
> > +#endif
> > =20
> >  #endif /* __ASSEMBLY__ */
>=20
> This is (IMO) a desirable change and will prevent a heck of a lot of
> goofing around, and will permit a lot of prior goofing around to
> be removed.
>=20
> But I bet there are lots of instalces of printk("%l", some_u64) down in
> arch code where the type of u64 _is_ known which will now spew warnings.
>=20
> Oh well.

As a rough estimate:

concordia powerpc(master) $ find arch/powerpc/ ! -name '*32.*' | xargs grep=
 "%l" | grep -v "%ll" | wc -l
635


Someone's gonna get a lot of git points for fixing all those. Might keep
the speeling fix crowd busy for a while.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-zzXwhI2BCaAafcumruBA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIhbgzdSjSd0sB4dIRArTZAKDHBi9mo4QUVr2xO/c5+WSAnSLG1ACdHXy4
A41TJDlZFWkrWfHH1UMztEA=
=Smrs
-----END PGP SIGNATURE-----

--=-zzXwhI2BCaAafcumruBA--


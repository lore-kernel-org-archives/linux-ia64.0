From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Wed, 24 Oct 2001 19:46:41 +0000
Subject: RE: [Linux-ia64] C union on ia-64
Message-Id: <marc-linux-ia64-105590698805386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-9"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

That slide looks to me like it escaped from a presentation on 64-bit Windows
programming, where "unsigned long" is 4 bytes long, unlike "void *", and
where it's customary to call both types by different names. =20

It is never legal C to union the two structures store into one structure
field, and retrieve the value through a field in the other structure.  In
many cases it may work, but it is officially undefined, and hence allowed to
confuse the compiler's alias analysis.  Thus the compiler is entitled to
generate incorrect code.  This applies to all platforms.

In the 64-bit Windows case, this sort of thing is guaranteed to fail, since
the fields also don't line up correctly.  On the Linux side, there is no
difference between the 64-bit and 32-bit cases. =20

Unless there's a better explanation, could someone at Intel correct this?

Hans

> -----Original Message-----
> From: Gururaj Ananthateerta [mailto:gururaj@cup.hp.com]
> Sent: Wednesday, October 24, 2001 11:53 AM
> To: Andreas Schwab
> Cc: KOCHI, Takayoshi; linux-64
> Subject: Re: [Linux-ia64] C union on ia-64
>=20
>=20
> http://developer.intel.com/design/itanium/linuxDDPorting/sld025.htm
>=20
> The above link provides an example.
>=20
>=20
>=20
> Andreas Schwab wrote:
>=20
> > Gururaj Ananthateerta <gururaj@cup.hp.com> writes:
> >
> > |> Anyone experienced (memory corruption ) problems with=20
> unions on ia-64.
> > |> I have found couple of documents which discourages the=20
> use of unions on
> > |> ia-64 in particular.
> >
> > Please expand.  Unions are an integral part of C, without=20
> them you could
> > not call it C.
> >
> > Andreas.
> >
> > --
> > Andreas Schwab                                  "And now=20
> for something
> > Andreas.Schwab@suse.de                          completely=20
> different."
> > SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
> > Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20


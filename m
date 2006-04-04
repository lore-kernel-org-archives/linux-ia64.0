From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 04 Apr 2006 06:07:58 +0000
Subject: Re: [Fastboot] Re: [PATCH] kexec on ia64
Message-Id: <1144130879.29756.11.camel@localhost.localdomain>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-mUP8jHBGvwM4iAqIVSJ1"
List-Id: <linux-ia64.vger.kernel.org>
References: <1144102818.8279.6.camel@localhost.localdomain>
	 <20060403212049.480ad388.akpm@osdl.org>
In-Reply-To: <20060403212049.480ad388.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Khalid Aziz <khalid_aziz@hp.com>, linux-ia64@vger.kernel.org, fastboot@lists.osdl.org, linux-kernel@vger.kernel.org


--=-mUP8jHBGvwM4iAqIVSJ1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-04-03 at 21:20 -0700, Andrew Morton wrote:
> Khalid Aziz <khalid_aziz@hp.com> wrote:
> > +/*
> > + * Terminate any outstanding interrupts
> > + */
> > +void terminate_irqs(void)
> > +{
> > +	struct irqaction * action;
> > +	irq_desc_t *idesc;
> > +	int i;
> > +
> > +	for (i=3D0; i<NR_IRQS; i++) {
>=20
> 	for (i =3D 0; i < NR_IRQS; i++) {
>=20
> > +		idesc =3D irq_descp(i);
> > +		action =3D idesc->action;
> > +		if (!action)
> > +			continue;
> > +		if (idesc->handler->end)
> > +			idesc->handler->end(i);
> > +	}
> > +}
>=20
> Could we have a bit more description of what this function does, and why =
we
> need it?
>=20
> Should other kexec-using architectures be using this?  If not, why does
> ia64 need it?

We've been kicking around a patch to do something similar, we also eoi
anything that's outstanding. I can't find the patch just now, but it's
on linuxppc somewhere I think.

cheers

--=20
Michael Ellerman
IBM OzLabs

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-mUP8jHBGvwM4iAqIVSJ1
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEMg0+dSjSd0sB4dIRAgIBAJ94wIIGbAjYSxFFw3lLB67gq/4BBgCfZHk6
6yDkgrajRYWfS5wbEXIy1rE=
=Ykix
-----END PGP SIGNATURE-----

--=-mUP8jHBGvwM4iAqIVSJ1--


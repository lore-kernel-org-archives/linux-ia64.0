From: Julia Lawall <julia@diku.dk>
Date: Mon, 12 May 2008 14:37:46 +0000
Subject: Re: [PATCH 1/6] arch/ia64/kernel: remove null pointer dereference
Message-Id: <Pine.LNX.4.64.0805121637180.3694@ask.diku.dk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-511516320-175496707-1210603066=:3694"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0805121536370.3694@ask.diku.dk>
 <1210603050.25310.9.camel@odie.local>
In-Reply-To: <1210603050.25310.9.camel@odie.local>
To: Simon Holm =?ISO-8859-1?Q?Th=F8gersen?= <odie@cs.aau.dk>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-175496707-1210603066=:3694
Content-Type: TEXT/PLAIN; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Mon, 12 May 2008, Simon Holm Th=F8gersen wrote:

> man, 12 05 2008 kl. 15:37 +0200, skrev Julia Lawall:
> > From: Julia Lawall <julia@diku.dk>
> >=20
> > If data is NULL, it is not possible to access data->ret.
> >=20
> > The problem was detected using the following semantic match
> > (http://www.emn.fr/x-info/coccinelle/)
> >=20
> > // <smpl>
> > @@
> > expression E, E1;
> > identifier f;
> > statement S1,S2,S3;
> > @@
> >=20
> > * if (E =3D=3D NULL)
> > {
> >   ... when !=3D if (E =3D=3D NULL) S1 else S2
> >       when !=3D E =3D E1
> > * E->f
> >   ... when any
> >   return ...;
> > }
> > else S3
> > // </smpl>
> >=20
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> >=20
> > ---
> >=20
> > diff -u -p a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
> > --- a/arch/ia64/kernel/palinfo.c	2008-05-09 16:46:57.000000000 +0200
> > +++ b/arch/ia64/kernel/palinfo.c	2008-05-12 08:43:35.000000000 +0200
> > @@ -902,7 +902,6 @@ palinfo_smp_call(void *info)
> >  	palinfo_smp_data_t *data =3D (palinfo_smp_data_t *)info;
> >  	if (data =3D=3D NULL) {
> >  		printk(KERN_ERR "palinfo: data pointer is NULL\n");
> > -		data->ret =3D 0; /* no output */
> >  		return;
> >  	}
> >  	/* does this actual call */
> > --
>=20
> The whole if block should just be deleted, as info is never NULL. There
> is only palinfo_handle_smp as (indirect) user of palinfo_smp_call (by
> way of smp_call_function_single) and surely palinfo_smp_call never pass
> NULL.

OK.  Will you fix it?

julia
---511516320-175496707-1210603066=:3694--

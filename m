From: Martin Hicks <mort@bork.org>
Date: Tue, 09 Dec 2003 13:46:06 +0000
Subject: Re: q-tools OOPS: Fixed perfmon.
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-zaQe+fwGTvq/+VNhQFOx"
Message-Id: <marc-linux-ia64-107097806311546@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092926502909@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092926502909@msgid-missing>
To: linux-ia64@vger.kernel.org


--=-zaQe+fwGTvq/+VNhQFOx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2003-12-08 at 20:24, Matthew Wilcox wrote:
> On Tue, Dec 09, 2003 at 11:17:56AM +1100, Peter Chubb wrote:
> > Here's a  fix for non-preemption safety in perfmon.c.
> >=20
> > I haven't tried it while running a preemption stress test, but this
> > allows q-syscollect to work.
> >=20
> > =3D=3D=3D=3D=3D arch/ia64/kernel/perfmon.c 1.67 vs edited =3D=3D=3D=3D=
=3D
> > --- 1.67/arch/ia64/kernel/perfmon.c   Tue Oct 28 17:36:50 2003
> > +++ edited/arch/ia64/kernel/perfmon.c Tue Dec  9 10:55:58 2003
> > @@ -5475,7 +5475,7 @@
> > 	int this_cpu;
> > 	int ret;
> > =20
> > -	this_cpu =3D smp_processor_id();
> > +	this_cpu =3D get_cpu();
> > 	min      =3D pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min;
> > 	max      =3D pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max;
>=20
> surely there needs to be a matching put_cpu() or else preempt is forever
> disabled.  no?

I agree.

(from include/linux/smp.h)
#define get_cpu()               ({ preempt_disable(); smp_processor_id(); }=
)
#define put_cpu()               preempt_enable()

mh

--=20
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

--=-zaQe+fwGTvq/+VNhQFOx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/1dIe0ZUZrUx/K+4RAgI5AKCeT1gY7h7Sq8ANMQDQ70pII8hjjACgs6xO
jlKIDgm2I0/SNcACTrCmkzM=
=VuV+
-----END PGP SIGNATURE-----

--=-zaQe+fwGTvq/+VNhQFOx--


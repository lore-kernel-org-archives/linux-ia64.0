From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Tue, 14 Sep 2004 10:53:03 +0000
Subject: Re: IA64 probe instruction
Message-Id: <20040914105303.GA16350@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
List-Id: <linux-ia64.vger.kernel.org>
References: <4146C00A.8060505@hob.de>
In-Reply-To: <4146C00A.8060505@hob.de>
To: linux-ia64@vger.kernel.org


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Christian

We have an ia64 technical mailing list at:
ia64-technical@gelato.unsw.edu.au

that has just started for this pariticlar type
of question you can sign up for the list at:
https://www.gelato.unsw.edu.au/mailman/listinfo/ia64-technical

Regards
Darren

On Tue, 14 Sep 2004, Christian Hildner wrote:

> Hi,
>=20
> there is  behavior of the probe instruction that confuses me a little=20
> bit. Testing of the attached module shows differences whether executed=20
> with interrupts enabled or not.
>=20
> # cat cpuinfo
> processor  : 0
> vendor     : GenuineIntel
> arch       : IA-64
> family     : Itanium 2
> model      : 0
> revision   : 7
> archrev    : 0
> features   : branchlong
> cpu number : 0
> cpu regs   : 4
> cpu MHz    : 900.000000
> itc MHz    : 900.000000
> BogoMIPS   : 1346.37
>=20
> #dmesg
> init_module called ...
> init_module result 0x0000000000000001
> init_module done
> cleanup_module called ...
> Unable to handle kernel paging request at virtual address e00000404391fe30
> ...
>=20
> Of course the reported address has nothing to do with the (nested!)=20
> fault of the second
> probe instruction since interrupt resources are not written. But why=20
> does the second
> probe interrupt instead of returning 0 or 1? The reference manual does=20
> not distinct between
> psr.ic 0 or 1.
>=20
> Although this is not really linux related maybe someone from Intel can=20
> comment on this.
>=20
> Christian

> #include <linux/kernel.h>
> #include <linux/module.h>
>=20
> MODULE_DESCRIPTION("Probe test");
> MODULE_AUTHOR("Christian Hildner");
> MODULE_LICENSE("GPL");
>=20
> int init_module(void)
> {
>     unsigned long addr;
>     unsigned long res;
>=20
>     printk("init_module called ...\n");
>     asm volatile ("\n\n"
>         "movl %0=3D0xe000100000000000\n\n"
>         ";;\n\n"
>         "probe.r %1=3D%0,0\n\n"
>         ";;\n\n"
>         : "=3Dr"(addr), "=3Dr"(res)
>         :);
>     printk("init_module result 0x%016lx\n", res);
>     printk("init_module done\n");
>     return(0);
> }
>=20
> void cleanup_module(void)
> {
>     unsigned long addr;
>     unsigned long res;
>=20
>     printk("cleanup_module called ...\n");
>     asm volatile ("\n\n"
>         "rsm psr.i | psr.ic\n\n"
>         "movl %0=3D0xe000100000000000\n\n"
>         ";;\n\n"
>         "srlz.i\n\n"
>         ";;\n\n"
>         "probe.r %1=3D%0,0\n\n"
>         ";;\n\n"
>         "ssm psr.ic\n\n"
>         ";;\n\n"
>         "srlz.d\n\n"
>         "ssm psr.i\n\n"
>         ";;\n\n"
>         "srlz.i\n\n"
>         ";;\n\n"
>         : "=3Dr"(addr), "=3Dr"(res)
>         :);
>     printk("cleanup_module result 0x%016lx\n", res);
>     printk("cleanup_module done\n");
>     return;
> }
>=20

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBRs2PLlUoiSll48sRAguUAJ99lS4maZoecc1tuC2Z7xUysKf0UACeNrYS
SHKTQk9gNJaQBtj3Bu2esK8=
=/FPL
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--

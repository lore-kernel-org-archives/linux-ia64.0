From: Xavier Bru <Xavier.Bru@bull.net>
Date: Thu, 28 Aug 2003 16:38:41 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106208914905331@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Martin,

Thanks for answering my mail. I applied Jesse's patch ([PATCH] latest
discontig mail dated Fri, 8 Aug 2003) but this does'nt build with:
	CONFIG_NUMA=3Dy
	CONFIG_ACPI_NUMA=3Dy
	CONFIG_DISCONTIGMEM=3Dy
	# CONFIG_VIRTUAL_MEM_MAP is not set
I get:
include/linux/mm.h: In function `lowmem_page_address':
include/linux/mm.h:349: `mem_map' undeclared (first use in this function)

It seems that this only works on Altix, unless I missed something.

BTW, applying your patch for removing alloc_bootmem and moving back
find_memory() to its previous place, system boots OK.
Thanks again for your help.

Xavier
---------------------------------------------------------------------------=
--
diff --exclude-from /users/xb/proc/diff.exclude -r 0t4/arch/ia64/kernel/set=
up.c linux-2.6.0-test4/arch/ia64/kernel/setup.c
374a375
> 	find_memory();
388,389d388
< 	find_memory();
<=20
diff --exclude-from /users/xb/proc/diff.exclude -r 0t4/drivers/acpi/tables.=
c linux-2.6.0-test4/drivers/acpi/tables.c
72,73c72
<=20
< static struct acpi_table_sdt	sdt_entry[ACPI_MAX_TABLES];
---
> static struct acpi_table_sdt	*sdt_entry;
428a428,433
> 		sdt_entry =3D alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt));
> 		if (!sdt_entry) {
> 			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
> 			return -ENOMEM;
> 		}
>=20
474a480,485
> 		sdt_entry =3D alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt));
> 		if (!sdt_entry) {
> 			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
> 			return -ENOMEM;
> 		}
>=20

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


Martin Hicks writes:
 >=20
 >=20
 > On Tue, Aug 26, 2003 at 05:39:32PM +0200, Xavier Bru wrote:
 > >=20
 > > I tried to put find_memory()  after acpi_numa_init() as in 2.5.72, but=
=20
 > > now we get:
 > >      bootmem alloc of 100 bytes failed! in acpi_table_init()
 > > that now uses the bootmem allocator.
 > >=20
 > > I wonder what should be the right order for initialisation, and if
 > > there are ia64 platforms running 2.6.0 with CONFIG_NUMA. Any help is
 > > apreciated.
 >=20
 > Jesse Barnes has an unreleased patch to make SGI SN2 work, which does
 > move the find_memory() after acpi_numa_init().  There is another patch,
 > which I've attached, which removes the bootmem alloc of memory in ACPI.
 >=20
 > I haven't played with this recently, so your mileage may vary.  Jesse
 > should be back from vacation next week, and should release updated SN2
 > patches then.
 >=20
 > mh
 >=20
 > --=20
 > Wild Open Source Inc.                  mort@wildopensource.com
 >=20
 >=20
 > # This is a BitKeeper generated patch for the following project:
 > # Project Name: Linux kernel tree
 > # This patch format is intended for GNU patch command version 2.5 or hig=
her.
 > # This patch includes the following deltas:
 > #	           ChangeSet	1.1395  -> 1.1396=20
 > #	drivers/acpi/tables.c	1.14    -> 1.15  =20
 > #
 > # The following is the BitKeeper ChangeSet Log
 > # --------------------------------------------
 > # 03/07/30	jbarnes@tomahawk.engr.sgi.com	1.1396
 > # don't use alloc_bootmem in acpi table init
 > # --------------------------------------------
 > #
 > diff -Nru a/drivers/acpi/tables.c b/drivers/acpi/tables.c
 > --- a/drivers/acpi/tables.c	Wed Jul 30 11:45:27 2003
 > +++ b/drivers/acpi/tables.c	Wed Jul 30 11:45:27 2003
 > @@ -69,7 +69,8 @@
 > =20
 >  static unsigned long		sdt_pa;		/* Physical Address */
 >  static unsigned long		sdt_count;	/* Table count */
 > -static struct acpi_table_sdt	*sdt_entry;
 > +
 > +static struct acpi_table_sdt	sdt_entry[ACPI_MAX_TABLES];
 > =20
 >  void
 >  acpi_table_print (
 > @@ -413,12 +414,6 @@
 >  			sdt_count =3D ACPI_MAX_TABLES;
 >  		}
 > =20
 > -		sdt_entry =3D alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt)=
);
 > -		if (!sdt_entry) {
 > -			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
 > -			return -ENOMEM;
 > -		}
 > -
 >  		for (i =3D 0; i < sdt_count; i++)
 >  			sdt_entry[i].pa =3D (unsigned long) mapped_xsdt->entry[i];
 >  	}
 > @@ -463,12 +458,6 @@
 >  			printk(KERN_WARNING PREFIX "Truncated %lu RSDT entries\n",
 >  				(sdt_count - ACPI_MAX_TABLES));
 >  			sdt_count =3D ACPI_MAX_TABLES;
 > -		}
 > -
 > -		sdt_entry =3D alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt)=
);
 > -		if (!sdt_entry) {
 > -			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
 > -			return -ENOMEM;
 >  		}
 > =20
 >  		for (i =3D 0; i < sdt_count; i++)
 > -
 > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Xavier Bru <Xavier.Bru@bull.net>
Date: Fri, 29 Aug 2003 16:41:56 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106217544927989@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Martin,

Thanks for the information (Until now CONFIG_DISCONTIGMEM was
exclusive with CONFIG_VIRTUAL_MEM_MAP).

System now builds OK with Jesse's patch + the acpi alloc_bootmem patch.

Unfortunately, it dies somewhere after entering paging_init(), and before
printing "On node %d totalpages:":

ifa=3D0xf000ff54f7c5722b
iip=3D0xa0000001007780d0
0xa0000001007780d0 <__alloc_bootmem_core+592>:	[MII]       ld8 r17=3D[r19],8

last traces are:

Mca related initilaization done
kernel unaligned access to 0xf000ff54f000eefb ip=3D0xa0000001007780d0
kernel unaligned access to 0xf000ff54f000ef03 ip=3D0xa0000001007780d0
kernel unaligned access to 0xf000ff54f000ef0b ip=3D0xa0000001007780d0


I will try to look at this a bit more if I find some more time.

Thanks again.

Xavier

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
 > On Thu, Aug 28, 2003 at 06:38:41PM +0200, Xavier Bru wrote:
 > >=20
 > > Martin,
 > >=20
 > > Thanks for answering my mail. I applied Jesse's patch ([PATCH] latest
 > > discontig mail dated Fri, 8 Aug 2003) but this does'nt build with:
 > > 	CONFIG_NUMA=3Dy
 > > 	CONFIG_ACPI_NUMA=3Dy
 > > 	CONFIG_DISCONTIGMEM=3Dy
 > > 	# CONFIG_VIRTUAL_MEM_MAP is not set
 > > I get:
 > > include/linux/mm.h: In function `lowmem_page_address':
 > > include/linux/mm.h:349: `mem_map' undeclared (first use in this functi=
on)
 > >=20
 > > It seems that this only works on Altix, unless I missed something.
 >=20
 > I'm pretty sure that you need CONFIG_VIRTUAL_MEM_MAP=3Dy if you have
 > CONFIG_DISCONTIGMEM=3Dy
 >=20
 > mh
 >=20
 > --=20
 > Wild Open Source Inc.                  mort@wildopensource.com

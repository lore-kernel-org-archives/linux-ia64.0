From: Xavier Bru <Xavier.Bru@bull.net>
Date: Mon, 01 Sep 2003 12:36:48 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106241985930191@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Martin,

I checked that the code for changeset 1.1292.1.3 is already present in 2.6.=
0 test4.=20

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1292.1.2 -> 1.1292.1.3
#	 arch/ia64/mm/numa.c	1.1     -> 1.2   =20
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/25	mort@wildopensource.com	1.1292.1.3
# [PATCH] ia64: paddr_to_nid fixup
#=20
# Here is a small patch for paddr_to_nid().  This fix is already in 2.4
# and is used in the case where a NUMA kernel is running on a machine
# without a SRAT ACPI table.  Without this patch the node info is not
# correctly located.
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
--- a/arch/ia64/mm/numa.c	Wed Aug 27 00:40:34 2003
+++ b/arch/ia64/mm/numa.c	Wed Aug 27 00:40:34 2003
@@ -42,5 +42,5 @@
 		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
 			break;
=20
-	return (i < num_memblks) ? node_memblk[i].nid : -1;
+	return (i < num_memblks) ? node_memblk[i].nid : (num_memblks ? -1 : 0);
 }

Thanks for your help.
Xavier=20

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
 > On Fri, Aug 29, 2003 at 06:41:56PM +0200, Xavier Bru wrote:
 > >=20
 > > printing "On node %d totalpages:":
 > >=20
 > > ifa=3D0xf000ff54f7c5722b
 > > iip=3D0xa0000001007780d0
 > > 0xa0000001007780d0 <__alloc_bootmem_core+592>:	[MII]       ld8 r17=3D[=
r19],8
 > >=20
 > >=20
 > > I will try to look at this a bit more if I find some more time.
 >=20
 > Do you have this changeset in your tree?  It sounds like a similar
 > problem to what I was seeing.
 >=20
 > ChangeSet@1.1292.1.3, 2003-08-25 12:23:20-07:00, mort@wildopensource.com
 >   [PATCH] ia64: paddr_to_nid fixup
 >  =20
 >   Here is a small patch for paddr_to_nid().  This fix is already in 2.4
 >   and is used in the case where a NUMA kernel is running on a machine
 >   without a SRAT ACPI table.  Without this patch the node info is not
 >   correctly located.
 >=20
 >=20
 > mh
 >=20
 > --=20
 > Wild Open Source Inc.                  mort@wildopensource.com
 > -
 > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html

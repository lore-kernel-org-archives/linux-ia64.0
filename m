From: Xavier Bru <Xavier.Bru@bull.net>
Date: Tue, 02 Sep 2003 17:27:53 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106253347504997@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello Martin,

I finally found the reason for crashing at init time:
On node 0, our test configuration has:
 2 GB of memory at address 0
 2 GB of memory at address 6 GB (due to PCI hole).

Current code for acpi_numa_memory_affinity_init ignores physical
memory bank if the hole (4GB) is bigger than the bank (2 GB).
As the node_memblk is not present for address 6 GB, paddr_to_nid
returns -1 and alloc_bootmem_pages_node crashes with a Null pointer.

As we now have CONFIG_VIRTUAL_MEM_MAP=3Dy, I suppose we should also use
sparse memory in same node. (Am I right ?)

Now 2.6.0 test4  boots OK in NUMA with:

. Jesse's discontig patch
. Tony's trim patch
. alloc_bootmem patch
. and this small one :-)

diff --exclude-from /users/xb/proc/diff.exclude -Nur linux-2.6.0-test4/arch=
/ia64/kernel/acpi.c 0t4/arch/ia64/kernel/acpi.c
--- linux-2.6.0-test4/arch/ia64/kernel/acpi.c	2003-08-23 01:55:43.000000000=
 +0200
+++ 0t4/arch/ia64/kernel/acpi.c	2003-09-02 15:37:17.000000000 +0200
@@ -423,9 +423,8 @@
=20
 	if (min_hole_size) {
 		if (min_hole_size > size) {
-			printk(KERN_ERR "Too huge memory hole. Ignoring %ld MBytes at %lx\n",
+			printk(KERN_WARNING "Huge memory hole. Using %ld MBytes at %lx\n",
 			       size/(1024*1024), paddr);
-			return;
 		}
 	}
=20
Thanks again for your help.

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

 > Martin Hicks writes:
 >  >=20
 >  >=20
 >  > On Fri, Aug 29, 2003 at 06:41:56PM +0200, Xavier Bru wrote:
 >  > >=20
 >  > > printing "On node %d totalpages:":
 >  > >=20
 >  > > ifa=3D0xf000ff54f7c5722b
 >  > > iip=3D0xa0000001007780d0
 >  > > 0xa0000001007780d0 <__alloc_bootmem_core+592>:	[MII]       ld8 r17=
=3D[r19],8
 >  > >=20
 >  > >=20
 >  > > I will try to look at this a bit more if I find some more time.
 >  >=20
 >  > Do you have this changeset in your tree?  It sounds like a similar
 >  > problem to what I was seeing.
 >  >=20
 >  > ChangeSet@1.1292.1.3, 2003-08-25 12:23:20-07:00, mort@wildopensource.=
com
 >  >   [PATCH] ia64: paddr_to_nid fixup
 >  >  =20
 >  >   Here is a small patch for paddr_to_nid().  This fix is already in 2=
.4
 >  >   and is used in the case where a NUMA kernel is running on a machine
 >  >   without a SRAT ACPI table.  Without this patch the node info is not
 >  >   correctly located.
 >  >=20
 >  >=20
 >  > mh
 >  >=20
 >  > --=20
 >  > Wild Open Source Inc.                  mort@wildopensource.com
 >  > -
 >  > To unsubscribe from this list: send the line "unsubscribe linux-ia64"=
 in
 >  > the body of a message to majordomo@vger.kernel.org
 >  > More majordomo info at  http://vger.kernel.org/majordomo-info.html

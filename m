From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 12 May 2004 20:33:19 +0000
Subject: bk pull on 2.4 ia64 linux tree
Message-Id: <200405121433.19839.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Marcelo,

Please do a

	bk pull http://lia64.bkbits.net/to-marcelo-2.4

This will update the following files:

 arch/ia64/configs/dig         |   14 +
 arch/ia64/configs/generic     |   14 +
 arch/ia64/configs/numa        |   14 +
 arch/ia64/configs/ski         |   10 -
 arch/ia64/configs/zx1         |   14 +
 arch/ia64/defconfig           |   14 +
 arch/ia64/ia32/binfmt_elf32.c |    6 
 arch/ia64/ia32/elfcore32.h    |  393 ++++++++++++++++++++++++++++--------------
 arch/ia64/ia32/sys_ia32.c     |   12 -
 arch/ia64/kernel/unwind.c     |    2 
 arch/ia64/mm/hugetlbpage.c    |   10 -
 include/asm-ia64/ia32.h       |   96 +++++-----
 12 files changed, 393 insertions(+), 206 deletions(-)

through these ChangeSets:

<bjorn.helgaas@hp.com> (04/05/10 1.1364)
   ia64: Update defconfig to current generic config.

<bjorn.helgaas@hp.com> (04/05/05 1.1363)
   ia64: Update defconfigs.

<steiner@sgi.com> (04/05/05 1.1362)
   ia64: fix HUGETLB null pointer dereference
   
   If the mmap fails, do_mmap_pgoff attempts to unmap the vma range it
   was mapping. Depending on where it failed during the mmap, some of the
   higher level PGD/PMDs may not have been assigned, so referencing them
   may cause NULL pointer dereferences.
   
   If you attempt to allocate a LOT more huge pages than are physically
   available, the kernel may reference invalid PGDs or PMDs. 
   
   Here is the 2.4 backtrace of a failure. If the mmap fails,
   do_mmap_pgoff attempts to unmap the vma range it was mapping.
   Depending on where it failed during the mmap, some of the higher level
   PGD/PMDs may not have been assigned.
   
   The bug (at least in 2.4) exists on all platforms but on our platform
   attempts to dereference NULL pointers usually cause MCAs. (If a
   platform has zeros in page 0, you may be lucky & the code would appear
   to work, but it is still a bug).
   
           Stack traceback for pid 6817
           0xe00025307ba50000     6817     6663  0  148   D  0xe00025307ba50420  toy
           0xe00000000445e180 unmap_hugepage_range+0x160  << mca surfaced here
           0xe00000000445e300 zap_hugepage_range+0x80
           0xe00000000452dbc0 do_mmap_pgoff+0xea0
           0xe000000004432910 sys_mmap+0x210
           0xe00000000440e2a0 ia64_ret_from_syscall
   
   The MCA was caused by the NULL pmd dereference in huge_pte_offset. The
   MCA doesn't surface until the bad data is consumed.

<bjorn.helgaas@hp.com> (04/04/07 1.1348.1.8)
   ia64: Fix ia32 core dumps.

<arun.sharma@intel.com> (04/04/07 1.1348.1.7)
   [PATCH] ia64: make ia32 core dumps work
   
   The attached patch implements core dump functionality for IA-32
   applications running on ia64.

<bjorn.helgaas@hp.com> (04/04/07 1.1348.1.5)
   Cset exclude: arun.sharma@intel.com[helgaas]|ChangeSet|20040405163028|42090

<arun.sharma@intel.com> (04/04/05 1.1319.5.2)
   [PATCH] ia64: make ia32 core dumps work
   
   The attached patch implements core dump functionality for IA-32
   applications running on ia64.

<davidm@tiger.hpl.hp.com> (04/04/05 1.1319.5.1)
   ia64: Fix typo in unwinder which could cause NULL-pointer dereferences.


Thanks!

Bjorn

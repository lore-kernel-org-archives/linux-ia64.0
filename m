From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 20 Jan 2004 21:22:39 +0000
Subject: 2.4.x arch/ia64 update
Message-Id: <200401201422.39522.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Marcelo,

Please do a

	bk pull http://lia64.bkbits.net/to-marcelo-2.4

This will update the following files:

 arch/ia64/config.in             |   30 +-
 arch/ia64/hp/common/sba_iommu.c |  544 ++++++++++++++++------------------------
 arch/ia64/ia32/sys_ia32.c       |    2 
 arch/ia64/kernel/acpi.c         |   18 +
 arch/ia64/kernel/efi.c          |   12 
 arch/ia64/kernel/ia64_ksyms.c   |    4 
 arch/ia64/kernel/ivt.S          |   24 +
 arch/ia64/kernel/mca.c          |  111 ++++----
 arch/ia64/kernel/mca_asm.S      |  342 ++++++++++++++++---------
 arch/ia64/kernel/pci.c          |   10 
 arch/ia64/kernel/perfmon.c      |    2 
 arch/ia64/kernel/salinfo.c      |    9 
 arch/ia64/kernel/setup.c        |    3 
 arch/ia64/kernel/sys_ia64.c     |    5 
 arch/ia64/mm/Makefile           |    1 
 arch/ia64/mm/hugetlbpage.c      |  513 +++++++++++++++++++++++++++++++++++++
 arch/ia64/mm/init.c             |   24 +
 arch/ia64/tools/print_offsets.c |    2 
 include/asm-ia64/mca.h          |   14 -
 include/asm-ia64/mmu_context.h  |    9 
 include/asm-ia64/page.h         |   35 ++
 include/asm-ia64/pgtable.h      |    6 
 include/asm-ia64/processor.h    |    1 
 include/asm-ia64/tlb.h          |    2 
 include/asm-ia64/xor.h          |   10 
 25 files changed, 1213 insertions(+), 520 deletions(-)

through these ChangeSets:

<bjorn.helgaas@hp.com> (04/01/20 1.1283)
   ia64: Add acpi_register_irq() interface.
   
   (This is only the ia64-specific part of this patch)

<willy@fc.hp.com> (04/01/20 1.1282)
   ia64: Add generic RAID xor routines with prefetch.
   
   (This includes only the ia64-specific parts of this patch)

<mort@wildopensource.com> (04/01/20 1.1281)
   ia64: Move mmu_gathers[] to local_cpu_data on ia64 (only ia64-specific bits)
   
   This is a patch that moves mmu_gathers into local_cpu_data on IA64 NUMA.
   I'm not exactly sure where to push this patch, because it does touch
   include/asm-generic/tlb.h although it has no effect on non ia64 arches.
   
   The main reason for making this change is that the mmu_gathers array
   gets very large as the number of processors increases.

<rohit.seth@intel.com> (04/01/20 1.1280)
   ia64: hugetlb support (ia64-specific parts)

<bjorn.helgaas@hp.com> (04/01/15 1.1267.35.21)
   ia64: Export acpi_hp_csr_space() for modular agpgart.

<bjorn.helgaas@hp.com> (04/01/15 1.1267.35.20)
   ia64: sba_iommu: print note about reserving IOVA space for agpgart.

<alex.williamson@hp.com> (04/01/15 1.1267.35.19)
   ia64: sba_iommu: use memparse, long double

<alex.williamson@hp.com> (04/01/14 1.1267.35.18)
   [PATCH] ia64: sba_iommu update
   
   This patch does a couple things:
         * Allows iommu page size different than PAGE_SIZE.  This was
           largely done by Bjorn.  The motivation for this is that sx1000
           hardware officially only supports use of the iommu with a 4k
           page size.  Thus the default is now 4k for sx1000 and PAGE_SIZE
           for zx1.
         * Cleanup the runtime statistics gathering such that we can turn
           it on for some info w/o impacting runtime performance.

<bjorn.helgaas@hp.com> (04/01/14 1.1267.35.17)
   ia64: Skip zero-length resources in PCI root bridge _CRS

<bjorn.helgaas@hp.com> (04/01/14 1.1267.35.16)
   ia64: Fix broken merge (remove mmu_gathers[] defn)

<bjorn.helgaas@hp.com> (04/01/14 1.1267.35.15)
   ia64: Fix system type selection to workaround menuconfig bug (select "HP",
   	get "HP-simulator").

<arun.sharma@intel.com> (04/01/14 1.1267.35.14)
   [PATCH] ia64: ia32 sigaltstack() fix
   
   The attached patch fixes a bug introduced by the earlier patch to
   handle the differences between ia32 and ia64 in the definition of
   MINSIGSTKSZ.

<steiner@sgi.com> (04/01/14 1.1267.35.13)
   [PATCH] ia64: fix ia64_ctx.lock deadlock
   
   I hit a deadlock involving the ia64_ctx.lock. The lock
   may be taken in interrupt context to process an IPI from smp_flush_tlb_mm.

<kaos@sgi.com> (04/01/14 1.1267.35.12)
   [PATCH] ia64: Avoid double clear of CMC/CPE records
   
   Credit to Ben Woodard <ben@zork.net>.

<tony.luck@intel.com> (04/01/14 1.1267.35.11)
   [PATCH] ia64: enable recovery from TLB errors
   
   Here's the updated version of the MCA TLB recovery patch.

<kaos@sgi.com> (04/01/14 1.1267.35.10)
   [PATCH] ia64: fix deadlock in ia64_mca_cmc_int_caller()
   
   smp_call_function() must not be called from interrupt context (can
   deadlock on tasklist_lock).  Use keventd to call smp_call_function().

<bjorn.helgaas@hp.com> (04/01/14 1.1267.35.9)
   ia64: work around a menuconfig bug.
   
   Re-order "HP" and "HP-simulator" to workaround menuconfig bug.  If "HP-simulator"
   appears first, menuconfig selects it when the user selects "HP".

<bjorn_helgaas@hp.com> (04/01/14 1.1267.35.8)
   ia64 HP iommu: add "sx1000" detection (no functional change).

<eranian@hpl.hp.com> (04/01/14 1.1267.35.7)
   ia64: Fix PFM_WRITE_PMCS failure in system-wide mode when PMC12 is zero
   
           - fixes a typo in pfm_write_pmcs() by which we were not using the
             correct index variable to check for the default value of a PMC.
             This caused calls to PFM_WRITE_PMCS to fail in system wide mode
             when PMC12 is programmed to be zero.


Thanks!

Bjorn


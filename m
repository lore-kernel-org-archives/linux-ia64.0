From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 11 Feb 2004 05:19:03 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200402110519.i1B5J3UM005920@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.  I realize this is a bit late,
but due to last week's vacation, it's the earliest I could manage.
Also, apart from the biggish mca.c update, most changes are rather
small (and everything is constrained to ia64 directories).

Thanks!

	--david

 arch/ia64/defconfig               |   60 -
 arch/ia64/hp/common/sba_iommu.c   |  345 ++++--
 arch/ia64/kernel/efivars.c        |   43 
 arch/ia64/kernel/mca.c            | 2008 ++++++++------------------------------
 arch/ia64/kernel/salinfo.c        |   44 
 arch/ia64/kernel/smpboot.c        |    1 
 arch/ia64/kernel/traps.c          |   11 
 arch/ia64/kernel/unaligned.c      |   44 
 arch/ia64/lib/io.c                |   16 
 arch/ia64/sn/kernel/mca.c         |   14 
 arch/ia64/sn/kernel/sn2/sn2_smp.c |   60 -
 include/asm-ia64/fpswa.h          |    2 
 include/asm-ia64/mca.h            |   58 -
 include/asm-ia64/mmu_context.h    |    3 
 include/asm-ia64/percpu.h         |    2 
 include/asm-ia64/processor.h      |   26 
 16 files changed, 899 insertions(+), 1838 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/02/10 1.1650)
   ia64: Correct init_task.rbs_bot value (not that it matters).

<davidm@tiger.hpl.hp.com> (04/02/10 1.1649)
   ia64: Update defconfig

<davidm@tiger.hpl.hp.com> (04/02/10 1.1648)
   ia64: Fix some more warnings caused by casts used as l-values.

<davidm@tiger.hpl.hp.com> (04/02/10 1.1647)
   ia64: Based on patch by Stephane Eranian: Make fpswa version info available
   	via /proc/efi/fpswa, rather than printing it at boot time.

<kaos@ocs.com.au> (04/02/10 1.1646)
   [PATCH] ia64: Periodically forward MCA or INIT records to user-level
   
   Periodically check for outstanding MCA or INIT records and pass them to
   user space salinfo.

<kaos@ocs.com.au> (04/02/10 1.1645)
   [PATCH] ia64: mca.c - Fix the "did we recover from MCA test" and move it up
   
   Correct the "did we recover from MCA test" and move it up a level to
   simplify interaction with debuggers.

<kenneth.w.chen@intel.com> (04/02/10 1.1644)
   [PATCH] ia64: remove unused cpucount variable
   

<kaos@sgi.com> (04/02/10 1.1643)
   [PATCH] ia64: mca.c - pass irq_safe around
   
   Patches from Ben Woodward to calculate irq_safe once and pass it around.

<kaos@sgi.com> (04/02/10 1.1642)
   [PATCH] ia64: mca.c cleanup - Bjorn's printk cleanup
   

<kaos@sgi.com> (04/02/10 1.1641)
   [PATCH] ia64: mca.c cleanup - Reorder to remove the need for forward declarations and to consolidate related code
   

<kaos@sgi.com> (04/02/10 1.1640)
   [PATCH] ia64: mca.c cleanup - Delete dead variables and functions
   

<kaos@sgi.com> (04/02/10 1.1639)
   [PATCH] ia64: mca.c cleanup - Mark variables and functions static where possible
   

<kaos@sgi.com> (04/02/10 1.1638)
   [PATCH] ia64: mca.c cleanup - Delete all record printing code, moved to salinfo_decode in user space
   

<kaos@sgi.com> (04/02/10 1.1637)
   [PATCH] ia64: Avoid deadlock when using printk() for MCA and INIT records
   
   Port the ia64 mca.c clean up patches from 2.4.25-pre8 to 2.6.2-rc2.
   
   The following 6 patches do :-
   
   1 Avoid deadlock when using printk() for MCA and INIT records.
   2 Delete all record printing code, moved to salinfo_decode in user space.
   3 Mark variables and functions static where possible.
   4 Delete dead variables and functions.
   5 Reorder to remove the need for forward declarations and to consolidate
     related code.
   6 Bjorn's printk cleanup.
   
   Altogether they shrink mca.c from 2432 to 1339 lines and make it much
   more readable.
   
   The only functional change is the removal of any attempt to print the
   CMC/CPE/MCA/INIT record contents in the kernel plus the addition of an
   info printk to ia64_mca_check_errors(), to match 2.4.  Now we just get
   one line to say that a record has been detected, except for MCA which
   prints nothing at all.

<alex.williamson@hp.com> (04/02/10 1.1636)
   [PATCH] ia64: sba_iommu perf tunning and new functionality
   
      I've been doing some performance tuning and adding some functionality
   to sba_iommu for zx1/sx1000 chipsets.  This adds:
   
         * Long overdue consistent_dma_mask support
         * Long overdue ability to do large mappings in the iommu
         * Tightened spinlock usage for better performance/scalability
         * Added branch prediction hints for some of the performance paths
         * Added explicit data prefetching to some performance paths -
           perfmon shows roughly a 20% decrease in L3 misses in the bitmap
           search code
         * Increased delayed resource freeing depth and added a separate
           lock per ioc to avoid contention
         * Added code to free up queued pdir entries should we be unable to
           find space for new ones (not that I've ever seen the pdir
           anywhere close to full)
         * Finished cleaning out the hint support code, Grant is
           maintaining this separately for now
         * Added option to control bypass of sg mappings separately from
           single/coherent mappings
   
   Much like the swiotlb, sba_iommu allows devices capable of 64bit
   addressing to bypass the iommu and DMA directly to/from memory.  Using a
   worst case scenario test (64bit bypass disabled, all DMA mapped through
   the iommu), I saw a 60% increase in sequential block input throughput
   using bonnie++ on a large RAID0 MD array.  In fact, this patch provides
   the best bonnie++ performance with bypass disabled.  This is likely due
   to benefits seen from coalescing the scatterlist, allowing better disk
   streaming.  I assume that network performance will likely be limited by
   mapping latency, so I added the last bullet item to allow sg mappings to
   get the benefit of coalescing while keeping a low latency path for
   single and coherent mappings.  If anyone is setup for network
   benchmarks, I'd be interested in a before and after with this patch.

<kenneth.w.chen@intel.com> (04/02/10 1.1635)
   [PATCH] ia64: fix ld.a emulation
   
   This patch fixes a corner-case of ld.a emulation.  ld.a should be
   emulated such that it always loads a misaligned value and clears the
   corresponding ALAT entry.  The old emulation was correct for the case
   where ld.a was followed by ld.c/chk.a (since ALAT entry was cleared),
   but wrong for the case where it _wasn't_ followed by ld.c/chk.a.  In
   that case, the misaligned value wasn't read from memory, as it should
   have been.

<steiner@sgi.com> (04/02/10 1.1634)
   [PATCH] ia64: Enable cpu_vm_mask maintenance and improve SN2 TLB flushing


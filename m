From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 19 Jun 2004 06:58:17 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200406190658.i5J6wHfY005790@napali.hpl.hp.com>
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

This will update the files shown below.

Thanks!

	--david

 arch/ia64/Kconfig                        |   14 
 arch/ia64/configs/sn2_defconfig          |  106 +--
 arch/ia64/defconfig                      |   23 
 arch/ia64/ia32/binfmt_elf32.c            |    4 
 arch/ia64/ia32/ia32_entry.S              |    2 
 arch/ia64/ia32/ia32_support.c            |   24 
 arch/ia64/ia32/ia32priv.h                |   36 +
 arch/ia64/ia32/sys_ia32.c                |  860 +++++++++++++++++++++++++------
 arch/ia64/kernel/entry.S                 |    6 
 arch/ia64/kernel/fsys.S                  |    3 
 arch/ia64/kernel/gate.S                  |    6 
 arch/ia64/kernel/head.S                  |    6 
 arch/ia64/kernel/iosapic.c               |   16 
 arch/ia64/kernel/irq.c                   |   16 
 arch/ia64/kernel/mca.c                   |   95 ++-
 arch/ia64/kernel/palinfo.c               |    4 
 arch/ia64/kernel/perfmon.c               |   89 +--
 arch/ia64/kernel/process.c               |   20 
 arch/ia64/kernel/unwind.c                |   35 -
 arch/ia64/mm/discontig.c                 |    3 
 arch/ia64/mm/hugetlbpage.c               |    2 
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c |    4 
 arch/ia64/sn/io/sn2/klgraph.c            |    4 
 arch/ia64/sn/io/sn2/ml_iograph.c         |   16 
 arch/ia64/sn/io/sn2/module.c             |   14 
 arch/ia64/sn/kernel/irq.c                |   17 
 arch/ia64/sn/kernel/setup.c              |   23 
 include/asm-ia64/gcc_intrin.h            |   16 
 include/asm-ia64/ia32.h                  |   14 
 include/asm-ia64/irq.h                   |    6 
 include/asm-ia64/pgtable.h               |    6 
 include/asm-ia64/processor.h             |    5 
 include/asm-ia64/sn/module.h             |    2 
 include/asm-ia64/sn/sn_sal.h             |   34 +
 include/asm-ia64/system.h                |    2 
 include/asm-ia64/unistd.h                |    3 
 36 files changed, 1164 insertions(+), 372 deletions(-)

through these ChangeSets:

<yanmin.zhang@intel.com> (04/06/18 1.1794)
   [PATCH] ia64: fix free_huge_page() call in hugetlb_prefault()
   
   In base kernel 2.6.7, there is bug in function hugetlb_prefault().  The
   call to free_huge_page() is incorrect and should be replaced with a call
   to page_cache_release().
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<eranian@hpl.hp.com> (04/06/18 1.1793)
   [PATCH] ia64: perfmon stack consumption fix
   
   This patch moves the pfm_ovfl_arg_t structure from the kernel stack
   into the pfm_context_t structure. This minimizes kernel stack space
   consumption.
   
   Signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<ashok.raj@intel.com> (04/06/18 1.1792)
   [PATCH] ia64: move move_irq() from iosapic.c to irq.c
   
   This patch moves move_irq() from ioaspic.c to irq.c to make this common
   for ia64 subarches.
   
   Signed-off-by: Ashok Raj <ashok.raj@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<arun.sharma@intel.com> (04/06/18 1.1791)
   [PATCH] ia64: fix ia32 partial-page map support for overlapping mmaps
   
   - Handle the overlapping mmaps in the MAP_FIXED case
   - Handle unmaps correctly i.e. call __ia32_delete_pp_range()
   - There are now three clear entry points into the pp manipulation code
           - ia32_set_pp
           - ia32_unset_pp
           - ia32_compare_pp
   - Rename internal functions to __ia32_*pp_*
   - Grab mmap_sem just once at the main entry point
   
   Signed-off-by: Gordon Jin <gordon.jin@intel.com>
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<tony.luck@intel.com> (04/06/17 1.1790)
   [PATCH] ia64: switching between CPEI & CPEP
   
   A couple of months ago Hidetoshi Seto from Fujitsu proposed
   a patch to provide similar switching between interrupt mode
   and polling mode for corrected platform events (CPE) as we
   have for processor events (CMC) [with the obvious difference
   that not all platforms support an interrupt for CPE].
   
   I dusted it off and made a couple of very minor cleanups (which
   Seto-san checked out last night on his test setup and confirmed
   still passes).
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<pfg@sgi.com> (04/06/17 1.1789)
   [PATCH] ia64: fix SN2 interrupt rerouting
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<davidm@tiger.hpl.hp.com> (04/06/17 1.1788)
   ia64: Fix build-problem when CONFIG_IA32 is not enabled.
   
   Without this fix, you'll get unresolved references to
   sys_rt_sigaction().

<davidm@tiger.hpl.hp.com> (04/06/17 1.1787)
   ia64: Squish some more hazards & warnings for UP compile.

<davidm@tiger.hpl.hp.com> (04/06/17 1.1786)
   ia64: Squish compiler-warning in perfmon.c when compiling for UP.

<davidm@tiger.hpl.hp.com> (04/06/16 1.1735.12.50)
   ia64: Nuke two warnings in mca.c that showed in the simulator configuration.

<davidm@tiger.hpl.hp.com> (04/06/16 1.1735.12.49)
   ia64: Fix ia32 partial-page-list code to compile cleanly in more configs.
   

<jbarnes@engr.sgi.com> (04/06/16 1.1735.12.48)
   [PATCH] ia64: update sn2_defconfig
   
   Small patch to update the sn2_defconfig file.  I just did a 'make oldconfig' 
   with the current sn2_defconfig and removed 8250 support.
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<kaos@sgi.com> (04/06/16 1.1735.12.47)
   [PATCH] ia64: Support SN platform specific error features
   
   The SN prom supports fine grained error handling features, the OS needs
   to tell the prom if the OS expects to use these platform specific
   features.
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<eranian@hpl.hp.com> (04/06/15 1.1735.12.46)
   [PATCH] ia64: fix info in /proc/pal/*/bus_info
   
   This patch fixes to minor bugs:
    - corrected descriptions for bit 52 and 53 of the /proc/pal/CPU*/bus_info
      entry; they were swapped
    - corrected a typo for bit 55 of the /proc/pal/CPU*/bus_info entry
   
   Signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<davidm@tiger.hpl.hp.com> (04/06/11 1.1735.12.45)
   ia64: Update defconfig

<kaos@sgi.com> (04/06/11 1.1735.12.44)
   [PATCH] ia64: Remove warnings when unwind debug is turned on
   
   Turning on UNW_DEBUG generates warnings for incorrect number of
   parameters for formats and several cases of "suggest explicit braces to
   avoid ambiguous `else'", because UNW_DPRINT contains an if statement.
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<kenneth.w.chen@intel.com> (04/06/10 1.1735.12.43)
   [PATCH] ia64: fix race in fsys_bubble_down to avoid fp-register corruption
   
   The fast system-call fall-back-path has a race: it reads PSR, modifies
   some bits, then writes back the new PSR.  Unfortunately, the contents
   of PSR may change between reading and writing it.  For example, an
   interrupt could occur which could trigger a context-switch.  The
   context-switch might in turn flush the floating-point-high (FPH)
   partition to memory, clear PSR.MFH, and set PSR.DFH.  To prevent this
   race, the patch below turns off PSR.I before reading PSR.
   
   This fixes a floating-point corruption problem that was observed on a
   system with a libc which has the fast system-call support enabled.
   
   The performance impact is minimal (on the order of a handful of cycles).
   
   Signed-off-by: Kevin Tian <kevin.tian@intel.com>
   Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
   Signed-off-by: Asit Mallick <asit.k.mallick@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<Robert.Picco@hp.com> (04/06/10 1.1735.12.42)
   [PATCH] ia64: mark non-existent NUMA-nodes as offline
   
   I found a problem with HP NUMA configuration in 2.6.7-rc3-mm1.  The
   node_online_map is incorrect because of actions taken by
   reassign_cpu_only_nodes in arch/ia64/mm/discontig.c.  The mm1 patch
   which changes the mempolicy for the init_task uses this invalid
   node_online_map and eventually uses a non-existent node's zonelist
   when calling __alloc_pages.
   
   The patch below takes care of this issue.  It puts the non-existent
   nodes offline.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<kaos@sgi.com> (04/06/07 1.1735.12.41)
   [PATCH] ia64: Rename SN "modules" variable to "sn_modules".
   
   SN code has a "modules" variable that conflicts with a variable of the
   same name in kernel/module.c.  This conflict breaks lcrash for ia64.
   Rename "modules" to "sn_modules".
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<arun.sharma@intel.com> (04/06/07 1.1735.12.40)
   [PATCH] ia64: fix ia32 virtual memory leaks due to partial-page mappings
   
   Certain IA-32 applications which do mmap/munmaps which are not
   PAGE_SIZE aligned could see temporary (recovered at process exit time)
   memory leaks, because the kernel didn't have enough data to decide if
   the complete page could be unmapped. This patch adds a new data
   structure called the "partial page list" which helps the kernel keep
   track of precisely which 4k pages are in use by the IA-32 application.
   
   Armed with this data, the kernel can make better decisions at munmap
   and mprotect time. No significant performance degradation was observed
   in the workloads we tested and in some cases, the performance actually
   improved!  This is possibly due to the reduced length of the vma list.
   
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: Gordon Jin <gordon.jin@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<alex.williamson@hp.com> (04/06/07 1.1735.12.38)
   [PATCH] ia64: delete McKinley A-stepping code
   
   The patch below removes the config option and one bit of code for
   McKinley A0/A1 CPU workarounds.  These CPUs were never used in
   production, and IIRC this workaround really only affected X11.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>


From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 Apr 2004 16:05:27 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200404091605.i39G5RPi009402@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

I'm running behind with 2.6.5 but since there is a largish
perfmon-update pending, I thought I should get this out before
2.6.5-rc1.

Please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Thanks!

	--david

 arch/ia64/Kconfig                        |    4 
 arch/ia64/hp/common/sba_iommu.c          |   13 
 arch/ia64/hp/sim/Kconfig                 |    2 
 arch/ia64/kernel/acpi.c                  |   24 -
 arch/ia64/kernel/perfmon.c               |  615 ++++++++++++++++---------------
 arch/ia64/kernel/perfmon_mckinley.h      |   13 
 arch/ia64/kernel/sys_ia64.c              |    8 
 arch/ia64/mm/hugetlbpage.c               |    1 
 arch/ia64/pci/pci.c                      |    1 
 arch/ia64/sn/io/hwgfs/interface.c        |    6 
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c |   26 -
 arch/ia64/sn/io/machvec/pci_dma.c        |   12 
 arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c   |    3 
 drivers/char/sn_serial.c                 |    4 
 include/asm-ia64/machvec_hpzx1.h         |    3 
 include/asm-ia64/perfmon.h               |    7 
 include/asm-ia64/processor.h             |    8 
 17 files changed, 403 insertions(+), 347 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/04/08 1.1789)
   ia64: Make acpi.c compile again: there was an implicit declaration
   	mismatch because the external declaration isn't in the arch-
   	independent ACPI bits yet.

<eranian@hpl.hp.com> (04/04/08 1.1788)
   [PATCH] ia64: perfmon update
   
   Here is a new perfmon patch. It is important because it
   fixes the problem of the close() when the file descriptor
   is shared between two related processes. The good thing
   is that it simplifies a lot the cleanup of the sampling
   buffer.
   
   Here is the ChangeLog:
   
   - fix bug in pfm_close() when the descriptor is
     shared between related processed. Introduce
     a pfm_flush() called for each invocation of
     close(). pfm_close() only called for the last
     user.
   
   - fix pfm_restore_monitoring() to also reload
     the debug registers. They could be modified
     while monitoring is masked.
   
   - fix pfm_close() to clear ctx_fl_is_sampling.
   
   - fix a bug in pfm_handle_work() which could cause
     the wrong PMD to be reset. 
   
   - converted PROTECT_CTX/UNPROTECT_CTX into
     local_irq_save/restore to keep context protection
     but allow IPI to proceed.
   
   - updated pfm_syswide_force_stop() to use
     local_irq_save/restore now that the context
     is protected from the caller side.
   
   - updated pfm_mck_pmc_check() to check if context is 
     loaded before checking for special IBR/DBR combinations.
     Clearing the debug registers is not needed when the context
     is not yet loaded.
   
   - updated perfmon.h to have to correct prototype definitions
     for the pfm_mod_*() functions.
   
   - got rid of the PFM_CTX_TERMINATED state.
   
   - cleanup the DPRINT() statements to remove
     explicit output of current->pid. This is done
      systematically by the macros.
   
   - added a systctl entry (expert_mode) to bypass
     read/write checks on PMC/PMD. As its name indicates
     this is for experts ONLY. Must be root to toggle
     /proc/sys entry.
   
   - corrected pfm_mod_*() to check against the current task.
   
   - removed pfm_mod_fast_read_pmds(). It is never needed.
   
   - added pfm_mod_write_ibrs() and pfm_mod_write_dbrs().

<bjorn.helgaas@hp.com> (04/04/08 1.1787)
   [PATCH] ia64: allow simscsi to be a module
   
   Requiring CONFIG_HP_SIMSCSI to be either  "y" or "n" breaks
   allmodconfig, because simscsi ends up built-in, while scsi itself
   is a module.  So allow simscsi to be a module also.

<bjorn.helgaas@hp.com> (04/04/08 1.1786)
   [PATCH] ia64: ACPI IRQ cleanup (arch part)
   
   Here's the ia64 part of the ACPI IRQ cleanup I proposed here:
   
   http://www.gelato.unsw.edu.au/linux-ia64/0403/8979.html
   
   After the arch bits are in, I'll post the corresponding ACPI changes.
   I removed the "Found IRQ" printk now because when the ACPI
   change goes in, dev->irq won't be initialized until *after*
   acpi_pci_irq_enable().

<petri.koistinen@iki.fi> (04/04/08 1.1785)
   [PATCH] ia64: put URLs in documentation files inside angle-brackets
   
   Patch by Petri T. Koistinen.

<alex.williamson@hp.com> (04/04/05 1.1678.1.13)
   [PATCH] ia64: setup max dma addr earlier on hp boxes
   
   sba_iommu was setting up MAX_DMA_ADDRESS way too late to do any
   good.  This patch makes it get setup via platform_setup, so it's ready
   for paging_init().  All pages should show up in zone DMA now.  Against
   latest 2.6.

<schwab@suse.de> (04/04/05 1.1678.1.12)
   [PATCH] ia64: Missing include in hugetlbpage.c
   
   This fixes a missing include file in arch/ia64/mm/hugetlbpage.c in 2.6.5.
   module.h is needed for EXPORT_SYMBOL.

<schwab@suse.de> (04/04/05 1.1678.1.11)
   [PATCH] ia64: Missing overflow check in mmap
   
   Calling mmap with len = -1 was silently accepted.  The test in the generic
   code was fixed in July 2003, but the fix didn't make it into the ia64-
   specific code.

<jbarnes@sgi.com> (04/04/01 1.1678.1.10)
   [PATCH] ia64: bring ia64 nodes online properly
   
   Andi's libnuma exposed the fact that we don't bring nodes online
   properly as we discover them in ia64.  Here's a quick patch to fix
   that.  Tested with Andi's numademo program; seems to work fine.

<pfg@sgi.com> (04/04/01 1.1678.1.9)
   [PATCH] ia64: small SN2 interface.c patch
   
   Change the calls to link_path_walk() to path_walk().  link_path_walk()
   doesn't initialze current->total_link_count and path_walk() does.
   Without the initialization, path_walks start to fail when 40 sym links
   have been followed.

<jbarnes@sgi.com> (04/04/01 1.1678.1.8)
   [PATCH] ia64: fix sn_serial warning
   
   In my fixes to quiet the sn_serial driver, I made sn_debug_printf only
   get used when the DEBUG define was turned on in the driver but forgot
   to #ifdef out the function definition, causing an 'defined but not
   used' warning.  This patch fixes that.

<jbarnes@sgi.com> (04/04/01 1.1678.1.7)
   [PATCH] ia64: clean up pcibr_slot.c warnings
   
   A few warnings crept into pcibr_slot.c that this patch takes care of.
     - forward declare pcibr_slot_pwr so it can be used w/o warning
     - fix argument passed to pcibr_slot_attach in pcibr_slot_enable

<jbarnes@sgi.com> (04/03/26 1.1678.1.6)
   [PATCH] ia64: only scan SN2 PCI busses that exist
   
   sn_pci_init was unconditionally scanning 255 PCI busses, even though
   only a few are actually present on most systems.  This patch adds a
   check to make sure a given bus exists before doing the scan, which
   saves a little memory and also makes /sys/devices reflect reality a
   bit more closely.

<jbarnes@sgi.com> (04/03/26 1.1678.1.5)
   [PATCH] ia64: implement SN2 version of dma_mapping_error()
   
   On sn2, dma_mapping_error is trivial.  pci_map_single was already returning 0 
   in case of failure (0 is an invalid DMA address on sn2), so make 
   dma_mapping_error check for that.

<davidm@tiger.hpl.hp.com> (04/03/25 1.1678.1.4)
   ia64: Patch by Stephane Eranian: remove irq_stat from cpuinfo_ia64.
   
   irq_stat isn't needed anymore since its members got rolled into
   thread_info.preempt_count.


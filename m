From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Apr 2002 23:49:51 +0000
Subject: [Linux-ia64] new kernel patch (relative to 2.5.8-pre3)
Message-Id: <marc-linux-ia64-105590701905431@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch relative to 2.5.8-pre3 is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:

	linux-2.5.8-pre3-ia64-020411.diff.gz

The reason this one is relative to a pre-patch again is that I tried
2.5.7 and had problems with lost IDE interrupts.  I didn't trust the
IDE drivers that were in 2.5.7, so I updated to 2.5.8-pre3 only to
find that this still doesn't fix the problem.  In the end, I found
that turning off CONFIG_BLK_DEV_PIIX fixed the problem.  Could someone
more knowledgable with IDE look into this?

Below is a summary of changes relative to Linus's tree.  The patch is
actually getting smaller primarily due to the ACPI merge!  Thanks to
Paul Diefenbaugh for his work here!  Let's hope the ACPI code will
stay synced.

Next on my list is DRM.  Also, Jes could you talk Linus into accepting
your qlogic drivers?  He started hacking on them, which caused some
conflicts.  I'd rather have him your cleaned up drivers. ;-)

Please give it a try and let me know how it goes.

Enjoy,

	--david

 arch/ia64/hp/hpsim_console.c            |   64 
 arch/ia64/hp/hpsim_irq.c                |   46 
 arch/ia64/hp/hpsim_machvec.c            |    2 
 arch/ia64/hp/hpsim_setup.c              |   58 
 arch/ia64/hp/hpsim_ssc.h                |   36 
 arch/ia64/hp/simeth.c                   |  533 -
 arch/ia64/hp/simscsi.c                  |  368 
 arch/ia64/hp/simscsi.h                  |   39 
 arch/ia64/hp/simserial.c                | 1104 --
 include/asm-ia64/acpi-ext.h             |  323 
 include/asm-ia64/acpikcfg.h             |   30 
 Documentation/mmio_barrier.txt          |   15 
 Makefile                                |    2 
 arch/i386/mm/fault.c                    |    2 
 arch/ia64/Config.help                   |   34 
 arch/ia64/Makefile                      |   22 
 arch/ia64/config.in                     |    3 
 arch/ia64/defconfig                     |   80 
 arch/ia64/dig/setup.c                   |   15 
 arch/ia64/hp/Config.in                  |    9 
 arch/ia64/hp/Makefile                   |   32 
 arch/ia64/hp/common/Makefile            |   28 
 arch/ia64/hp/common/sba_iommu.c         | 3700 +++++++++
 arch/ia64/hp/sim/Makefile               |   43 
 arch/ia64/hp/sim/hpsim_console.c        |   64 
 arch/ia64/hp/sim/hpsim_irq.c            |   46 
 arch/ia64/hp/sim/hpsim_machvec.c        |    2 
 arch/ia64/hp/sim/hpsim_setup.c          |   58 
 arch/ia64/hp/sim/hpsim_ssc.h            |   36 
 arch/ia64/hp/sim/simeth.c               |  533 +
 arch/ia64/hp/sim/simscsi.c              |  368 
 arch/ia64/hp/sim/simscsi.h              |   39 
 arch/ia64/hp/sim/simserial.c            | 1104 ++
 arch/ia64/hp/zx1/Makefile               |   26 
 arch/ia64/hp/zx1/hpzx1_machvec.c        |    4 
 arch/ia64/hp/zx1/hpzx1_misc.c           |  806 ++
 arch/ia64/ia32/binfmt_elf32.c           |    2 
 arch/ia64/ia32/sys_ia32.c               |    2 
 arch/ia64/kernel/Makefile               |    1 
 arch/ia64/kernel/acpi.c                 | 1153 +-
 arch/ia64/kernel/brl_emu.c              |    6 
 arch/ia64/kernel/efi.c                  |   64 
 arch/ia64/kernel/efivars.c              |   21 
 arch/ia64/kernel/entry.S                |  148 
 arch/ia64/kernel/head.S                 |  239 
 arch/ia64/kernel/ia64_ksyms.c           |    9 
 arch/ia64/kernel/iosapic.c              |  116 
 arch/ia64/kernel/irq.c                  |   17 
 arch/ia64/kernel/mca.c                  |   34 
 arch/ia64/kernel/minstate.h             |   98 
 arch/ia64/kernel/pci.c                  |  186 
 arch/ia64/kernel/process.c              |    6 
 arch/ia64/kernel/semaphore.c            |    5 
 arch/ia64/kernel/setup.c                |   69 
 arch/ia64/kernel/signal.c               |    6 
 arch/ia64/kernel/smp.c                  |    3 
 arch/ia64/kernel/smpboot.c              |    6 
 arch/ia64/kernel/sys_ia64.c             |    6 
 arch/ia64/kernel/unwind_i.h             |    2 
 arch/ia64/lib/Makefile                  |    3 
 arch/ia64/lib/copy_page_mck.S           |  239 
 arch/ia64/lib/do_csum.S                 |  102 
 arch/ia64/lib/swiotlb.c                 |   11 
 arch/ia64/mm/fault.c                    |    8 
 arch/ia64/mm/init.c                     |    9 
 arch/ia64/mm/tlb.c                      |    5 
 arch/parisc/kernel/traps.c              |    1 
 drivers/acpi/acpi_system.c              |    4 
 drivers/acpi/include/platform/aclinux.h |    2 
 drivers/char/Config.help                |    4 
 drivers/char/Config.in                  |    4 
 drivers/char/agp/agp.h                  |   33 
 drivers/char/agp/agpgart_be.c           | 1290 ++-
 drivers/char/drm/Config.in              |   15 
 drivers/char/drm/ati_pcigart.h          |   17 
 drivers/char/drm/drmP.h                 |   12 
 drivers/char/drm/drm_agpsupport.h       |    3 
 drivers/char/drm/drm_bufs.h             |    6 
 drivers/char/drm/drm_drv.h              |    2 
 drivers/char/drm/drm_memory.h           |   52 
 drivers/char/drm/drm_scatter.h          |    6 
 drivers/char/drm/drm_vm.h               |   70 
 drivers/char/drm/i810_dma.c             |    9 
 drivers/char/drm/mga_dma.c              |   12 
 drivers/char/drm/r128_cce.c             |   77 
 drivers/char/drm/radeon_cp.c            |   61 
 drivers/char/mem.c                      |    1 
 drivers/media/radio/Makefile            |    2 
 drivers/media/radio/dummy.c             |    1 
 drivers/media/video/Makefile            |    2 
 drivers/media/video/dummy.c             |    1 
 drivers/net/eepro100.c                  |   34 
 drivers/pci/pci.ids                     |    3 
 drivers/scsi/Config.in                  |    1 
 drivers/scsi/Makefile                   |    1 
 drivers/scsi/ql12160_fw.h               | 3125 ++++---
 drivers/scsi/ql1280_fw.h                | 3774 ++++-----
 drivers/scsi/ql2100_fw.h                | 4740 +++++++++++
 drivers/scsi/ql2200_fw.h                | 5179 ++++++++++++
 drivers/scsi/ql2300_fw.h                | 5486 +++++++++++++
 drivers/scsi/qla1280.c                  | 5215 ++++++-------
 drivers/scsi/qla1280.h                  |  550 -
 drivers/scsi/qla2x00.c                  |12823 ++++++++++++++++++++++++++++++++
 drivers/scsi/qla2x00.h                  | 2492 ++++++
 drivers/scsi/qla2x00exioct.h            |  823 ++
 drivers/scsi/qla2x00exioctln.h          |  131 
 drivers/scsi/qla2x00ioctl.c             | 1179 ++
 drivers/scsi/qlavendor.c                |  325 
 drivers/scsi/scsi_ioctl.c               |   13 
 drivers/usb/uhci.c                      |    2 
 drivers/usb/usb-ohci.c                  |   10 
 fs/binfmt_elf.c                         |    4 
 fs/fcntl.c                              |    1 
 fs/nfsd/nfsctl.c                        |    1 
 fs/proc/base.c                          |   17 
 include/asm-i386/hw_irq.h               |    2 
 include/asm-i386/page.h                 |    4 
 include/asm-i386/ptrace.h               |    1 
 include/asm-ia64/acpi.h                 |   49 
 include/asm-ia64/cacheflush.h           |   49 
 include/asm-ia64/efi.h                  |   43 
 include/asm-ia64/hw_irq.h               |    2 
 include/asm-ia64/ide.h                  |   32 
 include/asm-ia64/machvec.h              |    4 
 include/asm-ia64/machvec_hpzx1.h        |   74 
 include/asm-ia64/machvec_init.h         |    5 
 include/asm-ia64/module.h               |    3 
 include/asm-ia64/offsets.h              |    6 
 include/asm-ia64/pci.h                  |    5 
 include/asm-ia64/percpu.h               |   24 
 include/asm-ia64/pgalloc.h              |  117 
 include/asm-ia64/pgtable.h              |  104 
 include/asm-ia64/processor.h            |   11 
 include/asm-ia64/sal.h                  |   36 
 include/asm-ia64/thread_info.h          |    7 
 include/asm-ia64/tlbflush.h             |   83 
 include/asm-ia64/uaccess.h              |    5 
 include/asm-ia64/unistd.h               |    3 
 include/linux/acpi.h                    |    2 
 include/linux/acpi_serial.h             |    2 
 include/linux/agp_backend.h             |    5 
 include/linux/compiler.h                |    3 
 include/linux/fs.h                      |   13 
 include/linux/highmem.h                 |    4 
 include/linux/irq.h                     |    4 
 include/linux/irq_cpustat.h             |   22 
 include/linux/kernel.h                  |    9 
 include/linux/pci_ids.h                 |    3 
 include/linux/percpu.h                  |    4 
 include/linux/prctl.h                   |    6 
 include/linux/sched.h                   |    4 
 include/linux/smp.h                     |    5 
 kernel/exec_domain.c                    |    2 
 kernel/fork.c                           |    9 
 kernel/ksyms.c                          |    4 
 kernel/printk.c                         |   78 
 kernel/sched.c                          |    4 
 kernel/softirq.c                        |   26 
 kernel/sys.c                            |   62 
 kernel/time.c                           |    4 
 kernel/timer.c                          |    7 
 lib/brlock.c                            |    2 
 mm/filemap.c                            |    8 
 mm/memory.c                             |    2 
 sound/oss/cs4281/cs4281m.c              |   71 
 sound/oss/cs4281/cs4281pm-24.c          |   12 
 166 files changed, 50042 insertions(+), 10870 deletions(-)

through these ChangeSets:

<davidm@wailua.hpl.hp.com> (02/04/11 1.456.1.2)
   ia64: Add AGP support for HP zx1 platform.  Fix physical-address
   calculation.

<davidm@wailua.hpl.hp.com> (02/04/11 1.458.1.2)
   ia64: make 2.5.8-pre3 work on SMP ia64.

<davidm@wailua.hpl.hp.com> (02/04/11 1.456.6.3)
   ia64: Minor fixups.

<davidm@wailua.hpl.hp.com> (02/04/11 1.458.1.1)
   ia64: Make v2.5.8-pre3 work on ia64.

<davidm@wailua.hpl.hp.com> (02/04/10 1.458)
   ia64: Add asm/cacheflush.h and asm/tlbflush.h.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.29)
   minstate.h:
     Add mising include of <asm/cache.h>.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.28)
   Cset exclude: davidm@wailua.hpl.hp.com|ChangeSet|20020411000006|41013

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.27)
   ia64: Misc fixups.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.48.9)
   nfsctl.c:
     Add missing include of <linux/init.h>.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.26)
   setup.c:
     Move disabling of 8259 irqs into iosapic.c.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.25)
   smpboot.c:
     Declare ia64_iobase.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.24)
   minstate.h:
     Add missing include of <asm/cache.h>.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.23)
   acpi.c:
     Paul's ACPI update.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.22)
   Manual merge with Paul's 2.4.18 ACPI update.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.21)
   More McKinley tuning and minor do_csum() cleanup.

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.20)
   More EFI fixes.

<bjorn_helgaas@hp.com> (02/04/10 1.369.99.19)
   [PATCH] This patch against 2.4.18+ia64-020226 removes a legacy VGA
   dependency.  Non-legacy systems may have system memory
   at 0xA0000, and if that's the case, we don't want to install the
   VGA console.
   
   Restructured conswitchp init slightly so that if both
   CONFIG_DUMMY_CONSOLE and CONFIG_VGA_CONSOLE
   are defined, conswitchp is always set to something, even if we
   don't find VGA at 0xA0000.
   
   This work is due to Alex Williamson (alex_williamson@hp.com).
   

<davidm@wailua.hpl.hp.com> (02/04/10 1.369.99.18)
   Tune __ia64_init_fpu() for better performance and smaller size.

<schwab@suse.de> (02/04/08 1.369.99.17)
   [PATCH] The kernel cannot cope with modules without unwind data, which happens
   with data-only modules like the fs/nls modules when compiling with gcc
   3.1.  This patch fixes the problem.
   

<davidm@wailua.hpl.hp.com> (02/04/08 1.369.99.16)
   Misc fixes.

<davidm@wailua.hpl.hp.com> (02/04/05 1.369.99.15)
   Fix HP simulator Makefile for merge conflict with zx1 support patch.

<bjorn_helgaas@hp.com> (02/04/05 1.369.99.14)
   [PATCH] Add support for HP zx1 systems.
   

<davidm@wailua.hpl.hp.com> (02/04/05 1.369.99.13)
   New files for HP zx1 systems.

<davidm@wailua.hpl.hp.com> (02/04/05 1.369.99.12)
   Fix software I/O TLB to always return <4GB memory for alloc_consistent().

<davidm@wailua.hpl.hp.com> (02/04/02 1.369.99.11)
   arch/ia64/lib/copy_page_mck.S:
       Tweak for better performance when data is in L2 or L3 cache.

<garyhade@us.ibm.com> (02/04/02 1.369.99.10)
   [PATCH] arch/ia64/Makefile tweak
   

<Matt_Domsch@Dell.com> (02/04/02 1.369.99.9)
   [PATCH] Wouldn't you know it, but Richard Hirst found that I was *again* unparsing
   
   Patch below should apply to both the 2.5.7-pre1 and 2.4.18 trees.
   

<davidm@wailua.hpl.hp.com> (02/04/02 1.369.99.8)
   (arch/ia64/kernel/unwind_i.h): Fix typo in comment.

<davidm@wailua.hpl.hp.com> (02/04/01 1.369.99.7)
   Initialize ar.k0 with physical I/O base not just on BP but also on
   all APs (based on patch by Bjorn Helgaas).

<Matt_Domsch@Dell.com> (02/03/28 1.369.99.6)
   [PATCH] IA-64 specific part of Matt's patch:
   
   changes:
   * EFI_GUID macro defined per your suggestion - efi_guid_t is now a struct of
   char[16].  Fixed all GUID definitions.
   * Made one unified efi_guid_unparse() static inline in asm-ia64/efi.h.
   Removed three other definitions of similar in efivars.c and mca.c.
   * fixed endianness of fs/partitions/efi.c - thanks to Richard Hirst and his
   GPT work in Parted.
   * cleaned up find_valid_gpt() to make it easier to see what's going on and
   avoid future NULL ptr deref cases if this code gets modified yet again.
   * Only use partition table slots 0..max_p.  The previous behaviour would let
   you delete a partition in the middle of the table, and on next boot all the
   partition numbers above that would switch down.  This change makes it
   consistent with the MSDOS concept of primary partitions.  /dev/sdaX exists
   iff the partition type is not NULL.
   * Moved CONFIG_PARTITION_EFI help text to fs/partitions/Config.help
   

<elenstev@mesatop.com> (02/03/28 1.369.99.5)
   [PATCH] This patch adds 5 help texts to arch/ia64/Config.help.
   The texts were obtained from Eric S. Raymond's v2.97 Configure.help.
   

<davidm@hpl.hp.com> (02/03/28 1.369.99.4)
   [PATCH] First part of sync with 2.5.7 (ACPI still broken, Ski OK)..
   

<davidm@wailua.hpl.hp.com> (02/03/28 1.369.99.3)
   arch/ia64/defconfig:
   	Update for v2.5.7.
   

<davidm@wailua.hpl.hp.com> (02/03/27 1.369.99.2)
   Minor tweaks for McKinley-optimized copy_page().
   Fix configuration for HP Ski simulator.

<davidm@wailua.hpl.hp.com> (02/03/27 1.369.77.6)
   Fix ia64-version of thread_info.  Add McKinley-optimized copy_page().

<davidm@wailua.hpl.hp.com> (02/03/15 1.369.77.5)
   Cset exclude: davidm@hpl.hp.com|ChangeSet|20020312081510|17850

<davidm@wailua.hpl.hp.com> (02/03/14 1.369.43.3)
   Fix typos in qla1280.c and qla1280.h.

<davidm@wailua.hpl.hp.com> (02/03/14 1.369.78.2)
   Pick up binfmt_elf.c SET_PERSONALITY() fix from 2.4.18.

<davidm@hpl.hp.com> (02/03/13 1.369.66.7)
   [PATCH] Move __per_cpu_data from smp.h to compiler.h.
   

<jes@trained-monkey.org> (02/03/13 1.369.43.2)
   [PATCH] Clean up qla1280 SCSI driver.
   
   Clean up qla1280 SCSI driver.

<davidm@wailua.hpl.hp.com> (02/03/12 1.369.71.2)
   fs.h:
     Fix typo in definition of MAX_OFF_T.

<davidm@wailua.hpl.hp.com> (02/03/12 1.369.50.2)
   Clean up sys_prctl().

<davidm@wailua.hpl.hp.com> (02/03/12 1.369.71.1)
   Make sys_sendfile64() accept 64-bit fileoffsets on 64-bit platforms.
   Don't define sys_sendfile64() unless it's really needed.

<davidm@wailua.hpl.hp.com> (02/03/11 1.369.48.8)
   ide-geometry.c:
     Don't include RTC headerfile for IA-64.

<bjorn_helgaas@hp.com> (02/03/11 1.369.42.3)
   [PATCH] agpgart/DRM page_mask fix
   
   Support both 460GX and HP's zx1 chipset without having to put kludges in DRM.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.48.7)
   mmio_barrier.txt:
     new file

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.45.2)
   eepro100.c:
     Restore comment that was accidentally dropped by earlier patch.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.53.6)
   config:
     Update repo config.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.53.5)
   open.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.53.4)
   o3

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.53.3)
   o2

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.53.2)
   o1

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.53.1)
   o0

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.48.6)
   tmp-hacks5a

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.52.1)
   early-printk.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.48.5)
   tmp-hacks5

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.48.4)
   tmp-hacks4

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.48.3)
   tmp-hacks

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.51.1)
   console.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.50.1)
   fpemul.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.49.1)
   userpage.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.48.2)
   tmp-hacks2.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.48.1)
   tmp-hacks.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.47.2)
   Take advantage of CPU-local irqstat accessors.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.47.1)
   irq_cpustat.h:
     Rename local_irq_count() to irq_count() and local_bh_count() to bh_count().
     Provide old names as deprecated alternatives
     for now.  Define local_*() macros to provide
     local CPU efficient access to various irq_stat
     members.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.46.1)
   timer.c, time.c:
     Define and initialize time_offset variable to enable guaranteed monotonic time.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.42.2)
   agp_backend.h:
     Mention INTEL_460GX as a chipset.
     Add vmptr member to struct _agp_memory.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.45.1)
   eepro100.c:
     Bias Ethernet header so that IP header is (usually) aligned.
     Enable DMA even on word-oriented machines.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.44.1)
   64-bit cleanups for sound drivers.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.43.1)
   qlogic.diff

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.42.1)
   DRM fixes for IA-64.

<davidm@wailua.hpl.hp.com> (02/03/09 1.369.41.1)
   This patch provides a platform hook which can be used to force a successful
   system call return for system calls that can legitimately return (small)
   negative numbers.


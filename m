From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Sep 2003 17:59:50 +0000
Subject: [PATCH] 2.4.x arch/ia64 update
Message-Id: <marc-linux-ia64-106313111108959@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Marcelo,

Please do a

	bk pull http://lia64.bkbits.net/to-marcelo-2.4

This will update the following files:

 arch/ia64/Makefile                           |   26 
 arch/ia64/config.in                          |   17 
 arch/ia64/configs/dig                        |   18 
 arch/ia64/configs/generic                    |   18 
 arch/ia64/configs/numa                       |  998 +++++++++++
 arch/ia64/configs/ski                        |   17 
 arch/ia64/configs/zx1                        |   18 
 arch/ia64/defconfig                          |   18 
 arch/ia64/hp/common/sba_iommu.c              |   10 
 arch/ia64/hp/zx1/hpzx1_misc.c                |    2 
 arch/ia64/ia32/ia32_signal.c                 |   34 
 arch/ia64/ia32/ia32_support.c                |   20 
 arch/ia64/ia32/sys_ia32.c                    |   41 
 arch/ia64/kernel/Makefile                    |    1 
 arch/ia64/kernel/acpi.c                      |  331 +++
 arch/ia64/kernel/efi.c                       |    4 
 arch/ia64/kernel/efi_stub.S                  |    4 
 arch/ia64/kernel/efivars.c                   |   14 
 arch/ia64/kernel/entry.S                     |  382 +++-
 arch/ia64/kernel/entry.h                     |    3 
 arch/ia64/kernel/head.S                      |  160 +
 arch/ia64/kernel/iosapic.c                   |    2 
 arch/ia64/kernel/ivt.S                       |  379 ++--
 arch/ia64/kernel/mca.c                       |  338 ++--
 arch/ia64/kernel/mca_asm.S                   |    4 
 arch/ia64/kernel/minstate.h                  |  405 ++--
 arch/ia64/kernel/pal.S                       |   10 
 arch/ia64/kernel/palinfo.c                   |  298 +--
 arch/ia64/kernel/pci.c                       |   13 
 arch/ia64/kernel/perfmon.c                   |    6 
 arch/ia64/kernel/process.c                   |   57 
 arch/ia64/kernel/ptrace.c                    |  102 -
 arch/ia64/kernel/salinfo.c                   |    5 
 arch/ia64/kernel/setup.c                     |  146 +
 arch/ia64/kernel/signal.c                    |   59 
 arch/ia64/kernel/smpboot.c                   |   29 
 arch/ia64/kernel/traps.c                     |   20 
 arch/ia64/kernel/unaligned.c                 |    3 
 arch/ia64/kernel/unwind.c                    |   84 -
 arch/ia64/lib/idiv64.S                       |   35 
 arch/ia64/mm/Makefile                        |    2 
 arch/ia64/mm/discontig.c                     |  282 +++
 arch/ia64/mm/init.c                          |  278 +--
 arch/ia64/mm/numa.c                          |  104 +
 arch/ia64/mm/tlb.c                           |   58 
 arch/ia64/scripts/make_gas_hint_test.c       |   15 
 arch/ia64/sn/fakeprom/fpmem.c                |  221 ++
 arch/ia64/sn/fakeprom/fpmem.h                |   30 
 arch/ia64/sn/fakeprom/fpromasm.S             |   10 
 arch/ia64/sn/fakeprom/fw-emu.c               |  119 -
 arch/ia64/sn/fakeprom/main.c                 |   96 -
 arch/ia64/sn/fakeprom/make_textsym           |  168 ++
 arch/ia64/sn/io/Makefile                     |    5 
 arch/ia64/sn/io/drivers/Makefile             |    2 
 arch/ia64/sn/io/drivers/ifconfig_net.c       |   29 
 arch/ia64/sn/io/drivers/ioconfig_bus.c       |   26 
 arch/ia64/sn/io/drivers/pciba.c              |   12 
 arch/ia64/sn/io/hwgdfs/hcl.c                 |    9 
 arch/ia64/sn/io/hwgdfs/hcl_util.c            |    2 
 arch/ia64/sn/io/hwgfs/hcl.c                  |   89 -
 arch/ia64/sn/io/hwgfs/hcl_util.c             |    7 
 arch/ia64/sn/io/hwgfs/interface.c            |    6 
 arch/ia64/sn/io/io.c                         |  126 +
 arch/ia64/sn/io/machvec/iomv.c               |   11 
 arch/ia64/sn/io/machvec/pci.c                |   62 
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c     |  275 +--
 arch/ia64/sn/io/machvec/pci_dma.c            |   24 
 arch/ia64/sn/io/platform_init/Makefile       |    2 
 arch/ia64/sn/io/platform_init/irix_io_init.c |   73 
 arch/ia64/sn/io/sgi_if.c                     |   15 
 arch/ia64/sn/io/sn2/Makefile                 |    7 
 arch/ia64/sn/io/sn2/ioc4/Makefile            |   22 
 arch/ia64/sn/io/sn2/ioc4/ioc4.c              |  641 +++++++
 arch/ia64/sn/io/sn2/ioc4/sio_ioc4.c          | 2266 +++++++++++++++++++++++++++
 arch/ia64/sn/io/sn2/klconflib.c              |   29 
 arch/ia64/sn/io/sn2/klgraph.c                |  236 ++
 arch/ia64/sn/io/sn2/l1_command.c             |   22 
 arch/ia64/sn/io/sn2/ml_SN_init.c             |   62 
 arch/ia64/sn/io/sn2/ml_SN_intr.c             |   16 
 arch/ia64/sn/io/sn2/ml_iograph.c             |  124 -
 arch/ia64/sn/io/sn2/module.c                 |   70 
 arch/ia64/sn/io/sn2/pcibr/pcibr_ate.c        |   39 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c        |  302 ---
 arch/ia64/sn/io/sn2/pcibr/pcibr_error.c      |   16 
 arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c       |   15 
 arch/ia64/sn/io/sn2/pcibr/pcibr_rrb.c        |    8 
 arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c       |   13 
 arch/ia64/sn/io/sn2/pciio.c                  |  512 ------
 arch/ia64/sn/io/sn2/pic.c                    |   32 
 arch/ia64/sn/io/sn2/shub.c                   |   50 
 arch/ia64/sn/io/sn2/shub_intr.c              |   73 
 arch/ia64/sn/io/sn2/shuberror.c              |    4 
 arch/ia64/sn/io/sn2/shubio.c                 |   10 
 arch/ia64/sn/io/sn2/xbow.c                   |   91 -
 arch/ia64/sn/io/sn2/xtalk.c                  |    6 
 arch/ia64/sn/io/snia_if.c                    |  246 ++
 arch/ia64/sn/kernel/Makefile                 |    5 
 arch/ia64/sn/kernel/bte.c                    |    8 
 arch/ia64/sn/kernel/irq.c                    |   47 
 arch/ia64/sn/kernel/led.c                    |   56 
 arch/ia64/sn/kernel/setup.c                  |  194 ++
 arch/ia64/sn/kernel/sn2/Makefile             |    2 
 arch/ia64/sn/kernel/sn2/cache.c              |   12 
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c         |   55 
 arch/ia64/sn/kernel/sn2/timer.c              |    3 
 arch/ia64/sn/kernel/sn2/timer_interrupt.c    |   60 
 arch/ia64/sn/kernel/sn2_smp.c                |  242 ++
 arch/ia64/sn/kernel/sn_ivt.S                 |   96 +
 arch/ia64/sn/kernel/sn_ksyms.c               |    1 
 arch/ia64/tools/print_offsets.c              |   29 
 include/asm-ia64/a.out.h                     |    5 
 include/asm-ia64/acpi.h                      |   13 
 include/asm-ia64/bitops.h                    |   15 
 include/asm-ia64/elf.h                       |    2 
 include/asm-ia64/hw_irq.h                    |    8 
 include/asm-ia64/mca.h                       |    4 
 include/asm-ia64/mmzone.h                    |   63 
 include/asm-ia64/nodedata.h                  |   66 
 include/asm-ia64/numa.h                      |   85 +
 include/asm-ia64/numnodes.h                  |    7 
 include/asm-ia64/page.h                      |   17 
 include/asm-ia64/pci.h                       |    4 
 include/asm-ia64/pgtable.h                   |    8 
 include/asm-ia64/processor.h                 |   59 
 include/asm-ia64/ptrace.h                    |   39 
 include/asm-ia64/ptrace_offsets.h            |   66 
 include/asm-ia64/resource.h                  |    4 
 include/asm-ia64/sal.h                       |   48 
 include/asm-ia64/sigcontext.h                |    2 
 include/asm-ia64/smp.h                       |    1 
 include/asm-ia64/sn/bte.h                    |    9 
 include/asm-ia64/sn/cdl.h                    |    2 
 include/asm-ia64/sn/dmamap.h                 |   28 
 include/asm-ia64/sn/hcl.h                    |    8 
 include/asm-ia64/sn/invent.h                 |   10 
 include/asm-ia64/sn/io.h                     |    2 
 include/asm-ia64/sn/ioc4.h                   |   49 
 include/asm-ia64/sn/ioerror.h                |    4 
 include/asm-ia64/sn/ioerror_handling.h       |    6 
 include/asm-ia64/sn/iograph.h                |    7 
 include/asm-ia64/sn/klconfig.h               |   14 
 include/asm-ia64/sn/ksys/l1.h                |   26 
 include/asm-ia64/sn/module.h                 |   13 
 include/asm-ia64/sn/nodepda.h                |    5 
 include/asm-ia64/sn/pci/bridge.h             |   15 
 include/asm-ia64/sn/pci/pci_bus_cvlink.h     |    2 
 include/asm-ia64/sn/pci/pciba.h              |    8 
 include/asm-ia64/sn/pci/pcibr.h              |    5 
 include/asm-ia64/sn/pci/pcibr_private.h      |   10 
 include/asm-ia64/sn/pci/pciio.h              |  100 -
 include/asm-ia64/sn/pci/pic.h                |    9 
 include/asm-ia64/sn/serialio.h               |  477 +++++
 include/asm-ia64/sn/sgi.h                    |  144 -
 include/asm-ia64/sn/simulator.h              |    2 
 include/asm-ia64/sn/sn2/arch.h               |    2 
 include/asm-ia64/sn/sn2/io.h                 |    2 
 include/asm-ia64/sn/sn2/shubio.h             |    7 
 include/asm-ia64/sn/sn2/sn_private.h         |    1 
 include/asm-ia64/sn/sn_sal.h                 |   11 
 include/asm-ia64/sn/uart16550.h              |    6 
 include/asm-ia64/sn/xtalk/xtalk.h            |    2 
 include/asm-ia64/sn/xtalk/xwidget.h          |    4 
 include/asm-ia64/spinlock.h                  |   19 
 include/asm-ia64/system.h                    |    2 
 include/asm-ia64/topology.h                  |   63 
 include/asm-ia64/unwind.h                    |    4 
 include/asm-ia64/ustack.h                    |   16 
 167 files changed, 10282 insertions(+), 3339 deletions(-)

through these ChangeSets:

<erikj@subway.americas.sgi.com> (03/09/04 1.1107)
   ia64: 9/3/2003 SGI update.

<eranian@hpl.hp.com> (03/09/04 1.1106)
   ia64: Fix perfmon usage of rum/srsm and sum/ssm
   
   - fixes a problem with the rum/sum instructions being inoperative even
     at priv level zero when psr.sp=0.  Switching to ssm/rsm fixes the
     potential problem.

<steiner@sgi.com> (03/09/02 1.1105)
   ia64: remove some SN1 remnants, add a bit more SN2 support.
   
   	linux/arch/ia64/config.in
   		- delete some remnents of support for the SGI SN1 platform
   		- add config option for SN2. 
   
   	linux_base/arch/ia64/kernel/Makefile
   		- fix compile error (SN2 needs iosapic.o)
   
   	linux/arch/ia64/acpi.c
   		- update acpi.c to recognize the SN2 platform
   
   	linux/arch/ia64/kernel/efi_stub.S
   	linux/arch/ia64/kernel/head.S
   	linux/arch/ia64/kernel/pal.S
   		- backport of 2.6 "ia64_switch_mode" changes for non-identity
   	  	  mapped kernels

<bjorn.helgaas@hp.com> (03/08/29 1.1104)
   ia64: Remove AIC7XXX driver from ski defconfig.

<tony.luck@intel.com> (03/08/28 1.1103)
   ia64: Trim granules correctly in efi_memmap_walk()
   
   This was a fun one to track down.  I was trying to provide
   a fake SRAT table so that I could start working on some more
   ccNUMA issues on a non-NUMA tiger box, but my kernel kept dying
   while running scripts out of /etc/init.d/*
   
   I found I was getting an MCA while executing an lfetch.excl in
   clear_page_tables(), the address that was being fetched was
   0xe0000000000a00e8, which is non-cacheable VGA memory on Tiger.
   
   Root cause was the "trim" code in efi_memmap_walk() had failed
   to trim away all the blocks of memory in the bottom granule when
   it had seen the memory hole there, so the kernel had managed to
   allocate a page at 0x9c000 as a page table, and when the process
   using it ended, the cleanup code prefetched off the end of the
   page, and into the VGA memory, causing an MCA.
   
   The problem is that efi_memmap_walk() repeatedly trims the same
   entry, instead of trimming each of the entries in the granule.

<bjorn.helgaas@hp.com> (03/08/28 1.1102)
   [PATCH] ia64: fix SAVE_RESET so OS INIT handler works again
   
   The syscall optimization patches broke the OS INIT handler because
   SAVE_RESET was addressing relative to r12, which contains the virtual
   address of the stack pointer.  Fixed by addressing relative to r2/r3
   instead.

<bjorn.helgaas@hp.com> (03/08/28 1.1101)
   ia64: Fix minstate comments.

<bjorn.helgaas@hp.com> (03/08/28 1.1100)
   ia64: minstate.h: whitespace changes to reduce diffs with 2.5.

<bjorn.helgaas@hp.com> (03/08/28 1.1099)
   ia64: TRIVIAL: Remove extraneous '`'.

<bjorn.helgaas@hp.com> (03/08/28 1.1098)
   ia64: Clarify ACPI available_cpus handling.

<mort@wildopensource.com> (03/08/27 1.1097)
   [PATCH] ia64: max user stack size of main thread configurable via RLIMIT_STACK
   
   Make the size of the user stack based on the stack rlimit.
   The stack hard stack size now defaults to 2GB, but can be increased
    with ulimit up to 1/2 of the max mappable space in a region.
   For 16k pages, this makes the max stack size 8TB.

<steiner@sgi.com> (03/08/27 1.1096)
   ia64: add support for non-identity mapped kernels
   
   Attached is a patch that makes arch/ia64/kernel/head.S work on the
   SGI SN system. The patch consists mostly of a backport of portions
   of the same file from 2.6. 
   
   I tried to minimized differences between the new file & 2.6 as 
   opposed to minimizing differences between the new file & 2.4.21. 
   This makes the patch somewhat larger than needed but (I think) is 
   correct for the long term.
   
   
   The changes add support for non-identity mapped kernels. This patch
   does NOT change the kernel load address - it just adds support for the
   case where it was loaded into non-identity mapped memory.

<matthewc@cse.unsw.edu.au> (03/08/27 1.1095)
   smpboot.c, acpi.c:
     ia64: NR_CPUS and number of CPUs
   
   While building a kernel for our 4-way Lion box, I made the
   mistake of setting NR_CPUS to 4.  Little did I know that the
   Lion ACPI tables always list 8 CPUs (with only the first N
   enabled), and so the resulting kernel overflowed the
   smp_boot_data.cpu_phys_id array, crashed and burned.
   
   (Backported from 2.5 by Bjorn Helgaas).

<alex.williamson@hp.com> (03/08/26 1.1094)
   ia64: Correct NR_CPUS/cpu_online test order in CMC/CPE polling
   
      Oops, I must have only tested the UP polling on a 2.4 kernel.  On
   2.6, I hit the BUG_ON calling cpu_online(1).  Simply swapping the
   order of the test fixes it.  This should be applied for 2.6 and 2.4.

<arun.sharma@intel.com> (03/08/26 1.1093)
   ia64: fix memory leak in sys32_execve path
   
   The attached patch by Tony Luck fixes a memory leak in the ia32 execve 
   code path. Please apply to both 2.4 and 2.5.

<adsharma@unix-os.sc.intel.com> (03/08/26 1.1092)
   [PATCH] ia64: IA-32 compatibility patch: FP denormal handling
   
   The following patch makes ia64 compatible with i386 with respect to
   siginfo.si_code on FP denormal operands. This is necessary for the correct
   emulation of manycat /r/napali/tmp/p7 |bk-applypatch adsharma unix-os.sc.intel.com ia64:

<bjorn.helgaas@hp.com> (03/08/26 1.1091)
   ia64: Use $(CC), not $(AS), when checking for "hint @pause" support in binutils.

<bjorn.helgaas@hp.com> (03/08/26 1.1090)
   ia64: initialize bootmem early for acpi_table_init().

<steiner@sgi.com> (03/08/15 1.1087)
   ia64: Add ia64_imva() and a few more ia64_tpa() uses.
   
   Because of the strange memory map on the SGI SN hardware, we need a 
   portion of the 2.6 patches from Tony Luck backported into 2.4.21. 
   
   This patche adds the ia64_imva function & a few additional calls to ia64_tpa.
   
   In 2.6, these patches were part of the change to relocate the kernel to
   region 5. However, I am NOT proposing making that change!!  I just need the
   macros!!

<bjorn.helgaas@hp.com> (03/08/14 1.1086)
   ia64: Update defconfig to new generic config.

<bjorn.helgaas@hp.com> (03/08/14 1.1085)
   ia64 unwind: (unw_access_ar): initialize struct pt_regs *pt before using it to get AR_CSD & AR_SSD.
   White-space changes to follow 2.5.

<bjorn.helgaas@hp.com> (03/08/13 1.1083)
   ia64: Use ARRAY_SIZE(), fix formatting, remove static initializers to zero.
   	(Backported from 2.5).

<bjorn.helgaas@hp.com> (03/08/13 1.1082)
   ia64: Update configs for upstream changes.

<steiner@SGI.com> (03/08/12 1.1080)
   ia64: discontig/NUMA support
   
   Attached is the patch for discontig memory for 2.4.21. This patch
   has been tested on the ZX1 & NEC platforms & appears to work ok. It 
   also works on SN2 but there are additional patches (unrelated to 
   discontig) that at still needed in 2.4.21.

<bjorn.helgaas@hp.com> (03/08/12 1.1079)
   ia64: Fix check for binutils that supports "hint" instructions.

<bjorn.helgaas@hp.com> (03/08/08 1.1076)
   ia64: Comment changes to fix "correctable" usage.

<bjorn.helgaas@hp.com> (03/08/08 1.1075)
   ia64: sal.h: Backport spelling and other trivial changes from 2.5.

<alex_williamson@hp.com> (03/08/08 1.1074)
   ia64: Rename SAL_CALL_SAFE to SAL_CALL_REENTRANT.

<alex_williamson@hp.com> (03/08/08 1.1073)
   [PATCH] ia64: Update to CMC/CPE polling
   
    Based on the feedback from Tony, here's the patch that flips
   around the clearing of cmc_polling_enabled.

<alex_williamson@hp.com> (03/08/08 1.1072)
   [PATCH] ia64: New CMC/CPE polling
   
   Here's a redesign of the CMC and CPE polling for both 2.6.0-test2
   and 2.4.21.  This is roughly the same design I requested comment on
   a while back (BTW, nobody commented...).  Basically, rather than
   flooding all the cpus in parallel, I used some low priority interrupts
   to cascade through the cpus.  This should be much more scalable.  I
   also added a new feature of enabling interrupts for the CMC and CPE
   handlers.  The SAL spec claims these functions are SMP safe and
   re-entrant and even recommends that the corrected error handlers
   should run with interrupts enabled.  It works on HP boxes, others
   might want to double check that their firmware adheres to the spec.
   The combination of these things should keep polling from impacting
   system response time.

<bjorn.helgaas@hp.com> (03/08/08 1.1071)
   ia64: MCA: Find correct offset of OEM data (from Keith Owens).

<bjorn.helgaas@hp.com> (03/08/07 1.1069)
   ia64: minor bugfixes and whitespace cleanup to follow 2.5.

<bjorn.helgaas@hp.com> (03/08/07 1.1068)
   ia64: MCA: pass GP *physical address* to SAL.
   
   Based on a patch by Keith Owens.

<tony.luck@intel.com> (03/08/07 1.1067)
   ia64: cleaning up the INIT code
   	(Backported from 2.5 by Bjorn Helgaas)

<davidm@tiger.hpl.hp.com> (03/08/07 1.1066)
   ia64: Backtraces of all processes on INIT, warning cleanup.
   	(Backported from 2.5).

<bjorn.helgaas@hp.com> (03/08/05 1.1058.1.2)
   ia64: kernel/acpi.c: Whitespace changes to follow 2.5.

<kaos@sgi.com> (03/07/30 1.1019.1.31)
   ia64: Delete some generated ia64 files that were being left by make mrproper.

<bjorn.helgaas@hp.com> (03/07/30 1.1019.1.30)
   ia64: make cpu_relax() a barrier to be consistent with 2.5.

<willy@fc.hp.com> (03/07/30 1.1019.1.29)
   ia64: return PCI domain for pci_controller_num().

<rohit.seth@intel.com> (03/07/30 1.1019.1.28)
   ia64: Correct .unwabi for PT_REGS_SAVES (should be "3, 'i'").

<rohit.seth@intel.com> (03/07/30 1.1019.1.27)
   ia64: Restructure pt_regs and optimize syscall path.
   
   Patch by Rohit Seth, Fengua Yu, and Arun Sharma:
   
   The main items covered by this patch are:
   1) Support for 16 bytes instructions as per SDM2.1 (CSD/SSD in pt_regs)
   2) f10-f11 are added as additional scratch registers for kernel's use.
   3) Re-arrange pt_regs to access less cache lines in system call. Reduce
   scratch register saving/restoring in system call path.
   4) A few instruction reorg in low-level code.

<bjorn.helgaas@hp.com> (03/07/30 1.1019.1.26)
   ia64: tlb.c whitespace cleanup to follow 2.5.

<rohit.seth@intel.com> (03/07/30 1.1019.1.25)
   [PATCH] ia64: patch to use >256MB purges
   
   Attached is the updated patch that takes the supported purge page size
   bits from PAL call.
   
   Backported from 2.5, including two subsequent cleanups:
       ia64: Clean up purge-page-size-from-PAL patch a bit.
       ia64: Allow 4GB TLB purges by default.  Reported by Rohit Seth.

<kaos@sgi.com> (03/07/29 1.1019.1.24)
   ia64: Fix more UNW_DPRINT() typos.

<kaos@sgi.com> (03/07/29 1.1019.1.23)
   ia64: Correct typo in UNW_DPRINT() call.

<davidm@tiger.hpl.hp.com> (03/07/29 1.1019.1.22)
   ia64: handle_fpu_swa() scaling fix
   
   handle_fpu_swa() doesn't scale well if multiple CPUs need concurrent
   fp assist.  The problem lies with concurrent, potentially frequent
   updates of fpu_swa_count, which serves as the throttle for doing the
   printk().  A frenzy of concurrent updates will produce a frenzy of
   cacheline ping-ponging.
   
   The fix is simple:
   
   Only increment fpu_swa_count when the printk() is about to happen,
   which limits the increment to no more than four times every five
   seconds.

<rohit.seth@intel.com> (03/07/29 1.1019.1.21)
   ia64: use "hint @pause" in cpu_relax() and spinlock contention.

<kaos@ocs.com.au> (03/07/15 1.1003.36.4)
   ia64: Clean up several warnings (no functional change).

<arun.sharma@intel.com> (03/07/15 1.1003.36.3)
   ia64: translate F_GETLK64/F_SETLK64 to F_GETLK/F_SETLK
   
   Currently, sys32_fcntl64() is broken, because it passes F_*64 commands
   to sys_fcntl(), which it doesn't understand. The F_XXX64 commands need
   to be converted to F_XXX before calling sys_fcntl().

<bjorn.helgaas@hp.com> (03/07/14 1.1003.36.2)
   ia64: sys_ia32.c needs linux/quotacompat.h

<alex_williamson@hp.com> (03/07/10 1.1003.26.3)
   [PATCH] ia64: Use PAL_HALT_LIGHT in cpu_idle
   
   Here's patches for 2.4 & 2.5 to use PAL_HALT_LIGHT in cpu_idle.
   This helps to reduce CPU temp a little on boxes with firmware that
   takes advantage of this lower power state.  I've tried this on a
   rx2600 (2x900MHz McKinley) and an i2000 (fw 117) and it shows some
   benefit.  On McKinley systems, only the very latest PAL from Intel
   actually reduces power consumption in the halt_light state.  For HP
   rx2600/zx6000/zx2000, this means you need to be running firmware 1.82.
   
     Rohit Seth, at Intel, has run some benchmarks with this kind of
   modification and found the effects of enabling halt_light to fall
   within the noise of mosts tests.  I replaced pal_halt(1) in safe_halt
   with pal_halt_light() since halt_light is required to be implemented,
   but pal_halt(1) is an optional halt state.  I'd be interested to hear
   of any measurements anyone does using this, where it works/fails, and
   if any benchmarks/applications are impacted.

<bjorn.helgaas@hp.com> (03/07/10 1.1003.26.2)
   ia64: Merge to newer ACPI CA.

<bjorn.helgaas@hp.com> (03/07/10 1.1003.26.1)
   ia64: Remove partial semtimedop32 stuff from upstream.


Thanks!

Bjorn


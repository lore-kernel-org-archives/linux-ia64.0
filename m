From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Sep 2003 06:43:44 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106308985627549@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
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

 include/asm-ia64/sn/ioc3.h               |  705 -------------------------------
 include/asm-ia64/sn/klclock.h            |   61 --
 arch/ia64/Kconfig                        |    3 
 arch/ia64/Makefile                       |    1 
 arch/ia64/hp/common/sba_iommu.c          |    5 
 arch/ia64/hp/sim/boot/boot_head.S        |    8 
 arch/ia64/hp/sim/boot/bootloader.c       |   10 
 arch/ia64/ia32/elfcore32.h               |    5 
 arch/ia64/ia32/sys_ia32.c                |   11 
 arch/ia64/kernel/acpi.c                  |    4 
 arch/ia64/kernel/efi.c                   |    2 
 arch/ia64/kernel/entry.S                 |    4 
 arch/ia64/kernel/fsys.S                  |    4 
 arch/ia64/kernel/init_task.c             |    6 
 arch/ia64/kernel/perfmon.c               |  305 +++++++------
 arch/ia64/kernel/perfmon_hpsim.h         |   75 +++
 arch/ia64/kernel/smpboot.c               |    4 
 arch/ia64/kernel/time.c                  |   79 ++-
 arch/ia64/kernel/unwind.c                |    5 
 arch/ia64/oprofile/Kconfig               |   22 
 arch/ia64/oprofile/Makefile              |    9 
 arch/ia64/oprofile/init.c                |   25 +
 arch/ia64/scripts/toolchain-flags        |    2 
 arch/ia64/sn/io/drivers/ioconfig_bus.c   |   16 
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c |    2 
 arch/ia64/sn/io/machvec/pci_dma.c        |    2 
 arch/ia64/sn/io/sn2/ml_SN_intr.c         |    4 
 arch/ia64/sn/io/sn2/pcibr/pcibr_ate.c    |    1 
 arch/ia64/sn/io/sn2/pcibr/pcibr_config.c |    1 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c    |    1 
 arch/ia64/sn/io/sn2/pcibr/pcibr_error.c  |    1 
 arch/ia64/sn/io/sn2/pcibr/pcibr_hints.c  |    1 
 arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c   |    1 
 arch/ia64/sn/io/sn2/pcibr/pcibr_rrb.c    |    1 
 arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c   |    1 
 arch/ia64/sn/io/sn2/pic.c                |    1 
 include/asm-ia64/acpi.h                  |   78 +--
 include/asm-ia64/hw_irq.h                |    1 
 include/asm-ia64/intel_intrin.h          |  254 +++++++++++
 include/asm-ia64/ptrace.h                |    6 
 include/asm-ia64/signal.h                |   13 
 include/asm-ia64/sn/hcl.h                |    1 
 include/asm-ia64/sn/nodepda.h            |    2 
 include/asm-ia64/sn/pci/pciio.h          |   34 +
 include/asm-ia64/sn/sn2/intr.h           |    3 
 include/asm-ia64/spinlock.h              |   57 ++
 include/asm-ia64/uaccess.h               |   87 +++
 include/asm-ia64/unistd.h                |    1 
 48 files changed, 879 insertions(+), 1046 deletions(-)

through these ChangeSets:

<peterc@gelato.unsw.edu.au> (03/09/08 1.1242)
   [PATCH] ia64: unwind.c fix for spinlock-debug compilation
   
   If you try to compile 2.6.0-test[45] with spinlock debugging on, then
   unwind.c won't compile, because it uses a #define magic that hides
   the variable in the spinlock debugging code (also called magic).

<arun.sharma@intel.com> (03/09/08 1.1241)
   [PATCH] ia64: MINSIGSTKSZ on ia32
   
   MINSIGSTKSZ is defined differently for i386 and ia64. This patch improves
   compatibility with apps which use sigaltstack(2) with sizes between
   MINSIGSTKSZ_IA32 and MINSIGSTKSZ.

<suresh.b.siddha@intel.com> (03/09/08 1.1240)
   [PATCH] ia64: fix typo in spinlock.h
   

<jbarnes@sgi.com> (03/09/08 1.1153.64.28)
   [PATCH] ia64: fix current usage in sn2 code
   
   For some reason, we had a structure field called 'current'.  This patch
   fixes that.

<jbarnes@sgi.com> (03/09/08 1.1153.64.27)
   [PATCH] ia64: misc. sn2 updates
   
   Fix a couple of sn2 files.

<davidm@tiger.hpl.hp.com> (03/09/08 1.1153.64.26)
   ia64: Drop unnecessary version check in sba_iommu.c.

<davidm@tiger.hpl.hp.com> (03/09/08 1.1153.64.25)
   ia64: Fix things so that they compile with the latest GCC 3.4, which optimize
   	away static variables with no compiler-visible use.

<jes@wildopensource.com> (03/09/08 1.1153.64.24)
   [PATCH] ia64: remove unused sn2 header files
   
   This patch eliminates two unused SN2 header files:
   include/asm-ia64/sn/klclock.h and include/asm-ia64/sn/ioc3.h.

<davidm@tiger.hpl.hp.com> (03/09/05 1.1153.64.23)
   ia64: Direct sys_fadvise64() to sys_fadvise64_64().

<davidm@tiger.hpl.hp.com> (03/09/05 1.1153.64.22)
   ia64: Fix asm-ia64/acpi.h typo & name-collision.

<davidm@tiger.hpl.hp.com> (03/09/05 1.1153.64.21)
   ia64: Finnish adding ECC support.  Based on patch by Suresh Siddah.

<eranian@hpl.hp.com> (03/09/05 1.1153.64.20)
   [PATCH] ia64: perfmon2 update
   
   This patch fixes the following:
   
           - correct a bug in pfm_close() which was causing some per-process 
             sessions to not unreserve on exit.
   
           - changed the permission checking to load a context to allow more
             flexibility, modeled after ptrace_attach().

<davidm@tiger.hpl.hp.com> (03/09/05 1.1153.64.19)
   ia64: Document the typo that made it into the definition of MINSTKSZ
   	(last two numbers got transposed).  Thanks to Arun Sharma for
   	finding this.  New glibc's will have the value corrected, but
   	we leave the kernel at the old (bogus) value to retain backwards-
   	compatibility (and while a strange value, the old value works just
   	fine).

<davidm@tiger.hpl.hp.com> (03/09/02 1.1153.64.18)
   ia64: Drop unnecessary fadvise64_64() bloat (it isn't needed on 64-bit
   	platforms).

<eranian@hpl.hp.com> (03/08/28 1.1153.64.17)
   [PATCH] ia64: perfmon2 update
   
   This patch:- added support for the fake HP simulator PMU. Most of the
     code provided by Ian Wienand. Allows a kernel compiled for
     the simulator and with CONFIG_PERFMON enabled to boot.
   
   - cleaned up all CTX_*() macros for the context state changes.
   
   - relaxed constraint for system-wide session by allowing all
     task with access to the context's file descriptor to
     manipulate the context as long as they run on the CPU the
     context is attached to.

<tony.luck@intel.com> (03/08/28 1.1153.64.16)
   [PATCH] ia64: trim.bottom trims the wrong entry
   
   efi_memmap_walk() repeatedly trims the same
   entry, instead of trimming each of the entries in the granule.

<matthewc@cse.unsw.edu.au> (03/08/28 1.1153.64.15)
   [PATCH] ia64: Fix "nosmp" breakage from cpumask patch.
   
   Patch should be self-explanatory.

<tony.luck@intel.com> (03/08/28 1.1153.64.14)
   [PATCH] ia64: fix PM config option
   
   CONFIG_PM is set without a menu entry to turn it on/off.

<bjorn.helgaas@hp.com> (03/08/28 1.1153.64.13)
   [PATCH] ia64: clean up acpi_boot_init()
   
   I was confused about this bit
   of code in acpi_boot_init():
   
           smp_boot_data.cpu_count = available_cpus;
           if (available_cpus = 0) {
                   printk(KERN_INFO "ACPI: Found 0 CPUS; assuming 1\n");
                   available_cpus = 1; /* We've got at least one of these, no? */
           }
   
           smp_build_cpu_map();
   
   because it first saves available cpus in smp_boot_data, then potentially
   modifies available_cpus.  This looked at first like a bug, but I think
   actually works out correctly, because smp_boot_data.cpu_count is only
   used in smp_build_cpu_map(), and if cpu_count is zero, it prevents us
   from looking at smp_boot_data.cpu_phys_id[0], which hasn't been
   initialized.
   
   This should only happen with really buggy firmware, so I'm not even
   sure it's worth doing more than panicking, but if we're going to deal
   with it, I propose the following patch to avoid even the appearance
   of a bug.  This just does what acpi_parse_lsapic() would have done
   if the firmware tables were correct.

<wcohen@redhat.com> (03/08/28 1.1153.64.12)
   [PATCH] ia64: oprofile support
   
   I have revised the oprofile patch for ia64 to provide just the basic
   timer interrupt mechanism to avoid interferring with the perfmon 2.0
   support. I have verified the oprofile ia64 patch applies cleanly and
   build a working kernel with the 2.6.0-test4 kernel and the
   linux-2.6.0-test4-ia64-030826.diff.bz2 patch.
   
   More work is required to get oprofile to work with the perfmon 2.0.
   However, the patch as it is currently implements should not cause
   problems for the perfom 2.0 support.


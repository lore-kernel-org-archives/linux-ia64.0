From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 May 2004 21:45:20 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200405212145.i4LLjKUr026591@napali.hpl.hp.com>
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

 arch/ia64/kernel/perfmon_hpsim.h            |   75 ---
 arch/ia64/defconfig                         |   94 ++--
 arch/ia64/hp/sim/boot/boot_head.S           |   14 
 arch/ia64/ia32/Makefile                     |    4 
 arch/ia64/ia32/ia32_signal.c                |   19 
 arch/ia64/kernel/Makefile                   |    3 
 arch/ia64/kernel/efi.c                      |   27 +
 arch/ia64/kernel/fsys.S                     |   43 --
 arch/ia64/kernel/head.S                     |    9 
 arch/ia64/kernel/ivt.S                      |   35 +
 arch/ia64/kernel/machvec.c                  |    2 
 arch/ia64/kernel/perfmon.c                  |  555 ++++++++++++++++------------
 arch/ia64/kernel/perfmon_generic.h          |   10 
 arch/ia64/kernel/perfmon_hpsim.h            |   18 
 arch/ia64/kernel/perfmon_itanium.h          |   60 +--
 arch/ia64/kernel/perfmon_mckinley.h         |   45 --
 arch/ia64/kernel/process.c                  |    1 
 arch/ia64/kernel/signal.c                   |   17 
 arch/ia64/kernel/smp.c                      |    1 
 arch/ia64/kernel/smpboot.c                  |   47 +-
 arch/ia64/kernel/traps.c                    |   23 -
 arch/ia64/kernel/unwind.c                   |   72 ++-
 arch/ia64/kernel/unwind_i.h                 |    1 
 arch/ia64/mm/init.c                         |    1 
 arch/ia64/scripts/check-serialize.S         |    2 
 arch/ia64/scripts/toolchain-flags           |   10 
 arch/ia64/sn/io/io.c                        |    2 
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c    |   33 +
 arch/ia64/sn/io/platform_init/sgi_io_init.c |    7 
 arch/ia64/sn/io/sn2/klgraph.c               |   22 -
 arch/ia64/sn/io/sn2/ml_SN_init.c            |    8 
 arch/ia64/sn/io/sn2/ml_SN_intr.c            |   50 +-
 arch/ia64/sn/io/sn2/ml_iograph.c            |    8 
 arch/ia64/sn/io/sn2/module.c                |    4 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c       |    6 
 arch/ia64/sn/io/sn2/pic.c                   |    4 
 arch/ia64/sn/io/sn2/shuberror.c             |    4 
 arch/ia64/sn/io/sn2/shubio.c                |    4 
 arch/ia64/sn/kernel/setup.c                 |    6 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c     |   13 
 drivers/char/sn_serial.c                    |    8 
 include/asm-ia64/asmmacro.h                 |    8 
 include/asm-ia64/atomic.h                   |    4 
 include/asm-ia64/delay.h                    |    6 
 include/asm-ia64/gcc_intrin.h               |   14 
 include/asm-ia64/intel_intrin.h             |    3 
 include/asm-ia64/sn/arch.h                  |   14 
 include/asm-ia64/sn/intr.h                  |    2 
 include/asm-ia64/sn/module.h                |    4 
 include/asm-ia64/sn/nodepda.h               |    7 
 include/asm-ia64/sn/sn2/sn_private.h        |    2 
 include/asm-ia64/sn/types.h                 |    2 
 include/asm-ia64/system.h                   |   12 
 include/asm-ia64/unistd.h                   |    9 
 54 files changed, 773 insertions(+), 681 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/05/21 1.1635)
   ia64: Update defconfig

<davidm@tiger.hpl.hp.com> (04/05/21 1.1634)
   ia64: Kill a warning when arch/ia64/kernel/machvec.c gets compiled on UP.

<peterc@gelato.unsw.edu.au> (04/05/21 1.1633)
   ia64: Make cond_syscall() declare a dummy prototype so GCC doesn't complain.

<davidm@tiger.hpl.hp.com> (04/05/20 1.1632)
   ia64: Reserve syscall number for kexec_load().

<davidm@tiger.hpl.hp.com> (04/05/20 1.1631)
   ia64: Fix bug in fsys_rt_sigprocmask() reported by Andreas Schwab.

<eranian@hpl.hp.com> (04/05/19 1.1630)
   [PATCH] ia64: fix 1-CPU PMC/PMD dump for /proc/perfmon when PFM_DEBUG is on

<davidm@tiger.hpl.hp.com> (04/05/13 1.1629)
   ia64: Correct atomic_inc_and_test() and atomic64_inc_and_test().

<davidm@tiger.hpl.hp.com> (04/05/13 1.1628)
   ia64: fix spurious "timer tick before it's due" problem
   
   Patch Bjorn Helgaas: Fix the "timer tick before it's due" complaint
   from timer_interrupt().  The problem was that smp_callin() turned
   on the periodic timer tick before syncing the ITC with the BP.
   
   Syncing the ITC happens with interrupts disabled, and if you're
   unlucky enough to (1) pend a timer interrupt, and (2) set the ITC
   back before the ITM value that caused the timer interrupt, you
   can get stuck for several iterations in the following cycle
   (assume 100 clocks per tick):
   
       ITC     ITM
       ---	    ---
                       ia64_init_itm()
       100	    200	        schedule first tick at 200
                       ia64_sync_itc()
                           disable interrupts
       200     200         ITC = ITM; pend IT interrupt
       150                 set ITC to sync with BP
                           enable interrupts
                           recognize pending IT interrupt
                           disable IT interrupts
                       timer_interrupt()
       160     200         notice that 160 < 200,
                               printk "timer tick before it's due")
       200     200         ITC = ITM; pend IT interrupt
   	    300         set ITM for next tick
                           re-enable IT interrupt
                           recognize pending IT interrupt
                           disable IT interrupts
                       timer_interrupt()
       260     300         notice that 260 < 300,
                               printk "timer tick before it's due")
   
       ...	            repeat until you're tired or timer_interrupt()
                       takes long enough that the ITC lands after the
                       ITM
   
   This patch syncs the ITC with the BP before starting up the
   periodic tick, so the above scenario should never happen.
   
   This doesn't change how the timer tick on the BP is started;
   that happens quite early (and must be early because things
   like calibrate_delay() depend on jiffies updates).

<eranian@hpl.hp.com> (04/05/13 1.1627)
   [PATCH] ia64: switch /proc/perfmon to seq_file avoid buffer overflows
   
   Switches /proc/perfmon to using the seq_file interface.  This is more
   inline with the rest of the kernel and avoid crashes for very large
   machine configurations.
   
   Based on patch by Dean Nelson.

<jbarnes@engr.sgi.com> (04/05/12 1.1626)
   [PATCH] ia64: map display option ROMs on SN2
   
   By default, the sn2 PCI init code doesn't map option ROM address
   ranges since PIO address space is limited.  However, we do need to map
   display option ROMs in the event that userland applications want to
   read and emulate them.

<jbarnes@engr.sgi.com> (04/05/12 1.1625)
   [PATCH] ia64: This patch kills some unused lines and redundant functions

<davidm@tiger.hpl.hp.com> (04/05/12 1.1624)
   ia64: Call print_modules() before printing tombstone.

<jbarnes@engr.sgi.com> (04/05/12 1.1623)
   [PATCH] ia64: kill warnings in sn2 specific pci init
   
   A couple of unused variable warnings cropped up in the sn2 pci init routine.
   This patch kills the unused variables.

<jbarnes@engr.sgi.com> (04/05/12 1.1622)
   [PATCH] ia64: sn_get_node_first_cpu() is redundant
   
   sn_get_node_first_cpu() is redundant, so kill it.  Since calls to this routine 
   happen rather late in the boot process, using the generic topology functions 
   is safe.  Fixup the callers and kill the function.

<eranian@hpl.hp.com> (04/05/11 1.1621)
   [PATCH] ia64: perfmon dv serialization patch
   
   Add ia64_dv_serialize_*() macros to ia64_set_*br() calls to avoid DV warnings
   from the assembler (requires updated assembler).

<davidm@tiger.hpl.hp.com> (04/05/10 1.1620)
   ia64: Minor changes to get a (mostly) clean compile with GCC pre-3.5.

<davidm@tiger.hpl.hp.com> (04/05/10 1.1619)
   ia64: Add support to the kernel unwinder for the ".save rp, r0" idiom.
   
   Based on patch by Keith Owens.

<eranian@hpl.hp.com> (04/05/07 1.1587.10.13)
   [PATCH] ia64: make perfmon treat Ski simulator like real Itanium chip
   
   Remove perfmon_hpsim.c. Support is folded into perfmon_itanium.c or
   perfmon_itanium2.c depending on how Ski identifies itself via the CPU
   ID family (Merced or McKinley/Madison).  Also fix firmware emulator
   PAL_PERFMON_INFO emulation to report Itanium2 information.

<hch@lst.de> (04/05/07 1.1587.10.12)
   [PATCH] ia64: fix MOD_{INC,DEC}_USE_COUNT use in prominfo
   
   set proper proc_entry owner instead.  Patch OK'd by Jesse Barnes.

<davidm@tiger.hpl.hp.com> (04/05/06 1.1587.10.11)
   ia64: Fix spurious GAS dependency-violation (dv) warnings by taking
   	advantage of two new GAS directives (.serialize.{data,instruction}).

<pfg@sgi.com> (04/05/06 1.1587.10.10)
   [PATCH] ia64: SN2 - remove node_first_cpu member
   
   Remove node_first_cpu member from nodepda_s and replace its usage with calls
   to sn_get_node_first_cpu().

<davidm@tiger.hpl.hp.com> (04/05/05 1.1587.10.9)
   ia64: rename "mem" boot parameter to "max_addr" and implement proper "mem"
   
   Patch by Robert Picco:
   
   This patch renames the mem bootparameter to max_addr and implements the mem
   boot parameter to work as documented (i.e., to limit the amount of memory
   to be recognized by the kernel).

<a.othieno@bluewin.ch> (04/05/05 1.1587.10.8)
   [PATCH] ia64: arch/ia64/kernel/smp.c: kill duplicate #include
   
   linux/cache.h is included more than once.

<bjorn.helgaas@hp.com> (04/05/05 1.1587.10.7)
   [PATCH] ia64: initialize IO-port-base early
   
   (start_secondary): Set up IO port base here, in case early console
   needs it.
   (smp_callin): Move IO port base setup to start_secondary().

<eranian@hpl.hp.com> (04/05/05 1.1587.10.6)
   [PATCH] ia64: perfmon update
   
   - Cleanup the read/write check routines for pfm_write_pmcs,
     pfm_write_pmds, pfm_read_pmds.
   
   - Autodetect the PMU model. No need to have the kernel compiled for
     Itanium, HP Simulator, or Itanium2. The support for all PMU models
     is included.  Probing is based on processor family and
     platform_name, if necessary.  With this patch, it is possible to use
     an Itanium2 compiled kernel on an Itanium 1 system and get perfmon
     to work.
   
   - Removed remaining dependency on CONFIG_MCKINLEY by adding a new
     field (flags) to pmu_config_t.  Update /proc/perfmon to show the new
     field.
   
   - Fixed a bug in the Itanium2 pmc_ita2_write_check() where an inactive
     PMC13 would be considered active.

<davidm@tiger.hpl.hp.com> (04/05/03 1.1587.10.5)
   ia64: Avoid ".save rp, r0" since the kernel unwinder doesn't support it yet.
   
   Once we switch to a libunwind-based kernel unwinder, this code can be
   re-enabled again.


From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 May 2004 07:02:34 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200405110702.i4B72Yjn024733@napali.hpl.hp.com>
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

 arch/ia64/kernel/perfmon_hpsim.h        |   75 --------
 arch/ia64/hp/sim/boot/boot_head.S       |   14 -
 arch/ia64/ia32/Makefile                 |    4 
 arch/ia64/ia32/ia32_signal.c            |   19 --
 arch/ia64/kernel/Makefile               |    3 
 arch/ia64/kernel/efi.c                  |   27 ++
 arch/ia64/kernel/fsys.S                 |    4 
 arch/ia64/kernel/head.S                 |    9 
 arch/ia64/kernel/ivt.S                  |   35 +++
 arch/ia64/kernel/perfmon.c              |  291 +++++++++++++++++---------------
 arch/ia64/kernel/perfmon_generic.h      |   10 -
 arch/ia64/kernel/perfmon_hpsim.h        |   18 -
 arch/ia64/kernel/perfmon_itanium.h      |   60 +++---
 arch/ia64/kernel/perfmon_mckinley.h     |   45 ++--
 arch/ia64/kernel/signal.c               |   17 -
 arch/ia64/kernel/smp.c                  |    1 
 arch/ia64/kernel/smpboot.c              |    8 
 arch/ia64/kernel/traps.c                |   23 --
 arch/ia64/kernel/unwind.c               |   72 ++++++-
 arch/ia64/kernel/unwind_i.h             |    1 
 arch/ia64/mm/init.c                     |    1 
 arch/ia64/scripts/check-serialize.S     |    2 
 arch/ia64/scripts/toolchain-flags       |   10 +
 arch/ia64/sn/io/sn2/ml_SN_intr.c        |   26 ++
 arch/ia64/sn/kernel/setup.c             |    6 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |   13 -
 drivers/char/sn_serial.c                |    3 
 include/asm-ia64/asmmacro.h             |    8 
 include/asm-ia64/gcc_intrin.h           |   14 +
 include/asm-ia64/intel_intrin.h         |    3 
 include/asm-ia64/sn/arch.h              |    2 
 include/asm-ia64/sn/nodepda.h           |    7 
 include/asm-ia64/system.h               |   12 -
 include/asm-ia64/unistd.h               |    4 
 34 files changed, 431 insertions(+), 416 deletions(-)

through these ChangeSets:

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


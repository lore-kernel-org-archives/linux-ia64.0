From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 May 2004 22:21:54 +0000
Subject: kernel update (relative to v2.6.6)
Message-Id: <200405212221.i4LMLsRp026695@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch can now be found at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

in file:

 linux-2.6.6-ia64-040521.diff.gz

1-line summaries of ia64-specific changes since 2.6.5 is attached below.

If you use lots of groups, you'll want to upgrade to this kernel since
it contains this important bug-fix:

ChangeSet@1.1622, 2004-05-12 12:03:35-07:00, edwardsg@sgi.com
  [PATCH] calculate NGROUPS_PER_BLOCK from PAGE_SIZE

  On ia64, EXEC_PAGESIZE (max page size) is 65536, but the default page
  size is 16k.  This results in NGROUPS_PER_BLOCK in include/linux/sched.h
  being calculated incorrectly when the page size is anything other than
  64k.  For example, on a 16k page size kernel, a setgroups() call with a
  gidsetsize of 65536 will end up walking over memory since only 1/4 of
  the needed pages were allocated for the blocks[] array in the group_info
  struct.

  Patch below calculates NGROUPS_PER_BLOCK from PAGE_SIZE instead.

I have tested it with Ski simulator and various (zx1-based) Itanium 2
machines.  YMMV.

Remember that if you want to get a (mostly) warning-free build, you'll
need to upgrade to a version of GAS that supports the new .serialize
directive (old GAS will work fine, it'll just produce more warnings).

Enjoy,

	--david

  * Update defconfig
  * Kill a warning when arch/ia64/kernel/machvec.c gets compiled on UP.
  * Make cond_syscall() declare a dummy prototype so GCC doesn't complain.
  * Fix bug in fsys_rt_sigprocmask() reported by Andreas Schwab.
  * fix 1-CPU PMC/PMD dump for /proc/perfmon when PFM_DEBUG is on
  * Correct atomic_inc_and_test() and atomic64_inc_and_test().
  * fix spurious "timer tick before it's due" problem
  * switch /proc/perfmon to seq_file avoid buffer overflows
  * map display option ROMs on SN2
  * This patch kills some unused lines and redundant functions
  * Call print_modules() before printing tombstone.
  * kill warnings in sn2 specific pci init
  * sn_get_node_first_cpu() is redundant
  * perfmon dv serialization patch
  * Minor changes to get a (mostly) clean compile with GCC pre-3.5.
  * Add support to the kernel unwinder for the ".save rp, r0" idiom.
  * make perfmon treat Ski simulator like real Itanium chip
  * fix MOD_{INC,DEC}_USE_COUNT use in prominfo
  * Fix spurious GAS dependency-violation (dv) warnings by taking
  * SN2 - remove node_first_cpu member
  * rename "mem" boot parameter to "max_addr" and implement proper "mem"
  * arch/ia64/kernel/smp.c: kill duplicate #include
  * initialize IO-port-base early
  * perfmon update
  * Avoid ".save rp, r0" since the kernel unwinder doesn't support it yet.
  * SN2 fix
  * Fix Exec-Only stack patch so X can work again.
  * BUG if smp_call_function is called with interrupts disabled
  * SN_SAL_PRINT_ERROR is reentrant
  * Remove SN PDA page overflow check
  * bug w/ shared interrupts
  * Add message-queue support to copy_siginfo_from_user().
  * add mq support for ia64
  * fpswa_interface needs to be exported

From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Oct 2004 22:56:00 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200410072256.i97Mu0w20904@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.9

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Makefile                |    6 
 arch/ia64/hp/common/sba_iommu.c   |    6 
 arch/ia64/ia32/elfcore32.h        |   14 +
 arch/ia64/ia32/ia32_entry.S       |    2 
 arch/ia64/ia32/ia32_ldt.c         |   25 +--
 arch/ia64/ia32/ia32_signal.c      |  153 +++++++++++---------
 arch/ia64/ia32/ia32_support.c     |    4 
 arch/ia64/ia32/ia32priv.h         |    8 -
 arch/ia64/ia32/sys_ia32.c         |  282 ++++++++++++++++++++------------------
 arch/ia64/kernel/acpi-ext.c       |    2 
 arch/ia64/kernel/acpi.c           |    8 -
 arch/ia64/kernel/asm-offsets.c    |    5 
 arch/ia64/kernel/efi.c            |   10 -
 arch/ia64/kernel/iosapic.c        |   18 +-
 arch/ia64/kernel/irq.c            |    4 
 arch/ia64/kernel/irq_ia64.c       |    7 
 arch/ia64/kernel/module.c         |   20 +-
 arch/ia64/kernel/palinfo.c        |    2 
 arch/ia64/kernel/patch.c          |   26 +--
 arch/ia64/kernel/perfmon.c        |   21 +-
 arch/ia64/kernel/process.c        |   22 +-
 arch/ia64/kernel/ptrace.c         |  109 +++++++++-----
 arch/ia64/kernel/salinfo.c        |    6 
 arch/ia64/kernel/setup.c          |    2 
 arch/ia64/kernel/sigframe.h       |    2 
 arch/ia64/kernel/signal.c         |   30 ++--
 arch/ia64/kernel/smp.c            |    2 
 arch/ia64/kernel/sys_ia64.c       |    4 
 arch/ia64/kernel/time.c           |    2 
 arch/ia64/kernel/traps.c          |   25 +--
 arch/ia64/kernel/unaligned.c      |   18 +-
 arch/ia64/kernel/unwind.c         |   30 ++--
 arch/ia64/lib/csum_partial_copy.c |   12 -
 arch/ia64/lib/io.c                |   22 +-
 arch/ia64/mm/contig.c             |    2 
 arch/ia64/mm/extable.c            |    2 
 arch/ia64/mm/fault.c              |    2 
 arch/ia64/mm/init.c               |    8 -
 arch/ia64/mm/tlb.c                |    2 
 drivers/char/agp/hp-agp.c         |   16 +-
 drivers/char/efirtc.c             |   19 +-
 include/asm-ia64/compat.h         |    8 -
 include/asm-ia64/elf.h            |    6 
 include/asm-ia64/gcc_intrin.h     |   24 +--
 include/asm-ia64/hardirq.h        |    2 
 include/asm-ia64/hw_irq.h         |    2 
 include/asm-ia64/ia32.h           |    2 
 include/asm-ia64/io.h             |   85 +++++------
 include/asm-ia64/iosapic.h        |    8 -
 include/asm-ia64/mmu_context.h    |   12 -
 include/asm-ia64/page.h           |    4 
 include/asm-ia64/pgtable.h        |   10 -
 include/asm-ia64/processor.h      |   10 -
 include/asm-ia64/siginfo.h        |    2 
 include/asm-ia64/signal.h         |    4 
 include/asm-ia64/smp.h            |    8 -
 include/asm-ia64/spinlock.h       |    4 
 include/asm-ia64/system.h         |    4 
 include/asm-ia64/thread_info.h    |    8 -
 include/asm-ia64/uaccess.h        |   87 +++++++----
 include/asm-ia64/unistd.h         |    4 
 61 files changed, 681 insertions(+), 573 deletions(-)

through these ChangeSets:

<arun.sharma@intel.com> (04/10/07 1.2063)
   [IA64] Added support for the new syscall sys_waitid()
   
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<arun.sharma@intel.com> (04/10/07 1.2062)
   [IA64] sparse annotations and cleanups for ia32 subsystem
   
   + Add sparse annotations to ia32 subsystem so it checks out cleanly.
   + Add set_fs(KERNEL_DS) in elfcore32.h
   + Use compat_ptr() instead of P()
   + Fix a bug in ia32_sigsuspend() by introducing __ia32_rt_sigsuspend()
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/06 1.2061)
   [IA64] fix UP build
   
   Put back a secondary declaration of ipi_base_addr in hardirq.h.  It
   really is needed for UP builds and there doesn't seem to be an easy
   way to avoid include-hell otherwise.
   
   Signed-off-by: davidm@hpl.hp.com
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/10/06 1.2060)
   [IA64] Don't hardcode offsets in thread_info
   
   We had hardcoded defines for TI_TASK TI_EXEC_DOMAIN, TI_FLAGS, TI_CPU,
   TI_ADDR_LIMIT, TI_PRE_COUNT, TI_RESTART_BLOCK; but only two of these
   were ever used.  Remove all from thread_info.h, and generate the two
   that we do use (TI_FLAGS and TI_PRE_COUNT) in asm_offsets.c
   
   Patch supplied by Zou Nan hai
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2059)
   [IA64] minor sparse cleanups
   
   Here are three more sparse-triggered fixes which didn't fit anywhere
   else.  The first one gets rid of some quoting in palinfo.c which
   sparse doesn't like.  This used to be necessary because GCC would
   otherwise warn about an unknown trigraph.  That's not a problem
   anymore since the kernel is now being compiled with -Wno-trigraphs.
   The efirtc.c patch is mostly sparse-annotations but also cleans up
   trailing whitespace.  Finally, the bitfields in rwlock_t are changed
   to be explicitly "unsigned" to avoid a warning from sparse (it doesn't
   like 1-bit signed bitfields in particular).
                                                                                   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2058)
   [IA64] sparse __iomem annotations
   
   This patch adds __iomem annotations.  The only less-than-trivial part
   of the patch is the change of ipi_base_addr from "unsigned long" to
   "void __iomem *" but even that part should be safe.  The patch results
   in additional warnings from certain drivers (e.g., eepro100.c) but the
   warnings are harmless and just indicate that the offending drivers
   need to be updated for the more strict __iomem checking.  The patch
   has been boot-tested.
    
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2057)
   [IA64] minimal sparse-enablement; add __user annotations
   
   This enables sparse for ia64 and adds a basic set of __user
   annotations.  Apart for sys_execve() and the uaccess.h changes, the
   patch is trivially safe.  Also note that in gcc_intrin.h, I
   changed "asm __volatile" to "asm volatile" since sparse didn't
   like the old version (and it's a "strane" version anyhow).
   Patch has been (boot) tested.
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2056)
   [IA64] sparse "long" constant cleanup patch
   
   Sparse wants us to be clear about (unsigned) long constants.
   Make it so.
    
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2055)
   [IA64] sparse 0 vs. NULL cleanup patch
   
   Sparse really wants NULL for NULL-pointers.  This patch makes it so.
   The patch should be safe.  It compiles fine, creates no additional
   warnings, and the results has been boot-tested on an rx2600.
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tomy.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2054)
   [IA64] Don't directly deref user pointers.
   
   copy_siginfo_from_user32() directly dereferences a user-pointer, which
   is a no-no.  At that point, to->si_code already has been initialized
   so I think we can just use to->si_code instead.  Compile-tested (only)
   patch attached.
   
   Signed-off-by: davidm@hpl.hp.com
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2053)
   [IA64] fix argument-order in access_ok() call from csum_partial_copy_from_user
   
   Another sparse-detected bug.
   
   Signed-off-by: davidm@hpl.hp.com
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2052)
   [IA64] ptrace.c: Fix unchecked user-memory accesses due to ptrace_{get,set}regs()
   
   Here is another fix for a sparse-detected bug: turns out
   ptrace_getregs() and ptrace_putregs() did unchecked user-memory
   accesses!  These were tricky to see, so it's not surprising that they
   went unnoticed so far.  Fortunately, sparse can detect these
   trivially.  Patch below should fix the problem, but it's completely
   untested (I don't have any testcases for getregs/putregs).
   
   These were found by sparse.
   
   Signed-off-by: davidm@hpl.hp.com
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (04/10/05 1.2051)
   [IA64] signal.c: fix wrong argument order in __copy_to_user() call
   
   Signed-off-by: davidm@hpl.hp.com
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<eranian@hpl.hp.com> (04/10/05 1.2050)
   [IA64] perfmon2 fasync fix
   
   the pfm_fasync() function must not lock the context and mask interrupts
   because the fasync_helper() function may allocate memory and this could
   lead to sleeping, due to SLAB_KERNEL memory type, if no memory is available.
   Going to sleep with interrupts mask is not allowed otherwise you have a deadlock.
   The locking of the context is not necessary in this function because it is protected
   by caller via get_fd()/put_fd(). The async_queue is also protected. Serialization to
   pfm_fasync() is also ensured by caller. The fix is to drop the PROTECT_CTX()
   and UNPROTECT_CTX() calls.
   
   signed-off-by: stephane eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<mingo@elte.hu> (04/10/01 1.2009.3.4)
   [IA64] Makefile: Fix to make ccache/distcc happy.
   
   the (tested) patch below fixes ccache/distcc-assisted building of the
   ia64 tree. (CC is "ccache distcc gcc" in that case, not a simple
   one-word "gcc" - this confused the check-gas and toolchain-flags
   scripts.)
   
   Signed-off-by: Ingo Molnar <mingo@elte.hu>
   Signed-off-by: Tony Luck <tony.luck@intel.com>


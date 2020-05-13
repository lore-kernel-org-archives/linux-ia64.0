From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Wed, 13 May 2020 20:48:48 +0000
Subject: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, linux-kernel@vger.kernel.org, Christian Brauner <christian.brauner@ubuntu.com>

This is part of a larger series that aims at getting rid of the
copy_thread()/copy_thread_tls() split that makes the process creation
codepaths in the kernel more convoluted and error-prone than they need
to be.
I'm converting all the remaining arches that haven't yet switched and
am collecting individual acks. Once I have them, I'll send the whole series
removing the copy_thread()/copy_thread_tls() split, the
HAVE_COPY_THREAD_TLS define and the legacy do_fork() helper. The only
kernel-wide process creation entry point for anything not going directly
through the syscall path will then be based on struct kernel_clone_args.
No more danger of weird process creation abi quirks between architectures
hopefully, and easier to maintain overall.
It also unblocks implementing clone3() on architectures not support
copy_thread_tls(). Any architecture that wants to implement clone3()
will need to select HAVE_COPY_THREAD_TLS and thus need to implement
copy_thread_tls(). So both goals are connected but independently
beneficial.

HAVE_COPY_THREAD_TLS means that a given architecture supports
CLONE_SETTLS and not setting it should usually mean that the
architectures doesn't implement it but that's not how things are. In
fact all architectures support CLONE_TLS it's just that they don't
follow the calling convention that HAVE_COPY_THREAD_TLS implies. That
means all architectures can be switched over to select
HAVE_COPY_THREAD_TLS. Once that is done we can remove that macro (yay,
less code), the unnecessary do_fork() export in kernel/fork.c, and also
rename copy_thread_tls() back to copy_thread(). At this point
copy_thread() becomes the main architecture specific part of process
creation but it will be the same layout and calling convention for all
architectures. (Once that is done we can probably cleanup each
copy_thread() function even more but that's for the future.)

Since ia64 does support CLONE_SETTLS there's no reason to not select
HAVE_COPY_THREAD_TLS. This brings us one step closer to getting rid of
the copy_thread()/copy_thread_tls() split we still have and ultimately
the HAVE_COPY_THREAD_TLS define in general. A lot of architectures have
already converted and ia64 is one of the few hat haven't yet. This also
unblocks implementing the clone3() syscall on ia64. Once that is done we
can get of another ARCH_WANTS_* macro.

Once Any architecture that supports HAVE_COPY_THREAD_TLS cannot call the
do_fork() helper anymore. This is fine and intended since it should be
removed in favor of the new, cleaner _do_fork() calling convention based
on struct kernel_clone_args. In fact, most architectures have already
switched.  With this patch, ia64 joins the other arches which can't use
the fork(), vfork(), clone(), clone3() syscalls directly and who follow
the new process creation calling convention that is based on struct
kernel_clone_args which we introduced a while back. This means less
custom assembly in the architectures entry path to set up the registers
before calling into the process creation helper and it is easier to to
support new features without having to adapt calling conventions. It
also unifies all process creation paths between fork(), vfork(),
clone(), and clone3(). (We can't fix the ABI nightmare that legacy
clone() is but we can prevent stuff like this happening in the future.)

I tried my very best to test this patch including installing Debian 3
and 4 to try and get my hands on a gcc version that would allow
cross-compiling for ia64. But no, even that wasn't possible let alone a
working qemu for ia64. So this is largely untested but hopefully a
straightforward change. If this breaks something we will hear from
people if they still care about new kernels on ia64 since they won't be
able to get any further than trying to start init. :) If this patch
breaks it, I'll fix it.

(I had a different patch similar to what I did for sparc where I'm passing
 in struct pt_regs directly instead of keeping the in* to out* parameters
 but it wasn't immediately obvious to me what the registers in struct
 pt_regs would be for the syscall arguments that would correspond to out*
 and the ia64 documentation for the Linux syscall convention didn't explain
 this in more detail; I also doubt it matters much.)

For some more context, please see:
commit 606e9ad20094f6d500166881d301f31a51bc8aa7
Merge: ac61145a725a 457677c70c76
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sat Jan 11 15:33:48 2020 -0800

    Merge tag 'clone3-tls-v5.5-rc6' of git://git.kernel.org/pub/scm/linux/kernel/git/brauner/linux

    Pull thread fixes from Christian Brauner:
     "This contains a series of patches to fix CLONE_SETTLS when used with
      clone3().

      The clone3() syscall passes the tls argument through struct clone_args
      instead of a register. This means, all architectures that do not
      implement copy_thread_tls() but still support CLONE_SETTLS via
      copy_thread() expecting the tls to be located in a register argument
      based on clone() are currently unfortunately broken. Their tls value
      will be garbage.

      The patch series fixes this on all architectures that currently define
      __ARCH_WANT_SYS_CLONE3. It also adds a compile-time check to ensure
      that any architecture that enables clone3() in the future is forced to
      also implement copy_thread_tls().

      My ultimate goal is to get rid of the copy_thread()/copy_thread_tls()
      split and just have copy_thread_tls() at some point in the not too
      distant future (Maybe even renaming copy_thread_tls() back to simply
      copy_thread() once the old function is ripped from all arches). This
      is dependent now on all arches supporting clone3().

      While all relevant arches do that now there are still four missing:
      ia64, m68k, sh and sparc. They have the system call reserved, but not
      implemented. Once they all implement clone3() we can get rid of
      ARCH_WANT_SYS_CLONE3 and HAVE_COPY_THREAD_TLS.

Note that in the meantime, m68k has already switched to the new calling
convention. And I've got sparc patches acked by Dave, too.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Cc: Qais Yousef <qais.yousef@arm.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 arch/ia64/Kconfig          |  1 +
 arch/ia64/kernel/entry.S   | 36 +++++++++++++++---------------------
 arch/ia64/kernel/process.c | 33 +++++++++++++++++++++++++++------
 3 files changed, 43 insertions(+), 27 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index bab7cd878464..952aa4c0b556 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -56,6 +56,7 @@ config IA64
 	select HAVE_ARCH_AUDITSYSCALL
 	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
+	select HAVE_COPY_THREAD_TLS
 	select NUMA if !FLATMEM
 	default y
 	help
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 2ac926331500..2b846bc52483 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -110,21 +110,18 @@ GLOBAL_ENTRY(sys_clone2)
 	 * Allocate 8 input registers since ptrace() may clobber them
 	 */
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
-	alloc r16=ar.pfs,8,2,6,0
+	alloc r2=ar.pfs,8,2,6,0
 	DO_SAVE_SWITCH_STACK
-	adds r2=PT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
 	mov loc0=rp
-	mov loc1=r16				// save ar.pfs across do_fork
+	mov loc1=r2				// save ar.pfs across ia64_clone
 	.body
+	mov out0=in0
 	mov out1=in1
 	mov out2=in2
-	tbit.nz p6,p0=in0,CLONE_SETTLS_BIT
-	mov out3=in3	// parent_tidptr: valid only w/CLONE_PARENT_SETTID
-	;;
-(p6)	st8 [r2]=in5				// store TLS in r16 for copy_thread()
-	mov out4=in4	// child_tidptr:  valid only w/CLONE_CHILD_SETTID or CLONE_CHILD_CLEARTID
-	mov out0=in0				// out0 = clone_flags
-	br.call.sptk.many rp=do_fork
+	mov out3=in3
+	mov out4=in4
+	mov out5=in5
+	br.call.sptk.many rp=ia64_clone
 .ret1:	.restore sp
 	adds sp=IA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov ar.pfs=loc1
@@ -141,21 +138,18 @@ GLOBAL_ENTRY(sys_clone)
 	 * Allocate 8 input registers since ptrace() may clobber them
 	 */
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
-	alloc r16=ar.pfs,8,2,6,0
+	alloc r2=ar.pfs,8,2,6,0
 	DO_SAVE_SWITCH_STACK
-	adds r2=PT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
 	mov loc0=rp
-	mov loc1=r16				// save ar.pfs across do_fork
+	mov loc1=r2				// save ar.pfs across ia64_clone
 	.body
+	mov out0=in0
 	mov out1=in1
 	mov out2				// stacksize (compensates for 16-byte scratch area)
-	tbit.nz p6,p0=in0,CLONE_SETTLS_BIT
-	mov out3=in2	// parent_tidptr: valid only w/CLONE_PARENT_SETTID
-	;;
-(p6)	st8 [r2]=in4				// store TLS in r13 (tp)
-	mov out4=in3	// child_tidptr:  valid only w/CLONE_CHILD_SETTID or CLONE_CHILD_CLEARTID
-	mov out0=in0				// out0 = clone_flags
-	br.call.sptk.many rp=do_fork
+	mov out3=in3
+	mov out4=in4
+	mov out5=in5
+	br.call.sptk.many rp=ia64_clone
 .ret2:	.restore sp
 	adds sp=IA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov ar.pfs=loc1
@@ -590,7 +584,7 @@ GLOBAL_ENTRY(ia64_ret_from_clone)
 	nop.i 0
 	/*
 	 * We need to call schedule_tail() to complete the scheduling process.
-	 * Called by ia64_switch_to() after do_fork()->copy_thread().  r8 contains the
+	 * Called by ia64_switch_to() after ia64_clone()->copy_thread().  r8 contains the
 	 * address of the previously executing task.
 	 */
 	br.call.sptk.many rp=ia64_invoke_schedule_tail
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 10cb9382ab76..76e77f10536c 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -309,8 +309,8 @@ ia64_load_extra (struct task_struct *task)
  *
  *	<clone syscall>	        <some kernel call frames>
  *	sys_clone		   :
- *	do_fork			do_fork
- *	copy_thread		copy_thread
+ *	_do_fork		_do_fork
+ *	copy_thread_tls		copy_thread_tls
  *
  * This means that the stack layout is as follows:
  *
@@ -332,9 +332,9 @@ ia64_load_extra (struct task_struct *task)
  * so there is nothing to worry about.
  */
 int
-copy_thread(unsigned long clone_flags,
-	     unsigned long user_stack_base, unsigned long user_stack_size,
-	     struct task_struct *p)
+copy_thread_tls(unsigned long clone_flags, unsigned long user_stack_base,
+		    unsigned long user_stack_size, struct task_struct *p,
+		    unsigned long tls)
 {
 	extern char ia64_ret_from_clone;
 	struct switch_stack *child_stack, *stack;
@@ -415,7 +415,7 @@ copy_thread(unsigned long clone_flags,
 	rbs_size = stack->ar_bspstore - rbs;
 	memcpy((void *) child_rbs, (void *) rbs, rbs_size);
 	if (clone_flags & CLONE_SETTLS)
-		child_ptregs->r13 = regs->r16;	/* see sys_clone2() in entry.S */
+		child_ptregs->r13 = tls;
 	if (user_stack_base) {
 		child_ptregs->r12 = user_stack_base + user_stack_size - 16;
 		child_ptregs->ar_bspstore = user_stack_base;
@@ -440,6 +440,27 @@ copy_thread(unsigned long clone_flags,
 	return retval;
 }
 
+asmlinkage long ia64_clone(unsigned long clone_flags, unsigned long stack_start,
+			   unsigned long stack_size, int __user *parent_tidptr,
+			   int __user *child_tidptr, unsigned long tls)
+{
+	struct kernel_clone_args args = {
+		.flags		= (lower_32_bits(clone_flags) & ~CSIGNAL),
+		.pidfd		= parent_tidptr,
+		.child_tid	= child_tidptr,
+		.parent_tid	= parent_tidptr,
+		.exit_signal	= (lower_32_bits(clone_flags) & CSIGNAL),
+		.stack		= stack_start,
+		.stack_size	= stack_size,
+		.tls		= tls,
+	};
+
+	if (!legacy_clone_args_valid(&args))
+		return -EINVAL;
+
+	return _do_fork(&args);
+}
+
 static void
 do_copy_task_regs (struct task_struct *task, struct unw_frame_info *info, void *arg)
 {

base-commit: 2ef96a5bb12be62ef75b5828c0aab838ebb29cb8
-- 
2.26.2

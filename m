From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Jan 2003 06:36:32 +0000
Subject: [Linux-ia64] fsyscall-support
Message-Id: <marc-linux-ia64-105590709805677@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Attached below is a patch relative to 2.5.52+ia64 patch which adds
support for light-weight system calls.  I'm happy to say that
everything seems to have fallen into place _very_ nicely.  In fact,
the patch below is actually rather small: most of its size comes from
adding the fsyscall-table and some renaming (pUser/pKern got renamed
to pUStk/pKStk to reflect their new meaning).  Ah, the other
relatively sizeable piece is--ta ta---documentation: see
Documentation/ia64/fsys.txt for details (this file needs to be
improved; suggestions welcome).

I believe the design and the implementation of the fsyscall support is
safe and has no outstanding holes (well, at least none that I know
of).  For example, not only do fsyscalls have full system call
semantics, you can also single-step across them or taken-branch-trap
across them (extra credit for those who figure out how this works just
by looking at the code ;-).

And yet despite this, fsyscalls really _can_ be very fast: a
NULL-system call (e.g., getpid()) can run in as little as 35 cycles.
I find that pretty amazing---hats off to the ia64 & McKinley
architects!

Given this low (minimal) overhead, this ought to pretty much obviate
any desire for vsyscalls (pseudo-syscalls which run entirely in
user-level, e.g., by accessing a kernel-page that's mapped read-only).

To avoid confusion, I should point out three things:

 - The only fsyscall that's currently implemented in a light-weight
   fashion is getpid().  Of course, nobody really cares about the
   speed of getpid(), but it's easy to do and lets us establish the
   lower-bound for fsyscall overheads.  More interesting candidates
   for light-weight implementation would be gettimeofday(),
   sigprocmask(), and sigreturn(), for example.

 - In the absence of a light-weight system call handler, an fsyscall
   with fall back to a full-blown system call.  At the moment, the
   fall back path uses a "break 0x100000" for this, which is obviously
   silly and causes non-light-weight system calls to actually run
   slightly slower than before.  Next step is to streamline this path
   (e.g., avoid break 0x100000, save/restore only minimal set of
   registers).

 - Only limited testing has been done so far.  I'm working on putting
   together a system that's entirely built on top of fsyscalls, but
   the glibc pieces are not quite there yet.

Oh, I pushed some other changes into the lia64 bk tree before applying
this patch.  I don't think you need those in order to apply this patch
on top of 2.5.52+ia64, but I haven't actually tested it.

Enjoy,

	--david

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.895   -> 1.896 =20
#	include/asm-ia64/asmmacro.h	1.3     -> 1.4   =20
#	arch/ia64/kernel/entry.S	1.28    -> 1.29  =20
#	include/asm-ia64/processor.h	1.29    -> 1.30  =20
#	arch/ia64/kernel/entry.h	1.4     -> 1.5   =20
#	include/asm-ia64/ptrace.h	1.5     -> 1.6   =20
#	arch/ia64/kernel/head.S	1.7     -> 1.8   =20
#	include/asm-ia64/elf.h	1.5     -> 1.6   =20
#	arch/ia64/kernel/gate.S	1.9     -> 1.10  =20
#	arch/ia64/kernel/minstate.h	1.8     -> 1.9   =20
#	arch/ia64/kernel/unaligned.c	1.8     -> 1.9   =20
#	arch/ia64/tools/print_offsets.c	1.10    -> 1.11  =20
#	   arch/ia64/Kconfig	1.11    -> 1.12  =20
#	arch/ia64/kernel/traps.c	1.20    -> 1.21  =20
#	arch/ia64/kernel/Makefile	1.12    -> 1.13  =20
#	               (new)	        -> 1.1     arch/ia64/kernel/fsys.S
#	               (new)	        -> 1.1     Documentation/ia64/fsys.txt
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/01/14	davidm@tiger.hpl.hp.com	1.896
# ia64: Light-weight system call support (aka, "fsyscalls").  This does not=
 (yet)
# 	accelerate normal system calls, but it puts the infrastructure in place
# 	and lets you write fsyscall-handlers to your hearts content.  A null sys=
tem-
# 	call (such as getpid()) can now run in as little as 35 cycles!
# --------------------------------------------
#
diff -Nru a/Documentation/ia64/fsys.txt b/Documentation/ia64/fsys.txt
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/Documentation/ia64/fsys.txt	Tue Jan 14 22:18:08 2003
@@ -0,0 +1,219 @@
+-*-Mode: outline-*-
+
+		Light-weight System Calls for IA-64
+		-----------------------------------
+
+		        Started: 13-Jan-2002
+		    Last update: 14-Jan-2002
+
+	              David Mosberger-Tang
+		      <davidm@hpl.hp.com>
+
+Using the "epc" instruction effectively introduces a new mode of
+execution to the ia64 linux kernel.  We call this mode the
+"fsys-mode".  To recap, the normal states of execution are:
+
+  - kernel mode:
+	Both the register stack and the kernel stack have been
+	switched over to the kernel stack.  The user-level state
+	is saved in a pt-regs structure at the top of the kernel
+	memory stack.
+
+  - user mode:
+	Both the register stack and the kernel stack are in
+	user land.  The user-level state is contained in the
+	CPU registers.
+
+  - bank 0 interruption-handling mode:
+	This is the non-interruptible state in that all
+	interruption-handlers start executing in.  The user-level
+	state remains in the CPU registers and some kernel state may
+	be stored in bank 0 of registers r16-r31.
+
+Fsys-mode has the following special properties:
+
+  - execution is at privilege level 0 (most-privileged)
+
+  - CPU registers may contain a mixture of user-level and kernel-level
+    state (it is the responsibility of the kernel to ensure that no
+    security-sensitive kernel-level state is leaked back to
+    user-level)
+
+  - execution is interruptible and preemptible (an fsys-mode handler
+    can disable interrupts and avoid all other interruption-sources
+    to avoid preemption)
+
+  - neither the memory nor the register stack can be trusted while
+    in fsys-mode (they point to the user-level stacks, which may
+    be invalid)
+
+In summary, fsys-mode is much more similar to running in user-mode
+than it is to running in kernel-mode.  Of course, given that the
+privilege level is at level 0, this means that fsys-mode requires some
+care (see below).
+
+
+* How to tell fsys-mode
+
+Linux operates in fsys-mode when (a) the privilege level is 0 (most
+privileged) and (b) the stacks have NOT been switched to kernel memory
+yet.  For convenience, the header file <asm-ia64/ptrace.h> provides
+three macros:
+
+	user_mode(regs)
+	user_stack(regs)
+	fsys_mode(regs)
+
+The "regs" argument is a pointer to a pt_regs structure.  user_mode()
+returns TRUE if the CPU state pointed to by "regs" was executing in
+user mode (privilege level 3).  user_stack() returns TRUE if the state
+pointed to by "regs" was executing on the user-level stack(s).
+Finally, fsys_mode() returns TRUE if the CPU state pointed to by
+"regs" was executing in fsys-mode.  The fsys_mode() macro corresponds
+exactly to the expression:
+
+	!user_mode(regs) && user_stack(regs)
+
+* How to write an fsyscall handler
+
+The file arch/ia64/kernel/fsys.S contains a table of fsyscall-handlers
+(fsyscall_table).  This table contains one entry for each system call.
+By default, a system call is handled by fsys_fallback_syscall().  This
+routine takes care of entering (full) kernel mode and calling the
+normal Linux system call handler.  For performance-critical system
+calls, it is possible to write a hand-tuned fsyscall_handler.  For
+example, fsys.S contains fsys_getpid(), which is a hand-tuned version
+of the getpid() system call.
+
+The entry and exit-state of an fsyscall handler is as follows:
+
+** Machine state on entry to fsyscall handler:
+
+ - r11	  =3D saved ar.pfs (a user-level value)
+ - r15	  =3D system call number
+ - r16	  =3D "current" task pointer (in normal kernel-mode, this is in r13)
+ - r32-r39 =3D system call arguments
+ - b6	  =3D return address (a user-level value)
+ - ar.pfs =3D previous frame-state (a user-level value)
+ - PSR.be =3D cleared to zero (i.e., little-endian byte order is in effect)
+ - all other registers may contain values passed in from user-mode
+
+** Required machine state on exit to fsyscall handler:
+
+ - r11	  =3D saved ar.pfs (as passed into the fsyscall handler)
+ - r15	  =3D system call number (as passed into the fsyscall handler)
+ - r32-r39 =3D system call arguments (as passed into the fsyscall handler)
+ - b6	  =3D return address (as passed into the fsyscall handler)
+ - ar.pfs =3D previous frame-state (as passed into the fsyscall handler)
+
+Fsyscall handlers can execute with very little overhead, but with that
+speed comes a set of restrictions:
+
+ o Fsyscall-handlers MUST check for any pending work in the flags
+   member of the thread-info structure and if any of the
+   TIF_ALLWORK_MASK flags are set, the handler needs to fall back on
+   doing a full system call (by calling fsys_fallback_syscall).
+
+ o Fsyscall-handlers MUST preserve incoming arguments (r32-r39, r11,
+   r15, b6, and ar.pfs) because they will be needed in case of a
+   system call restart.  Of course, all "preserved" registers also
+   must be preserved, in accordance to the normal calling conventions.
+
+ o Fsyscall-handlers MUST check argument registers for containing a
+   NaT value before using them in any way that could trigger a
+   NaT-consumption fault.  If a system call argument is found to
+   contain a NaT value, an fsyscall-handler may return immediately
+   with r8=3DEINVAL, r10=3D-1.
+
+ o Fsyscall-handlers MUST NOT use the "alloc" instruction or perform
+   any other operation that would trigger mandatory RSE
+   (register-stack engine) traffic.
+
+ o Fsyscall-handlers MUST NOT write to any stacked registers because
+   it is not safe to assume that user-level called a handler with the
+   proper number of arguments.
+
+ o Fsyscall-handlers need to be careful when accessing per-CPU variables:
+   unless proper safe-guards are taken (e.g., interruptions are avoided),
+   execution may be pre-empted and resumed on another CPU at any given
+   time.
+
+ o Fsyscall-handlers must be careful not to leak sensitive kernel'
+   information back to user-level.  In particular, before returning to
+   user-level, care needs to be taken to clear any scratch registers
+   that could contain sensitive information (note that the current
+   task pointer is not considered sensitive: it's already exposed
+   through ar.k6).
+
+The above restrictions may seem draconian, but remember that it's
+possible to trade off some of the restrictions by paying a slightly
+higher overhead.  For example, if an fsyscall-handler could benefit
+from the shadow register bank, it could temporarily disable PSR.i and
+PSR.ic, switch to bank 0 (bsw.0) and then use the shadow registers as
+needed.  In other words, following the above rules yields extremely
+fast system call execution (while fully preserving system call
+semantics), but there is also a lot of flexibility in handling more
+complicated cases.
+
+* PSR Handling
+
+The "epc" instruction doesn't change the contents of PSR at all.  This
+is in contrast to a regular interruption, which clears almost all
+bits.  Because of that, some care needs to be taken to ensure things
+work as expected.  The following discussion describes how each PSR bit
+is handled.
+
+PSR.be	Cleared when entering fsys-mode.  A srlz.d instruction is used
+	to ensure the CPU is in little-endian mode before the first
+	load/store instruction is executed.  PSR.be is normally NOT
+	restored upon return from an fsys-mode handler.  In other
+	words, user-level code must not rely on PSR.be being preserved
+	across a system call.
+PSR.up	Unchanged.
+PSR.ac	Unchanged.
+PSR.mfl Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.mfh	Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.ic	Unchanged.  Note: fsys-mode handlers can clear the bit, if needed.
+PSR.i	Unchanged.  Note: fsys-mode handlers can clear the bit, if needed.
+PSR.pk	Unchanged.
+PSR.dt	Unchanged.
+PSR.dfl	Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.dfh	Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.sp	Unchanged.
+PSR.pp	Unchanged.
+PSR.di	Unchanged.
+PSR.si	Unchanged.
+PSR.db	Unchanged.  The kernel prevents user-level from setting a hardware
+	breakpoint that triggers at any privilege level other than 3 (user-mode).
+PSR.lp	Unchanged.
+PSR.tb	Lazy redirect.  If a taken-branch trap occurs while in
+	fsys-mode, the trap-handler modifies the saved machine state
+	such that execution resumes in the gate page at
+	syscall_via_break(), with privilege level 3.  Note: the
+	taken branch would occur on the branch invoking the
+	fsyscall-handler, at which point, by definition, a syscall
+	restart is still safe.  If the system call number is invalid,
+	the fsys-mode handler will return directly to user-level.  This
+	return will trigger a taken-branch trap, but since the trap is
+	taken _after_ restoring the privilege level, the CPU has already
+	left fsys-mode, so no special treatment is needed.
+PSR.rt	Unchanged.
+PSR.cpl	Cleared to 0.
+PSR.is	Unchanged (guaranteed to be 0 on entry to the gate page).
+PSR.mc	Unchanged.
+PSR.it	Unchanged (guaranteed to be 1).
+PSR.id	Unchanged.  Note: the ia64 linux kernel never sets this bit.
+PSR.da	Unchanged.  Note: the ia64 linux kernel never sets this bit.
+PSR.dd	Unchanged.  Note: the ia64 linux kernel never sets this bit.
+PSR.ss	Lazy redirect.  If set, "epc" will cause a Single Step Trap to
+	be taken.  The trap handler then modifies the saved machine
+	state such that execution resumes in the gate page at
+	syscall_via_break(), with privilege level 3.
+PSR.ri	Unchanged.
+PSR.ed	Unchanged.  Note: This bit could only have an effect if an fsys-mode
+	handler performed a speculative load that gets NaTted.  If so, this
+	would be the normal & expected behavior, so no special treatment is
+	needed.
+PSR.bn	Unchanged.  Note: fsys-mode handlers may clear the bit, if needed.
+	Doing so requires clearing PSR.i and PSR.ic as well.
+PSR.ia	Unchanged.  Note: the ia64 linux kernel never sets this bit.
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/Kconfig	Tue Jan 14 22:18:08 2003
@@ -806,6 +806,9 @@
=20
 menu "Kernel hacking"
=20
+config FSYS
+	bool "Light-weight system-call support (via epc)"
+
 choice
 	prompt "Physical memory granularity"
 	default IA64_GRANULE_64MB
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/Makefile	Tue Jan 14 22:18:08 2003
@@ -12,6 +12,7 @@
 	 semaphore.o setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
=20
+obj-$(CONFIG_FSYS) +=3D fsys.o
 obj-$(CONFIG_IOSAPIC) +=3D iosapic.o
 obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
 obj-$(CONFIG_EFI_VARS) +=3D efivars.o
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/entry.S	Tue Jan 14 22:18:08 2003
@@ -3,7 +3,7 @@
  *
  * Kernel entry points.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
@@ -22,8 +22,8 @@
 /*
  * Global (preserved) predicate usage on syscall entry/exit path:
  *
- *	pKern:		See entry.h.
- *	pUser:		See entry.h.
+ *	pKStk:		See entry.h.
+ *	pUStk:		See entry.h.
  *	pSys:		See entry.h.
  *	pNonSys:	!pSys
  */
@@ -63,7 +63,7 @@
 	sxt4 r8=3Dr8			// return 64-bit result
 	;;
 	stf.spill [sp]=F0
-(p6)	cmp.ne pKern,pUser=3Dr0,r0	// a successful execve() lands us in user-=
mode...
+(p6)	cmp.ne pKStk,pUStk=3Dr0,r0	// a successful execve() lands us in user-=
mode...
 	mov rp=3Dloc0
 (p6)	mov ar.pfs=3Dr0			// clear ar.pfs on success
 (p7)	br.ret.sptk.many rp
@@ -193,7 +193,7 @@
 	;;
 (p6)	srlz.d
 	ld8 sp=3D[r21]			// load kernel stack pointer of new task
-	mov IA64_KR(CURRENT)=3Dr20	// update "current" application register
+	mov IA64_KR(CURRENT)=3Din0	// update "current" application register
 	mov r8=3Dr13			// return pointer to previously running task
 	mov r13=3Din0			// set "current" pointer
 	;;
@@ -569,11 +569,12 @@
 	// fall through
 GLOBAL_ENTRY(ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
-	// work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to userspace:
-(pUser)	cmp.eq.unc p6,p0=3Dr0,r0			// p6 <- pUser
-(pUser)	rsm psr.i
+	// work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
+	// user- or fsys-mode:
+(pUStk)	cmp.eq.unc p6,p0=3Dr0,r0			// p6 <- pUStk
+(pUStk)	rsm psr.i
 	;;
-(pUser)	adds r17=3DTI_FLAGS+IA64_TASK_SIZE,r13
+(pUStk)	adds r17=3DTI_FLAGS+IA64_TASK_SIZE,r13
 	;;
 .work_processed:
 (p6)	ld4 r18=3D[r17]				// load current_thread_info()->flags
@@ -635,9 +636,9 @@
 	;;
 	srlz.i			// ensure interruption collection is off
 	mov b7=3Dr15
+	bsw.0			// switch back to bank 0 (no stop bit required beforehand...)
 	;;
-	bsw.0			// switch back to bank 0
-	;;
+(pUStk)	mov r18=3DIA64_KR(CURRENT)	// Itanium 2: 12 cycle read latency
 	adds r16=16,r12
 	adds r17$,r12
 	;;
@@ -665,16 +666,21 @@
 	;;
 	ld8.fill r12=3D[r16],16
 	ld8.fill r13=3D[r17],16
+(pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18
 	;;
 	ld8.fill r14=3D[r16]
 	ld8.fill r15=3D[r17]
+(pUStk)	mov r17=3D1
+	;;
+(pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 	;;
 	mov r16=3Dar.bsp		// get existing backing store pointer
 	movl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8)
 	;;
 	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
-(pKern)	br.cond.dpnt skip_rbs_switch
+(pKStk)	br.cond.dpnt skip_rbs_switch
+
 	/*
 	 * Restore user backing store.
 	 *
@@ -788,12 +794,12 @@
 skip_rbs_switch:
 	mov b6=3DrB6
 	mov ar.pfs=3DrARPFS
-(pUser)	mov ar.bspstore=3DrARBSPSTORE
+(pUStk)	mov ar.bspstore=3DrARBSPSTORE
 (p9)	mov cr.ifs=3DrCRIFS
 	mov cr.ipsr=3DrCRIPSR
 	mov cr.iip=3DrCRIIP
 	;;
-(pUser)	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
+(pUStk)	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
 	mov ar.rsc=3DrARRSC
 	mov ar.unat=3DrARUNAT
 	mov pr=3DrARPR,-1
diff -Nru a/arch/ia64/kernel/entry.h b/arch/ia64/kernel/entry.h
--- a/arch/ia64/kernel/entry.h	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/entry.h	Tue Jan 14 22:18:08 2003
@@ -4,8 +4,8 @@
  * Preserved registers that are shared between code in ivt.S and entry.S. =
 Be
  * careful not to step on these!
  */
-#define pKern		p2	/* will leave_kernel return to kernel-mode? */
-#define pUser		p3	/* will leave_kernel return to user-mode? */
+#define pKStk		p2	/* will leave_kernel return to kernel-stacks? */
+#define pUStk		p3	/* will leave_kernel return to user-stacks? */
 #define pSys		p4	/* are we processing a (synchronous) system call? */
 #define pNonSys		p5	/* complement of pSys */
=20
diff -Nru a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/fsys.S	Tue Jan 14 22:18:08 2003
@@ -0,0 +1,291 @@
+/*
+ * This file contains the light-weight system call handlers (fsyscall-hand=
lers).
+ *
+ * Copyright (C) 2003 Hewlett-Packard Co
+ * 	David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/errno.h>
+#include <asm/offsets.h>
+#include <asm/thread_info.h>
+
+ENTRY(fsys_ni_syscall)
+	mov r8=3DENOSYS
+	mov r10=3D-1
+	br.ret.sptk.many b6
+END(fsys_ni_syscall)
+
+ENTRY(fsys_getpid)
+	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
+	;;
+	ld4 r9=3D[r9]
+	add r8=3DIA64_TASK_TGID_OFFSET,r16
+	;;
+	and r9=3DTIF_ALLWORK_MASK,r9
+	ld4 r8=3D[r8]
+	;;
+	cmp.ne p8,p0=3D0,r9
+(p8)	br.spnt.many fsys_fallback_syscall
+	br.ret.sptk.many b6
+END(fsys_getpid)
+
+	.rodata
+	.align 8
+	.globl fsyscall_table
+fsyscall_table:
+	data8 fsys_ni_syscall
+	data8 fsys_fallback_syscall	// exit			// 1025
+	data8 fsys_fallback_syscall	// read
+	data8 fsys_fallback_syscall	// write
+	data8 fsys_fallback_syscall	// open
+	data8 fsys_fallback_syscall	// close
+	data8 fsys_fallback_syscall	// creat		// 1030
+	data8 fsys_fallback_syscall	// link
+	data8 fsys_fallback_syscall	// unlink
+	data8 fsys_fallback_syscall	// execve
+	data8 fsys_fallback_syscall	// chdir
+	data8 fsys_fallback_syscall	// fchdir		// 1035
+	data8 fsys_fallback_syscall	// utimes
+	data8 fsys_fallback_syscall	// mknod
+	data8 fsys_fallback_syscall	// chmod
+	data8 fsys_fallback_syscall	// chown
+	data8 fsys_fallback_syscall	// lseek		// 1040
+	data8 fsys_getpid
+	data8 fsys_fallback_syscall	// getppid
+	data8 fsys_fallback_syscall	// mount
+	data8 fsys_fallback_syscall	// umount
+	data8 fsys_fallback_syscall	// setuid		// 1045
+	data8 fsys_fallback_syscall	// getuid
+	data8 fsys_fallback_syscall	// geteuid
+	data8 fsys_fallback_syscall	// ptrace
+	data8 fsys_fallback_syscall	// access
+	data8 fsys_fallback_syscall	// sync			// 1050
+	data8 fsys_fallback_syscall	// fsync
+	data8 fsys_fallback_syscall	// fdatasync
+	data8 fsys_fallback_syscall	// kill
+	data8 fsys_fallback_syscall	// rename
+	data8 fsys_fallback_syscall	// mkdir		// 1055
+	data8 fsys_fallback_syscall	// rmdir
+	data8 fsys_fallback_syscall	// dup
+	data8 fsys_fallback_syscall	// pipe
+	data8 fsys_fallback_syscall	// times
+	data8 fsys_fallback_syscall	// brk			// 1060
+	data8 fsys_fallback_syscall	// setgid
+	data8 fsys_fallback_syscall	// getgid
+	data8 fsys_fallback_syscall	// getegid
+	data8 fsys_fallback_syscall	// acct
+	data8 fsys_fallback_syscall	// ioctl		// 1065
+	data8 fsys_fallback_syscall	// fcntl
+	data8 fsys_fallback_syscall	// umask
+	data8 fsys_fallback_syscall	// chroot
+	data8 fsys_fallback_syscall	// ustat
+	data8 fsys_fallback_syscall	// dup2			// 1070
+	data8 fsys_fallback_syscall	// setreuid
+	data8 fsys_fallback_syscall	// setregid
+	data8 fsys_fallback_syscall	// getresuid
+	data8 fsys_fallback_syscall	// setresuid
+	data8 fsys_fallback_syscall	// getresgid		// 1075
+	data8 fsys_fallback_syscall	// setresgid
+	data8 fsys_fallback_syscall	// getgroups
+	data8 fsys_fallback_syscall	// setgroups
+	data8 fsys_fallback_syscall	// getpgid
+	data8 fsys_fallback_syscall	// setpgid		// 1080
+	data8 fsys_fallback_syscall	// setsid
+	data8 fsys_fallback_syscall	// getsid
+	data8 fsys_fallback_syscall	// sethostname
+	data8 fsys_fallback_syscall	// setrlimit
+	data8 fsys_fallback_syscall	// getrlimit		// 1085
+	data8 fsys_fallback_syscall	// getrusage
+	data8 fsys_fallback_syscall	// gettimeofday
+	data8 fsys_fallback_syscall	// settimeofday
+	data8 fsys_fallback_syscall	// select
+	data8 fsys_fallback_syscall	// poll			// 1090
+	data8 fsys_fallback_syscall	// symlink
+	data8 fsys_fallback_syscall	// readlink
+	data8 fsys_fallback_syscall	// uselib
+	data8 fsys_fallback_syscall	// swapon
+	data8 fsys_fallback_syscall	// swapoff		// 1095
+	data8 fsys_fallback_syscall	// reboot
+	data8 fsys_fallback_syscall	// truncate
+	data8 fsys_fallback_syscall	// ftruncate
+	data8 fsys_fallback_syscall	// fchmod
+	data8 fsys_fallback_syscall	// fchown		// 1100
+	data8 fsys_fallback_syscall	// getpriority
+	data8 fsys_fallback_syscall	// setpriority
+	data8 fsys_fallback_syscall	// statfs
+	data8 fsys_fallback_syscall	// fstatfs
+	data8 fsys_fallback_syscall	// gettid		// 1105
+	data8 fsys_fallback_syscall	// semget
+	data8 fsys_fallback_syscall	// semop
+	data8 fsys_fallback_syscall	// semctl
+	data8 fsys_fallback_syscall	// msgget
+	data8 fsys_fallback_syscall	// msgsnd		// 1110
+	data8 fsys_fallback_syscall	// msgrcv
+	data8 fsys_fallback_syscall	// msgctl
+	data8 fsys_fallback_syscall	// shmget
+	data8 fsys_fallback_syscall	// shmat
+	data8 fsys_fallback_syscall	// shmdt		// 1115
+	data8 fsys_fallback_syscall	// shmctl
+	data8 fsys_fallback_syscall	// syslog
+	data8 fsys_fallback_syscall	// setitimer
+	data8 fsys_fallback_syscall	// getitimer
+	data8 fsys_fallback_syscall		 		// 1120
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// vhangup
+	data8 fsys_fallback_syscall	// lchown
+	data8 fsys_fallback_syscall	// remap_file_pages	// 1125
+	data8 fsys_fallback_syscall	// wait4
+	data8 fsys_fallback_syscall	// sysinfo
+	data8 fsys_fallback_syscall	// clone
+	data8 fsys_fallback_syscall	// setdomainname
+	data8 fsys_fallback_syscall	// newuname		// 1130
+	data8 fsys_fallback_syscall	// adjtimex
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// init_module
+	data8 fsys_fallback_syscall	// delete_module
+	data8 fsys_fallback_syscall				// 1135
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// quotactl
+	data8 fsys_fallback_syscall	// bdflush
+	data8 fsys_fallback_syscall	// sysfs
+	data8 fsys_fallback_syscall	// personality		// 1140
+	data8 fsys_fallback_syscall	// afs_syscall
+	data8 fsys_fallback_syscall	// setfsuid
+	data8 fsys_fallback_syscall	// setfsgid
+	data8 fsys_fallback_syscall	// getdents
+	data8 fsys_fallback_syscall	// flock		// 1145
+	data8 fsys_fallback_syscall	// readv
+	data8 fsys_fallback_syscall	// writev
+	data8 fsys_fallback_syscall	// pread64
+	data8 fsys_fallback_syscall	// pwrite64
+	data8 fsys_fallback_syscall	// sysctl		// 1150
+	data8 fsys_fallback_syscall	// mmap
+	data8 fsys_fallback_syscall	// munmap
+	data8 fsys_fallback_syscall	// mlock
+	data8 fsys_fallback_syscall	// mlockall
+	data8 fsys_fallback_syscall	// mprotect		// 1155
+	data8 fsys_fallback_syscall	// mremap
+	data8 fsys_fallback_syscall	// msync
+	data8 fsys_fallback_syscall	// munlock
+	data8 fsys_fallback_syscall	// munlockall
+	data8 fsys_fallback_syscall	// sched_getparam	// 1160
+	data8 fsys_fallback_syscall	// sched_setparam
+	data8 fsys_fallback_syscall	// sched_getscheduler
+	data8 fsys_fallback_syscall	// sched_setscheduler
+	data8 fsys_fallback_syscall	// sched_yield
+	data8 fsys_fallback_syscall	// sched_get_priority_max	// 1165
+	data8 fsys_fallback_syscall	// sched_get_priority_min
+	data8 fsys_fallback_syscall	// sched_rr_get_interval
+	data8 fsys_fallback_syscall	// nanosleep
+	data8 fsys_fallback_syscall	// nfsservctl
+	data8 fsys_fallback_syscall	// prctl		// 1170
+	data8 fsys_fallback_syscall	// getpagesize
+	data8 fsys_fallback_syscall	// mmap2
+	data8 fsys_fallback_syscall	// pciconfig_read
+	data8 fsys_fallback_syscall	// pciconfig_write
+	data8 fsys_fallback_syscall	// perfmonctl		// 1175
+	data8 fsys_fallback_syscall	// sigaltstack
+	data8 fsys_fallback_syscall	// rt_sigaction
+	data8 fsys_fallback_syscall	// rt_sigpending
+	data8 fsys_fallback_syscall	// rt_sigprocmask
+	data8 fsys_fallback_syscall	// rt_sigqueueinfo	// 1180
+	data8 fsys_fallback_syscall	// rt_sigreturn
+	data8 fsys_fallback_syscall	// rt_sigsuspend
+	data8 fsys_fallback_syscall	// rt_sigtimedwait
+	data8 fsys_fallback_syscall	// getcwd
+	data8 fsys_fallback_syscall	// capget		// 1185
+	data8 fsys_fallback_syscall	// capset
+	data8 fsys_fallback_syscall	// sendfile
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// socket		// 1190
+	data8 fsys_fallback_syscall	// bind
+	data8 fsys_fallback_syscall	// connect
+	data8 fsys_fallback_syscall	// listen
+	data8 fsys_fallback_syscall	// accept
+	data8 fsys_fallback_syscall	// getsockname		// 1195
+	data8 fsys_fallback_syscall	// getpeername
+	data8 fsys_fallback_syscall	// socketpair
+	data8 fsys_fallback_syscall	// send
+	data8 fsys_fallback_syscall	// sendto
+	data8 fsys_fallback_syscall	// recv			// 1200
+	data8 fsys_fallback_syscall	// recvfrom
+	data8 fsys_fallback_syscall	// shutdown
+	data8 fsys_fallback_syscall	// setsockopt
+	data8 fsys_fallback_syscall	// getsockopt
+	data8 fsys_fallback_syscall	// sendmsg		// 1205
+	data8 fsys_fallback_syscall	// recvmsg
+	data8 fsys_fallback_syscall	// pivot_root
+	data8 fsys_fallback_syscall	// mincore
+	data8 fsys_fallback_syscall	// madvise
+	data8 fsys_fallback_syscall	// newstat		// 1210
+	data8 fsys_fallback_syscall	// newlstat
+	data8 fsys_fallback_syscall	// newfstat
+	data8 fsys_fallback_syscall	// clone2
+	data8 fsys_fallback_syscall	// getdents64
+	data8 fsys_fallback_syscall	// getunwind		// 1215
+	data8 fsys_fallback_syscall	// readahead
+	data8 fsys_fallback_syscall	// setxattr
+	data8 fsys_fallback_syscall	// lsetxattr
+	data8 fsys_fallback_syscall	// fsetxattr
+	data8 fsys_fallback_syscall	// getxattr		// 1220
+	data8 fsys_fallback_syscall	// lgetxattr
+	data8 fsys_fallback_syscall	// fgetxattr
+	data8 fsys_fallback_syscall	// listxattr
+	data8 fsys_fallback_syscall	// llistxattr
+	data8 fsys_fallback_syscall	// flistxattr		// 1225
+	data8 fsys_fallback_syscall	// removexattr
+	data8 fsys_fallback_syscall	// lremovexattr
+	data8 fsys_fallback_syscall	// fremovexattr
+	data8 fsys_fallback_syscall	// tkill
+	data8 fsys_fallback_syscall	// futex		// 1230
+	data8 fsys_fallback_syscall	// sched_setaffinity
+	data8 fsys_fallback_syscall	// sched_getaffinity
+	data8 fsys_fallback_syscall	// set_tid_address
+	data8 fsys_fallback_syscall	// alloc_hugepages
+	data8 fsys_fallback_syscall	// free_hugepages	// 1235
+	data8 fsys_fallback_syscall	// exit_group
+	data8 fsys_fallback_syscall	// lookup_dcookie
+	data8 fsys_fallback_syscall	// io_setup
+	data8 fsys_fallback_syscall	// io_destroy
+	data8 fsys_fallback_syscall	// io_getevents		// 1240
+	data8 fsys_fallback_syscall	// io_submit
+	data8 fsys_fallback_syscall	// io_cancel
+	data8 fsys_fallback_syscall	// epoll_create
+	data8 fsys_fallback_syscall	// epoll_ctl
+	data8 fsys_fallback_syscall	// epoll_wait		// 1245
+	data8 fsys_fallback_syscall	// restart_syscall
+	data8 fsys_fallback_syscall	// semtimedop
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1250
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1255
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1260
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1265
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1270
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1275
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
diff -Nru a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
--- a/arch/ia64/kernel/gate.S	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/gate.S	Tue Jan 14 22:18:08 2003
@@ -2,7 +2,7 @@
  * This file contains the code that gets mapped at the upper end of each t=
ask's text
  * region.  For now, it contains the signal trampoline code only.
  *
- * Copyright (C) 1999-2002 Hewlett-Packard Co
+ * Copyright (C) 1999-2003 Hewlett-Packard Co
  * 	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
@@ -14,6 +14,85 @@
 #include <asm/page.h>
=20
 	.section .text.gate, "ax"
+.start_gate:
+
+
+#if CONFIG_FSYS
+
+#include <asm/errno.h>
+
+/*
+ * On entry:
+ *	r11 =3D saved ar.pfs
+ *	r15 =3D system call #
+ *	b0  =3D saved return address
+ *	b6  =3D return address
+ * On exit:
+ *	r11 =3D saved ar.pfs
+ *	r15 =3D system call #
+ *	b0  =3D saved return address
+ *	all other "scratch" registers:	undefined
+ *	all "preserved" registers:	same as on entry
+ */
+GLOBAL_ENTRY(syscall_via_epc)
+	.prologue
+	.altrp b6
+	.body
+{
+	/*
+	 * Note: the kernel cannot assume that the first two instructions in this
+	 * bundle get executed.  The remaining code must be safe even if
+	 * they do not get executed.
+	 */
+	adds r17=3D-1024,r15
+	mov r10=3D0				// default to successful syscall execution
+	epc
+}
+	;;
+	rsm psr.be
+	movl r18=3Dfsyscall_table
+
+	mov r16=3DIA64_KR(CURRENT)
+	mov r19%5
+	;;
+	shladd r18=3Dr17,3,r18
+	cmp.geu p6,p0=3Dr19,r17			// (syscall > 0 && syscall <=3D 1024+255)?
+	;;
+	srlz.d					// ensure little-endian byteorder is in effect
+(p6)	ld8 r18=3D[r18]
+	;;
+(p6)	mov b7=3Dr18
+(p6)	br.sptk.many b7
+
+	mov r10=3D-1
+	mov r8=3DENOSYS
+	br.ret.sptk.many b6
+END(syscall_via_epc)
+
+GLOBAL_ENTRY(syscall_via_break)
+	.prologue
+	.altrp b6
+	.body
+	break 0x100000
+	br.ret.sptk.many b6
+END(syscall_via_break)
+
+GLOBAL_ENTRY(fsys_fallback_syscall)
+	/*
+	 * It would be better/fsyser to do the SAVE_MIN magic directly here, but =
for now
+	 * we simply fall back on doing a system-call via break.  Good enough
+	 * to get started.  (Note: we have to do this through the gate page again=
, since
+	 * the br.ret will switch us back to user-level privilege.)
+	 *
+	 * XXX Move this back to fsys.S after changing it over to avoid break 0x1=
00000.
+	 */
+	movl r2=3D(syscall_via_break - .start_gate) + GATE_ADDR
+	;;
+	mov b7=3Dr2
+	br.ret.sptk.many b7
+END(fsys_fallback_syscall)
+
+#endif /* CONFIG_FSYS */
=20
 #	define ARG0_OFF		(16 + IA64_SIGFRAME_ARG0_OFFSET)
 #	define ARG1_OFF		(16 + IA64_SIGFRAME_ARG1_OFFSET)
diff -Nru a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
--- a/arch/ia64/kernel/head.S	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/head.S	Tue Jan 14 22:18:08 2003
@@ -5,7 +5,7 @@
  * to set up the kernel's global pointer and jump to the kernel
  * entry point.
  *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
@@ -143,17 +143,14 @@
 	movl r2=3Dinit_thread_union
 	cmp.eq isBP,isAP=3Dr0,r0
 #endif
-	;;
-	extr r3=3Dr2,0,61		// r3 =3D phys addr of task struct
 	mov r16=3DKERNEL_TR_PAGE_NUM
 	;;
=20
 	// load the "current" pointer (r13) and ar.k6 with the current task
-	mov r13=3Dr2
-	mov IA64_KR(CURRENT)=3Dr3		// Physical address
-
+	mov IA64_KR(CURRENT)=3Dr2		// virtual address
 	// initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
 	mov IA64_KR(CURRENT_STACK)=3Dr16
+	mov r13=3Dr2
 	/*
 	 * Reserve space at the top of the stack for "struct pt_regs".  Kernel th=
reads
 	 * don't store interesting values in that structure, but the space still =
needs
diff -Nru a/arch/ia64/kernel/minstate.h b/arch/ia64/kernel/minstate.h
--- a/arch/ia64/kernel/minstate.h	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/minstate.h	Tue Jan 14 22:18:08 2003
@@ -30,25 +30,23 @@
  * on interrupts.
  */
 #define MINSTATE_START_SAVE_MIN_VIRT								\
-(pUser)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
-	dep r1=3D-1,r1,61,3;				/* r1 =3D current (virtual) */		\
+(pUStk)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
 	;;											\
-(pUser)	mov.m rARRNAT=3Dar.rnat;									\
-(pUser)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
-(pKern) mov r1=3Dsp;					/* get sp  */				\
-	;;											\
-(pUser) lfetch.fault.excl.nt1 [rKRBS];								\
-(pUser)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
-(pUser)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUStk)	mov.m rARRNAT=3Dar.rnat;									\
+(pUStk)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
+(pKStk) mov r1=3Dsp;					/* get sp  */				\
 	;;											\
-(pUser)	mov ar.bspstore=3DrKRBS;				/* switch to kernel RBS */		\
-(pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r=
12) */	\
+(pUStk) lfetch.fault.excl.nt1 [rKRBS];								\
+(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUStk)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
 	;;											\
-(pUser)	mov r18=3Dar.bsp;										\
-(pUser)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
+(pUStk)	mov ar.bspstore=3DrKRBS;				/* switch to kernel RBS */		\
+(pKStk) addl r1=3D-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r=
12) */	\
+	;;											\
+(pUStk)	mov r18=3Dar.bsp;										\
+(pUStk)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
=20
 #define MINSTATE_END_SAVE_MIN_VIRT								\
-	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			\
 	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
 	;;
=20
@@ -57,21 +55,21 @@
  * go virtual and dont want to destroy the iip or ipsr.
  */
 #define MINSTATE_START_SAVE_MIN_PHYS								\
-(pKern) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
-(pUser)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
-(pUser)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register back=
ing store */	\
-	;;											\
-(pUser)	mov rARRNAT=3Dar.rnat;									\
-(pKern) dep r1=3D0,sp,61,3;				/* compute physical addr of sp	*/	\
-(pUser)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
-(pUser)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
-(pUser)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS=
 */\
+(pKStk) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
+(pUStk)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
+(pUStk)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register back=
ing store */	\
+	;;											\
+(pUStk)	mov rARRNAT=3Dar.rnat;									\
+(pKStk) dep r1=3D0,sp,61,3;				/* compute physical addr of sp	*/	\
+(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUStk)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
+(pUStk)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS=
 */\
 	;;											\
-(pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		\
-(pUser)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			\
+(pKStk) addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		\
+(pUStk)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			\
 	;;											\
-(pUser)	mov r18=3Dar.bsp;										\
-(pUser)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
+(pUStk)	mov r18=3Dar.bsp;										\
+(pUStk)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
=20
 #define MINSTATE_END_SAVE_MIN_PHYS								\
 	or r12=3Dr12,r14;		/* make sp a kernel virtual address */				\
@@ -79,11 +77,13 @@
 	;;
=20
 #ifdef MINSTATE_VIRT
+# define MINSTATE_GET_CURRENT(reg)	mov reg=3DIA64_KR(CURRENT)
 # define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_VIRT
 # define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_VIRT
 #endif
=20
 #ifdef MINSTATE_PHYS
+# define MINSTATE_GET_CURRENT(reg)	mov reg=3DIA64_KR(CURRENT);; dep reg=3D=
0,reg,61,3
 # define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_PHYS
 # define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_PHYS
 #endif
@@ -110,23 +110,26 @@
  * we can pass interruption state as arguments to a handler.
  */
 #define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							  \
-	mov rARRSC=3Dar.rsc;									  \
-	mov rARPFS=3Dar.pfs;									  \
-	mov rR1=3Dr1;										  \
-	mov rARUNAT=3Dar.unat;									  \
-	mov rCRIPSR=3Dcr.ipsr;									  \
-	mov rB6=B6;				/* rB6 =3D branch reg 6 */			  \
-	mov rCRIIP=3Dcr.iip;									  \
-	mov r1=3DIA64_KR(CURRENT);		/* r1 =3D current (physical) */			  \
-	COVER;											  \
+	mov rARRSC=3Dar.rsc;		/* M */							  \
+	mov rARUNAT=3Dar.unat;		/* M */							  \
+	mov rR1=3Dr1;			/* A */							  \
+	MINSTATE_GET_CURRENT(r1);	/* M (or M;;I) */					  \
+	mov rCRIPSR=3Dcr.ipsr;		/* M */							  \
+	mov rARPFS=3Dar.pfs;		/* I */							  \
+	mov rCRIIP=3Dcr.iip;		/* M */							  \
+	mov rB6=B6;			/* I */	/* rB6 =3D branch reg 6 */			  \
+	COVER;				/* B;; (or nothing) */					  \
 	;;											  \
-	invala;											  \
-	extr.u r16=3DrCRIPSR,32,2;		/* extract psr.cpl */				  \
+	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r1;						  \
 	;;											  \
-	cmp.eq pKern,pUser=3Dr0,r16;		/* are we in kernel mode already? (psr.cpl=
=3D0) */ \
+	ld1 r17=3D[r16];				/* load current->thread.on_ustack flag */	  \
+	st1 [r16]=3Dr0;				/* clear current->thread.on_ustack flag */	  \
 	/* switch from user to kernel RBS: */							  \
 	;;											  \
+	invala;				/* M */							  \
 	SAVE_IFS;										  \
+	cmp.eq pKStk,pUStk=3Dr0,r17;		/* are we in kernel mode already? (psr.cpl=
=3D0) */ \
+	;;											  \
 	MINSTATE_START_SAVE_MIN									  \
 	add r17=3DL1_CACHE_BYTES,r1			/* really: biggest cache-line size */	  \
 	;;											  \
@@ -138,23 +141,23 @@
 	;;											  \
 	lfetch.fault.excl.nt1 [r17];								  \
 	adds r17=3D8,r1;					/* initialize second base pointer */	  \
-(pKern)	mov r18=3Dr0;		/* make sure r18 isn't NaT */					  \
+(pKStk)	mov r18=3Dr0;		/* make sure r18 isn't NaT */					  \
 	;;											  \
 	st8 [r17]=3DrCRIIP,16;	/* save cr.iip */						  \
 	st8 [r16]=3DrCRIFS,16;	/* save cr.ifs */						  \
-(pUser)	sub r18=3Dr18,rKRBS;	/* r18=3DRSE.ndirty*8 */						  \
+(pUStk)	sub r18=3Dr18,rKRBS;	/* r18=3DRSE.ndirty*8 */						  \
 	;;											  \
 	st8 [r17]=3DrARUNAT,16;	/* save ar.unat */						  \
 	st8 [r16]=3DrARPFS,16;	/* save ar.pfs */						  \
 	shl r18=3Dr18,16;		/* compute ar.rsc to be used for "loadrs" */			  \
 	;;											  \
 	st8 [r17]=3DrARRSC,16;	/* save ar.rsc */						  \
-(pUser)	st8 [r16]=3DrARRNAT,16;	/* save ar.rnat */						  \
-(pKern)	adds r16=16,r16;	/* skip over ar_rnat field */					  \
+(pUStk)	st8 [r16]=3DrARRNAT,16;	/* save ar.rnat */						  \
+(pKStk)	adds r16=16,r16;	/* skip over ar_rnat field */					  \
 	;;			/* avoid RAW on r16 & r17 */					  \
-(pUser)	st8 [r17]=3DrARBSPSTORE,16;	/* save ar.bspstore */					  \
+(pUStk)	st8 [r17]=3DrARBSPSTORE,16;	/* save ar.bspstore */					  \
 	st8 [r16]=3DrARPR,16;	/* save predicates */						  \
-(pKern)	adds r17=16,r17;	/* skip over ar_bspstore field */				  \
+(pKStk)	adds r17=16,r17;	/* skip over ar_bspstore field */				  \
 	;;											  \
 	st8 [r17]=3DrB6,16;	/* save b6 */							  \
 	st8 [r16]=3Dr18,16;	/* save ar.rsc value for "loadrs" */				  \
diff -Nru a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
--- a/arch/ia64/kernel/traps.c	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/traps.c	Tue Jan 14 22:18:08 2003
@@ -524,6 +524,23 @@
 	      case 29: /* Debug */
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
+		if (fsys_mode(regs)) {
+			extern char syscall_via_break[], __start_gate_section[];
+			/*
+			 * Got a trap in fsys-mode: Taken Branch Trap and Single Step trap
+			 * need special handling; Debug trap is not supposed to happen.
+			 */
+			if (unlikely(vector =3D 29)) {
+				die("Got debug trap in fsys-mode---not supposed to happen!",
+				    regs, 0);
+				return;
+			}
+			/* re-do the system call via break 0x100000: */
+			regs->cr_iip =3D GATE_ADDR + (syscall_via_break - __start_gate_section);
+			ia64_psr(regs)->ri =3D 0;
+			ia64_psr(regs)->cpl =3D 3;
+			return;
+		}
 		switch (vector) {
 		      case 29:
 			siginfo.si_code =3D TRAP_HWBKPT;
diff -Nru a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
--- a/arch/ia64/kernel/unaligned.c	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/kernel/unaligned.c	Tue Jan 14 22:18:08 2003
@@ -331,12 +331,8 @@
 		return;
 	}
=20
-	/*
-	 * Avoid using user_mode() here: with "epc", we cannot use the privilege =
level to
-	 * infer whether the interrupt task was running on the kernel backing sto=
re.
-	 */
-	if (regs->r12 >=3D TASK_SIZE) {
-		DPRINT("ignoring kernel write to r%lu; register isn't on the RBS!", r1);
+	if (!user_stack(regs)) {
+		DPRINT("ignoring kernel write to r%lu; register isn't on the kernel RBS!=
", r1);
 		return;
 	}
=20
@@ -406,11 +402,7 @@
 		return;
 	}
=20
-	/*
-	 * Avoid using user_mode() here: with "epc", we cannot use the privilege =
level to
-	 * infer whether the interrupt task was running on the kernel backing sto=
re.
-	 */
-	if (regs->r12 >=3D TASK_SIZE) {
+	if (!user_stack(regs)) {
 		DPRINT("ignoring kernel read of r%lu; register isn't on the RBS!", r1);
 		goto fail;
 	}
diff -Nru a/arch/ia64/tools/print_offsets.c b/arch/ia64/tools/print_offsets=
.c
--- a/arch/ia64/tools/print_offsets.c	Tue Jan 14 22:18:08 2003
+++ b/arch/ia64/tools/print_offsets.c	Tue Jan 14 22:18:08 2003
@@ -1,7 +1,7 @@
 /*
  * Utility to generate asm-ia64/offsets.h.
  *
- * Copyright (C) 1999-2002 Hewlett-Packard Co
+ * Copyright (C) 1999-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Note that this file has dual use: when building the kernel
@@ -53,7 +53,9 @@
     { "UNW_FRAME_INFO_SIZE",		sizeof (struct unw_frame_info) },
     { "", 0 },			/* spacer */
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.=
ksp) },
+    { "IA64_TASK_THREAD_ON_USTACK_OFFSET", offsetof (struct task_struct, t=
hread.on_ustack) },
     { "IA64_TASK_PID_OFFSET",		offsetof (struct task_struct, pid) },
+    { "IA64_TASK_TGID_OFFSET",		offsetof (struct task_struct, tgid) },
     { "IA64_PT_REGS_CR_IPSR_OFFSET",	offsetof (struct pt_regs, cr_ipsr) },
     { "IA64_PT_REGS_CR_IIP_OFFSET",	offsetof (struct pt_regs, cr_iip) },
     { "IA64_PT_REGS_CR_IFS_OFFSET",	offsetof (struct pt_regs, cr_ifs) },
diff -Nru a/include/asm-ia64/asmmacro.h b/include/asm-ia64/asmmacro.h
--- a/include/asm-ia64/asmmacro.h	Tue Jan 14 22:18:08 2003
+++ b/include/asm-ia64/asmmacro.h	Tue Jan 14 22:18:08 2003
@@ -2,12 +2,17 @@
 #define _ASM_IA64_ASMMACRO_H
=20
 /*
- * Copyright (C) 2000-2001 Hewlett-Packard Co
+ * Copyright (C) 2000-2001, 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #define ENTRY(name)				\
 	.align 32;				\
+	.proc name;				\
+name:
+
+#define ENTRY_MIN_ALIGN(name)			\
+	.align 16;				\
 	.proc name;				\
 name:
=20
diff -Nru a/include/asm-ia64/elf.h b/include/asm-ia64/elf.h
--- a/include/asm-ia64/elf.h	Tue Jan 14 22:18:08 2003
+++ b/include/asm-ia64/elf.h	Tue Jan 14 22:18:08 2003
@@ -4,10 +4,12 @@
 /*
  * ELF-specific definitions.
  *
- * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
+ * Copyright (C) 1998-1999, 2002-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
+#include <linux/config.h>
+
 #include <asm/fpu.h>
 #include <asm/page.h>
=20
@@ -88,6 +90,11 @@
    relevant until we have real hardware to play with... */
 #define ELF_PLATFORM	0
=20
+/*
+ * This should go into linux/elf.h...
+ */
+#define AT_SYSINFO	32
+
 #ifdef __KERNEL__
 struct elf64_hdr;
 extern void ia64_set_personality (struct elf64_hdr *elf_ex, int ibcs2_inte=
rpreter);
@@ -99,7 +106,14 @@
 #define ELF_CORE_COPY_TASK_REGS(tsk, elf_gregs) dump_task_regs(tsk, elf_gr=
egs)
 #define ELF_CORE_COPY_FPREGS(tsk, elf_fpregs) dump_task_fpu(tsk, elf_fpreg=
s)
=20
-
+#ifdef CONFIG_FSYS
+#define ARCH_DLINFO					\
+do {							\
+	extern int syscall_via_epc;			\
+	NEW_AUX_ENT(AT_SYSINFO, syscall_via_epc);	\
+} while (0)
 #endif
+
+#endif /* __KERNEL__ */
=20
 #endif /* _ASM_IA64_ELF_H */
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Tue Jan 14 22:18:08 2003
+++ b/include/asm-ia64/processor.h	Tue Jan 14 22:18:08 2003
@@ -2,7 +2,7 @@
 #define _ASM_IA64_PROCESSOR_H
=20
 /*
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
@@ -223,7 +223,10 @@
 struct siginfo;
=20
 struct thread_struct {
-	__u64 flags;			/* various thread flags (see IA64_THREAD_*) */
+	__u32 flags;			/* various thread flags (see IA64_THREAD_*) */
+	/* writing on_ustack is performance-critical, so it's worth spending 8 bi=
ts on it... */
+	__u8 on_ustack;			/* executing on user-stacks? */
+	__u8 pad[3];
 	__u64 ksp;			/* kernel stack pointer */
 	__u64 map_base;			/* base address for get_unmapped_area() */
 	__u64 task_size;		/* limit for task size */
@@ -277,6 +280,7 @@
=20
 #define INIT_THREAD {				\
 	.flags =3D	0,			\
+	.on_ustack =3D	0,			\
 	.ksp =3D		0,			\
 	.map_base =3D	DEFAULT_MAP_BASE,	\
 	.task_size =3D	DEFAULT_TASK_SIZE,	\
diff -Nru a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
--- a/include/asm-ia64/ptrace.h	Tue Jan 14 22:18:08 2003
+++ b/include/asm-ia64/ptrace.h	Tue Jan 14 22:18:08 2003
@@ -218,6 +218,8 @@
 # define ia64_task_regs(t)		(((struct pt_regs *) ((char *) (t) + IA64_STK_=
OFFSET)) - 1)
 # define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)
 # define user_mode(regs)		(((struct ia64_psr *) &(regs)->cr_ipsr)->cpl !=
=3D 0)
+# define user_stack(regs)		(current->thread.on_ustack !=3D 0)
+# define fsys_mode(regs)		(!user_mode(regs) && user_stack(regs))
=20
   struct task_struct;			/* forward decl */
=20


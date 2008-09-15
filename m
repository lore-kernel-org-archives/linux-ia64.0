From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 15 Sep 2008 16:36:51 +0000
Subject: [patch] Allow 8 TIF_ flags for pending work to be done
Message-Id: <1221496611.14678.24.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I know there are currently enough TIF_ flags, but some time ago I
promised to post a patch that extends their very limited number to 8.

The main reason for having special work-to-be-done bits is that they can
be checked by a more efficient CPU instruction. The reason for only
having 7 such bits on IA64 is that the "and" instruction sign-extends
its immediate argument.

Since the assembler code never cares about the high bits, it is possible
to load only the first byte from the thread flags. The 8-bit value is
zero-extended, so the sign extension of the most significant bit in the
"and immediate" instruction does not matter (it gets masked off by the
register content itself). This allows to use 8 TIF_ flags for pending
work to be done.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index 7c60fcd..e30c470 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -95,8 +95,8 @@ extern void tsk_clear_notify_resume(struct task_struct *tsk);
 /*
  * thread information flags
  * - these are process state flags that various assembly files may need to access
- * - pending work-to-be-done flags are in least-significant 16 bits, other flags
- *   in top 16 bits
+ * - pending work-to-be-done flags are in least-significant 8 bits, other flags
+ *   in top 24 bits
  */
 #define TIF_SIGPENDING		0	/* signal pending */
 #define TIF_NEED_RESCHED	1	/* rescheduling necessary */
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 0dd6c14..3bc2119 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -626,7 +626,7 @@ GLOBAL_ENTRY(ia64_ret_from_clone)
 .ret8:
 	adds r2=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
-	ld4 r2=[r2]
+	ld1 r2=[r2]
 	;;
 	mov r8=0
 	and r2=_TIF_SYSCALL_TRACEAUDIT,r2
@@ -732,7 +732,7 @@ __paravirt_work_processed_syscall:
 (pUStk)	mov.m r22=ar.itc			// fetch time at leave
 	adds r18=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
-(p6)	ld4 r31=[r18]				// load current_thread_info()->flags
+(p6)	ld1 r31=[r18]				// r31 = current_thread_info()->flags & 0xff
 	ld8 r19=[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
 	adds r3=PT(AR_BSPSTORE)+16,r12		// deferred
 	;;
@@ -741,7 +741,7 @@ __paravirt_work_processed_syscall:
 	adds r3=PT(AR_BSPSTORE)+16,r12
 	adds r18=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
-(p6)	ld4 r31=[r18]				// load current_thread_info()->flags
+(p6)	ld1 r31=[r18]				// r31 = current_thread_info()->flags & 0xff
 	ld8 r19=[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
 	nop.i 0
 	;;
@@ -896,7 +896,7 @@ GLOBAL_ENTRY(__paravirt_leave_kernel)
 .work_processed_kernel:
 	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
-(p6)	ld4 r31=[r17]				// load current_thread_info()->flags
+(p6)	ld1 r31=[r17]				// r31 = current_thread_info()->flags & 0xff
 	adds r21=PT(PR)+16,r12
 	;;
 
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index c1625c7..d9feb9c 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -66,7 +66,7 @@ ENTRY(fsys_getpid)
 	ld8 r17=[r17]				// r17 = current->group_leader
 	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
 	;;
-	ld4 r9=[r9]
+	ld1 r9=[r9]
 	add r17=IA64_TASK_TGIDLINK_OFFSET,r17
 	;;
 	and r9=TIF_ALLWORK_MASK,r9
@@ -100,7 +100,7 @@ ENTRY(fsys_getppid)
 	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
 	;;
 
-	ld4 r9=[r9]
+	ld1 r9=[r9]
 	add r17=IA64_TASK_REAL_PARENT_OFFSET,r17 // r17 = &current->group_leader->real_parent
 	;;
 	and r9=TIF_ALLWORK_MASK,r9
@@ -144,7 +144,7 @@ ENTRY(fsys_set_tid_address)
 	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
 	add r17=IA64_TASK_TGIDLINK_OFFSET,r16
 	;;
-	ld4 r9=[r9]
+	ld1 r9=[r9]
 	tnat.z p6,p7=r32		// check argument register for being NaT
 	ld8 r17=[r17]				// r17 = current->pids[PIDTYPE_PID].pid
 	;;
@@ -242,7 +242,7 @@ ENTRY(fsys_gettimeofday)
 (p6)	br.cond.spnt.few .fail_einval
 	movl r20 = fsyscall_gtod_data // load fsyscall gettimeofday data address
 	;;
-	ld4 r2 = [r2]			// process work pending flags
+	ld1 r2 = [r2]			// process work pending flags
 	movl r29 = itc_jitter_data	// itc_jitter
 	add r22 = IA64_GTOD_WALL_TIME_OFFSET,r20	// wall_time
 	add r21 = IA64_CLKSRC_MMIO_OFFSET,r20
@@ -391,7 +391,7 @@ ENTRY(fsys_rt_sigprocmask)
 	add r31=IA64_TASK_SIGHAND_OFFSET,r16
 	;;
 	ld8 r3=[r2]				// read/prefetch current->blocked
-	ld4 r9=[r9]
+	ld1 r9=[r9]
 	tnat.nz.or p6,p0=r35
 
 	cmp.ne.or p6,p0=_NSIG_WORDS*8,r35
@@ -476,14 +476,14 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 (p6)	br.cond.dpnt.many .sig_pending
 	;;
 
-1:	ld4 r17=[r9]				// r17 <- current->thread_info->flags
+1:	ld1 r17=[r9]				// r17 <- current->thread_info->flags & 0xff
 	;;
 	mov ar.ccv=r17
 	and r18=~_TIF_SIGPENDING,r17		// r18 <- r17 & ~(1 << TIF_SIGPENDING)
 	;;
 
 	st8 [r2]=r14				// update current->blocked with new mask
-	cmpxchg4.acq r8=[r9],r18,ar.ccv		// current->thread_info->flags <- r18
+	cmpxchg1.acq r8=[r9],r18,ar.ccv		// current->thread_info->flags <- r18
 	;;
 	cmp.ne p6,p0=r17,r8			// update failed?
 (p6)	br.cond.spnt.few 1b			// yes -> retry
@@ -542,7 +542,7 @@ ENTRY(fsys_getcpu)
 	add r3=TI_CPU+IA64_TASK_SIZE,r16
 	;;
 	ld4 r3=[r3]				// M r3 = thread_info->cpu
-	ld4 r2=[r2]				// M r2 = thread_info->flags
+	ld1 r2=[r2]				// M r2 = thread_info->flags & 0xff
 (p6)    br.cond.spnt.few .fail_einval		// B
 	;;
 	tnat.nz p7,p0 = r33			// I guard against NaT argument
@@ -677,7 +677,7 @@ GLOBAL_ENTRY(fsys_bubble_down)
 	addl r22=IA64_RBS_OFFSET,r2		// A    compute base of RBS
 	add r3=TI_FLAGS+IA64_TASK_SIZE,r2	// A
 	;;
-	ld4 r3=[r3]				// M0|1 r3 = current_thread_info()->flags
+	ld1 r3=[r3]				// M0|1 r3 = current_thread_info()->flags & 0xff
 	lfetch.fault.excl.nt1 [r22]		// M0|1 prefetch register backing-store
 	nop.i 0
 	;;
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 416a952..4ab0253 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -765,7 +765,7 @@ ENTRY(break_fault)
 	mov r3=NR_syscalls - 1
 	;;
 	ld1.bias r17=[r16]			// M0|1 r17 = current->thread.on_ustack flag
-	ld4 r9=[r9]				// M0|1 r9 = current_thread_info()->flags
+	ld1 r9=[r9]				// M0|1 r9 = current_thread_info()->flags
 	extr.u r8=r29,41,2			// I0   extract ei field from cr.ipsr
 
 	shladd r30=r15,3,r30			// A    r30 = sys_call_table + 8*(syscall-1024)
@@ -1775,7 +1775,7 @@ ENTRY(dispatch_to_ia32_handler)
 	movl r16=ia32_syscall_table
 	;;
 (p6)	shladd r16=r8,3,r16	// force ni_syscall if not valid syscall number
-	ld4 r2=[r2]		// r2 = current_thread_info()->flags
+	ld1 r2=[r2]		// r2 = current_thread_info()->flags
 	;;
 	ld8 r16=[r16]
 	and r2=_TIF_SYSCALL_TRACEAUDIT,r2	// mask trace or audit



From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 21 Jun 2004 23:57:43 +0000
Subject: Re: Fw: [Bugme-new] [Bug 2885] New: realtime process can't preempt low priority process in kernel
Message-Id: <16599.30199.893980.862770@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040614002931.00b846a4.akpm@osdl.org>
In-Reply-To: <20040614002931.00b846a4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Here's a patch to fix OSDL BugMe 2885: IA64 preemption support.

There is one small change in semantics: when returning from a
preemption, the preemption flag will *not* be rechecked.  Otherwise, I
found that it was easy to get into a livelock situation where no
forward progress was made.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/22 09:08:06+10:00 peterc@gelato.unsw.edu.au 
#   [IA64] [Bug 2885]New: realtime process can't preempt low priority process in kernel 
#   
#   Rearranged code to make it work. There were two problems:
#   
#   	1.  The preempt flag was being tested only if code was 
#               leaving for user space
#   	   (the logic should be: test for RESCHEDULE if we're 
#   	    switching to a kernel thread, test everything
#               if switching to a user thread)
#       
#           2.  The check of the user space flags was being repeated 
#               even if the work had been done.
#   
#    
# 
# arch/ia64/kernel/entry.S
#   2004/06/22 09:07:57+10:00 peterc@gelato.unsw.edu.au +20 -7
#   [IA64] [Bug 2885]New: realtime process can't preempt low priority process in kernel 
#   
#   Rearranged code to make it work. There were two problems:
#   
#   	1.  The preempt flag was being tested only if code was 
#               leaving for user space
#   	   (the logic should be: test for RESCHEDULE if we're 
#   	    switching to a kernel thread, test everything
#               if switching to a user thread)
#       
#           2.  The check of the user space flags was being repeated 
#               even if the work had been done.
#   
#    
# 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Tue Jun 22 09:22:03 2004
+++ b/arch/ia64/kernel/entry.S	Tue Jun 22 09:22:03 2004
@@ -662,6 +662,11 @@
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it returns to
 	 * user- or fsys-mode, hence we disable interrupts early on:
+	 *
+	 * p6 means to check the threadinfo_flags for work to do, including
+	 * preemption if we're returning to kernel mode.
+	 * This code is reentered at .work_processed_syscall
+	 * with p6 = 0 so we don't recheck
 	 */
 #ifdef CONFIG_PREEMPT
 	rsm psr.i				// disable interrupts
@@ -669,8 +674,6 @@
 (pUStk)	rsm psr.i
 #endif
 	cmp.eq pLvSys,p0=r0,r0			// pLvSys=1: leave from syscall
-(pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
-.work_processed_syscall:
 #ifdef CONFIG_PREEMPT
 (pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
@@ -678,8 +681,11 @@
 (pKStk) ld4 r21=[r20]			// r21 <- preempt_count
 (pUStk)	mov r21=0			// r21 <- 0
 	;;
-(p6)	cmp.eq.unc p6,p0=r21,r0		// p6 <- p6 && (r21 = 0)
+	cmp.eq.unc p6,p0=r21,r0		// p6 <- pUStk || (preempt_count = 0)
+#else
+(pUStk) cmp.eq.unc p6,p0=r0,r0		// p6 <- pUStk
 #endif /* CONFIG_PREEMPT */
+.work_processed_syscall:
 	adds r16=PT(LOADRS)+16,r12
 	adds r17=PT(AR_BSPSTORE)+16,r12
 	adds r18=TI_FLAGS+IA64_TASK_SIZE,r13
@@ -775,6 +781,11 @@
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it returns to
 	 * user- or fsys-mode, hence we disable interrupts early on:
+	 *
+	 * p6 means to check the threadinfo_flags for work to do, including
+	 * preemption if we're returning to kernel mode.
+	 * This code is reentered at .work_processed_kernel
+	 * with p6 = 0 so we don't recheck
 	 */
 #ifdef CONFIG_PREEMPT
 	rsm psr.i				// disable interrupts
@@ -782,18 +793,20 @@
 (pUStk)	rsm psr.i
 #endif
 	cmp.eq p0,pLvSys=r0,r0			// pLvSys=0: leave from kernel
-(pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
 	;;
-.work_processed_kernel:
 #ifdef CONFIG_PREEMPT
 	adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
 	.pred.rel.mutex pUStk,pKStk
 (pKStk)	ld4 r21=[r20]			// r21 <- preempt_count
-(pUStk)	mov r21=0			// r21 <- 0
+(pUStk)	mov r21=0
 	;;
-(p6)	cmp.eq.unc p6,p0=r21,r0		// p6 <- p6 && (r21 = 0)
+	cmp.eq p6,p0=r21,r0		// p6 <- pUStk || (preempt_count = 0)
+#else
+(pUStk)	cmp.eq.unc p6,p0=r0,r0		// p6 <- pUStk
 #endif /* CONFIG_PREEMPT */
+
+.work_processed_kernel:
 	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
 (p6)	ld4 r31=[r17]				// load current_thread_info()->flags


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

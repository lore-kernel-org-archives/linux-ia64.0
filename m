From: "tip-bot2 for Thomas Gleixner" <tip-bot2@linutronix.de>
Date: Sun, 08 Dec 2019 14:58:33 +0000
Subject: [tip: sched/urgent] sched/rt, ia64: Use CONFIG_PREEMPTION
Message-Id: <157581711385.21853.17716722558979268134.tip-bot2@tip-bot2>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191015191821.11479-10-bigeasy@linutronix.de>
In-Reply-To: <20191015191821.11479-10-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-tip-commits@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Fenghua Yu <fenghua.yu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, x86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

The following commit has been merged into the sched/urgent branch of tip:

Commit-ID:     b9b75e53b2fb040bc74a750fb27bbfa80059b3fe
Gitweb:        https://git.kernel.org/tip/b9b75e53b2fb040bc74a750fb27bbfa80059b3fe
Author:        Thomas Gleixner <tglx@linutronix.de>
AuthorDate:    Tue, 15 Oct 2019 21:17:56 +02:00
Committer:     Ingo Molnar <mingo@kernel.org>
CommitterDate: Sun, 08 Dec 2019 14:37:33 +01:00

sched/rt, ia64: Use CONFIG_PREEMPTION

CONFIG_PREEMPTION is selected by CONFIG_PREEMPT and by CONFIG_PREEMPT_RT.
Both PREEMPT and PREEMPT_RT require the same functionality which today
depends on CONFIG_PREEMPT.

Switch the entry code and kprobes over to use CONFIG_PREEMPTION.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
Link: https://lore.kernel.org/r/20191015191821.11479-10-bigeasy@linutronix.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/ia64/kernel/entry.S   | 12 ++++++------
 arch/ia64/kernel/kprobes.c |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index a9992be..2ac9263 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -670,12 +670,12 @@ GLOBAL_ENTRY(ia64_leave_syscall)
 	 *
 	 * p6 controls whether current_thread_info()->flags needs to be check for
 	 * extra work.  We always check for extra work when returning to user-level.
-	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_count
+	 * With CONFIG_PREEMPTION, we also check for extra work when the preempt_count
 	 * is 0.  After extra work processing has been completed, execution
 	 * resumes at ia64_work_processed_syscall with p6 set to 1 if the extra-work-check
 	 * needs to be redone.
 	 */
-#ifdef CONFIG_PREEMPT
+#ifdef CONFIG_PREEMPTION
 	RSM_PSR_I(p0, r2, r18)			// disable interrupts
 	cmp.eq pLvSys,p0=r0,r0			// pLvSys=1: leave from syscall
 (pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
@@ -685,7 +685,7 @@ GLOBAL_ENTRY(ia64_leave_syscall)
 (pUStk)	mov r21=0			// r21 <- 0
 	;;
 	cmp.eq p6,p0=r21,r0		// p6 <- pUStk || (preempt_count = 0)
-#else /* !CONFIG_PREEMPT */
+#else /* !CONFIG_PREEMPTION */
 	RSM_PSR_I(pUStk, r2, r18)
 	cmp.eq pLvSys,p0=r0,r0		// pLvSys=1: leave from syscall
 (pUStk)	cmp.eq.unc p6,p0=r0,r0		// p6 <- pUStk
@@ -814,12 +814,12 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	 *
 	 * p6 controls whether current_thread_info()->flags needs to be check for
 	 * extra work.  We always check for extra work when returning to user-level.
-	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_count
+	 * With CONFIG_PREEMPTION, we also check for extra work when the preempt_count
 	 * is 0.  After extra work processing has been completed, execution
 	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-check
 	 * needs to be redone.
 	 */
-#ifdef CONFIG_PREEMPT
+#ifdef CONFIG_PREEMPTION
 	RSM_PSR_I(p0, r17, r31)			// disable interrupts
 	cmp.eq p0,pLvSys=r0,r0			// pLvSys=0: leave from kernel
 (pKStk)	adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
@@ -1120,7 +1120,7 @@ skip_rbs_switch:
 
 	/*
 	 * On entry:
-	 *	r20 = &current->thread_info->pre_count (if CONFIG_PREEMPT)
+	 *	r20 = &current->thread_info->pre_count (if CONFIG_PREEMPTION)
 	 *	r31 = current->thread_info->flags
 	 * On exit:
 	 *	p6 = TRUE if work-pending-check needs to be redone
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index b8356ed..a6d6a05 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -841,7 +841,7 @@ static int __kprobes pre_kprobes_handler(struct die_args *args)
 		return 1;
 	}
 
-#if !defined(CONFIG_PREEMPT)
+#if !defined(CONFIG_PREEMPTION)
 	if (p->ainsn.inst_flag = INST_FLAG_BOOSTABLE && !p->post_handler) {
 		/* Boost up -- we can execute copied instructions directly */
 		ia64_psr(regs)->ri = p->ainsn.slot;

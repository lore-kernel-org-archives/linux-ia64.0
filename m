From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 27 Jul 2005 22:07:40 +0000
Subject: Add prefetch switch stack hook in scheduler function
Message-Id: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

I would like to propose adding a prefetch switch stack hook in
the scheduler function.  For architecture like ia64, the switch
stack structure is fairly large (currently 528 bytes).  For context
switch intensive application, we found that significant amount of
cache misses occurs in switch_to() function.  The following patch
adds a hook in the schedule() function to prefetch switch stack
structure as soon as 'next' task is determined.  This allows maximum
overlap in prefetch cache lines for that structure.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.12/include/linux/sched.h.orig	2005-07-27 14:43:49.321986290 -0700
+++ linux-2.6.12/include/linux/sched.h	2005-07-27 14:44:03.390345492 -0700
@@ -622,6 +622,11 @@ extern int groups_search(struct group_in
 #define GROUP_AT(gi, i) \
     ((gi)->blocks[(i)/NGROUPS_PER_BLOCK][(i)%NGROUPS_PER_BLOCK])
 
+#ifdef ARCH_HAS_PREFETCH_SWITCH_STACK
+extern void prefetch_switch_stack(struct task_struct*);
+#else
+#define prefetch_switch_stack(task)	do { } while (0)
+#endif
 
 struct audit_context;		/* See audit.c */
 struct mempolicy;
--- linux-2.6.12/kernel/sched.c.orig	2005-07-27 14:43:49.391322226 -0700
+++ linux-2.6.12/kernel/sched.c	2005-07-27 14:44:03.394251742 -0700
@@ -3044,6 +3044,7 @@ switch_tasks:
 	if (next = rq->idle)
 		schedstat_inc(rq, sched_goidle);
 	prefetch(next);
+	prefetch_switch_stack(next);
 	clear_tsk_need_resched(prev);
 	rcu_qsctr_inc(task_cpu(prev));
 


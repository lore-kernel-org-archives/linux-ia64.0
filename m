From: Nick Piggin <npiggin@suse.de>
Date: Wed, 23 May 2007 03:32:38 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <20070523033238.GA26298@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, sorry not to do a proper threaded reply, but I can't find an mbox
of the relevant message (or know another good way to do it).

Well I don't presume to know the ia64 unwind code, however from the
sounds of it, we _might_ be able to get away with simply blocking the
task from running at the scheduler, during the unwind? Note this
requires we have interrupts disabled and the rq lock held, so it may
not work if the unwinder does anything nontrivial...

Longer term, it seems better to make the unwinder more robust, but
maybe this gives us a fix until then? Just an idea (untested!)

---

Index: linux-2.6/arch/ia64/kernel/process.c
=================================--- linux-2.6.orig/arch/ia64/kernel/process.c
+++ linux-2.6/arch/ia64/kernel/process.c
@@ -760,7 +760,9 @@ unsigned long
 get_wchan (struct task_struct *p)
 {
 	struct unw_frame_info info;
+	unsigned long flags;
 	unsigned long ip;
+	unsigned long ret = 0;
 	int count = 0;
 
 	/*
@@ -771,15 +773,24 @@ get_wchan (struct task_struct *p)
 	 * gracefully if the process wasn't really blocked after all.
 	 * --davidm 99/12/15
 	 */
+	if (!lock_blocked_task(p, &flags))
+		goto out;
+
 	unw_init_from_blocked_task(&info, p);
 	do {
 		if (unw_unwind(&info) < 0)
-			return 0;
+			goto unlock;
 		unw_get_ip(&info, &ip);
-		if (!in_sched_functions(ip))
-			return ip;
+		if (!in_sched_functions(ip)) {
+			ret = ip;
+			goto unlock;
+		}
 	} while (count++ < 16);
-	return 0;
+
+unlock:
+	unlock_blocked_task(p, &flags);
+out:
+	return ret;
 }
 
 void
Index: linux-2.6/include/linux/sched.h
=================================--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1332,6 +1332,8 @@ extern void FASTCALL(wake_up_new_task(st
 #endif
 extern void FASTCALL(sched_fork(struct task_struct * p, int clone_flags));
 extern void FASTCALL(sched_exit(struct task_struct * p));
+extern int lock_blocked_task(struct task_struct *p, unsigned long *flags);
+extern void unlock_blocked_task(struct task_struct *p, unsigned long *flags);
 
 extern int in_group_p(gid_t);
 extern int in_egroup_p(gid_t);
Index: linux-2.6/kernel/sched.c
=================================--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -1177,6 +1177,25 @@ repeat:
 	task_rq_unlock(rq, &flags);
 }
 
+int lock_blocked_task(struct task_struct *p, unsigned long *flags)
+{
+	struct rq *rq;
+
+	rq = task_rq_lock(p, flags);
+	if (p->state = TASK_RUNNING || task_running(rq, p)) {
+		task_rq_unlock(rq, flags);
+		return 0;
+	}
+
+	return 1;
+}
+
+void unlock_blocked_task(struct task_struct *p, unsigned long *flags)
+{
+	task_rq_unlock(task_rq(p), flags);
+}
+
+
 /***
  * kick_process - kick a running thread to enter/exit the kernel
  * @p: the to-be-kicked thread

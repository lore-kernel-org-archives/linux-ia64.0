From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 Jan 2002 01:42:30 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805863@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In case you're still fighting with Ingo's scheduler on 2.4.xx, you
might want to try the attached patch.  It's a gross hack to work
around a race condition in set_cpus_allowed().  Without this hack, the
kernel would almost always die as soon as it tried to migrate
ksoftirqd_CPU1 from CPU 0 to CPU 1.  With the patch, it boots up to
the point where the serial line driver gets initialized, which is
progress, I suppose.

The fundamental problem is that current set_cpus_allowed() lets the
same task run on two CPUs for a brief period of time.  This violates
scheduling assumptions made by the kernel and hence results in race
conditions.

	--david

--- linux-2.5.2/kernel/sched.c	Tue Jan 15 22:10:27 2002
+++ lia64-kdb/kernel/sched.c	Wed Jan 16 17:24:39 2002
@@ -230,7 +230,7 @@
 	spin_unlock_irq(&this_rq()->lock);
 }
 
-static inline void context_switch(task_t *prev, task_t *next)
+static inline void context_switch(task_t *prev, task_t *next, int dont_clear)
 {
 	struct mm_struct *mm = next->mm;
 	struct mm_struct *oldmm = prev->active_mm;
@@ -245,7 +245,8 @@
 		switch_mm(oldmm, mm, next, smp_processor_id());
 
 	if (!prev->mm) {
-		prev->active_mm = NULL;
+		if (!dont_clear)
+			prev->active_mm = NULL;
 		mmdrop(oldmm);
 	}
 
@@ -519,7 +520,7 @@
 		rq->nr_switches++;
 		rq->curr = next;
 		next->cpu = prev->cpu;
-		context_switch(prev, next);
+		context_switch(prev, next, 0);
 		/*
 		 * The runqueue pointer might be from another CPU
 		 * if the new task was last running on a different
@@ -721,7 +722,7 @@
 	this_rq->nr_switches++;
 	this_rq->curr = this_rq->idle;
 	this_rq->idle->need_resched = 1;
-	context_switch(current, this_rq->idle);
+	context_switch(current, this_rq->idle, 1);
 	barrier();
 	spin_unlock_irq(&this_rq()->lock);
 }


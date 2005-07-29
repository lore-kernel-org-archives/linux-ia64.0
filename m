From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 14:13:11 +0000
Subject: [sched, patch] better wake-balancing
Message-Id: <20050729141311.GA4154@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E98DEA.9090606@yahoo.com.au> <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <20050729114822.GA25249@elte.hu>
In-Reply-To: <20050729114822.GA25249@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>


another approach would be the patch below, to do wakeup-balancing only 
if the wakeup CPU or the task CPU is idle.

I've measured half-loaded tbench and unless total wakeup-balancing 
removal it does not degrade with this patch applied, while fully loaded 
tbench and other workloads clearly improve.

Ken, could you give this one a try? (It's against the current scheduler 
queue in -mm, but also applies fine to current Linus trees.)

	Ingo

---

do wakeup-balancing only if the wakeup-CPU or the task-CPU is idle.

this prevents excessive wakeup-balancing while the system is highly
loaded, but helps spread out the workload on partly idle systems.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

 kernel/sched.c |    6 ++++++
 1 files changed, 6 insertions(+)

Index: linux-sched-curr/kernel/sched.c
=================================--- linux-sched-curr.orig/kernel/sched.c
+++ linux-sched-curr/kernel/sched.c
@@ -1252,7 +1252,13 @@ static int try_to_wake_up(task_t *p, uns
 	if (unlikely(task_running(rq, p)))
 		goto out_activate;
 
+	/*
+	 * If neither this CPU, nor the previous CPU the task was
+	 * running on is idle then skip wakeup-balancing:
+	 */
 	new_cpu = cpu;
+	if (!idle_cpu(this_cpu) && !idle_cpu(cpu))
+		goto out_set_cpu;
 
 	schedstat_inc(rq, ttwu_cnt);
 	if (cpu = this_cpu) {

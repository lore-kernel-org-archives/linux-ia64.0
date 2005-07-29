From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 16:21:08 +0000
Subject: [sched, patch] better wake-balancing, #3
Message-Id: <20050729162108.GA10243@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E98DEA.9090606@yahoo.com.au> <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <20050729114822.GA25249@elte.hu> <20050729141311.GA4154@elte.hu> <20050729150207.GA6332@elte.hu>
In-Reply-To: <20050729150207.GA6332@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> there's an even simpler way: only do wakeup-balancing if this_cpu is 
> idle. (tbench results are still OK, and other workloads improved.)

here's an updated patch. It handles one more detail: on SCHED_SMT we 
should check the idleness of siblings too. Benchmark numbers still look 
good.

	Ingo

----
do wakeup-balancing only if the wakeup-CPU (or any of its siblings)
is idle.

this prevents excessive wakeup-balancing while the system is highly
loaded, but helps spread out the workload on partly idle systems.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

 kernel/sched.c |    6 ++++++
 1 files changed, 6 insertions(+)

Index: linux-sched-curr/kernel/sched.c
=================================--- linux-sched-curr.orig/kernel/sched.c
+++ linux-sched-curr/kernel/sched.c
@@ -1253,7 +1253,13 @@ static int try_to_wake_up(task_t *p, uns
 	if (unlikely(task_running(rq, p)))
 		goto out_activate;
 
+	/*
+	 * Only do wakeup-balancing (= potentially migrate the task)
+	 * if this CPU (or any SMT sibling) is idle:
+	 */
 	new_cpu = cpu;
+	if (!idle_cpu(this_cpu) && this_cpu = wake_idle(this_cpu, p))
+		goto out_set_cpu;
 
 	schedstat_inc(rq, ttwu_cnt);
 	if (cpu = this_cpu) {

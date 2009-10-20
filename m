From: Jiri Kosina <jkosina@suse.cz>
Date: Tue, 20 Oct 2009 05:58:22 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org>
In-Reply-To: <4ADD48D1.1040701@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, 20 Oct 2009, Tejun Heo wrote:

> If the structure can be dynamically allocated at all, just using
> percpu_alloc() to allocate the whole thing should solve it with the
> correct numa locality.
> 
> Thanks.

So how about something along the lines below? (completely untested as 
well)



From: Jiri Kosina <jkosina@suse.cz>
Subject: sched: move rq_weight data array out of .percpu

Commit 34d76c41 introduced percpu array update_shares_data, size of which
being proportional to NR_CPUS. Unfortunately this blows up ia64 for large
NR_CPUS configuration, as ia64 allows only 64k for .percpu section.

Fix this by allocating this array dynamically and keep only pointer to it
percpu.
                                                                                                     
Signed-off-by: Jiri Kosina <jkosina@suse.cz>   
--- 
 kernel/sched.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index e886895..071cc66 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -1564,11 +1564,7 @@ static unsigned long cpu_avg_load_per_task(int cpu)
 
 #ifdef CONFIG_FAIR_GROUP_SCHED
 
-struct update_shares_data {
-	unsigned long rq_weight[NR_CPUS];
-};
-
-static DEFINE_PER_CPU(struct update_shares_data, update_shares_data);
+unsigned long *update_shares_data;
 
 static void __set_se_shares(struct sched_entity *se, unsigned long shares);
 
@@ -1578,12 +1574,12 @@ static void __set_se_shares(struct sched_entity *se, unsigned long shares);
 static void update_group_shares_cpu(struct task_group *tg, int cpu,
 				    unsigned long sd_shares,
 				    unsigned long sd_rq_weight,
-				    struct update_shares_data *usd)
+				    unsigned long *usd)
 {
 	unsigned long shares, rq_weight;
 	int boost = 0;
 
-	rq_weight = usd->rq_weight[cpu];
+	rq_weight = usd[cpu];
 	if (!rq_weight) {
 		boost = 1;
 		rq_weight = NICE_0_LOAD;
@@ -1618,7 +1614,7 @@ static void update_group_shares_cpu(struct task_group *tg, int cpu,
 static int tg_shares_up(struct task_group *tg, void *data)
 {
 	unsigned long weight, rq_weight = 0, shares = 0;
-	struct update_shares_data *usd;
+	unsigned long *usd;
 	struct sched_domain *sd = data;
 	unsigned long flags;
 	int i;
@@ -1627,11 +1623,10 @@ static int tg_shares_up(struct task_group *tg, void *data)
 		return 0;
 
 	local_irq_save(flags);
-	usd = &__get_cpu_var(update_shares_data);
 
 	for_each_cpu(i, sched_domain_span(sd)) {
 		weight = tg->cfs_rq[i]->load.weight;
-		usd->rq_weight[i] = weight;
+		usd = *per_cpu_ptr(update_shares_data, i) = weight;
 
 		/*
 		 * If there are currently no tasks on the cpu pretend there
@@ -9407,6 +9402,10 @@ void __init sched_init(void)
 #endif /* CONFIG_USER_SCHED */
 #endif /* CONFIG_GROUP_SCHED */
 
+#ifdef CONFIG_FAIR_GROUP_SCHED
+	update_shares_data = __alloc_percpu(NR_CPUS * sizeof(unsigned long),
+			unsigned long);
+#endif
 	for_each_possible_cpu(i) {
 		struct rq *rq;
 

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

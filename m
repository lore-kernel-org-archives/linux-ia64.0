From: Jiri Kosina <jkosina@suse.cz>
Date: Tue, 20 Oct 2009 04:57:25 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz>
In-Reply-To: <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, 20 Oct 2009, Jiri Kosina wrote:

> > Commit 34d76c41 introduced the update_shares_data percpu, but it ends up
> > causing problems on large ia64 machines. Specifically, ia64 is limited
> > to 64k in percpu vars and with NR_CPUS@96, that ends up being 32k by
> > itself. It ends up causing link errors since that is how ia64 enforces
> > the 64k limit.
> > 
> > I can take a deeper look at finding a workable solution but thought I'd
> > mention it in case you had ideas already.
> 
> I am adding some IA64 CCs, as the failure is solely caused by the ia64 
> percpu implementation/pagefault handler optimization which requires the 
> .percpu section area not be larger than 64k, which blows up with 34d76c41 
> and NR_CPUS high enoufh (due to introduction of percpu array being 
> size-dependent on NR_CPUS).

How about this one? (untested)



From: Jiri Kosina <jkosina@suse.cz>
Subject: sched: move rq_weight data array out of .percpu

Commit 34d76c41 introduced percpu array update_shares_data, size of which 
being proportional to NR_CPUS. Unfortunately this blows up ia64 for large 
NR_CPUS configuration, as ia64 allows only 64k for .percpu section.

Fix this by allocating this array dynamically and keep only pointer to it 
percpu.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
--- 
 kernel/sched.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index e886895..21337da 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -1564,11 +1564,9 @@ static unsigned long cpu_avg_load_per_task(int cpu)
 
 #ifdef CONFIG_FAIR_GROUP_SCHED
 
-struct update_shares_data {
-	unsigned long rq_weight[NR_CPUS];
-};
+unsigned long *update_shares_data;
 
-static DEFINE_PER_CPU(struct update_shares_data, update_shares_data);
+static DEFINE_PER_CPU(unsigned long *, update_shares_data);
 
 static void __set_se_shares(struct sched_entity *se, unsigned long shares);
 
@@ -1578,12 +1576,12 @@ static void __set_se_shares(struct sched_entity *se, unsigned long shares);
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
@@ -1618,7 +1616,7 @@ static void update_group_shares_cpu(struct task_group *tg, int cpu,
 static int tg_shares_up(struct task_group *tg, void *data)
 {
 	unsigned long weight, rq_weight = 0, shares = 0;
-	struct update_shares_data *usd;
+	unsigned long *usd;
 	struct sched_domain *sd = data;
 	unsigned long flags;
 	int i;
@@ -1631,7 +1629,7 @@ static int tg_shares_up(struct task_group *tg, void *data)
 
 	for_each_cpu(i, sched_domain_span(sd)) {
 		weight = tg->cfs_rq[i]->load.weight;
-		usd->rq_weight[i] = weight;
+		usd[i] = weight;
 
 		/*
 		 * If there are currently no tasks on the cpu pretend there
@@ -9420,6 +9418,7 @@ void __init sched_init(void)
 #ifdef CONFIG_FAIR_GROUP_SCHED
 		init_task_group.shares = init_task_group_load;
 		INIT_LIST_HEAD(&rq->leaf_cfs_rq_list);
+		__get_cpu_var(update_shares_data) = kmalloc(NR_CPUS * sizeof(unsigned long));
 #ifdef CONFIG_CGROUP_SCHED
 		/*
 		 * How much cpu bandwidth does init_task_group get?

-- 
Jiri Kosina
SUSE Labs, Novell Inc.


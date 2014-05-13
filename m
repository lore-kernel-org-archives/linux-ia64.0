From: Vincent Guittot <vincent.guittot@linaro.org>
Date: Tue, 13 May 2014 09:11:01 +0000
Subject: sched: fix: initialization of sched_domain_topology for NUMA
Message-Id: <1399972261-25693-1-git-send-email-vincent.guittot@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140513082609.GA2485@laptop.programming.kicks-ass.net>
In-Reply-To: <20140513082609.GA2485@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org, mingo@kernel.org
Cc: jet.chen@intel.com, fengguang.wu@intel.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Vincent Guittot <vincent.guittot@linaro.org>

Jet Chen has reported a kernel panics when booting qemu-system-x86_64 with
kvm64 cpu. A panic occured while building the sched_domain.

In sched_init_numa, we create a new topology table in which both default
levels and numa levels are copied. The last row of the table must have a null
pointer in the mask field.

The current implementation doesn't add this last row in the computation of the
table size. So we add 1 row in the allocation size that will be used as the
last row of the table. The kzalloc will ensure that the mask field is NULL.

Reported-by: Jet Chen <jet.chen@intel.com>
Tested-by: Jet Chen <jet.chen@intel.com>
Signed-off-by: Vincent Guittot <vincent.guittot@linaro.org>
link: https://lkml.org/lkml/2014/5/12/130

---

Hi Peter,

Does this commit message contain enough information ?

Regards,
Vincent

 kernel/sched/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 4ea7b3f..205fa17 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6234,7 +6234,7 @@ static void sched_init_numa(void)
 	/* Compute default topology size */
 	for (i = 0; sched_domain_topology[i].mask; i++);
 
-	tl = kzalloc((i + level) *
+	tl = kzalloc((i + level + 1) *
 			sizeof(struct sched_domain_topology_level), GFP_KERNEL);
 	if (!tl)
 		return;
-- 
1.9.1


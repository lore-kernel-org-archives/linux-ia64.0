From: Vincent Guittot <vincent.guittot@linaro.org>
Date: Mon, 12 May 2014 09:52:04 +0000
Subject: RE: [sched] BUG: unable to handle kernel paging request at 093cd001
Message-Id: <1399888324-2007-1-git-send-email-vincent.guittot@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <53708067.7050700@intel.com>
In-Reply-To: <53708067.7050700@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jet.chen@intel.com
Cc: mingo@kernel.org, fengguang.wu@intel.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Vincent Guittot <vincent.guittot@linaro.org>

Hi,

Does this patch solve your issue ?

A null line is missing at the end of the array for NUMA case.
My test was passed thanks to a null data after the allocated array 

regards,
Vincent
---
 kernel/sched/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 4ea7b3f..941da33 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6232,7 +6232,7 @@ static void sched_init_numa(void)
 	}
 
 	/* Compute default topology size */
-	for (i = 0; sched_domain_topology[i].mask; i++);
+	for (i = 1; sched_domain_topology[i].mask; i++);
 
 	tl = kzalloc((i + level) *
 			sizeof(struct sched_domain_topology_level), GFP_KERNEL);
-- 
1.9.1


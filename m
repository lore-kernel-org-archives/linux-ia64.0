From: Jack Steiner <steiner@sgi.com>
Date: Fri, 23 Jul 2004 01:02:57 +0000
Subject: [PATCH] - Initialize sched domain table
Message-Id: <20040723010257.GA27350@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Here is a trivial patch that is required to boot the latest 2.6.7 tree 
on the SGI 512p system.

	Initial the busy_factor in the sched_domain_init table.
	Otherwise, booting hangs doing excessive load balance
	operations.

	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c
+++ linux/kernel/sched.c
@@ -3922,6 +3922,7 @@ void __init sched_init(void)
 	sched_domain_init.groups = &sched_group_init;
 	sched_domain_init.last_balance = jiffies;
 	sched_domain_init.balance_interval = INT_MAX; /* Don't balance */
+	sched_domain_init.busy_factor = 1;
 
 	memset(&sched_group_init, 0, sizeof(struct sched_group));
 	sched_group_init.cpumask = CPU_MASK_ALL;
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.



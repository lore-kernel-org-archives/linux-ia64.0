From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 15 Jan 2009 06:16:55 +0000
Subject: [PATCH] ia64, xen: compilation fix caused by 79741dd35713ff4f6fd0eafd59fa94e8a4ba922d
Message-Id: <20090115061655.GM1565%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes the following errors caused by
79741dd35713ff4f6fd0eafd59fa94e8a4ba922d which changed
the prototypes of account_steal_time() and account_idle_time().

>   CC      arch/ia64/xen/time.o
> arch/ia64/xen/time.c: In function 'consider_steal_time':
> arch/ia64/xen/time.c:132: warning: passing argument 1 of 'account_steal_time' makes integer from pointer without a cast
> arch/ia64/xen/time.c:132: error: too many arguments to function 'account_steal_time'
> arch/ia64/xen/time.c:133: warning: passing argument 1 of 'account_steal_time' makes integer from pointer without a cast
> arch/ia64/xen/time.c:133: error: too many arguments to function 'account_steal_time'

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/time.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/xen/time.c b/arch/ia64/xen/time.c
index c85d319..fb83326 100644
--- a/arch/ia64/xen/time.c
+++ b/arch/ia64/xen/time.c
@@ -129,8 +129,8 @@ consider_steal_time(unsigned long new_itm)
 		blocked = stolentick;
 
 	if (stolen > 0 || blocked > 0) {
-		account_steal_time(NULL, jiffies_to_cputime(stolen));
-		account_steal_time(idle_task(cpu), jiffies_to_cputime(blocked));
+		account_steal_ticks(stolen);
+		account_idle_ticks(blocked);
 		run_local_timers();
 
 		if (rcu_pending(cpu))
-- 
1.6.0.2

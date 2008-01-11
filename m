From: Daniel Walker <dwalker@mvista.com>
Date: Fri, 11 Jan 2008 04:31:51 +0000
Subject: [PATCH] ia64: sn_hwperf semaphore to mutex
Message-Id: <20080111043151.805226977@mvista.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Really simple mutex style semaphore user. The new API is struct mutex which is
what I've converted it to with this change.

Signed-off-by: Daniel Walker <dwalker@mvista.com>
 
---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: linux-2.6.23/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux-2.6.23.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ linux-2.6.23/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -33,6 +33,7 @@
 #include <linux/smp_lock.h>
 #include <linux/nodemask.h>
 #include <linux/smp.h>
+#include <linux/mutex.h>
 
 #include <asm/processor.h>
 #include <asm/topology.h>
@@ -50,7 +51,7 @@ static void *sn_hwperf_salheap = NULL;
 static int sn_hwperf_obj_cnt = 0;
 static nasid_t sn_hwperf_master_nasid = INVALID_NASID;
 static int sn_hwperf_init(void);
-static DECLARE_MUTEX(sn_hwperf_init_mutex);
+static DEFINE_MUTEX(sn_hwperf_init_mutex);
 
 #define cnode_possible(n)	((n) < num_cnodes)
 
@@ -884,10 +885,10 @@ static int sn_hwperf_init(void)
 	int e = 0;
 
 	/* single threaded, once-only initialization */
-	down(&sn_hwperf_init_mutex);
+	mutex_lock(&sn_hwperf_init_mutex);
 
 	if (sn_hwperf_salheap) {
-		up(&sn_hwperf_init_mutex);
+		mutex_unlock(&sn_hwperf_init_mutex);
 		return e;
 	}
 
@@ -936,7 +937,7 @@ out:
 		sn_hwperf_salheap = NULL;
 		sn_hwperf_obj_cnt = 0;
 	}
-	up(&sn_hwperf_init_mutex);
+	mutex_unlock(&sn_hwperf_init_mutex);
 	return e;
 }
 
-- 

-- 

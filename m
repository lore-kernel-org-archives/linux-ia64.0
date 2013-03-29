From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 29 Mar 2013 18:02:30 +0000
Subject: [PATCH] [IA64] idle: delete (*idle)()
Message-Id: <5155d7361472244cb0@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Len Brown <len.brown@intel.com>

Commit 3e7fc708eb
	ia64 idle: delete pm_idle
in 3.9-rc1 didn't finish the job, leaving an un-initialized
reference to (*idle)().

Reported-by: Lars-Peter Clausen <lars@metafoo.de>
Signed-off-by: Len Brown <len.brown@intel.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
[Haven't seen a crash from this - but seems like we are
 just being lucky that "idle" is zero so it does get
 initialized before we jump to randomland]

 arch/ia64/kernel/process.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index e34f565..6f7dc8b 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -291,7 +291,6 @@ cpu_idle (void)
 		}
 
 		if (!need_resched()) {
-			void (*idle)(void);
 #ifdef CONFIG_SMP
 			min_xtp();
 #endif
@@ -299,9 +298,7 @@ cpu_idle (void)
 			if (mark_idle)
 				(*mark_idle)(1);
 
-			if (!idle)
-				idle = default_idle;
-			(*idle)();
+			default_idle();
 			if (mark_idle)
 				(*mark_idle)(0);
 #ifdef CONFIG_SMP
-- 
1.8.1.4


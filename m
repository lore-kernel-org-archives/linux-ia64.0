From: Allen Pais <allen.lkml@gmail.com>
Date: Fri, 22 Sep 2017 11:38:02 +0000
Subject: [PATCH 3/3] ia64: salinfo: use setup_timer() helper.
Message-Id: <1506079562-5068-4-git-send-email-allen.lkml@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 arch/ia64/kernel/salinfo.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 63dc9cd..ac31b00 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -623,9 +623,8 @@ salinfo_init(void)
 
 	*sdir++ = salinfo_dir;
 
-	init_timer(&salinfo_timer);
+	setup_timer(&salinfo_timer, &salinfo_timeout, 0UL);
 	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
-	salinfo_timer.function = &salinfo_timeout;
 	add_timer(&salinfo_timer);
 
 	i = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "ia64/salinfo:online",
-- 
2.7.4


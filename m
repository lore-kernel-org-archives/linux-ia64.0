From: Allen Pais <allen.lkml@gmail.com>
Date: Fri, 22 Sep 2017 11:38:01 +0000
Subject: [PATCH 2/3] ia64: mca: use setup_timer() helper.
Message-Id: <1506079562-5068-3-git-send-email-allen.lkml@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 arch/ia64/sn/kernel/mca.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/mca.c b/arch/ia64/sn/kernel/mca.c
index 5b799d4d..5783e92 100644
--- a/arch/ia64/sn/kernel/mca.c
+++ b/arch/ia64/sn/kernel/mca.c
@@ -80,9 +80,8 @@ static void sn_cpei_timer_handler(unsigned long dummy)
 
 void sn_init_cpei_timer(void)
 {
-	init_timer(&sn_cpei_timer);
+	setup_timer(&sn_cpei_timer, sn_cpei_timer_handler, 0UL);
 	sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
-	sn_cpei_timer.function = sn_cpei_timer_handler;
 	add_timer(&sn_cpei_timer);
 }
 
-- 
2.7.4


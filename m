From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sun, 23 May 2010 20:01:52 +0000
Subject: [PATCH 156/199] arch/ia64/sn/kernel/idle.c: Checkpatch cleanup
Message-Id: <1274644930-26600-8-git-send-email-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/sn/kernel/idle.c:15: ERROR: trailing whitespace
arch/ia64/sn/kernel/idle.c:23: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/sn/kernel/idle.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/idle.c b/arch/ia64/sn/kernel/idle.c
index 49d178f..c982a10 100644
--- a/arch/ia64/sn/kernel/idle.c
+++ b/arch/ia64/sn/kernel/idle.c
@@ -12,7 +12,7 @@ void snidle(int state)
 {
 	if (state) {
 		if (pda->idle_flag = 0) {
-			/* 
+			/*
 			 * Turn the activity LED off.
 			 */
 			set_led_bits(0, LED_CPU_ACTIVITY);
@@ -20,7 +20,7 @@ void snidle(int state)
 
 		pda->idle_flag = 1;
 	} else {
-		/* 
+		/*
 		 * Turn the activity LED on.
 		 */
 		set_led_bits(LED_CPU_ACTIVITY, LED_CPU_ACTIVITY);
-- 
1.7.1.251.gf80a2


From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 21 Feb 2009 22:40:27 +0000
Subject: [PATCH] ia64: beyond iosapic_intr_info's arraysize?
Message-Id: <49A082DB.9040708@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

vi arch/ia64/kernel/iosapic.c +142
static struct iosapic_intr_info {
	...
} iosapic_intr_info[NR_IRQS];

So this goes beyond its arraysize, correct?
--------------------------->8-------------8<------------------------------
Don't go beyond iosapic_intr_info's arraysize

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 5cfd3d9..e131250 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -507,7 +507,7 @@ static int iosapic_find_sharable_irq(unsigned long trigger, unsigned long pol)
 	if (trigger = IOSAPIC_EDGE)
 		return -EINVAL;
 
-	for (i = 0; i <= NR_IRQS; i++) {
+	for (i = 0; i < NR_IRQS; i++) {
 		info = &iosapic_intr_info[i];
 		if (info->trigger = trigger && info->polarity = pol &&
 		    (info->dmode = IOSAPIC_FIXED ||

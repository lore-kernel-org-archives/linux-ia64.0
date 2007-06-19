From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:16:54 +0000
Subject: [PATCH take2 7/13]  Check if irq is sharable
Message-Id: <467790F6.9030407@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Need to check if irq is sharable amoung handlers when searching
sharable IOSAPIC irq.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:35.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:38.000000000 +0900
@@ -502,8 +502,9 @@ static int iosapic_find_sharable_irq(uns
 	for (i = 0; i <= NR_IRQS; i++) {
 		info = &iosapic_intr_info[i];
 		if (info->trigger = trigger && info->polarity = pol &&
-		    (info->dmode = IOSAPIC_FIXED || info->dmode =
-		     IOSAPIC_LOWEST_PRIORITY)) {
+		    (info->dmode = IOSAPIC_FIXED ||
+		     info->dmode = IOSAPIC_LOWEST_PRIORITY) &&
+		    can_request_irq(i, IRQF_SHARED)) {
 			if (min_count = -1 || info->count < min_count) {
 				irq = i;
 				min_count = info->count;


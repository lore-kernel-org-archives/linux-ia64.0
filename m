From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:22:14 +0000
Subject: [PATCH take3 7/12] Check if irq is sharable
Message-Id: <469CB476.8040507@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Need to check if irq is sharable amoung handlers when searching
sharable IOSAPIC irq.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

 arch/ia64/kernel/iosapic.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/iosapic.c	2007-07-13 16:49:24.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/iosapic.c	2007-07-13 16:50:02.000000000 +0900
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

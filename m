From: akpm@linux-foundation.org
Date: Fri, 18 Sep 2009 19:48:12 +0000
Subject: [patch 1/1] ia64: use printk_once
Message-Id: <200909181948.n8IJmCOT016578@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Marcin Slusarz <marcin.slusarz@gmail.com>

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/unaligned.c    |    6 ++----
 arch/ia64/sn/kernel/io_common.c |    8 ++------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff -puN arch/ia64/kernel/unaligned.c~ia64-use-printk_once arch/ia64/kernel/unaligned.c
--- a/arch/ia64/kernel/unaligned.c~ia64-use-printk_once
+++ a/arch/ia64/kernel/unaligned.c
@@ -60,7 +60,6 @@ dump (const char *str, void *vp, size_t 
  */
 int no_unaligned_warning;
 int unaligned_dump_stack;
-static int noprint_warning;
 
 /*
  * For M-unit:
@@ -1357,9 +1356,8 @@ ia64_handle_unaligned (unsigned long ifa
 			/* watch for command names containing %s */
 			printk(KERN_WARNING "%s", buf);
 		} else {
-			if (no_unaligned_warning && !noprint_warning) {
-				noprint_warning = 1;
-				printk(KERN_WARNING "%s(%d) encountered an "
+			if (no_unaligned_warning) {
+				printk_once(KERN_WARNING "%s(%d) encountered an "
 				       "unaligned exception which required\n"
 				       "kernel assistance, which degrades "
 				       "the performance of the application.\n"
diff -puN arch/ia64/sn/kernel/io_common.c~ia64-use-printk_once arch/ia64/sn/kernel/io_common.c
--- a/arch/ia64/sn/kernel/io_common.c~ia64-use-printk_once
+++ a/arch/ia64/sn/kernel/io_common.c
@@ -119,7 +119,6 @@ sn_pcidev_info_get(struct pci_dev *dev)
  * Additionally note that the struct sn_flush_device_war also has to be
  * removed from arch/ia64/sn/include/xtalk/hubdev.h
  */
-static u8 war_implemented = 0;
 
 static s64 sn_device_fixup_war(u64 nasid, u64 widget, int device,
 			       struct sn_flush_device_common *common)
@@ -128,11 +127,8 @@ static s64 sn_device_fixup_war(u64 nasid
 	struct sn_flush_device_war *dev_entry;
 	struct ia64_sal_retval isrv = {0,0,0,0};
 
-	if (!war_implemented) {
-		printk(KERN_WARNING "PROM version < 4.50 -- implementing old "
-		       "PROM flush WAR\n");
-		war_implemented = 1;
-	}
+	printk_once(KERN_WARNING
+		"PROM version < 4.50 -- implementing old PROM flush WAR\n");
 
 	war_list = kzalloc(DEV_PER_WIDGET * sizeof(*war_list), GFP_KERNEL);
 	BUG_ON(!war_list);
_

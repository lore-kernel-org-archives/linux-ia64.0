From: Keith Owens <kaos@sgi.com>
Date: Thu, 23 Oct 2003 08:12:19 +0000
Subject: [patch] 2.4.23-pre7-cset-1.1069.1.112-to-1.1104/arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-106689678007421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trivial fixes for correct field type in formats.  prfunc_t does not
include attribute format so gcc does not pick these up automatically.

--- 2.4.23-pre7-cset-1.1069.1.112-to-1.1104/arch/ia64/kernel/mca.c	Mon Oct 20 16:41:21 2003
+++ 2.4.23-pre7-cset-1.1069.1.112-to-1.1104/arch/ia64/kernel/mca.c.new	Thu Oct 23 18:08:59 2003
@@ -1490,7 +1490,7 @@
 void
 ia64_log_rec_header_print (sal_log_record_header_t *lh, prfunc_t prfunc)
 {
-	prfunc("+Err Record ID: %d    SAL Rev: %2x.%02x\n", lh->id,
+	prfunc("+Err Record ID: %ld    SAL Rev: %2x.%02x\n", lh->id,
 			lh->revision.major, lh->revision.minor);
 	prfunc("+Time: %02x/%02x/%02x%02x %02x:%02x:%02x    Severity %d\n",
 			lh->timestamp.slh_month, lh->timestamp.slh_day,
@@ -1655,11 +1655,11 @@
 		prfunc("  Failure: Data Translation Cache");
 	if (info->itr) {
 		prfunc("  Failure: Instruction Translation Register");
-		prfunc(" ,Slot: %d", info->tr_slot);
+		prfunc(" ,Slot: %ld", info->tr_slot);
 	}
 	if (info->dtr) {
 		prfunc("  Failure: Data Translation Register");
-		prfunc(" ,Slot: %d", info->tr_slot);
+		prfunc(" ,Slot: %ld", info->tr_slot);
 	}
 	if (info->mc)
 		prfunc(" ,MC: Corrected");


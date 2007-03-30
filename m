From: Russ Anderson <rja@sgi.com>
Date: Fri, 30 Mar 2007 22:13:18 +0000
Subject: [patch] BTE error timer fix
Message-Id: <200703302213.l2UMDIn336073718@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] BTE error timer fix

The bte recovery_timer was not being set correctly.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/sn/kernel/bte_error.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: test/arch/ia64/sn/kernel/bte_error.c
=================================--- test.orig/arch/ia64/sn/kernel/bte_error.c	2007-03-30 14:46:06.892555673 -0500
+++ test/arch/ia64/sn/kernel/bte_error.c	2007-03-30 17:04:21.934963590 -0500
@@ -78,7 +78,7 @@ int shub1_bte_error_handler(unsigned lon
 		 * There are errors which still need to be cleaned up by
 		 * hubiio_crb_error_handler
 		 */
-		mod_timer(recovery_timer, HZ * 5);
+		mod_timer(recovery_timer, jiffies + (HZ * 5));
 		BTE_PRINTK(("eh:%p:%d Marked Giving up\n", err_nodepda,
 			    smp_processor_id()));
 		return 1;
@@ -95,7 +95,7 @@ int shub1_bte_error_handler(unsigned lon
 			icrbd.ii_icrb0_d_regval  			    REMOTE_HUB_L(nasid, IIO_ICRB_D(i));
 			if (icrbd.d_bteop) {
-				mod_timer(recovery_timer, HZ * 5);
+				mod_timer(recovery_timer, jiffies + (HZ * 5));
 				BTE_PRINTK(("eh:%p:%d Valid %d, Giving up\n",
 					    err_nodepda, smp_processor_id(),
 					    i));
@@ -150,7 +150,7 @@ int shub2_bte_error_handler(unsigned lon
 		status = BTE_LNSTAT_LOAD(bte);
 		if ((status & IBLS_ERROR) || !(status & IBLS_BUSY))
 			continue;
-		mod_timer(recovery_timer, HZ * 5);
+		mod_timer(recovery_timer, jiffies + (HZ * 5));
 		BTE_PRINTK(("eh:%p:%d Marked Giving up\n", err_nodepda,
 			    smp_processor_id()));
 		return 1;
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

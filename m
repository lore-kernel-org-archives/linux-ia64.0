From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 16 Dec 2005 23:19:01 +0000
Subject: [patch] Altix BTE error handling fixes
Message-Id: <200512162319.jBGNJ1QZ026941@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Altix BTE error handling fixes

Altix (shub2) pushes the BTE clean-up into SAL.
This patch correctly interfaces with the now implemented SAL call.
It also fixes a bug when delaying clean-up to allow busy BTEs to 
complete (or error out).

Signed-off-by: Russ Anderson <rja@sgi.com>

------------
 arch/ia64/sn/kernel/bte_error.c |   58 +++++++++++++++++++++++++++++++++-------
 arch/ia64/sn/kernel/huberror.c  |    9 +++---
 include/asm-ia64/sn/sn_sal.h    |    2 -
 3 files changed, 54 insertions(+), 15 deletions(-)

Index: test/include/asm-ia64/sn/sn_sal.h
=================================--- test.orig/include/asm-ia64/sn/sn_sal.h	2005-12-14 12:58:15.270315202 -0600
+++ test/include/asm-ia64/sn/sn_sal.h	2005-12-16 13:33:45.254146655 -0600
@@ -1100,7 +1100,7 @@ ia64_sn_bte_recovery(nasid_t nasid)
 	struct ia64_sal_retval rv;
 
 	rv.status = 0;
-	SAL_CALL_NOLOCK(rv, SN_SAL_BTE_RECOVER, 0, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(rv, SN_SAL_BTE_RECOVER, (u64)nasid, 0, 0, 0, 0, 0, 0);
 	if (rv.status = SALRET_NOT_IMPLEMENTED)
 		return 0;
 	return (int) rv.status;
Index: test/arch/ia64/sn/kernel/bte_error.c
=================================--- test.orig/arch/ia64/sn/kernel/bte_error.c	2005-12-14 12:58:08.035675745 -0600
+++ test/arch/ia64/sn/kernel/bte_error.c	2005-12-16 15:31:18.382816725 -0600
@@ -33,7 +33,7 @@ void bte_error_handler(unsigned long);
  * Wait until all BTE related CRBs are completed
  * and then reset the interfaces.
  */
-void shub1_bte_error_handler(unsigned long _nodepda)
+int shub1_bte_error_handler(unsigned long _nodepda)
 {
 	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
 	struct timer_list *recovery_timer = &err_nodepda->bte_recovery_timer;
@@ -53,7 +53,7 @@ void shub1_bte_error_handler(unsigned lo
 	    (err_nodepda->bte_if[1].bh_error = BTE_SUCCESS)) {
 		BTE_PRINTK(("eh:%p:%d Nothing to do.\n", err_nodepda,
 			    smp_processor_id()));
-		return;
+		return 1;
 	}
 
 	/* Determine information about our hub */
@@ -81,7 +81,7 @@ void shub1_bte_error_handler(unsigned lo
 		mod_timer(recovery_timer, HZ * 5);
 		BTE_PRINTK(("eh:%p:%d Marked Giving up\n", err_nodepda,
 			    smp_processor_id()));
-		return;
+		return 1;
 	}
 	if (icmr.ii_icmr_fld_s.i_crb_vld != 0) {
 
@@ -99,7 +99,7 @@ void shub1_bte_error_handler(unsigned lo
 				BTE_PRINTK(("eh:%p:%d Valid %d, Giving up\n",
 					    err_nodepda, smp_processor_id(),
 					    i));
-				return;
+				return 1;
 			}
 		}
 	}
@@ -124,6 +124,42 @@ void shub1_bte_error_handler(unsigned lo
 	REMOTE_HUB_S(nasid, IIO_IBCR, ibcr.ii_ibcr_regval);
 
 	del_timer(recovery_timer);
+	return 0;
+}
+
+/*
+ * Wait until all BTE related CRBs are completed
+ * and then reset the interfaces.
+ */
+int shub2_bte_error_handler(unsigned long _nodepda)
+{
+	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
+	struct timer_list *recovery_timer = &err_nodepda->bte_recovery_timer;
+	struct bteinfo_s *bte;
+	nasid_t nasid;
+	u64 status;
+	int i;
+
+	nasid = cnodeid_to_nasid(err_nodepda->bte_if[0].bte_cnode);
+
+	/*
+	 * Verify that all the BTEs are complete
+	 */
+	for (i = 0; i < BTES_PER_NODE; i++) {
+		bte = &err_nodepda->bte_if[i];
+		status = BTE_LNSTAT_LOAD(bte);
+		if ((status & IBLS_ERROR) || !(status & IBLS_BUSY))
+			continue;
+		mod_timer(recovery_timer, HZ * 5);
+		BTE_PRINTK(("eh:%p:%d Marked Giving up\n", err_nodepda,
+			    smp_processor_id()));
+		return 1;
+	}
+	if (ia64_sn_bte_recovery(nasid))
+		panic("bte_error_handler(): Fatal BTE Error");
+
+	del_timer(recovery_timer);
+	return 0;
 }
 
 /*
@@ -135,7 +171,6 @@ void bte_error_handler(unsigned long _no
 	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
 	spinlock_t *recovery_lock = &err_nodepda->bte_recovery_lock;
 	int i;
-	nasid_t nasid;
 	unsigned long irq_flags;
 	volatile u64 *notify;
 	bte_result_t bh_error;
@@ -160,12 +195,15 @@ void bte_error_handler(unsigned long _no
 	}
 
 	if (is_shub1()) {
-		shub1_bte_error_handler(_nodepda);
+		if (shub1_bte_error_handler(_nodepda)) {
+			spin_unlock_irqrestore(recovery_lock, irq_flags);
+			return;
+		}
 	} else {
-		nasid = cnodeid_to_nasid(err_nodepda->bte_if[0].bte_cnode);
-
-		if (ia64_sn_bte_recovery(nasid))
-			panic("bte_error_handler(): Fatal BTE Error");
+		if (shub2_bte_error_handler(_nodepda)) {
+			spin_unlock_irqrestore(recovery_lock, irq_flags);
+			return;
+		}
 	}
 
 	for (i = 0; i < BTES_PER_NODE; i++) {
Index: test/arch/ia64/sn/kernel/huberror.c
=================================--- test.orig/arch/ia64/sn/kernel/huberror.c	2005-12-14 12:58:08.035675745 -0600
+++ test/arch/ia64/sn/kernel/huberror.c	2005-12-16 14:50:29.315025175 -0600
@@ -32,13 +32,14 @@ static irqreturn_t hub_eint_handler(int 
 	ret_stuff.v0 = 0;
 	hubdev_info = (struct hubdev_info *)arg;
 	nasid = hubdev_info->hdi_nasid;
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_HUB_ERROR_INTERRUPT,
+
+	if (is_shub1()) {
+		SAL_CALL_NOLOCK(ret_stuff, SN_SAL_HUB_ERROR_INTERRUPT,
 			(u64) nasid, 0, 0, 0, 0, 0, 0);
 
-	if ((int)ret_stuff.v0)
-		panic("hubii_eint_handler(): Fatal TIO Error");
+		if ((int)ret_stuff.v0)
+			panic("hubii_eint_handler(): Fatal TIO Error");
 
-	if (is_shub1()) {
 		if (!(nasid & 1)) /* Not a TIO, handle CRB errors */
 			(void)hubiio_crb_error_handler(hubdev_info);
 	} else 

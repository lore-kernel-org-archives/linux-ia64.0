From: Russ Anderson <rja@sgi.com>
Date: Fri, 11 Mar 2005 00:25:56 +0000
Subject: [patch 2/2] Altix: Shub2 BTE support - BTE recovery code
Message-Id: <200503110025.j2B0Pul34003981@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch 2/2] Altix: Shub2 BTE support - BTE recovery code

This patch adds support for shub2 BTE.

patch 1:
	Add new MMR definitions.
	Modify BTE initialiation
	Modify BTE copy.

patch 2:
	Shub2 BTE recovery code will be implemented in SAL.  
	Define the SAL interface.
	Modify bte_error to call SAL for shub2.

The patches apply on top of
  - Jack Steiner's patch of 3/1/05 ("New chipset support for SN platform")
  - Mark Goodwin's patch of 3/8/05 ("Altix SN topology support for new
                                        chipsets and pci topology")
  - Greg Howard's patch of 3/10/05 ("Altix system controller event handling").


Signed-off-by: Russ Anderson <rja@sgi.com>

---------------------------------------------------------------------------------
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-03-10 16:51:59.893333402 -0600
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-03-10 17:53:06.567325324 -0600
@@ -8,7 +8,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -77,7 +77,7 @@
 #define  SN_SAL_IOIF_GET_PCI_TOPOLOGY	           0x02000059
 
 #define SN_SAL_HUB_ERROR_INTERRUPT		   0x02000060
-
+#define SN_SAL_BTE_RECOVER			   0x02000061
 
 /*
  * Service-specific constants
@@ -1023,4 +1023,19 @@
 	return (int) rv.status;
 }
 
+/*
+ * BTE error recovery is implemented in SAL
+ */
+static inline int
+ia64_sn_bte_recovery(nasid_t nasid)
+{
+	struct ia64_sal_retval rv;
+
+	rv.status = 0;
+	SAL_CALL_NOLOCK(rv, SN_SAL_BTE_RECOVER, 0, 0, 0, 0, 0, 0, 0);
+	if (rv.status = SALRET_NOT_IMPLEMENTED)
+		return 0;
+	return (int) rv.status;
+}
+
 #endif /* _ASM_IA64_SN_SN_SAL_H */
Index: linux/arch/ia64/sn/kernel/huberror.c
=================================--- linux.orig/arch/ia64/sn/kernel/huberror.c	2005-03-04 15:39:14.733722125 -0600
+++ linux/arch/ia64/sn/kernel/huberror.c	2005-03-10 17:57:59.045792194 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000,2002-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000,2002-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/types.h>
@@ -38,8 +38,11 @@
 	if ((int)ret_stuff.v0)
 		panic("hubii_eint_handler(): Fatal TIO Error");
 
-	if (!(nasid & 1)) /* Not a TIO, handle CRB errors */
-		(void)hubiio_crb_error_handler(hubdev_info);
+	if (is_shub1()) {
+		if (!(nasid & 1)) /* Not a TIO, handle CRB errors */
+			(void)hubiio_crb_error_handler(hubdev_info);
+	} else 
+		bte_error_handler((unsigned long)NODEPDA(nasid_to_cnodeid(nasid)));
 
 	return IRQ_HANDLED;
 }
Index: linux/arch/ia64/sn/kernel/bte_error.c
=================================--- linux.orig/arch/ia64/sn/kernel/bte_error.c	2005-03-04 15:39:14.732745573 -0600
+++ linux/arch/ia64/sn/kernel/bte_error.c	2005-03-10 18:01:29.663793041 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/types.h>
@@ -33,48 +33,28 @@
  * Wait until all BTE related CRBs are completed
  * and then reset the interfaces.
  */
-void bte_error_handler(unsigned long _nodepda)
+void shub1_bte_error_handler(unsigned long _nodepda)
 {
 	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
-	spinlock_t *recovery_lock = &err_nodepda->bte_recovery_lock;
 	struct timer_list *recovery_timer = &err_nodepda->bte_recovery_timer;
 	nasid_t nasid;
 	int i;
 	int valid_crbs;
-	unsigned long irq_flags;
-	volatile u64 *notify;
-	bte_result_t bh_error;
 	ii_imem_u_t imem;	/* II IMEM Register */
 	ii_icrb0_d_u_t icrbd;	/* II CRB Register D */
 	ii_ibcr_u_t ibcr;
 	ii_icmr_u_t icmr;
 	ii_ieclr_u_t ieclr;
 
-	BTE_PRINTK(("bte_error_handler(%p) - %d\n", err_nodepda,
+	BTE_PRINTK(("shub1_bte_error_handler(%p) - %d\n", err_nodepda,
 		    smp_processor_id()));
 
-	spin_lock_irqsave(recovery_lock, irq_flags);
-
 	if ((err_nodepda->bte_if[0].bh_error = BTE_SUCCESS) &&
 	    (err_nodepda->bte_if[1].bh_error = BTE_SUCCESS)) {
 		BTE_PRINTK(("eh:%p:%d Nothing to do.\n", err_nodepda,
 			    smp_processor_id()));
-		spin_unlock_irqrestore(recovery_lock, irq_flags);
 		return;
 	}
-	/*
-	 * Lock all interfaces on this node to prevent new transfers
-	 * from being queued.
-	 */
-	for (i = 0; i < BTES_PER_NODE; i++) {
-		if (err_nodepda->bte_if[i].cleanup_active) {
-			continue;
-		}
-		spin_lock(&err_nodepda->bte_if[i].spinlock);
-		BTE_PRINTK(("eh:%p:%d locked %d\n", err_nodepda,
-			    smp_processor_id(), i));
-		err_nodepda->bte_if[i].cleanup_active = 1;
-	}
 
 	/* Determine information about our hub */
 	nasid = cnodeid_to_nasid(err_nodepda->bte_if[0].bte_cnode);
@@ -101,7 +81,6 @@
 		mod_timer(recovery_timer, HZ * 5);
 		BTE_PRINTK(("eh:%p:%d Marked Giving up\n", err_nodepda,
 			    smp_processor_id()));
-		spin_unlock_irqrestore(recovery_lock, irq_flags);
 		return;
 	}
 	if (icmr.ii_icmr_fld_s.i_crb_vld != 0) {
@@ -120,8 +99,6 @@
 				BTE_PRINTK(("eh:%p:%d Valid %d, Giving up\n",
 					    err_nodepda, smp_processor_id(),
 					    i));
-				spin_unlock_irqrestore(recovery_lock,
-						       irq_flags);
 				return;
 			}
 		}
@@ -146,6 +123,51 @@
 	ibcr.ii_ibcr_fld_s.i_soft_reset = 1;
 	REMOTE_HUB_S(nasid, IIO_IBCR, ibcr.ii_ibcr_regval);
 
+	del_timer(recovery_timer);
+}
+
+/*
+ * Wait until all BTE related CRBs are completed
+ * and then reset the interfaces.
+ */
+void bte_error_handler(unsigned long _nodepda)
+{
+	struct nodepda_s *err_nodepda = (struct nodepda_s *)_nodepda;
+	spinlock_t *recovery_lock = &err_nodepda->bte_recovery_lock;
+	int i;
+	nasid_t nasid;
+	unsigned long irq_flags;
+	volatile u64 *notify;
+	bte_result_t bh_error;
+
+	BTE_PRINTK(("bte_error_handler(%p) - %d\n", err_nodepda,
+		    smp_processor_id()));
+
+	spin_lock_irqsave(recovery_lock, irq_flags);
+
+	/*
+	 * Lock all interfaces on this node to prevent new transfers
+	 * from being queued.
+	 */
+	for (i = 0; i < BTES_PER_NODE; i++) {
+		if (err_nodepda->bte_if[i].cleanup_active) {
+			continue;
+		}
+		spin_lock(&err_nodepda->bte_if[i].spinlock);
+		BTE_PRINTK(("eh:%p:%d locked %d\n", err_nodepda,
+			    smp_processor_id(), i));
+		err_nodepda->bte_if[i].cleanup_active = 1;
+	}
+
+	if (is_shub1()) {
+		shub1_bte_error_handler(_nodepda);
+	} else {
+		nasid = cnodeid_to_nasid(err_nodepda->bte_if[0].bte_cnode);
+
+		if (ia64_sn_bte_recovery(nasid))
+			panic("bte_error_handler(): Fatal BTE Error");
+	}
+
 	for (i = 0; i < BTES_PER_NODE; i++) {
 		bh_error = err_nodepda->bte_if[i].bh_error;
 		if (bh_error != BTE_SUCCESS) {
@@ -165,8 +187,6 @@
 		spin_unlock(&err_nodepda->bte_if[i].spinlock);
 	}
 
-	del_timer(recovery_timer);
-
 	spin_unlock_irqrestore(recovery_lock, irq_flags);
 }
 
---------------------------------------------------------------------------------

From: Robin Holt <holt@sgi.com>
Date: Tue, 19 Oct 2004 19:10:04 +0000
Subject: Correct BTE notification timeouts on SN2.
Message-Id: <20041019191004.GE1012@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The SN2 Block Transfer Engine occassionally fails to send a notification
that it has completed a transfer to the kernel.  This patch adds a
timeout mechanism which will detect the failure, reset the interface,
and then retry the transfer.

Signed-off-by: Robin Holt


Index: linux-2.6/include/asm-ia64/sn/bte.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/bte.h	2004-10-18 07:12:40.000000000 -0500
+++ linux-2.6/include/asm-ia64/sn/bte.h	2004-10-18 15:47:29.000000000 -0500
@@ -55,7 +55,9 @@
 /* macro to force the IBCT0 value valid */
 #define BTE_VALID_MODE(x) ((x) & (IBCT_NOTIFY | IBCT_ZFIL_MODE))
 
-#define BTE_ACTIVE	(IBLS_BUSY | IBLS_ERROR)
+#define BTE_ACTIVE		(IBLS_BUSY | IBLS_ERROR)
+#define BTE_WORD_AVAILABLE	(IBLS_BUSY << 1)
+#define BTE_WORD_BUSY		(~BTE_WORD_AVAILABLE)
 
 /*
  * Some macros to simplify reading.
Index: linux-2.6/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/bte.c	2004-10-18 15:45:52.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/bte.c	2004-10-18 15:49:03.000000000 -0500
@@ -15,6 +15,7 @@
 #include <asm/sn/pda.h>
 #include "shubio.h"
 #include <asm/nodedata.h>
+#include <asm/delay.h>
 
 #include <linux/bootmem.h>
 #include <linux/string.h>
@@ -69,6 +70,7 @@
 	struct bteinfo_s *bte;
 	bte_result_t bte_status;
 	unsigned long irq_flags;
+	unsigned long itc_end = 0;
 	struct bteinfo_s *btes_to_try[MAX_INTERFACES_TO_TRY];
 	int bte_if_index;
 
@@ -107,6 +109,7 @@
 		}
 	}
 
+retry_bteop:
 	do {
 		local_irq_save(irq_flags);
 
@@ -121,7 +124,7 @@
 			}
 
 			if (spin_trylock(&bte->spinlock)) {
-				if ((*bte->most_rcnt_na & BTE_ACTIVE) ||
+				if (!(*bte->most_rcnt_na & BTE_WORD_AVAILABLE) ||
 				    (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
 					/* Got the lock but BTE still busy */
 					spin_unlock(&bte->spinlock);
@@ -155,7 +158,7 @@
 	transfer_size = ((len >> L1_CACHE_SHIFT) & BTE_LEN_MASK);
 
 	/* Initialize the notification to a known value. */
-	*bte->most_rcnt_na = -1L;
+	*bte->most_rcnt_na = BTE_WORD_BUSY;
 
 	/* Set the status reg busy bit and transfer length */
 	BTE_PRINTKV(("IBLS = 0x%lx\n", IBLS_BUSY | transfer_size));
@@ -177,13 +180,25 @@
 	BTE_PRINTK(("IBCT = 0x%lx)\n", BTE_VALID_MODE(mode)));
 	BTE_CTRL_STORE(bte, BTE_VALID_MODE(mode));
 
+	itc_end = ia64_get_itc() + (40000000 * local_cpu_data->cyc_per_usec);
+
 	spin_unlock_irqrestore(&bte->spinlock, irq_flags);
 
 	if (notification != NULL) {
 		return BTE_SUCCESS;
 	}
 
-	while ((transfer_stat = *bte->most_rcnt_na) = -1UL) {
+	while ((transfer_stat = *bte->most_rcnt_na) = BTE_WORD_BUSY) {
+		if (ia64_get_itc() > itc_end) {
+			BTE_PRINTK(("BTE timeout nasid 0x%x bte%d IBLS = 0x%lx na 0x%lx\n",
+				NASID_GET(bte->bte_base_addr), bte->bte_num,
+				BTE_LNSTAT_LOAD(bte), *bte->most_rcnt_na) );
+			bte->bte_error_count++;
+			bte->bh_error = IBLS_ERROR;
+			bte_error_handler((unsigned long)NODEPDA(bte->bte_cnode));
+			*bte->most_rcnt_na = BTE_WORD_AVAILABLE;
+			goto retry_bteop;
+		}
 	}
 
 	BTE_PRINTKV((" Delay Done.  IBLS = 0x%lx, most_rcnt_na = 0x%lx\n",
@@ -191,10 +206,11 @@
 
 	if (transfer_stat & IBLS_ERROR) {
 		bte_status = transfer_stat & ~IBLS_ERROR;
-		*bte->most_rcnt_na = 0L;
 	} else {
 		bte_status = BTE_SUCCESS;
 	}
+	*bte->most_rcnt_na = BTE_WORD_AVAILABLE;
+
 	BTE_PRINTK(("Returning status is 0x%lx and most_rcnt_na is 0x%lx\n",
 		    BTE_LNSTAT_LOAD(bte), *bte->most_rcnt_na));
 
@@ -414,7 +430,7 @@
 		 */
 		mynodepda->bte_if[i].most_rcnt_na  		    &(mynodepda->bte_if[i].notify);
-		mynodepda->bte_if[i].notify = 0L;
+		mynodepda->bte_if[i].notify = BTE_WORD_AVAILABLE;
 		spin_lock_init(&mynodepda->bte_if[i].spinlock);
 
 		mynodepda->bte_if[i].bte_cnode = cnode;

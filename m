From: Robin Holt <holt@sgi.com>
Date: Mon, 18 Oct 2004 21:34:52 +0000
Subject: Re: Double spin_unlock in bte.c
Message-Id: <20041018213452.GA18004@lnx-holt.americas.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014114003.GF19122@lnx-holt.americas.sgi.com>
In-Reply-To: <20041014114003.GF19122@lnx-holt.americas.sgi.com>
To: linux-ia64@vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> I have another bte mod too - I've added it to the list - it's
> 008-bugon-fix on the oss site.

Pat and Tony,

I have created a 009-bte_double_unlock patch which is the same patch that
was sent to the list last week.  Russ Anderson and I have worked up two
additional patches for the bte.  The first works around an extremely
infrequent hardware issue and the other reduces contention on the bte
interface locks by distributing based upon the slice that the requestors
cpu is on.

Pat, can you add those to your patch set?

Thanks,
Robin Holt

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=009-bte_double_unlock

Index: linux-2.6/arch/ia64/sn/kernel/bte.c
===================================================================
--- linux-2.6.orig/arch/ia64/sn/kernel/bte.c	2004-10-18 06:59:45.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/bte.c	2004-10-18 07:00:26.000000000 -0500
@@ -125,12 +125,12 @@
 				    (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
 					/* Got the lock but BTE still busy */
 					spin_unlock(&bte->spinlock);
-					bte = NULL;
 				} else {
 					/* we got the lock and it's not busy */
 					break;
 				}
 			}
+			bte = NULL;
 		}
 
 		if (bte != NULL) {

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=010-notification_war

Index: linux-2.6/include/asm-ia64/sn/bte.h
===================================================================
--- linux-2.6.orig/include/asm-ia64/sn/bte.h	2004-10-18 07:12:40.000000000 -0500
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
===================================================================
--- linux-2.6.orig/arch/ia64/sn/kernel/bte.c	2004-10-18 15:45:52.000000000 -0500
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
 
-	while ((transfer_stat = *bte->most_rcnt_na) == -1UL) {
+	while ((transfer_stat = *bte->most_rcnt_na) == BTE_WORD_BUSY) {
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
 		mynodepda->bte_if[i].most_rcnt_na =
 		    &(mynodepda->bte_if[i].notify);
-		mynodepda->bte_if[i].notify = 0L;
+		mynodepda->bte_if[i].notify = BTE_WORD_AVAILABLE;
 		spin_lock_init(&mynodepda->bte_if[i].spinlock);
 
 		mynodepda->bte_if[i].bte_cnode = cnode;

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=011-bte_cpu_pref

Index: linux-2.6/arch/ia64/sn/kernel/bte.c
===================================================================
--- linux-2.6.orig/arch/ia64/sn/kernel/bte.c	2004-10-18 15:51:04.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/bte.c	2004-10-18 16:18:54.000000000 -0500
@@ -73,6 +73,7 @@
 	unsigned long itc_end = 0;
 	struct bteinfo_s *btes_to_try[MAX_INTERFACES_TO_TRY];
 	int bte_if_index;
+	int bte_pri, bte_sec;
 
 	BTE_PRINTK(("bte_copy(0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%p)\n",
 		    src, dest, len, mode, notification));
@@ -85,24 +86,33 @@
 		 (src & L1_CACHE_MASK) || (dest & L1_CACHE_MASK));
 	BUG_ON(!(len < ((BTE_LEN_MASK + 1) << L1_CACHE_SHIFT)));
 
+	/* CPU 0 (per node) tries bte0 first, CPU 1 try bte1 first */
+	if (cpuid_to_subnode(smp_processor_id()) == 0) {
+		bte_pri = 0;
+		bte_sec = 1;
+	} else {
+		bte_pri = 1;
+		bte_sec = 0;
+	}
+
 	if (mode & BTE_USE_DEST) {
 		/* try remote then local */
-		btes_to_try[0] = bte_if_on_node(NASID_GET(dest), 0);
-		btes_to_try[1] = bte_if_on_node(NASID_GET(dest), 1);
+		btes_to_try[0] = bte_if_on_node(NASID_GET(dest), bte_pri);
+		btes_to_try[1] = bte_if_on_node(NASID_GET(dest), bte_sec);
 		if (mode & BTE_USE_ANY) {
-			btes_to_try[2] = bte_if_on_node(get_nasid(), 0);
-			btes_to_try[3] = bte_if_on_node(get_nasid(), 1);
+			btes_to_try[2] = bte_if_on_node(get_nasid(), bte_pri);
+			btes_to_try[3] = bte_if_on_node(get_nasid(), bte_sec);
 		} else {
 			btes_to_try[2] = NULL;
 			btes_to_try[3] = NULL;
 		}
 	} else {
 		/* try local then remote */
-		btes_to_try[0] = bte_if_on_node(get_nasid(), 0);
-		btes_to_try[1] = bte_if_on_node(get_nasid(), 1);
+		btes_to_try[0] = bte_if_on_node(get_nasid(), bte_pri);
+		btes_to_try[1] = bte_if_on_node(get_nasid(), bte_sec);
 		if (mode & BTE_USE_ANY) {
-			btes_to_try[2] = bte_if_on_node(NASID_GET(dest), 0);
-			btes_to_try[3] = bte_if_on_node(NASID_GET(dest), 1);
+			btes_to_try[2] = bte_if_on_node(NASID_GET(dest), bte_pri);
+			btes_to_try[3] = bte_if_on_node(NASID_GET(dest), bte_sec);
 		} else {
 			btes_to_try[2] = NULL;
 			btes_to_try[3] = NULL;

--xHFwDpU9dbj6ez1V--

From: Robin Holt <holt@sgi.com>
Date: Tue, 27 Jul 2004 17:12:38 +0000
Subject: Some BTE Error handling cleanups.
Message-Id: <20040727171238.GA1248@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


After working with the chip designer some more, we have determined one
more hardware register we were supposed to write to ensure the SHUB
chip was ready for future transfers.  This patch fixes that.  This also
allowed us to eliminate a udelay which was working around the problem.

During retesting, we uncovered a race condition where transfer status
was changed by a different cpu after we were expecting one value which
cascaded to additional problems.  This patch uses a local variable to
also eliminate that race.


Signed-off-by: Robin Holt <holt@sgi.com> 

Index: linux-2.5/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.5.orig/arch/ia64/sn/kernel/bte.c
+++ linux-2.5/arch/ia64/sn/kernel/bte.c
@@ -16,7 +16,6 @@
 #include <asm/sn/pda.h>
 #include <asm/sn/sn2/shubio.h>
 #include <asm/nodedata.h>
-#include <asm/delay.h>
 
 #include <linux/bootmem.h>
 #include <linux/string.h>
@@ -71,6 +70,7 @@
 bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
 {
 	u64 transfer_size;
+	u64 transfer_stat;
 	struct bteinfo_s *bte;
 	bte_result_t bte_status;
 	unsigned long irq_flags;
@@ -148,9 +148,6 @@
 		if (!(mode & BTE_WACQUIRE)) {
 			return BTEFAIL_NOTAVAIL;
 		}
-
-		/* Wait until a bte is available. */
-		udelay(1);
 	} while (1);
 
 
@@ -194,15 +191,15 @@
 		return BTE_SUCCESS;
 	}
 
-	while (*bte->most_rcnt_na = -1UL) {
+	while ((transfer_stat = *bte->most_rcnt_na) = -1UL) {
 	}
 
 
 	BTE_PRINTKV((" Delay Done.  IBLS = 0x%lx, most_rcnt_na = 0x%lx\n",
 				BTE_LNSTAT_LOAD(bte), *bte->most_rcnt_na));
 
-	if (*bte->most_rcnt_na & IBLS_ERROR) {
-		bte_status = *bte->most_rcnt_na & ~IBLS_ERROR;
+	if (transfer_stat & IBLS_ERROR) {
+		bte_status = transfer_stat & ~IBLS_ERROR;
 		*bte->most_rcnt_na = 0L;
 	} else {
 		bte_status = BTE_SUCCESS;
Index: linux-2.5/arch/ia64/sn/io/sn2/bte_error.c
=================================--- linux-2.5.orig/arch/ia64/sn/io/sn2/bte_error.c
+++ linux-2.5/arch/ia64/sn/io/sn2/bte_error.c
@@ -90,6 +90,7 @@
 	ii_icrb0_d_u_t icrbd;	/* II CRB Register D */
 	ii_ibcr_u_t ibcr;
 	ii_icmr_u_t icmr;
+	ii_ieclr_u_t ieclr;
 
 
 	BTE_PRINTK(("bte_error_handler(%p) - %d\n", err_nodepda,
@@ -177,6 +178,14 @@
 	imem.ii_imem_fld_s.i_b0_esd = imem.ii_imem_fld_s.i_b1_esd = 1;
 	REMOTE_HUB_S(nasid, IIO_IMEM, imem.ii_imem_regval);
 
+	/* Clear IBLS0/1 error bits */
+	ieclr.ii_ieclr_regval = 0;
+	if (err_nodepda->bte_if[0].bh_error != BTE_SUCCESS)
+		ieclr.ii_ieclr_fld_s.i_e_bte_0 = 1;
+	if (err_nodepda->bte_if[1].bh_error != BTE_SUCCESS)
+                ieclr.ii_ieclr_fld_s.i_e_bte_1 = 1;
+	REMOTE_HUB_S(nasid, IIO_IECLR, ieclr.ii_ieclr_regval);
+
 	/* Reinitialize both BTE state machines. */
 	ibcr.ii_ibcr_regval = REMOTE_HUB_L(nasid, IIO_IBCR);
 	ibcr.ii_ibcr_fld_s.i_soft_reset = 1;

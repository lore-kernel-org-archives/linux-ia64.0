From: Alex Williamson <alex_williamson@hp.com>
Date: Tue, 05 Aug 2003 16:13:30 +0000
Subject: [PATCH] Update to CMC/CPE polling
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------AB34F027485AA7F6460488E2"
Message-Id: <marc-linux-ia64-106010036115145@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------AB34F027485AA7F6460488E2
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


    Based on the feedback from Tony, here's the patch that flips
around the clearing of cmc_polling_enabled.  This is based on
what's currently in to-linus-2.5, but applies on 2.4.21 as well.
Bjorn, I've also attached the diff for the name change David
recommended.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
--------------AB34F027485AA7F6460488E2
Content-Type: text/plain; charset=us-ascii;
 name="cmc_cpe_update.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cmc_cpe_update.diff"

--- to-linus-2.5/arch/ia64/kernel/mca.c~	2003-08-05 09:03:02.000000000 -0600
+++ to-linus-2.5/arch/ia64/kernel/mca.c	2003-08-05 09:05:03.000000000 -0600
@@ -1149,13 +1149,19 @@
 
 			printk(KERN_WARNING "%s: Returning to interrupt driven CMC handler\n", __FUNCTION__);
 
-			cmc_polling_enabled = 0;
 			/*
 			 * The cmc interrupt handler enabled irqs, so
 			 * this can't deadlock.
 			 */
 			smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
+
+			/*
+			 * Turn off interrupts before re-enabling the
+			 * cmc vector locally.  Make sure we get out.
+			 */
+			local_irq_disable();
 			ia64_mca_cmc_vector_enable(NULL);
+			cmc_polling_enabled = 0;
 
 		} else {
 

--------------AB34F027485AA7F6460488E2
Content-Type: text/plain; charset=us-ascii;
 name="sal_call_reentrant.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sal_call_reentrant.diff"

--- linux-2.4.21/include/asm-ia64/sal.h~	2003-08-05 09:22:35.000000000 -0600
+++ linux-2.4.21/include/asm-ia64/sal.h	2003-08-05 09:24:22.000000000 -0600
@@ -56,7 +56,7 @@
 	ia64_load_scratch_fpregs(__ia64_scn_fr);	\
 } while (0)
 
-# define SAL_CALL_SAFE(result,args...) do {		\
+# define SAL_CALL_REENTRANT(result,args...) do {	\
 	struct ia64_fpreg __ia64_scs_fr[6];		\
 	ia64_save_scratch_fpregs(__ia64_scs_fr);	\
 	__SAL_CALL(result, args);			\
@@ -665,7 +665,7 @@
 ia64_sal_clear_state_info (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL_SAFE(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, 0,
+	SAL_CALL_REENTRANT(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, 0,
 	              0, 0, 0, 0, 0);
 	return isrv.status;
 }
@@ -678,7 +678,7 @@
 ia64_sal_get_state_info (u64 sal_info_type, u64 *sal_info)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL_SAFE(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
+	SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
 	              sal_info, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
@@ -694,7 +694,7 @@
 ia64_sal_get_state_info_size (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL_SAFE(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, 0,
+	SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, 0,
 	              0, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;

--------------AB34F027485AA7F6460488E2--


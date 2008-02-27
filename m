From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 27 Feb 2008 09:44:06 +0000
Subject: ia64_mca_cpe_int_handler - take 2
Message-Id: <47C530E6.7080905@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010500070605020609020802"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010500070605020609020802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The ia64_mca_cpe_int_handler() and the ia64_mca_cmc_int_handler() are
not safe against nested interrupts. The interrupts are enabled too early.
The interrupts should remain blocked while we are inside the lock-
protected region. (See ..._history_lock.)

The interrupts will be enabled in ia64_mca_log_sal_error_record()
unless it is called from the MCA/INIT handlers.

Please have a look at this patch.

Thanks,

Zoltan Menyhart

Signed-off-by: Zoltan Menyhart, <Zoltan.Menyhart@bull.net>


--------------010500070605020609020802
Content-Type: text/plain;
 name="mca.c-patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca.c-patch"

--- linux-2.6.24-old/arch/ia64/kernel/mca.c	2008-02-22 18:09:12.000000000 +0100
+++ linux-2.6.24/arch/ia64/kernel/mca.c	2008-02-22 18:09:26.000000000 +0100
@@ -423,19 +423,25 @@
  *  and wakes up any processes waiting for error records.
  *
  *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE)
- *              FIXME: remove MCA and irq_safe.
+ *              irq_safe	(TRUE if not called from the MCA/INIT handlers)
  */
 static void
-ia64_mca_log_sal_error_record(int sal_info_type)
+ia64_mca_log_sal_error_record(int sal_info_type, int irq_safe)
 {
 	u8 *buffer;
 	sal_log_record_header_t *rh;
 	u64 size;
-	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA;
 #ifdef IA64_MCA_DEBUG_INFO
 	static const char * const rec_name[] = { "MCA", "INIT", "CMC", "CPE" };
 #endif
 
+	if (irq_safe){
+		/* SAL spec says: SAL_GET_STATE_INFO() and SAL_CLEAR_STATE_INFO()
+		 * should be called with interrupts enabled, unless we are in
+		 * MCA/INIT handlers.
+		 */
+		local_irq_enable();
+	}
 	size = ia64_log_get(sal_info_type, &buffer, irq_safe);
 	if (!size)
 		return;
@@ -512,9 +518,6 @@
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __FUNCTION__, cpe_irq, smp_processor_id());
 
-	/* SAL spec states this should run w/ interrupts enabled */
-	local_irq_enable();
-
 	spin_lock(&cpe_history_lock);
 	if (!cpe_poll_enabled && cpe_vector >= 0) {
 
@@ -553,8 +556,8 @@
 	spin_unlock(&cpe_history_lock);
 out:
 	/* Get the CPE error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
-
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE,
+					1 /* not called from the MCA/INIT handlers */);
 	return IRQ_HANDLED;
 }
 
@@ -1245,7 +1248,8 @@
         }
 
 	/* Get the MCA error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA,
+					0 /* called from the MCA/INIT handlers */);
 
 	/* MCA error recovery */
 	recover = (ia64_mca_ucmc_extension
@@ -1322,9 +1326,6 @@
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __FUNCTION__, cmc_irq, smp_processor_id());
 
-	/* SAL spec states this should run w/ interrupts enabled */
-	local_irq_enable();
-
 	spin_lock(&cmc_history_lock);
 	if (!cmc_polling_enabled) {
 		int i, count = 1; /* we know 1 happened now */
@@ -1367,7 +1368,8 @@
 	spin_unlock(&cmc_history_lock);
 out:
 	/* Get the CMC error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC,
+					1 /* not called from the MCA/INIT handlers */);
 
 	return IRQ_HANDLED;
 }

--------------010500070605020609020802--

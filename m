From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 28 Feb 2008 09:11:53 +0000
Subject: ia64_mca_cpe_int_handler - take 3
Message-Id: <47C67AD9.9030404@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070103060507050906020505"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070103060507050906020505
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



--------------070103060507050906020505
Content-Type: text/plain;
 name="mca.c-patch-new"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca.c-patch-new"

--- linux-2.6.24-old/arch/ia64/kernel/mca.c	2008-02-28 09:32:09.000000000 +0100
+++ linux-2.6.24/arch/ia64/kernel/mca.c	2008-02-28 09:32:09.000000000 +0100
@@ -176,6 +176,14 @@
 	oops_in_progress = 0;
 
 /*
+ * It is not safe enabling interrupts (nor touching locks) in
+ * MCA/INIT handler context.
+ */
+#define	MCA_IRQ_NOTSAFE	0	/* Called from the MCA/INIT handlers */
+#define	MCA_IRQ_SAFE	1	/* NOT called from the MCA/INIT handlers */
+
+
+/*
  * Push messages into buffer, print them later if not urgent.
  */
 void ia64_mca_printk(const char *fmt, ...)
@@ -423,19 +431,26 @@
  *  and wakes up any processes waiting for error records.
  *
  *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE)
- *              FIXME: remove MCA and irq_safe.
+ *              irq_safe	(MCA_IRQ_NOTSAFE == 0 if called from the MCA/INIT handlers,
+ *				 MCA_IRQ_SAFE == 1 otherwise)
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
@@ -512,9 +527,6 @@
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __FUNCTION__, cpe_irq, smp_processor_id());
 
-	/* SAL spec states this should run w/ interrupts enabled */
-	local_irq_enable();
-
 	spin_lock(&cpe_history_lock);
 	if (!cpe_poll_enabled && cpe_vector >= 0) {
 
@@ -553,7 +565,7 @@
 	spin_unlock(&cpe_history_lock);
 out:
 	/* Get the CPE error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, MCA_IRQ_SAFE);
 
 	return IRQ_HANDLED;
 }
@@ -1245,7 +1257,7 @@
         }
 
 	/* Get the MCA error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, MCA_IRQ_NOTSAFE);
 
 	/* MCA error recovery */
 	recover = (ia64_mca_ucmc_extension
@@ -1322,9 +1334,6 @@
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __FUNCTION__, cmc_irq, smp_processor_id());
 
-	/* SAL spec states this should run w/ interrupts enabled */
-	local_irq_enable();
-
 	spin_lock(&cmc_history_lock);
 	if (!cmc_polling_enabled) {
 		int i, count = 1; /* we know 1 happened now */
@@ -1367,7 +1376,7 @@
 	spin_unlock(&cmc_history_lock);
 out:
 	/* Get the CMC error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC, MCA_IRQ_SAFE);
 
 	return IRQ_HANDLED;
 }

--------------070103060507050906020505--

From: Alex Williamson <alex_williamson@hp.com>
Date: Tue, 25 Feb 2003 20:36:32 +0000
Subject: [Linux-ia64] [PATCH] MCA updates w/o memory scrubbing
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------A370D04E991B18D29A485D46"
Message-Id: <marc-linux-ia64-105590709805929@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------A370D04E991B18D29A485D46
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


  Here's an update to the patch I sent a couple weeks ago.  I'm going
to retract the memory scrubbing piece of the patch till I get some
more validation that it's beneficial.  I kept the CPE polling on all
processors, the MCA timestamp fix, and added a better mechanism for
the CPE polling to determine if a log was found.  Previously, if an
even number of CPE logs were retrieved, the index looked like nothing
happened.  Feedback welcome.  Thanks,

	Alex 

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------A370D04E991B18D29A485D46
Content-Type: text/plain; charset=us-ascii;
 name="cpe_polling_fixes.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cpe_polling_fixes.diff"

--- linux-2.4.20/arch/ia64/kernel/mca.c~	2003-02-25 09:39:25.000000000 -0700
+++ linux-2.4.20/arch/ia64/kernel/mca.c	2003-02-25 09:44:30.000000000 -0700
@@ -45,6 +45,7 @@
 #include <linux/timer.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/smp.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -53,6 +54,7 @@
 #include <asm/sal.h>
 #include <asm/mca.h>
 
+#include <asm/processor.h>
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
@@ -160,7 +162,7 @@
 void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. vector = %#x\n", cpe_irq);
+	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n", smp_processor_id(), cpe_irq);
 
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
@@ -797,6 +799,7 @@
 {
 	spinlock_t	isl_lock;
 	int		isl_index;
+	unsigned long	isl_count;
 	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
 } ia64_state_log_t;
 
@@ -813,11 +816,28 @@
 #define IA64_LOG_NEXT_INDEX(it)    ia64_state_log[it].isl_index
 #define IA64_LOG_CURR_INDEX(it)    1 - ia64_state_log[it].isl_index
 #define IA64_LOG_INDEX_INC(it) \
-    ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index
+    {ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index; \
+    ia64_state_log[it].isl_count++;}
 #define IA64_LOG_INDEX_DEC(it) \
     ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index
 #define IA64_LOG_NEXT_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)]))
 #define IA64_LOG_CURR_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
+#define IA64_LOG_COUNT(it)         ia64_state_log[it].isl_count
+
+/*
+ *  ia64_mca_cpe_int_caller
+ *
+ * 	Call CPE interrupt handler, only purpose is to have a
+ * 	smp_call_function callable entry.
+ *
+ * Inputs   :	dummy(unused)
+ * Outputs  :	None
+ * */
+static void
+ia64_mca_cpe_int_caller(void *dummy)
+{
+	ia64_mca_cpe_int_handler(0, NULL, NULL);
+}
 
 /*
  *  ia64_mca_cpe_poll
@@ -832,19 +852,20 @@
 static void
 ia64_mca_cpe_poll (unsigned long dummy)
 {
-	int start_index;
+	int start_count;
 	static int poll_time = MAX_CPE_POLL_INTERVAL;
 
-	start_index = IA64_LOG_CURR_INDEX(SAL_INFO_TYPE_CPE);
+	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);
 
 	/* Call the interrupt handler */
-	ia64_mca_cpe_int_handler(0, NULL, NULL);
+	smp_call_function(ia64_mca_cpe_int_caller, NULL, 1, 1);
+	ia64_mca_cpe_int_caller(NULL);
 
 	/*
 	 * If a log was recorded, increase our polling frequency,
 	 * otherwise, backoff.
 	 */
-	if (start_index != IA64_LOG_CURR_INDEX(SAL_INFO_TYPE_CPE)) {
+	if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
 		poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time/2);
 	} else {
 		poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
@@ -1077,7 +1098,7 @@
 {
 	prfunc("+Err Record ID: %d    SAL Rev: %2x.%02x\n", lh->id,
 		lh->revision.major, lh->revision.minor);
-	prfunc("+Time: %02x/%02x/%02x%02x %02d:%02d:%02d    Severity %d\n",
+	prfunc("+Time: %02x/%02x/%02x%02x %02x:%02x:%02x    Severity %d\n",
 		lh->timestamp.slh_month, lh->timestamp.slh_day,
 		lh->timestamp.slh_century, lh->timestamp.slh_year,
 		lh->timestamp.slh_hour, lh->timestamp.slh_minute,

--------------A370D04E991B18D29A485D46--



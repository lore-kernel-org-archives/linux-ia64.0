From: Alex Williamson <alex_williamson@hp.com>
Date: Fri, 07 Mar 2003 21:36:07 +0000
Subject: [Linux-ia64] Re: [PATCH] CMC polling
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------1FB17C66CDF7A69CC0404ACB"
Message-Id: <marc-linux-ia64-105590709806005@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------1FB17C66CDF7A69CC0404ACB
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


  Here's a bugfix update to my previous patch.  I was mistakenly
using smp_call_function w/ interrupts disabled.  There's a definite
danger of deadlock under those circumstances.  I've attached a new
version of the last patch as well as an interdiff between the two.
Let me know if there are any other issues.  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------1FB17C66CDF7A69CC0404ACB
Content-Type: text/plain; charset=us-ascii;
 name="cmc_polling_mca_updates_v2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cmc_polling_mca_updates_v2.diff"

--- arch/ia64/kernel/mca.c~	2003-03-03 11:41:09.000000000 -0700
+++ arch/ia64/kernel/mca.c	2003-03-07 12:07:53.000000000 -0700
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
 
@@ -110,8 +112,16 @@
 
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
 #define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
+#define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
+#define CMC_HISTORY_LENGTH    5
 
 static struct timer_list cpe_poll_timer;
+static struct timer_list cmc_poll_timer;
+/*
+ * Start with this in the wrong state so we won't play w/ timers
+ * before the system is ready.
+ */
+static int cmc_polling_enabled = 1;
 
 /*
  *  ia64_mca_log_sal_error_record
@@ -160,7 +170,7 @@
 void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. vector = %#x\n", cpe_irq);
+	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n", smp_processor_id(), cpe_irq);
 
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
@@ -331,6 +341,60 @@
 		       smp_processor_id(), ia64_get_cmcv());
 }
 
+/*
+ * ia64_mca_cmc_vector_disable
+ *
+ *  Mask the corrected machine check vector register in the processor.
+ *  This function is invoked on a per-processor basis.
+ *
+ * Inputs
+ *      dummy(unused)
+ *
+ * Outputs
+ *	None
+ */
+void
+ia64_mca_cmc_vector_disable (void *dummy)
+{
+	cmcv_reg_t	cmcv;
+	
+	cmcv = (cmcv_reg_t)ia64_get_cmcv();
+
+	cmcv.cmcv_mask = 1; /* Mask/disable interrupt */
+	ia64_set_cmcv(cmcv.cmcv_regval);
+
+	IA64_MCA_DEBUG("ia64_mca_cmc_vector_disable: CPU %d corrected "
+		       "machine check vector %#x disabled.\n",
+		       smp_processor_id(), cmcv.cmcv_vector);
+}
+
+/*
+ * ia64_mca_cmc_vector_enable
+ *
+ *  Unmask the corrected machine check vector register in the processor.
+ *  This function is invoked on a per-processor basis.
+ *
+ * Inputs
+ *      dummy(unused)
+ *
+ * Outputs
+ *	None
+ */
+void
+ia64_mca_cmc_vector_enable (void *dummy)
+{
+	cmcv_reg_t	cmcv;
+	
+	cmcv = (cmcv_reg_t)ia64_get_cmcv();
+
+	cmcv.cmcv_mask = 0; /* Unmask/enable interrupt */
+	ia64_set_cmcv(cmcv.cmcv_regval);
+
+	IA64_MCA_DEBUG("ia64_mca_cmc_vector_enable: CPU %d corrected "
+		       "machine check vector %#x enabled.\n",
+		       smp_processor_id(), cmcv.cmcv_vector);
+}
+
 
 #if defined(MCA_TEST)
 
@@ -780,11 +844,68 @@
 void
 ia64_mca_cmc_int_handler(int cmc_irq, void *arg, struct pt_regs *ptregs)
 {
+	static unsigned long	cmc_history[CMC_HISTORY_LENGTH];
+	static int		index;
+	static spinlock_t	cmc_history_lock = SPIN_LOCK_UNLOCKED;
+
 	IA64_MCA_DEBUG("ia64_mca_cmc_int_handler: received interrupt vector = %#x on CPU %d\n",
 		       cmc_irq, smp_processor_id());
 
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC, 0);
+
+	spin_lock(&cmc_history_lock);
+	if (!cmc_polling_enabled) {
+		int i, count = 1; /* we know 1 happened now */
+		unsigned long now = jiffies;
+		
+		for (i = 0; i < CMC_HISTORY_LENGTH; i++) {
+			if (now - cmc_history[i] <= HZ)
+				count++;
+		}
+
+		IA64_MCA_DEBUG(KERN_INFO "CMC threshold %d/%d\n", count, CMC_HISTORY_LENGTH);
+		if (count >= CMC_HISTORY_LENGTH) {
+			/*
+			 * CMC threshold exceeded, clear the history
+			 * so we have a fresh start when we return
+			 */
+			for (index = 0 ; index < CMC_HISTORY_LENGTH; index++)
+				cmc_history[index] = 0;
+			index = 0;
+
+			/* Switch to polling mode */
+			cmc_polling_enabled = 1;
+
+			/*
+			 * Unlock & enable interrupts  before 
+			 * smp_call_function or risk deadlock
+			 */
+			spin_unlock(&cmc_history_lock);
+			ia64_mca_cmc_vector_disable(NULL);
+
+			local_irq_enable();
+			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 1);
+
+			/*
+			 * Corrected errors will still be corrected, but
+			 * make sure there's a log somewhere that indicates
+			 * something is generating more than we can handle.
+			 */
+			printk(KERN_WARNING "ia64_mca_cmc_int_handler: WARNING: Switching to polling CMC handler, error records may be lost\n");
+			
+
+			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
+
+			/* lock already released, get out now */
+			return;
+		} else {
+			cmc_history[index++] = now;
+			if (index == CMC_HISTORY_LENGTH)
+				index = 0;
+		}
+	}
+	spin_unlock(&cmc_history_lock);
 }
 
 /*
@@ -797,6 +918,7 @@
 {
 	spinlock_t	isl_lock;
 	int		isl_index;
+	unsigned long	isl_count;
 	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
 } ia64_state_log_t;
 
@@ -813,11 +935,78 @@
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
+ *  ia64_mca_cmc_int_caller
+ *
+ * 	Call CMC interrupt handler, only purpose is to have a
+ * 	smp_call_function callable entry.
+ *
+ * Inputs   :	dummy(unused)
+ * Outputs  :	None
+ * */
+static void
+ia64_mca_cmc_int_caller(void *dummy)
+{
+	ia64_mca_cmc_int_handler(0, NULL, NULL);
+}
+
+/*
+ *  ia64_mca_cmc_poll
+ *
+ *	Poll for Corrected Machine Checks (CMCs)
+ *
+ * Inputs   :   dummy(unused)
+ * Outputs  :   None
+ *
+ */
+static void
+ia64_mca_cmc_poll (unsigned long dummy)
+{
+	int start_count;
+
+	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC);
+
+	/* Call the interrupt handler */
+	smp_call_function(ia64_mca_cmc_int_caller, NULL, 1, 1);
+	local_irq_disable();
+	ia64_mca_cmc_int_caller(NULL);
+	local_irq_enable();
+
+	/*
+	 * If no log recored, switch out of polling mode.
+	 */
+	if (start_count == IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
+		printk(KERN_WARNING "ia64_mca_cmc_poll: Returning to interrupt driven CMC handler\n");
+		cmc_polling_enabled = 0;
+		smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 1);
+		ia64_mca_cmc_vector_enable(NULL);
+	} else {
+		mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
+	}
+}
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
@@ -832,19 +1021,22 @@
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
+	local_irq_disable();
+	ia64_mca_cpe_int_caller(NULL);
+	local_irq_enable();
 
 	/*
 	 * If a log was recorded, increase our polling frequency,
 	 * otherwise, backoff.
 	 */
-	if (start_index != IA64_LOG_CURR_INDEX(SAL_INFO_TYPE_CPE)) {
+	if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
 		poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time/2);
 	} else {
 		poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
@@ -865,11 +1057,19 @@
 static int __init
 ia64_mca_late_init(void)
 {
-	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0) {
-		init_timer(&cpe_poll_timer);
-		cpe_poll_timer.function = ia64_mca_cpe_poll;
-		ia64_mca_cpe_poll(0);
-	}
+	init_timer(&cmc_poll_timer);
+	cmc_poll_timer.function = ia64_mca_cmc_poll;
+
+	/* Reset to the correct state */
+	cmc_polling_enabled = 0;
+
+	init_timer(&cpe_poll_timer);
+	cpe_poll_timer.function = ia64_mca_cpe_poll;
+
+	/* If platform doesn't support CPEI, get the timer going. */
+	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0)
+		ia64_mca_cpe_poll(0UL);
+
 	return 0;
 }
 
@@ -1077,7 +1277,7 @@
 {
 	prfunc("+Err Record ID: %d    SAL Rev: %2x.%02x\n", lh->id,
 		lh->revision.major, lh->revision.minor);
-	prfunc("+Time: %02x/%02x/%02x%02x %02d:%02d:%02d    Severity %d\n",
+	prfunc("+Time: %02x/%02x/%02x%02x %02x:%02x:%02x    Severity %d\n",
 		lh->timestamp.slh_month, lh->timestamp.slh_day,
 		lh->timestamp.slh_century, lh->timestamp.slh_year,
 		lh->timestamp.slh_hour, lh->timestamp.slh_minute,

--------------1FB17C66CDF7A69CC0404ACB
Content-Type: text/plain; charset=us-ascii;
 name="cmc_polling_mca_updates_v1-v2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cmc_polling_mca_updates_v1-v2.diff"

diff -u arch/ia64/kernel/mca.c arch/ia64/kernel/mca.c
--- arch/ia64/kernel/mca.c	2003-03-03 11:41:23.000000000 -0700
+++ arch/ia64/kernel/mca.c	2003-03-07 12:07:53.000000000 -0700
@@ -877,11 +877,16 @@
 			/* Switch to polling mode */
 			cmc_polling_enabled = 1;
 
-			/* Unlock before smp_call_function or risk deadlock */
+			/*
+			 * Unlock & enable interrupts  before 
+			 * smp_call_function or risk deadlock
+			 */
 			spin_unlock(&cmc_history_lock);
-			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 1);
 			ia64_mca_cmc_vector_disable(NULL);
 
+			local_irq_enable();
+			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 1);
+
 			/*
 			 * Corrected errors will still be corrected, but
 			 * make sure there's a log somewhere that indicates
@@ -970,8 +975,8 @@
 	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC);
 
 	/* Call the interrupt handler */
-	local_irq_disable();
 	smp_call_function(ia64_mca_cmc_int_caller, NULL, 1, 1);
+	local_irq_disable();
 	ia64_mca_cmc_int_caller(NULL);
 	local_irq_enable();
 
@@ -1022,8 +1027,8 @@
 	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);
 
 	/* Call the interrupt handler */
-	local_irq_disable();
 	smp_call_function(ia64_mca_cpe_int_caller, NULL, 1, 1);
+	local_irq_disable();
 	ia64_mca_cpe_int_caller(NULL);
 	local_irq_enable();
 

--------------1FB17C66CDF7A69CC0404ACB--



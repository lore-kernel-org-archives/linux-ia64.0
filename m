From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 10 Mar 2003 22:50:57 +0000
Subject: [Linux-ia64] [PATCH] CPE & CMC polling for 2.5
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------C49D27E234E8E6C4FE96E545"
Message-Id: <marc-linux-ia64-105590709806019@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------C49D27E234E8E6C4FE96E545
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Here's versions of CPE and CMC polling against 2.5.64.  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------C49D27E234E8E6C4FE96E545
Content-Type: text/plain; charset=us-ascii;
 name="linux-2.5.64-mca-updates.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.5.64-mca-updates.diff"

--- linux-2.5.64/arch/ia64/kernel/mca.c~	2003-03-10 15:10:48.000000000 -0700
+++ linux-2.5.64/arch/ia64/kernel/mca.c	2003-03-10 15:40:44.000000000 -0700
@@ -42,6 +42,10 @@
 #include <linux/smp_lock.h>
 #include <linux/bootmem.h>
 #include <linux/acpi.h>
+#include <linux/timer.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/smp.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -105,6 +109,19 @@
 	.name =		"cpe_hndlr"
 };
 
+#define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
+#define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
+#define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
+#define CMC_HISTORY_LENGTH    5
+
+static struct timer_list cpe_poll_timer;
+static struct timer_list cmc_poll_timer;
+/*
+ * Start with this in the wrong state so we won't play w/ timers
+ * before the system is ready.
+ */
+static int cmc_polling_enabled = 1;
+
 /*
  *  ia64_mca_log_sal_error_record
  *
@@ -152,7 +169,7 @@
 void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. vector = %#x\n", cpe_irq);
+	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n", smp_processor_id(), cpe_irq);
 
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
@@ -295,6 +312,60 @@
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
 
@@ -494,9 +565,7 @@
 					setup_irq(irq, &mca_cpe_irqaction);
 				}
 			ia64_mca_register_cpev(cpev);
-		} else
-			printk(KERN_ERR
-			       "ia64_mca_init: Failed to get routed CPEI vector from ACPI.\n");
+		}
 	}
 
 	/* Initialize the areas set aside by the OS to buffer the
@@ -751,11 +820,68 @@
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
@@ -768,6 +894,7 @@
 {
 	spinlock_t	isl_lock;
 	int		isl_index;
+	unsigned long	isl_count;
 	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
 } ia64_state_log_t;
 
@@ -784,11 +911,145 @@
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
+
+/*
+ *  ia64_mca_cpe_poll
+ *
+ *	Poll for Corrected Platform Errors (CPEs), dynamically adjust
+ *	polling interval based on occurance of an event.
+ *
+ * Inputs   :   dummy(unused)
+ * Outputs  :   None
+ *
+ */
+static void
+ia64_mca_cpe_poll (unsigned long dummy)
+{
+	int start_count;
+	static int poll_time = MAX_CPE_POLL_INTERVAL;
+
+	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);
+
+	/* Call the interrupt handler */
+	smp_call_function(ia64_mca_cpe_int_caller, NULL, 1, 1);
+	local_irq_disable();
+	ia64_mca_cpe_int_caller(NULL);
+	local_irq_enable();
+
+	/*
+	 * If a log was recorded, increase our polling frequency,
+	 * otherwise, backoff.
+	 */
+	if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
+		poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time/2);
+	} else {
+		poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
+	}
+	mod_timer(&cpe_poll_timer, jiffies + poll_time);
+}
+
+/*
+ * ia64_mca_late_init
+ *
+ *	Opportunity to setup things that require initialization later
+ *	than ia64_mca_init.  Setup a timer to poll for CPEs if the
+ *	platform doesn't support an interrupt driven mechanism.
+ *
+ *  Inputs  :   None
+ *  Outputs :   Status
+ */
+static int __init
+ia64_mca_late_init(void)
+{
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
+	return 0;
+}
+
+device_initcall(ia64_mca_late_init);
 
 /*
  * C portion of the OS INIT handler
@@ -949,7 +1210,6 @@
 		return total_len;
 	} else {
 		IA64_LOG_UNLOCK(sal_info_type);
-		prfunc("ia64_log_get: No SAL error record available for type %d\n", sal_info_type);
 		return 0;
 	}
 }

--------------C49D27E234E8E6C4FE96E545--



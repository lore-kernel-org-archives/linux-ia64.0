From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 31 Jul 2003 23:06:08 +0000
Subject: [PATCH] New CMC/CPE polling
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------4956790ACE5AD555316B1A01"
Message-Id: <marc-linux-ia64-105969308328993@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------4956790ACE5AD555316B1A01
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Here's a redesign of the CMC and CPE polling for both 2.6.0-test2
and 2.4.21.  This is roughly the same design I requested comment on
a while back (BTW, nobody commented...).  Basically, rather than
flooding all the cpus in parallel, I used some low priority interrupts
to cascade through the cpus.  This should be much more scalable.  I
also added a new feature of enabling interrupts for the CMC and CPE
handlers.  The SAL spec claims these functions are SMP safe and
re-entrant and even recommends that the corrected error handlers
should run with interrupts enabled.  It works on HP boxes, others
might want to double check that their firmware adheres to the spec.
The combination of these things should keep polling from impacting
system response time.  I tried to keep the 2.6 and 2.4 code as similar
as possible, so I also backported __ffs() to 2.4.  Feedback and bug
reports welcome.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
--------------4956790ACE5AD555316B1A01
Content-Type: text/plain; charset=us-ascii;
 name="linux-2.6.0-test2-ia64-cmc_cpe.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.0-test2-ia64-cmc_cpe.diff"

--- linux/arch/ia64/kernel/iosapic.c	2003-07-27 11:01:50.000000000 -0600
+++ linux/arch/ia64/kernel/iosapic.c	2003-07-29 09:24:37.000000000 -0600
@@ -543,7 +543,7 @@
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:
-		vector = IA64_PCE_VECTOR;
+		vector = IA64_CPE_VECTOR;
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		break;
 	      default:
--- linux/arch/ia64/sn/kernel/setup.c	2003-07-27 10:59:24.000000000 -0600
+++ linux/arch/ia64/sn/kernel/setup.c	2003-07-29 09:51:24.000000000 -0600
@@ -280,7 +280,7 @@
 	else
 		sn_rtc_cycles_per_second = ticks_per_sec;
 
-	platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_PCE_VECTOR;
+	platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_CPE_VECTOR;
 
 
 	if ( IS_RUNNING_ON_SIMULATOR() )
--- linux/include/asm-ia64/mca.h	2003-07-27 10:58:27.000000000 -0600
+++ linux/include/asm-ia64/mca.h	2003-07-29 09:53:58.000000000 -0600
@@ -137,7 +137,9 @@
 extern irqreturn_t ia64_mca_rendez_int_handler(int,void *,struct pt_regs *);
 extern irqreturn_t ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
 extern irqreturn_t ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
+extern irqreturn_t ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
 extern irqreturn_t ia64_mca_cpe_int_handler(int,void *,struct pt_regs *);
+extern irqreturn_t ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
 extern int  ia64_log_print(int,prfunc_t);
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
--- linux/include/asm-ia64/hw_irq.h	2003-07-27 11:01:51.000000000 -0600
+++ linux/include/asm-ia64/hw_irq.h	2003-07-29 09:53:10.000000000 -0600
@@ -38,7 +38,9 @@
 /*
  * Vectors 0x10-0x1f are used for low priority interrupts, e.g. CMCI.
  */
-#define IA64_PCE_VECTOR			0x1e	/* platform corrected error interrupt vector */
+#define IA64_CPEP_VECTOR		0x1c	/* corrected platform error polling vector */
+#define IA64_CMCP_VECTOR		0x1d	/* correctable machine-check polling vector */
+#define IA64_CPE_VECTOR			0x1e	/* corrected platform error interrupt vector */
 #define IA64_CMC_VECTOR			0x1f	/* correctable machine-check interrupt vector */
 /*
  * Vectors 0x20-0x2f are reserved for legacy ISA IRQs.
--- linux/include/asm-ia64/sal.h	2003-07-27 11:09:47.000000000 -0600
+++ linux/include/asm-ia64/sal.h	2003-07-29 09:57:15.000000000 -0600
@@ -68,6 +68,13 @@
 	ia64_load_scratch_fpregs(__ia64_scn_fr);	\
 } while (0)
 
+# define SAL_CALL_SAFE(result,args...) do {		\
+	struct ia64_fpreg __ia64_scs_fr[6];		\
+	ia64_save_scratch_fpregs(__ia64_scs_fr);	\
+	__SAL_CALL(result, args);			\
+	ia64_load_scratch_fpregs(__ia64_scs_fr);	\
+} while (0)
+
 #define SAL_SET_VECTORS			0x01000000
 #define SAL_GET_STATE_INFO		0x01000001
 #define SAL_GET_STATE_INFO_SIZE		0x01000002
@@ -665,8 +672,8 @@
 ia64_sal_clear_state_info (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-    SAL_CALL(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, 0,
-             0, 0, 0, 0, 0);
+	SAL_CALL_SAFE(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, 0,
+	              0, 0, 0, 0, 0);
 	return isrv.status;
 }
 
@@ -678,8 +685,8 @@
 ia64_sal_get_state_info (u64 sal_info_type, u64 *sal_info)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
-	         sal_info, 0, 0, 0, 0);
+	SAL_CALL_SAFE(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
+	              sal_info, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 
@@ -694,8 +701,8 @@
 ia64_sal_get_state_info_size (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-    SAL_CALL(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, 0,
-             0, 0, 0, 0, 0);
+	SAL_CALL_SAFE(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, 0,
+	              0, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 	return isrv.v0;
--- linux/arch/ia64/kernel/mca.c	2003-07-31 16:01:44.000000000 -0600
+++ linux/arch/ia64/kernel/mca.c	2003-07-31 16:12:13.000000000 -0600
@@ -97,6 +97,12 @@
 	.name =		"cmc_hndlr"
 };
 
+static struct irqaction cmcp_irqaction = {
+	.handler =	ia64_mca_cmc_int_caller,
+	.flags =	SA_INTERRUPT,
+	.name =		"cmc_poll"
+};
+
 static struct irqaction mca_rdzv_irqaction = {
 	.handler =	ia64_mca_rendez_int_handler,
 	.flags =	SA_INTERRUPT,
@@ -115,6 +121,12 @@
 	.name =		"cpe_hndlr"
 };
 
+static struct irqaction mca_cpep_irqaction = {
+	.handler =	ia64_mca_cpe_int_caller,
+	.flags =	SA_INTERRUPT,
+	.name =		"cpe_poll"
+};
+
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
 #define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
 #define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
@@ -123,12 +135,21 @@
 static struct timer_list cpe_poll_timer;
 static struct timer_list cmc_poll_timer;
 /*
+ * This variable tells whether we are currently in polling mode.
  * Start with this in the wrong state so we won't play w/ timers
  * before the system is ready.
  */
 static int cmc_polling_enabled = 1;
 
 /*
+ * Clearing this variable prevents CPE polling from getting activated
+ * in mca_late_init.  Use it if your system doesn't provide a CPEI,
+ * but encounters problems retrieving CPE logs.  This should only be
+ * necessary for debugging.
+ */
+static int cpe_poll_enabled = 1;
+
+/*
  *  ia64_mca_log_sal_error_record
  *
  *  This function retrieves a specified error record type from SAL, sends it to
@@ -178,6 +199,9 @@
 	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n",
 		       smp_processor_id(), cpe_irq);
 
+	/* SAL spec states this should run w/ interrupts enabled */
+	local_irq_enable();
+
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
 	return IRQ_HANDLED;
@@ -713,10 +737,11 @@
 	IA64_MCA_DEBUG("ia64_mca_init: registered os init handler with SAL\n");
 
 	/*
-	 *  Configure the CMCI vector and handler. Interrupts for CMC are
+	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
 	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
 	 */
 	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
+	register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
 	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP & enable */
 
 	/* Setup the MCA rendezvous interrupt vector */
@@ -1000,6 +1025,9 @@
 	IA64_MCA_DEBUG("ia64_mca_cmc_int_handler: received interrupt vector = %#x on CPU %d\n",
 		       cmc_irq, smp_processor_id());
 
+	/* SAL spec states this should run w/ interrupts enabled */
+	local_irq_enable();
+
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC, 0);
 
@@ -1015,34 +1043,24 @@
 
 		IA64_MCA_DEBUG(KERN_INFO "CMC threshold %d/%d\n", count, CMC_HISTORY_LENGTH);
 		if (count >= CMC_HISTORY_LENGTH) {
-			/*
-			 * CMC threshold exceeded, clear the history
-			 * so we have a fresh start when we return
-			 */
-			for (index = 0 ; index < CMC_HISTORY_LENGTH; index++)
-				cmc_history[index] = 0;
-			index = 0;
 
-			/* Switch to polling mode */
 			cmc_polling_enabled = 1;
+			spin_unlock(&cmc_history_lock);
 
 			/*
-			 * Unlock & enable interrupts  before
-			 * smp_call_function or risk deadlock
+			 * We rely on the local_irq_enable() above so
+			 * that this can't deadlock.
 			 */
-			spin_unlock(&cmc_history_lock);
 			ia64_mca_cmc_vector_disable(NULL);
 
-			local_irq_enable();
-			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 1);
+			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 0);
 
 			/*
 			 * Corrected errors will still be corrected, but
 			 * make sure there's a log somewhere that indicates
 			 * something is generating more than we can handle.
 			 */
-			printk(KERN_WARNING "ia64_mca_cmc_int_handler: WARNING: Switching to polling CMC handler, error records may be lost\n");
-
+			printk(KERN_WARNING "%s: WARNING: Switching to polling CMC handler, error records may be lost\n", __FUNCTION__);
 
 			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
 
@@ -1096,16 +1114,58 @@
 /*
  *  ia64_mca_cmc_int_caller
  *
- * 	Call CMC interrupt handler, only purpose is to have a
- * 	smp_call_function callable entry.
+ * 	Triggered by sw interrupt from CMC polling routine.  Calls
+ * 	real interrupt handler and either triggers a sw interrupt
+ * 	on the next cpu or does cleanup at the end.
  *
- * Inputs   :	dummy(unused)
- * Outputs  :	None
- * */
-static void
-ia64_mca_cmc_int_caller(void *dummy)
+ * Inputs
+ *	interrupt number
+ *	client data arg ptr
+ *	saved registers ptr
+ * Outputs
+ * 	handled
+ */
+irqreturn_t
+ia64_mca_cmc_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	ia64_mca_cmc_int_handler(0, NULL, NULL);
+	static int start_count = -1;
+	unsigned int cpuid;
+
+	cpuid = smp_processor_id();
+
+	/* If first cpu, update count */
+	if (start_count == -1)
+		start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC);
+
+	ia64_mca_cmc_int_handler(cpe_irq, arg, ptregs);
+
+	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+		
+	if (cpuid < NR_CPUS) {
+		platform_send_ipi(cpuid, IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
+	} else {
+		/* If no log recored, switch out of polling mode */
+		if (start_count == IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
+
+			printk(KERN_WARNING "%s: Returning to interrupt driven CMC handler\n", __FUNCTION__);
+
+			cmc_polling_enabled = 0;
+			/*
+			 * The cmc interrupt handler enabled irqs, so
+			 * this can't deadlock.
+			 */
+			smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
+			ia64_mca_cmc_vector_enable(NULL);
+
+		} else {
+
+			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
+		}
+
+		start_count = -1;
+	}
+		
+	return IRQ_HANDLED;
 }
 
 /*
@@ -1120,49 +1180,65 @@
 static void
 ia64_mca_cmc_poll (unsigned long dummy)
 {
-	unsigned long start_count;
-
-	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC);
-
-	/* Call the interrupt handler */
-	smp_call_function(ia64_mca_cmc_int_caller, NULL, 1, 1);
-	local_irq_disable();
-	ia64_mca_cmc_int_caller(NULL);
-	local_irq_enable();
-
-	/*
-	 * If no log recored, switch out of polling mode.
-	 */
-	if (start_count == IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
-		printk(KERN_WARNING "ia64_mca_cmc_poll: Returning to interrupt driven CMC handler\n");
-		cmc_polling_enabled = 0;
-		smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 1);
-		ia64_mca_cmc_vector_enable(NULL);
-	} else {
-		mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
-	}
+	/* Trigger a CMC interrupt cascade  */
+	platform_send_ipi(__ffs(cpu_online_map), IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
 /*
  *  ia64_mca_cpe_int_caller
  *
- * 	Call CPE interrupt handler, only purpose is to have a
- * 	smp_call_function callable entry.
+ * 	Triggered by sw interrupt from CPE polling routine.  Calls
+ * 	real interrupt handler and either triggers a sw interrupt
+ * 	on the next cpu or does cleanup at the end.
  *
- * Inputs   :	dummy(unused)
- * Outputs  :	None
- * */
-static void
-ia64_mca_cpe_int_caller(void *dummy)
+ * Inputs
+ *	interrupt number
+ *	client data arg ptr
+ *	saved registers ptr
+ * Outputs
+ * 	handled
+ */
+irqreturn_t
+ia64_mca_cpe_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	ia64_mca_cpe_int_handler(0, NULL, NULL);
+	static int start_count = -1;
+	static int poll_time = MAX_CPE_POLL_INTERVAL;
+	unsigned int cpuid;
+
+	cpuid = smp_processor_id();
+
+	/* If first cpu, update count */
+	if (start_count == -1)
+		start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);
+
+	ia64_mca_cpe_int_handler(cpe_irq, arg, ptregs);
+
+	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+
+	if (cpuid < NR_CPUS) {
+		platform_send_ipi(cpuid, IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
+	} else {
+		/*
+		 * If a log was recorded, increase our polling frequency,
+		 * otherwise, backoff.
+		 */
+		if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
+			poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time / 2);
+		} else {
+			poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
+		}
+		start_count = -1;
+		mod_timer(&cpe_poll_timer, jiffies + poll_time);
+	}
+
+	return IRQ_HANDLED;
 }
 
 /*
  *  ia64_mca_cpe_poll
  *
- *	Poll for Corrected Platform Errors (CPEs), dynamically adjust
- *	polling interval based on occurrence of an event.
+ *	Poll for Corrected Platform Errors (CPEs), trigger interrupt
+ *	on first cpu, from there it will trickle through all the cpus.
  *
  * Inputs   :   dummy(unused)
  * Outputs  :   None
@@ -1171,27 +1248,8 @@
 static void
 ia64_mca_cpe_poll (unsigned long dummy)
 {
-	unsigned long start_count;
-	static int poll_time = MAX_CPE_POLL_INTERVAL;
-
-	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);
-
-	/* Call the interrupt handler */
-	smp_call_function(ia64_mca_cpe_int_caller, NULL, 1, 1);
-	local_irq_disable();
-	ia64_mca_cpe_int_caller(NULL);
-	local_irq_enable();
-
-	/*
-	 * If a log was recorded, increase our polling frequency,
-	 * otherwise, backoff.
-	 */
-	if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
-		poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time/2);
-	} else {
-		poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
-	}
-	mod_timer(&cpe_poll_timer, jiffies + poll_time);
+	/* Trigger a CPE interrupt cascade  */
+	platform_send_ipi(__ffs(cpu_online_map), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
 /*
@@ -1217,8 +1275,10 @@
 	cpe_poll_timer.function = ia64_mca_cpe_poll;
 
 	/* If platform doesn't support CPEI, get the timer going. */
-	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0)
+	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0 && cpe_poll_enabled) {
+		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
 		ia64_mca_cpe_poll(0UL);
+	}
 
 	return 0;
 }
@@ -2326,3 +2386,12 @@
 	}
 	return platform_err;
 }
+
+static int __init
+ia64_mca_disable_cpe_polling(char *str)
+{
+	cpe_poll_enabled = 0;
+	return 1;
+}
+
+__setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);

--------------4956790ACE5AD555316B1A01
Content-Type: text/plain; charset=us-ascii;
 name="linux-2.4.21-ia64-cmc_cpe.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-ia64-cmc_cpe.diff"

--- linux/arch/ia64/kernel/iosapic.c	2003-07-29 15:41:15.000000000 -0600
+++ linux/arch/ia64/kernel/iosapic.c	2003-07-29 15:55:51.000000000 -0600
@@ -530,7 +530,7 @@
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:
-		vector = IA64_PCE_VECTOR;
+		vector = IA64_CPE_VECTOR;
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		break;
 	      default:
--- linux/arch/ia64/sn/kernel/setup.c	2003-07-29 15:41:17.000000000 -0600
+++ linux/arch/ia64/sn/kernel/setup.c	2003-07-29 15:55:51.000000000 -0600
@@ -277,7 +277,7 @@
 	else
 		sn_rtc_cycles_per_second = ticks_per_sec;
 
-	platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_PCE_VECTOR;
+	platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_CPE_VECTOR;
 
 
 	if ( IS_RUNNING_ON_SIMULATOR() )
--- linux/include/asm-ia64/mca.h	2003-07-29 15:41:22.000000000 -0600
+++ linux/include/asm-ia64/mca.h	2003-07-30 08:29:00.000000000 -0600
@@ -132,7 +132,9 @@
 extern void ia64_mca_rendez_int_handler(int,void *,struct pt_regs *);
 extern void ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
 extern void ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
+extern void ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
 extern void ia64_mca_cpe_int_handler(int,void *,struct pt_regs *);
+extern void ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
 extern int  ia64_log_print(int,prfunc_t);
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
--- linux/include/asm-ia64/hw_irq.h	2002-11-28 16:53:15.000000000 -0700
+++ linux/include/asm-ia64/hw_irq.h	2003-07-29 16:28:17.000000000 -0600
@@ -37,7 +37,9 @@
 /*
  * Vectors 0x10-0x1f are used for low priority interrupts, e.g. CMCI.
  */
-#define IA64_PCE_VECTOR			0x1e	/* platform corrected error interrupt vector */
+#define IA64_CPEP_VECTOR		0x1c	/* corrected platform error polling vector */
+#define IA64_CMCP_VECTOR		0x1d	/* correctable machine-check polling vector */
+#define IA64_CPE_VECTOR			0x1e	/* corrected platform error interrupt vector */
 #define IA64_CMC_VECTOR			0x1f	/* correctable machine-check interrupt vector */
 /*
  * Vectors 0x20-0x2f are reserved for legacy ISA IRQs.
--- linux/include/asm-ia64/sal.h	2003-07-29 15:41:23.000000000 -0600
+++ linux/include/asm-ia64/sal.h	2003-07-30 08:28:35.000000000 -0600
@@ -56,6 +56,13 @@
 	ia64_load_scratch_fpregs(__ia64_scn_fr);	\
 } while (0)
 
+# define SAL_CALL_SAFE(result,args...) do {		\
+	struct ia64_fpreg __ia64_scs_fr[6];		\
+	ia64_save_scratch_fpregs(__ia64_scs_fr);	\
+	__SAL_CALL(result, args);			\
+	ia64_load_scratch_fpregs(__ia64_scs_fr);	\
+} while (0)
+
 #define SAL_SET_VECTORS			0x01000000
 #define SAL_GET_STATE_INFO		0x01000001
 #define SAL_GET_STATE_INFO_SIZE		0x01000002
@@ -658,8 +665,8 @@
 ia64_sal_clear_state_info (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-    SAL_CALL(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, 0,
-             0, 0, 0, 0, 0);
+	SAL_CALL_SAFE(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, 0,
+	              0, 0, 0, 0, 0);
 	return isrv.status;
 }
 
@@ -671,8 +678,8 @@
 ia64_sal_get_state_info (u64 sal_info_type, u64 *sal_info)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
-	         sal_info, 0, 0, 0, 0);
+	SAL_CALL_SAFE(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
+	              sal_info, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 
@@ -687,8 +694,8 @@
 ia64_sal_get_state_info_size (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-    SAL_CALL(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, 0,
-             0, 0, 0, 0, 0);
+	SAL_CALL_SAFE(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, 0,
+	              0, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 	return isrv.v0;
--- linux/arch/ia64/kernel/mca.c	2003-07-31 16:15:16.000000000 -0600
+++ linux/arch/ia64/kernel/mca.c	2003-07-31 16:10:36.000000000 -0600
@@ -99,6 +99,12 @@
 	.name =		"cmc_hndlr"
 };
 
+static struct irqaction cmcp_irqaction = {
+	.handler =	ia64_mca_cmc_int_caller,
+	.flags =	SA_INTERRUPT,
+	.name =		"cmc_poll"
+};
+
 static struct irqaction mca_rdzv_irqaction = {
 	.handler =	ia64_mca_rendez_int_handler,
 	.flags =	SA_INTERRUPT,
@@ -117,6 +123,12 @@
 	.name =		"cpe_hndlr"
 };
 
+static struct irqaction mca_cpep_irqaction = {
+	.handler =	ia64_mca_cpe_int_caller,
+	.flags =	SA_INTERRUPT,
+	.name =		"cpe_poll"
+};
+
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
 #define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
 #define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
@@ -125,11 +137,20 @@
 static struct timer_list cpe_poll_timer;
 static struct timer_list cmc_poll_timer;
 /*
+ * This variable tells whether we are currently in polling mode.
  * Start with this in the wrong state so we won't play w/ timers
  * before the system is ready.
  */
 static int cmc_polling_enabled = 1;
 
+/*
+ * Clearing this variable prevents CPE polling from getting activated
+ * in mca_late_init.  Use it if your system doesn't provide a CPEI,
+ * but encounters problems retrieving CPE logs.  This should only be
+ * necessary for debugging.
+ */
+static int cpe_poll_enabled = 1;
+
 extern void salinfo_log_wakeup(int);
 
 /*
@@ -179,6 +200,9 @@
 	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n",
 		       smp_processor_id(), cpe_irq);
 
+	/* SAL spec states this should run w/ interrupts enabled */
+	local_irq_enable();
+
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
 }
@@ -704,10 +728,11 @@
 	IA64_MCA_DEBUG("ia64_mca_init: registered os init handler with SAL\n");
 
 	/*
-	 *  Configure the CMCI vector and handler. Interrupts for CMC are
+	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
 	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
 	 */
 	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
+	register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
 	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP & enable */
 
 	/* Setup the MCA rendezvous interrupt vector */
@@ -987,6 +1012,9 @@
 	IA64_MCA_DEBUG("ia64_mca_cmc_int_handler: received interrupt vector = %#x on CPU %d\n",
 		       cmc_irq, smp_processor_id());
 
+	/* SAL spec states this should run w/ interrupts enabled */
+	local_irq_enable();
+
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC, 0);
 
@@ -1002,34 +1030,23 @@
 
 		IA64_MCA_DEBUG(KERN_INFO "CMC threshold %d/%d\n", count, CMC_HISTORY_LENGTH);
 		if (count >= CMC_HISTORY_LENGTH) {
-			/*
-			 * CMC threshold exceeded, clear the history
-			 * so we have a fresh start when we return
-			 */
-			for (index = 0 ; index < CMC_HISTORY_LENGTH; index++)
-				cmc_history[index] = 0;
-			index = 0;
 
-			/* Switch to polling mode */
 			cmc_polling_enabled = 1;
+			spin_unlock(&cmc_history_lock);
 
 			/*
-			 * Unlock & enable interrupts  before
-			 * smp_call_function or risk deadlock
+			 * We rely on the local_irq_enable() above so
+			 * that this can't deadlock.
 			 */
-			spin_unlock(&cmc_history_lock);
 			ia64_mca_cmc_vector_disable(NULL);
-
-			local_irq_enable();
-			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 1);
+			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 0);
 
 			/*
 			 * Corrected errors will still be corrected, but
 			 * make sure there's a log somewhere that indicates
 			 * something is generating more than we can handle.
 			 */
-			printk(KERN_WARNING "ia64_mca_cmc_int_handler: WARNING: Switching to polling CMC handler, error records may be lost\n");
-			
+			printk(KERN_WARNING "%s: WARNING: Switching to polling CMC handler, error records may be lost\n", __FUNCTION__);
 
 			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
 
@@ -1082,16 +1099,56 @@
 /*
  *  ia64_mca_cmc_int_caller
  *
- * 	Call CMC interrupt handler, only purpose is to have a
- * 	smp_call_function callable entry.
+ * 	Triggered by sw interrupt from CMC polling routine.  Calls
+ * 	real interrupt handler and either triggers a sw interrupt
+ * 	on the next cpu or does cleanup at the end.
  *
- * Inputs   :	dummy(unused)
- * Outputs  :	None
- * */
-static void
-ia64_mca_cmc_int_caller(void *dummy)
+ * Inputs
+ *	interrupt number
+ *	client data arg ptr
+ *	saved registers ptr
+ * Outputs
+ *	None
+ */
+void
+ia64_mca_cmc_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	ia64_mca_cmc_int_handler(0, NULL, NULL);
+	static int start_count = -1;
+	unsigned int cpuid;
+
+	cpuid = smp_processor_id();
+
+	/* If first cpu, update count */
+	if (start_count == -1)
+		start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC);
+
+	ia64_mca_cmc_int_handler(cpe_irq, arg, ptregs);
+
+	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+		
+	if (cpuid < NR_CPUS) {
+		platform_send_ipi(cpuid, IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
+	} else {
+		/* If no log recored, switch out of polling mode */
+		if (start_count == IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
+
+			printk(KERN_WARNING "%s: Returning to interrupt driven CMC handler\n", __FUNCTION__);
+
+			cmc_polling_enabled = 0;
+			/*
+			 * The cmc interrupt handler enabled irqs, so
+			 * this can't deadlock.
+			 */
+			smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
+			ia64_mca_cmc_vector_enable(NULL);
+
+		} else {
+
+			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
+		}
+
+		start_count = -1;
+	}
 }
 
 /*
@@ -1106,49 +1164,63 @@
 static void
 ia64_mca_cmc_poll (unsigned long dummy)
 {
-	int start_count;
-
-	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC);
-
-	/* Call the interrupt handler */
-	smp_call_function(ia64_mca_cmc_int_caller, NULL, 1, 1);
-	local_irq_disable();
-	ia64_mca_cmc_int_caller(NULL);
-	local_irq_enable();
-
-	/*
-	 * If no log recored, switch out of polling mode.
-	 */
-	if (start_count == IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
-		printk(KERN_WARNING "ia64_mca_cmc_poll: Returning to interrupt driven CMC handler\n");
-		cmc_polling_enabled = 0;
-		smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 1);
-		ia64_mca_cmc_vector_enable(NULL);
-	} else {
-		mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
-	}
+	/* Trigger a CMC interrupt cascade  */
+	platform_send_ipi(__ffs(cpu_online_map), IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
 /*
  *  ia64_mca_cpe_int_caller
  *
- * 	Call CPE interrupt handler, only purpose is to have a
- * 	smp_call_function callable entry.
+ * 	Triggered by sw interrupt from CPE polling routine.  Calls
+ * 	real interrupt handler and either triggers a sw interrupt
+ * 	on the next cpu or does cleanup at the end.
  *
- * Inputs   :	dummy(unused)
- * Outputs  :	None
- * */
-static void
-ia64_mca_cpe_int_caller(void *dummy)
+ * Inputs
+ *	interrupt number
+ *	client data arg ptr
+ *	saved registers ptr
+ * Outputs
+ *	None
+ */
+void
+ia64_mca_cpe_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	ia64_mca_cpe_int_handler(0, NULL, NULL);
+	static int start_count = -1;
+	static int poll_time = MAX_CPE_POLL_INTERVAL;
+	unsigned int cpuid;
+
+	cpuid = smp_processor_id();
+
+	/* If first cpu, update count */
+	if (start_count == -1)
+		start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);
+
+	ia64_mca_cpe_int_handler(cpe_irq, arg, ptregs);
+
+	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+
+	if (cpuid < NR_CPUS) {
+		platform_send_ipi(cpuid, IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
+	 } else {
+		/*
+		 * If a log was recorded, increase our polling frequency,
+		 * otherwise, backoff.
+		 */
+		if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
+			poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time / 2);
+		} else {
+			poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
+		}
+		start_count = -1;
+		mod_timer(&cpe_poll_timer, jiffies + poll_time);
+	}
 }
 
 /*
  *  ia64_mca_cpe_poll
  *
- *	Poll for Corrected Platform Errors (CPEs), dynamically adjust
- *	polling interval based on occurance of an event.
+ *	Poll for Corrected Platform Errors (CPEs), trigger interrupt
+ *	on first cpu, from there it will trickle through all the cpus.
  *
  * Inputs   :   dummy(unused)
  * Outputs  :   None
@@ -1157,27 +1230,8 @@
 static void
 ia64_mca_cpe_poll (unsigned long dummy)
 {
-	int start_count;
-	static int poll_time = MAX_CPE_POLL_INTERVAL;
-
-	start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CPE);
-
-	/* Call the interrupt handler */
-	smp_call_function(ia64_mca_cpe_int_caller, NULL, 1, 1);
-	local_irq_disable();
-	ia64_mca_cpe_int_caller(NULL);
-	local_irq_enable();
-
-	/*
-	 * If a log was recorded, increase our polling frequency,
-	 * otherwise, backoff.
-	 */
-	if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
-		poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time/2);
-	} else {
-		poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
-	}
-	mod_timer(&cpe_poll_timer, jiffies + poll_time);
+	/* Trigger a CPE interrupt cascade  */
+	platform_send_ipi(__ffs(cpu_online_map), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
 /*
@@ -1203,8 +1257,10 @@
 	cpe_poll_timer.function = ia64_mca_cpe_poll;
 
 	/* If platform doesn't support CPEI, get the timer going. */
-	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0)
+	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0 && cpe_poll_enabled) {
+		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
 		ia64_mca_cpe_poll(0UL);
+	}
 
 	return 0;
 }
@@ -2319,3 +2375,12 @@
 	}
 	return platform_err;
 }
+
+static int __init
+ia64_mca_disable_cpe_polling(char *str)
+{
+	cpe_poll_enabled = 0;
+	return 1;
+}
+
+__setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);
--- linux/include/asm-ia64/bitops.h	2003-07-29 15:41:22.000000000 -0600
+++ linux/include/asm-ia64/bitops.h	2003-07-29 16:24:39.000000000 -0600
@@ -282,6 +282,21 @@
 	return result;
 }
 
+/**
+ * __ffs - find first bit in word.
+ * @x: The word to search
+ *
+ * Undefined if no bit exists, so code should check against 0 first.
+ */
+static __inline__ unsigned long
+__ffs (unsigned long x)
+{
+	unsigned long result;
+
+	__asm__ ("popcnt %0=%1" : "=r" (result) : "r" ((x - 1) & ~x));
+	return result;
+}
+
 #ifdef __KERNEL__
 
 /*

--------------4956790ACE5AD555316B1A01--


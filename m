From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 02 Mar 2004 02:21:53 +0000
Subject: [PATCH] CPE trigger-switching by threshold
Message-Id: <0HTX0044UFWGF7@fjmail505.fjmail.jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Like CMC, is it better to implement a trigger-switching between
interrupt and poll for CPE?


Thanks,

H.Seto


--- linux-2.6.3/arch/ia64/kernel/mca.c	2004-02-19 18:36:08.000000000 +0900
+++ linux-2.6.3/arch/ia64/kernel/mca+cpe_poll.c	2004-03-02 10:22:09.272642488 +0900
@@ -110,6 +110,7 @@
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
 #define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
 #define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
+#define CPE_HISTORY_LENGTH    5
 #define CMC_HISTORY_LENGTH    5
 
 static struct timer_list cpe_poll_timer;
@@ -272,14 +273,55 @@
 static irqreturn_t
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("%s: received interrupt. CPU:%d vector = %#x\n",
-		       __FUNCTION__, smp_processor_id(), cpe_irq);
+	static unsigned long	cpe_history[CPE_HISTORY_LENGTH];
+	static int		index;
+	static spinlock_t	cpe_history_lock = SPIN_LOCK_UNLOCKED;
+
+	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
+		       __FUNCTION__, cpe_irq, smp_processor_id());
 
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
 
-	/* Get the CMC error record and log it */
+	/* Get the CPE error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
+
+	spin_lock(&cpe_history_lock);
+	if (!cpe_poll_enabled && acpi_request_vector(ACPI_INTERRUPT_CPEI)) {
+
+		int i, count = 1; /* we know 1 happened now */
+		unsigned long now = jiffies;
+
+		for (i = 0; i < CPE_HISTORY_LENGTH; i++) {
+			if (now - cpe_history[i] <= HZ)
+				count++;
+		}
+
+		IA64_MCA_DEBUG(KERN_INFO "CPE threshold %d/%d\n", count, CPE_HISTORY_LENGTH);
+		if (count >= CPE_HISTORY_LENGTH) {
+
+			cpe_poll_enabled = 1;
+			spin_unlock(&cpe_history_lock);
+			disable_irq_nosync(local_vector_to_irq(IA64_CPE_VECTOR));
+
+			/*
+			 * Corrected errors will still be corrected, but
+			 * make sure there's a log somewhere that indicates
+			 * something is generating more than we can handle.
+			 */
+			printk(KERN_WARNING "WARNING: Switching to polling CPE handler; error records may be lost\n");
+
+			mod_timer(&cpe_poll_timer, jiffies + MIN_CPE_POLL_INTERVAL);
+
+			/* lock already released, get out now */
+			return IRQ_HANDLED;
+		} else {
+			cpe_history[index++] = now;
+			if (index = CPE_HISTORY_LENGTH)
+				index = 0;
+		}
+	}
+	spin_unlock(&cpe_history_lock);
 	return IRQ_HANDLED;
 }
 
@@ -903,7 +945,7 @@
  * 	handled
  */
 static irqreturn_t
-ia64_mca_cmc_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
+ia64_mca_cmc_int_caller(int cmc_irq, void *arg, struct pt_regs *ptregs)
 {
 	static int start_count = -1;
 	unsigned int cpuid;
@@ -914,7 +956,7 @@
 	if (start_count = -1)
 		start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC);
 
-	ia64_mca_cmc_int_handler(cpe_irq, arg, ptregs);
+	ia64_mca_cmc_int_handler(cmc_irq, arg, ptregs);
 
 	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
 
@@ -973,7 +1015,7 @@
 ia64_mca_cpe_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
 	static int start_count = -1;
-	static int poll_time = MAX_CPE_POLL_INTERVAL;
+	static int poll_time = MIN_CPE_POLL_INTERVAL;
 	unsigned int cpuid;
 
 	cpuid = smp_processor_id();
@@ -991,15 +1033,23 @@
 	} else {
 		/*
 		 * If a log was recorded, increase our polling frequency,
-		 * otherwise, backoff.
+		 * otherwise, backoff or return to interrupt mode.
 		 */
 		if (start_count != IA64_LOG_COUNT(SAL_INFO_TYPE_CPE)) {
 			poll_time = max(MIN_CPE_POLL_INTERVAL, poll_time / 2);
-		} else {
+		} else if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0) {
 			poll_time = min(MAX_CPE_POLL_INTERVAL, poll_time * 2);
+		} else {
+			poll_time = MIN_CPE_POLL_INTERVAL;
+
+			printk(KERN_WARNING "Returning to interrupt driven CPE handler\n");
+			enable_irq(local_vector_to_irq(IA64_CPE_VECTOR));
+			cpe_poll_enabled = 0;
 		}
+
+		if (cpe_poll_enabled)
+			mod_timer(&cpe_poll_timer, jiffies + poll_time);
 		start_count = -1;
-		mod_timer(&cpe_poll_timer, jiffies + poll_time);
 	}
 
 	return IRQ_HANDLED;
@@ -1242,7 +1292,7 @@
 	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, &mca_wkup_irqaction);
 
 #ifdef CONFIG_ACPI
-	/* Setup the CPE interrupt vector */
+	/* Setup the CPEI/P vector and handler */
 	{
 		irq_desc_t *desc;
 		unsigned int irq;
@@ -1258,6 +1308,7 @@
 				}
 			ia64_mca_register_cpev(cpev);
 		}
+		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
 	}
 #endif
 
@@ -1298,7 +1349,6 @@
 #ifdef CONFIG_ACPI
 	/* If platform doesn't support CPEI, get the timer going. */
 	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0 && cpe_poll_enabled) {
-		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
 		ia64_mca_cpe_poll(0UL);
 	}
 #endif


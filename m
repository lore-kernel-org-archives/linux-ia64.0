From: Alex Williamson <alex_williamson@hp.com>
Date: Tue, 12 Nov 2002 20:27:20 +0000
Subject: [Linux-ia64] [PATCH] Polling for Corrected Platform Errors
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------A8FBA3DFA326558CEAA1A7DA"
Message-Id: <marc-linux-ia64-105590709805405@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------A8FBA3DFA326558CEAA1A7DA
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


  Attached is a patch that adds a fallback polling mechanism for
retrieving CPE logs from firmware.  The code makes an attempt to
determine if CPEs are happening and adjust the polling interval
accordingly.  On a system that's not getting CPEs, it should
poll every 15 minutes, so should have no performance impact.

   HP zx1 systems do not support an interrupt driven CPE notifier,
so polling is required to get these logs.  Comments?  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------A8FBA3DFA326558CEAA1A7DA
Content-Type: text/plain; charset=us-ascii;
 name="cpe_polling.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cpe_polling.diff"

--- arch/ia64/kernel/mca.c	23 Sep 2002 22:38:11 -0000	1.5
+++ arch/ia64/kernel/mca.c	12 Nov 2002 20:03:09 -0000
@@ -42,6 +42,9 @@
 #include <linux/smp_lock.h>
 #include <linux/bootmem.h>
 #include <linux/acpi.h>
+#include <linux/timer.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -105,6 +108,11 @@ static struct irqaction mca_cpe_irqactio
 	name:       "cpe_hndlr"
 };
 
+#define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
+#define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
+
+static struct timer_list cpe_poll_timer;
+
 /*
  *  ia64_mca_log_sal_error_record
  *
@@ -510,8 +518,7 @@ ia64_mca_init(void)
 					setup_irq(irq, &mca_cpe_irqaction);
 				}
 			ia64_mca_register_cpev(cpev);
-		} else
-			printk("ia64_mca_init: Failed to get routed CPEI vector from ACPI.\n");
+		}
 	}
 
 	/* Initialize the areas set aside by the OS to buffer the
@@ -803,6 +810,62 @@ static ia64_state_log_t ia64_state_log[I
 #define IA64_LOG_CURR_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
 
 /*
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
+	int start_index;
+	static int poll_time = MAX_CPE_POLL_INTERVAL;
+
+	start_index = IA64_LOG_CURR_INDEX(SAL_INFO_TYPE_CPE);
+
+	/* Call the interrupt handler */
+	ia64_mca_cpe_int_handler(0, NULL, NULL);
+
+	/*
+	 * If a log was recorded, increase our polling frequency,
+	 * otherwise, backoff.
+	 */
+	if (start_index != IA64_LOG_CURR_INDEX(SAL_INFO_TYPE_CPE)) {
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
+	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0) {
+		init_timer(&cpe_poll_timer);
+		cpe_poll_timer.function = ia64_mca_cpe_poll;
+		ia64_mca_cpe_poll(0);
+	}
+	return 0;
+}
+
+module_init(ia64_mca_late_init);
+
+/*
  * C portion of the OS INIT handler
  *
  * Called from ia64_monarch_init_handler
@@ -962,7 +1025,6 @@ ia64_log_get(int sal_info_type, prfunc_t
 		return total_len;
 	} else {
 		IA64_LOG_UNLOCK(sal_info_type);
-		prfunc("ia64_log_get: No SAL error record available for type %d\n", sal_info_type);
 		return 0;
 	}
 }

--------------A8FBA3DFA326558CEAA1A7DA--



From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 20 Dec 2003 00:04:14 +0000
Subject: RE: [patch] 2.6.0 MCA TLB error recovery
Message-Id: <marc-linux-ia64-107187879424994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107181047921141@msgid-missing>
In-Reply-To: <marc-linux-ia64-107181047921141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> I didn't keep the old patches around.  Could you and Keith send me a
> consistent set of patches?  That would help me.
> 

Keith's second fix:

From: linux-ia64-owner@vger.kernel.org on behalf of Keith Owens
[kaos@sgi.com]
Sent: Sunday, December 07, 2003 10:25 PM
To: Alex Williamson
Cc: linux-ia64@vger.kernel.org
Subject: Re: [patch] 2.4.23 fix deadlock in ia64_mca_cmc_int_caller 

On Sun, 07 Dec 2003 22:30:00 -0700, 
Alex Williamson <alex.williamson@hp.com> wrote:
>   Looks good to me, only comment I have would be to tack the below
>chunk into ia64_mca_late_init().

Duh, how did I miss ia64_mca_init?  Take 2.

smp_call_function() must not be called from interrupt context (can
deadlock on tasklist_lock).  Use keventd to call smp_call_function().

Index: 23.5/arch/ia64/kernel/mca.c
--- 23.5/arch/ia64/kernel/mca.c Tue, 18 Nov 2003 16:26:06 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.5 644)
+++ 23.5(w)/arch/ia64/kernel/mca.c Mon, 08 Dec 2003 17:23:55 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.5 644)
@@ -36,6 +36,10 @@
  *                      SAL 3.0 spec.
  * 00/03/29 C. Fleckenstein  Fixed PAL/SAL update issues, began MCA bug fixes, logging issues,
  *                           added min save state dump, added INIT handler.
+ *
+ * 2003-12-08 Keith Owens <kaos@sgi.com>
+ *            smp_call_function() must not be called from interrupt context (can
+ *            deadlock on tasklist_lock).  Use keventd to call smp_call_function().
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -50,6 +54,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/smp.h>
+#include <linux/tqueue.h>
 
 #include <asm/delay.h>
 #include <asm/machvec.h>
@@ -154,6 +159,8 @@ static int cpe_poll_enabled = 1;
 
 extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size);
 
+static struct tq_struct	cmc_disable_tq, cmc_enable_tq;
+
 /*
  *  ia64_mca_log_sal_error_record
  *
@@ -626,6 +633,36 @@ verify_guid (efi_guid_t *test, efi_guid_
 }
 
 /*
+ * ia64_mca_cmc_vector_disable_keventd
+ *
+ * Called via keventd (smp_call_function() is not safe in interrupt context) to
+ * disable the cmc interrupt vector.
+ *
+ * Note: needs preempt_disable() if you apply the preempt patch to 2.4.
+ */
+static void
+ia64_mca_cmc_vector_disable_keventd(void *unused)
+{
+	ia64_mca_cmc_vector_disable(NULL);
+	smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 0);
+}
+
+/*
+ * ia64_mca_cmc_vector_enable_keventd
+ *
+ * Called via keventd (smp_call_function() is not safe in interrupt context) to
+ * enable the cmc interrupt vector.
+ *
+ * Note: needs preempt_disable() if you apply the preempt patch to 2.4.
+ */
+static void
+ia64_mca_cmc_vector_enable_keventd(void *unused)
+{
+	smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
+	ia64_mca_cmc_vector_enable(NULL);
+}
+
+/*
  * ia64_mca_init
  *
  *  Do all the system level mca specific initialization.
@@ -658,6 +695,9 @@ ia64_mca_init(void)
 
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
+	INIT_TQUEUE(&cmc_disable_tq, ia64_mca_cmc_vector_disable_keventd, NULL);
+	INIT_TQUEUE(&cmc_enable_tq, ia64_mca_cmc_vector_enable_keventd, NULL);
+
 	/* initialize recovery success indicator */
 	ia64_os_mca_recovery_successful = 0;
 
@@ -1062,14 +1102,7 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 
 			cmc_polling_enabled = 1;
 			spin_unlock(&cmc_history_lock);
-
-			/*
-			 * We rely on the local_irq_enable() above so
-			 * that this can't deadlock.
-			 */
-			ia64_mca_cmc_vector_disable(NULL);
-
-			smp_call_function(ia64_mca_cmc_vector_disable, NULL, 1, 0);
+			schedule_task(&cmc_disable_tq);
 
 			/*
 			 * Corrected errors will still be corrected, but
@@ -1163,19 +1196,7 @@ ia64_mca_cmc_int_caller(int cpe_irq, voi
 		if (start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
 
 			printk(KERN_WARNING "%s: Returning to interrupt driven CMC handler\n", __FUNCTION__);
-
-			/*
-			 * The cmc interrupt handler enabled irqs, so
-			 * this can't deadlock.
-			 */
-			smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
-
-			/*
-			 * Turn off interrupts before re-enabling the
-			 * cmc vector locally.  Make sure we get out.
-			 */
-			local_irq_disable();
-			ia64_mca_cmc_vector_enable(NULL);
+			schedule_task(&cmc_enable_tq);
 			cmc_polling_enabled = 0;
 
 		} else {

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Keith Owens <kaos@sgi.com>
Date: Mon, 02 Feb 2004 07:02:33 +0000
Subject: Subject: [patch] 1/5 2.4.25-pre7 mca.c cleanup - Avoid deadlock when using printk() for MCA and INIT
Message-Id: <6735.1075705353@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Avoid deadlock when using printk() for MCA and INIT records.

Index: 25-pre7.3/arch/ia64/kernel/mca.c
--- 25-pre7.3/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 14:21:30 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.6 644)
+++ 25-pre7.4/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 16:38:33 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.7 644)
@@ -18,7 +18,7 @@
  * Copyright (C) 2000 Intel
  * Copyright (C) Chuck Fleckenstein (cfleck@co.intel.com)
  *
- * Copyright (C) 1999 Silicon Graphics, Inc.
+ * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander(vijay@engr.sgi.com)
  *
  * 03/04/15 D. Mosberger Added INIT backtrace support.
@@ -40,6 +40,9 @@
  * 2003-12-08 Keith Owens <kaos@sgi.com>
  *            smp_call_function() must not be called from interrupt context (can
  *            deadlock on tasklist_lock).  Use keventd to call smp_call_function().
+ *
+ * 2004-02-01 Keith Owens <kaos@sgi.com>
+ *            Avoid deadlock when using printk() for MCA and INIT records.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -163,37 +166,34 @@ static struct tq_struct	cmc_disable_tq, 
 /*
  *  ia64_mca_log_sal_error_record
  *
- *  This function retrieves a specified error record type from SAL,
- *  wakes up any processes waiting for error records, and sends it to
- *  the system log.
+ *  This function retrieves a specified error record type from SAL
+ *  and wakes up any processes waiting for error records.
  *
  *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE/INIT)
- *  Outputs :   platform error status
+ *  		called_from_init (1 for boot processing)
  */
-int
+static void
 ia64_mca_log_sal_error_record(int sal_info_type, int called_from_init)
 {
 	u8 *buffer;
 	u64 size;
-	int platform_err;
+	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
+	static const char * const rec_name[] = { "MCA", "INIT", "CMC", "CPE" };
 
 	size = ia64_log_get(sal_info_type, &buffer);
 	if (!size)
-		return 0;
-
-	/* TODO:
-	 * 1. analyze error logs to determine recoverability
-	 * 2. perform error recovery procedures, if applicable
-	 * 3. set ia64_os_mca_recovery_successful flag, if applicable
-	 */
+		return;
 
 	salinfo_log_wakeup(sal_info_type, buffer, size);
-	platform_err = ia64_log_print(sal_info_type, (prfunc_t)printk);
+
+	if (irq_safe || called_from_init)
+		printk(KERN_INFO "CPU %d: SAL log contains %s error record\n",
+			smp_processor_id(),
+			sal_info_type < ARRAY_SIZE(rec_name) ? rec_name[sal_info_type] : "UNKNOWN");
+
 	/* Clear logs from corrected errors in case there's no user-level logger */
 	if (sal_info_type = SAL_INFO_TYPE_CPE || sal_info_type = SAL_INFO_TYPE_CMC)
 		ia64_sal_clear_state_info(sal_info_type);
-
-	return platform_err;
 }
 
 /*
@@ -1024,16 +1024,8 @@ ia64_return_to_sal_check(void)
 void
 ia64_mca_ucmc_handler(void)
 {
-	int platform_err = 0;
-
 	/* Get the MCA error record and log it */
-	platform_err = ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 0);
-
-	/*
-	 *  Do Platform-specific mca error handling if required.
-	 */
-	if (platform_err)
-		mca_handler_platform();
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 0);
 
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
@@ -1328,6 +1320,8 @@ ia64_init_handler (struct pt_regs *pt, s
 {
 	pal_min_state_area_t *ms;
 
+	oops_in_progress = 1;	/* avoid deadlock in printk, but it makes recovery dodgy */
+
 	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx\n",
 		ia64_sal_to_os_handoff_state.proc_state_param);
 
@@ -1442,6 +1436,7 @@ ia64_log_get(int sal_info_type, u8 **buf
 	sal_log_record_header_t     *log_buffer;
 	u64                         total_len = 0;
 	int                         s;
+	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
 
 	IA64_LOG_LOCK(sal_info_type);
 
@@ -1453,8 +1448,10 @@ ia64_log_get(int sal_info_type, u8 **buf
 	if (total_len) {
 		IA64_LOG_INDEX_INC(sal_info_type);
 		IA64_LOG_UNLOCK(sal_info_type);
-		IA64_MCA_DEBUG("ia64_log_get: SAL error record type %d retrieved. "
-			       "Record length = %ld\n", sal_info_type, total_len);
+		if (irq_safe) {
+			IA64_MCA_DEBUG("ia64_log_get: SAL error record type %d retrieved. "
+				       "Record length = %ld\n", sal_info_type, total_len);
+		}
 		*buffer = (u8 *) log_buffer;
 		return total_len;
 	} else {



From: Keith Owens <kaos@sgi.com>
Date: Fri, 13 Feb 2004 00:33:47 +0000
Subject: [patch] 2.6.3-rc2 Delete redundant ia64_mca_check_errors
Message-Id: <2568.1076632427@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

salinfo automatically processes all record types on all cpus at boot
time, ia64_mca_check_errors is now redundant.  This also removes the
need for a called_from_init flag on ia64_mca_log_sal_error_record.

Index: 3-rc2.4/include/asm-ia64/mca.h
--- 3-rc2.4/include/asm-ia64/mca.h Thu, 12 Feb 2004 12:43:26 +1100 kaos (linux-2.6/V/b/0_mca.h 1.1.1.1.2.1 644)
+++ 3-rc2.4(w)/include/asm-ia64/mca.h Fri, 13 Feb 2004 10:59:13 +1100 kaos (linux-2.6/V/b/0_mca.h 1.1.1.1.2.1 644)
@@ -114,7 +114,6 @@ extern void ia64_mca_ucmc_handler(void);
 extern void ia64_monarch_init_handler(void);
 extern void ia64_slave_init_handler(void);
 extern void ia64_mca_cmc_vector_setup(void);
-extern int  ia64_mca_check_errors(void);
 
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_MCA_H */
Index: 3-rc2.4/arch/ia64/kernel/mca.c
--- 3-rc2.4/arch/ia64/kernel/mca.c Thu, 12 Feb 2004 12:43:26 +1100 kaos (linux-2.6/Z/c/43_mca.c 1.1.1.1.2.1 644)
+++ 3-rc2.4(w)/arch/ia64/kernel/mca.c Fri, 13 Feb 2004 11:14:34 +1100 kaos (linux-2.6/Z/c/43_mca.c 1.1.1.1.2.1 644)
@@ -239,10 +239,9 @@ ia64_log_get(int sal_info_type, u8 **buf
  *  and wakes up any processes waiting for error records.
  *
  *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE/INIT)
- *  		called_from_init (1 for boot processing)
  */
 static void
-ia64_mca_log_sal_error_record(int sal_info_type, int called_from_init)
+ia64_mca_log_sal_error_record(int sal_info_type)
 {
 	u8 *buffer;
 	u64 size;
@@ -255,7 +254,7 @@ ia64_mca_log_sal_error_record(int sal_in
 
 	salinfo_log_wakeup(sal_info_type, buffer, size, irq_safe);
 
-	if (irq_safe || called_from_init)
+	if (irq_safe)
 		printk(KERN_INFO "CPU %d: SAL log contains %s error record\n",
 			smp_processor_id(),
 			sal_info_type < ARRAY_SIZE(rec_name) ? rec_name[sal_info_type] : "UNKNOWN");
@@ -280,7 +279,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 	local_irq_enable();
 
 	/* Get the CMC error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
 	return IRQ_HANDLED;
 }
 
@@ -469,32 +468,6 @@ init_handler_platform (pal_min_state_are
 	while (1);			/* hang city if no debugger */
 }
 
-/*
- *  ia64_mca_check_errors
- *
- *  External entry to check for error records which may have been posted by SAL
- *  for a prior failure which resulted in a machine shutdown before an the
- *  error could be logged.  This function must be called after the filesystem
- *  is initialized.
- *
- *  Inputs  :   None
- *
- *  Outputs :   None
- */
-int
-ia64_mca_check_errors (void)
-{
-	/*
-	 *  If there is an MCA error record pending, get it and log it.
-	 */
-	printk(KERN_INFO "CPU %d: checking for saved MCA error records\n", smp_processor_id());
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 1);
-
-	return 0;
-}
-
-device_initcall(ia64_mca_check_errors);
-
 #ifdef CONFIG_ACPI
 /*
  * ia64_mca_register_cpev
@@ -831,7 +804,7 @@ ia64_mca_ucmc_handler(void)
 	int recover = psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
 
 	/* Get the MCA error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 0);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
@@ -875,7 +848,7 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 	local_irq_enable();
 
 	/* Get the CMC error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC, 0);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC);
 
 	spin_lock(&cmc_history_lock);
 	if (!cmc_polling_enabled) {
Index: 3-rc2.4/arch/ia64/kernel/smpboot.c
--- 3-rc2.4/arch/ia64/kernel/smpboot.c Thu, 12 Feb 2004 12:43:26 +1100 kaos (linux-2.6/a/d/3_smpboot.c 1.1.1.1.1.2.1.1 644)
+++ 3-rc2.4(w)/arch/ia64/kernel/smpboot.c Fri, 13 Feb 2004 10:58:47 +1100 kaos (linux-2.6/a/d/3_smpboot.c 1.1.1.1.1.2.1.1 644)
@@ -306,7 +306,6 @@ smp_callin (void)
 
 #ifdef CONFIG_IA64_MCA
 	ia64_mca_cmc_vector_setup();	/* Setup vector on AP & enable */
-	ia64_mca_check_errors();	/* For post-failure MCA error logging */
 #endif
 
 #ifdef CONFIG_PERFMON


From: Keith Owens <kaos@sgi.com>
Date: Fri, 13 Feb 2004 00:32:13 +0000
Subject: [patch] 2.4.25-rc1 Delete redundant ia64_mca_check_errors
Message-Id: <2539.1076632333@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

salinfo automatically processes all record types on all cpus at boot
time, ia64_mca_check_errors is now redundant.  This also removes the
need for a called_from_init flag on ia64_mca_log_sal_error_record.

Index: 25-rc1.10/include/asm-ia64/mca.h
--- 25-rc1.10/include/asm-ia64/mca.h Thu, 05 Feb 2004 10:53:36 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.1.1.1.1.1.1.1.1.3 644)
+++ 25-rc1.10(w)/include/asm-ia64/mca.h Fri, 13 Feb 2004 11:15:28 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.1.1.1.1.1.1.1.1.3 644)
@@ -111,7 +111,6 @@ extern void ia64_mca_ucmc_handler(void);
 extern void ia64_monarch_init_handler(void);
 extern void ia64_slave_init_handler(void);
 extern void ia64_mca_cmc_vector_setup(void);
-extern int  ia64_mca_check_errors(void);
 
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_MCA_H */
Index: 25-rc1.10/arch/ia64/kernel/smpboot.c
--- 25-rc1.10/arch/ia64/kernel/smpboot.c Tue, 16 Sep 2003 19:32:24 +1000 kaos (linux-2.4/r/c/37_smpboot.c 1.1.3.1.3.1.1.4.1.3.1.1 644)
+++ 25-rc1.10(w)/arch/ia64/kernel/smpboot.c Fri, 13 Feb 2004 11:25:50 +1100 kaos (linux-2.4/r/c/37_smpboot.c 1.1.3.1.3.1.1.4.1.3.1.1 644)
@@ -349,7 +349,6 @@ smp_callin (void)
 
 #ifdef CONFIG_IA64_MCA
 	ia64_mca_cmc_vector_setup();	/* Setup vector on AP & enable */
-	ia64_mca_check_errors();	/* For post-failure MCA error logging */
 #endif
 
 #ifdef CONFIG_PERFMON
Index: 25-rc1.10/arch/ia64/kernel/pci.c
--- 25-rc1.10/arch/ia64/kernel/pci.c Sun, 25 Jan 2004 06:42:02 +1100 kaos (linux-2.4/s/c/0_pci.c 1.1.2.1.3.1.1.2.1.5.1.1.1.2 644)
+++ 25-rc1.10(w)/arch/ia64/kernel/pci.c Fri, 13 Feb 2004 11:25:50 +1100 kaos (linux-2.4/s/c/0_pci.c 1.1.2.1.3.1.1.2.1.5.1.1.1.2 644)
@@ -386,10 +386,6 @@ pcibios_config_init (void)
 void __init
 pcibios_init (void)
 {
-#ifdef CONFIG_IA64_MCA
-	ia64_mca_check_errors();    /* For post-failure MCA error logging */
-#endif
-
 	pcibios_config_init();
 
 	platform_pci_fixup(0);	/* phase 0 fixups (before buses scanned) */
Index: 25-rc1.10/arch/ia64/kernel/mca.c
--- 25-rc1.10/arch/ia64/kernel/mca.c Wed, 11 Feb 2004 11:17:55 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.3.1.1.1.1 644)
+++ 25-rc1.10(w)/arch/ia64/kernel/mca.c Fri, 13 Feb 2004 11:25:50 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.3.1.1.1.1 644)
@@ -242,10 +242,9 @@ ia64_log_get(int sal_info_type, u8 **buf
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
@@ -258,7 +257,7 @@ ia64_mca_log_sal_error_record(int sal_in
 
 	salinfo_log_wakeup(sal_info_type, buffer, size, irq_safe);
 
-	if (irq_safe || called_from_init)
+	if (irq_safe)
 		printk(KERN_INFO "CPU %d: SAL log contains %s error record\n",
 			smp_processor_id(),
 			sal_info_type < ARRAY_SIZE(rec_name) ? rec_name[sal_info_type] : "UNKNOWN");
@@ -283,7 +282,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 	local_irq_enable();
 
 	/* Get the CMC error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
 }
 
 #define print_symbol(fmt, addr)	printk(fmt, "(no symbol)");
@@ -473,30 +472,6 @@ init_handler_platform (pal_min_state_are
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
 #ifdef CONFIG_ACPI
 /*
  * ia64_mca_register_cpev
@@ -837,7 +812,7 @@ ia64_mca_ucmc_handler(void)
 	int recover = psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
 
 	/* Get the MCA error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 0);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
@@ -878,7 +853,7 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 	local_irq_enable();
 
 	/* Get the CMC error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC, 0);
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC);
 
 	spin_lock(&cmc_history_lock);
 	if (!cmc_polling_enabled) {


From: Keith Owens <kaos@sgi.com>
Date: Sat, 19 Jul 2003 06:25:21 +0000
Subject: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-105859610730955@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patches to arch/ia64/kernel/mca.c against 2.4.21-ia64-030702.

Generic:
  Issue a message to identify INIT/MCA records printed on the next boot.
  gp passed to SAL_VECTOR_OS_MCA should be a physical address.
  Enable console logging for INIT/MCA messages.
  OEM data can be variable sized, do not use sizeof().
  Convert #ifdef CONFIG_SGI_SN2 to ia64_platform_is("sn2") to allow the
  building of generic kernels.

SN2:
  Set SN2 specific flag for MCA rendezvous.
  Break SAL locks if they are still held during an error.
  Save logs until next boot.
  Use platform_plat_specific_err_print(), ia64_log_platform_info_print().


Index: 21.7/arch/ia64/kernel/mca.c
--- 21.7/arch/ia64/kernel/mca.c Thu, 03 Jul 2003 12:05:08 +1000 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.4 644)
+++ 21.7(w)/arch/ia64/kernel/mca.c Sat, 19 Jul 2003 15:37:58 +1000 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.4 644)
@@ -149,7 +149,7 @@ ia64_mca_log_sal_error_record(int sal_in
 
 	/* Get the MCA error record */
 	if (!ia64_log_get(sal_info_type, (prfunc_t)printk))
-		return platform_err;		/* no record retrieved */
+		return -1;		/* no record retrieved */
 
 	/* TODO:
 	 * 1. analyze error logs to determine recoverability
@@ -377,12 +377,27 @@ ia64_mca_init_platform (void)
 int
 ia64_mca_check_errors (void)
 {
+	int print_note = 0;
+
 	/*
 	 *  If there is an MCA error record pending, get it and log it.
 	 */
 	printk("CPU %d: checking for saved MCA error records\n", smp_processor_id());
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 1);
+	if (ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 1) != -1)
+		print_note = 1;
+
+#ifdef IA64_DUMP_INIT_RECORDS_AT_BOOT
+	if (ia64_mca_log_sal_error_record(SAL_INFO_TYPE_INIT, 1) != -1)
+		print_note = 1;
+#endif
 
+	if (print_note) {
+		printk("+ \n");
+		printk("+ The above MCA error records were posted by SAL for a prior failure\n");
+		printk("+ which resulted in a machine shutdown before an the error could be logged.\n");
+		printk("+ They are probably not a result of the current boot.\n");
+		printk("+ \n");
+	}
 	return 0;
 }
 
@@ -604,6 +619,9 @@ ia64_mca_init(void)
 	s64 rc;
 	struct ia64_sal_retval isrv;
 	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
+	u64 mca_flags = SAL_MC_PARAM_RZ_ALWAYS;	/* platform specific */
+	if (ia64_platform_is("sn2"))
+		mca_flags |= 0x8;		/* SGI prom specific */
 
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
@@ -624,7 +642,7 @@ ia64_mca_init(void)
 					      SAL_MC_PARAM_MECHANISM_INT,
 					      IA64_MCA_RENDEZ_VECTOR,
 					      timeout,
-					      SAL_MC_PARAM_RZ_ALWAYS);
+					      mca_flags);
 		rc = isrv.status;
 		if (rc = 0)
 			break;
@@ -663,7 +681,7 @@ ia64_mca_init(void)
 	/* Register the os mca handler with SAL */
 	if ((rc = ia64_sal_set_vectors(SAL_VECTOR_OS_MCA,
 				       ia64_mc_info.imi_mca_handler,
-				       mca_hldlr_ptr->gp,
+				       __pa(mca_hldlr_ptr->gp),
 				       ia64_mc_info.imi_mca_handler_size,
 				       0, 0, 0)))
 	{
@@ -673,7 +691,7 @@ ia64_mca_init(void)
 	}
 
 	IA64_MCA_DEBUG("ia64_mca_init: registered os mca handler with SAL at 0x%lx, gp = 0x%lx\n",
-		       ia64_mc_info.imi_mca_handler, mca_hldlr_ptr->gp);
+		       ia64_mc_info.imi_mca_handler, __pa(mca_hldlr_ptr->gp));
 
 	/*
 	 * XXX - disable SAL checksum by setting size to 0, should be
@@ -942,6 +960,23 @@ void
 ia64_mca_ucmc_handler(void)
 {
 	int platform_err = 0;
+	int loglevel_save = console_loglevel;
+
+#ifdef CONFIG_SMP
+	if (ia64_platform_is("sn2") && sal_lock.lock) {
+		udelay(500000);
+		sal_lock.lock = 0;
+	}
+#endif
+
+	/*
+	 * Enable console logging. This MAY cause a deadlock if the MCA occurred
+	 * while critical locks were set. But what have we got to lose..... 
+	 * This policy must be revisited when we can recover from certain types
+	 * of MCAs.
+	 */
+	console_loglevel = 8;
+	bust_spinlocks(1);
 
 	/* Get the MCA error record and log it */
 	platform_err = ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 0);
@@ -949,7 +984,7 @@ ia64_mca_ucmc_handler(void)
 	/*
 	 *  Do Platform-specific mca error handling if required.
 	 */
-	if (platform_err)
+	if (platform_err > 0)
 		mca_handler_platform();
 
 	/*
@@ -960,6 +995,8 @@ ia64_mca_ucmc_handler(void)
 
 	/* Return to SAL */
 	ia64_return_to_sal_check();
+	console_loglevel = loglevel_save;
+	bust_spinlocks(0);
 }
 
 /*
@@ -1228,12 +1265,28 @@ ia64_init_handler (struct pt_regs *pt, s
 {
 	sal_log_processor_info_t *proc_ptr;
 	ia64_err_rec_t *plog_ptr;
+	int loglevel_save = console_loglevel;
 
+#ifdef CONFIG_SMP
+	if (ia64_platform_is("sn2") && sal_lock.lock) {
+		udelay(500000);
+		sal_lock.lock = 0;
+	}
+#endif
+	/*
+	 * Enable console logging. This MAY cause a deadlock if the INIT occurred
+	 * while critical locks were set.  But what have we got to lose.....
+	 * This policy must be revisited when we can recover from certain types
+	 * of INITs.
+	 */
+	console_loglevel = 8;
+
+	bust_spinlocks(1);
 	printk(KERN_INFO "Entered OS INIT handler\n");
 
 	/* Get the INIT processor log */
 	if (!ia64_log_get(SAL_INFO_TYPE_INIT, (prfunc_t)printk))
-		return;                 // no record retrieved
+		goto out;
 
 #ifdef IA64_DUMP_ALL_PROC_INFO
 	ia64_log_print(SAL_INFO_TYPE_INIT, (prfunc_t)printk);
@@ -1248,7 +1301,19 @@ ia64_init_handler (struct pt_regs *pt, s
 
 	ia64_process_min_state_save(&SAL_LPI_PSI_INFO(proc_ptr)->min_state_area);
 
+	if (ia64_platform_is("sn2")) {
+		/* SN saves logs until next boot */
+		;
+	} else {
+		/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
+		ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
+	}
+
 	init_handler_platform(proc_ptr, pt, sw);	/* call platform specific routines */
+out:
+
+	console_loglevel = loglevel_save;
+	bust_spinlocks(0);
 }
 
 /*
@@ -1913,7 +1978,7 @@ ia64_log_plat_specific_err_info_print (s
 	}
 	if (psei->valid.oem_data) {
 		platform_plat_specific_err_print((int)psei->header.len,
-				      (int)sizeof(sal_log_plat_specific_err_info_t) - 1,
+				      ((char*)psei->oem_data - (char*)psei),
 				      &(psei->oem_data[0]), prfunc);
 	}
 	prfunc("\n");
@@ -2076,6 +2141,11 @@ ia64_log_proc_dev_err_info_print (sal_lo
 		/* copy interrupted context PAL min-state info */
 		ia64_process_min_state_save(&spsi->min_state_area);
 
+		if (ia64_platform_is("sn2")) {
+			platform_plat_specific_err_print((int)slpi->header.len,
+			      0, (void*)slpi, prfunc);
+			return;
+		}
 		/* Print branch register contents if valid */
 		if (spsi->valid.br)
 			ia64_log_processor_regs_print(spsi->br, 8, "Branch", "br",
@@ -2301,7 +2371,13 @@ ia64_log_print(int sal_info_type, prfunc
 		ia64_log_rec_header_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
 		break;
 	      case SAL_INFO_TYPE_INIT:
-		prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
+		if (ia64_platform_is("sn2")) {
+			prfunc("+BEGIN HARDWARE ERROR STATE AT INIT\n");
+			platform_err = ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
+			prfunc("+END HARDWARE ERROR STATE AT INIT\n");
+		} else {
+			prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
+		}
 		break;
 	      case SAL_INFO_TYPE_CMC:
 		prfunc("+BEGIN HARDWARE ERROR STATE AT CMC\n");


From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 10 Feb 2004 05:48:03 +0000
Subject: [patch] 2.4.25-rc1, 2.6.2-rc2 mca.c
Message-Id: <6209.1076392083@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Correct the "did we recover from MCA test" and move it up a level to
simplify interaction with debuggers.

Patch is against 2.4.25-rc1 bk.  It applies to 2.6.2-rc2 with some
offsets and fuzz, after my preceding 7 patches to mca.c.  David, if it
makes it easier, I can supply a patch that takes 2.4.25-rc1 mca.c to
2.6.2-rc2 mca.c.

Index: 25-rc1.5/arch/ia64/kernel/mca.c
--- 25-rc1.5/arch/ia64/kernel/mca.c Sat, 07 Feb 2004 10:36:36 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.3.1.1 644)
+++ 25-rc1.5(w)/arch/ia64/kernel/mca.c Tue, 10 Feb 2004 16:15:07 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.3.1.1 644)
@@ -788,10 +788,8 @@ ia64_mca_wakeup_int_handler(int wakeup_i
  */
 
 static void
-ia64_return_to_sal_check(void)
+ia64_return_to_sal_check(int recover)
 {
-	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
-		&ia64_sal_to_os_handoff_state.proc_state_param;
 
 	/* Copy over some relevant stuff from the sal_to_os_mca_handoff
 	 * so that it can be used at the time of os_mca_to_sal_handoff
@@ -802,15 +800,10 @@ ia64_return_to_sal_check(void)
 	ia64_os_to_sal_handoff_state.imots_sal_check_ra  		ia64_sal_to_os_handoff_state.imsto_sal_check_ra;
 
-	/*
-	 * Did we correct the error? At the moment the only error that
-	 * we fix is a TLB error, if any other kind of error occurred
-	 * we must reboot.
-	 */
-	if (psp->cc = 1 && psp->bc = 1 && psp->rc = 1 && psp->uc = 1)
-		ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_COLD_BOOT;
-	else
+	if (recover)
 		ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_CORRECTED;
+	else
+		ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_COLD_BOOT;
 
 	/* Default = tell SAL to return to same context */
 	ia64_os_to_sal_handoff_state.imots_context = IA64_MCA_SAME_CONTEXT;
@@ -839,6 +832,10 @@ ia64_return_to_sal_check(void)
 void
 ia64_mca_ucmc_handler(void)
 {
+	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
+		&ia64_sal_to_os_handoff_state.proc_state_param;
+	int recover = psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
+
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, 0);
 
@@ -849,7 +846,7 @@ ia64_mca_ucmc_handler(void)
 	ia64_mca_wakeup_all();
 
 	/* Return to SAL */
-	ia64_return_to_sal_check();
+	ia64_return_to_sal_check(recover);
 }
 
 /*


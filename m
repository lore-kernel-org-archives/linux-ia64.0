From: Keith Owens <kaos@sgi.com>
Date: Tue, 06 May 2003 05:02:34 +0000
Subject: [Linux-ia64] [patch] 2.4.21-rc1 SAL MCA timeout
Message-Id: <marc-linux-ia64-105590723705642@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SAL can reject an MCA rendezvous timeout value and require a different
value.  The new value is part of the SAL return value structure so the
full structure must be returned by ia64_sal_mc_set_params.

diff -ur 2.4.21-rc1-ia64.orig/include/asm-ia64/sal.h 2.4.21-rc1-ia64/include/asm-ia64/sal.h
--- 2.4.21-rc1-ia64.orig/include/asm-ia64/sal.h	Tue May  6 12:18:43 2003
+++ 2.4.21-rc1-ia64/include/asm-ia64/sal.h	Tue May  6 14:56:37 2003
@@ -711,14 +711,15 @@
  * Allow the OS to specify the interrupt number to be used by SAL to interrupt OS during
  * the machine check rendezvous sequence as well as the mechanism to wake up the
  * non-monarch processor at the end of machine check processing.
+ * Returns the complete ia64_sal_retval, some calls return more than just a status value.
  */
-static inline s64
+static inline struct ia64_sal_retval
 ia64_sal_mc_set_params (u64 param_type, u64 i_or_m, u64 i_or_m_val, u64 timeout, u64 rz_always)
 {
 	struct ia64_sal_retval isrv;
 	SAL_CALL(isrv, SAL_MC_SET_PARAMS, param_type, i_or_m, i_or_m_val,
 		 timeout, rz_always, 0, 0);
-	return isrv.status;
+	return isrv;
 }
 
 /* Read from PCI configuration space */
diff -ur 2.4.21-rc1-ia64.orig/arch/ia64/kernel/mca.c 2.4.21-rc1-ia64/arch/ia64/kernel/mca.c
--- 2.4.21-rc1-ia64.orig/arch/ia64/kernel/mca.c	Tue May  6 12:18:41 2003
+++ 2.4.21-rc1-ia64/arch/ia64/kernel/mca.c	Tue May  6 14:57:39 2003
@@ -404,8 +404,10 @@
 ia64_mca_register_cpev (int cpev)
 {
 	/* Register the CPE interrupt vector with SAL */
-	if (ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_INT, cpev, 0, 0)) {
-		printk(KERN_ERR "ia64_mca_platform_init: failed to register Corrected "
+	struct ia64_sal_retval isrv;
+	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_INT, cpev, 0, 0);
+	if (isrv.status) {
+		printk("ia64_mca_platform_init: failed to register Corrected "
 		       "Platform Error interrupt vector with SAL.\n");
 		return;
 	}
@@ -602,6 +604,12 @@
 	ia64_fptr_t *mca_hldlr_ptr = (ia64_fptr_t *)ia64_os_mca_dispatch;
 	int i;
 	s64 rc;
+	struct ia64_sal_retval isrv;
+	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
+	u64 mca_flags = SAL_MC_PARAM_RZ_ALWAYS;	/* platform specific */
+#ifdef CONFIG_IA64_SGI_SN
+	mca_flags |= 0x8;			/* SGI prom specific */
+#endif
 
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
@@ -617,23 +625,34 @@
 	 */
 
 	/* Register the rendezvous interrupt vector with SAL */
-	if ((rc = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
-					 SAL_MC_PARAM_MECHANISM_INT,
-					 IA64_MCA_RENDEZ_VECTOR,
-					 IA64_MCA_RENDEZ_TIMEOUT,
-					 SAL_MC_PARAM_RZ_ALWAYS)))
-	{
+	while (1) {
+		isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
+					      SAL_MC_PARAM_MECHANISM_INT,
+					      IA64_MCA_RENDEZ_VECTOR,
+					      timeout,
+					      mca_flags);
+		rc = isrv.status;
+		if (rc = 0)
+			break;
+		if (rc = -2) {
+			printk(KERN_INFO
+				"ia64_mca_init: increasing mca rendezvous timeout from %ld to %ld\n",
+				timeout, isrv.v0);
+			timeout = isrv.v0;
+			continue;
+		}
 		printk(KERN_ERR "ia64_mca_init: Failed to register rendezvous interrupt "
 		       "with SAL.  rc = %ld\n", rc);
 		return;
 	}
 
 	/* Register the wakeup interrupt vector with SAL */
-	if ((rc = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
-					 SAL_MC_PARAM_MECHANISM_INT,
-					 IA64_MCA_WAKEUP_VECTOR,
-					 0, 0)))
-	{
+	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
+				      SAL_MC_PARAM_MECHANISM_INT,
+				      IA64_MCA_WAKEUP_VECTOR,
+				      0, 0);
+	rc = isrv.status;
+	if (rc) {
 		printk(KERN_ERR "ia64_mca_init: Failed to register wakeup interrupt with SAL.  "
 		       "rc = %ld\n", rc);
 		return;



From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 13 May 2003 22:48:46 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-rc1 SAL MCA timeout
Message-Id: <marc-linux-ia64-105590723705765@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705642@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705642@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 05 May 2003 11:02 pm, Keith Owens wrote:
> SAL can reject an MCA rendezvous timeout value and require a different
> value.  The new value is part of the SAL return value structure so the
> full structure must be returned by ia64_sal_mc_set_params.

I applied this for 2.4, except that I made a couple whitespace changes
and left out the SGI-specific flags value.  I hesitate to add more
platform-specific #ifdefs, and I think the SN kernel still requires
extra patches anyway, so I figured that change could go in there.

Here's the actual patch I applied:

#### AUTHOR kaos@sgi.com
#### COMMENT START
### Comments for ChangeSet
ia64: Handle SAL rejection of MCA rendezvous timeout value.
### Comments for arch/ia64/kernel/mca.c
(ia64_mca_init): Handle SAL rejection of MCA rendezvous timeout value.
### Comments for include/asm-ia64/sal.h
(ia64_sal_mc_set_params): Return struct ia64_sal_retval because sometimes
more than just status value is returned.
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1144  -> 1.1145 
#	arch/ia64/kernel/mca.c	1.24    -> 1.25   
#	include/asm-ia64/sal.h	1.12    -> 1.13   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/13	bjorn_helgaas@hp.com	1.1145
# ia64: Handle SAL rejection of MCA rendezvous timeout value.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c	Tue May 13 16:18:17 2003
+++ b/arch/ia64/kernel/mca.c	Tue May 13 16:18:17 2003
@@ -404,7 +404,10 @@
 ia64_mca_register_cpev (int cpev)
 {
 	/* Register the CPE interrupt vector with SAL */
-	if (ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_INT, cpev, 0, 0)) {
+	struct ia64_sal_retval isrv;
+
+	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_INT, cpev, 0, 0);
+	if (isrv.status) {
 		printk(KERN_ERR "ia64_mca_platform_init: failed to register Corrected "
 		       "Platform Error interrupt vector with SAL.\n");
 		return;
@@ -602,6 +605,8 @@
 	ia64_fptr_t *mca_hldlr_ptr = (ia64_fptr_t *)ia64_os_mca_dispatch;
 	int i;
 	s64 rc;
+	struct ia64_sal_retval isrv;
+	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
 
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
@@ -617,23 +622,33 @@
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
+					      SAL_MC_PARAM_RZ_ALWAYS);
+		rc = isrv.status;
+		if (rc = 0)
+			break;
+		if (rc = -2) {
+			printk(KERN_INFO "ia64_mca_init: increasing MCA rendezvous timeout from "
+				"%ld to %ld\n", timeout, isrv.v0);
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
diff -Nru a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
--- a/include/asm-ia64/sal.h	Tue May 13 16:18:17 2003
+++ b/include/asm-ia64/sal.h	Tue May 13 16:18:17 2003
@@ -711,14 +711,16 @@
  * Allow the OS to specify the interrupt number to be used by SAL to interrupt OS during
  * the machine check rendezvous sequence as well as the mechanism to wake up the
  * non-monarch processor at the end of machine check processing.
+ * Returns the complete ia64_sal_retval because some calls return more than just a status
+ * value.
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



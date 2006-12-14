From: Russ Anderson <rja@sgi.com>
Date: Thu, 14 Dec 2006 22:01:41 +0000
Subject: [patch] Proper handling of TLB errors from duplicate itr.d dropins
Message-Id: <200612142201.kBEM1fL267221699@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Proper handling of TLB errors from duplicate itr.d dropins

Jack Steiner noticed that duplicate TLB DTC entries do not cause a
linux panic.  See discussion:

http://www.gelato.unsw.edu.au/archives/linux-ia64/0307/6108.html

The current TLB recovery code is recovering from the duplicate itr.d
dropins, masking the underlying problem.  This change modifies
the MCA recovery code to look for the TLB check signature of the 
duplicate TLB entry and panic in that case.


Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/mca.c     |    8 ++------
 arch/ia64/kernel/mca_drv.c |   33 +++++++++++++++++++++++++++++++++
 include/asm-ia64/pal.h     |    1 +
 3 files changed, 36 insertions(+), 6 deletions(-)

Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2006-12-13 09:39:56.471871015 -0600
+++ test/arch/ia64/kernel/mca.c	2006-12-13 16:10:03.233439784 -0600
@@ -1192,8 +1192,6 @@ void
 ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		 struct ia64_sal_os_state *sos)
 {
-	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
-		&sos->proc_state_param;
 	int recover, cpu = smp_processor_id();
 	struct task_struct *previous_current;
 	struct ia64_mca_notify_die nd @@ -1223,10 +1221,8 @@ ia64_mca_handler(struct pt_regs *regs, s
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
-	/* TLB error is only exist in this SAL error record */
-	recover = (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
-	/* other error recovery */
-	   || (ia64_mca_ucmc_extension
+	/* MCA error recovery */
+	recover = (ia64_mca_ucmc_extension
 		&& ia64_mca_ucmc_extension(
 			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
 			sos));
Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2006-12-13 09:39:56.471871015 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2006-12-13 17:14:00.054326684 -0600
@@ -607,6 +607,33 @@ recover_from_platform_error(slidx_table_
 	return status;
 }
 
+/*
+ * recover_from_tlb_check
+ * @peidx:	pointer of index of processor error section
+ *
+ * Return value:
+ *	1 on Success / 0 on Failure
+ */
+static int
+recover_from_tlb_check(peidx_table_t *peidx)
+{
+	sal_log_mod_error_info_t *smei;
+	pal_tlb_check_info_t *ptci;
+
+	smei = (sal_log_mod_error_info_t *)peidx_tlb_check(peidx, 0);
+	ptci = (pal_tlb_check_info_t *)&(smei->check_info);
+
+	/*
+	 * Look for signature of a duplicate TLB DTC entry, which is
+	 * a SW bug and always fatal.
+	 */
+	if (ptci->op = PAL_TLB_CHECK_OP_PURGE
+	    && !(ptci->itr || ptci->dtc || ptci->itc))
+		return fatal_mca("Duplicate TLB entry");
+
+	return mca_recovered("TLB check recovered");
+}
+
 /**
  * recover_from_processor_error
  * @platform:	whether there are some platform error section or not
@@ -650,6 +677,12 @@ recover_from_processor_error(int platfor
 	 */
 	if (psp->us || psp->ci = 0)
 		return fatal_mca("error not contained");
+
+	/*
+	 * Look for recoverable TLB check
+	 */
+	if (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
+		return recover_from_tlb_check(peidx);
 
 	/*
 	 * The cache check and bus check bits have four possible states
Index: test/include/asm-ia64/pal.h
=================================--- test.orig/include/asm-ia64/pal.h	2006-12-13 09:39:56.523877398 -0600
+++ test/include/asm-ia64/pal.h	2006-12-13 16:10:03.333452074 -0600
@@ -373,6 +373,7 @@ typedef u64					pal_mc_info_index_t;
 							 * dependent
 							 */
 
+#define PAL_TLB_CHECK_OP_PURGE			8
 
 typedef struct pal_process_state_info_s {
 	u64		reserved1	: 2,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

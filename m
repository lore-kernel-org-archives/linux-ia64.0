From: Keith Owens <kaos@sgi.com>
Date: Mon, 12 Jul 2004 02:56:58 +0000
Subject: [patch 2.6.8-rc1] IA64_MCA_DEBUG_INFO
Message-Id: <4577.1089601018@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Am I the only person that builds with IA64_MCA_DEBUG_INFO?

Signed-off-by: Keith Owens <kaos@sgi.com>

Note: The first hunk is already in ia64 bk, but not in Linus's bk.

Index: 2.6.8-rc1-pristine/arch/ia64/kernel/mca.c
=================================--- 2.6.8-rc1-pristine.orig/arch/ia64/kernel/mca.c	Mon Jul 12 09:22:22 2004
+++ 2.6.8-rc1-pristine/arch/ia64/kernel/mca.c	Mon Jul 12 12:48:52 2004
@@ -247,7 +247,9 @@ ia64_mca_log_sal_error_record(int sal_in
 	u8 *buffer;
 	u64 size;
 	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
+#ifdef	IA64_MCA_DEBUG_INFO
 	static const char * const rec_name[] = { "MCA", "INIT", "CMC", "CPE" };
+#endif
 
 	size = ia64_log_get(sal_info_type, &buffer, irq_safe);
 	if (!size)
@@ -596,7 +598,7 @@ ia64_mca_cmc_vector_disable (void *dummy
 	cmcv = (cmcv_reg_t)ia64_getreg(_IA64_REG_CR_CMCV);
 
 	cmcv.cmcv_mask = 1; /* Mask/disable interrupt */
-	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval)
+	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);
 
 	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x disabled.\n",
@@ -623,7 +625,7 @@ ia64_mca_cmc_vector_enable (void *dummy)
 	cmcv = (cmcv_reg_t)ia64_getreg(_IA64_REG_CR_CMCV);
 
 	cmcv.cmcv_mask = 0; /* Unmask/enable interrupt */
-	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval)
+	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);
 
 	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x enabled.\n",


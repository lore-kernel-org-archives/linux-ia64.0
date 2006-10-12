From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 12 Oct 2006 22:21:17 +0000
Subject: [patch 2/2] ia64: reformat pal.S to fit in 80 columns, fix typos
Message-Id: <200610121621.17610.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Reformat to fit in 80 columns.  Fix a couple typos.  Remove
a couple unused labels.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-1/arch/ia64/kernel/pal.S
=================================--- work-1.orig/arch/ia64/kernel/pal.S	2006-10-12 10:18:31.000000000 -0600
+++ work-1/arch/ia64/kernel/pal.S	2006-10-12 16:21:54.000000000 -0600
@@ -21,11 +21,12 @@
 	.text
 
 /*
- * Set the PAL entry point address.  This could be written in C code, but we do it here
- * to keep it all in one module (besides, it's so trivial that it's
+ * Set the PAL entry point address.  This could be written in C code, but we
+ * do it here to keep it all in one module (besides, it's so trivial that it's
  * not a big deal).
  *
- * in0		Address of the PAL entry point (text address, NOT a function descriptor).
+ * in0		Address of the PAL entry point (text address, NOT a function
+ *		descriptor).
  */
 GLOBAL_ENTRY(ia64_pal_handler_init)
 	alloc r3=ar.pfs,1,0,0,0
@@ -36,9 +37,9 @@
 END(ia64_pal_handler_init)
 
 /*
- * Default PAL call handler.  This needs to be coded in assembly because it uses
- * the static calling convention, i.e., the RSE may not be used and calls are
- * done via "br.cond" (not "br.call").
+ * Default PAL call handler.  This needs to be coded in assembly because it
+ * uses the static calling convention, i.e., the RSE may not be used and
+ * calls are done via "br.cond" (not "br.call").
  */
 GLOBAL_ENTRY(ia64_pal_default_handler)
 	mov r8=-1
@@ -91,8 +92,8 @@
  * Make a PAL call using the stacked registers calling convention.
  *
  * Inputs:
- * 	in0         Index of PAL service
- * 	in2 - in3   Remaning PAL arguments
+ *	in0         Index of PAL service
+ *	in2 - in3   Remaining PAL arguments
  */
 GLOBAL_ENTRY(ia64_pal_call_stacked)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
@@ -126,18 +127,18 @@
  * Make a physical mode PAL call using the static registers calling convention.
  *
  * Inputs:
- * 	in0         Index of PAL service
- * 	in2 - in3   Remaning PAL arguments
+ *	in0         Index of PAL service
+ *	in2 - in3   Remaining PAL arguments
  *
  * PSR_LP, PSR_TB, PSR_ID, PSR_DA are never set by the kernel.
  * So we don't need to clear them.
  */
-#define PAL_PSR_BITS_TO_CLEAR							\
-	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT  | IA64_PSR_DB | IA64_PSR_RT |	\
-	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |		\
+#define PAL_PSR_BITS_TO_CLEAR						      \
+	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT  | IA64_PSR_DB | IA64_PSR_RT |\
+	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	      \
 	 IA64_PSR_DFL | IA64_PSR_DFH)
 
-#define PAL_PSR_BITS_TO_SET							\
+#define PAL_PSR_BITS_TO_SET						      \
 	(IA64_PSR_BN)
 
 
@@ -173,7 +174,7 @@
 	;;
 	andcm r16=loc3,r16		// removes bits to clear from psr
 	br.call.sptk.many rp=ia64_switch_mode_phys
-.ret1:	mov rp = r8			// install return address (physical)
+	mov rp = r8			// install return address (physical)
 	mov loc5 = r19
 	mov loc6 = r20
 	br.cond.sptk.many b7
@@ -183,7 +184,6 @@
 	mov r19=loc5
 	mov r20=loc6
 	br.call.sptk.many rp=ia64_switch_mode_virt // return to virtual mode
-.ret2:
 	mov psr.l = loc3		// restore init PSR
 
 	mov ar.pfs = loc1
@@ -198,8 +198,8 @@
  * Make a PAL call using the stacked registers in physical mode.
  *
  * Inputs:
- * 	in0         Index of PAL service
- * 	in2 - in3   Remaning PAL arguments
+ *	in0         Index of PAL service
+ *	in2 - in3   Remaining PAL arguments
  */
 GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
@@ -207,7 +207,7 @@
 	movl	loc2 = pal_entry_point
 1:	{
 	  mov r28  = in0		// copy procedure index
-	  mov loc0 = rp		// save rp
+	  mov loc0 = rp			// save rp
 	}
 	.body
 	;;
@@ -240,7 +240,7 @@
 	mov r16=loc3			// r16= original psr
 	mov r19=loc5
 	mov r20=loc6
-	br.call.sptk.many rp=ia64_switch_mode_virt	// return to virtual mode
+	br.call.sptk.many rp=ia64_switch_mode_virt // return to virtual mode
 
 	mov psr.l  = loc3		// restore init PSR
 	mov ar.pfs = loc1
@@ -252,10 +252,11 @@
 END(ia64_pal_call_phys_stacked)
 
 /*
- * Save scratch fp scratch regs which aren't saved in pt_regs already (fp10-fp15).
+ * Save scratch fp scratch regs which aren't saved in pt_regs already
+ * (fp10-fp15).
  *
- * NOTE: We need to do this since firmware (SAL and PAL) may use any of the scratch
- * regs fp-low partition.
+ * NOTE: We need to do this since firmware (SAL and PAL) may use any of the
+ * scratch regs fp-low partition.
  *
  * Inputs:
  *      in0	Address of stack storage for fp regs

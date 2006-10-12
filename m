From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 12 Oct 2006 22:20:59 +0000
Subject: [patch 1/2] ia64: remove unused PAL_CALL_IC_OFF
Message-Id: <200610121621.00227.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linux maps PAL instructions with an ITR, but uses a DTC for PAL data.
Section 11.10.2.1.3, "Making PAL Procedures Calls in Physical or Virtual
Mode," of the SDM (rev 2.2), says we must therefore make all PAL calls
with PSR.ic = 1 so that Linux can handle any TLB faults.

PAL_CALL_IC_OFF is currently unused, and as long as we use the ITR + DTC
strategy, we can't use it.  So remove it.  I also removed the code in
ia64_pal_call_static() that conditionally cleared PSR.ic.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-1/arch/ia64/kernel/pal.S
=================================--- work-1.orig/arch/ia64/kernel/pal.S	2006-09-27 16:33:06.000000000 -0600
+++ work-1/arch/ia64/kernel/pal.S	2006-10-12 10:18:31.000000000 -0600
@@ -50,12 +50,10 @@
  *
  * in0         Index of PAL service
  * in1 - in3   Remaining PAL arguments
- * in4	       1 => clear psr.ic,  0 => don't clear psr.ic
- *
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
-	alloc loc1 = ar.pfs,5,5,0,0
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
+	alloc loc1 = ar.pfs,4,5,0,0
 	movl loc2 = pal_entry_point
 1:	{
 	  mov r28 = in0
@@ -64,7 +62,6 @@
 	}
 	;;
 	ld8 loc2 = [loc2]		// loc2 <- entry point
-	tbit.nz p6,p7 = in4, 0
 	adds r8 = 1f-1b,r8
 	mov loc4=ar.rsc			// save RSE configuration
 	;;
@@ -74,13 +71,11 @@
 	.body
 	mov r30 = in2
 
-(p6)	rsm psr.i | psr.ic
 	mov r31 = in3
 	mov b7 = loc2
 
-(p7)	rsm psr.i
+	rsm psr.i
 	;;
-(p6)	srlz.i
 	mov rp = r8
 	br.cond.sptk.many b7
 1:	mov psr.l = loc3
Index: work-1/include/asm-ia64/pal.h
=================================--- work-1.orig/include/asm-ia64/pal.h	2006-09-27 16:34:13.000000000 -0600
+++ work-1/include/asm-ia64/pal.h	2006-10-12 10:17:36.000000000 -0600
@@ -764,7 +764,7 @@
  * (generally 0) MUST be passed.  Reserved parameters are not optional
  * parameters.
  */
-extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64, u64);
+extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64);
 extern struct ia64_pal_retval ia64_pal_call_stacked (u64, u64, u64, u64);
 extern struct ia64_pal_retval ia64_pal_call_phys_static (u64, u64, u64, u64);
 extern struct ia64_pal_retval ia64_pal_call_phys_stacked (u64, u64, u64, u64);
@@ -774,14 +774,7 @@
 #define PAL_CALL(iprv,a0,a1,a2,a3) do {			\
 	struct ia64_fpreg fr[6];			\
 	ia64_save_scratch_fpregs(fr);			\
-	iprv = ia64_pal_call_static(a0, a1, a2, a3, 0);	\
-	ia64_load_scratch_fpregs(fr);			\
-} while (0)
-
-#define PAL_CALL_IC_OFF(iprv,a0,a1,a2,a3) do {		\
-	struct ia64_fpreg fr[6];			\
-	ia64_save_scratch_fpregs(fr);			\
-	iprv = ia64_pal_call_static(a0, a1, a2, a3, 1);	\
+	iprv = ia64_pal_call_static(a0, a1, a2, a3);	\
 	ia64_load_scratch_fpregs(fr);			\
 } while (0)
 

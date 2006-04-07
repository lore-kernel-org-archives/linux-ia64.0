From: Keith Owens <kaos@sgi.com>
Date: Fri, 07 Apr 2006 07:29:09 +0000
Subject: [patch 2.6.17-rc1] Sanitize assembler code for ia64_sal_os_state
Message-Id: <24281.1144394949@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

struct ia64_sal_os_state has three semi-independent sections.  The code
in mca_asm.S assumes that these three sections are contiguous, which
makes it very awkward to add new data to this structure.  Remove the
assumption that the sections are contiguous.  Define a macro to shorten
references to offsets in ia64_sal_os_state.

This patch does not change the way that the code behaves.  It just
makes it easier to update the code in future and to add fields to
ia64_sal_os_state when debugging the MCA/INIT handlers.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 arch/ia64/kernel/asm-offsets.c |   16 ++++++++++++----
 arch/ia64/kernel/entry.h       |    1 +
 arch/ia64/kernel/mca_asm.S     |   28 +++++++++++++++++-----------
 3 files changed, 30 insertions(+), 15 deletions(-)

Index: linux/arch/ia64/kernel/entry.h
=================================--- linux.orig/arch/ia64/kernel/entry.h	2006-04-07 16:17:11.401746366 +1000
+++ linux/arch/ia64/kernel/entry.h	2006-04-07 16:42:43.585789214 +1000
@@ -23,6 +23,7 @@
 
 #define PT(f)		(IA64_PT_REGS_##f##_OFFSET)
 #define SW(f)		(IA64_SWITCH_STACK_##f##_OFFSET)
+#define SOS(f)		(IA64_SAL_OS_STATE_##f##_OFFSET)
 
 #define PT_REGS_SAVES(off)			\
 	.unwabi 3, 'i';				\
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2006-04-07 16:42:20.893564402 +1000
+++ linux/arch/ia64/kernel/mca_asm.S	2006-04-07 17:09:34.849108607 +1000
@@ -159,7 +159,7 @@ ia64_os_mca_spin:
 	GET_IA64_MCA_DATA(r2)
 	// Using MCA stack, struct ia64_sal_os_state, variable proc_state_param
 	;;
-	add r3=IA64_MCA_CPU_MCA_STACK_OFFSET+MCA_SOS_OFFSET+IA64_SAL_OS_STATE_PROC_STATE_PARAM_OFFSET, r2
+	add r3=IA64_MCA_CPU_MCA_STACK_OFFSET+MCA_SOS_OFFSET+SOS(PROC_STATE_PARAM), r2
 	;;
 	ld8 r18=[r3]				// Get processor state parameter on existing PALE_CHECK.
 	;;
@@ -479,9 +479,11 @@ ia64_state_save:
 	st8 [temp2]=r11,16	// rv_rc
 	mov r11=cr.iipa
 	;;
-	st8 [temp1]=r18,16	// proc_state_param
-	st8 [temp2]=r19,16	// monarch
+	st8 [temp1]=r18		// proc_state_param
+	st8 [temp2]=r19		// monarch
 	mov r6=IA64_KR(CURRENT)
+	add temp1=SOS(SAL_RA), regs
+	add temp2=SOS(SAL_GP), regs
 	;;
 	st8 [temp1]=r12,16	// sal_ra
 	st8 [temp2]=r10,16	// sal_gp
@@ -503,12 +505,14 @@ ia64_state_save:
 	st8 [temp2]=r11,16	// cr.iipa
 	mov r12=cr.iim
 	;;
-	st8 [temp1]=r12,16	// cr.iim
+	st8 [temp1]=r12		// cr.iim
 (p1)	mov r12=IA64_MCA_COLD_BOOT
 (p2)	mov r12=IA64_INIT_WARM_BOOT
 	mov r6=cr.iha
+	add temp1=SOS(OS_STATUS), regs
 	;;
-	st8 [temp2]=r6,16	// cr.iha
+	st8 [temp2]=r6		// cr.iha
+	add temp2=SOS(CONTEXT), regs
 	st8 [temp1]=r12		// os_status, default is cold boot
 	mov r6=IA64_MCA_SAME_CONTEXT
 	;;
@@ -820,8 +824,8 @@ ia64_state_restore:
 	// Restore the SAL to OS state. The previous code left regs at pt_regs.
 	add regs=MCA_SOS_OFFSET-MCA_PT_REGS_OFFSET, regs
 	;;
-	add temp1=IA64_SAL_OS_STATE_COMMON_OFFSET, regs
-	add temp2=IA64_SAL_OS_STATE_COMMON_OFFSET+8, regs
+	add temp1=SOS(SAL_RA), regs
+	add temp2=SOS(SAL_GP), regs
 	;;
 	ld8 r12=[temp1],16	// sal_ra
 	ld8 r9=[temp2],16	// sal_gp
@@ -842,8 +846,10 @@ ia64_state_restore:
 	;;
 	mov cr.itir=temp3
 	mov cr.iipa=temp4
-	ld8 temp3=[temp1],16	// cr.iim
-	ld8 temp4=[temp2],16	// cr.iha
+	ld8 temp3=[temp1]	// cr.iim
+	ld8 temp4=[temp2]		// cr.iha
+	add temp1=SOS(OS_STATUS), regs
+	add temp2=SOS(CONTEXT), regs
 	;;
 	mov cr.iim=temp3
 	mov cr.iha=temp4
@@ -916,7 +922,7 @@ ia64_state_restore:
 
 ia64_new_stack:
 	add regs=MCA_PT_REGS_OFFSET, r3
-	add temp2=MCA_SOS_OFFSET+IA64_SAL_OS_STATE_PAL_MIN_STATE_OFFSET, r3
+	add temp2=MCA_SOS_OFFSET+SOS(PAL_MIN_STATE), r3
 	mov b0=r2			// save return address
 	GET_IA64_MCA_DATA(temp1)
 	invala
@@ -1020,7 +1026,7 @@ ia64_old_stack:
 
 ia64_set_kernel_registers:
 	add temp3=MCA_SP_OFFSET, r3
-	add temp4=MCA_SOS_OFFSET+IA64_SAL_OS_STATE_OS_GP_OFFSET, r3
+	add temp4=MCA_SOS_OFFSET+SOS(OS_GP), r3
 	mov b0=r2		// save return address
 	GET_IA64_MCA_DATA(temp1)
 	;;
Index: linux/arch/ia64/kernel/asm-offsets.c
=================================--- linux.orig/arch/ia64/kernel/asm-offsets.c	2006-04-07 16:17:11.000000000 +1000
+++ linux/arch/ia64/kernel/asm-offsets.c	2006-04-07 17:25:57.678399811 +1000
@@ -217,16 +217,24 @@ void foo(void)
 	DEFINE(IA64_MCA_CPU_INIT_STACK_OFFSET,
 	       offsetof (struct ia64_mca_cpu, init_stack));
 	BLANK();
-	DEFINE(IA64_SAL_OS_STATE_COMMON_OFFSET,
-	       offsetof (struct ia64_sal_os_state, sal_ra));
 	DEFINE(IA64_SAL_OS_STATE_OS_GP_OFFSET,
 	       offsetof (struct ia64_sal_os_state, os_gp));
-	DEFINE(IA64_SAL_OS_STATE_PAL_MIN_STATE_OFFSET,
-	       offsetof (struct ia64_sal_os_state, pal_min_state));
 	DEFINE(IA64_SAL_OS_STATE_PROC_STATE_PARAM_OFFSET,
 	       offsetof (struct ia64_sal_os_state, proc_state_param));
+	DEFINE(IA64_SAL_OS_STATE_SAL_RA_OFFSET,
+	       offsetof (struct ia64_sal_os_state, sal_ra));
+	DEFINE(IA64_SAL_OS_STATE_SAL_GP_OFFSET,
+	       offsetof (struct ia64_sal_os_state, sal_gp));
+	DEFINE(IA64_SAL_OS_STATE_PAL_MIN_STATE_OFFSET,
+	       offsetof (struct ia64_sal_os_state, pal_min_state));
+	DEFINE(IA64_SAL_OS_STATE_OS_STATUS_OFFSET,
+	       offsetof (struct ia64_sal_os_state, os_status));
+	DEFINE(IA64_SAL_OS_STATE_CONTEXT_OFFSET,
+	       offsetof (struct ia64_sal_os_state, context));
 	DEFINE(IA64_SAL_OS_STATE_SIZE,
 	       sizeof (struct ia64_sal_os_state));
+	BLANK();
+
 	DEFINE(IA64_PMSA_GR_OFFSET,
 	       offsetof (struct pal_min_state_area_s, pmsa_gr));
 	DEFINE(IA64_PMSA_BANK1_GR_OFFSET,


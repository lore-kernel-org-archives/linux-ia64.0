From: Keith Owens <kaos@sgi.com>
Date: Thu, 10 Feb 2005 01:32:53 +0000
Subject: Make MCA stack look like a normal kernel stack
Message-Id: <10372.1107999173@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have a long term aim to make the MCA and INIT stacks look like normal
process stacks, so we can get decent backtraces for both MCA and INIT.
This includes tracing problems in the MCA/INIT C code, even if we take
an MCA in the INIT handler :).  Eventually we should be able to take a
crash dump from MCA or INIT, with a decent backtrace for the dump
analysis to work with.

This patch makes the MCA stack the same size as a kernel stack, with
the same basic layout.  That includes using the MCA stack for RBS
instead of the existing disjoint rbstore.  The patch is being thrown
open for review, before I spend too much time on this project.

There is space reserved for pt_regs on the MCA stack, it is not being
filled in yet.  pt_regs is required to tell the unwinder that it needs
to switch bsp to chain from MCA to INIT to normal stack; only pt_regs
contains the old bsp values.

The MCA RSE stack frame needs more work before it can be used for
unwinding.  For the moment I have kept the existing layout.

Index: linux/include/asm-ia64/mca_asm.h
=================================--- linux.orig/include/asm-ia64/mca_asm.h	2005-02-09 12:30:05.000000000 +1100
+++ linux/include/asm-ia64/mca_asm.h	2005-02-10 12:09:37.000000000 +1100
@@ -231,6 +231,7 @@
 #define  rse_bspstore_offset	(rse_ifs_offset+0x08)
 #define  rse_rnat_offset	(rse_bspstore_offset+0x08)
 #define  rse_ndirty_offset	(rse_rnat_offset+0x08)
+#define  rse_stack_size		(rse_ndirty_offset+0x08)
 
 /*
  * rse_switch_context
@@ -309,4 +310,32 @@
 	srlz.i;;								\
 	rfi;;
 
+/* MCA stack in struct ia64_mca_cpu looks like a normal kernel stack, except
+ * that the rse_stack and proc_state_dump are stored at the top of the MCA
+ * stack.  All entries are 16 byte aligned.
+ *
+ *      +---------------------------+
+ *      |       RSE stack frame     |
+ *      +---------------------------+
+ *      |       proc_state_dump     |
+ *      +---------------------------+
+ *      |           pt_regs         |
+ *      +---------------------------+
+ *      |    16 byte scratch area   |
+ *      +---------------------------+ <-------- SP at start of C MCA handler
+ *      |           .....           |
+ *      +---------------------------+
+ *      |    RBS for MCA handler    |
+ *      +---------------------------+
+ *      | struct task, not used yet |
+ *      +---------------------------+ <-------- Bottom of MCA stack
+ */
+#define ALIGN16(x)			((x)&~15)
+#define MCA_STACKFRAME_OFFSET		ALIGN16(IA64_MCA_CPU_MCA_STACK_OFFSET+KERNEL_STACK_SIZE-rse_stack_size)
+#define MCA_PROC_STATE_DUMP_SIZE	(512*8)
+#define MCA_PROC_STATE_DUMP_OFFSET	ALIGN16(MCA_STACKFRAME_OFFSET-MCA_PROC_STATE_DUMP_SIZE)
+#define MCA_PT_REGS_OFFSET		ALIGN16(MCA_PROC_STATE_DUMP_OFFSET-IA64_PT_REGS_SIZE)
+#define MCA_SP_OFFSET			ALIGN16(MCA_PT_REGS_OFFSET-16)
+#define MCA_RBSTORE_OFFSET      	(IA64_MCA_CPU_MCA_STACK_OFFSET+IA64_RBS_OFFSET)
+
 #endif /* _ASM_IA64_MCA_ASM_H */
Index: linux/include/asm-ia64/mca.h
=================================--- linux.orig/include/asm-ia64/mca.h	2005-02-09 12:30:05.000000000 +1100
+++ linux/include/asm-ia64/mca.h	2005-02-10 12:27:53.000000000 +1100
@@ -11,8 +11,6 @@
 #ifndef _ASM_IA64_MCA_H
 #define _ASM_IA64_MCA_H
 
-#define IA64_MCA_STACK_SIZE	8192
-
 #if !defined(__ASSEMBLY__)
 
 #include <linux/interrupt.h>
@@ -107,10 +105,7 @@ typedef struct ia64_mca_os_to_sal_state_
 /* Per-CPU MCA state that is too big for normal per-CPU variables.  */
 
 struct ia64_mca_cpu {
-	u64 stack[IA64_MCA_STACK_SIZE/8];	/* MCA memory-stack */
-	u64 proc_state_dump[512];
-	u64 stackframe[32];
-	u64 rbstore[IA64_MCA_STACK_SIZE/8];	/* MCA reg.-backing store */
+	u64 mca_stack[KERNEL_STACK_SIZE/8];
 	u64 init_stack[KERNEL_STACK_SIZE/8];
 } __attribute__ ((aligned(16)));
 
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-02-09 12:30:07.000000000 +1100
+++ linux/arch/ia64/kernel/mca_asm.S	2005-02-10 12:26:36.000000000 +1100
@@ -316,16 +316,14 @@ done_tlb_purge_and_reload:
 	// Setup new stack frame for OS_MCA handling
 	GET_IA64_MCA_DATA(r2)
 	;;
-	add r3 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
-	add r2 = IA64_MCA_CPU_RBSTORE_OFFSET, r2
+	add r3 = MCA_STACKFRAME_OFFSET, r2
+	add r2 = MCA_RBSTORE_OFFSET, r2
 	;;
 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
 
 	GET_IA64_MCA_DATA(r2)
 	;;
-	add r2 = IA64_MCA_CPU_STACK_OFFSET+IA64_MCA_STACK_SIZE-16, r2
-	;;
-	mov r12=r2		// establish new stack-pointer
+	add r12 = MCA_SP_OFFSET, r2 // establish new stack-pointer
 
         // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
@@ -343,7 +341,7 @@ ia64_os_mca_virtual_end:
 	// restore the original stack frame here
 	GET_IA64_MCA_DATA(r2)
 	;;
-	add r2 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
+	add r2 = MCA_STACKFRAME_OFFSET, r2
 	;;
 	movl    r4=IA64_PSR_MC
 	;;
@@ -387,7 +385,7 @@ ia64_os_mca_proc_state_dump:
 //  to virtual addressing mode.
 	GET_IA64_MCA_DATA(r2)
 	;;
-	add r2 = IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
+	add r2 = MCA_PROC_STATE_DUMP_OFFSET, r2
 	;;
 // save ar.NaT
 	mov		r5=ar.unat                  // ar.unat
@@ -620,7 +618,7 @@ ia64_os_mca_proc_state_restore:
 // Restore bank1 GR16-31
 	GET_IA64_MCA_DATA(r2)
 	;;
-	add r2 = IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
+	add r2 = MCA_PROC_STATE_DUMP_OFFSET, r2
 
 restore_GRs:                                    // restore bank-1 GRs 16-31
 	bsw.1;;
Index: linux/arch/ia64/kernel/asm-offsets.c
=================================--- linux.orig/arch/ia64/kernel/asm-offsets.c	2005-02-09 12:30:05.000000000 +1100
+++ linux/arch/ia64/kernel/asm-offsets.c	2005-02-10 11:26:25.000000000 +1100
@@ -211,14 +211,8 @@ void foo(void)
 #endif
 
 	BLANK();
-	DEFINE(IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET,
-	       offsetof (struct ia64_mca_cpu, proc_state_dump));
-	DEFINE(IA64_MCA_CPU_STACK_OFFSET,
-	       offsetof (struct ia64_mca_cpu, stack));
-	DEFINE(IA64_MCA_CPU_STACKFRAME_OFFSET,
-	       offsetof (struct ia64_mca_cpu, stackframe));
-	DEFINE(IA64_MCA_CPU_RBSTORE_OFFSET,
-	       offsetof (struct ia64_mca_cpu, rbstore));
+	DEFINE(IA64_MCA_CPU_MCA_STACK_OFFSET,
+	       offsetof (struct ia64_mca_cpu, mca_stack));
 	DEFINE(IA64_MCA_CPU_INIT_STACK_OFFSET,
 	       offsetof (struct ia64_mca_cpu, init_stack));
 	BLANK();


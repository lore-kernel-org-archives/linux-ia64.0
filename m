From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Nov 2008 12:59:49 +0000
Subject: [PATCH 2/5] ia64/pv_ops: implement binary patching optimization for native.
Message-Id: <1227618235-3890-3-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

implement binary patching optimization for pv_cpu_ops.
With this optimization, indirect call for pv_cpu_ops methods can be
converted into inline execution or direct call.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/intrinsics.h      |    6 +-
 arch/ia64/include/asm/paravirt.h        |    8 +
 arch/ia64/include/asm/paravirt_privop.h |  341 ++++++++++++++++++++-
 arch/ia64/kernel/Makefile               |    3 +-
 arch/ia64/kernel/paravirt.c             |  520 ++++++++++++++++++++++++++++++-
 arch/ia64/kernel/paravirtentry.S        |   43 ++--
 arch/ia64/kernel/setup.c                |    1 +
 7 files changed, 897 insertions(+), 25 deletions(-)

diff --git a/arch/ia64/include/asm/intrinsics.h b/arch/ia64/include/asm/intrinsics.h
index a3e44a5..fbe2ad9 100644
--- a/arch/ia64/include/asm/intrinsics.h
+++ b/arch/ia64/include/asm/intrinsics.h
@@ -201,7 +201,11 @@ extern long ia64_cmpxchg_called_with_bad_pointer (void);
 
 #ifndef __ASSEMBLY__
 #if defined(CONFIG_PARAVIRT) && defined(__KERNEL__)
-#define IA64_INTRINSIC_API(name)	pv_cpu_ops.name
+#ifdef ASM_SUPPORTED
+# define IA64_INTRINSIC_API(name)	paravirt_ ## name
+#else
+# define IA64_INTRINSIC_API(name)	pv_cpu_ops.name
+#endif
 #define IA64_INTRINSIC_MACRO(name)	paravirt_ ## name
 #else
 #define IA64_INTRINSIC_API(name)	ia64_native_ ## name
diff --git a/arch/ia64/include/asm/paravirt.h b/arch/ia64/include/asm/paravirt.h
index fc433f6..2eb0a98 100644
--- a/arch/ia64/include/asm/paravirt.h
+++ b/arch/ia64/include/asm/paravirt.h
@@ -118,6 +118,14 @@ struct pv_init_ops {
 	int (*arch_setup_nomca)(void);
 
 	void (*post_smp_prepare_boot_cpu)(void);
+
+#ifdef ASM_SUPPORTED
+	unsigned long (*patch_bundle)(void *sbundle, void *ebundle,
+				      unsigned long type);
+	unsigned long (*patch_inst)(unsigned long stag, unsigned long etag,
+				    unsigned long type);
+#endif
+	void (*patch_branch)(unsigned long tag, unsigned long type);
 };
 
 extern struct pv_init_ops pv_init_ops;
diff --git a/arch/ia64/include/asm/paravirt_privop.h b/arch/ia64/include/asm/paravirt_privop.h
index 0b59742..ee941cb 100644
--- a/arch/ia64/include/asm/paravirt_privop.h
+++ b/arch/ia64/include/asm/paravirt_privop.h
@@ -60,12 +60,18 @@ extern unsigned long ia64_native_getreg_func(int regnum);
 /* Instructions paravirtualized for performance */
 /************************************************/
 
+#ifndef ASM_SUPPORTED
+#define paravirt_ssm_i()	pv_cpu_ops.ssm_i()
+#define paravirt_rsm_i()	pv_cpu_ops.rsm_i()
+#define __paravirt_getreg()	pv_cpu_ops.getreg()
+#endif
+
 /* mask for ia64_native_ssm/rsm() must be constant.("i" constraing).
  * static inline function doesn't satisfy it. */
 #define paravirt_ssm(mask)			\
 	do {					\
 		if ((mask) = IA64_PSR_I)	\
-			pv_cpu_ops.ssm_i();	\
+			paravirt_ssm_i();	\
 		else				\
 			ia64_native_ssm(mask);	\
 	} while (0)
@@ -73,7 +79,7 @@ extern unsigned long ia64_native_getreg_func(int regnum);
 #define paravirt_rsm(mask)			\
 	do {					\
 		if ((mask) = IA64_PSR_I)	\
-			pv_cpu_ops.rsm_i();	\
+			paravirt_rsm_i();	\
 		else				\
 			ia64_native_rsm(mask);	\
 	} while (0)
@@ -87,7 +93,7 @@ extern unsigned long ia64_native_getreg_func(int regnum);
 		if ((reg) = _IA64_REG_IP)			\
 			res = ia64_native_getreg(_IA64_REG_IP); \
 		else						\
-			res = pv_cpu_ops.getreg(reg);		\
+			res = __paravirt_getreg(reg);		\
 		res;						\
 	})
 
@@ -122,4 +128,333 @@ void paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch);
 	IA64_PARAVIRT_ASM_FUNC(work_processed_syscall)
 #define ia64_leave_kernel		IA64_PARAVIRT_ASM_FUNC(leave_kernel)
 
+
+#if defined(CONFIG_PARAVIRT)
+/******************************************************************************
+ * binary patching infrastructure
+ */
+#define PARAVIRT_PATCH_TYPE_FC				1
+#define PARAVIRT_PATCH_TYPE_THASH			2
+#define PARAVIRT_PATCH_TYPE_GET_CPUID			3
+#define PARAVIRT_PATCH_TYPE_GET_PMD			4
+#define PARAVIRT_PATCH_TYPE_PTCGA			5
+#define PARAVIRT_PATCH_TYPE_GET_RR			6
+#define PARAVIRT_PATCH_TYPE_SET_RR			7
+#define PARAVIRT_PATCH_TYPE_SET_RR0_TO_RR4		8
+#define PARAVIRT_PATCH_TYPE_SSM_I			9
+#define PARAVIRT_PATCH_TYPE_RSM_I			10
+#define PARAVIRT_PATCH_TYPE_GET_PSR_I			11
+#define PARAVIRT_PATCH_TYPE_INTRIN_LOCAL_IRQ_RESTORE	12
+
+/* PARAVIRT_PATY_TYPE_[GS]ETREG + _IA64_REG_xxx */
+#define PARAVIRT_PATCH_TYPE_GETREG			0x10000000
+#define PARAVIRT_PATCH_TYPE_SETREG			0x20000000
+
+/*
+ * struct task_struct* (*ia64_switch_to)(void* next_task);
+ * void *ia64_leave_syscall;
+ * void *ia64_work_processed_syscall
+ * void *ia64_leave_kernel;
+ */
+
+#define PARAVIRT_PATCH_TYPE_BR_START			0x30000000
+#define PARAVIRT_PATCH_TYPE_BR_SWITCH_TO		\
+	(PARAVIRT_PATCH_TYPE_BR_START + 0)
+#define PARAVIRT_PATCH_TYPE_BR_LEAVE_SYSCALL		\
+	(PARAVIRT_PATCH_TYPE_BR_START + 1)
+#define PARAVIRT_PATCH_TYPE_BR_WORK_PROCESSED_SYSCALL	\
+	(PARAVIRT_PATCH_TYPE_BR_START + 2)
+#define PARAVIRT_PATCH_TYPE_BR_LEAVE_KERNEL		\
+	(PARAVIRT_PATCH_TYPE_BR_START + 3)
+
+#ifdef ASM_SUPPORTED
+#include <asm/paravirt_patch.h>
+
+/*
+ * pv_cpu_ops calling stub.
+ * normal function call convension can't be written by gcc
+ * inline assembly.
+ *
+ * from the caller's point of view,
+ * the following registers will be clobbered.
+ * r2, r3
+ * r8-r15
+ * r16, r17
+ * b6, b7
+ * p6-p15
+ * ar.ccv
+ *
+ * from the callee's point of view ,
+ * the following registers can be used.
+ * r2, r3: scratch
+ * r8: scratch, input argument0 and return value
+ * r0-r15: scratch, input argument1-5
+ * b6: return pointer
+ * b7: scratch
+ * p6-p15: scratch
+ * ar.ccv: scratch
+ *
+ * other registers must not be changed. especially
+ * b0: rp: preserved. gcc ignores b0 in clobbered register.
+ * r16: saved gp
+ */
+/* 5 bundles */
+#define __PARAVIRT_BR							\
+	";;\n"								\
+	"{ .mlx\n"							\
+	"nop 0\n"							\
+	"movl r2 = %[op_addr]\n"/* get function pointer address */	\
+	";;\n"								\
+	"}\n"								\
+	"1:\n"								\
+	"{ .mii\n"							\
+	"ld8 r2 = [r2]\n"	/* load function descriptor address */	\
+	"mov r17 = ip\n"	/* get ip to calc return address */	\
+	"mov r16 = gp\n"	/* save gp */				\
+	";;\n"								\
+	"}\n"								\
+	"{ .mii\n"							\
+	"ld8 r3 = [r2], 8\n"	/* load entry address */		\
+	"adds r17 =  1f - 1b, r17\n"	/* calculate return address */	\
+	";;\n"								\
+	"mov b7 = r3\n"		/* set entry address */			\
+	"}\n"								\
+	"{ .mib\n"							\
+	"ld8 gp = [r2]\n"	/* load gp value */			\
+	"mov b6 = r17\n"	/* set return address */		\
+	"br.cond.sptk.few b7\n"	/* intrinsics are very short isns */	\
+	"}\n"								\
+	"1:\n"								\
+	"{ .mii\n"							\
+	"mov gp = r16\n"	/* restore gp value */			\
+	"nop 0\n"							\
+	"nop 0\n"							\
+	";;\n"								\
+	"}\n"
+
+#define PARAVIRT_OP(op)				\
+	[op_addr] "i"(&pv_cpu_ops.op)
+
+#define PARAVIRT_TYPE(type)			\
+	PARAVIRT_PATCH_TYPE_ ## type
+
+#define PARAVIRT_REG_CLOBBERS0					\
+	"r2", "r3", /*"r8",*/ "r9", "r10", "r11", "r14",	\
+		"r15", "r16", "r17"
+
+#define PARAVIRT_REG_CLOBBERS1					\
+	"r2","r3", /*"r8",*/ "r9", "r10", "r11", "r14",	\
+		"r15", "r16", "r17"
+
+#define PARAVIRT_REG_CLOBBERS2					\
+	"r2", "r3", /*"r8", "r9",*/ "r10", "r11", "r14",	\
+		"r15", "r16", "r17"
+
+#define PARAVIRT_REG_CLOBBERS5					\
+	"r2", "r3", /*"r8", "r9", "r10", "r11", "r14",*/	\
+		"r15", "r16", "r17"
+
+#define PARAVIRT_BR_CLOBBERS			\
+	"b6", "b7"
+
+#define PARAVIRT_PR_CLOBBERS						\
+	"p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13", "p14", "p15"
+
+#define PARAVIRT_AR_CLOBBERS			\
+	"ar.ccv"
+
+#define PARAVIRT_CLOBBERS0			\
+		PARAVIRT_REG_CLOBBERS0,		\
+		PARAVIRT_BR_CLOBBERS,		\
+		PARAVIRT_PR_CLOBBERS,		\
+		PARAVIRT_AR_CLOBBERS,		\
+		"memory"
+
+#define PARAVIRT_CLOBBERS1			\
+		PARAVIRT_REG_CLOBBERS1,		\
+		PARAVIRT_BR_CLOBBERS,		\
+		PARAVIRT_PR_CLOBBERS,		\
+		PARAVIRT_AR_CLOBBERS,		\
+		"memory"
+
+#define PARAVIRT_CLOBBERS2			\
+		PARAVIRT_REG_CLOBBERS2,		\
+		PARAVIRT_BR_CLOBBERS,		\
+		PARAVIRT_PR_CLOBBERS,		\
+		PARAVIRT_AR_CLOBBERS,		\
+		"memory"
+
+#define PARAVIRT_CLOBBERS5			\
+		PARAVIRT_REG_CLOBBERS5,		\
+		PARAVIRT_BR_CLOBBERS,		\
+		PARAVIRT_PR_CLOBBERS,		\
+		PARAVIRT_AR_CLOBBERS,		\
+		"memory"
+
+#define PARAVIRT_BR0(op, type)					\
+	register unsigned long ia64_clobber asm ("r8");		\
+	asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
+					  PARAVIRT_TYPE(type))	\
+		      :	"=r"(ia64_clobber)			\
+		      : PARAVIRT_OP(op)				\
+		      : PARAVIRT_CLOBBERS0)
+
+#define PARAVIRT_BR0_RET(op, type)				\
+	register unsigned long ia64_intri_res asm ("r8");	\
+	asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
+					  PARAVIRT_TYPE(type))	\
+		      : "=r"(ia64_intri_res)			\
+		      : PARAVIRT_OP(op)				\
+		      : PARAVIRT_CLOBBERS0)
+
+#define PARAVIRT_BR1(op, type, arg1)				\
+	register unsigned long __##arg1 asm ("r8") = arg1;	\
+	register unsigned long ia64_clobber asm ("r8");		\
+	asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
+					  PARAVIRT_TYPE(type))	\
+		      :	"=r"(ia64_clobber)			\
+		      : PARAVIRT_OP(op), "0"(__##arg1)		\
+		      : PARAVIRT_CLOBBERS1)
+
+#define PARAVIRT_BR1_RET(op, type, arg1)			\
+	register unsigned long ia64_intri_res asm ("r8");	\
+	register unsigned long __##arg1 asm ("r8") = arg1;	\
+	asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
+					  PARAVIRT_TYPE(type))	\
+		      : "=r"(ia64_intri_res)			\
+		      : PARAVIRT_OP(op), "0"(__##arg1)		\
+		      : PARAVIRT_CLOBBERS1)
+
+#define PARAVIRT_BR2(op, type, arg1, arg2)				\
+	register unsigned long __##arg1 asm ("r8") = arg1;		\
+	register unsigned long __##arg2 asm ("r9") = arg2;		\
+	register unsigned long ia64_clobber1 asm ("r8");		\
+	register unsigned long ia64_clobber2 asm ("r9");		\
+	asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,		\
+					  PARAVIRT_TYPE(type))		\
+		      : "=r"(ia64_clobber1), "=r"(ia64_clobber2)	\
+		      : PARAVIRT_OP(op), "0"(__##arg1), "1"(__##arg2)	\
+		      : PARAVIRT_CLOBBERS2)
+
+
+#define PARAVIRT_DEFINE_CPU_OP0(op, type)		\
+	static inline void				\
+	paravirt_ ## op (void)				\
+	{						\
+		PARAVIRT_BR0(op, type);			\
+	}
+
+#define PARAVIRT_DEFINE_CPU_OP0_RET(op, type)		\
+	static inline unsigned long			\
+	paravirt_ ## op (void)				\
+	{						\
+		PARAVIRT_BR0_RET(op, type);		\
+		return ia64_intri_res;			\
+	}
+
+#define PARAVIRT_DEFINE_CPU_OP1(op, type)		\
+	static inline void				\
+	paravirt_ ## op (unsigned long arg1)		\
+	{						\
+		PARAVIRT_BR1(op, type, arg1);		\
+	}
+
+#define PARAVIRT_DEFINE_CPU_OP1_RET(op, type)		\
+	static inline unsigned long			\
+	paravirt_ ## op (unsigned long arg1)		\
+	{						\
+		PARAVIRT_BR1_RET(op, type, arg1);	\
+		return ia64_intri_res;			\
+	}
+
+#define PARAVIRT_DEFINE_CPU_OP2(op, type)		\
+	static inline void				\
+	paravirt_ ## op (unsigned long arg1,		\
+			 unsigned long arg2)		\
+	{						\
+		PARAVIRT_BR2(op, type, arg1, arg2);	\
+	}
+
+
+PARAVIRT_DEFINE_CPU_OP1(fc, FC);
+PARAVIRT_DEFINE_CPU_OP1_RET(thash, THASH)
+PARAVIRT_DEFINE_CPU_OP1_RET(get_cpuid, GET_CPUID)
+PARAVIRT_DEFINE_CPU_OP1_RET(get_pmd, GET_PMD)
+PARAVIRT_DEFINE_CPU_OP2(ptcga, PTCGA)
+PARAVIRT_DEFINE_CPU_OP1_RET(get_rr, GET_RR)
+PARAVIRT_DEFINE_CPU_OP2(set_rr, SET_RR)
+PARAVIRT_DEFINE_CPU_OP0(ssm_i, SSM_I)
+PARAVIRT_DEFINE_CPU_OP0(rsm_i, RSM_I)
+PARAVIRT_DEFINE_CPU_OP0_RET(get_psr_i, GET_PSR_I)
+PARAVIRT_DEFINE_CPU_OP1(intrin_local_irq_restore, INTRIN_LOCAL_IRQ_RESTORE)
+
+static inline void
+paravirt_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
+			unsigned long val2, unsigned long val3,
+			unsigned long val4)
+{
+	register unsigned long __val0 asm ("r8") = val0;
+	register unsigned long __val1 asm ("r9") = val1;
+	register unsigned long __val2 asm ("r10") = val2;
+	register unsigned long __val3 asm ("r11") = val3;
+	register unsigned long __val4 asm ("r14") = val4;
+
+	register unsigned long ia64_clobber0 asm ("r8");
+	register unsigned long ia64_clobber1 asm ("r9");
+	register unsigned long ia64_clobber2 asm ("r10");
+	register unsigned long ia64_clobber3 asm ("r11");
+	register unsigned long ia64_clobber4 asm ("r14");
+
+	asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,
+					  PARAVIRT_TYPE(SET_RR0_TO_RR4))
+		      : "=r"(ia64_clobber0),
+			"=r"(ia64_clobber1),
+			"=r"(ia64_clobber2),
+			"=r"(ia64_clobber3),
+			"=r"(ia64_clobber4)
+		      : PARAVIRT_OP(set_rr0_to_rr4),
+			"0"(__val0), "1"(__val1), "2"(__val2),
+			"3"(__val3), "4"(__val4)
+		      : PARAVIRT_CLOBBERS5);
+}
+
+/* unsigned long paravirt_getreg(int reg) */
+#define __paravirt_getreg(reg)						\
+	({								\
+		register unsigned long ia64_intri_res asm ("r8");	\
+		register unsigned long __reg asm ("r8") = (reg);	\
+									\
+		BUILD_BUG_ON(!__builtin_constant_p(reg));		\
+		asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
+						  PARAVIRT_TYPE(GETREG) \
+						  + (reg))		\
+			      : "=r"(ia64_intri_res)			\
+			      : PARAVIRT_OP(getreg), "0"(__reg)		\
+			      : PARAVIRT_CLOBBERS1);			\
+									\
+		ia64_intri_res;						\
+	})
+
+/* void paravirt_setreg(int reg, unsigned long val) */
+#define paravirt_setreg(reg, val)					\
+	do {								\
+		register unsigned long __val asm ("r8") = val;		\
+		register unsigned long __reg asm ("r9") = reg;		\
+		register unsigned long ia64_clobber1 asm ("r8");	\
+		register unsigned long ia64_clobber2 asm ("r9");	\
+									\
+		BUILD_BUG_ON(!__builtin_constant_p(reg));		\
+		asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
+						  PARAVIRT_TYPE(SETREG) \
+						  + (reg))		\
+			      : "=r"(ia64_clobber1),			\
+				"=r"(ia64_clobber2)			\
+			      : PARAVIRT_OP(setreg),			\
+				"1"(__reg), "0"(__val)			\
+			      : PARAVIRT_CLOBBERS2);			\
+	} while (0)
+
+#endif /* ASM_SUPPORTED */
+#endif /* CONFIG_PARAVIRT && ASM_SUPPOTED */
+
 #endif /* _ASM_IA64_PARAVIRT_PRIVOP_H */
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 8dc9df8..dbc19e4 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -36,7 +36,8 @@ obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
 
-obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirtentry.o
+obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirtentry.o \
+				   paravirt_patch.o
 
 obj-$(CONFIG_IA64_ESI)		+= esi.o
 ifneq ($(CONFIG_IA64_ESI),)
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index 6bc33a6..158d524 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -46,13 +46,23 @@ struct pv_info pv_info = {
  * initialization hooks.
  */
 
-struct pv_init_ops pv_init_ops;
+static void __init
+ia64_native_patch_branch(unsigned long tag, unsigned long type);
+
+struct pv_init_ops pv_init_ops +{
+#ifdef ASM_SUPPORTED
+	.patch_bundle = ia64_native_patch_bundle,
+#endif
+	.patch_branch = ia64_native_patch_branch,
+};
 
 /***************************************************************************
  * pv_cpu_ops
  * intrinsics hooks.
  */
 
+#ifndef ASM_SUPPORTED
 /* ia64_native_xxx are macros so that we have to make them real functions */
 
 #define DEFINE_VOID_FUNC1(name)					\
@@ -274,6 +284,261 @@ ia64_native_setreg_func(int regnum, unsigned long val)
 		break;
 	}
 }
+#else
+
+#define __DEFINE_FUNC(name, code)					\
+	extern const char ia64_native_ ## name ## _direct_start[];	\
+	extern const char ia64_native_ ## name ## _direct_end[];	\
+	asm (".align 32\n"						\
+	     ".proc ia64_native_" #name "_func\n"			\
+	     "ia64_native_" #name "_func:\n"				\
+	     "ia64_native_" #name "_direct_start:\n"			\
+	     code							\
+	     "ia64_native_" #name "_direct_end:\n"			\
+	     "br.cond.sptk.many b6\n"					\
+	     ".endp ia64_native_" #name "_func\n")
+
+#define DEFINE_VOID_FUNC0(name, code)				\
+	extern void						\
+	ia64_native_ ## name ## _func(void);			\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_VOID_FUNC1(name, code)				\
+	extern void						\
+	ia64_native_ ## name ## _func(unsigned long arg);	\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_VOID_FUNC2(name, code)				\
+	extern void						\
+	ia64_native_ ## name ## _func(unsigned long arg0,	\
+				      unsigned long arg1);	\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_FUNC0(name, code)		\
+	extern unsigned long			\
+	ia64_native_ ## name ## _func(void);	\
+	__DEFINE_FUNC(name, code)
+
+#define DEFINE_FUNC1(name, type, code)			\
+	extern unsigned long				\
+	ia64_native_ ## name ## _func(type arg);	\
+	__DEFINE_FUNC(name, code)
+
+DEFINE_VOID_FUNC1(fc,
+		  "fc r8\n");
+DEFINE_VOID_FUNC1(intrin_local_irq_restore,
+		  ";;\n"
+		  "     cmp.ne p6, p7 = r8, r0\n"
+		  ";;\n"
+		  "(p6) ssm psr.i\n"
+		  "(p7) rsm psr.i\n"
+		  ";;\n"
+		  "(p6) srlz.d\n");
+
+DEFINE_VOID_FUNC2(ptcga,
+		  "ptc.ga r8, r9\n");
+DEFINE_VOID_FUNC2(set_rr,
+		  "mov rr[r8] = r9\n");
+
+/* ia64_native_getreg(_IA64_REG_PSR) & IA64_PSR_I */
+DEFINE_FUNC0(get_psr_i,
+	     "mov r2 = " __stringify(1 << IA64_PSR_I_BIT) "\n"
+	     "mov r8 = psr\n"
+	     ";;\n"
+	     "and r8 = r2, r8\n");
+
+DEFINE_FUNC1(thash, unsigned long,
+	     "thash r8 = r8\n");
+DEFINE_FUNC1(get_cpuid, int,
+	     "mov r8 = cpuid[r8]\n");
+DEFINE_FUNC1(get_pmd, int,
+	     "mov r8 = pmd[r8]\n");
+DEFINE_FUNC1(get_rr, unsigned long,
+	     "mov r8 = rr[r8]\n");
+
+DEFINE_VOID_FUNC0(ssm_i,
+		  "ssm psr.i\n");
+DEFINE_VOID_FUNC0(rsm_i,
+		  "rsm psr.i\n");
+
+extern void
+ia64_native_set_rr0_to_rr4_func(unsigned long val0, unsigned long val1,
+				unsigned long val2, unsigned long val3,
+				unsigned long val4);
+__DEFINE_FUNC(set_rr0_to_rr4,
+	      "mov rr[r0] = r8\n"
+	      "movl r2 = 0x2000000000000000\n"
+	      ";;\n"
+	      "mov rr[r2] = r9\n"
+	      "shl r3 = r2, 1\n"	/* movl r3 = 0x4000000000000000 */
+	      ";;\n"
+	      "add r2 = r2, r3\n"	/* movl r2 = 0x6000000000000000 */
+	      "mov rr[r3] = r10\n"
+	      ";;\n"
+	      "mov rr[r2] = r11\n"
+	      "shl r3 = r3, 1\n"	/* movl r3 = 0x8000000000000000 */
+	      ";;\n"
+	      "mov rr[r3] = r14\n");
+
+extern unsigned long ia64_native_getreg_func(int regnum);
+asm(".global ia64_native_getreg_func\n");
+#define __DEFINE_GET_REG(id, reg)			\
+	"mov r2 = " __stringify(_IA64_REG_ ## id) "\n"	\
+	";;\n"						\
+	"cmp.eq p6, p0 = r2, r8\n"			\
+	";;\n"						\
+	"(p6) mov r8 = " #reg "\n"			\
+	"(p6) br.cond.sptk.many b6\n"			\
+	";;\n"
+#define __DEFINE_GET_AR(id, reg)	__DEFINE_GET_REG(AR_ ## id, ar.reg)
+#define __DEFINE_GET_CR(id, reg)	__DEFINE_GET_REG(CR_ ## id, cr.reg)
+
+__DEFINE_FUNC(getreg,
+	      __DEFINE_GET_REG(GP, gp)
+	      /*__DEFINE_GET_REG(IP, ip)*/ /* returned ip value shouldn't be constant */
+	      __DEFINE_GET_REG(PSR, psr)
+	      __DEFINE_GET_REG(TP, tp)
+	      __DEFINE_GET_REG(SP, sp)
+
+	      __DEFINE_GET_REG(AR_KR0, ar0)
+	      __DEFINE_GET_REG(AR_KR1, ar1)
+	      __DEFINE_GET_REG(AR_KR2, ar2)
+	      __DEFINE_GET_REG(AR_KR3, ar3)
+	      __DEFINE_GET_REG(AR_KR4, ar4)
+	      __DEFINE_GET_REG(AR_KR5, ar5)
+	      __DEFINE_GET_REG(AR_KR6, ar6)
+	      __DEFINE_GET_REG(AR_KR7, ar7)
+	      __DEFINE_GET_AR(RSC, rsc)
+	      __DEFINE_GET_AR(BSP, bsp)
+	      __DEFINE_GET_AR(BSPSTORE, bspstore)
+	      __DEFINE_GET_AR(RNAT, rnat)
+	      __DEFINE_GET_AR(FCR, fcr)
+	      __DEFINE_GET_AR(EFLAG, eflag)
+	      __DEFINE_GET_AR(CSD, csd)
+	      __DEFINE_GET_AR(SSD, ssd)
+	      __DEFINE_GET_REG(AR_CFLAG, ar27)
+	      __DEFINE_GET_AR(FSR, fsr)
+	      __DEFINE_GET_AR(FIR, fir)
+	      __DEFINE_GET_AR(FDR, fdr)
+	      __DEFINE_GET_AR(CCV, ccv)
+	      __DEFINE_GET_AR(UNAT, unat)
+	      __DEFINE_GET_AR(FPSR, fpsr)
+	      __DEFINE_GET_AR(ITC, itc)
+	      __DEFINE_GET_AR(PFS, pfs)
+	      __DEFINE_GET_AR(LC, lc)
+	      __DEFINE_GET_AR(EC, ec)
+
+	      __DEFINE_GET_CR(DCR, dcr)
+	      __DEFINE_GET_CR(ITM, itm)
+	      __DEFINE_GET_CR(IVA, iva)
+	      __DEFINE_GET_CR(PTA, pta)
+	      __DEFINE_GET_CR(IPSR, ipsr)
+	      __DEFINE_GET_CR(ISR, isr)
+	      __DEFINE_GET_CR(IIP, iip)
+	      __DEFINE_GET_CR(IFA, ifa)
+	      __DEFINE_GET_CR(ITIR, itir)
+	      __DEFINE_GET_CR(IIPA, iipa)
+	      __DEFINE_GET_CR(IFS, ifs)
+	      __DEFINE_GET_CR(IIM, iim)
+	      __DEFINE_GET_CR(IHA, iha)
+	      __DEFINE_GET_CR(LID, lid)
+	      __DEFINE_GET_CR(IVR, ivr)
+	      __DEFINE_GET_CR(TPR, tpr)
+	      __DEFINE_GET_CR(EOI, eoi)
+	      __DEFINE_GET_CR(IRR0, irr0)
+	      __DEFINE_GET_CR(IRR1, irr1)
+	      __DEFINE_GET_CR(IRR2, irr2)
+	      __DEFINE_GET_CR(IRR3, irr3)
+	      __DEFINE_GET_CR(ITV, itv)
+	      __DEFINE_GET_CR(PMV, pmv)
+	      __DEFINE_GET_CR(CMCV, cmcv)
+	      __DEFINE_GET_CR(LRR0, lrr0)
+	      __DEFINE_GET_CR(LRR1, lrr1)
+
+	      "mov r8 = -1\n"	/* unsupported case */
+	);
+
+extern void ia64_native_setreg_func(int regnum, unsigned long val);
+asm(".global ia64_native_setreg_func\n");
+#define __DEFINE_SET_REG(id, reg)			\
+	"mov r2 = " __stringify(_IA64_REG_ ## id) "\n"	\
+	";;\n"						\
+	"cmp.eq p6, p0 = r2, r9\n"			\
+	";;\n"						\
+	"(p6) mov " #reg " = r8\n"			\
+	"(p6) br.cond.sptk.many b6\n"			\
+	";;\n"
+#define __DEFINE_SET_AR(id, reg)	__DEFINE_SET_REG(AR_ ## id, ar.reg)
+#define __DEFINE_SET_CR(id, reg)	__DEFINE_SET_REG(CR_ ## id, cr.reg)
+__DEFINE_FUNC(setreg,
+	      "mov r2 = " __stringify(_IA64_REG_PSR_L) "\n"
+	      ";;\n"
+	      "cmp.eq p6, p0 = r2, r9\n"
+	      ";;\n"
+	      "(p6) mov psr.l = r8\n"
+#ifdef HAVE_SERIALIZE_DIRECTIVE
+	      ".serialize.data\n"
+#endif
+	      "(p6) br.cond.sptk.many b6\n"
+	      __DEFINE_SET_REG(GP, gp)
+	      __DEFINE_SET_REG(SP, sp)
+
+	      __DEFINE_SET_REG(AR_KR0, ar0)
+	      __DEFINE_SET_REG(AR_KR1, ar1)
+	      __DEFINE_SET_REG(AR_KR2, ar2)
+	      __DEFINE_SET_REG(AR_KR3, ar3)
+	      __DEFINE_SET_REG(AR_KR4, ar4)
+	      __DEFINE_SET_REG(AR_KR5, ar5)
+	      __DEFINE_SET_REG(AR_KR6, ar6)
+	      __DEFINE_SET_REG(AR_KR7, ar7)
+	      __DEFINE_SET_AR(RSC, rsc)
+	      __DEFINE_SET_AR(BSP, bsp)
+	      __DEFINE_SET_AR(BSPSTORE, bspstore)
+	      __DEFINE_SET_AR(RNAT, rnat)
+	      __DEFINE_SET_AR(FCR, fcr)
+	      __DEFINE_SET_AR(EFLAG, eflag)
+	      __DEFINE_SET_AR(CSD, csd)
+	      __DEFINE_SET_AR(SSD, ssd)
+	      __DEFINE_SET_REG(AR_CFLAG, ar27)
+	      __DEFINE_SET_AR(FSR, fsr)
+	      __DEFINE_SET_AR(FIR, fir)
+	      __DEFINE_SET_AR(FDR, fdr)
+	      __DEFINE_SET_AR(CCV, ccv)
+	      __DEFINE_SET_AR(UNAT, unat)
+	      __DEFINE_SET_AR(FPSR, fpsr)
+	      __DEFINE_SET_AR(ITC, itc)
+	      __DEFINE_SET_AR(PFS, pfs)
+	      __DEFINE_SET_AR(LC, lc)
+	      __DEFINE_SET_AR(EC, ec)
+
+	      __DEFINE_SET_CR(DCR, dcr)
+	      __DEFINE_SET_CR(ITM, itm)
+	      __DEFINE_SET_CR(IVA, iva)
+	      __DEFINE_SET_CR(PTA, pta)
+	      __DEFINE_SET_CR(IPSR, ipsr)
+	      __DEFINE_SET_CR(ISR, isr)
+	      __DEFINE_SET_CR(IIP, iip)
+	      __DEFINE_SET_CR(IFA, ifa)
+	      __DEFINE_SET_CR(ITIR, itir)
+	      __DEFINE_SET_CR(IIPA, iipa)
+	      __DEFINE_SET_CR(IFS, ifs)
+	      __DEFINE_SET_CR(IIM, iim)
+	      __DEFINE_SET_CR(IHA, iha)
+	      __DEFINE_SET_CR(LID, lid)
+	      __DEFINE_SET_CR(IVR, ivr)
+	      __DEFINE_SET_CR(TPR, tpr)
+	      __DEFINE_SET_CR(EOI, eoi)
+	      __DEFINE_SET_CR(IRR0, irr0)
+	      __DEFINE_SET_CR(IRR1, irr1)
+	      __DEFINE_SET_CR(IRR2, irr2)
+	      __DEFINE_SET_CR(IRR3, irr3)
+	      __DEFINE_SET_CR(ITV, itv)
+	      __DEFINE_SET_CR(PMV, pmv)
+	      __DEFINE_SET_CR(CMCV, cmcv)
+	      __DEFINE_SET_CR(LRR0, lrr0)
+	      __DEFINE_SET_CR(LRR1, lrr1)
+	);
+#endif
 
 struct pv_cpu_ops pv_cpu_ops = {
 	.fc		= ia64_native_fc_func,
@@ -368,3 +633,256 @@ struct pv_time_ops pv_time_ops = {
 	.do_steal_accounting = ia64_native_do_steal_accounting,
 	.sched_clock = ia64_native_sched_clock,
 };
+
+/***************************************************************************
+ * binary pacthing
+ * pv_init_ops.patch_bundle
+ */
+
+#ifdef ASM_SUPPORTED
+#define IA64_NATIVE_PATCH_DEFINE_GET_REG(name, reg)	\
+	__DEFINE_FUNC(get_ ## name,			\
+		      ";;\n"				\
+		      "mov r8 = " #reg "\n"		\
+		      ";;\n")
+
+#define IA64_NATIVE_PATCH_DEFINE_SET_REG(name, reg)	\
+	__DEFINE_FUNC(set_ ## name,			\
+		      ";;\n"				\
+		      "mov " #reg " = r8\n"		\
+		      ";;\n")
+
+#define IA64_NATIVE_PATCH_DEFINE_REG(name, reg)		\
+	IA64_NATIVE_PATCH_DEFINE_GET_REG(name, reg);	\
+	IA64_NATIVE_PATCH_DEFINE_SET_REG(name, reg)	\
+
+#define IA64_NATIVE_PATCH_DEFINE_AR(name, reg)			\
+	IA64_NATIVE_PATCH_DEFINE_REG(ar_ ## name, ar.reg)
+
+#define IA64_NATIVE_PATCH_DEFINE_CR(name, reg)			\
+	IA64_NATIVE_PATCH_DEFINE_REG(cr_ ## name, cr.reg)
+
+
+IA64_NATIVE_PATCH_DEFINE_GET_REG(psr, psr);
+IA64_NATIVE_PATCH_DEFINE_GET_REG(tp, tp);
+
+/* IA64_NATIVE_PATCH_DEFINE_SET_REG(psr_l, psr.l); */
+__DEFINE_FUNC(set_psr_l,
+	      ";;\n"
+	      "mov psr.l = r8\n"
+#ifdef HAVE_SERIALIZE_DIRECTIVE
+	      ".serialize.data\n"
+#endif
+	      ";;\n");
+
+IA64_NATIVE_PATCH_DEFINE_REG(gp, gp);
+IA64_NATIVE_PATCH_DEFINE_REG(sp, sp);
+
+IA64_NATIVE_PATCH_DEFINE_REG(kr0, ar0);
+IA64_NATIVE_PATCH_DEFINE_REG(kr1, ar1);
+IA64_NATIVE_PATCH_DEFINE_REG(kr2, ar2);
+IA64_NATIVE_PATCH_DEFINE_REG(kr3, ar3);
+IA64_NATIVE_PATCH_DEFINE_REG(kr4, ar4);
+IA64_NATIVE_PATCH_DEFINE_REG(kr5, ar5);
+IA64_NATIVE_PATCH_DEFINE_REG(kr6, ar6);
+IA64_NATIVE_PATCH_DEFINE_REG(kr7, ar7);
+
+IA64_NATIVE_PATCH_DEFINE_AR(rsc, rsc);
+IA64_NATIVE_PATCH_DEFINE_AR(bsp, bsp);
+IA64_NATIVE_PATCH_DEFINE_AR(bspstore, bspstore);
+IA64_NATIVE_PATCH_DEFINE_AR(rnat, rnat);
+IA64_NATIVE_PATCH_DEFINE_AR(fcr, fcr);
+IA64_NATIVE_PATCH_DEFINE_AR(eflag, eflag);
+IA64_NATIVE_PATCH_DEFINE_AR(csd, csd);
+IA64_NATIVE_PATCH_DEFINE_AR(ssd, ssd);
+IA64_NATIVE_PATCH_DEFINE_REG(ar27, ar27);
+IA64_NATIVE_PATCH_DEFINE_AR(fsr, fsr);
+IA64_NATIVE_PATCH_DEFINE_AR(fir, fir);
+IA64_NATIVE_PATCH_DEFINE_AR(fdr, fdr);
+IA64_NATIVE_PATCH_DEFINE_AR(ccv, ccv);
+IA64_NATIVE_PATCH_DEFINE_AR(unat, unat);
+IA64_NATIVE_PATCH_DEFINE_AR(fpsr, fpsr);
+IA64_NATIVE_PATCH_DEFINE_AR(itc, itc);
+IA64_NATIVE_PATCH_DEFINE_AR(pfs, pfs);
+IA64_NATIVE_PATCH_DEFINE_AR(lc, lc);
+IA64_NATIVE_PATCH_DEFINE_AR(ec, ec);
+
+IA64_NATIVE_PATCH_DEFINE_CR(dcr, dcr);
+IA64_NATIVE_PATCH_DEFINE_CR(itm, itm);
+IA64_NATIVE_PATCH_DEFINE_CR(iva, iva);
+IA64_NATIVE_PATCH_DEFINE_CR(pta, pta);
+IA64_NATIVE_PATCH_DEFINE_CR(ipsr, ipsr);
+IA64_NATIVE_PATCH_DEFINE_CR(isr, isr);
+IA64_NATIVE_PATCH_DEFINE_CR(iip, iip);
+IA64_NATIVE_PATCH_DEFINE_CR(ifa, ifa);
+IA64_NATIVE_PATCH_DEFINE_CR(itir, itir);
+IA64_NATIVE_PATCH_DEFINE_CR(iipa, iipa);
+IA64_NATIVE_PATCH_DEFINE_CR(ifs, ifs);
+IA64_NATIVE_PATCH_DEFINE_CR(iim, iim);
+IA64_NATIVE_PATCH_DEFINE_CR(iha, iha);
+IA64_NATIVE_PATCH_DEFINE_CR(lid, lid);
+IA64_NATIVE_PATCH_DEFINE_CR(ivr, ivr);
+IA64_NATIVE_PATCH_DEFINE_CR(tpr, tpr);
+IA64_NATIVE_PATCH_DEFINE_CR(eoi, eoi);
+IA64_NATIVE_PATCH_DEFINE_CR(irr0, irr0);
+IA64_NATIVE_PATCH_DEFINE_CR(irr1, irr1);
+IA64_NATIVE_PATCH_DEFINE_CR(irr2, irr2);
+IA64_NATIVE_PATCH_DEFINE_CR(irr3, irr3);
+IA64_NATIVE_PATCH_DEFINE_CR(itv, itv);
+IA64_NATIVE_PATCH_DEFINE_CR(pmv, pmv);
+IA64_NATIVE_PATCH_DEFINE_CR(cmcv, cmcv);
+IA64_NATIVE_PATCH_DEFINE_CR(lrr0, lrr0);
+IA64_NATIVE_PATCH_DEFINE_CR(lrr1, lrr1);
+
+static const struct paravirt_patch_bundle_elem ia64_native_patch_bundle_elems[]
+__initdata_or_module +{
+#define IA64_NATIVE_PATCH_BUNDLE_ELEM(name, type)		\
+	{							\
+		(void*)ia64_native_ ## name ## _direct_start,	\
+		(void*)ia64_native_ ## name ## _direct_end,	\
+		PARAVIRT_PATCH_TYPE_ ## type,			\
+	}
+
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(fc, FC),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(thash, THASH),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(get_cpuid, GET_CPUID),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(get_pmd, GET_PMD),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(ptcga, PTCGA),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(get_rr, GET_RR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(set_rr, SET_RR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(set_rr0_to_rr4, SET_RR0_TO_RR4),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(ssm_i, SSM_I),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(rsm_i, RSM_I),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(get_psr_i, GET_PSR_I),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM(intrin_local_irq_restore,
+				      INTRIN_LOCAL_IRQ_RESTORE),
+
+#define IA64_NATIVE_PATCH_BUNDLE_ELEM_GETREG(name, reg)			\
+	{								\
+		(void*)ia64_native_get_ ## name ## _direct_start,	\
+		(void*)ia64_native_get_ ## name ## _direct_end,		\
+		PARAVIRT_PATCH_TYPE_GETREG + _IA64_REG_ ## reg,		\
+	}
+
+#define IA64_NATIVE_PATCH_BUNDLE_ELEM_SETREG(name, reg)			\
+	{								\
+		(void*)ia64_native_set_ ## name ## _direct_start,	\
+		(void*)ia64_native_set_ ## name ## _direct_end,		\
+		PARAVIRT_PATCH_TYPE_SETREG + _IA64_REG_ ## reg,		\
+	}
+
+#define IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(name, reg)		\
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_GETREG(name, reg),	\
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_SETREG(name, reg)		\
+
+#define IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(name, reg)		\
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(ar_ ## name, AR_ ## reg)
+
+#define IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(name, reg)		\
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(cr_ ## name, CR_ ## reg)
+
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_GETREG(psr, PSR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_GETREG(tp, TP),
+
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_SETREG(psr_l, PSR_L),
+
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(gp, GP),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(sp, SP),
+
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr0, AR_KR0),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr1, AR_KR1),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr2, AR_KR2),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr3, AR_KR3),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr4, AR_KR4),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr5, AR_KR5),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr6, AR_KR6),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(kr7, AR_KR7),
+
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(rsc, RSC),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(bsp, BSP),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(bspstore, BSPSTORE),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(rnat, RNAT),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(fcr, FCR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(eflag, EFLAG),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(csd, CSD),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(ssd, SSD),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_REG(ar27, AR_CFLAG),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(fsr, FSR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(fir, FIR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(fdr, FDR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(ccv, CCV),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(unat, UNAT),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(fpsr, FPSR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(itc, ITC),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(pfs, PFS),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(lc, LC),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_AR(ec, EC),
+
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(dcr, DCR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(itm, ITM),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(iva, IVA),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(pta, PTA),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(ipsr, IPSR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(isr, ISR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(iip, IIP),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(ifa, IFA),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(itir, ITIR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(iipa, IIPA),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(ifs, IFS),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(iim, IIM),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(iha, IHA),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(lid, LID),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(ivr, IVR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(tpr, TPR),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(eoi, EOI),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(irr0, IRR0),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(irr1, IRR1),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(irr2, IRR2),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(irr3, IRR3),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(itv, ITV),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(pmv, PMV),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(cmcv, CMCV),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(lrr0, LRR0),
+	IA64_NATIVE_PATCH_BUNDLE_ELEM_CR(lrr1, LRR1),
+};
+
+unsigned long __init_or_module
+ia64_native_patch_bundle(void *sbundle, void *ebundle, unsigned long type)
+{
+	const unsigned long nelems = sizeof(ia64_native_patch_bundle_elems) /
+		sizeof(ia64_native_patch_bundle_elems[0]);
+
+	return __paravirt_patch_apply_bundle(sbundle, ebundle, type,
+					      ia64_native_patch_bundle_elems,
+					      nelems, NULL);
+}
+#endif /* ASM_SUPPOTED */
+
+extern const char ia64_native_switch_to[];
+extern const char ia64_native_leave_syscall[];
+extern const char ia64_native_work_processed_syscall[];
+extern const char ia64_native_leave_kernel[];
+
+const struct paravirt_patch_branch_target ia64_native_branch_target[]
+__initconst = {
+#define PARAVIRT_BR_TARGET(name, type)			\
+	{						\
+		ia64_native_ ## name,			\
+		PARAVIRT_PATCH_TYPE_BR_ ## type,	\
+	}
+	PARAVIRT_BR_TARGET(switch_to, SWITCH_TO),
+	PARAVIRT_BR_TARGET(leave_syscall, LEAVE_SYSCALL),
+	PARAVIRT_BR_TARGET(work_processed_syscall, WORK_PROCESSED_SYSCALL),
+	PARAVIRT_BR_TARGET(leave_kernel, LEAVE_KERNEL),
+};
+
+static void __init
+ia64_native_patch_branch(unsigned long tag, unsigned long type)
+{
+	const unsigned long nelem +		sizeof(ia64_native_branch_target) /
+		sizeof(ia64_native_branch_target[0]);
+	__paravirt_patch_apply_branch(tag, type,
+				      ia64_native_branch_target, nelem);
+}
diff --git a/arch/ia64/kernel/paravirtentry.S b/arch/ia64/kernel/paravirtentry.S
index 733e31a..19e87aa 100644
--- a/arch/ia64/kernel/paravirtentry.S
+++ b/arch/ia64/kernel/paravirtentry.S
@@ -20,8 +20,11 @@
  *
  */
 
+#include <linux/init.h>
 #include <asm/asmmacro.h>
 #include <asm/asm-offsets.h>
+#include <asm/paravirt_privop.h>
+#include <asm/paravirt_patch.h>
 #include "entry.h"
 
 #define DATA8(sym, init_value)			\
@@ -32,32 +35,34 @@
 	data8 init_value ;			\
 	.popsection
 
-#define BRANCH(targ, reg, breg)		\
-	movl reg=targ ;			\
-	;;				\
-	ld8 reg=[reg] ;			\
-	;;				\
-	mov breg=reg ;			\
+#define BRANCH(targ, reg, breg, type)					\
+	PARAVIRT_PATCH_SITE_BR(PARAVIRT_PATCH_TYPE_BR_ ## type) ;	\
+	;;								\
+	movl reg=targ ;							\
+	;;								\
+	ld8 reg=[reg] ;							\
+	;;								\
+	mov breg=reg ;							\
 	br.cond.sptk.many breg
 
-#define BRANCH_PROC(sym, reg, breg)				\
-	DATA8(paravirt_ ## sym ## _targ, ia64_native_ ## sym) ; \
-	GLOBAL_ENTRY(paravirt_ ## sym) ;			\
-		BRANCH(paravirt_ ## sym ## _targ, reg, breg) ;	\
+#define BRANCH_PROC(sym, reg, breg, type)				\
+	DATA8(paravirt_ ## sym ## _targ, ia64_native_ ## sym) ;		\
+	GLOBAL_ENTRY(paravirt_ ## sym) ;				\
+		BRANCH(paravirt_ ## sym ## _targ, reg, breg, type) ;	\
 	END(paravirt_ ## sym)
 
-#define BRANCH_PROC_UNWINFO(sym, reg, breg)			\
-	DATA8(paravirt_ ## sym ## _targ, ia64_native_ ## sym) ; \
-	GLOBAL_ENTRY(paravirt_ ## sym) ;			\
-		PT_REGS_UNWIND_INFO(0) ;			\
-		BRANCH(paravirt_ ## sym ## _targ, reg, breg) ;	\
+#define BRANCH_PROC_UNWINFO(sym, reg, breg, type)			\
+	DATA8(paravirt_ ## sym ## _targ, ia64_native_ ## sym) ;		\
+	GLOBAL_ENTRY(paravirt_ ## sym) ;				\
+		PT_REGS_UNWIND_INFO(0) ;				\
+		BRANCH(paravirt_ ## sym ## _targ, reg, breg, type) ;	\
 	END(paravirt_ ## sym)
 
 
-BRANCH_PROC(switch_to, r22, b7)
-BRANCH_PROC_UNWINFO(leave_syscall, r22, b7)
-BRANCH_PROC(work_processed_syscall, r2, b7)
-BRANCH_PROC_UNWINFO(leave_kernel, r22, b7)
+BRANCH_PROC(switch_to, r22, b7, SWITCH_TO)
+BRANCH_PROC_UNWINFO(leave_syscall, r22, b7, LEAVE_SYSCALL)
+BRANCH_PROC(work_processed_syscall, r2, b7, WORK_PROCESSED_SYSCALL)
+BRANCH_PROC_UNWINFO(leave_kernel, r22, b7, LEAVE_KERNEL)
 
 
 #ifdef CONFIG_MODULES
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 865af27..a76ad4e 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -537,6 +537,7 @@ setup_arch (char **cmdline_p)
 	paravirt_arch_setup_early();
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
+	paravirt_patch_apply();
 
 	*cmdline_p = __va(ia64_boot_param->command_line);
 	strlcpy(boot_command_line, *cmdline_p, COMMAND_LINE_SIZE);
-- 
1.6.0.2


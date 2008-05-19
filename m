From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 13:13:34 +0000
Subject: [PATCH 07/17] ia64/pv_ops: introduce pv_cpu_ops to paravirtualize privileged instructions.
Message-Id: <121120282528-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

introduce pv_cpu_ops to paravirtualize privleged instructions
which are defined by ia64 intrinsics.
make them indirect C function calls by introducing function
tables, pv_cpu_ops.

Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/paravirt.c        |  247 ++++++++++++++++++++++++++++++++++++
 include/asm-ia64/Kbuild            |    2 +-
 include/asm-ia64/gcc_intrin.h      |   24 ++--
 include/asm-ia64/intel_intrin.h    |   41 +++---
 include/asm-ia64/intrinsics.h      |   62 ++++++++--
 include/asm-ia64/paravirt_privop.h |   91 +++++++++++++
 6 files changed, 425 insertions(+), 42 deletions(-)
 create mode 100644 include/asm-ia64/paravirt_privop.h

diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index d295ea5..e5482bb 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -26,6 +26,7 @@
 #include <linux/compiler.h>
 #include <linux/io.h>
 #include <linux/irq.h>
+#include <linux/module.h>
 #include <linux/types.h>
 
 #include <asm/iosapic.h>
@@ -39,3 +40,249 @@ struct pv_info pv_info = {
 	.paravirt_enabled = 0,
 	.name = "bare hardware"
 };
+
+/***************************************************************************
+ * pv_cpu_ops
+ * intrinsics hooks.
+ */
+
+/* ia64_native_xxx are macros so that we have to make them real functions */
+
+#define DEFINE_VOID_FUNC1(name)					\
+	static void						\
+	ia64_native_ ## name ## _func(unsigned long arg)	\
+	{							\
+		ia64_native_ ## name(arg);			\
+	}							\
+
+#define DEFINE_VOID_FUNC2(name)					\
+	static void						\
+	ia64_native_ ## name ## _func(unsigned long arg0,	\
+				      unsigned long arg1)	\
+	{							\
+		ia64_native_ ## name(arg0, arg1);		\
+	}							\
+
+#define DEFINE_FUNC0(name)			\
+	static unsigned long			\
+	ia64_native_ ## name ## _func(void)	\
+	{					\
+		return ia64_native_ ## name();	\
+	}
+
+#define DEFINE_FUNC1(name, type)			\
+	static unsigned long				\
+	ia64_native_ ## name ## _func(type arg)		\
+	{						\
+		return ia64_native_ ## name(arg);	\
+	}						\
+
+DEFINE_VOID_FUNC1(fc);
+DEFINE_VOID_FUNC1(intrin_local_irq_restore);
+
+DEFINE_VOID_FUNC2(ptcga);
+DEFINE_VOID_FUNC2(set_rr);
+
+DEFINE_FUNC0(get_psr_i);
+
+DEFINE_FUNC1(thash, unsigned long);
+DEFINE_FUNC1(get_cpuid, int);
+DEFINE_FUNC1(get_pmd, int);
+DEFINE_FUNC1(get_rr, unsigned long);
+
+static void
+ia64_native_ssm_i_func(void)
+{
+	ia64_native_ssm(IA64_PSR_I);
+}
+
+static void
+ia64_native_rsm_i_func(void)
+{
+	ia64_native_rsm(IA64_PSR_I);
+}
+
+static void
+ia64_native_set_rr0_to_rr4_func(unsigned long val0, unsigned long val1,
+				unsigned long val2, unsigned long val3,
+				unsigned long val4)
+{
+	ia64_native_set_rr0_to_rr4(val0, val1, val2, val3, val4);
+}
+
+#define CASE_GET_REG(id)				\
+	case _IA64_REG_ ## id:				\
+	res = ia64_native_getreg(_IA64_REG_ ## id);	\
+	break;
+#define CASE_GET_AR(id) CASE_GET_REG(AR_ ## id)
+#define CASE_GET_CR(id) CASE_GET_REG(CR_ ## id)
+
+unsigned long
+ia64_native_getreg_func(int regnum)
+{
+	unsigned long res = -1;
+	switch (regnum) {
+	CASE_GET_REG(GP);
+	CASE_GET_REG(IP);
+	CASE_GET_REG(PSR);
+	CASE_GET_REG(TP);
+	CASE_GET_REG(SP);
+
+	CASE_GET_AR(KR0);
+	CASE_GET_AR(KR1);
+	CASE_GET_AR(KR2);
+	CASE_GET_AR(KR3);
+	CASE_GET_AR(KR4);
+	CASE_GET_AR(KR5);
+	CASE_GET_AR(KR6);
+	CASE_GET_AR(KR7);
+	CASE_GET_AR(RSC);
+	CASE_GET_AR(BSP);
+	CASE_GET_AR(BSPSTORE);
+	CASE_GET_AR(RNAT);
+	CASE_GET_AR(FCR);
+	CASE_GET_AR(EFLAG);
+	CASE_GET_AR(CSD);
+	CASE_GET_AR(SSD);
+	CASE_GET_AR(CFLAG);
+	CASE_GET_AR(FSR);
+	CASE_GET_AR(FIR);
+	CASE_GET_AR(FDR);
+	CASE_GET_AR(CCV);
+	CASE_GET_AR(UNAT);
+	CASE_GET_AR(FPSR);
+	CASE_GET_AR(ITC);
+	CASE_GET_AR(PFS);
+	CASE_GET_AR(LC);
+	CASE_GET_AR(EC);
+
+	CASE_GET_CR(DCR);
+	CASE_GET_CR(ITM);
+	CASE_GET_CR(IVA);
+	CASE_GET_CR(PTA);
+	CASE_GET_CR(IPSR);
+	CASE_GET_CR(ISR);
+	CASE_GET_CR(IIP);
+	CASE_GET_CR(IFA);
+	CASE_GET_CR(ITIR);
+	CASE_GET_CR(IIPA);
+	CASE_GET_CR(IFS);
+	CASE_GET_CR(IIM);
+	CASE_GET_CR(IHA);
+	CASE_GET_CR(LID);
+	CASE_GET_CR(IVR);
+	CASE_GET_CR(TPR);
+	CASE_GET_CR(EOI);
+	CASE_GET_CR(IRR0);
+	CASE_GET_CR(IRR1);
+	CASE_GET_CR(IRR2);
+	CASE_GET_CR(IRR3);
+	CASE_GET_CR(ITV);
+	CASE_GET_CR(PMV);
+	CASE_GET_CR(CMCV);
+	CASE_GET_CR(LRR0);
+	CASE_GET_CR(LRR1);
+
+	default:
+		printk(KERN_CRIT "wrong_getreg %d\n", regnum);
+		break;
+	}
+	return res;
+}
+
+#define CASE_SET_REG(id)				\
+	case _IA64_REG_ ## id:				\
+	ia64_native_setreg(_IA64_REG_ ## id, val);	\
+	break;
+#define CASE_SET_AR(id) CASE_SET_REG(AR_ ## id)
+#define CASE_SET_CR(id) CASE_SET_REG(CR_ ## id)
+
+void
+ia64_native_setreg_func(int regnum, unsigned long val)
+{
+	switch (regnum) {
+	case _IA64_REG_PSR_L:
+		ia64_native_setreg(_IA64_REG_PSR_L, val);
+		ia64_dv_serialize_data();
+		break;
+	CASE_SET_REG(SP);
+	CASE_SET_REG(GP);
+
+	CASE_SET_AR(KR0);
+	CASE_SET_AR(KR1);
+	CASE_SET_AR(KR2);
+	CASE_SET_AR(KR3);
+	CASE_SET_AR(KR4);
+	CASE_SET_AR(KR5);
+	CASE_SET_AR(KR6);
+	CASE_SET_AR(KR7);
+	CASE_SET_AR(RSC);
+	CASE_SET_AR(BSP);
+	CASE_SET_AR(BSPSTORE);
+	CASE_SET_AR(RNAT);
+	CASE_SET_AR(FCR);
+	CASE_SET_AR(EFLAG);
+	CASE_SET_AR(CSD);
+	CASE_SET_AR(SSD);
+	CASE_SET_AR(CFLAG);
+	CASE_SET_AR(FSR);
+	CASE_SET_AR(FIR);
+	CASE_SET_AR(FDR);
+	CASE_SET_AR(CCV);
+	CASE_SET_AR(UNAT);
+	CASE_SET_AR(FPSR);
+	CASE_SET_AR(ITC);
+	CASE_SET_AR(PFS);
+	CASE_SET_AR(LC);
+	CASE_SET_AR(EC);
+
+	CASE_SET_CR(DCR);
+	CASE_SET_CR(ITM);
+	CASE_SET_CR(IVA);
+	CASE_SET_CR(PTA);
+	CASE_SET_CR(IPSR);
+	CASE_SET_CR(ISR);
+	CASE_SET_CR(IIP);
+	CASE_SET_CR(IFA);
+	CASE_SET_CR(ITIR);
+	CASE_SET_CR(IIPA);
+	CASE_SET_CR(IFS);
+	CASE_SET_CR(IIM);
+	CASE_SET_CR(IHA);
+	CASE_SET_CR(LID);
+	CASE_SET_CR(IVR);
+	CASE_SET_CR(TPR);
+	CASE_SET_CR(EOI);
+	CASE_SET_CR(IRR0);
+	CASE_SET_CR(IRR1);
+	CASE_SET_CR(IRR2);
+	CASE_SET_CR(IRR3);
+	CASE_SET_CR(ITV);
+	CASE_SET_CR(PMV);
+	CASE_SET_CR(CMCV);
+	CASE_SET_CR(LRR0);
+	CASE_SET_CR(LRR1);
+	default:
+		printk(KERN_CRIT "wrong setreg %d\n", regnum);
+		break;
+	}
+}
+
+struct pv_cpu_ops pv_cpu_ops = {
+	.fc		= ia64_native_fc_func,
+	.thash		= ia64_native_thash_func,
+	.get_cpuid	= ia64_native_get_cpuid_func,
+	.get_pmd	= ia64_native_get_pmd_func,
+	.ptcga		= ia64_native_ptcga_func,
+	.get_rr		= ia64_native_get_rr_func,
+	.set_rr		= ia64_native_set_rr_func,
+	.set_rr0_to_rr4	= ia64_native_set_rr0_to_rr4_func,
+	.ssm_i		= ia64_native_ssm_i_func,
+	.getreg		= ia64_native_getreg_func,
+	.setreg		= ia64_native_setreg_func,
+	.rsm_i		= ia64_native_rsm_i_func,
+	.get_psr_i	= ia64_native_get_psr_i_func,
+	.intrin_local_irq_restore
+			= ia64_native_intrin_local_irq_restore_func,
+};
+EXPORT_SYMBOL(pv_cpu_ops);
diff --git a/include/asm-ia64/Kbuild b/include/asm-ia64/Kbuild
index eb24a3f..ccbe8ae 100644
--- a/include/asm-ia64/Kbuild
+++ b/include/asm-ia64/Kbuild
@@ -5,12 +5,12 @@ header-y += fpu.h
 header-y += fpswa.h
 header-y += ia64regs.h
 header-y += intel_intrin.h
-header-y += intrinsics.h
 header-y += perfmon_default_smpl.h
 header-y += ptrace_offsets.h
 header-y += rse.h
 header-y += ucontext.h
 
 unifdef-y += gcc_intrin.h
+unifdef-y += intrinsics.h
 unifdef-y += perfmon.h
 unifdef-y += ustack.h
diff --git a/include/asm-ia64/gcc_intrin.h b/include/asm-ia64/gcc_intrin.h
index 2fe292c..0f5b559 100644
--- a/include/asm-ia64/gcc_intrin.h
+++ b/include/asm-ia64/gcc_intrin.h
@@ -32,7 +32,7 @@ extern void ia64_bad_param_for_getreg (void);
 register unsigned long ia64_r13 asm ("r13") __used;
 #endif
 
-#define ia64_setreg(regnum, val)						\
+#define ia64_native_setreg(regnum, val)						\
 ({										\
 	switch (regnum) {							\
 	    case _IA64_REG_PSR_L:						\
@@ -61,7 +61,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 	}									\
 })
 
-#define ia64_getreg(regnum)							\
+#define ia64_native_getreg(regnum)						\
 ({										\
 	__u64 ia64_intri_res;							\
 										\
@@ -385,7 +385,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 
 #define ia64_invala() asm volatile ("invala" ::: "memory")
 
-#define ia64_thash(addr)							\
+#define ia64_native_thash(addr)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("thash %0=%1" : "=r"(ia64_intri_res) : "r" (addr));	\
@@ -438,10 +438,10 @@ register unsigned long ia64_r13 asm ("r13") __used;
 #define ia64_set_pmd(index, val)						\
 	asm volatile ("mov pmd[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_rr(index, val)							\
+#define ia64_native_set_rr(index, val)							\
 	asm volatile ("mov rr[%0]=%1" :: "r"(index), "r"(val) : "memory");
 
-#define ia64_get_cpuid(index)								\
+#define ia64_native_get_cpuid(index)							\
 ({											\
 	__u64 ia64_intri_res;								\
 	asm volatile ("mov %0=cpuid[%r1]" : "=r"(ia64_intri_res) : "rO"(index));	\
@@ -477,33 +477,33 @@ register unsigned long ia64_r13 asm ("r13") __used;
 })
 
 
-#define ia64_get_pmd(index)							\
+#define ia64_native_get_pmd(index)						\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pmd[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_rr(index)							\
+#define ia64_native_get_rr(index)						\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=rr[%1]" : "=r"(ia64_intri_res) : "r" (index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
+#define ia64_native_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
 
 
 #define ia64_sync_i()	asm volatile (";; sync.i" ::: "memory")
 
-#define ia64_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
-#define ia64_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
+#define ia64_native_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
+#define ia64_native_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
 #define ia64_sum(mask)	asm volatile ("sum %0":: "i"((mask)) : "memory")
 #define ia64_rum(mask)	asm volatile ("rum %0":: "i"((mask)) : "memory")
 
 #define ia64_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
 
-#define ia64_ptcga(addr, size)							\
+#define ia64_native_ptcga(addr, size)						\
 do {										\
 	asm volatile ("ptc.ga %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
@@ -608,7 +608,7 @@ do {										\
         }								\
 })
 
-#define ia64_intrin_local_irq_restore(x)			\
+#define ia64_native_intrin_local_irq_restore(x)			\
 do {								\
 	asm volatile (";;   cmp.ne p6,p7=%0,r0;;"		\
 		      "(p6) ssm psr.i;"				\
diff --git a/include/asm-ia64/intel_intrin.h b/include/asm-ia64/intel_intrin.h
index a520d10..53cec57 100644
--- a/include/asm-ia64/intel_intrin.h
+++ b/include/asm-ia64/intel_intrin.h
@@ -16,8 +16,8 @@
 		 	 * intrinsic
 		 	 */
 
-#define ia64_getreg		__getReg
-#define ia64_setreg		__setReg
+#define ia64_native_getreg	__getReg
+#define ia64_native_setreg	__setReg
 
 #define ia64_hint		__hint
 #define ia64_hint_pause		__hint_pause
@@ -39,10 +39,10 @@
 #define ia64_invala_fr		__invala_fr
 #define ia64_nop		__nop
 #define ia64_sum		__sum
-#define ia64_ssm		__ssm
+#define ia64_native_ssm		__ssm
 #define ia64_rum		__rum
-#define ia64_rsm		__rsm
-#define ia64_fc 		__fc
+#define ia64_native_rsm		__rsm
+#define ia64_native_fc 		__fc
 
 #define ia64_ldfs		__ldfs
 #define ia64_ldfd		__ldfd
@@ -88,16 +88,17 @@
 		__setIndReg(_IA64_REG_INDR_PMC, index, val)
 #define ia64_set_pmd(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMD, index, val)
-#define ia64_set_rr(index, val)	\
+#define ia64_native_set_rr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_RR, index, val)
 
-#define ia64_get_cpuid(index) 	__getIndReg(_IA64_REG_INDR_CPUID, index)
-#define __ia64_get_dbr(index) 	__getIndReg(_IA64_REG_INDR_DBR, index)
-#define ia64_get_ibr(index) 	__getIndReg(_IA64_REG_INDR_IBR, index)
-#define ia64_get_pkr(index) 	__getIndReg(_IA64_REG_INDR_PKR, index)
-#define ia64_get_pmc(index) 	__getIndReg(_IA64_REG_INDR_PMC, index)
-#define ia64_get_pmd(index)  	__getIndReg(_IA64_REG_INDR_PMD, index)
-#define ia64_get_rr(index) 	__getIndReg(_IA64_REG_INDR_RR, index)
+#define ia64_native_get_cpuid(index)	\
+		__getIndReg(_IA64_REG_INDR_CPUID, index)
+#define __ia64_get_dbr(index)		__getIndReg(_IA64_REG_INDR_DBR, index)
+#define ia64_get_ibr(index)		__getIndReg(_IA64_REG_INDR_IBR, index)
+#define ia64_get_pkr(index)		__getIndReg(_IA64_REG_INDR_PKR, index)
+#define ia64_get_pmc(index)		__getIndReg(_IA64_REG_INDR_PMC, index)
+#define ia64_native_get_pmd(index)	__getIndReg(_IA64_REG_INDR_PMD, index)
+#define ia64_native_get_rr(index)	__getIndReg(_IA64_REG_INDR_RR, index)
 
 #define ia64_srlz_d		__dsrlz
 #define ia64_srlz_i		__isrlz
@@ -119,16 +120,16 @@
 #define ia64_ld8_acq		__ld8_acq
 
 #define ia64_sync_i		__synci
-#define ia64_thash		__thash
-#define ia64_ttag		__ttag
+#define ia64_native_thash	__thash
+#define ia64_native_ttag	__ttag
 #define ia64_itcd		__itcd
 #define ia64_itci		__itci
 #define ia64_itrd		__itrd
 #define ia64_itri		__itri
 #define ia64_ptce		__ptce
 #define ia64_ptcl		__ptcl
-#define ia64_ptcg		__ptcg
-#define ia64_ptcga		__ptcga
+#define ia64_native_ptcg	__ptcg
+#define ia64_native_ptcga	__ptcga
 #define ia64_ptri		__ptri
 #define ia64_ptrd		__ptrd
 #define ia64_dep_mi		_m64_dep_mi
@@ -145,13 +146,13 @@
 #define ia64_lfetch_fault	__lfetch_fault
 #define ia64_lfetch_fault_excl	__lfetch_fault_excl
 
-#define ia64_intrin_local_irq_restore(x)		\
+#define ia64_native_intrin_local_irq_restore(x)		\
 do {							\
 	if ((x) != 0) {					\
-		ia64_ssm(IA64_PSR_I);			\
+		ia64_native_ssm(IA64_PSR_I);		\
 		ia64_srlz_d();				\
 	} else {					\
-		ia64_rsm(IA64_PSR_I);			\
+		ia64_native_rsm(IA64_PSR_I);		\
 	}						\
 } while (0)
 
diff --git a/include/asm-ia64/intrinsics.h b/include/asm-ia64/intrinsics.h
index a3b9689..47d686d 100644
--- a/include/asm-ia64/intrinsics.h
+++ b/include/asm-ia64/intrinsics.h
@@ -18,15 +18,15 @@
 # include <asm/gcc_intrin.h>
 #endif
 
-#define ia64_get_psr_i()	(ia64_getreg(_IA64_REG_PSR) & IA64_PSR_I)
-
-#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
-do {								\
-	ia64_set_rr(0x0000000000000000UL, (val0));		\
-	ia64_set_rr(0x2000000000000000UL, (val1));		\
-	ia64_set_rr(0x4000000000000000UL, (val2));		\
-	ia64_set_rr(0x6000000000000000UL, (val3));		\
-	ia64_set_rr(0x8000000000000000UL, (val4));		\
+#define ia64_native_get_psr_i()	(ia64_native_getreg(_IA64_REG_PSR) & IA64_PSR_I)
+
+#define ia64_native_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
+do {									\
+	ia64_native_set_rr(0x0000000000000000UL, (val0));		\
+	ia64_native_set_rr(0x2000000000000000UL, (val1));		\
+	ia64_native_set_rr(0x4000000000000000UL, (val2));		\
+	ia64_native_set_rr(0x6000000000000000UL, (val3));		\
+	ia64_native_set_rr(0x8000000000000000UL, (val4));		\
 } while (0)
 
 /*
@@ -194,4 +194,48 @@ extern long ia64_cmpxchg_called_with_bad_pointer (void);
 #endif /* !CONFIG_IA64_DEBUG_CMPXCHG */
 
 #endif
+
+#ifdef __KERNEL__
+#include <asm/paravirt_privop.h>
+#endif
+
+#ifndef __ASSEMBLY__
+#if defined(CONFIG_PARAVIRT) && defined(__KERNEL__)
+#define IA64_INTRINSIC_API(name)	pv_cpu_ops.name
+#define IA64_INTRINSIC_MACRO(name)	paravirt_ ## name
+#else
+#define IA64_INTRINSIC_API(name)	ia64_native_ ## name
+#define IA64_INTRINSIC_MACRO(name)	ia64_native_ ## name
+#endif
+
+/************************************************/
+/* Instructions paravirtualized for correctness */
+/************************************************/
+/* fc, thash, get_cpuid, get_pmd, get_eflags, set_eflags */
+/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
+ * is not currently used (though it may be in a long-format VHPT system!)
+ */
+#define ia64_fc				IA64_INTRINSIC_API(fc)
+#define ia64_thash			IA64_INTRINSIC_API(thash)
+#define ia64_get_cpuid			IA64_INTRINSIC_API(get_cpuid)
+#define ia64_get_pmd			IA64_INTRINSIC_API(get_pmd)
+
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+#define ia64_ssm			IA64_INTRINSIC_MACRO(ssm)
+#define ia64_rsm			IA64_INTRINSIC_MACRO(rsm)
+#define ia64_getreg			IA64_INTRINSIC_API(getreg)
+#define ia64_setreg			IA64_INTRINSIC_API(setreg)
+#define ia64_set_rr			IA64_INTRINSIC_API(set_rr)
+#define ia64_get_rr			IA64_INTRINSIC_API(get_rr)
+#define ia64_ptcga			IA64_INTRINSIC_API(ptcga)
+#define ia64_get_psr_i			IA64_INTRINSIC_API(get_psr_i)
+#define ia64_intrin_local_irq_restore	\
+	IA64_INTRINSIC_API(intrin_local_irq_restore)
+#define ia64_set_rr0_to_rr4		IA64_INTRINSIC_API(set_rr0_to_rr4)
+
+#endif /* !__ASSEMBLY__ */
+
 #endif /* _ASM_IA64_INTRINSICS_H */
diff --git a/include/asm-ia64/paravirt_privop.h b/include/asm-ia64/paravirt_privop.h
new file mode 100644
index 0000000..7b133ae
--- /dev/null
+++ b/include/asm-ia64/paravirt_privop.h
@@ -0,0 +1,91 @@
+/******************************************************************************
+ * include/asm-ia64/paravirt_privops.h
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _ASM_IA64_PARAVIRT_PRIVOP_H
+#define _ASM_IA64_PARAVIRT_PRIVOP_H
+
+#ifdef CONFIG_PARAVIRT
+
+#ifndef __ASSEMBLY__
+
+#include <linux/types.h>
+#include <asm/kregs.h> /* for IA64_PSR_I */
+
+/******************************************************************************
+ * replacement of intrinsics operations.
+ */
+
+struct pv_cpu_ops {
+	void (*fc)(unsigned long addr);
+	unsigned long (*thash)(unsigned long addr);
+	unsigned long (*get_cpuid)(int index);
+	unsigned long (*get_pmd)(int index);
+	unsigned long (*getreg)(int reg);
+	void (*setreg)(int reg, unsigned long val);
+	void (*ptcga)(unsigned long addr, unsigned long size);
+	unsigned long (*get_rr)(unsigned long index);
+	void (*set_rr)(unsigned long index, unsigned long val);
+	void (*set_rr0_to_rr4)(unsigned long val0, unsigned long val1,
+			       unsigned long val2, unsigned long val3,
+			       unsigned long val4);
+	void (*ssm_i)(void);
+	void (*rsm_i)(void);
+	unsigned long (*get_psr_i)(void);
+	void (*intrin_local_irq_restore)(unsigned long flags);
+};
+
+extern struct pv_cpu_ops pv_cpu_ops;
+
+extern void ia64_native_setreg_func(int regnum, unsigned long val);
+extern unsigned long ia64_native_getreg_func(int regnum);
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+
+/* mask for ia64_native_ssm/rsm() must be constant.("i" constraing).
+ * static inline function doesn't satisfy it. */
+#define paravirt_ssm(mask)			\
+	do {					\
+		if ((mask) = IA64_PSR_I)	\
+			pv_cpu_ops.ssm_i();	\
+		else				\
+			ia64_native_ssm(mask);	\
+	} while (0)
+
+#define paravirt_rsm(mask)			\
+	do {					\
+		if ((mask) = IA64_PSR_I)	\
+			pv_cpu_ops.rsm_i();	\
+		else				\
+			ia64_native_rsm(mask);	\
+	} while (0)
+
+#endif /* __ASSEMBLY__ */
+
+#else
+
+/* fallback for native case */
+
+#endif /* CONFIG_PARAVIRT */
+
+#endif /* _ASM_IA64_PARAVIRT_PRIVOP_H */
-- 
1.5.3


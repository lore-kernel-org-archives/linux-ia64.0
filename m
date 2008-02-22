From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:28 +0000
Subject: [PATCH 10/28] ia64/xen: introduce xen paravirtualized intrinsic operations for privileged instructio
Message-Id: <12036570473611-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/hypercall.S       |  124 ++++++++++
 include/asm-ia64/gcc_intrin.h   |   58 +++---
 include/asm-ia64/intel_intrin.h |   64 +++---
 include/asm-ia64/intrinsics.h   |   14 +-
 include/asm-ia64/privop.h       |   36 +++
 include/asm-ia64/xen/privop.h   |  489 +++++++++++++++++++++++++++++++++++++++
 6 files changed, 717 insertions(+), 68 deletions(-)
 create mode 100644 arch/ia64/xen/hypercall.S

diff --git a/arch/ia64/xen/hypercall.S b/arch/ia64/xen/hypercall.S
new file mode 100644
index 0000000..a96f278
--- /dev/null
+++ b/arch/ia64/xen/hypercall.S
@@ -0,0 +1,124 @@
+/*
+ * Support routines for Xen hypercalls
+ *
+ * Copyright (C) 2005 Dan Magenheimer <dan.magenheimer@hp.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/intrinsics.h>
+
+#ifdef __INTEL_COMPILER
+# undef ASM_SUPPORTED
+#else
+# define ASM_SUPPORTED
+#endif
+
+#ifndef ASM_SUPPORTED
+GLOBAL_ENTRY(xen_get_psr)
+	XEN_HYPER_GET_PSR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_psr)
+
+GLOBAL_ENTRY(xen_get_ivr)
+	XEN_HYPER_GET_IVR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_ivr)
+
+GLOBAL_ENTRY(xen_get_tpr)
+	XEN_HYPER_GET_TPR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_tpr)
+
+GLOBAL_ENTRY(xen_set_tpr)
+	mov r8=r32
+	XEN_HYPER_SET_TPR
+	br.ret.sptk.many rp
+	;;
+END(xen_set_tpr)
+
+GLOBAL_ENTRY(xen_eoi)
+	mov r8=r32
+	XEN_HYPER_EOI
+	br.ret.sptk.many rp
+	;;
+END(xen_eoi)
+
+GLOBAL_ENTRY(xen_thash)
+	mov r8=r32
+	XEN_HYPER_THASH
+	br.ret.sptk.many rp
+	;;
+END(xen_thash)
+
+GLOBAL_ENTRY(xen_set_itm)
+	mov r8=r32
+	XEN_HYPER_SET_ITM
+	br.ret.sptk.many rp
+	;;
+END(xen_set_itm)
+
+GLOBAL_ENTRY(xen_ptcga)
+	mov r8=r32
+	mov r9=r33
+	XEN_HYPER_PTC_GA
+	br.ret.sptk.many rp
+	;;
+END(xen_ptcga)
+
+GLOBAL_ENTRY(xen_get_rr)
+	mov r8=r32
+	XEN_HYPER_GET_RR
+	br.ret.sptk.many rp
+	;;
+END(xen_get_rr)
+
+GLOBAL_ENTRY(xen_set_rr)
+	mov r8=r32
+	mov r9=r33
+	XEN_HYPER_SET_RR
+	br.ret.sptk.many rp
+	;;
+END(xen_set_rr)
+
+GLOBAL_ENTRY(xen_set_kr)
+	mov r8=r32
+	mov r9=r33
+	XEN_HYPER_SET_KR
+	br.ret.sptk.many rp
+END(xen_set_kr)
+
+GLOBAL_ENTRY(xen_fc)
+	mov r8=r32
+	XEN_HYPER_FC
+	br.ret.sptk.many rp
+END(xen_fc)
+
+GLOBAL_ENTRY(xen_get_cpuid)
+	mov r8=r32
+	XEN_HYPER_GET_CPUID
+	br.ret.sptk.many rp
+END(xen_get_cpuid)
+
+GLOBAL_ENTRY(xen_get_pmd)
+	mov r8=r32
+	XEN_HYPER_GET_PMD
+	br.ret.sptk.many rp
+END(xen_get_pmd)
+
+#ifdef CONFIG_IA32_SUPPORT
+GLOBAL_ENTRY(xen_get_eflag)
+	XEN_HYPER_GET_EFLAG
+	br.ret.sptk.many rp
+END(xen_get_eflag)
+
+// some bits aren't set if pl!=0, see SDM vol1 3.1.8
+GLOBAL_ENTRY(xen_set_eflag)
+	mov r8=r32
+	XEN_HYPER_SET_EFLAG
+	br.ret.sptk.many rp
+END(xen_set_eflag)
+#endif /* CONFIG_IA32_SUPPORT */
+#endif /* ASM_SUPPORTED */
diff --git a/include/asm-ia64/gcc_intrin.h b/include/asm-ia64/gcc_intrin.h
index de2ed2c..5fe2932 100644
--- a/include/asm-ia64/gcc_intrin.h
+++ b/include/asm-ia64/gcc_intrin.h
@@ -28,7 +28,7 @@ extern void ia64_bad_param_for_getreg (void);
 register unsigned long ia64_r13 asm ("r13") __used;
 #endif
 
-#define ia64_setreg(regnum, val)						\
+#define __ia64_setreg(regnum, val)						\
 ({										\
 	switch (regnum) {							\
 	    case _IA64_REG_PSR_L:						\
@@ -57,7 +57,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 	}									\
 })
 
-#define ia64_getreg(regnum)							\
+#define __ia64_getreg(regnum)							\
 ({										\
 	__u64 ia64_intri_res;							\
 										\
@@ -94,7 +94,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 
 #define ia64_hint_pause 0
 
-#define ia64_hint(mode)						\
+#define __ia64_hint(mode)						\
 ({								\
 	switch (mode) {						\
 	case ia64_hint_pause:					\
@@ -381,7 +381,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 
 #define ia64_invala() asm volatile ("invala" ::: "memory")
 
-#define ia64_thash(addr)							\
+#define __ia64_thash(addr)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("thash %0=%1" : "=r"(ia64_intri_res) : "r" (addr));	\
@@ -401,18 +401,18 @@ register unsigned long ia64_r13 asm ("r13") __used;
 
 #define ia64_nop(x)	asm volatile ("nop %0"::"i"(x));
 
-#define ia64_itci(addr)	asm volatile ("itc.i %0;;" :: "r"(addr) : "memory")
+#define __ia64_itci(addr)	asm volatile ("itc.i %0;;" :: "r"(addr) : "memory")
 
-#define ia64_itcd(addr)	asm volatile ("itc.d %0;;" :: "r"(addr) : "memory")
+#define __ia64_itcd(addr)	asm volatile ("itc.d %0;;" :: "r"(addr) : "memory")
 
 
-#define ia64_itri(trnum, addr) asm volatile ("itr.i itr[%0]=%1"				\
+#define __ia64_itri(trnum, addr) asm volatile ("itr.i itr[%0]=%1"			\
 					     :: "r"(trnum), "r"(addr) : "memory")
 
-#define ia64_itrd(trnum, addr) asm volatile ("itr.d dtr[%0]=%1"				\
+#define __ia64_itrd(trnum, addr) asm volatile ("itr.d dtr[%0]=%1"			\
 					     :: "r"(trnum), "r"(addr) : "memory")
 
-#define ia64_tpa(addr)								\
+#define __ia64_tpa(addr)							\
 ({										\
 	__u64 ia64_pa;								\
 	asm volatile ("tpa %0 = %1" : "=r"(ia64_pa) : "r"(addr) : "memory");	\
@@ -422,22 +422,22 @@ register unsigned long ia64_r13 asm ("r13") __used;
 #define __ia64_set_dbr(index, val)						\
 	asm volatile ("mov dbr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_ibr(index, val)						\
+#define __ia64_set_ibr(index, val)						\
 	asm volatile ("mov ibr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pkr(index, val)						\
+#define __ia64_set_pkr(index, val)						\
 	asm volatile ("mov pkr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pmc(index, val)						\
+#define __ia64_set_pmc(index, val)						\
 	asm volatile ("mov pmc[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pmd(index, val)						\
+#define __ia64_set_pmd(index, val)						\
 	asm volatile ("mov pmd[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_rr(index, val)							\
+#define __ia64_set_rr(index, val)							\
 	asm volatile ("mov rr[%0]=%1" :: "r"(index), "r"(val) : "memory");
 
-#define ia64_get_cpuid(index)								\
+#define __ia64_get_cpuid(index)								\
 ({											\
 	__u64 ia64_intri_res;								\
 	asm volatile ("mov %0=cpuid[%r1]" : "=r"(ia64_intri_res) : "rO"(index));	\
@@ -451,21 +451,21 @@ register unsigned long ia64_r13 asm ("r13") __used;
 	ia64_intri_res;								\
 })
 
-#define ia64_get_ibr(index)							\
+#define __ia64_get_ibr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=ibr[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_pkr(index)							\
+#define __ia64_get_pkr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pkr[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_pmc(index)							\
+#define __ia64_get_pmc(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pmc[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
@@ -473,48 +473,48 @@ register unsigned long ia64_r13 asm ("r13") __used;
 })
 
 
-#define ia64_get_pmd(index)							\
+#define __ia64_get_pmd(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pmd[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_rr(index)							\
+#define __ia64_get_rr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=rr[%1]" : "=r"(ia64_intri_res) : "r" (index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
+#define __ia64_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
 
 
 #define ia64_sync_i()	asm volatile (";; sync.i" ::: "memory")
 
-#define ia64_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
-#define ia64_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
+#define __ia64_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
+#define __ia64_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
 #define ia64_sum(mask)	asm volatile ("sum %0":: "i"((mask)) : "memory")
 #define ia64_rum(mask)	asm volatile ("rum %0":: "i"((mask)) : "memory")
 
-#define ia64_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
+#define __ia64_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
 
-#define ia64_ptcga(addr, size)							\
+#define __ia64_ptcga(addr, size)							\
 do {										\
 	asm volatile ("ptc.ga %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
 } while (0)
 
-#define ia64_ptcl(addr, size)							\
+#define __ia64_ptcl(addr, size)							\
 do {										\
 	asm volatile ("ptc.l %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
 } while (0)
 
-#define ia64_ptri(addr, size)						\
+#define __ia64_ptri(addr, size)						\
 	asm volatile ("ptr.i %0,%1" :: "r"(addr), "r"(size) : "memory")
 
-#define ia64_ptrd(addr, size)						\
+#define __ia64_ptrd(addr, size)						\
 	asm volatile ("ptr.d %0,%1" :: "r"(addr), "r"(size) : "memory")
 
 /* Values for lfhint in ia64_lfetch and ia64_lfetch_fault */
@@ -596,7 +596,7 @@ do {										\
         }								\
 })
 
-#define ia64_intrin_local_irq_restore(x)			\
+#define __ia64_intrin_local_irq_restore(x)			\
 do {								\
 	asm volatile (";;   cmp.ne p6,p7=%0,r0;;"		\
 		      "(p6) ssm psr.i;"				\
diff --git a/include/asm-ia64/intel_intrin.h b/include/asm-ia64/intel_intrin.h
index a520d10..83ee398 100644
--- a/include/asm-ia64/intel_intrin.h
+++ b/include/asm-ia64/intel_intrin.h
@@ -16,8 +16,8 @@
 		 	 * intrinsic
 		 	 */
 
-#define ia64_getreg		__getReg
-#define ia64_setreg		__setReg
+#define __ia64_getreg		__getReg
+#define __ia64_setreg		__setReg
 
 #define ia64_hint		__hint
 #define ia64_hint_pause		__hint_pause
@@ -33,16 +33,16 @@
 #define ia64_getf_exp		__getf_exp
 #define ia64_shrp		_m64_shrp
 
-#define ia64_tpa		__tpa
+#define __ia64_tpa		__tpa
 #define ia64_invala		__invala
 #define ia64_invala_gr		__invala_gr
 #define ia64_invala_fr		__invala_fr
 #define ia64_nop		__nop
 #define ia64_sum		__sum
-#define ia64_ssm		__ssm
+#define __ia64_ssm		__ssm
 #define ia64_rum		__rum
-#define ia64_rsm		__rsm
-#define ia64_fc 		__fc
+#define __ia64_rsm		__rsm
+#define __ia64_fc 		__fc
 
 #define ia64_ldfs		__ldfs
 #define ia64_ldfd		__ldfd
@@ -80,24 +80,24 @@
 
 #define __ia64_set_dbr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_DBR, index, val)
-#define ia64_set_ibr(index, val)	\
+#define __ia64_set_ibr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_IBR, index, val)
-#define ia64_set_pkr(index, val)	\
+#define __ia64_set_pkr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PKR, index, val)
-#define ia64_set_pmc(index, val)	\
+#define __ia64_set_pmc(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMC, index, val)
-#define ia64_set_pmd(index, val)	\
+#define __ia64_set_pmd(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMD, index, val)
-#define ia64_set_rr(index, val)	\
+#define __ia64_set_rr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_RR, index, val)
 
-#define ia64_get_cpuid(index) 	__getIndReg(_IA64_REG_INDR_CPUID, index)
+#define __ia64_get_cpuid(index) 	__getIndReg(_IA64_REG_INDR_CPUID, index)
 #define __ia64_get_dbr(index) 	__getIndReg(_IA64_REG_INDR_DBR, index)
-#define ia64_get_ibr(index) 	__getIndReg(_IA64_REG_INDR_IBR, index)
-#define ia64_get_pkr(index) 	__getIndReg(_IA64_REG_INDR_PKR, index)
-#define ia64_get_pmc(index) 	__getIndReg(_IA64_REG_INDR_PMC, index)
-#define ia64_get_pmd(index)  	__getIndReg(_IA64_REG_INDR_PMD, index)
-#define ia64_get_rr(index) 	__getIndReg(_IA64_REG_INDR_RR, index)
+#define __ia64_get_ibr(index) 	__getIndReg(_IA64_REG_INDR_IBR, index)
+#define __ia64_get_pkr(index) 	__getIndReg(_IA64_REG_INDR_PKR, index)
+#define __ia64_get_pmc(index) 	__getIndReg(_IA64_REG_INDR_PMC, index)
+#define __ia64_get_pmd(index)  	__getIndReg(_IA64_REG_INDR_PMD, index)
+#define __ia64_get_rr(index) 	__getIndReg(_IA64_REG_INDR_RR, index)
 
 #define ia64_srlz_d		__dsrlz
 #define ia64_srlz_i		__isrlz
@@ -119,18 +119,18 @@
 #define ia64_ld8_acq		__ld8_acq
 
 #define ia64_sync_i		__synci
-#define ia64_thash		__thash
-#define ia64_ttag		__ttag
-#define ia64_itcd		__itcd
-#define ia64_itci		__itci
-#define ia64_itrd		__itrd
-#define ia64_itri		__itri
-#define ia64_ptce		__ptce
-#define ia64_ptcl		__ptcl
-#define ia64_ptcg		__ptcg
-#define ia64_ptcga		__ptcga
-#define ia64_ptri		__ptri
-#define ia64_ptrd		__ptrd
+#define __ia64_thash		__thash
+#define __ia64_ttag		__ttag
+#define __ia64_itcd		__itcd
+#define __ia64_itci		__itci
+#define __ia64_itrd		__itrd
+#define __ia64_itri		__itri
+#define __ia64_ptce		__ptce
+#define __ia64_ptcl		__ptcl
+#define __ia64_ptcg		__ptcg
+#define __ia64_ptcga		__ptcga
+#define __ia64_ptri		__ptri
+#define __ia64_ptrd		__ptrd
 #define ia64_dep_mi		_m64_dep_mi
 
 /* Values for lfhint in __lfetch and __lfetch_fault */
@@ -145,13 +145,13 @@
 #define ia64_lfetch_fault	__lfetch_fault
 #define ia64_lfetch_fault_excl	__lfetch_fault_excl
 
-#define ia64_intrin_local_irq_restore(x)		\
+#define __ia64_intrin_local_irq_restore(x)		\
 do {							\
 	if ((x) != 0) {					\
-		ia64_ssm(IA64_PSR_I);			\
+		__ia64_ssm(IA64_PSR_I);			\
 		ia64_srlz_d();				\
 	} else {					\
-		ia64_rsm(IA64_PSR_I);			\
+		__ia64_rsm(IA64_PSR_I);			\
 	}						\
 } while (0)
 
diff --git a/include/asm-ia64/intrinsics.h b/include/asm-ia64/intrinsics.h
index 5800ad0..4edf6de 100644
--- a/include/asm-ia64/intrinsics.h
+++ b/include/asm-ia64/intrinsics.h
@@ -18,15 +18,15 @@
 # include <asm/gcc_intrin.h>
 #endif
 
-#define ia64_get_psr_i()	(ia64_getreg(_IA64_REG_PSR) & IA64_PSR_I)
+#define __ia64_get_psr_i()	(__ia64_getreg(_IA64_REG_PSR) & IA64_PSR_I)
 
-#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
+#define __ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
 do {								\
-	ia64_set_rr(0x0000000000000000UL, (val0));		\
-	ia64_set_rr(0x2000000000000000UL, (val1));		\
-	ia64_set_rr(0x4000000000000000UL, (val2));		\
-	ia64_set_rr(0x6000000000000000UL, (val3));		\
-	ia64_set_rr(0x8000000000000000UL, (val4));		\
+	__ia64_set_rr(0x0000000000000000UL, (val0));		\
+	__ia64_set_rr(0x2000000000000000UL, (val1));		\
+	__ia64_set_rr(0x4000000000000000UL, (val2));		\
+	__ia64_set_rr(0x6000000000000000UL, (val3));		\
+	__ia64_set_rr(0x8000000000000000UL, (val4));		\
 } while (0)
 
 /*
diff --git a/include/asm-ia64/privop.h b/include/asm-ia64/privop.h
index 09c14ae..8261dad 100644
--- a/include/asm-ia64/privop.h
+++ b/include/asm-ia64/privop.h
@@ -16,6 +16,42 @@
 
 /* fallback for native case */
 
+#ifndef IA64_PARAVIRTUALIZED_PRIVOP
+#ifndef __ASSEMBLY
+#define ia64_getreg			__ia64_getreg
+#define ia64_setreg			__ia64_setreg
+#define ia64_hint			__ia64_hint
+#define ia64_thash			__ia64_thash
+#define ia64_itci			__ia64_itci
+#define ia64_itcd			__ia64_itcd
+#define ia64_itri			__ia64_itri
+#define ia64_itrd			__ia64_itrd
+#define ia64_tpa			__ia64_tpa
+#define ia64_set_ibr			__ia64_set_ibr
+#define ia64_set_pkr			__ia64_set_pkr
+#define ia64_set_pmc			__ia64_set_pmc
+#define ia64_set_pmd			__ia64_set_pmd
+#define ia64_set_rr			__ia64_set_rr
+#define ia64_get_cpuid			__ia64_get_cpuid
+#define ia64_get_ibr			__ia64_get_ibr
+#define ia64_get_pkr			__ia64_get_pkr
+#define ia64_get_pmc			__ia64_get_pmc
+#define ia64_get_pmd			__ia64_get_pmd
+#define ia64_get_rr			__ia64_get_rr
+#define ia64_fc				__ia64_fc
+#define ia64_ssm			__ia64_ssm
+#define ia64_rsm			__ia64_rsm
+#define ia64_ptce			__ia64_ptce
+#define ia64_ptcga			__ia64_ptcga
+#define ia64_ptcl			__ia64_ptcl
+#define ia64_ptri			__ia64_ptri
+#define ia64_ptrd			__ia64_ptrd
+#define ia64_get_psr_i			__ia64_get_psr_i
+#define ia64_intrin_local_irq_restore	__ia64_intrin_local_irq_restore
+#define ia64_set_rr0_to_rr4		__ia64_set_rr0_to_rr4
+#endif /* !__ASSEMBLY */
+#endif /* !IA64_PARAVIRTUALIZED_PRIVOP */
+
 #ifndef IA64_PARAVIRTUALIZED_ENTRY
 #define ia64_switch_to			__ia64_switch_to
 #define ia64_leave_syscall		__ia64_leave_syscall
diff --git a/include/asm-ia64/xen/privop.h b/include/asm-ia64/xen/privop.h
index 0fa8aa6..3caa7e9 100644
--- a/include/asm-ia64/xen/privop.h
+++ b/include/asm-ia64/xen/privop.h
@@ -70,6 +70,495 @@
 #define XSI_IHA				(XSI_BASE + XSI_IHA_OFS)
 #endif
 
+#ifndef __ASSEMBLY__
+#define	XEN_HYPER_SSM_I		asm("break %0" : : "i" (HYPERPRIVOP_SSM_I))
+#define	XEN_HYPER_GET_IVR	asm("break %0" : : "i" (HYPERPRIVOP_GET_IVR))
+
+/************************************************/
+/* Instructions paravirtualized for correctness */
+/************************************************/
+
+/* "fc" and "thash" are privilege-sensitive instructions, meaning they
+ *  may have different semantics depending on whether they are executed
+ *  at PL0 vs PL!=0.  When paravirtualized, these instructions mustn't
+ *  be allowed to execute directly, lest incorrect semantics result. */
+#ifdef ASM_SUPPORTED
+static inline void
+xen_fc(unsigned long addr)
+{
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile ("break %0":: "i"(HYPERPRIVOP_FC), "r"(__addr));
+}
+
+static inline unsigned long
+xen_thash(unsigned long addr)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_THASH), "0"(__addr));
+	return ia64_intri_res;
+}
+#else
+extern void xen_fc(unsigned long addr);
+extern unsigned long xen_thash(unsigned long addr);
+#endif
+
+/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
+ * is not currently used (though it may be in a long-format VHPT system!)
+ * and the semantics of cover only change if psr.ic is off which is very
+ * rare (and currently non-existent outside of assembly code */
+
+/* There are also privilege-sensitive registers.  These registers are
+ * readable at any privilege level but only writable at PL0. */
+#ifdef ASM_SUPPORTED
+static inline unsigned long
+xen_get_cpuid(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_GET_CPUID), "0"(__index));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+xen_get_pmd(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_GET_PMD), "0O"(__index));
+	return ia64_intri_res;
+}
+#else
+extern unsigned long xen_get_cpuid(int index);
+extern unsigned long xen_get_pmd(int index);
+#endif
+
+#ifdef ASM_SUPPORTED
+static inline unsigned long
+xen_get_eflag(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_EFLAG));
+	return ia64_intri_res;
+}
+
+static inline void
+xen_set_eflag(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0":: "i"(HYPERPRIVOP_SET_EFLAG), "r"(__val));
+}
+#else
+extern unsigned long xen_get_eflag(void);	/* see xen_ia64_getreg */
+extern void xen_set_eflag(unsigned long);	/* see xen_ia64_setreg */
+#endif
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+
+/* Xen uses memory-mapped virtual privileged registers for access to many
+ * performance-sensitive privileged registers.  Some, like the processor
+ * status register (psr), are broken up into multiple memory locations.
+ * Others, like "pend", are abstractions based on privileged registers.
+ * "Pend" is guaranteed to be set if reading cr.ivr would return a
+ * (non-spurious) interrupt. */
+#define XEN_MAPPEDREGS ((struct mapped_regs *)XMAPPEDREGS_BASE)
+
+#define XSI_PSR_I			\
+	(*XEN_MAPPEDREGS->interrupt_mask_addr)
+#define xen_get_virtual_psr_i()		\
+	(!XSI_PSR_I)
+#define xen_set_virtual_psr_i(_val)	\
+	({ XSI_PSR_I = (uint8_t)(_val) ? 0 : 1; })
+#define xen_set_virtual_psr_ic(_val)	\
+	({ XEN_MAPPEDREGS->interrupt_collection_enabled = _val ? 1 : 0; })
+#define xen_get_virtual_pend()		\
+	(*(((uint8_t *)XEN_MAPPEDREGS->interrupt_mask_addr) - 1))
+
+/* Hyperprivops are "break" instructions with a well-defined API.
+ * In particular, the virtual psr.ic bit must be off; in this way
+ * it is guaranteed to never conflict with a linux break instruction.
+ * Normally, this is done in a xen stub but this one is frequent enough
+ * that we inline it */
+#define xen_hyper_ssm_i()						\
+({									\
+	XEN_HYPER_SSM_I;						\
+})
+
+/* turning off interrupts can be paravirtualized simply by writing
+ * to a memory-mapped virtual psr.i bit (implemented as a 16-bit bool) */
+#define xen_rsm_i()							\
+do {									\
+	xen_set_virtual_psr_i(0);					\
+	barrier();							\
+} while (0)
+
+/* turning on interrupts is a bit more complicated.. write to the
+ * memory-mapped virtual psr.i bit first (to avoid race condition),
+ * then if any interrupts were pending, we have to execute a hyperprivop
+ * to ensure the pending interrupt gets delivered; else we're done! */
+#define xen_ssm_i()							\
+do {									\
+	int old = xen_get_virtual_psr_i();				\
+	xen_set_virtual_psr_i(1);					\
+	barrier();							\
+	if (!old && xen_get_virtual_pend())				\
+		xen_hyper_ssm_i();					\
+} while (0)
+
+#define xen_ia64_intrin_local_irq_restore(x)				\
+do {									\
+     if (is_running_on_xen()) {						\
+	     if ((x) & IA64_PSR_I)					\
+		     xen_ssm_i();					\
+	     else							\
+		     xen_rsm_i();					\
+     } else {								\
+	     __ia64_intrin_local_irq_restore((x));			\
+     }									\
+} while (0)
+
+#define	xen_get_psr_i()							\
+({									\
+									\
+	(is_running_on_xen()) ?						\
+		(xen_get_virtual_psr_i() ? IA64_PSR_I : 0)		\
+		: __ia64_get_psr_i()					\
+})
+
+#define xen_ia64_ssm(mask)						\
+do {									\
+	if ((mask) = IA64_PSR_I) {					\
+		if (is_running_on_xen())				\
+			xen_ssm_i(); 					\
+		else							\
+			__ia64_ssm(mask);				\
+	} else {							\
+		__ia64_ssm(mask);					\
+	}								\
+} while (0)
+
+#define xen_ia64_rsm(mask)						\
+do {									\
+	if ((mask) = IA64_PSR_I) {					\
+		if (is_running_on_xen())				\
+			xen_rsm_i(); 					\
+		else							\
+			__ia64_rsm(mask);				\
+	} else {							\
+		__ia64_rsm(mask);					\
+	}								\
+} while (0)
+
+/* Although all privileged operations can be left to trap and will
+ * be properly handled by Xen, some are frequent enough that we use
+ * hyperprivops for performance. */
+
+#ifndef ASM_SUPPORTED
+extern unsigned long xen_get_psr(void);
+extern unsigned long xen_get_ivr(void);
+extern unsigned long xen_get_tpr(void);
+extern void xen_set_itm(unsigned long);
+extern void xen_set_tpr(unsigned long);
+extern void xen_eoi(unsigned long);
+extern void xen_set_rr(unsigned long index, unsigned long val);
+extern unsigned long xen_get_rr(unsigned long index);
+extern void xen_set_kr(unsigned long index, unsigned long val);
+extern void xen_ptcga(unsigned long addr, unsigned long size);
+#else
+static inline unsigned long
+xen_get_psr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_PSR));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+xen_get_ivr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_IVR));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+xen_get_tpr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res): "i"(HYPERPRIVOP_GET_TPR));
+	return ia64_intri_res;
+}
+
+static inline void
+xen_set_tpr(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_GET_TPR), "r"(__val));
+}
+
+static inline void
+xen_eoi(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_EOI), "r"(__val));
+}
+
+static inline void
+xen_set_itm(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile ("break %0":: "i"(HYPERPRIVOP_SET_ITM), "r"(__val));
+}
+
+static inline void
+xen_ptcga(unsigned long addr, unsigned long size)
+{
+	register __u64 __addr asm ("r8") = addr;
+	register __u64 __size asm ("r9") = size;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_PTC_GA), "r"(__addr), "r"(__size));
+}
+
+static inline unsigned long
+xen_get_rr(unsigned long index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile ("break %1":
+		      "=r"(ia64_intri_res):
+		      "i"(HYPERPRIVOP_GET_RR), "0"(__index));
+	return ia64_intri_res;
+}
+
+static inline void
+xen_set_rr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index;
+	register __u64 __val asm ("r9") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_SET_RR), "r"(__index), "r"(__val));
+}
+
+static inline void
+xen_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
+		   unsigned long val2, unsigned long val3, unsigned long val4)
+{
+	register __u64 __val0 asm ("r8") = val0;
+	register __u64 __val1 asm ("r9") = val1;
+	register __u64 __val2 asm ("r10") = val2;
+	register __u64 __val3 asm ("r11") = val3;
+	register __u64 __val4 asm ("r14") = val4;
+	asm volatile ("break %0" ::
+		      "i"(HYPERPRIVOP_SET_RR0_TO_RR4),
+		      "r"(__val0), "r"(__val1),
+		      "r"(__val2), "r"(__val3), "r"(__val4));
+}
+
+static inline void
+xen_set_kr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index;
+	register __u64 __val asm ("r9") = val;
+	asm volatile ("break %0"::
+		      "i"(HYPERPRIVOP_SET_KR), "r"(__index), "r"(__val));
+}
+#endif
+
+/* Note: It may look wrong to test for is_running_on_xen() in each case.
+ * However regnum is always a constant so, as written, the compiler
+ * eliminates the switch statement, whereas is_running_on_xen() must be
+ * tested dynamically. */
+#define xen_ia64_getreg(regnum)						\
+({									\
+	__u64 ia64_intri_res;						\
+									\
+	switch (regnum) {						\
+	case _IA64_REG_PSR:						\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_psr() :					\
+			__ia64_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_CR_IVR:						\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_ivr() :					\
+			__ia64_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_CR_TPR:						\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_tpr() :					\
+			__ia64_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_AR_EFLAG:					\
+		ia64_intri_res = (is_running_on_xen()) ?		\
+			xen_get_eflag() :				\
+			__ia64_getreg(regnum);				\
+		break;							\
+	default:							\
+		ia64_intri_res = __ia64_getreg(regnum);			\
+		break;							\
+	}								\
+	ia64_intri_res;							\
+})
+
+#define xen_ia64_setreg(regnum, val)					\
+({									\
+	switch (regnum) {						\
+	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_KR7:			\
+		(is_running_on_xen()) ?					\
+			xen_set_kr(((regnum)-_IA64_REG_AR_KR0), (val)) :\
+			__ia64_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_CR_ITM:						\
+		(is_running_on_xen()) ?					\
+			xen_set_itm(val) :				\
+			__ia64_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_CR_TPR:						\
+		(is_running_on_xen()) ?					\
+			xen_set_tpr(val) :				\
+			__ia64_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_CR_EOI:						\
+		(is_running_on_xen()) ?					\
+			xen_eoi(val) :					\
+			__ia64_setreg((regnum), (val));			\
+		break;							\
+	case _IA64_REG_AR_EFLAG:					\
+		(is_running_on_xen()) ?					\
+			xen_set_eflag(val) :				\
+			__ia64_setreg((regnum), (val));			\
+		break;							\
+	default:							\
+		__ia64_setreg((regnum), (val));				\
+		break;							\
+	}								\
+})
+
+#if defined(ASM_SUPPORTED) && !defined(CONFIG_PARAVIRT_ALT)
+
+#define IA64_PARAVIRTUALIZED_PRIVOP
+
+#define ia64_fc(addr)							\
+do {									\
+	if (is_running_on_xen())					\
+		xen_fc((unsigned long)(addr));				\
+	else								\
+		__ia64_fc(addr);					\
+} while (0)
+
+#define ia64_thash(addr)						\
+({									\
+	unsigned long ia64_intri_res;					\
+	if (is_running_on_xen())					\
+		ia64_intri_res =					\
+			xen_thash((unsigned long)(addr));		\
+	else								\
+		ia64_intri_res = __ia64_thash(addr);			\
+	ia64_intri_res;							\
+})
+
+#define ia64_get_cpuid(i)						\
+({									\
+	unsigned long ia64_intri_res;					\
+	if (is_running_on_xen())					\
+		ia64_intri_res = xen_get_cpuid(i);			\
+	else								\
+		ia64_intri_res = __ia64_get_cpuid(i);			\
+	ia64_intri_res;							\
+})
+
+#define ia64_get_pmd(i)							\
+({									\
+	unsigned long ia64_intri_res;					\
+	if (is_running_on_xen())					\
+		ia64_intri_res = xen_get_pmd(i);			\
+	else								\
+		ia64_intri_res = __ia64_get_pmd(i);			\
+	ia64_intri_res;							\
+})
+
+
+#define ia64_ptcga(addr, size)						\
+do {									\
+	if (is_running_on_xen())					\
+		xen_ptcga((addr), (size));				\
+	else								\
+		__ia64_ptcga((addr), (size));				\
+} while (0)
+
+#define ia64_set_rr(index, val)						\
+do {									\
+	if (is_running_on_xen())					\
+		xen_set_rr((index), (val));				\
+	else								\
+		__ia64_set_rr((index), (val));				\
+} while (0)
+
+#define ia64_get_rr(index)						\
+({									\
+	__u64 ia64_intri_res;						\
+	if (is_running_on_xen())					\
+		ia64_intri_res = xen_get_rr((index));			\
+	else								\
+		ia64_intri_res = __ia64_get_rr((index));		\
+	ia64_intri_res;							\
+})
+
+#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)		\
+do {									\
+	if (is_running_on_xen())					\
+		xen_set_rr0_to_rr4((val0), (val1), (val2),		\
+				   (val3), (val4));			\
+	else								\
+		__ia64_set_rr0_to_rr4((val0), (val1), (val2),		\
+				      (val3), (val4));			\
+} while (0)
+
+#define ia64_getreg			xen_ia64_getreg
+#define ia64_setreg			xen_ia64_setreg
+#define ia64_ssm			xen_ia64_ssm
+#define ia64_rsm			xen_ia64_rsm
+#define ia64_intrin_local_irq_restore	xen_ia64_intrin_local_irq_restore
+#define ia64_get_psr_i			xen_get_psr_i
+
+/* the remainder of these are not performance-sensitive so its
+ * OK to not paravirtualize and just take a privop trap and emulate */
+#define ia64_hint			__ia64_hint
+#define ia64_set_pmd			__ia64_set_pmd
+#define ia64_itci			__ia64_itci
+#define ia64_itcd			__ia64_itcd
+#define ia64_itri			__ia64_itri
+#define ia64_itrd			__ia64_itrd
+#define ia64_tpa			__ia64_tpa
+#define ia64_set_ibr			__ia64_set_ibr
+#define ia64_set_pkr			__ia64_set_pkr
+#define ia64_set_pmc			__ia64_set_pmc
+#define ia64_get_ibr			__ia64_get_ibr
+#define ia64_get_pkr			__ia64_get_pkr
+#define ia64_get_pmc			__ia64_get_pmc
+#define ia64_ptce			__ia64_ptce
+#define ia64_ptcl			__ia64_ptcl
+#define ia64_ptri			__ia64_ptri
+#define ia64_ptrd			__ia64_ptrd
+
+#endif /* ASM_SUPPORTED && !CONFIG_PARAVIRT_ALT */
+
+#endif /* !__ASSEMBLY__ */
+
 /* these routines utilize privilege-sensitive or performance-sensitive
  * privileged instructions so the code must be replaced with
  * paravirtualized versions */
-- 
1.5.3


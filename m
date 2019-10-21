From: Juergen Gross <jgross@suse.com>
Date: Mon, 21 Oct 2019 10:04:15 +0000
Subject: [PATCH] ia64: remove stale paravirt leftovers
Message-Id: <20191021100415.7642-1-jgross@suse.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Remove the last leftovers from IA64 Xen pv-guest support.

PARAVIRT is long gone from IA64 Kconfig and Xen IA64 support, too.

Due to lack of infrastructure no testing done.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/ia64/include/asm/irqflags.h          |  4 ---
 arch/ia64/include/uapi/asm/gcc_intrin.h   | 24 +++++++--------
 arch/ia64/include/uapi/asm/intel_intrin.h | 32 +++++++++----------
 arch/ia64/include/uapi/asm/intrinsics.h   | 51 ++++---------------------------
 4 files changed, 34 insertions(+), 77 deletions(-)

diff --git a/arch/ia64/include/asm/irqflags.h b/arch/ia64/include/asm/irqflags.h
index d97f8435be4f..1dc30f12e545 100644
--- a/arch/ia64/include/asm/irqflags.h
+++ b/arch/ia64/include/asm/irqflags.h
@@ -36,11 +36,7 @@ static inline void arch_maybe_save_ip(unsigned long flags)
 static inline unsigned long arch_local_save_flags(void)
 {
 	ia64_stop();
-#ifdef CONFIG_PARAVIRT
-	return ia64_get_psr_i();
-#else
 	return ia64_getreg(_IA64_REG_PSR);
-#endif
 }
 
 static inline unsigned long arch_local_irq_save(void)
diff --git a/arch/ia64/include/uapi/asm/gcc_intrin.h b/arch/ia64/include/uapi/asm/gcc_intrin.h
index c60696fd1e37..ecfa3eadb217 100644
--- a/arch/ia64/include/uapi/asm/gcc_intrin.h
+++ b/arch/ia64/include/uapi/asm/gcc_intrin.h
@@ -31,7 +31,7 @@ extern void ia64_bad_param_for_setreg (void);
 extern void ia64_bad_param_for_getreg (void);
 
 
-#define ia64_native_setreg(regnum, val)						\
+#define ia64_setreg(regnum, val)						\
 ({										\
 	switch (regnum) {							\
 	    case _IA64_REG_PSR_L:						\
@@ -60,7 +60,7 @@ extern void ia64_bad_param_for_getreg (void);
 	}									\
 })
 
-#define ia64_native_getreg(regnum)						\
+#define ia64_getreg(regnum)							\
 ({										\
 	__u64 ia64_intri_res;							\
 										\
@@ -384,7 +384,7 @@ extern void ia64_bad_param_for_getreg (void);
 
 #define ia64_invala() asm volatile ("invala" ::: "memory")
 
-#define ia64_native_thash(addr)							\
+#define ia64_thash(addr)							\
 ({										\
 	unsigned long ia64_intri_res;						\
 	asm volatile ("thash %0=%1" : "=r"(ia64_intri_res) : "r" (addr));	\
@@ -437,10 +437,10 @@ extern void ia64_bad_param_for_getreg (void);
 #define ia64_set_pmd(index, val)						\
 	asm volatile ("mov pmd[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_native_set_rr(index, val)							\
+#define ia64_set_rr(index, val)							\
 	asm volatile ("mov rr[%0]=%1" :: "r"(index), "r"(val) : "memory");
 
-#define ia64_native_get_cpuid(index)							\
+#define ia64_get_cpuid(index)								\
 ({											\
 	unsigned long ia64_intri_res;							\
 	asm volatile ("mov %0=cpuid[%r1]" : "=r"(ia64_intri_res) : "rO"(index));	\
@@ -476,33 +476,33 @@ extern void ia64_bad_param_for_getreg (void);
 })
 
 
-#define ia64_native_get_pmd(index)						\
+#define ia64_get_pmd(index)							\
 ({										\
 	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=pmd[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_native_get_rr(index)						\
+#define ia64_get_rr(index)							\
 ({										\
 	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=rr[%1]" : "=r"(ia64_intri_res) : "r" (index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_native_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
+#define ia64_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
 
 
 #define ia64_sync_i()	asm volatile (";; sync.i" ::: "memory")
 
-#define ia64_native_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
-#define ia64_native_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
+#define ia64_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
+#define ia64_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
 #define ia64_sum(mask)	asm volatile ("sum %0":: "i"((mask)) : "memory")
 #define ia64_rum(mask)	asm volatile ("rum %0":: "i"((mask)) : "memory")
 
 #define ia64_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
 
-#define ia64_native_ptcga(addr, size)						\
+#define ia64_ptcga(addr, size)							\
 do {										\
 	asm volatile ("ptc.ga %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
@@ -607,7 +607,7 @@ do {										\
         }								\
 })
 
-#define ia64_native_intrin_local_irq_restore(x)			\
+#define ia64_intrin_local_irq_restore(x)			\
 do {								\
 	asm volatile (";;   cmp.ne p6,p7=%0,r0;;"		\
 		      "(p6) ssm psr.i;"				\
diff --git a/arch/ia64/include/uapi/asm/intel_intrin.h b/arch/ia64/include/uapi/asm/intel_intrin.h
index ab649691545a..dc1884dc54b5 100644
--- a/arch/ia64/include/uapi/asm/intel_intrin.h
+++ b/arch/ia64/include/uapi/asm/intel_intrin.h
@@ -17,8 +17,8 @@
 		 	 * intrinsic
 		 	 */
 
-#define ia64_native_getreg	__getReg
-#define ia64_native_setreg	__setReg
+#define ia64_getreg		__getReg
+#define ia64_setreg		__setReg
 
 #define ia64_hint		__hint
 #define ia64_hint_pause		__hint_pause
@@ -40,10 +40,10 @@
 #define ia64_invala_fr		__invala_fr
 #define ia64_nop		__nop
 #define ia64_sum		__sum
-#define ia64_native_ssm		__ssm
+#define ia64_ssm		__ssm
 #define ia64_rum		__rum
-#define ia64_native_rsm		__rsm
-#define ia64_native_fc 		__fc
+#define ia64_rsm		__rsm
+#define ia64_fc			__fc
 
 #define ia64_ldfs		__ldfs
 #define ia64_ldfd		__ldfd
@@ -89,17 +89,17 @@
 		__setIndReg(_IA64_REG_INDR_PMC, index, val)
 #define ia64_set_pmd(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMD, index, val)
-#define ia64_native_set_rr(index, val)	\
+#define ia64_set_rr(index, val)		\
 		__setIndReg(_IA64_REG_INDR_RR, index, val)
 
-#define ia64_native_get_cpuid(index)	\
+#define ia64_get_cpuid(index)	\
 		__getIndReg(_IA64_REG_INDR_CPUID, index)
 #define __ia64_get_dbr(index)		__getIndReg(_IA64_REG_INDR_DBR, index)
 #define ia64_get_ibr(index)		__getIndReg(_IA64_REG_INDR_IBR, index)
 #define ia64_get_pkr(index)		__getIndReg(_IA64_REG_INDR_PKR, index)
 #define ia64_get_pmc(index)		__getIndReg(_IA64_REG_INDR_PMC, index)
-#define ia64_native_get_pmd(index)	__getIndReg(_IA64_REG_INDR_PMD, index)
-#define ia64_native_get_rr(index)	__getIndReg(_IA64_REG_INDR_RR, index)
+#define ia64_get_pmd(index)		__getIndReg(_IA64_REG_INDR_PMD, index)
+#define ia64_get_rr(index)		__getIndReg(_IA64_REG_INDR_RR, index)
 
 #define ia64_srlz_d		__dsrlz
 #define ia64_srlz_i		__isrlz
@@ -121,16 +121,16 @@
 #define ia64_ld8_acq		__ld8_acq
 
 #define ia64_sync_i		__synci
-#define ia64_native_thash	__thash
-#define ia64_native_ttag	__ttag
+#define ia64_thash		__thash
+#define ia64_ttag		__ttag
 #define ia64_itcd		__itcd
 #define ia64_itci		__itci
 #define ia64_itrd		__itrd
 #define ia64_itri		__itri
 #define ia64_ptce		__ptce
 #define ia64_ptcl		__ptcl
-#define ia64_native_ptcg	__ptcg
-#define ia64_native_ptcga	__ptcga
+#define ia64_ptcg		__ptcg
+#define ia64_ptcga		__ptcga
 #define ia64_ptri		__ptri
 #define ia64_ptrd		__ptrd
 #define ia64_dep_mi		_m64_dep_mi
@@ -147,13 +147,13 @@
 #define ia64_lfetch_fault	__lfetch_fault
 #define ia64_lfetch_fault_excl	__lfetch_fault_excl
 
-#define ia64_native_intrin_local_irq_restore(x)		\
+#define ia64_intrin_local_irq_restore(x)		\
 do {							\
 	if ((x) != 0) {					\
-		ia64_native_ssm(IA64_PSR_I);		\
+		ia64_ssm(IA64_PSR_I);			\
 		ia64_srlz_d();				\
 	} else {					\
-		ia64_native_rsm(IA64_PSR_I);		\
+		ia64_rsm(IA64_PSR_I);			\
 	}						\
 } while (0)
 
diff --git a/arch/ia64/include/uapi/asm/intrinsics.h b/arch/ia64/include/uapi/asm/intrinsics.h
index aecc217eca63..a0e0a064f5b1 100644
--- a/arch/ia64/include/uapi/asm/intrinsics.h
+++ b/arch/ia64/include/uapi/asm/intrinsics.h
@@ -21,15 +21,13 @@
 #endif
 #include <asm/cmpxchg.h>
 
-#define ia64_native_get_psr_i()	(ia64_native_getreg(_IA64_REG_PSR) & IA64_PSR_I)
-
-#define ia64_native_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
+#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)		\
 do {									\
-	ia64_native_set_rr(0x0000000000000000UL, (val0));		\
-	ia64_native_set_rr(0x2000000000000000UL, (val1));		\
-	ia64_native_set_rr(0x4000000000000000UL, (val2));		\
-	ia64_native_set_rr(0x6000000000000000UL, (val3));		\
-	ia64_native_set_rr(0x8000000000000000UL, (val4));		\
+	ia64_set_rr(0x0000000000000000UL, (val0));			\
+	ia64_set_rr(0x2000000000000000UL, (val1));			\
+	ia64_set_rr(0x4000000000000000UL, (val2));			\
+	ia64_set_rr(0x6000000000000000UL, (val3));			\
+	ia64_set_rr(0x8000000000000000UL, (val4));			\
 } while (0)
 
 /*
@@ -85,41 +83,4 @@ extern unsigned long __bad_increment_for_ia64_fetch_and_add (void);
 
 #endif
 
-
-#ifndef __ASSEMBLY__
-
-#define IA64_INTRINSIC_API(name)	ia64_native_ ## name
-#define IA64_INTRINSIC_MACRO(name)	ia64_native_ ## name
-
-
-/************************************************/
-/* Instructions paravirtualized for correctness */
-/************************************************/
-/* fc, thash, get_cpuid, get_pmd, get_eflags, set_eflags */
-/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
- * is not currently used (though it may be in a long-format VHPT system!)
- */
-#define ia64_fc				IA64_INTRINSIC_API(fc)
-#define ia64_thash			IA64_INTRINSIC_API(thash)
-#define ia64_get_cpuid			IA64_INTRINSIC_API(get_cpuid)
-#define ia64_get_pmd			IA64_INTRINSIC_API(get_pmd)
-
-
-/************************************************/
-/* Instructions paravirtualized for performance */
-/************************************************/
-#define ia64_ssm			IA64_INTRINSIC_MACRO(ssm)
-#define ia64_rsm			IA64_INTRINSIC_MACRO(rsm)
-#define ia64_getreg			IA64_INTRINSIC_MACRO(getreg)
-#define ia64_setreg			IA64_INTRINSIC_API(setreg)
-#define ia64_set_rr			IA64_INTRINSIC_API(set_rr)
-#define ia64_get_rr			IA64_INTRINSIC_API(get_rr)
-#define ia64_ptcga			IA64_INTRINSIC_API(ptcga)
-#define ia64_get_psr_i			IA64_INTRINSIC_API(get_psr_i)
-#define ia64_intrin_local_irq_restore	\
-	IA64_INTRINSIC_API(intrin_local_irq_restore)
-#define ia64_set_rr0_to_rr4		IA64_INTRINSIC_API(set_rr0_to_rr4)
-
-#endif /* !__ASSEMBLY__ */
-
 #endif /* _UAPI_ASM_IA64_INTRINSICS_H */
-- 
2.16.4

From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 28 Feb 2008 09:57:13 +0000
Subject: [PATCH 1/5] ia64/pv_ops: preparation for ia64 intrinsics operations paravirtualization
Message-Id: <12041926372070-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To make them overridable cleanly, change their prefix from ia64_ to native_
and define ia64_ to native_.
Later ia64_xxx would be redeinfed to pv_ops'ed one.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/gcc_intrin.h   |   58 +++++++++++++++++-----------------
 include/asm-ia64/intel_intrin.h |   64 +++++++++++++++++++-------------------
 include/asm-ia64/intrinsics.h   |   14 ++++----
 include/asm-ia64/privop.h       |   36 ++++++++++++++++++++++
 4 files changed, 104 insertions(+), 68 deletions(-)

diff --git a/include/asm-ia64/gcc_intrin.h b/include/asm-ia64/gcc_intrin.h
index de2ed2c..31db638 100644
--- a/include/asm-ia64/gcc_intrin.h
+++ b/include/asm-ia64/gcc_intrin.h
@@ -28,7 +28,7 @@ extern void ia64_bad_param_for_getreg (void);
 register unsigned long ia64_r13 asm ("r13") __used;
 #endif
 
-#define ia64_setreg(regnum, val)						\
+#define native_setreg(regnum, val)						\
 ({										\
 	switch (regnum) {							\
 	    case _IA64_REG_PSR_L:						\
@@ -57,7 +57,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 	}									\
 })
 
-#define ia64_getreg(regnum)							\
+#define native_getreg(regnum)							\
 ({										\
 	__u64 ia64_intri_res;							\
 										\
@@ -94,7 +94,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 
 #define ia64_hint_pause 0
 
-#define ia64_hint(mode)						\
+#define native_hint(mode)						\
 ({								\
 	switch (mode) {						\
 	case ia64_hint_pause:					\
@@ -381,7 +381,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
 
 #define ia64_invala() asm volatile ("invala" ::: "memory")
 
-#define ia64_thash(addr)							\
+#define native_thash(addr)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("thash %0=%1" : "=r"(ia64_intri_res) : "r" (addr));	\
@@ -401,18 +401,18 @@ register unsigned long ia64_r13 asm ("r13") __used;
 
 #define ia64_nop(x)	asm volatile ("nop %0"::"i"(x));
 
-#define ia64_itci(addr)	asm volatile ("itc.i %0;;" :: "r"(addr) : "memory")
+#define native_itci(addr)	asm volatile ("itc.i %0;;" :: "r"(addr) : "memory")
 
-#define ia64_itcd(addr)	asm volatile ("itc.d %0;;" :: "r"(addr) : "memory")
+#define native_itcd(addr)	asm volatile ("itc.d %0;;" :: "r"(addr) : "memory")
 
 
-#define ia64_itri(trnum, addr) asm volatile ("itr.i itr[%0]=%1"				\
+#define native_itri(trnum, addr) asm volatile ("itr.i itr[%0]=%1"			\
 					     :: "r"(trnum), "r"(addr) : "memory")
 
-#define ia64_itrd(trnum, addr) asm volatile ("itr.d dtr[%0]=%1"				\
+#define native_itrd(trnum, addr) asm volatile ("itr.d dtr[%0]=%1"			\
 					     :: "r"(trnum), "r"(addr) : "memory")
 
-#define ia64_tpa(addr)								\
+#define native_tpa(addr)							\
 ({										\
 	__u64 ia64_pa;								\
 	asm volatile ("tpa %0 = %1" : "=r"(ia64_pa) : "r"(addr) : "memory");	\
@@ -422,22 +422,22 @@ register unsigned long ia64_r13 asm ("r13") __used;
 #define __ia64_set_dbr(index, val)						\
 	asm volatile ("mov dbr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_ibr(index, val)						\
+#define native_set_ibr(index, val)						\
 	asm volatile ("mov ibr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pkr(index, val)						\
+#define native_set_pkr(index, val)						\
 	asm volatile ("mov pkr[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pmc(index, val)						\
+#define native_set_pmc(index, val)						\
 	asm volatile ("mov pmc[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_pmd(index, val)						\
+#define native_set_pmd(index, val)						\
 	asm volatile ("mov pmd[%0]=%1" :: "r"(index), "r"(val) : "memory")
 
-#define ia64_set_rr(index, val)							\
+#define native_set_rr(index, val)							\
 	asm volatile ("mov rr[%0]=%1" :: "r"(index), "r"(val) : "memory");
 
-#define ia64_get_cpuid(index)								\
+#define native_get_cpuid(index)								\
 ({											\
 	__u64 ia64_intri_res;								\
 	asm volatile ("mov %0=cpuid[%r1]" : "=r"(ia64_intri_res) : "rO"(index));	\
@@ -451,21 +451,21 @@ register unsigned long ia64_r13 asm ("r13") __used;
 	ia64_intri_res;								\
 })
 
-#define ia64_get_ibr(index)							\
+#define native_get_ibr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=ibr[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_pkr(index)							\
+#define native_get_pkr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pkr[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_pmc(index)							\
+#define native_get_pmc(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pmc[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
@@ -473,48 +473,48 @@ register unsigned long ia64_r13 asm ("r13") __used;
 })
 
 
-#define ia64_get_pmd(index)							\
+#define native_get_pmd(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=pmd[%1]" : "=r"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_get_rr(index)							\
+#define native_get_rr(index)							\
 ({										\
 	__u64 ia64_intri_res;							\
 	asm volatile ("mov %0=rr[%1]" : "=r"(ia64_intri_res) : "r" (index));	\
 	ia64_intri_res;								\
 })
 
-#define ia64_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
+#define native_fc(addr)	asm volatile ("fc %0" :: "r"(addr) : "memory")
 
 
 #define ia64_sync_i()	asm volatile (";; sync.i" ::: "memory")
 
-#define ia64_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
-#define ia64_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
+#define native_ssm(mask)	asm volatile ("ssm %0":: "i"((mask)) : "memory")
+#define native_rsm(mask)	asm volatile ("rsm %0":: "i"((mask)) : "memory")
 #define ia64_sum(mask)	asm volatile ("sum %0":: "i"((mask)) : "memory")
 #define ia64_rum(mask)	asm volatile ("rum %0":: "i"((mask)) : "memory")
 
-#define ia64_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
+#define native_ptce(addr)	asm volatile ("ptc.e %0" :: "r"(addr))
 
-#define ia64_ptcga(addr, size)							\
+#define native_ptcga(addr, size)							\
 do {										\
 	asm volatile ("ptc.ga %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
 } while (0)
 
-#define ia64_ptcl(addr, size)							\
+#define native_ptcl(addr, size)							\
 do {										\
 	asm volatile ("ptc.l %0,%1" :: "r"(addr), "r"(size) : "memory");	\
 	ia64_dv_serialize_data();						\
 } while (0)
 
-#define ia64_ptri(addr, size)						\
+#define native_ptri(addr, size)						\
 	asm volatile ("ptr.i %0,%1" :: "r"(addr), "r"(size) : "memory")
 
-#define ia64_ptrd(addr, size)						\
+#define native_ptrd(addr, size)						\
 	asm volatile ("ptr.d %0,%1" :: "r"(addr), "r"(size) : "memory")
 
 /* Values for lfhint in ia64_lfetch and ia64_lfetch_fault */
@@ -596,7 +596,7 @@ do {										\
         }								\
 })
 
-#define ia64_intrin_local_irq_restore(x)			\
+#define native_intrin_local_irq_restore(x)			\
 do {								\
 	asm volatile (";;   cmp.ne p6,p7=%0,r0;;"		\
 		      "(p6) ssm psr.i;"				\
diff --git a/include/asm-ia64/intel_intrin.h b/include/asm-ia64/intel_intrin.h
index a520d10..ab3c8a3 100644
--- a/include/asm-ia64/intel_intrin.h
+++ b/include/asm-ia64/intel_intrin.h
@@ -16,8 +16,8 @@
 		 	 * intrinsic
 		 	 */
 
-#define ia64_getreg		__getReg
-#define ia64_setreg		__setReg
+#define native_getreg		__getReg
+#define native_setreg		__setReg
 
 #define ia64_hint		__hint
 #define ia64_hint_pause		__hint_pause
@@ -33,16 +33,16 @@
 #define ia64_getf_exp		__getf_exp
 #define ia64_shrp		_m64_shrp
 
-#define ia64_tpa		__tpa
+#define native_tpa		__tpa
 #define ia64_invala		__invala
 #define ia64_invala_gr		__invala_gr
 #define ia64_invala_fr		__invala_fr
 #define ia64_nop		__nop
 #define ia64_sum		__sum
-#define ia64_ssm		__ssm
+#define native_ssm		__ssm
 #define ia64_rum		__rum
-#define ia64_rsm		__rsm
-#define ia64_fc 		__fc
+#define native_rsm		__rsm
+#define native_fc 		__fc
 
 #define ia64_ldfs		__ldfs
 #define ia64_ldfd		__ldfd
@@ -80,24 +80,24 @@
 
 #define __ia64_set_dbr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_DBR, index, val)
-#define ia64_set_ibr(index, val)	\
+#define native_set_ibr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_IBR, index, val)
-#define ia64_set_pkr(index, val)	\
+#define native_set_pkr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PKR, index, val)
-#define ia64_set_pmc(index, val)	\
+#define native_set_pmc(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMC, index, val)
-#define ia64_set_pmd(index, val)	\
+#define native_set_pmd(index, val)	\
 		__setIndReg(_IA64_REG_INDR_PMD, index, val)
-#define ia64_set_rr(index, val)	\
+#define native_set_rr(index, val)	\
 		__setIndReg(_IA64_REG_INDR_RR, index, val)
 
-#define ia64_get_cpuid(index) 	__getIndReg(_IA64_REG_INDR_CPUID, index)
+#define native_get_cpuid(index)	__getIndReg(_IA64_REG_INDR_CPUID, index)
 #define __ia64_get_dbr(index) 	__getIndReg(_IA64_REG_INDR_DBR, index)
-#define ia64_get_ibr(index) 	__getIndReg(_IA64_REG_INDR_IBR, index)
-#define ia64_get_pkr(index) 	__getIndReg(_IA64_REG_INDR_PKR, index)
-#define ia64_get_pmc(index) 	__getIndReg(_IA64_REG_INDR_PMC, index)
-#define ia64_get_pmd(index)  	__getIndReg(_IA64_REG_INDR_PMD, index)
-#define ia64_get_rr(index) 	__getIndReg(_IA64_REG_INDR_RR, index)
+#define native_get_ibr(index) 	__getIndReg(_IA64_REG_INDR_IBR, index)
+#define native_get_pkr(index) 	__getIndReg(_IA64_REG_INDR_PKR, index)
+#define native_get_pmc(index) 	__getIndReg(_IA64_REG_INDR_PMC, index)
+#define native_get_pmd(index)  	__getIndReg(_IA64_REG_INDR_PMD, index)
+#define native_get_rr(index) 	__getIndReg(_IA64_REG_INDR_RR, index)
 
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
+#define native_thash		__thash
+#define native_ttag		__ttag
+#define native_itcd		__itcd
+#define native_itci		__itci
+#define native_itrd		__itrd
+#define native_itri		__itri
+#define native_ptce		__ptce
+#define native_ptcl		__ptcl
+#define native_ptcg		__ptcg
+#define native_ptcga		__ptcga
+#define native_ptri		__ptri
+#define native_ptrd		__ptrd
 #define ia64_dep_mi		_m64_dep_mi
 
 /* Values for lfhint in __lfetch and __lfetch_fault */
@@ -145,13 +145,13 @@
 #define ia64_lfetch_fault	__lfetch_fault
 #define ia64_lfetch_fault_excl	__lfetch_fault_excl
 
-#define ia64_intrin_local_irq_restore(x)		\
+#define native_intrin_local_irq_restore(x)		\
 do {							\
 	if ((x) != 0) {					\
-		ia64_ssm(IA64_PSR_I);			\
+		native_ssm(IA64_PSR_I);			\
 		ia64_srlz_d();				\
 	} else {					\
-		ia64_rsm(IA64_PSR_I);			\
+		native_rsm(IA64_PSR_I);			\
 	}						\
 } while (0)
 
diff --git a/include/asm-ia64/intrinsics.h b/include/asm-ia64/intrinsics.h
index 5800ad0..3a58069 100644
--- a/include/asm-ia64/intrinsics.h
+++ b/include/asm-ia64/intrinsics.h
@@ -18,15 +18,15 @@
 # include <asm/gcc_intrin.h>
 #endif
 
-#define ia64_get_psr_i()	(ia64_getreg(_IA64_REG_PSR) & IA64_PSR_I)
+#define native_get_psr_i()	(native_getreg(_IA64_REG_PSR) & IA64_PSR_I)
 
-#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
+#define native_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
 do {								\
-	ia64_set_rr(0x0000000000000000UL, (val0));		\
-	ia64_set_rr(0x2000000000000000UL, (val1));		\
-	ia64_set_rr(0x4000000000000000UL, (val2));		\
-	ia64_set_rr(0x6000000000000000UL, (val3));		\
-	ia64_set_rr(0x8000000000000000UL, (val4));		\
+	native_set_rr(0x0000000000000000UL, (val0));		\
+	native_set_rr(0x2000000000000000UL, (val1));		\
+	native_set_rr(0x4000000000000000UL, (val2));		\
+	native_set_rr(0x6000000000000000UL, (val3));		\
+	native_set_rr(0x8000000000000000UL, (val4));		\
 } while (0)
 
 /*
diff --git a/include/asm-ia64/privop.h b/include/asm-ia64/privop.h
index 7b9de4f..b0b74fd 100644
--- a/include/asm-ia64/privop.h
+++ b/include/asm-ia64/privop.h
@@ -16,6 +16,42 @@
 
 /* fallback for native case */
 
+#ifndef IA64_PARAVIRTUALIZED_PRIVOP
+#ifndef __ASSEMBLY
+#define ia64_getreg			native_getreg
+#define ia64_setreg			native_setreg
+#define ia64_hint			native_hint
+#define ia64_thash			native_thash
+#define ia64_itci			native_itci
+#define ia64_itcd			native_itcd
+#define ia64_itri			native_itri
+#define ia64_itrd			native_itrd
+#define ia64_tpa			native_tpa
+#define ia64_set_ibr			native_set_ibr
+#define ia64_set_pkr			native_set_pkr
+#define ia64_set_pmc			native_set_pmc
+#define ia64_set_pmd			native_set_pmd
+#define ia64_set_rr			native_set_rr
+#define ia64_get_cpuid			native_get_cpuid
+#define ia64_get_ibr			native_get_ibr
+#define ia64_get_pkr			native_get_pkr
+#define ia64_get_pmc			native_get_pmc
+#define ia64_get_pmd			native_get_pmd
+#define ia64_get_rr			native_get_rr
+#define ia64_fc				native_fc
+#define ia64_ssm			native_ssm
+#define ia64_rsm			native_rsm
+#define ia64_ptce			native_ptce
+#define ia64_ptcga			native_ptcga
+#define ia64_ptcl			native_ptcl
+#define ia64_ptri			native_ptri
+#define ia64_ptrd			native_ptrd
+#define ia64_get_psr_i			native_get_psr_i
+#define ia64_intrin_local_irq_restore	native_intrin_local_irq_restore
+#define ia64_set_rr0_to_rr4		native_set_rr0_to_rr4
+#endif /* !__ASSEMBLY */
+#endif /* !IA64_PARAVIRTUALIZED_PRIVOP */
+
 #ifndef IA64_PARAVIRTUALIZED_ENTRY
 #define ia64_switch_to			native_switch_to
 #define ia64_leave_syscall		native_leave_syscall
-- 
1.5.3


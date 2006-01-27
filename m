From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 01:08:47 +0000
Subject: [patch 2/5] clean up asm/intel_intrin.h
Message-Id: <200601270108.k0R18mg20925@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Include intrinsic header file from icc compiler.  Remove
duplicate definition from kernel source.

Signed-off-by: HJ Lu <hongjiu.lu@intel.com>
Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/intel_intrin.h.orig	2006-01-26 16:43:03.945997107 -0800
+++ ./include/asm-ia64/intel_intrin.h	2006-01-26 16:44:13.800488439 -0800
@@ -5,113 +5,10 @@
  *
  * Copyright (C) 2002,2003 Jun Nakajima <jun.nakajima@intel.com>
  * Copyright (C) 2002,2003 Suresh Siddha <suresh.b.siddha@intel.com>
+ * Copyright (C) 2005,2006 Hongjiu Lu <hongjiu.lu@intel.com>
  *
  */
-#include <asm/types.h>
-
-void  __lfetch(int lfhint, void *y);
-void  __lfetch_excl(int lfhint, void *y);
-void  __lfetch_fault(int lfhint, void *y);
-void  __lfetch_fault_excl(int lfhint, void *y);
-
-/* In the following, whichFloatReg should be an integer from 0-127 */
-void  __ldfs(const int whichFloatReg, void *src);
-void  __ldfd(const int whichFloatReg, void *src);
-void  __ldfe(const int whichFloatReg, void *src);
-void  __ldf8(const int whichFloatReg, void *src);
-void  __ldf_fill(const int whichFloatReg, void *src);
-void  __stfs(void *dst, const int whichFloatReg);
-void  __stfd(void *dst, const int whichFloatReg);
-void  __stfe(void *dst, const int whichFloatReg);
-void  __stf8(void *dst, const int whichFloatReg);
-void  __stf_spill(void *dst, const int whichFloatReg);
-
-void  __st1_rel(void *dst, const __s8  value);
-void  __st2_rel(void *dst, const __s16 value);
-void  __st4_rel(void *dst, const __s32 value);
-void  __st8_rel(void *dst, const __s64 value);
-__u8  __ld1_acq(void *src);
-__u16 __ld2_acq(void *src);
-__u32 __ld4_acq(void *src);
-__u64 __ld8_acq(void *src);
-
-__u64 __fetchadd4_acq(__u32 *addend, const int increment);
-__u64 __fetchadd4_rel(__u32 *addend, const int increment);
-__u64 __fetchadd8_acq(__u64 *addend, const int increment);
-__u64 __fetchadd8_rel(__u64 *addend, const int increment);
-
-__u64 __getf_exp(double d);
-
-/* OS Related Itanium(R) Intrinsics  */
-
-/* The names to use for whichReg and whichIndReg below come from
-   the include file asm/ia64regs.h */
-
-__u64 __getIndReg(const int whichIndReg, __s64 index);
-__u64 __getReg(const int whichReg);
-
-void  __setIndReg(const int whichIndReg, __s64 index, __u64 value);
-void  __setReg(const int whichReg, __u64 value);
-
-void  __mf(void);
-void  __mfa(void);
-void  __synci(void);
-void  __itcd(__s64 pa);
-void  __itci(__s64 pa);
-void  __itrd(__s64 whichTransReg, __s64 pa);
-void  __itri(__s64 whichTransReg, __s64 pa);
-void  __ptce(__s64 va);
-void  __ptcl(__s64 va, __s64 pagesz);
-void  __ptcg(__s64 va, __s64 pagesz);
-void  __ptcga(__s64 va, __s64 pagesz);
-void  __ptri(__s64 va, __s64 pagesz);
-void  __ptrd(__s64 va, __s64 pagesz);
-void  __invala (void);
-void  __invala_gr(const int whichGeneralReg /* 0-127 */ );
-void  __invala_fr(const int whichFloatReg /* 0-127 */ );
-void  __nop(const int);
-void  __fc(__u64 *addr);
-void  __sum(int mask);
-void  __rum(int mask);
-void  __ssm(int mask);
-void  __rsm(int mask);
-__u64 __thash(__s64);
-__u64 __ttag(__s64);
-__s64 __tpa(__s64);
-
-/* Intrinsics for implementing get/put_user macros */
-void __st_user(const char *tableName, __u64 addr, char size, char relocType, __u64 val);
-void __ld_user(const char *tableName, __u64 addr, char size, char relocType);
-
-/* This intrinsic does not generate code, it creates a barrier across which
- * the compiler will not schedule data access instructions.
- */
-void __memory_barrier(void);
-
-void __isrlz(void);
-void __dsrlz(void);
-
-__u64  _m64_mux1(__u64 a, const int n);
-__u64  __thash(__u64);
-
-/* Lock and Atomic Operation Related Intrinsics */
-__u64 _InterlockedExchange8(volatile __u8 *trgt, __u8 value);
-__u64 _InterlockedExchange16(volatile __u16 *trgt, __u16 value);
-__s64 _InterlockedExchange(volatile __u32 *trgt, __u32 value);
-__s64 _InterlockedExchange64(volatile __u64 *trgt, __u64 value);
-
-__u64 _InterlockedCompareExchange8_rel(volatile __u8 *dest, __u64 xchg, __u64 comp);
-__u64 _InterlockedCompareExchange8_acq(volatile __u8 *dest, __u64 xchg, __u64 comp);
-__u64 _InterlockedCompareExchange16_rel(volatile __u16 *dest, __u64 xchg, __u64 comp);
-__u64 _InterlockedCompareExchange16_acq(volatile __u16 *dest, __u64 xchg, __u64 comp);
-__u64 _InterlockedCompareExchange_rel(volatile __u32 *dest, __u64 xchg, __u64 comp);
-__u64 _InterlockedCompareExchange_acq(volatile __u32 *dest, __u64 xchg, __u64 comp);
-__u64 _InterlockedCompareExchange64_rel(volatile __u64 *dest, __u64 xchg, __u64 comp);
-__u64 _InterlockedCompareExchange64_acq(volatile __u64 *dest, __u64 xchg, __u64 comp);
-
-__s64 _m64_dep_mi(const int v, __s64 s, const int p, const int len);
-__s64 _m64_shrp(__s64 a, __s64 b, const int count);
-__s64 _m64_popcnt(__s64 a);
+#include <ia64intrin.h>
 
 #define ia64_barrier()		__memory_barrier()
 
@@ -131,7 +28,7 @@ __s64 _m64_popcnt(__s64 a);
 #define ia64_mux1_alt		10
 #define ia64_mux1_rev		11
 
-#define ia64_mux1		_m64_mux1
+#define ia64_mux1(x,v)		_m_to_int64(_m64_mux1(_m_from_int64(x), (v)))
 #define ia64_popcnt		_m64_popcnt
 #define ia64_getf_exp		__getf_exp
 #define ia64_shrp		_m64_shrp


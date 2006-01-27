From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 01:19:46 +0000
Subject: [patch 4/5] use icc defined constant
Message-Id: <200601270119.k0R1Jlg21055@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use icc defined constant instead of magic number.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/intel_intrin.h.orig	2006-01-26 16:57:54.058290891 -0800
+++ ./include/asm-ia64/intel_intrin.h	2006-01-26 17:11:34.656913651 -0800
@@ -22,11 +22,11 @@
 #define ia64_hint		__hint
 #define ia64_hint_pause		__hint_pause
 
-#define ia64_mux1_brcst	 0
-#define ia64_mux1_mix		 8
-#define ia64_mux1_shuf		 9
-#define ia64_mux1_alt		10
-#define ia64_mux1_rev		11
+#define ia64_mux1_brcst		_m64_mux1_brcst
+#define ia64_mux1_mix		_m64_mux1_mix
+#define ia64_mux1_shuf		_m64_mux1_shuf
+#define ia64_mux1_alt		_m64_mux1_alt
+#define ia64_mux1_rev		_m64_mux1_rev
 
 #define ia64_mux1(x,v)		_m_to_int64(_m64_mux1(_m_from_int64(x), (v)))
 #define ia64_popcnt		_m64_popcnt
@@ -56,7 +56,7 @@
 #define ia64_stf8		__stf8
 #define ia64_stf_spill		__stf_spill
 
-#define ia64_mf		__mf
+#define ia64_mf			__mf
 #define ia64_mfa		__mfa
 
 #define ia64_fetchadd4_acq	__fetchadd4_acq
@@ -132,10 +132,10 @@
 
 /* Values for lfhint in __lfetch and __lfetch_fault */
 
-#define ia64_lfhint_none   	0
-#define ia64_lfhint_nt1    	1
-#define ia64_lfhint_nt2    	2
-#define ia64_lfhint_nta    	3
+#define ia64_lfhint_none	__lfhint_none
+#define ia64_lfhint_nt1		__lfhint_nt1
+#define ia64_lfhint_nt2		__lfhint_nt2
+#define ia64_lfhint_nta		__lfhint_nta
 
 #define ia64_lfetch		__lfetch
 #define ia64_lfetch_excl	__lfetch_excl


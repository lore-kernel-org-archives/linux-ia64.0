From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 00:58:52 +0000
Subject: [patch 1/5] map ia64_hint definition to intel compiler intrinsic
Message-Id: <200601270058.k0R0wrg20717@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Map ia64_hint() to internal intel compiler intrinsic.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

---
Same patch as what was sent yesterday.



--- ./include/asm-ia64/intel_intrin.h.orig	2006-01-26 16:42:58.815137795 -0800
+++ ./include/asm-ia64/intel_intrin.h	2006-01-26 16:43:03.945997107 -0800
@@ -122,7 +122,8 @@ __s64 _m64_popcnt(__s64 a);
 #define ia64_getreg		__getReg
 #define ia64_setreg		__setReg
 
-#define ia64_hint(x)
+#define ia64_hint		__hint
+#define ia64_hint_pause		__hint_pause
 
 #define ia64_mux1_brcst	 0
 #define ia64_mux1_mix		 8


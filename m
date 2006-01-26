From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 26 Jan 2006 04:24:33 +0000
Subject: [patch] fix ia64_hint definition for intel compiler intrinsic
Message-Id: <200601260424.k0Q4OXg05063@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Map ia64_hint() to internal intel compiler intrinsic.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

---
Compile tested on selective files.  icc 9.0 appears to have
memory clobber behavior for the hint@pause intrinsic similar
to gcc with "memory" clobber modifier. Your mileage may vary.


--- ./include/asm-ia64/intel_intrin.h.orig	2006-01-25 17:40:12.468497883 -0800
+++ ./include/asm-ia64/intel_intrin.h	2006-01-25 21:04:41.921472582 -0800
@@ -122,7 +122,8 @@ __s64 _m64_popcnt(__s64 a);
 #define ia64_getreg		__getReg
 #define ia64_setreg		__setReg
 
-#define ia64_hint(x)
+#define ia64_hint		__hint
+#define ia64_hint_pause		0
 
 #define ia64_mux1_brcst	 0
 #define ia64_mux1_mix		 8




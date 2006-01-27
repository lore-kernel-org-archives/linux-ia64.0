From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 01:12:02 +0000
Subject: [patch 3/5] add __builtin_trap definition for icc build
Message-Id: <200601270112.k0R1C3g20970@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Map __builtin_trap function to break 0 instruction.

Signed-off-by: HJ Lu <hongjiu.lu@intel.com>
Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/intel_intrin.h.orig	2006-01-26 16:46:38.263377294 -0800
+++ ./include/asm-ia64/intel_intrin.h	2006-01-26 16:57:54.058290891 -0800
@@ -152,4 +152,6 @@ do {							\
 	}						\
 } while (0)
 
+#define __builtin_trap()	__break(0);
+
 #endif /* _ASM_IA64_INTEL_INTRIN_H */


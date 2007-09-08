From: Jiri Slaby <jirislaby@gmail.com>
Date: Sat, 08 Sep 2007 20:06:29 +0000
Subject: [PATCH 2/2] forbid asm/bitops.h direct inclusion
Message-Id: <276116173913632310@pripojeni.net>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <30483262301654323266@pripojeni.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

forbid asm/bitops.h direct inclusion

Because of compile errors that may occur after bit changes if asm/bitops.h is
included directly without e.g. linux/kernel.h which includes linux/bitops.h, forbid
direct inclusion of asm/bitops.h. Thanks to Adrian Bunk.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Adrian Bunk <bunk@kernel.org>

---
commit cd28a228ae727b2224da736edc613c58a08c5ed9
tree 483ca1765baaf80996484889ed3078c4af24be03
parent 3c05eef3d0a98065323d7d6d9a78e0985eba4b10
author Jiri Slaby <jirislaby@gmail.com> Sat, 08 Sep 2007 21:02:48 +0200
committer Jiri Slaby <jirislaby@gmail.com> Sat, 08 Sep 2007 21:02:48 +0200

 include/asm-alpha/bitops.h     |    4 ++++
 include/asm-arm/bitops.h       |    4 ++++
 include/asm-avr32/bitops.h     |    4 ++++
 include/asm-blackfin/bitops.h  |    4 ++++
 include/asm-cris/bitops.h      |    4 ++++
 include/asm-frv/bitops.h       |    4 ++++
 include/asm-generic/bitops.h   |    4 ++++
 include/asm-h8300/bitops.h     |    5 +++++
 include/asm-i386/bitops.h      |    4 ++++
 include/asm-ia64/bitops.h      |    4 ++++
 include/asm-m32r/bitops.h      |    4 ++++
 include/asm-m68k/bitops.h      |    4 ++++
 include/asm-m68knommu/bitops.h |    4 ++++
 include/asm-mips/bitops.h      |    4 ++++
 include/asm-parisc/bitops.h    |    4 ++++
 include/asm-powerpc/bitops.h   |    4 ++++
 include/asm-s390/bitops.h      |    4 ++++
 include/asm-sh/bitops.h        |    5 +++++
 include/asm-sh64/bitops.h      |    5 +++++
 include/asm-sparc/bitops.h     |    4 ++++
 include/asm-sparc64/bitops.h   |    4 ++++
 include/asm-um/bitops.h        |    4 ++++
 include/asm-v850/bitops.h      |    3 +++
 include/asm-x86_64/bitops.h    |    4 ++++
 include/asm-xtensa/bitops.h    |    4 ++++
 25 files changed, 102 insertions(+), 0 deletions(-)

diff --git a/include/asm-alpha/bitops.h b/include/asm-alpha/bitops.h
index ffec8a8..6490e50 100644
--- a/include/asm-alpha/bitops.h
+++ b/include/asm-alpha/bitops.h
@@ -1,6 +1,10 @@
 #ifndef _ALPHA_BITOPS_H
 #define _ALPHA_BITOPS_H
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm/compiler.h>
 
 /*
diff --git a/include/asm-arm/bitops.h b/include/asm-arm/bitops.h
index 52fe058..47a6b08 100644
--- a/include/asm-arm/bitops.h
+++ b/include/asm-arm/bitops.h
@@ -19,6 +19,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <asm/system.h>
 
diff --git a/include/asm-avr32/bitops.h b/include/asm-avr32/bitops.h
index f3faddf..1a50b69 100644
--- a/include/asm-avr32/bitops.h
+++ b/include/asm-avr32/bitops.h
@@ -8,6 +8,10 @@
 #ifndef __ASM_AVR32_BITOPS_H
 #define __ASM_AVR32_BITOPS_H
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm/byteorder.h>
 #include <asm/system.h>
 
diff --git a/include/asm-blackfin/bitops.h b/include/asm-blackfin/bitops.h
index 03ecedc..b39a175 100644
--- a/include/asm-blackfin/bitops.h
+++ b/include/asm-blackfin/bitops.h
@@ -11,6 +11,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm-generic/bitops/ffs.h>
 #include <asm-generic/bitops/__ffs.h>
 #include <asm-generic/bitops/sched.h>
diff --git a/include/asm-cris/bitops.h b/include/asm-cris/bitops.h
index 617151b..e2f49c2 100644
--- a/include/asm-cris/bitops.h
+++ b/include/asm-cris/bitops.h
@@ -14,6 +14,10 @@
 /* Currently this is unsuitable for consumption outside the kernel.  */
 #ifdef __KERNEL__ 
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm/arch/bitops.h>
 #include <asm/system.h>
 #include <asm/atomic.h>
diff --git a/include/asm-frv/bitops.h b/include/asm-frv/bitops.h
index 8dba74b..e29de71 100644
--- a/include/asm-frv/bitops.h
+++ b/include/asm-frv/bitops.h
@@ -21,6 +21,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm-generic/bitops/ffz.h>
 
 /*
diff --git a/include/asm-generic/bitops.h b/include/asm-generic/bitops.h
index e022a0f..15e6f25 100644
--- a/include/asm-generic/bitops.h
+++ b/include/asm-generic/bitops.h
@@ -19,6 +19,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm-generic/bitops/sched.h>
 #include <asm-generic/bitops/ffs.h>
 #include <asm-generic/bitops/hweight.h>
diff --git a/include/asm-h8300/bitops.h b/include/asm-h8300/bitops.h
index e64ad31..cb18e3b 100644
--- a/include/asm-h8300/bitops.h
+++ b/include/asm-h8300/bitops.h
@@ -10,6 +10,11 @@
 #include <asm/system.h>
 
 #ifdef __KERNEL__
+
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 /*
  * Function prototypes to keep gcc -Wall happy
  */
diff --git a/include/asm-i386/bitops.h b/include/asm-i386/bitops.h
index c96641f..3268a34 100644
--- a/include/asm-i386/bitops.h
+++ b/include/asm-i386/bitops.h
@@ -5,6 +5,10 @@
  * Copyright 1992, Linus Torvalds.
  */
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <asm/alternative.h>
 
diff --git a/include/asm-ia64/bitops.h b/include/asm-ia64/bitops.h
index 2144f1a..a977aff 100644
--- a/include/asm-ia64/bitops.h
+++ b/include/asm-ia64/bitops.h
@@ -9,6 +9,10 @@
  * O(1) scheduler patch
  */
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <linux/types.h>
 #include <asm/intrinsics.h>
diff --git a/include/asm-m32r/bitops.h b/include/asm-m32r/bitops.h
index 313a02c..6dc9b81 100644
--- a/include/asm-m32r/bitops.h
+++ b/include/asm-m32r/bitops.h
@@ -11,6 +11,10 @@
  *    Copyright (C) 2004  Hirokazu Takata <takata at linux-m32r.org>
  */
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <asm/assembler.h>
 #include <asm/system.h>
diff --git a/include/asm-m68k/bitops.h b/include/asm-m68k/bitops.h
index da151f7..2976b5d 100644
--- a/include/asm-m68k/bitops.h
+++ b/include/asm-m68k/bitops.h
@@ -8,6 +8,10 @@
  * for more details.
  */
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 
 /*
diff --git a/include/asm-m68knommu/bitops.h b/include/asm-m68knommu/bitops.h
index b8b2770..f8dfb7b 100644
--- a/include/asm-m68knommu/bitops.h
+++ b/include/asm-m68knommu/bitops.h
@@ -10,6 +10,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm-generic/bitops/ffs.h>
 #include <asm-generic/bitops/__ffs.h>
 #include <asm-generic/bitops/sched.h>
diff --git a/include/asm-mips/bitops.h b/include/asm-mips/bitops.h
index d00738e..3b773eb 100644
--- a/include/asm-mips/bitops.h
+++ b/include/asm-mips/bitops.h
@@ -9,6 +9,10 @@
 #ifndef _ASM_BITOPS_H
 #define _ASM_BITOPS_H
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <linux/irqflags.h>
 #include <linux/types.h>
diff --git a/include/asm-parisc/bitops.h b/include/asm-parisc/bitops.h
index 03ae287..f8eebcb 100644
--- a/include/asm-parisc/bitops.h
+++ b/include/asm-parisc/bitops.h
@@ -1,6 +1,10 @@
 #ifndef _PARISC_BITOPS_H
 #define _PARISC_BITOPS_H
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <asm/types.h>		/* for BITS_PER_LONG/SHIFT_PER_LONG */
 #include <asm/byteorder.h>
diff --git a/include/asm-powerpc/bitops.h b/include/asm-powerpc/bitops.h
index 27f6106..3c14f0d 100644
--- a/include/asm-powerpc/bitops.h
+++ b/include/asm-powerpc/bitops.h
@@ -38,6 +38,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <asm/asm-compat.h>
 #include <asm/synch.h>
diff --git a/include/asm-s390/bitops.h b/include/asm-s390/bitops.h
index d756b34..34d9a63 100644
--- a/include/asm-s390/bitops.h
+++ b/include/asm-s390/bitops.h
@@ -15,6 +15,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 
 /*
diff --git a/include/asm-sh/bitops.h b/include/asm-sh/bitops.h
index 9d70217..df805f2 100644
--- a/include/asm-sh/bitops.h
+++ b/include/asm-sh/bitops.h
@@ -2,6 +2,11 @@
 #define __ASM_SH_BITOPS_H
 
 #ifdef __KERNEL__
+
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm/system.h>
 /* For __swab32 */
 #include <asm/byteorder.h>
diff --git a/include/asm-sh64/bitops.h b/include/asm-sh64/bitops.h
index 444d5ea..600c59e 100644
--- a/include/asm-sh64/bitops.h
+++ b/include/asm-sh64/bitops.h
@@ -13,6 +13,11 @@
  */
 
 #ifdef __KERNEL__
+
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <asm/system.h>
 /* For __swab32 */
diff --git a/include/asm-sparc/bitops.h b/include/asm-sparc/bitops.h
index 00bd0a6..cb3cefa 100644
--- a/include/asm-sparc/bitops.h
+++ b/include/asm-sparc/bitops.h
@@ -14,6 +14,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 extern unsigned long ___set_bit(unsigned long *addr, unsigned long mask);
 extern unsigned long ___clear_bit(unsigned long *addr, unsigned long mask);
 extern unsigned long ___change_bit(unsigned long *addr, unsigned long mask);
diff --git a/include/asm-sparc64/bitops.h b/include/asm-sparc64/bitops.h
index dd4bfe9..982ce89 100644
--- a/include/asm-sparc64/bitops.h
+++ b/include/asm-sparc64/bitops.h
@@ -7,6 +7,10 @@
 #ifndef _SPARC64_BITOPS_H
 #define _SPARC64_BITOPS_H
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <linux/compiler.h>
 #include <asm/byteorder.h>
 
diff --git a/include/asm-um/bitops.h b/include/asm-um/bitops.h
index 46d7819..e4d38d4 100644
--- a/include/asm-um/bitops.h
+++ b/include/asm-um/bitops.h
@@ -1,6 +1,10 @@
 #ifndef __UM_BITOPS_H
 #define __UM_BITOPS_H
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include "asm/arch/bitops.h"
 
 #endif
diff --git a/include/asm-v850/bitops.h b/include/asm-v850/bitops.h
index 8eafdb1..f82f5b4 100644
--- a/include/asm-v850/bitops.h
+++ b/include/asm-v850/bitops.h
@@ -13,6 +13,9 @@
 #ifndef __V850_BITOPS_H__
 #define __V850_BITOPS_H__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
 
 #include <linux/compiler.h>	/* unlikely  */
 #include <asm/byteorder.h>	/* swab32 */
diff --git a/include/asm-x86_64/bitops.h b/include/asm-x86_64/bitops.h
index 2607dbc..4dbf36d 100644
--- a/include/asm-x86_64/bitops.h
+++ b/include/asm-x86_64/bitops.h
@@ -5,6 +5,10 @@
  * Copyright 1992, Linus Torvalds.
  */
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm/alternative.h>
 
 #if __GNUC__ < 4 || (__GNUC__ = 4 && __GNUC_MINOR__ < 1)
diff --git a/include/asm-xtensa/bitops.h b/include/asm-xtensa/bitops.h
index 78db04c..23261e8 100644
--- a/include/asm-xtensa/bitops.h
+++ b/include/asm-xtensa/bitops.h
@@ -15,6 +15,10 @@
 
 #ifdef __KERNEL__
 
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
 #include <asm/processor.h>
 #include <asm/byteorder.h>
 #include <asm/system.h>

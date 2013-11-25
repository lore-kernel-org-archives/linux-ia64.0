From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 25 Nov 2013 08:55:34 +0000
Subject: [PATCH 24/24] asm-generic: Rename int-ll64.h to types.h
Message-Id: <1385369734-24893-25-git-send-email-geert@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1385369734-24893-1-git-send-email-geert@linux-m68k.org>
In-Reply-To: <1385369734-24893-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org

Since kernelspace always uses "(unsigned) long long" for 64-bit integer
values ("u64" and "s64"), rename include/asm-generic/int-ll64.h to
include/asm-generic/types.h, as suggested by Arnd Bergmann.

Userspace still has both include/uapi/asm-generic/int-l64.h and
include/uapi/asm-generic/int-ll64.h, as int-l64.h may still be used for
userspace on existing 64-bit platforms (alpha, ia64, mips, and powerpc).

Note: While arch/alpha/include/asm/types.h just includes
asm-generic/types.h, don't be tempted to use Kbuild logic to provide it!
arch/*/include/asm/Kbuild applies to both arch/*/include/asm and
arch/*/include/uapi/asm, while alpha has its own <uapi/asm/types.h>.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-alpha@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-kbuild@vger.kernel.org
---
Question: Is the arch/*/include/asm/Kbuild behavior intentional?

 arch/alpha/include/asm/types.h              |    2 +-
 arch/arm/include/asm/types.h                |    2 +-
 arch/ia64/include/asm/types.h               |    2 +-
 arch/mips/include/asm/types.h               |    2 +-
 arch/powerpc/include/asm/types.h            |    2 +-
 arch/s390/include/asm/types.h               |    2 +-
 arch/sh/include/asm/types.h                 |    2 +-
 arch/xtensa/include/asm/types.h             |    2 +-
 include/asm-generic/io-64-nonatomic-hi-lo.h |    2 +-
 include/asm-generic/io-64-nonatomic-lo-hi.h |    2 +-
 include/asm-generic/{int-ll64.h => types.h} |    8 ++++----
 11 files changed, 14 insertions(+), 14 deletions(-)
 rename include/asm-generic/{int-ll64.h => types.h} (85%)

diff --git a/arch/alpha/include/asm/types.h b/arch/alpha/include/asm/types.h
index 4cb4b6d3452c..b86fb65c5b10 100644
--- a/arch/alpha/include/asm/types.h
+++ b/arch/alpha/include/asm/types.h
@@ -1,6 +1,6 @@
 #ifndef _ALPHA_TYPES_H
 #define _ALPHA_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 
 #endif /* _ALPHA_TYPES_H */
diff --git a/arch/arm/include/asm/types.h b/arch/arm/include/asm/types.h
index a53cdb8f068c..09e15a8a40b1 100644
--- a/arch/arm/include/asm/types.h
+++ b/arch/arm/include/asm/types.h
@@ -1,7 +1,7 @@
 #ifndef _ASM_TYPES_H
 #define _ASM_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 
 /*
  * The C99 types uintXX_t that are usually defined in 'stdint.h' are not as
diff --git a/arch/ia64/include/asm/types.h b/arch/ia64/include/asm/types.h
index 4c351b169da2..6bc2e8acadd7 100644
--- a/arch/ia64/include/asm/types.h
+++ b/arch/ia64/include/asm/types.h
@@ -13,7 +13,7 @@
 #ifndef _ASM_IA64_TYPES_H
 #define _ASM_IA64_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 #include <uapi/asm/types.h>
 
 #ifdef __ASSEMBLY__
diff --git a/arch/mips/include/asm/types.h b/arch/mips/include/asm/types.h
index 4d5ce4c9c924..0d6729329a6a 100644
--- a/arch/mips/include/asm/types.h
+++ b/arch/mips/include/asm/types.h
@@ -11,7 +11,7 @@
 #ifndef _ASM_TYPES_H
 #define _ASM_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 
 /*
  * These aren't exported outside the kernel to avoid name space clashes
diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
index 4b9c3530bb12..69d42a918e0e 100644
--- a/arch/powerpc/include/asm/types.h
+++ b/arch/powerpc/include/asm/types.h
@@ -13,7 +13,7 @@
 #ifndef _ASM_POWERPC_TYPES_H
 #define _ASM_POWERPC_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 #include <uapi/asm/types.h>
 
 #ifndef __ASSEMBLY__
diff --git a/arch/s390/include/asm/types.h b/arch/s390/include/asm/types.h
index a5c7e829dbc3..abb93c7f0125 100644
--- a/arch/s390/include/asm/types.h
+++ b/arch/s390/include/asm/types.h
@@ -6,7 +6,7 @@
 #ifndef _S390_TYPES_H
 #define _S390_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 #include <uapi/asm/types.h>
 
 /*
diff --git a/arch/sh/include/asm/types.h b/arch/sh/include/asm/types.h
index 062324be5cd6..ef745dcfd926 100644
--- a/arch/sh/include/asm/types.h
+++ b/arch/sh/include/asm/types.h
@@ -1,7 +1,7 @@
 #ifndef __ASM_SH_TYPES_H
 #define __ASM_SH_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 
 /*
  * These aren't exported outside the kernel to avoid name space clashes
diff --git a/arch/xtensa/include/asm/types.h b/arch/xtensa/include/asm/types.h
index d873cb17d944..20ffdf440e4f 100644
--- a/arch/xtensa/include/asm/types.h
+++ b/arch/xtensa/include/asm/types.h
@@ -10,7 +10,7 @@
 #ifndef _XTENSA_TYPES_H
 #define _XTENSA_TYPES_H
 
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 #include <uapi/asm/types.h>
 
 #endif	/* _XTENSA_TYPES_H */
diff --git a/include/asm-generic/io-64-nonatomic-hi-lo.h b/include/asm-generic/io-64-nonatomic-hi-lo.h
index a6806a94250d..414d2c49d53c 100644
--- a/include/asm-generic/io-64-nonatomic-hi-lo.h
+++ b/include/asm-generic/io-64-nonatomic-hi-lo.h
@@ -2,7 +2,7 @@
 #define _ASM_IO_64_NONATOMIC_HI_LO_H_
 
 #include <linux/io.h>
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 
 #ifndef readq
 static inline __u64 readq(const volatile void __iomem *addr)
diff --git a/include/asm-generic/io-64-nonatomic-lo-hi.h b/include/asm-generic/io-64-nonatomic-lo-hi.h
index ca546b1ff8b5..9bc5a3393ca1 100644
--- a/include/asm-generic/io-64-nonatomic-lo-hi.h
+++ b/include/asm-generic/io-64-nonatomic-lo-hi.h
@@ -2,7 +2,7 @@
 #define _ASM_IO_64_NONATOMIC_LO_HI_H_
 
 #include <linux/io.h>
-#include <asm-generic/int-ll64.h>
+#include <asm-generic/types.h>
 
 #ifndef readq
 static inline __u64 readq(const volatile void __iomem *addr)
diff --git a/include/asm-generic/int-ll64.h b/include/asm-generic/types.h
similarity index 85%
rename from include/asm-generic/int-ll64.h
rename to include/asm-generic/types.h
index 4cd84855cb46..b9542bb3d991 100644
--- a/include/asm-generic/int-ll64.h
+++ b/include/asm-generic/types.h
@@ -1,11 +1,11 @@
 /*
- * asm-generic/int-ll64.h
+ * asm-generic/types.h
  *
  * Integer declarations for architectures which use "long long"
  * for 64-bit types.
  */
-#ifndef _ASM_GENERIC_INT_LL64_H
-#define _ASM_GENERIC_INT_LL64_H
+#ifndef _ASM_GENERIC_TYPES_H
+#define _ASM_GENERIC_TYPES_H
 
 #include <uapi/asm-generic/int-ll64.h>
 
@@ -46,4 +46,4 @@ typedef unsigned long long u64;
 
 #endif /* __ASSEMBLY__ */
 
-#endif /* _ASM_GENERIC_INT_LL64_H */
+#endif /* _ASM_GENERIC_TYPES_H */
-- 
1.7.9.5


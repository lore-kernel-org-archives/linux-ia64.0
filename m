From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 06 Jan 2017 09:43:53 +0000
Subject: [PATCH v2 1/7] arm: put types.h in uapi
Message-Id: <1483695839-18660-2-git-send-email-nicolas.dichtel@6wind.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, coreteam@netfilter.org, fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, linux-me

This header file is exported, thus move it to uapi.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 arch/arm/include/asm/types.h      | 36 +----------------------------------
 arch/arm/include/uapi/asm/types.h | 40 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 35 deletions(-)
 create mode 100644 arch/arm/include/uapi/asm/types.h

diff --git a/arch/arm/include/asm/types.h b/arch/arm/include/asm/types.h
index a53cdb8f068c..c48fee3d7b3b 100644
--- a/arch/arm/include/asm/types.h
+++ b/arch/arm/include/asm/types.h
@@ -1,40 +1,6 @@
 #ifndef _ASM_TYPES_H
 #define _ASM_TYPES_H
 
-#include <asm-generic/int-ll64.h>
-
-/*
- * The C99 types uintXX_t that are usually defined in 'stdint.h' are not as
- * unambiguous on ARM as you would expect. For the types below, there is a
- * difference on ARM between GCC built for bare metal ARM, GCC built for glibc
- * and the kernel itself, which results in build errors if you try to build with
- * -ffreestanding and include 'stdint.h' (such as when you include 'arm_neon.h'
- * in order to use NEON intrinsics)
- *
- * As the typedefs for these types in 'stdint.h' are based on builtin defines
- * supplied by GCC, we can tweak these to align with the kernel's idea of those
- * types, so 'linux/types.h' and 'stdint.h' can be safely included from the same
- * source file (provided that -ffreestanding is used).
- *
- *                    int32_t         uint32_t               uintptr_t
- * bare metal GCC     long            unsigned long          unsigned int
- * glibc GCC          int             unsigned int           unsigned int
- * kernel             int             unsigned int           unsigned long
- */
-
-#ifdef __INT32_TYPE__
-#undef __INT32_TYPE__
-#define __INT32_TYPE__		int
-#endif
-
-#ifdef __UINT32_TYPE__
-#undef __UINT32_TYPE__
-#define __UINT32_TYPE__	unsigned int
-#endif
-
-#ifdef __UINTPTR_TYPE__
-#undef __UINTPTR_TYPE__
-#define __UINTPTR_TYPE__	unsigned long
-#endif
+#include <uapi/asm/types.h>
 
 #endif /* _ASM_TYPES_H */
diff --git a/arch/arm/include/uapi/asm/types.h b/arch/arm/include/uapi/asm/types.h
new file mode 100644
index 000000000000..9435a42f575e
--- /dev/null
+++ b/arch/arm/include/uapi/asm/types.h
@@ -0,0 +1,40 @@
+#ifndef _UAPI_ASM_TYPES_H
+#define _UAPI_ASM_TYPES_H
+
+#include <asm-generic/int-ll64.h>
+
+/*
+ * The C99 types uintXX_t that are usually defined in 'stdint.h' are not as
+ * unambiguous on ARM as you would expect. For the types below, there is a
+ * difference on ARM between GCC built for bare metal ARM, GCC built for glibc
+ * and the kernel itself, which results in build errors if you try to build with
+ * -ffreestanding and include 'stdint.h' (such as when you include 'arm_neon.h'
+ * in order to use NEON intrinsics)
+ *
+ * As the typedefs for these types in 'stdint.h' are based on builtin defines
+ * supplied by GCC, we can tweak these to align with the kernel's idea of those
+ * types, so 'linux/types.h' and 'stdint.h' can be safely included from the same
+ * source file (provided that -ffreestanding is used).
+ *
+ *                    int32_t         uint32_t               uintptr_t
+ * bare metal GCC     long            unsigned long          unsigned int
+ * glibc GCC          int             unsigned int           unsigned int
+ * kernel             int             unsigned int           unsigned long
+ */
+
+#ifdef __INT32_TYPE__
+#undef __INT32_TYPE__
+#define __INT32_TYPE__		int
+#endif
+
+#ifdef __UINT32_TYPE__
+#undef __UINT32_TYPE__
+#define __UINT32_TYPE__	unsigned int
+#endif
+
+#ifdef __UINTPTR_TYPE__
+#undef __UINTPTR_TYPE__
+#define __UINTPTR_TYPE__	unsigned long
+#endif
+
+#endif /* _UAPI_ASM_TYPES_H */
-- 
2.8.1


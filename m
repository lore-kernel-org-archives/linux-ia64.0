From: Thomas Huth <thuth@redhat.com>
Date: Wed, 26 Apr 2023 06:50:32 +0000
Subject: [PATCH] arch/ia64/include: Remove CONFIG_IA64_DEBUG_CMPXCHG from uapi header
Message-Id: <20230426065032.517693-1-thuth@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
Cc: linux-ia64@vger.kernel.org

CONFIG_* switches should not be exposed in uapi headers.
The macros that are defined here are also only useful for the
kernel code, so let's move them to asm/cmpxchg.h instead.

The only two files that are using these macros are the headers
arch/ia64/include/asm/bitops.h and arch/ia64/include/asm/atomic.h
and these include asm/cmpxchg.h via asm/intrinsics.h, so this
movement should not cause any trouble.

Signed-off-by: Thomas Huth <thuth@redhat.com>
---
 arch/ia64/include/asm/cmpxchg.h      | 17 +++++++++++++++++
 arch/ia64/include/uapi/asm/cmpxchg.h | 17 -----------------
 scripts/headers_install.sh           |  1 -
 3 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/include/asm/cmpxchg.h b/arch/ia64/include/asm/cmpxchg.h
index 94ef84429843..d9f01ede9768 100644
--- a/arch/ia64/include/asm/cmpxchg.h
+++ b/arch/ia64/include/asm/cmpxchg.h
@@ -13,4 +13,21 @@
 #define arch_cmpxchg_local		arch_cmpxchg
 #define arch_cmpxchg64_local		arch_cmpxchg64
 
+#ifdef CONFIG_IA64_DEBUG_CMPXCHG
+# define CMPXCHG_BUGCHECK_DECL	int _cmpxchg_bugcheck_count = 128;
+# define CMPXCHG_BUGCHECK(v)						\
+do {									\
+	if (_cmpxchg_bugcheck_count-- <= 0) {				\
+		void *ip;						\
+		extern int _printk(const char *fmt, ...);		\
+		ip = (void *) ia64_getreg(_IA64_REG_IP);		\
+		_printk("CMPXCHG_BUGCHECK: stuck at %p on word %p\n", ip, (v));\
+		break;							\
+	}								\
+} while (0)
+#else /* !CONFIG_IA64_DEBUG_CMPXCHG */
+# define CMPXCHG_BUGCHECK_DECL
+# define CMPXCHG_BUGCHECK(v)
+#endif /* !CONFIG_IA64_DEBUG_CMPXCHG */
+
 #endif /* _ASM_IA64_CMPXCHG_H */
diff --git a/arch/ia64/include/uapi/asm/cmpxchg.h b/arch/ia64/include/uapi/asm/cmpxchg.h
index 259ae57570bf..986dbe01d883 100644
--- a/arch/ia64/include/uapi/asm/cmpxchg.h
+++ b/arch/ia64/include/uapi/asm/cmpxchg.h
@@ -133,23 +133,6 @@ extern long ia64_cmpxchg_called_with_bad_pointer(void);
 #define cmpxchg64_local		cmpxchg64
 #endif
 
-#ifdef CONFIG_IA64_DEBUG_CMPXCHG
-# define CMPXCHG_BUGCHECK_DECL	int _cmpxchg_bugcheck_count = 128;
-# define CMPXCHG_BUGCHECK(v)						\
-do {									\
-	if (_cmpxchg_bugcheck_count-- <= 0) {				\
-		void *ip;						\
-		extern int _printk(const char *fmt, ...);		\
-		ip = (void *) ia64_getreg(_IA64_REG_IP);		\
-		_printk("CMPXCHG_BUGCHECK: stuck at %p on word %p\n", ip, (v));\
-		break;							\
-	}								\
-} while (0)
-#else /* !CONFIG_IA64_DEBUG_CMPXCHG */
-# define CMPXCHG_BUGCHECK_DECL
-# define CMPXCHG_BUGCHECK(v)
-#endif /* !CONFIG_IA64_DEBUG_CMPXCHG */
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _UAPI_ASM_IA64_CMPXCHG_H */
diff --git a/scripts/headers_install.sh b/scripts/headers_install.sh
index 36b56b746fce..afdddc82f02b 100755
--- a/scripts/headers_install.sh
+++ b/scripts/headers_install.sh
@@ -76,7 +76,6 @@ arch/arc/include/uapi/asm/swab.h:CONFIG_ARC_HAS_SWAPE
 arch/arm/include/uapi/asm/ptrace.h:CONFIG_CPU_ENDIAN_BE8
 arch/hexagon/include/uapi/asm/ptrace.h:CONFIG_HEXAGON_ARCH_VERSION
 arch/hexagon/include/uapi/asm/user.h:CONFIG_HEXAGON_ARCH_VERSION
-arch/ia64/include/uapi/asm/cmpxchg.h:CONFIG_IA64_DEBUG_CMPXCHG
 arch/m68k/include/uapi/asm/ptrace.h:CONFIG_COLDFIRE
 arch/nios2/include/uapi/asm/swab.h:CONFIG_NIOS2_CI_SWAB_NO
 arch/nios2/include/uapi/asm/swab.h:CONFIG_NIOS2_CI_SWAB_SUPPORT
-- 
2.31.1

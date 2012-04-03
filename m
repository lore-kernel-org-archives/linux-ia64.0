From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 03 Apr 2012 19:00:10 +0000
Subject: [PATCH] ia64: populate the cmpxchg header with appropriate code
Message-Id: <1333479610-13321-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>

commit 93f378883cecb9dcb2cf5b51d9d24175906659da

    "Fix ia64 build errors (fallout from system.h disintegration)"

introduced arch/ia64/include/asm/cmpxchg.h as a temporary
build fix and stated:

    "... leave the migration of xchg() and cmpxchg() to this new
     header file for a future patch."

Migrate the appropriate chunks from asm/intrinsics.h and fix
the whitespace issues in the migrated chunk.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/arch/ia64/include/asm/cmpxchg.h b/arch/ia64/include/asm/cmpxchg.h
index 4c96187..4f37dbb 100644
--- a/arch/ia64/include/asm/cmpxchg.h
+++ b/arch/ia64/include/asm/cmpxchg.h
@@ -1 +1,147 @@
-#include <asm/intrinsics.h>
+#ifndef _ASM_IA64_CMPXCHG_H
+#define _ASM_IA64_CMPXCHG_H
+
+/*
+ * Compare/Exchange, forked from asm/intrinsics.h
+ * which was:
+ *
+ *	Copyright (C) 2002-2003 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+
+#ifndef __ASSEMBLY__
+
+#include <linux/types.h>
+/* include compiler specific intrinsics */
+#include <asm/ia64regs.h>
+#ifdef __INTEL_COMPILER
+# include <asm/intel_intrin.h>
+#else
+# include <asm/gcc_intrin.h>
+#endif
+
+/*
+ * This function doesn't exist, so you'll get a linker error if
+ * something tries to do an invalid xchg().
+ */
+extern void ia64_xchg_called_with_bad_pointer(void);
+
+#define __xchg(x, ptr, size)						\
+({									\
+	unsigned long __xchg_result;					\
+									\
+	switch (size) {							\
+	case 1:								\
+		__xchg_result = ia64_xchg1((__u8 *)ptr, x);		\
+		break;							\
+									\
+	case 2:								\
+		__xchg_result = ia64_xchg2((__u16 *)ptr, x);		\
+		break;							\
+									\
+	case 4:								\
+		__xchg_result = ia64_xchg4((__u32 *)ptr, x);		\
+		break;							\
+									\
+	case 8:								\
+		__xchg_result = ia64_xchg8((__u64 *)ptr, x);		\
+		break;							\
+	default:							\
+		ia64_xchg_called_with_bad_pointer();			\
+	}								\
+	__xchg_result;							\
+})
+
+#define xchg(ptr, x)							\
+((__typeof__(*(ptr))) __xchg((unsigned long) (x), (ptr), sizeof(*(ptr))))
+
+/*
+ * Atomic compare and exchange.  Compare OLD with MEM, if identical,
+ * store NEW in MEM.  Return the initial value in MEM.  Success is
+ * indicated by comparing RETURN with OLD.
+ */
+
+#define __HAVE_ARCH_CMPXCHG 1
+
+/*
+ * This function doesn't exist, so you'll get a linker error
+ * if something tries to do an invalid cmpxchg().
+ */
+extern long ia64_cmpxchg_called_with_bad_pointer(void);
+
+#define ia64_cmpxchg(sem, ptr, old, new, size)				\
+({									\
+	__u64 _o_, _r_;							\
+									\
+	switch (size) {							\
+	case 1:								\
+		_o_ = (__u8) (long) (old);				\
+		break;							\
+	case 2:								\
+		_o_ = (__u16) (long) (old);				\
+		break;							\
+	case 4:								\
+		_o_ = (__u32) (long) (old);				\
+		break;							\
+	case 8:								\
+		_o_ = (__u64) (long) (old);				\
+		break;							\
+	default:							\
+		break;							\
+	}								\
+	switch (size) {							\
+	case 1:								\
+		_r_ = ia64_cmpxchg1_##sem((__u8 *) ptr, new, _o_);	\
+		break;							\
+									\
+	case 2:								\
+		_r_ = ia64_cmpxchg2_##sem((__u16 *) ptr, new, _o_);	\
+		break;							\
+									\
+	case 4:								\
+		_r_ = ia64_cmpxchg4_##sem((__u32 *) ptr, new, _o_);	\
+		break;							\
+									\
+	case 8:								\
+		_r_ = ia64_cmpxchg8_##sem((__u64 *) ptr, new, _o_);	\
+		break;							\
+									\
+	default:							\
+		_r_ = ia64_cmpxchg_called_with_bad_pointer();		\
+		break;							\
+	}								\
+	(__typeof__(old)) _r_;						\
+})
+
+#define cmpxchg_acq(ptr, o, n)	\
+	ia64_cmpxchg(acq, (ptr), (o), (n), sizeof(*(ptr)))
+#define cmpxchg_rel(ptr, o, n)	\
+	ia64_cmpxchg(rel, (ptr), (o), (n), sizeof(*(ptr)))
+
+/* for compatibility with other platforms: */
+#define cmpxchg(ptr, o, n)	cmpxchg_acq((ptr), (o), (n))
+#define cmpxchg64(ptr, o, n)	cmpxchg_acq((ptr), (o), (n))
+
+#define cmpxchg_local		cmpxchg
+#define cmpxchg64_local		cmpxchg64
+
+#ifdef CONFIG_IA64_DEBUG_CMPXCHG
+# define CMPXCHG_BUGCHECK_DECL	int _cmpxchg_bugcheck_count = 128;
+# define CMPXCHG_BUGCHECK(v)						\
+do {									\
+	if (_cmpxchg_bugcheck_count-- <= 0) {				\
+		void *ip;						\
+		extern int printk(const char *fmt, ...);		\
+		ip = (void *) ia64_getreg(_IA64_REG_IP);		\
+		printk("CMPXCHG_BUGCHECK: stuck at %p on word %p\n", ip, (v));\
+		break;							\
+	}								\
+} while (0)
+#else /* !CONFIG_IA64_DEBUG_CMPXCHG */
+# define CMPXCHG_BUGCHECK_DECL
+# define CMPXCHG_BUGCHECK(v)
+#endif /* !CONFIG_IA64_DEBUG_CMPXCHG */
+
+#endif /* !__ASSEMBLY__ */
+
+#endif /* _ASM_IA64_CMPXCHG_H */
diff --git a/arch/ia64/include/asm/intrinsics.h b/arch/ia64/include/asm/intrinsics.h
index e4076b5..d129e36 100644
--- a/arch/ia64/include/asm/intrinsics.h
+++ b/arch/ia64/include/asm/intrinsics.h
@@ -18,6 +18,7 @@
 #else
 # include <asm/gcc_intrin.h>
 #endif
+#include <asm/cmpxchg.h>
 
 #define ia64_native_get_psr_i()	(ia64_native_getreg(_IA64_REG_PSR) & IA64_PSR_I)
 
@@ -81,119 +82,6 @@ extern unsigned long __bad_increment_for_ia64_fetch_and_add (void);
 
 #define ia64_fetch_and_add(i,v)	(ia64_fetchadd(i, v, rel) + (i)) /* return new value */
 
-/*
- * This function doesn't exist, so you'll get a linker error if
- * something tries to do an invalid xchg().
- */
-extern void ia64_xchg_called_with_bad_pointer (void);
-
-#define __xchg(x,ptr,size)						\
-({									\
-	unsigned long __xchg_result;					\
-									\
-	switch (size) {							\
-	      case 1:							\
-		__xchg_result = ia64_xchg1((__u8 *)ptr, x);		\
-		break;							\
-									\
-	      case 2:							\
-		__xchg_result = ia64_xchg2((__u16 *)ptr, x);		\
-		break;							\
-									\
-	      case 4:							\
-		__xchg_result = ia64_xchg4((__u32 *)ptr, x);		\
-		break;							\
-									\
-	      case 8:							\
-		__xchg_result = ia64_xchg8((__u64 *)ptr, x);		\
-		break;							\
-	      default:							\
-		ia64_xchg_called_with_bad_pointer();			\
-	}								\
-	__xchg_result;							\
-})
-
-#define xchg(ptr,x)							     \
-  ((__typeof__(*(ptr))) __xchg ((unsigned long) (x), (ptr), sizeof(*(ptr))))
-
-/*
- * Atomic compare and exchange.  Compare OLD with MEM, if identical,
- * store NEW in MEM.  Return the initial value in MEM.  Success is
- * indicated by comparing RETURN with OLD.
- */
-
-#define __HAVE_ARCH_CMPXCHG 1
-
-/*
- * This function doesn't exist, so you'll get a linker error
- * if something tries to do an invalid cmpxchg().
- */
-extern long ia64_cmpxchg_called_with_bad_pointer (void);
-
-#define ia64_cmpxchg(sem,ptr,old,new,size)						\
-({											\
-	__u64 _o_, _r_;									\
-											\
-	switch (size) {									\
-	      case 1: _o_ = (__u8 ) (long) (old); break;				\
-	      case 2: _o_ = (__u16) (long) (old); break;				\
-	      case 4: _o_ = (__u32) (long) (old); break;				\
-	      case 8: _o_ = (__u64) (long) (old); break;				\
-	      default: break;								\
-	}										\
-	switch (size) {									\
-	      case 1:									\
-	      	_r_ = ia64_cmpxchg1_##sem((__u8 *) ptr, new, _o_);			\
-		break;									\
-											\
-	      case 2:									\
-	       _r_ = ia64_cmpxchg2_##sem((__u16 *) ptr, new, _o_);			\
-		break;									\
-											\
-	      case 4:									\
-	      	_r_ = ia64_cmpxchg4_##sem((__u32 *) ptr, new, _o_);			\
-		break;									\
-											\
-	      case 8:									\
-		_r_ = ia64_cmpxchg8_##sem((__u64 *) ptr, new, _o_);			\
-		break;									\
-											\
-	      default:									\
-		_r_ = ia64_cmpxchg_called_with_bad_pointer();				\
-		break;									\
-	}										\
-	(__typeof__(old)) _r_;								\
-})
-
-#define cmpxchg_acq(ptr, o, n)	\
-	ia64_cmpxchg(acq, (ptr), (o), (n), sizeof(*(ptr)))
-#define cmpxchg_rel(ptr, o, n)	\
-	ia64_cmpxchg(rel, (ptr), (o), (n), sizeof(*(ptr)))
-
-/* for compatibility with other platforms: */
-#define cmpxchg(ptr, o, n)	cmpxchg_acq((ptr), (o), (n))
-#define cmpxchg64(ptr, o, n)	cmpxchg_acq((ptr), (o), (n))
-
-#define cmpxchg_local		cmpxchg
-#define cmpxchg64_local		cmpxchg64
-
-#ifdef CONFIG_IA64_DEBUG_CMPXCHG
-# define CMPXCHG_BUGCHECK_DECL	int _cmpxchg_bugcheck_count = 128;
-# define CMPXCHG_BUGCHECK(v)							\
-  do {										\
-	if (_cmpxchg_bugcheck_count-- <= 0) {					\
-		void *ip;							\
-		extern int printk(const char *fmt, ...);			\
-		ip = (void *) ia64_getreg(_IA64_REG_IP);			\
-		printk("CMPXCHG_BUGCHECK: stuck at %p on word %p\n", ip, (v));	\
-		break;								\
-	}									\
-  } while (0)
-#else /* !CONFIG_IA64_DEBUG_CMPXCHG */
-# define CMPXCHG_BUGCHECK_DECL
-# define CMPXCHG_BUGCHECK(v)
-#endif /* !CONFIG_IA64_DEBUG_CMPXCHG */
-
 #endif
 
 #ifdef __KERNEL__
-- 
1.7.9.1


From: Lv Zheng <lv.zheng@intel.com>
Date: Wed, 23 Apr 2014 06:54:06 +0000
Subject: [PATCH v2 3/5] ACPICA: Add <asm/acenv.h> to remove mis-ordered inclusion of <asm/acpi.h> from <acpi/
Message-Id: <522ac0c3a52f1697d75363cc808a213773dca295.1398232409.git.lv.zheng@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1396930406.git.lv.zheng@intel.com> <cover.1398232408.git.lv.zheng@intel.com>
In-Reply-To: <cover.1398232408.git.lv.zheng@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>
Cc: Lv Zheng <lv.zheng@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

There is a mis-order inclusion for <asm/acpi.h>.

As we will enforce including <linux/acpi.h> for all Linux ACPI users, we
can find the inclusion order is as follows:

<linux/acpi.h>
  <acpi/acpi.h>
   <acpi/platform/acenv.h>
    (acenv.h before including aclinux.h)
    <acpi/platform/aclinux.h>
...........................................................................
     (aclinux.h before including asm/acpi.h)
     <asm/acpi.h>                             @Redundant@
      (ACPICA specific stuff)
...........................................................................
...........................................................................
      (Linux ACPI specific stuff) ? - - - - - - - - - - - - +
     (aclinux.h after including asm/acpi.h)   @Invisible@   |
    (acenv.h after including aclinux.h)       @Invisible@   |
   other ACPICA headers                       @Invisible@   |
............................................................|..............
  <acpi/acpi_bus.h>                                         |
  <acpi/acpi_drivers.h>                                     |
  <asm/acpi.h> (Excluded)                                   |
   (Linux ACPI specific stuff) ! <- - - - - - - - - - - - - +

NOTE that, in ACPICA, <acpi/platform/acenv.h> is more like Kconfig
generated <generated/autoconf.h> for Linux, it is meant to be included
before including any ACPICA code.

In the above figure, there is a question mark for "Linux ACPI specific
stuff" in <asm/acpi.h> which should be included after including all other
ACPICA header files.  Thus they really need to be moved to the position
marked with exclaimation mark or the definitions in the blocks marked with
"@Invisible@" will be invisible to such architecture specific "Linux ACPI
specific stuff" header blocks.  This leaves 2 issues:
1. All environmental definitions in these blocks should have a copy in the
   area marked with "@Redundant@" if they are required by the "Linux ACPI
   specific stuff".
2. We cannot use any ACPICA defined types in <asm/acpi.h>.

This patch splits architecture specific ACPICA stuff from <asm/acpi.h> to
fix this issue.

Signed-off-by: Lv Zheng <lv.zheng@intel.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
---
 arch/ia64/include/asm/acenv.h   |   71 +++++++++++++++++++++++++++++++++++++++
 arch/ia64/include/asm/acpi.h    |   50 ---------------------------
 arch/x86/include/asm/acenv.h    |   65 +++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/acpi.h     |   45 -------------------------
 include/acpi/platform/aclinux.h |    2 +-
 5 files changed, 137 insertions(+), 96 deletions(-)
 create mode 100644 arch/ia64/include/asm/acenv.h
 create mode 100644 arch/x86/include/asm/acenv.h

diff --git a/arch/ia64/include/asm/acenv.h b/arch/ia64/include/asm/acenv.h
new file mode 100644
index 0000000..e0896eb
--- /dev/null
+++ b/arch/ia64/include/asm/acenv.h
@@ -0,0 +1,71 @@
+/*
+ * IA64 specific ACPICA environments and implementation
+ *
+ * Copyright (C) 2014, Intel Corporation
+ *   Author: Lv Zheng <lv.zheng@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_IA64_ACENV_H
+#define _ASM_IA64_ACENV_H
+
+#include <asm/intrinsics.h>
+
+#define COMPILER_DEPENDENT_INT64	long
+#define COMPILER_DEPENDENT_UINT64	unsigned long
+
+/*
+ * Calling conventions:
+ *
+ * ACPI_SYSTEM_XFACE        - Interfaces to host OS (handlers, threads)
+ * ACPI_EXTERNAL_XFACE      - External ACPI interfaces
+ * ACPI_INTERNAL_XFACE      - Internal ACPI interfaces
+ * ACPI_INTERNAL_VAR_XFACE  - Internal variable-parameter list interfaces
+ */
+#define ACPI_SYSTEM_XFACE
+#define ACPI_EXTERNAL_XFACE
+#define ACPI_INTERNAL_XFACE
+#define ACPI_INTERNAL_VAR_XFACE
+
+/* Asm macros */
+
+#define ACPI_FLUSH_CPU_CACHE()
+
+#ifdef CONFIG_ACPI
+
+static inline int
+ia64_acpi_acquire_global_lock(unsigned int *lock)
+{
+	unsigned int old, new, val;
+	do {
+		old = *lock;
+		new = (((old & ~0x3) + 2) + ((old >> 1) & 0x1));
+		val = ia64_cmpxchg4_acq(lock, new, old);
+	} while (unlikely (val != old));
+	return (new < 3) ? -1 : 0;
+}
+
+static inline int
+ia64_acpi_release_global_lock(unsigned int *lock)
+{
+	unsigned int old, new, val;
+	do {
+		old = *lock;
+		new = old & ~0x3;
+		val = ia64_cmpxchg4_acq(lock, new, old);
+	} while (unlikely (val != old));
+	return old & 0x1;
+}
+
+#define ACPI_ACQUIRE_GLOBAL_LOCK(facs, Acq)				\
+	((Acq) = ia64_acpi_acquire_global_lock(&facs->global_lock))
+
+#define ACPI_RELEASE_GLOBAL_LOCK(facs, Acq)				\
+	((Acq) = ia64_acpi_release_global_lock(&facs->global_lock))
+
+#endif
+
+#endif /* _ASM_IA64_ACENV_H */
diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index d651102..b0ddcfd 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -34,56 +34,6 @@
 #include <linux/numa.h>
 #include <asm/numa.h>
 
-#define COMPILER_DEPENDENT_INT64	long
-#define COMPILER_DEPENDENT_UINT64	unsigned long
-
-/*
- * Calling conventions:
- *
- * ACPI_SYSTEM_XFACE        - Interfaces to host OS (handlers, threads)
- * ACPI_EXTERNAL_XFACE      - External ACPI interfaces
- * ACPI_INTERNAL_XFACE      - Internal ACPI interfaces
- * ACPI_INTERNAL_VAR_XFACE  - Internal variable-parameter list interfaces
- */
-#define ACPI_SYSTEM_XFACE
-#define ACPI_EXTERNAL_XFACE
-#define ACPI_INTERNAL_XFACE
-#define ACPI_INTERNAL_VAR_XFACE
-
-/* Asm macros */
-
-#define ACPI_FLUSH_CPU_CACHE()
-
-static inline int
-ia64_acpi_acquire_global_lock (unsigned int *lock)
-{
-	unsigned int old, new, val;
-	do {
-		old = *lock;
-		new = (((old & ~0x3) + 2) + ((old >> 1) & 0x1));
-		val = ia64_cmpxchg4_acq(lock, new, old);
-	} while (unlikely (val != old));
-	return (new < 3) ? -1 : 0;
-}
-
-static inline int
-ia64_acpi_release_global_lock (unsigned int *lock)
-{
-	unsigned int old, new, val;
-	do {
-		old = *lock;
-		new = old & ~0x3;
-		val = ia64_cmpxchg4_acq(lock, new, old);
-	} while (unlikely (val != old));
-	return old & 0x1;
-}
-
-#define ACPI_ACQUIRE_GLOBAL_LOCK(facs, Acq)				\
-	((Acq) = ia64_acpi_acquire_global_lock(&facs->global_lock))
-
-#define ACPI_RELEASE_GLOBAL_LOCK(facs, Acq)				\
-	((Acq) = ia64_acpi_release_global_lock(&facs->global_lock))
-
 #ifdef	CONFIG_ACPI
 #define acpi_disabled 0	/* ACPI always enabled on IA64 */
 #define acpi_noirq 0	/* ACPI always enabled on IA64 */
diff --git a/arch/x86/include/asm/acenv.h b/arch/x86/include/asm/acenv.h
new file mode 100644
index 0000000..6978584
--- /dev/null
+++ b/arch/x86/include/asm/acenv.h
@@ -0,0 +1,65 @@
+/*
+ * X86 specific ACPICA environments and implementation
+ *
+ * Copyright (C) 2014, Intel Corporation
+ *   Author: Lv Zheng <lv.zheng@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_X86_ACENV_H
+#define _ASM_X86_ACENV_H
+
+#include <asm/special_insns.h>
+
+#define COMPILER_DEPENDENT_INT64   long long
+#define COMPILER_DEPENDENT_UINT64  unsigned long long
+
+/*
+ * Calling conventions:
+ *
+ * ACPI_SYSTEM_XFACE        - Interfaces to host OS (handlers, threads)
+ * ACPI_EXTERNAL_XFACE      - External ACPI interfaces
+ * ACPI_INTERNAL_XFACE      - Internal ACPI interfaces
+ * ACPI_INTERNAL_VAR_XFACE  - Internal variable-parameter list interfaces
+ */
+#define ACPI_SYSTEM_XFACE
+#define ACPI_EXTERNAL_XFACE
+#define ACPI_INTERNAL_XFACE
+#define ACPI_INTERNAL_VAR_XFACE
+
+/* Asm macros */
+
+#define ACPI_FLUSH_CPU_CACHE()	wbinvd()
+
+#ifdef CONFIG_ACPI
+
+int __acpi_acquire_global_lock(unsigned int *lock);
+int __acpi_release_global_lock(unsigned int *lock);
+
+#define ACPI_ACQUIRE_GLOBAL_LOCK(facs, Acq) \
+	((Acq) = __acpi_acquire_global_lock(&facs->global_lock))
+
+#define ACPI_RELEASE_GLOBAL_LOCK(facs, Acq) \
+	((Acq) = __acpi_release_global_lock(&facs->global_lock))
+
+/*
+ * Math helper asm macros
+ */
+#define ACPI_DIV_64_BY_32(n_hi, n_lo, d32, q32, r32) \
+	asm("divl %2;"				     \
+	    : "=a"(q32), "=d"(r32)		     \
+	    : "r"(d32),				     \
+	     "0"(n_lo), "1"(n_hi))
+
+#define ACPI_SHIFT_RIGHT_64(n_hi, n_lo) \
+	asm("shrl   $1,%2	;"	\
+	    "rcrl   $1,%3;"		\
+	    : "=r"(n_hi), "=r"(n_lo)	\
+	    : "0"(n_hi), "1"(n_lo))
+
+#endif
+
+#endif /* _ASM_X86_ACENV_H */
diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
index c8c1e70..e06225e 100644
--- a/arch/x86/include/asm/acpi.h
+++ b/arch/x86/include/asm/acpi.h
@@ -32,51 +32,6 @@
 #include <asm/mpspec.h>
 #include <asm/realmode.h>
 
-#define COMPILER_DEPENDENT_INT64   long long
-#define COMPILER_DEPENDENT_UINT64  unsigned long long
-
-/*
- * Calling conventions:
- *
- * ACPI_SYSTEM_XFACE        - Interfaces to host OS (handlers, threads)
- * ACPI_EXTERNAL_XFACE      - External ACPI interfaces
- * ACPI_INTERNAL_XFACE      - Internal ACPI interfaces
- * ACPI_INTERNAL_VAR_XFACE  - Internal variable-parameter list interfaces
- */
-#define ACPI_SYSTEM_XFACE
-#define ACPI_EXTERNAL_XFACE
-#define ACPI_INTERNAL_XFACE
-#define ACPI_INTERNAL_VAR_XFACE
-
-/* Asm macros */
-
-#define ACPI_FLUSH_CPU_CACHE()	wbinvd()
-
-int __acpi_acquire_global_lock(unsigned int *lock);
-int __acpi_release_global_lock(unsigned int *lock);
-
-#define ACPI_ACQUIRE_GLOBAL_LOCK(facs, Acq) \
-	((Acq) = __acpi_acquire_global_lock(&facs->global_lock))
-
-#define ACPI_RELEASE_GLOBAL_LOCK(facs, Acq) \
-	((Acq) = __acpi_release_global_lock(&facs->global_lock))
-
-/*
- * Math helper asm macros
- */
-#define ACPI_DIV_64_BY_32(n_hi, n_lo, d32, q32, r32) \
-	asm("divl %2;"				     \
-	    : "=a"(q32), "=d"(r32)		     \
-	    : "r"(d32),				     \
-	     "0"(n_lo), "1"(n_hi))
-
-
-#define ACPI_SHIFT_RIGHT_64(n_hi, n_lo) \
-	asm("shrl   $1,%2	;"	\
-	    "rcrl   $1,%3;"		\
-	    : "=r"(n_hi), "=r"(n_lo)	\
-	    : "0"(n_hi), "1"(n_lo))
-
 #ifdef CONFIG_ACPI
 extern int acpi_lapic;
 extern int acpi_ioapic;
diff --git a/include/acpi/platform/aclinux.h b/include/acpi/platform/aclinux.h
index a20f051..99d0546 100644
--- a/include/acpi/platform/aclinux.h
+++ b/include/acpi/platform/aclinux.h
@@ -71,7 +71,7 @@
 #ifdef EXPORT_ACPI_INTERFACES
 #include <linux/export.h>
 #endif
-#include <asm/acpi.h>
+#include <asm/acenv.h>
 
 /* Host-dependent types and defines for in-kernel ACPICA */
 
-- 
1.7.10


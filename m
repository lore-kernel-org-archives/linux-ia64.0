From: Lv Zheng <lv.zheng@intel.com>
Date: Tue, 08 Apr 2014 07:57:04 +0000
Subject: [PATCH 3/4] ACPICA: Cleanup redudant definitions that already have defaults in <acpi/platform/acenv.
Message-Id: <c2ff25bb3a3383d6e40317577918b803089c9df4.1396930406.git.lv.zheng@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1385110130.git.lv.zheng@intel.com> <cover.1396930406.git.lv.zheng@intel.com>
In-Reply-To: <cover.1396930406.git.lv.zheng@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>
Cc: Lv Zheng <lv.zheng@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Since mis-order issues have been solved, we can cleanup redundant
definitions that already have defaults in <acpi/platform/acenv.h>.

This patch removes redudant environments for __KERNEL__ surrounded code.

Signed-off-by: Lv Zheng <lv.zheng@intel.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
---
 arch/ia64/include/asm/acenv.h   |   15 ---------------
 arch/x86/include/asm/acenv.h    |   16 ----------------
 include/acpi/platform/aclinux.h |    1 -
 3 files changed, 32 deletions(-)

diff --git a/arch/ia64/include/asm/acenv.h b/arch/ia64/include/asm/acenv.h
index e0896eb..3f9eaee 100644
--- a/arch/ia64/include/asm/acenv.h
+++ b/arch/ia64/include/asm/acenv.h
@@ -17,23 +17,8 @@
 #define COMPILER_DEPENDENT_INT64	long
 #define COMPILER_DEPENDENT_UINT64	unsigned long
 
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
 /* Asm macros */
 
-#define ACPI_FLUSH_CPU_CACHE()
-
 #ifdef CONFIG_ACPI
 
 static inline int
diff --git a/arch/x86/include/asm/acenv.h b/arch/x86/include/asm/acenv.h
index 6978584..6687329 100644
--- a/arch/x86/include/asm/acenv.h
+++ b/arch/x86/include/asm/acenv.h
@@ -14,22 +14,6 @@
 
 #include <asm/special_insns.h>
 
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
 /* Asm macros */
 
 #define ACPI_FLUSH_CPU_CACHE()	wbinvd()
diff --git a/include/acpi/platform/aclinux.h b/include/acpi/platform/aclinux.h
index a12e9e0..943c167 100644
--- a/include/acpi/platform/aclinux.h
+++ b/include/acpi/platform/aclinux.h
@@ -48,7 +48,6 @@
 
 #define ACPI_USE_SYSTEM_CLIBRARY
 #define ACPI_USE_DO_WHILE_0
-#define ACPI_MUTEX_TYPE             ACPI_BINARY_SEMAPHORE
 
 #ifdef __KERNEL__
 
-- 
1.7.10


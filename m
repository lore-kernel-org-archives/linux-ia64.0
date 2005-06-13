From: Ashok Raj <ashok.raj@intel.com>
Date: Mon, 13 Jun 2005 21:23:55 +0000
Subject: ia64: Add cpu cache flush to offlining cpu
Message-Id: <20050613142355.A4152@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony

This patch adds a cache flush to the offlining CPU. Also added the same
to ACPI counterpart that requires this as well.

Please consider this patch along with BSP removal patch posted earlier
for next ia64 test tree.

-- 
Cheers,
Ashok Raj
- Open Source Technology Center


Flush caches on cpu thats going to go away. Also added to
ACPI_FLUSH_CPU_CACHE which was null macro earlier.

Had to remove linux/include/proc_fs.h from efi.h to
have sal.h included. Triggers many compile errors
without removal.

Signed-off-by: Ashok Raj <ashok.raj@intel.com>
---------------------------------------------
 arch/ia64/kernel/process.c |    1 +
 include/asm-ia64/acpi.h    |    3 ++-
 include/asm-ia64/sal.h     |    5 +++++
 include/linux/efi.h        |    1 -
 4 files changed, 8 insertions(+), 2 deletions(-)

Index: linux-2.6.12-rc6-mm1/arch/ia64/kernel/process.c
=================================--- linux-2.6.12-rc6-mm1.orig/arch/ia64/kernel/process.c
+++ linux-2.6.12-rc6-mm1/arch/ia64/kernel/process.c
@@ -215,6 +215,7 @@ static inline void play_dead(void)
 	max_xtp();
 	local_irq_disable();
 	idle_task_exit();
+	ia64_sal_cache_flush(FLUSH_INST_DATA_CACHE);
 	ia64_jump_to_sal(&sal_boot_rendez_state[this_cpu]);
 	/*
 	 * The above is a point of no-return, the processor is
Index: linux-2.6.12-rc6-mm1/include/asm-ia64/acpi.h
=================================--- linux-2.6.12-rc6-mm1.orig/include/asm-ia64/acpi.h
+++ linux-2.6.12-rc6-mm1/include/asm-ia64/acpi.h
@@ -33,6 +33,7 @@
 #include <linux/init.h>
 #include <linux/numa.h>
 #include <asm/system.h>
+#include <asm/sal.h>
 
 #define COMPILER_DEPENDENT_INT64	long
 #define COMPILER_DEPENDENT_UINT64	unsigned long
@@ -56,7 +57,7 @@
 #define BREAKPOINT3
 #define ACPI_DISABLE_IRQS() local_irq_disable()
 #define ACPI_ENABLE_IRQS()  local_irq_enable()
-#define ACPI_FLUSH_CPU_CACHE()
+#define ACPI_FLUSH_CPU_CACHE() ia64_sal_cache_flush(FLUSH_INST_DATA_CACHE)
 
 static inline int
 ia64_acpi_acquire_global_lock (unsigned int *lock)
Index: linux-2.6.12-rc6-mm1/include/asm-ia64/sal.h
=================================--- linux-2.6.12-rc6-mm1.orig/include/asm-ia64/sal.h
+++ linux-2.6.12-rc6-mm1/include/asm-ia64/sal.h
@@ -657,6 +657,11 @@ ia64_sal_freq_base (unsigned long which,
 	return isrv.status;
 }
 
+#define FLUSH_INSTR_CACHE		(1UL)
+#define FLUSH_DATA_CACHE		(2UL)
+#define FLUSH_INST_DATA_CACHE	(3UL)
+#define MAKE_INST_DATA_COHERENT	(4UL)
+
 /* Flush all the processor and platform level instruction and/or data caches */
 static inline s64
 ia64_sal_cache_flush (u64 cache_type)
Index: linux-2.6.12-rc6-mm1/include/linux/efi.h
=================================--- linux-2.6.12-rc6-mm1.orig/include/linux/efi.h
+++ linux-2.6.12-rc6-mm1/include/linux/efi.h
@@ -15,7 +15,6 @@
 #include <linux/string.h>
 #include <linux/time.h>
 #include <linux/types.h>
-#include <linux/proc_fs.h>
 #include <linux/rtc.h>
 #include <linux/ioport.h>
 

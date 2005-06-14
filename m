From: Ashok Raj <ashok.raj@intel.com>
Date: Tue, 14 Jun 2005 02:16:48 +0000
Subject: Re: ia64: Add cpu cache flush to offlining cpu
Message-Id: <20050613191647.A6274@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050613142355.A4152@unix-os.sc.intel.com>
In-Reply-To: <20050613142355.A4152@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 13, 2005 at 02:44:03PM -0700, David Mosberger wrote:
> >>>>> On Mon, 13 Jun 2005 14:23:55 -0700, Ashok Raj <ashok.raj@intel.com> said:
> 
>   Ashok> +#define FLUSH_INSTR_CACHE		(1UL)
>   Ashok> +#define FLUSH_DATA_CACHE		(2UL)
>   Ashok> +#define FLUSH_INST_DATA_CACHE	(3UL)
>   Ashok> +#define MAKE_INST_DATA_COHERENT	(4UL)
> 
> How about using a "SAL_" prefix for these (customary and given the
> generic nature of these names, it's quite likely that sooner or later
> the unprefixed names would cause a collision with other kernel
> headers).

Makes perfect sense... just oversight... Thanks

modified patch attached.

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
+	ia64_sal_cache_flush(SAL_FLUSH_INST_DATA_CACHE);
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
+#define ACPI_FLUSH_CPU_CACHE() ia64_sal_cache_flush(SAL_FLUSH_INST_DATA_CACHE)
 
 static inline int
 ia64_acpi_acquire_global_lock (unsigned int *lock)
Index: linux-2.6.12-rc6-mm1/include/asm-ia64/sal.h
=================================--- linux-2.6.12-rc6-mm1.orig/include/asm-ia64/sal.h
+++ linux-2.6.12-rc6-mm1/include/asm-ia64/sal.h
@@ -657,6 +657,11 @@ ia64_sal_freq_base (unsigned long which,
 	return isrv.status;
 }
 
+#define SAL_FLUSH_INSTR_CACHE		(1UL)
+#define SAL_FLUSH_DATA_CACHE		(2UL)
+#define SAL_FLUSH_INST_DATA_CACHE	(3UL)
+#define SAL_MAKE_INST_DATA_COHERENT	(4UL)
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
 

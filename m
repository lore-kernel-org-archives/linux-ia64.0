From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:31 +0000
Subject: [PATCH 12/35] cpumask: make CONFIG_NR_CPUS always valid.
Message-Id: <20081020170321.260062000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Currently we have NR_CPUS, which is 1 on UP, and CONFIG_NR_CPUS on
SMP.  If we make CONFIG_NR_CPUS always valid (and always 1 on !SMP),
we can skip the middleman.

This also allows us to find and check all the remaining NR_CPUS users.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/alpha/Kconfig      |   10 +++++-----
 arch/arm/Kconfig        |    6 +++---
 arch/ia64/Kconfig       |    8 ++++----
 arch/m32r/Kconfig       |    8 ++++----
 arch/mips/Kconfig       |    4 ++--
 arch/parisc/Kconfig     |    8 ++++----
 arch/s390/Kconfig       |   10 +++++-----
 arch/sh/Kconfig         |   10 +++++-----
 arch/sparc/Kconfig      |    8 ++++----
 arch/sparc64/Kconfig    |    8 ++++----
 arch/um/Kconfig         |    8 ++++----
 arch/x86/Kconfig        |   11 +++++------
 include/linux/threads.h |   10 ++--------
 13 files changed, 51 insertions(+), 58 deletions(-)

--- test-compile.orig/arch/alpha/Kconfig
+++ test-compile/arch/alpha/Kconfig
@@ -543,11 +543,11 @@ config HAVE_DEC_LOCK
 	default y
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-32)"
-	range 2 32
-	depends on SMP
-	default "32" if ALPHA_GENERIC || ALPHA_MARVEL
-	default "4" if !ALPHA_GENERIC && !ALPHA_MARVEL
+	int "Maximum number of CPUs (2-32)" if SMP
+	range 2 32 if SMP
+	default "1" if !SMP
+	default "32" if SMP && (ALPHA_GENERIC || ALPHA_MARVEL)
+	default "4" if SMP && (!ALPHA_GENERIC && !ALPHA_MARVEL)
 	help
 	  MARVEL support can handle a maximum of 32 CPUs, all the others
           with working support have a maximum of 4 CPUs.
--- test-compile.orig/arch/arm/Kconfig
+++ test-compile/arch/arm/Kconfig
@@ -767,9 +767,9 @@ config PAGE_OFFSET
 	default 0xC0000000
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-32)"
-	range 2 32
-	depends on SMP
+	int "Maximum number of CPUs (2-32)" if SMP
+	range 2 32 if SMP
+	default "1" if !SMP
 	default "4"
 
 config HOTPLUG_CPU
--- test-compile.orig/arch/ia64/Kconfig
+++ test-compile/arch/ia64/Kconfig
@@ -313,10 +313,10 @@ config SMP
 	  If you don't know what to do here, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-4096)"
-	range 2 4096
-	depends on SMP
-	default "4096"
+	int "Maximum number of CPUs (2-4096)" if SMP
+	range 2 4096 if SMP
+	default "1" if !SMP
+	default "4096" if SMP
 	help
 	  You should set this to the number of CPUs in your system, but
 	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
--- test-compile.orig/arch/m32r/Kconfig
+++ test-compile/arch/m32r/Kconfig
@@ -316,10 +316,10 @@ config CHIP_M32700_TS1
 	default n
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-32)"
-	range 2 32
-	depends on SMP
-	default "2"
+	int "Maximum number of CPUs (2-32)" if SMP
+	range 2 32 if SMP
+	default "1" if !SMP
+	default "2" if SMP
 	help
 	  This allows you to specify the maximum number of CPUs which this
 	  kernel will support.  The maximum supported value is 32 and the
--- test-compile.orig/arch/mips/Kconfig
+++ test-compile/arch/mips/Kconfig
@@ -1719,9 +1719,9 @@ config NR_CPUS_DEFAULT_64
 	bool
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-64)"
+	int "Maximum number of CPUs (2-64)" if SMP
 	range 1 64 if NR_CPUS_DEFAULT_1
-	depends on SMP
+	default "1" if !SMP
 	default "1" if NR_CPUS_DEFAULT_1
 	default "2" if NR_CPUS_DEFAULT_2
 	default "4" if NR_CPUS_DEFAULT_4
--- test-compile.orig/arch/parisc/Kconfig
+++ test-compile/arch/parisc/Kconfig
@@ -251,10 +251,10 @@ config HPUX
 	depends on !64BIT
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-32)"
-	range 2 32
-	depends on SMP
-	default "32"
+	int "Maximum number of CPUs (2-32)" if SMP
+	range 2 32 if SMP
+	default "1" if !SMP
+	default "32" if SMP
 
 endmenu
 
--- test-compile.orig/arch/s390/Kconfig
+++ test-compile/arch/s390/Kconfig
@@ -113,11 +113,11 @@ config SMP
 	  Even if you don't know what to do here, say Y.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-64)"
-	range 2 64
-	depends on SMP
-	default "32" if !64BIT
-	default "64" if 64BIT
+	int "Maximum number of CPUs (2-64)" if SMP
+	range 2 64 if SMP
+	default "1" if !SMP
+	default "32" if SMP && !64BIT
+	default "64" if SMP && 64BIT
 	help
 	  This allows you to specify the maximum number of CPUs which this
 	  kernel will support.  The maximum supported value is 64 and the
--- test-compile.orig/arch/sh/Kconfig
+++ test-compile/arch/sh/Kconfig
@@ -528,11 +528,11 @@ config SMP
 	  If you don't know what to do here, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-32)"
-	range 2 32
-	depends on SMP
-	default "4" if CPU_SHX3
-	default "2"
+	int "Maximum number of CPUs (2-32)" if SMP
+	range 2 32 if SMP
+	default "1" if !SMP
+	default "4" if SMP && CPU_SHX3
+	default "2" if SMP
 	help
 	  This allows you to specify the maximum number of CPUs which this
 	  kernel will support.  The maximum supported value is 32 and the
--- test-compile.orig/arch/sparc/Kconfig
+++ test-compile/arch/sparc/Kconfig
@@ -62,10 +62,10 @@ config SMP
 	  If you don't know what to do here, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-32)"
-	range 2 32
-	depends on SMP
-	default "32"
+	int "Maximum number of CPUs (2-32)" if SMP
+	range 2 32 if SMP
+	default "1" if SMP
+	default "32" if SMP
 
 config SPARC
 	bool
--- test-compile.orig/arch/sparc64/Kconfig
+++ test-compile/arch/sparc64/Kconfig
@@ -168,10 +168,10 @@ config SMP
 	  If you don't know what to do here, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-1024)"
-	range 2 1024
-	depends on SMP
-	default "64"
+	int "Maximum number of CPUs (2-1024)" if SMP
+	range 2 1024 if SMP
+	default "1" if !SMP
+	default "64" if SMP
 
 source "drivers/cpufreq/Kconfig"
 
--- test-compile.orig/arch/um/Kconfig
+++ test-compile/arch/um/Kconfig
@@ -198,10 +198,10 @@ config SMP
 	  If you don't know what to do, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-32)"
-	range 2 32
-	depends on SMP
-	default "32"
+	int "Maximum number of CPUs (2-32)" if SMP
+	range 2 32 if SMP
+	default "1" if !SMP
+	default "32" if SMP
 
 config HIGHMEM
 	bool "Highmem support (EXPERIMENTAL)"
--- test-compile.orig/arch/x86/Kconfig
+++ test-compile/arch/x86/Kconfig
@@ -586,12 +586,11 @@ endif
 
 if !MAXSMP
 config NR_CPUS
-	int "Maximum number of CPUs (2-512)" if !MAXSMP
-	range 2 512
-	depends on SMP
-	default "4096" if MAXSMP
-	default "32" if X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000
-	default "8"
+	int "Maximum number of CPUs (2-512)" if SMP
+	range 2 512 if SMP
+	default "1" if !SMP
+	default "32" if SMP && (X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000)
+	default "8" if SMP
 	help
 	  This allows you to specify the maximum number of CPUs which this
 	  kernel will support.  The maximum supported value is 512 and the
--- test-compile.orig/include/linux/threads.h
+++ test-compile/include/linux/threads.h
@@ -8,16 +8,10 @@
  */
 
 /*
- * Maximum supported processors that can run under SMP.  This value is
- * set via configure setting.  The maximum is equal to the size of the
- * bitmasks used on that platform, i.e. 32 or 64.  Setting this smaller
- * saves quite a bit of memory.
+ * Maximum supported processors.  Setting this smaller saves quite a
+ * bit of memory.  Use nr_cpu_ids instead of this except for bitmaps.
  */
-#ifdef CONFIG_SMP
 #define NR_CPUS		CONFIG_NR_CPUS
-#else
-#define NR_CPUS		1
-#endif
 
 #define MIN_THREADS_LEFT_FOR_ROOT 4
 

-- 

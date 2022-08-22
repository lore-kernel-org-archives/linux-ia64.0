From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 22 Aug 2022 02:15:12 +0000
Subject: [RFC 02/10] cpu/hotplug: Compile smp_shutdown_nonboot_cpus() conditioned on CONFIG_SHUTDOWN_NONBOOT_
Message-Id: <20220822021520.6996-3-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220822021520.6996-1-kernelfans@gmail.com>
In-Reply-To: <20220822021520.6996-1-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Peter Zijlstra <peterz@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, Masami Hiramatsu <mhiramat@kernel.org>, Dan Li <ashimida@linux.alibaba.com>, Song Liu <song@kernel.org>, Sami Tolvanen <samitolvanen@google.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ardb@kernel.org>, Tony Lindgren <tony@atomide.com>, Nick Hawkins <nick.hawkins@hpe.com>, John Crispin <john@phrozen.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Price <steven.price@arm.com>

Only arm/arm64/ia64/riscv share the smp_shutdown_nonboot_cpus(). So
compiling this code conditioned on the macro
CONFIG_SHUTDOWN_NONBOOT_CPUS. Later this macro will brace the quick
kexec reboot code.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Marco Elver <elver@google.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Dan Li <ashimida@linux.alibaba.com>
Cc: Song Liu <song@kernel.org>
Cc: Sami Tolvanen <samitolvanen@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Linus Walleij <linus.walleij@linaro.org>
Cc: Ard Biesheuvel <ardb@kernel.org>
Cc: Tony Lindgren <tony@atomide.com>
Cc: Nick Hawkins <nick.hawkins@hpe.com>
Cc: John Crispin <john@phrozen.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Price <steven.price@arm.com>
To: linux-arm-kernel@lists.infradead.org
To: linux-ia64@vger.kernel.org
To: linux-riscv@lists.infradead.org
To: linux-kernel@vger.kernel.org
---
 arch/Kconfig       | 4 ++++
 arch/arm/Kconfig   | 1 +
 arch/arm64/Kconfig | 1 +
 arch/ia64/Kconfig  | 1 +
 arch/riscv/Kconfig | 1 +
 kernel/cpu.c       | 3 +++
 6 files changed, 11 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index f330410da63a..be447537d0f6 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -14,6 +14,10 @@ menu "General architecture-dependent options"
 config CRASH_CORE
 	bool
 
+config SHUTDOWN_NONBOOT_CPUS
+	select KEXEC_CORE
+	bool
+
 config KEXEC_CORE
 	select CRASH_CORE
 	bool
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 87badeae3181..711cfdb4f9f4 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -129,6 +129,7 @@ config ARM
 	select PCI_SYSCALL if PCI
 	select PERF_USE_VMALLOC
 	select RTC_LIB
+	select SHUTDOWN_NONBOOT_CPUS
 	select SYS_SUPPORTS_APM_EMULATION
 	select THREAD_INFO_IN_TASK
 	select HAVE_ARCH_VMAP_STACK if MMU && ARM_HAS_GROUP_RELOCS
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 571cc234d0b3..8c481a0b1829 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -223,6 +223,7 @@ config ARM64
 	select PCI_SYSCALL if PCI
 	select POWER_RESET
 	select POWER_SUPPLY
+	select SHUTDOWN_NONBOOT_CPUS
 	select SPARSE_IRQ
 	select SWIOTLB
 	select SYSCTL_EXCEPTION_TRACE
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 26ac8ea15a9e..8a3ddea97d1b 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -52,6 +52,7 @@ config IA64
 	select ARCH_CLOCKSOURCE_DATA
 	select GENERIC_TIME_VSYSCALL
 	select LEGACY_TIMER_TICK
+	select SHUTDOWN_NONBOOT_CPUS
 	select SWIOTLB
 	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index ed66c31e4655..02606a48c5ea 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -120,6 +120,7 @@ config RISCV
 	select PCI_MSI if PCI
 	select RISCV_INTC
 	select RISCV_TIMER if RISCV_SBI
+	select SHUTDOWN_NONBOOT_CPUS
 	select SPARSE_IRQ
 	select SYSCTL_EXCEPTION_TRACE
 	select THREAD_INFO_IN_TASK
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 338e1d426c7e..2be6ba811a01 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -1258,6 +1258,8 @@ int remove_cpu(unsigned int cpu)
 }
 EXPORT_SYMBOL_GPL(remove_cpu);
 
+#ifdef CONFIG_SHUTDOWN_NONBOOT_CPUS
+
 void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
 {
 	unsigned int cpu;
@@ -1299,6 +1301,7 @@ void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
 
 	cpu_maps_update_done();
 }
+#endif
 
 #else
 #define takedown_cpu		NULL
-- 
2.31.1

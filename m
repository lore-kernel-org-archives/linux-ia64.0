From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 12 May 2022 03:06:19 +0000
Subject: [PATCHv4 2/2] cpu/hotplug: Remove the input parameter primary_cpu of smp_shutdown_nonboot_cpus()
Message-Id: <20220512030619.13426-3-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220512030619.13426-1-kernelfans@gmail.com>
In-Reply-To: <20220512030619.13426-1-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Jens Axboe <axboe@kernel.dk>, Russell King <linux@armlinux.org.uk>, Guenter Roeck <linux@roeck-us.net>, Arnd Bergmann <arnd@arndb.de>, Wolfram Sang <wsa+renesas@sang-engineering.com>, Lee Jones <lee.jones@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Peter Collingbourne <pcc@google.com>, Marc Zyngier <maz@kernel.org>, linux-kernel@vger.kernel.org

For all call sites of smp_shutdown_nonboot_cpus(),

$git grep smp_shutdown_nonboot_cpus -- arch | grep -v \*
arch/arm/kernel/reboot.c:94:    smp_shutdown_nonboot_cpus(reboot_cpu);
arch/arm64/kernel/process.c:89: smp_shutdown_nonboot_cpus(reboot_cpu);
arch/ia64/kernel/process.c:578: smp_shutdown_nonboot_cpus(reboot_cpu);
arch/riscv/kernel/machine_kexec.c:135:  smp_shutdown_nonboot_cpus(smp_processor_id());

As it shows, the input parameter seems a little arbitrary.

Since kernel_kexec()->migrate_to_reboot_cpu() has already pinned the
rebooting thread on the selected CPU and the CPU hotplug keeps disabled
before smp_shutdown_nonboot_cpus(). Let smp_shutdown_nonboot_cpus()
deduce the rebooting CPU by smp_processor_id(), instead of passing the
parameter primary_cpu to it.

As a result, all call sites look consistent.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Jens Axboe <axboe@kernel.dk>
To: linux-ia64@vger.kernel.org
Cc: Russell King <linux@armlinux.org.uk>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Wolfram Sang <wsa+renesas@sang-engineering.com>
Cc: Lee Jones <lee.jones@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Collingbourne <pcc@google.com>
Cc: Marc Zyngier <maz@kernel.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/kernel/reboot.c          | 2 +-
 arch/arm64/kernel/process.c       | 2 +-
 arch/ia64/kernel/process.c        | 2 +-
 arch/riscv/kernel/machine_kexec.c | 2 +-
 include/linux/cpu.h               | 4 ++--
 kernel/cpu.c                      | 4 ++--
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/arm/kernel/reboot.c b/arch/arm/kernel/reboot.c
index 3044fcb8d073..98c961f0b377 100644
--- a/arch/arm/kernel/reboot.c
+++ b/arch/arm/kernel/reboot.c
@@ -91,7 +91,7 @@ void soft_restart(unsigned long addr)
  */
 void machine_shutdown(void)
 {
-	smp_shutdown_nonboot_cpus(reboot_cpu);
+	smp_shutdown_nonboot_cpus();
 }
 
 /*
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 7fa97df55e3a..1f6498d44740 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -86,7 +86,7 @@ void arch_cpu_idle_dead(void)
  */
 void machine_shutdown(void)
 {
-	smp_shutdown_nonboot_cpus(reboot_cpu);
+	smp_shutdown_nonboot_cpus();
 }
 
 /*
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index d7a256bd9d6b..9af53ff43983 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -575,7 +575,7 @@ cpu_halt (void)
 
 void machine_shutdown(void)
 {
-	smp_shutdown_nonboot_cpus(reboot_cpu);
+	smp_shutdown_nonboot_cpus();
 
 #ifdef CONFIG_KEXEC
 	kexec_disable_iosapic();
diff --git a/arch/riscv/kernel/machine_kexec.c b/arch/riscv/kernel/machine_kexec.c
index cbef0fc73afa..a30c545714cc 100644
--- a/arch/riscv/kernel/machine_kexec.c
+++ b/arch/riscv/kernel/machine_kexec.c
@@ -132,7 +132,7 @@ void machine_shutdown(void)
 	local_irq_disable();
 
 #if defined(CONFIG_HOTPLUG_CPU)
-	smp_shutdown_nonboot_cpus(smp_processor_id());
+	smp_shutdown_nonboot_cpus();
 #endif
 }
 
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 54dc2f9a2d56..0506ba3ac85e 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -127,7 +127,7 @@ extern void cpu_hotplug_enable(void);
 void clear_tasks_mm_cpumask(int cpu);
 int remove_cpu(unsigned int cpu);
 int cpu_device_down(struct device *dev);
-extern void smp_shutdown_nonboot_cpus(unsigned int primary_cpu);
+extern void smp_shutdown_nonboot_cpus(void);
 
 #else /* CONFIG_HOTPLUG_CPU */
 
@@ -140,7 +140,7 @@ static inline void lockdep_assert_cpus_held(void) { }
 static inline void cpu_hotplug_disable(void) { }
 static inline void cpu_hotplug_enable(void) { }
 static inline int remove_cpu(unsigned int cpu) { return -EPERM; }
-static inline void smp_shutdown_nonboot_cpus(unsigned int primary_cpu) { }
+static inline void smp_shutdown_nonboot_cpus(void) { }
 #endif	/* !CONFIG_HOTPLUG_CPU */
 
 #ifdef CONFIG_PM_SLEEP_SMP
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 4415370f0e91..66b8af6b8a3e 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -1228,7 +1228,7 @@ int remove_cpu(unsigned int cpu)
 }
 EXPORT_SYMBOL_GPL(remove_cpu);
 
-void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
+void smp_shutdown_nonboot_cpus(void)
 {
 	unsigned int cpu;
 	int error;
@@ -1244,7 +1244,7 @@ void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
 	__cpu_hotplug_enable();
 
 	for_each_online_cpu(cpu) {
-		if (cpu = primary_cpu)
+		if (cpu = smp_processor_id())
 			continue;
 
 		error = cpu_down_maps_locked(cpu, CPUHP_OFFLINE);
-- 
2.31.1

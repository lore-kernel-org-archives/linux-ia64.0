From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:19 +0000
Subject: [RFC PATCH 08/32] x86/topology: Switch over to GENERIC_CPU_DEVICES
Message-Id: <20230203135043.409192-9-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Now that GENERIC_CPU_DEVICES calls arch_register_cpu(), which can be
overridden by the arch code, switch over to this to allow common code
to choose when the register_cpu() call is made.

x86's struct cpus come from struct x86_cpu, which has no other members
or users. Remove this and use the version defined by common code.

This is an intermediate step to the logic being moved to drivers/acpi,
where GENERIC_CPU_DEVICES will do the work when booting with acpi=off.

Signed-off-by: James Morse <james.morse@arm.com>
---
 arch/x86/Kconfig           |  1 +
 arch/x86/include/asm/cpu.h |  4 ----
 arch/x86/kernel/topology.c | 19 +++----------------
 3 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 6a520c22c3eb..e1aaee2f8412 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -144,6 +144,7 @@ config X86
 	select GENERIC_CLOCKEVENTS_MIN_ADJUST
 	select GENERIC_CMOS_UPDATE
 	select GENERIC_CPU_AUTOPROBE
+	select GENERIC_CPU_DEVICES
 	select GENERIC_CPU_VULNERABILITIES
 	select GENERIC_EARLY_IOREMAP
 	select GENERIC_ENTRY
diff --git a/arch/x86/include/asm/cpu.h b/arch/x86/include/asm/cpu.h
index a0a62ac00e88..2955541abebb 100644
--- a/arch/x86/include/asm/cpu.h
+++ b/arch/x86/include/asm/cpu.h
@@ -23,10 +23,6 @@ static inline void prefill_possible_map(void) {}
 
 #endif /* CONFIG_SMP */
 
-struct x86_cpu {
-	struct cpu cpu;
-};
-
 #ifdef CONFIG_HOTPLUG_CPU
 extern void arch_unregister_cpu(int);
 extern void start_cpu0(void);
diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
index 1b83377274b8..2275e22dfc8b 100644
--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -35,8 +35,6 @@
 #include <asm/io_apic.h>
 #include <asm/cpu.h>
 
-static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
-
 #ifdef CONFIG_HOTPLUG_CPU
 
 #ifdef CONFIG_BOOTPARAM_HOTPLUG_CPU0
@@ -131,15 +129,15 @@ int arch_register_cpu(int num)
 		}
 	}
 	if (num || cpu0_hotpluggable)
-		per_cpu(cpu_devices, num).cpu.hotpluggable = 1;
+		per_cpu(cpu_devices, num).hotpluggable = 1;
 
-	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
+	return register_cpu(&per_cpu(cpu_devices, num), num);
 }
 EXPORT_SYMBOL(arch_register_cpu);
 
 void arch_unregister_cpu(int num)
 {
-	unregister_cpu(&per_cpu(cpu_devices, num).cpu);
+	unregister_cpu(&per_cpu(cpu_devices, num));
 }
 EXPORT_SYMBOL(arch_unregister_cpu);
 #else /* CONFIG_HOTPLUG_CPU */
@@ -149,14 +147,3 @@ static int __init arch_register_cpu(int num)
 	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
 }
 #endif /* CONFIG_HOTPLUG_CPU */
-
-static int __init topology_init(void)
-{
-	int i;
-
-	for_each_present_cpu(i)
-		arch_register_cpu(i);
-
-	return 0;
-}
-subsys_initcall(topology_init);
-- 
2.30.2

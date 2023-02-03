From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:20 +0000
Subject: [RFC PATCH 09/32] LoongArch: Switch over to GENERIC_CPU_DEVICES
Message-Id: <20230203135043.409192-10-james.morse@arm.com>
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

This allows topology_init() to be removed.

This is an intermediate step to the logic being moved to drivers/acpi,
where GENERIC_CPU_DEVICES will do the work when booting with acpi=off.

Signed-off-by: James Morse <james.morse@arm.com>
---
 arch/loongarch/Kconfig           |  1 +
 arch/loongarch/kernel/topology.c | 22 +---------------------
 2 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/arch/loongarch/Kconfig b/arch/loongarch/Kconfig
index 075aa50e5d5f..53f6feba0008 100644
--- a/arch/loongarch/Kconfig
+++ b/arch/loongarch/Kconfig
@@ -64,6 +64,7 @@ config LOONGARCH
 	select GENERIC_CLOCKEVENTS
 	select GENERIC_CMOS_UPDATE
 	select GENERIC_CPU_AUTOPROBE
+	select GENERIC_CPU_DEVICES
 	select GENERIC_ENTRY
 	select GENERIC_GETTIMEOFDAY
 	select GENERIC_IOREMAP if !ARCH_IOREMAP
diff --git a/arch/loongarch/kernel/topology.c b/arch/loongarch/kernel/topology.c
index caa7cd859078..a86d51269b09 100644
--- a/arch/loongarch/kernel/topology.c
+++ b/arch/loongarch/kernel/topology.c
@@ -7,15 +7,13 @@
 #include <linux/percpu.h>
 #include <asm/bootinfo.h>
 
-static DEFINE_PER_CPU(struct cpu, cpu_devices);
-
 #ifdef CONFIG_HOTPLUG_CPU
 int arch_register_cpu(int cpu)
 {
 	int ret;
 	struct cpu *c = &per_cpu(cpu_devices, cpu);
 
-	c->hotpluggable = 1;
+	c->hotpluggable = !io_master(cpu);
 	ret = register_cpu(c, cpu);
 	if (ret < 0)
 		pr_warn("register_cpu %d failed (%d)\n", cpu, ret);
@@ -33,21 +31,3 @@ void arch_unregister_cpu(int cpu)
 }
 EXPORT_SYMBOL(arch_unregister_cpu);
 #endif
-
-static int __init topology_init(void)
-{
-	int i, ret;
-
-	for_each_present_cpu(i) {
-		struct cpu *c = &per_cpu(cpu_devices, i);
-
-		c->hotpluggable = !io_master(i);
-		ret = register_cpu(c, i);
-		if (ret < 0)
-			pr_warn("topology_init: register_cpu %d failed (%d)\n", i, ret);
-	}
-
-	return 0;
-}
-
-subsys_initcall(topology_init);
-- 
2.30.2

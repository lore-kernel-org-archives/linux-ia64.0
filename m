From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 30 Apr 2008 07:50:55 +0000
Subject: [PATCH] ia64: fix section mismatch in arch/ia64/kernel/topology.c
Message-Id: <481824DF.5000508@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <481824BE.2000409@jp.fujitsu.com>
In-Reply-To: <481824BE.2000409@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch silences:

	WARNING: vmlinux.o(.text+0x44672): Section mismatch in
	reference from the function arch_register_cpu() to the
	function .cpuinit.text:register_cpu()

Changes are based on codes in arch/x86/kernel/topology.c

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/topology.c |   16 ++++++++++------
 include/asm-ia64/cpu.h      |    2 +-
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index abb17a6..30c5db8 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -36,9 +36,11 @@ void arch_fix_phys_package_id(int num, u32 slot)
 }
 EXPORT_SYMBOL_GPL(arch_fix_phys_package_id);
 
-int arch_register_cpu(int num)
+
+#ifdef CONFIG_HOTPLUG_CPU
+int __ref arch_register_cpu(int num)
 {
-#if defined (CONFIG_ACPI) && defined (CONFIG_HOTPLUG_CPU)
+#ifdef CONFIG_ACPI
 	/*
 	 * If CPEI can be re-targetted or if this is not
 	 * CPEI target, then it is hotpluggable
@@ -47,19 +49,21 @@ int arch_register_cpu(int num)
 		sysfs_cpus[num].cpu.hotpluggable = 1;
 	map_cpu_to_node(num, node_cpuid[num].nid);
 #endif
-
 	return register_cpu(&sysfs_cpus[num].cpu, num);
 }
-
-#ifdef CONFIG_HOTPLUG_CPU
+EXPORT_SYMBOL(arch_register_cpu);
 
 void arch_unregister_cpu(int num)
 {
 	unregister_cpu(&sysfs_cpus[num].cpu);
 	unmap_cpu_from_node(num, cpu_to_node(num));
 }
-EXPORT_SYMBOL(arch_register_cpu);
 EXPORT_SYMBOL(arch_unregister_cpu);
+#else
+static int __init arch_register_cpu(int num)
+{
+	return register_cpu(&sysfs_cpus[num].cpu, num);
+}
 #endif /*CONFIG_HOTPLUG_CPU*/
 
 
diff --git a/include/asm-ia64/cpu.h b/include/asm-ia64/cpu.h
index e87fa32..fcca30b 100644
--- a/include/asm-ia64/cpu.h
+++ b/include/asm-ia64/cpu.h
@@ -14,8 +14,8 @@ DECLARE_PER_CPU(struct ia64_cpu, cpu_devices);
 
 DECLARE_PER_CPU(int, cpu_state);
 
-extern int arch_register_cpu(int num);
 #ifdef CONFIG_HOTPLUG_CPU
+extern int arch_register_cpu(int num);
 extern void arch_unregister_cpu(int);
 #endif
 

From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 19 Jul 2015 15:05:42 +0000
Subject: [PATCH 2/3] ia64, topology: Remove bogus __ref annotations
Message-Id: <1437318343-13152-3-git-send-email-minipli@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The __cpuinit annotation was dropped from map_cpu_to_node() and
unmap_cpu_from_node() in commit ccce9bb83ed2 ("[IA64] Delete __cpuinit
usage from all ia64 users"), vanishing the need for arch_register_cpu()
and arch_unregister_cpu() to be annotated with __ref.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/ia64/kernel/topology.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index c01fe8991244..f11660071d0b 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -40,7 +40,7 @@ EXPORT_SYMBOL_GPL(arch_fix_phys_package_id);
 
 
 #ifdef CONFIG_HOTPLUG_CPU
-int __ref arch_register_cpu(int num)
+int arch_register_cpu(int num)
 {
 #ifdef CONFIG_ACPI
 	/*
@@ -55,7 +55,7 @@ int __ref arch_register_cpu(int num)
 }
 EXPORT_SYMBOL(arch_register_cpu);
 
-void __ref arch_unregister_cpu(int num)
+void arch_unregister_cpu(int num)
 {
 	unregister_cpu(&sysfs_cpus[num].cpu);
 #ifdef CONFIG_ACPI
-- 
1.7.10.4


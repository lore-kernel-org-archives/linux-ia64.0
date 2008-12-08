From: Robin Holt <holt@sgi.com>
Date: Mon, 08 Dec 2008 14:43:46 +0000
Subject: [Patch 3/4] Clear up section mismatch with arch_unregister_cpu()
Message-Id: <20081208144346.699315443@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The generic_defconfig has three section mismatches.  This clears
arch_unregister_cpu()

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>

---

 arch/ia64/kernel/topology.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)
Index: v2.6.28-rc7-20081208-218d11a/arch/ia64/kernel/topology.c
=================================--- v2.6.28-rc7-20081208-218d11a.orig/arch/ia64/kernel/topology.c	2008-12-08 08:23:35.011494686 -0600
+++ v2.6.28-rc7-20081208-218d11a/arch/ia64/kernel/topology.c	2008-12-08 08:24:25.153747021 -0600
@@ -53,10 +53,12 @@ int __ref arch_register_cpu(int num)
 }
 EXPORT_SYMBOL(arch_register_cpu);
 
-void arch_unregister_cpu(int num)
+void __ref arch_unregister_cpu(int num)
 {
 	unregister_cpu(&sysfs_cpus[num].cpu);
+#ifdef CONFIG_ACPI
 	unmap_cpu_from_node(num, cpu_to_node(num));
+#endif
 }
 EXPORT_SYMBOL(arch_unregister_cpu);
 #else


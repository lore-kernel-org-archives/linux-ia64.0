From: "Anil" <anil.s.keshavamurthy@intel.com>
Date: Thu, 10 Jun 2004 23:20:40 +0000
Subject: [PATCH] ia64_cleanup_topology_init
Message-Id: <ORSMSX409FRaqbC8wSA0000000c@orsmsx409.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	I am submitting a patch to cleanup ia64 topology_init. I will first explain how the current code is structured and what my
patch does.

In the current kernel, topology_init() is defined in arch/ia64/dig/topology.c and this file gets included if and only if CONFIG_NUMA
is _not_defined. Another version of the same function topology_init() which does exactly the same is defined under
arch/ia64/mm/numa.c and this file gets included if and only if CONFIG_NUMA is defined.
Also in numa.c register_cpu() was getting called only for online cpu's and in dig/topology.c register_cpu() was getting called for
all possible cpu's.

The attached patch combines them and moves it under arch/ia64/kernel directory. There are two reasons for doing this.
1) Allow for future expansion of the this file where in one can implement dynamic register_cpu() and register_node() for the cpu's
and node that are hot-added.
2) All sub-architecture can benefit if it is moved under ia64/kernel.

Side-effects with this patch:
With this patch register_cpu() is now called only for _online_ cpu's and not for all _possible_ cpu's as the code was doing in
arch/ia64/dig/topology.c. The reason for this is when the new cpu or node gets hot added at that time one can dynamically call these
register functions.

Please apply.

---
Patch name: ia64_cleanup_topology_init
Description: Combines the functionality of topology_init() defined in Arch/ia64/dig/topology.c and arch/ia64/mm/numa.c to
arch/ia64/kernel/topology.c
Status: Booted on tiger4 platform and compile tested for NUMA case.
---

 /dev/null                                            |   43 ------------
 arch/ia64/mm/Makefile                                |    0 
 linux-2.6.7-rc2-mm2-root/arch/ia64/dig/Makefile      |    4 -
 linux-2.6.7-rc2-mm2-root/arch/ia64/kernel/Makefile   |    3 
 linux-2.6.7-rc2-mm2-root/arch/ia64/kernel/topology.c |   66 +++++++++++++++++++
 linux-2.6.7-rc2-mm2-root/arch/ia64/mm/numa.c         |   37 ----------
 6 files changed, 68 insertions(+), 85 deletions(-)

diff -puN -L arch/ia64/dig/topology.c arch/ia64/dig/topology.c~ia64_cleanup_topology /dev/null
--- linux-2.6.7-rc2-mm2/arch/ia64/dig/topology.c
+++ /dev/null	2003-09-15 06:02:17.000000000 -0700
@@ -1,43 +0,0 @@
-/*
- * arch/ia64/dig/topology.c
- *	Popuate driverfs with topology information.
- *	Derived entirely from i386/mach-default.c
- *  Intel Corporation - Ashok Raj
- */
-#include <linux/init.h>
-#include <linux/smp.h>
-#include <linux/cpumask.h>
-#include <linux/percpu.h>
-#include <linux/notifier.h>
-#include <linux/cpu.h>
-#include <asm/cpu.h>
-
-static DEFINE_PER_CPU(struct ia64_cpu, cpu_devices);
-
-/*
- * First Pass: simply borrowed code for now. Later should hook into
- * hotplug notification for node/cpu/memory as applicable
- */
-
-static int arch_register_cpu(int num)
-{
-	struct node *parent = NULL;
-
-#ifdef CONFIG_NUMA
-	//parent = &node_devices[cpu_to_node(num)].node;
-#endif
-
-	return register_cpu(&per_cpu(cpu_devices,num).cpu, num, parent);
-}
-
-static int __init topology_init(void)
-{
-    int i;
-
-    for_each_cpu(i) {
-        arch_register_cpu(i);
-	}
-    return 0;
-}
-
-subsys_initcall(topology_init);
diff -puN arch/ia64/mm/numa.c~ia64_cleanup_topology arch/ia64/mm/numa.c
--- linux-2.6.7-rc2-mm2/arch/ia64/mm/numa.c~ia64_cleanup_topology	2004-06-10 21:05:59.000000000 -0700
+++ linux-2.6.7-rc2-mm2-root/arch/ia64/mm/numa.c	2004-06-10 21:55:29.000000000 -0700
@@ -20,9 +20,6 @@
 #include <asm/mmzone.h>
 #include <asm/numa.h>
 
-static struct node *sysfs_nodes;
-static struct cpu *sysfs_cpus;
-
 /*
  * The following structures are usually initialized by ACPI or
  * similar mechanisms and describe the NUMA characteristics of the machine.
@@ -49,37 +46,3 @@ paddr_to_nid(unsigned long paddr)
 
 	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
 }
-
-static int __init topology_init(void)
-{
-	int i, err = 0;
-
-	sysfs_nodes = kmalloc(sizeof(struct node) * numnodes, GFP_KERNEL);
-	if (!sysfs_nodes) {
-		err = -ENOMEM;
-		goto out;
-	}
-	memset(sysfs_nodes, 0, sizeof(struct node) * numnodes);
-
-	sysfs_cpus = kmalloc(sizeof(struct cpu) * NR_CPUS, GFP_KERNEL);
-	if (!sysfs_cpus) {
-		kfree(sysfs_nodes);
-		err = -ENOMEM;
-		goto out;
-	}
-	memset(sysfs_cpus, 0, sizeof(struct cpu) * NR_CPUS);
-
-	for (i = 0; i < numnodes; i++)
-		if ((err = register_node(&sysfs_nodes[i], i, 0)))
-			goto out;
-
-	for (i = 0; i < NR_CPUS; i++)
-		if (cpu_online(i))
-			if((err = register_cpu(&sysfs_cpus[i], i,
-					       &sysfs_nodes[cpu_to_node(i)])))
-				goto out;
- out:
-	return err;
-}
-
-__initcall(topology_init);
diff -puN /dev/null arch/ia64/kernel/topology.c
--- /dev/null	2003-09-15 06:02:17.000000000 -0700
+++ linux-2.6.7-rc2-mm2-root/arch/ia64/kernel/topology.c	2004-06-10 22:07:02.000000000 -0700
@@ -0,0 +1,66 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * This file contains NUMA specific variables and functions which can
+ * be split away from DISCONTIGMEM and are used on NUMA machines with
+ * contiguous memory.
+ *                        2002/08/07 Erich Focht <efocht@ess.nec.de>
+ * Popuate driverfs with topology information, Derived entirely from i386/mach-default.c
+ *  			Intel Corporation - Ashok Raj
+ */
+
+#include <linux/config.h>
+#include <linux/cpu.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/node.h>
+#include <linux/init.h>
+#include <linux/bootmem.h>
+#include <asm/mmzone.h>
+#include <asm/numa.h>
+#include <asm/cpu.h>
+
+static struct ia64_cpu *sysfs_cpus;
+
+#ifdef CONFIG_NUMA
+static struct node *sysfs_nodes;
+#define SYSFS_CPU_NODE(i)	(&sysfs_nodes[cpu_to_node(i)])
+#else
+#define SYSFS_CPU_NODE(i)	(NULL)
+#endif
+
+static int __init topology_init(void)
+{
+	int i, err = 0;
+
+#ifdef CONFIG_NUMA
+	sysfs_nodes = kmalloc(sizeof(struct node) * numnodes, GFP_KERNEL);
+	if (!sysfs_nodes) {
+		err = -ENOMEM;
+		goto out;
+	}
+	memset(sysfs_nodes, 0, sizeof(struct node) * numnodes);
+
+	for (i = 0; i < numnodes; i++)
+		if ((err = register_node(&sysfs_nodes[i], i, 0)))
+			goto out;
+#endif
+
+	sysfs_cpus = kmalloc(sizeof(struct ia64_cpu) * NR_CPUS, GFP_KERNEL);
+	if (!sysfs_cpus) {
+		err = -ENOMEM;
+		goto out;
+	}
+	memset(sysfs_cpus, 0, sizeof(struct ia64_cpu) * NR_CPUS);
+
+	for_each_online_cpu(i)
+			if((err = register_cpu(&sysfs_cpus[i].cpu, i,
+						SYSFS_CPU_NODE(i))))
+				goto out;
+ out:
+	return err;
+}
+
+__initcall(topology_init);
diff -puN arch/ia64/dig/Makefile~ia64_cleanup_topology arch/ia64/dig/Makefile
--- linux-2.6.7-rc2-mm2/arch/ia64/dig/Makefile~ia64_cleanup_topology	2004-06-10 21:53:34.000000000 -0700
+++ linux-2.6.7-rc2-mm2-root/arch/ia64/dig/Makefile	2004-06-10 21:54:08.000000000 -0700
@@ -7,8 +7,4 @@
 
 obj-y := setup.o
 
-ifndef CONFIG_NUMA
-obj-$(CONFIG_IA64_DIG) += topology.o
-endif
-
 obj-$(CONFIG_IA64_GENERIC) += machvec.o
diff -puN arch/ia64/mm/Makefile~ia64_cleanup_topology arch/ia64/mm/Makefile
diff -puN arch/ia64/kernel/Makefile~ia64_cleanup_topology arch/ia64/kernel/Makefile
--- linux-2.6.7-rc2-mm2/arch/ia64/kernel/Makefile~ia64_cleanup_topology	2004-06-10 22:01:32.000000000 -0700
+++ linux-2.6.7-rc2-mm2-root/arch/ia64/kernel/Makefile	2004-06-10 22:02:21.000000000 -0700
@@ -6,7 +6,8 @@ extra-y	:= head.o init_task.o vmlinux.ld
 
 obj-y := acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o sal.o		\
-	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o unwind.o mca.o mca_asm.o
+	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o 	\
+	 unwind.o mca.o mca_asm.o topology.o
 
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o

_


Thanks,

-Anil Keshavamurthy
Sr. Software Engineer
Linux OS Technology Team
Intel Corp.
(w) 503-712-4476


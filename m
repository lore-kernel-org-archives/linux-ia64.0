From: "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>
Date: Fri, 11 Jun 2004 00:04:29 +0000
Subject: RE: [PATCH] (take 1)ia64_cleanup_topology_init
Message-Id: <44BDAFB888F59F408FAE3CC35AB47041550E5B@orsmsx409>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Dave,
	One of our internal team member(Ashok Raj) suggested to call
register_cpu() for_each_present_cpu() instead of for_each_online_cpu().
So I changed accordingly.

And another suggestion was to use NR_NODES to allocate memory for
sysfs_nodes. So I changed accordingly.



Thanks,
Anil  

-------------------------------------------

Signed-off-by: Anil Keshavamurthy
<anil.s.keshavamurthy@intel.com@intel.com>

D: This patch moves the topology_init() function from
arch/ia64/mm/numa.c
D: to a common file. The non-numa implementation placed in arch/ia64/dig
has
D: been removed to keep the implementation generic.
D: Allocate for NR_NODES to permit future node-hotplug work.


---

 /dev/null                                        |   43 --------------
 linux-2.6.7-rc2-root/arch/ia64/dig/Makefile      |    4 -
 linux-2.6.7-rc2-root/arch/ia64/kernel/Makefile   |    3 -
 linux-2.6.7-rc2-root/arch/ia64/kernel/topology.c |   66
+++++++++++++++++++++++
 linux-2.6.7-rc2-root/arch/ia64/mm/numa.c         |   37 ------------
 5 files changed, 68 insertions(+), 85 deletions(-)

diff -puN arch/ia64/dig/Makefile~ia64_topology_clean
arch/ia64/dig/Makefile
--- linux-2.6.7-rc2/arch/ia64/dig/Makefile~ia64_topology_clean
2004-06-10 15:44:07.472869220 -0700
+++ linux-2.6.7-rc2-root/arch/ia64/dig/Makefile	2004-06-10
15:44:07.486541102 -0700
@@ -7,8 +7,4 @@
 
 obj-y := setup.o
 
-ifndef CONFIG_NUMA
-obj-$(CONFIG_IA64_DIG) += topology.o
-endif
-
 obj-$(CONFIG_IA64_GENERIC) += machvec.o
diff -puN -L arch/ia64/dig/topology.c
arch/ia64/dig/topology.c~ia64_topology_clean /dev/null
--- linux-2.6.7-rc2/arch/ia64/dig/topology.c
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
diff -puN arch/ia64/kernel/Makefile~ia64_topology_clean
arch/ia64/kernel/Makefile
--- linux-2.6.7-rc2/arch/ia64/kernel/Makefile~ia64_topology_clean
2004-06-10 15:44:07.476775472 -0700
+++ linux-2.6.7-rc2-root/arch/ia64/kernel/Makefile	2004-06-10
16:00:04.109101205 -0700
@@ -6,7 +6,8 @@ extra-y	:= head.o init_task.o vmlinux.ld
 
 obj-y := acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o
ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o
ptrace.o sal.o		\
-	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o
traps.o unaligned.o unwind.o mca.o mca_asm.o
+	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o
traps.o unaligned.o unwind.o mca.o mca_asm.o \
+	 topology.o
 
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
diff -puN /dev/null arch/ia64/kernel/topology.c
--- /dev/null	2003-09-15 06:02:17.000000000 -0700
+++ linux-2.6.7-rc2-root/arch/ia64/kernel/topology.c	2004-06-10
16:12:59.132935517 -0700
@@ -0,0 +1,66 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General
Public
+ * License.  See the file "COPYING" in the main directory of this
archive
+ * for more details.
+ *
+ * This file contains NUMA specific variables and functions which can
+ * be split away from DISCONTIGMEM and are used on NUMA machines with
+ * contiguous memory.
+ * 		2002/08/07 Erich Focht <efocht@ess.nec.de>
+ * Populate cpu entries in sysfs for non-numa systems as well
+ *  	Intel Corporation - Ashok Raj
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
+	sysfs_nodes = kmalloc(sizeof(struct node) * NR_NODES,
GFP_KERNEL);
+	if (!sysfs_nodes) {
+		err = -ENOMEM;
+		goto out;
+	}
+	memset(sysfs_nodes, 0, sizeof(struct node) * NR_NODES);
+
+	for (i = 0; i < numnodes; i++)
+		if ((err = register_node(&sysfs_nodes[i], i, 0)))
+			goto out;
+#endif
+
+	sysfs_cpus = kmalloc(sizeof(struct ia64_cpu) * NR_CPUS,
GFP_KERNEL);
+	if (!sysfs_cpus) {
+		err = -ENOMEM;
+		goto out;
+	}
+	memset(sysfs_cpus, 0, sizeof(struct ia64_cpu) * NR_CPUS);
+
+	for_each_present_cpu(i)
+			if((err = register_cpu(&sysfs_cpus[i].cpu, i,
+						SYSFS_CPU_NODE(i))))
+				goto out;
+ out:
+	return err;
+}
+
+__initcall(topology_init);
diff -puN arch/ia64/mm/numa.c~ia64_topology_clean arch/ia64/mm/numa.c
--- linux-2.6.7-rc2/arch/ia64/mm/numa.c~ia64_topology_clean
2004-06-10 15:44:07.478728598 -0700
+++ linux-2.6.7-rc2-root/arch/ia64/mm/numa.c	2004-06-10
15:44:07.485564539 -0700
@@ -20,9 +20,6 @@
 #include <asm/mmzone.h>
 #include <asm/numa.h>
 
-static struct node *sysfs_nodes;
-static struct cpu *sysfs_cpus;
-
 /*
  * The following structures are usually initialized by ACPI or
  * similar mechanisms and describe the NUMA characteristics of the
machine.
@@ -49,37 +46,3 @@ paddr_to_nid(unsigned long paddr)
 
 	return (i < num_node_memblks) ? node_memblk[i].nid :
(num_node_memblks ? -1 : 0);
 }
-
-static int __init topology_init(void)
-{
-	int i, err = 0;
-
-	sysfs_nodes = kmalloc(sizeof(struct node) * numnodes,
GFP_KERNEL);
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
-
&sysfs_nodes[cpu_to_node(i)])))
-				goto out;
- out:
-	return err;
-}
-
-__initcall(topology_init);

_
>-----Original Message-----
>From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
>Sent: Thursday, June 10, 2004 4:54 PM
>To: Keshavamurthy, Anil S
>Cc: linux-ia64@vger.kernel.org; davidm@hpl.hp.com; Andrew Morton
>Subject: Re: [PATCH] ia64_cleanup_topology_init
>
>I'm fine with the patch, but please provide a Signed-off-by 
>trail (see Documentation/SubmittingPatches).
>
>Thanks,
>
>	--david
>
>

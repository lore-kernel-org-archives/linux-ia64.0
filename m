From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 28 Apr 2004 01:02:45 +0000
Subject: Updated CPU hotplug patches for IA64 [Patch 3/7]
Message-Id: <20040427180245.D29377@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040427180033.B29377@unix-os.sc.intel.com>
In-Reply-To: <20040427180033.B29377@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Name: sysfs_ia64.patch
Author: Ashok Raj (Intel Corporation)
D: Creation of sysfs via topology_init() creates sysfs entries. The creation of
D: the online control file is created separately when the cpu_up is invoked
D: in arch independent code.
---



---

 linux-2.6.5-lhcs-root/arch/ia64/dig/Makefile   |    5 ++
 linux-2.6.5-lhcs-root/arch/ia64/dig/topology.c |   43 +++++++++++++++++++++++++
 linux-2.6.5-lhcs-root/include/asm-ia64/cpu.h   |   17 +++++++++
 3 files changed, 65 insertions(+)

diff -puN arch/ia64/dig/Makefile~sysfs_ia64 arch/ia64/dig/Makefile
--- linux-2.6.5-lhcs/arch/ia64/dig/Makefile~sysfs_ia64	2004-04-26 23:03:37.000000000 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/dig/Makefile	2004-04-27 17:43:09.534588587 -0700
@@ -6,4 +6,9 @@
 #
 
 obj-y := setup.o
+
+ifndef CONFIG_NUMA
+obj-$(CONFIG_IA64_DIG) += topology.o
+endif
+
 obj-$(CONFIG_IA64_GENERIC) += machvec.o
diff -puN /dev/null arch/ia64/dig/topology.c
--- /dev/null	2003-09-15 06:02:17.000000000 -0700
+++ linux-2.6.5-lhcs-root/arch/ia64/dig/topology.c	2004-04-26 23:03:37.000000000 -0700
@@ -0,0 +1,43 @@
+/*
+ * arch/ia64/dig/topology.c
+ *	Popuate driverfs with topology information.
+ *	Derived entirely from i386/mach-default.c
+ *  Intel Corporation - Ashok Raj
+ */
+#include <linux/init.h>
+#include <linux/smp.h>
+#include <linux/cpumask.h>
+#include <linux/percpu.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
+#include <asm/cpu.h>
+
+static DEFINE_PER_CPU(struct ia64_cpu, cpu_devices);
+
+/*
+ * First Pass: simply borrowed code for now. Later should hook into
+ * hotplug notification for node/cpu/memory as applicable
+ */
+
+static int arch_register_cpu(int num)
+{
+	struct node *parent = NULL;
+
+#ifdef CONFIG_NUMA
+	//parent = &node_devices[cpu_to_node(num)].node;
+#endif
+
+	return register_cpu(&per_cpu(cpu_devices,num).cpu, num, parent);
+}
+
+static int __init topology_init(void)
+{
+    int i;
+
+    for_each_cpu(i) {
+        arch_register_cpu(i);
+	}
+    return 0;
+}
+
+subsys_initcall(topology_init);
diff -puN /dev/null include/asm-ia64/cpu.h
--- /dev/null	2003-09-15 06:02:17.000000000 -0700
+++ linux-2.6.5-lhcs-root/include/asm-ia64/cpu.h	2004-04-26 23:03:28.000000000 -0700
@@ -0,0 +1,17 @@
+#ifndef _ASM_IA64_CPU_H_
+#define _ASM_IA64_CPU_H_
+
+#include <linux/device.h>
+#include <linux/cpu.h>
+#include <linux/topology.h>
+#include <linux/percpu.h>
+
+struct ia64_cpu {
+	struct cpu cpu;
+};
+
+DECLARE_PER_CPU(struct ia64_cpu, cpu_devices);
+
+DECLARE_PER_CPU(int, cpu_state);
+
+#endif /* _ASM_IA64_CPU_H_ */

_

From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 01:32:54 +0000
Subject: Re: r996 - in trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7: . debian
Message-Id: <200408121832.54207.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_GpBHBIZkaWM2JcP"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040810071417.GA5080@lst.de>
In-Reply-To: <20040810071417.GA5080@lst.de>
To: linux-ia64@vger.kernel.org


--Boundary-00=_GpBHBIZkaWM2JcP
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday, August 12, 2004 5:07 pm, Alex Williamson wrote:
> On Thu, 2004-08-12 at 16:30 -0700, Jesse Barnes wrote:
> > On Thursday, August 12, 2004 4:03 pm, dann frazier wrote:
> > > On Tue, Aug 10, 2004 at 09:14:17AM +0200, Christoph Hellwig wrote:
> > > > Btw, where is this patch from and why wasn't it discussed on
> > > > linux-ia64?
> > >
> > > Alex Williamson sent it to me a few patches to fix build problems on
> > > an earlier 2.6 kernel - this is one that I still need when building
> > > UP kernels w/ 2.6.7.  Here's where the builds fail (both using the
> > > attached config).
> > >
> > > If I remove this patch, it forces DISCONTIGMEM on, which doesn't build
> > > w/o SMP:
> >
> > I think you'll need CONFIG_NUMA and CONFIG_SMP for a generic kernel.
>
>    The point is to be able to provide a working UP kernel.  A generic
> kernel shouldn't be limited to SMP, and NUMA doesn't make much sense on
> a UP kernel....

Here's a patch that fixes a generic build when CONFIG_SMP is turned off.  It 
still doesn't boot on Altix though, I haven't debugged that yet.  The 
addition of a numa.c file should allow for some additional cleanups.

Jesse

--Boundary-00=_GpBHBIZkaWM2JcP
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="ia64-generic-no-smp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-generic-no-smp.patch"

diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2004-08-12 18:28:06 -07:00
+++ b/arch/ia64/kernel/Makefile	2004-08-12 18:28:06 -07:00
@@ -15,6 +15,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 
diff -Nru a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
--- a/arch/ia64/kernel/cyclone.c	2004-08-12 18:28:06 -07:00
+++ b/arch/ia64/kernel/cyclone.c	2004-08-12 18:28:06 -07:00
@@ -1,6 +1,8 @@
+#include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/time.h>
 #include <linux/errno.h>
+#include <asm/io.h>
 
 /* IBM Summit (EXA) Cyclone counter code*/
 #define CYCLONE_CBAR_ADDR 0xFEB00CD0
diff -Nru a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/kernel/numa.c	2004-08-12 18:28:06 -07:00
@@ -0,0 +1,46 @@
+#include <linux/config.h>
+#include <linux/topology.h>
+#include <linux/module.h>
+#include <asm/processor.h>
+#include <asm/smp.h>
+
+#ifdef CONFIG_NUMA
+
+/* on which node is each logical CPU (one cacheline even for 64 CPUs) */
+u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_to_node_map);
+/* which logical CPUs are on which nodes */
+cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+
+/*
+ * Build cpu to node mapping and initialize the per node cpu masks.
+ */
+void __init
+build_cpu_to_node_map (void)
+{
+	int cpu, i, node;
+
+	for(node=0; node<MAX_NUMNODES; node++)
+		cpus_clear(node_to_cpu_mask[node]);
+	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
+		/*
+		 * All Itanium NUMA platforms I know use ACPI, so maybe we
+		 * can drop this ifdef completely.                    [EF]
+		 */
+#ifdef CONFIG_ACPI_NUMA
+		node = -1;
+		for (i = 0; i < NR_CPUS; ++i)
+			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
+				node = node_cpuid[i].nid;
+				break;
+			}
+#else
+#		error Fixme: Dunno how to build CPU-to-node map.
+#endif
+		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
+		if (node >= 0)
+			cpu_set(cpu, node_to_cpu_mask[node]);
+	}
+}
+
+#endif /* CONFIG_NUMA */
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	2004-08-12 18:28:06 -07:00
+++ b/arch/ia64/kernel/smpboot.c	2004-08-12 18:28:06 -07:00
@@ -491,47 +491,6 @@
 	}
 }
 
-#ifdef CONFIG_NUMA
-
-/* on which node is each logical CPU (one cacheline even for 64 CPUs) */
-u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
-EXPORT_SYMBOL(cpu_to_node_map);
-/* which logical CPUs are on which nodes */
-cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
-
-/*
- * Build cpu to node mapping and initialize the per node cpu masks.
- */
-void __init
-build_cpu_to_node_map (void)
-{
-	int cpu, i, node;
-
-	for(node=0; node<MAX_NUMNODES; node++)
-		cpus_clear(node_to_cpu_mask[node]);
-	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
-		/*
-		 * All Itanium NUMA platforms I know use ACPI, so maybe we
-		 * can drop this ifdef completely.                    [EF]
-		 */
-#ifdef CONFIG_ACPI_NUMA
-		node = -1;
-		for (i = 0; i < NR_CPUS; ++i)
-			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
-				node = node_cpuid[i].nid;
-				break;
-			}
-#else
-#		error Fixme: Dunno how to build CPU-to-node map.
-#endif
-		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
-		if (node >= 0)
-			cpu_set(cpu, node_to_cpu_mask[node]);
-	}
-}
-
-#endif /* CONFIG_NUMA */
-
 /*
  * Cycle through the APs sending Wakeup IPIs to boot each.
  */
diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	2004-08-12 18:28:06 -07:00
+++ b/arch/ia64/mm/discontig.c	2004-08-12 18:28:06 -07:00
@@ -225,6 +225,33 @@
 }
 
 /**
+ * per_cpu_node_setup - setup per-cpu areas on each node
+ * @cpu_data: per-cpu area on this node
+ * @node: node to setup
+ *
+ * Copy the static per-cpu data into the region we just set aside and then
+ * setup __per_cpu_offset for each CPU on this node.  Return a pointer to
+ * the end of the area.
+ */
+static void *per_cpu_node_setup(void *cpu_data, int node)
+{
+#ifdef CONFIG_SMP
+	int cpu;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		if (node == node_cpuid[cpu].nid) {
+			memcpy(__va(cpu_data), __phys_per_cpu_start,
+			       __per_cpu_end - __per_cpu_start);
+			__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
+				__per_cpu_start;
+			cpu_data += PERCPU_PAGE_SIZE;
+		}
+	}
+#endif
+	return cpu_data;
+}
+
+/**
  * find_pernode_space - allocate memory for memory map and per-node structures
  * @start: physical start of range
  * @len: length of range
@@ -255,7 +282,7 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus;
+	unsigned long epfn, cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
 	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
@@ -305,20 +332,7 @@
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
-		/*
-		 * Copy the static per-cpu data into the region we
-		 * just set aside and then setup __per_cpu_offset
-		 * for each CPU on this node.
-		 */
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			if (node == node_cpuid[cpu].nid) {
-				memcpy(__va(cpu_data), __phys_per_cpu_start,
-				       __per_cpu_end - __per_cpu_start);
-				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
-					__per_cpu_start;
-				cpu_data += PERCPU_PAGE_SIZE;
-			}
-		}
+		cpu_data = per_cpu_node_setup(cpu_data, node);
 	}
 
 	return 0;
@@ -464,6 +478,7 @@
 	find_initrd();
 }
 
+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
@@ -483,6 +498,7 @@
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#endif /* CONFIG_SMP */
 
 /**
  * show_mem - give short summary of memory stats
diff -Nru a/drivers/serial/sn_console.c b/drivers/serial/sn_console.c
--- a/drivers/serial/sn_console.c	2004-08-12 18:28:06 -07:00
+++ b/drivers/serial/sn_console.c	2004-08-12 18:28:06 -07:00
@@ -50,6 +50,7 @@
 #include <linux/miscdevice.h>
 #include <linux/serial_core.h>
 
+#include <asm/io.h>
 #include <asm/sn/simulator.h>
 #include <asm/sn/sn2/sn_private.h>
 #include <asm/sn/sn_sal.h>
@@ -1085,7 +1086,9 @@
 			spin_unlock_irqrestore(&port->sc_port.lock, flags);
 
 			puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
+#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 		}
+#endif
 	}
 	else {
 		/* Not yet registered with serial core - simple case */
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	2004-08-12 18:28:06 -07:00
+++ b/include/asm-ia64/smp.h	2004-08-12 18:28:06 -07:00
@@ -126,6 +126,7 @@
 #else
 
 #define cpu_logical_id(cpuid)		0
+#define cpu_physical_id(i)	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
diff -Nru a/include/asm-ia64/sn/sn_cpuid.h b/include/asm-ia64/sn/sn_cpuid.h
--- a/include/asm-ia64/sn/sn_cpuid.h	2004-08-12 18:28:06 -07:00
+++ b/include/asm-ia64/sn/sn_cpuid.h	2004-08-12 18:28:06 -07:00
@@ -83,10 +83,6 @@
  *
  */
 
-#ifndef CONFIG_SMP
-#define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
-#endif
-
 /*
  * macros for some of these exist in sn/addrs.h & sn/arch.h, etc. However, 
  * trying #include these files here causes circular dependencies.

--Boundary-00=_GpBHBIZkaWM2JcP--

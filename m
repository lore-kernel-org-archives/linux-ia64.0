From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 16 Jan 2004 21:47:08 +0000
Subject: [PATCH] kill some more warnings
Message-Id: <20040116214708.GA16350@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kills a warning and a false sense of safety by removing the volatile
qualifier on cpu_to_node_map[] and node_to_cpu_mask[].  Also fix the
printk for total processors since num_online_cpus() can return an int or
a long depending on the value of NR_CPUS.

Jesse

=== arch/ia64/kernel/smpboot.c 1.43 vs edited ==--- 1.43/arch/ia64/kernel/smpboot.c	Tue Jan 13 21:24:55 2004
+++ edited/arch/ia64/kernel/smpboot.c	Fri Jan 16 12:23:48 2004
@@ -467,10 +467,10 @@
 #ifdef CONFIG_NUMA
 
 /* on which node is each logical CPU (one cacheline even for 64 CPUs) */
-volatile u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 EXPORT_SYMBOL(cpu_to_node_map);
 /* which logical CPUs are on which nodes */
-volatile cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
 /*
  * Build cpu to node mapping and initialize the per node cpu masks.
@@ -566,8 +566,8 @@
 		if (cpu_online(cpu))
 			bogosum += cpu_data(cpu)->loops_per_jiffy;
 
-	printk(KERN_INFO "Total of %lu processors activated (%lu.%02lu BogoMIPS).\n",
-	       num_online_cpus(), bogosum/(500000/HZ), (bogosum/(5000/HZ))%100);
+	printk(KERN_INFO "Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
+	       (int)num_online_cpus(), bogosum/(500000/HZ), (bogosum/(5000/HZ))%100);
 }
 
 int __devinit
=== include/asm-ia64/numa.h 1.13 vs edited ==--- 1.13/include/asm-ia64/numa.h	Sun Jan 11 22:56:51 2004
+++ edited/include/asm-ia64/numa.h	Fri Jan 16 12:20:26 2004
@@ -23,8 +23,8 @@
 
 #include <asm/mmzone.h>
 
-extern volatile u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
-extern volatile cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+extern u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
 /* Stuff below this line could be architecture independent */
 

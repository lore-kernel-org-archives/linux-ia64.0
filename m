From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 09 Sep 2003 18:21:02 +0000
Subject: [PATCH] cpumask_t fixes
Message-Id: <marc-linux-ia64-106313195909965@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch coverts a few spots to use cpumask_t instead of unsigned
long.

Thanks,
Jesse


diff -Nru a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c	Tue Sep  9 11:19:45 2003
+++ b/arch/ia64/kernel/mca.c	Tue Sep  9 11:19:45 2003
@@ -1193,7 +1193,7 @@
 ia64_mca_cmc_poll (unsigned long dummy)
 {
 	/* Trigger a CMC interrupt cascade  */
-	platform_send_ipi(__ffs(cpu_online_map), IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(first_cpu(cpu_online_map), IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
 /*
@@ -1260,7 +1260,7 @@
 ia64_mca_cpe_poll (unsigned long dummy)
 {
 	/* Trigger a CPE interrupt cascade  */
-	platform_send_ipi(__ffs(cpu_online_map), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(first_cpu(cpu_online_map), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
 /*
diff -Nru a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c	Tue Sep  9 11:19:45 2003
+++ b/arch/ia64/kernel/time.c	Tue Sep  9 11:19:45 2003
@@ -187,7 +187,7 @@
 ia64_do_profile (struct pt_regs * regs)
 {
 	unsigned long ip, slot;
-	extern unsigned long prof_cpu_mask;
+	extern cpumask_t prof_cpu_mask;
 
 	profile_hook(regs);
 
diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
--- a/include/asm-ia64/numa.h	Tue Sep  9 11:19:45 2003
+++ b/include/asm-ia64/numa.h	Tue Sep  9 11:19:45 2003
@@ -23,7 +23,7 @@
 
 #include <linux/cache.h>
 extern volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
-extern volatile unsigned long node_to_cpu_mask[NR_NODES] __cacheline_aligned;
+extern volatile cpumask_t node_to_cpu_mask[NR_NODES] __cacheline_aligned;
 
 /* Stuff below this line could be architecture independent */
 
diff -Nru a/include/asm-ia64/sn/nodepda.h b/include/asm-ia64/sn/nodepda.h
--- a/include/asm-ia64/sn/nodepda.h	Tue Sep  9 11:19:45 2003
+++ b/include/asm-ia64/sn/nodepda.h	Tue Sep  9 11:19:45 2003
@@ -128,7 +128,7 @@
  * Check if given a compact node id the corresponding node has all the
  * cpus disabled. 
  */
-#define is_headless_node(cnode)		(!node_to_cpumask(cnode))
+#define is_headless_node(cnode)		(!any_online_cpu(node_to_cpumask(cnode)))
 
 /*
  * Check if given a node vertex handle the corresponding node has all the

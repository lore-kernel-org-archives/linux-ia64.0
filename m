From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 15 Jan 2005 07:21:58 +0000
Subject: [patch] eliminate two compiler warnings
Message-Id: <16872.50326.736554.584145@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below eliminates two compiler warnings.  The first one
(domain.c) showed when compiling for non-NUMA.  In that case, variable
"node" ended up not being used, which solicits a warning from GCC.
Fix is to evluate cpu_to_node(i) in place.  This has the effect of
doing cpu_to_node(i) twice on NUMA, but this is init code, so
performance is not an issue (and even if it were, you can just declare
cpu_to_node() as being a pure function, so the compiler can eliminate
the second call).

The second warning was due to somebody calling a "const" pointer to
__find_next_zero_bit, but that function didn't declare the pointer as
const.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/domain.c 1.8 vs edited ==--- 1.8/arch/ia64/kernel/domain.c	2005-01-10 17:29:23 -08:00
+++ edited/arch/ia64/kernel/domain.c	2005-01-14 22:19:50 -08:00
@@ -151,10 +151,9 @@
 	 * Set up domains. Isolated domains just stay on the dummy domain.
 	 */
 	for_each_cpu_mask(i, cpu_default_map) {
-		int node = cpu_to_node(i);
 		int group;
 		struct sched_domain *sd = NULL, *p;
-		cpumask_t nodemask = node_to_cpumask(node);
+		cpumask_t nodemask = node_to_cpumask(cpu_to_node(i));
 
 		cpus_and(nodemask, nodemask, cpu_default_map);
 
@@ -172,7 +171,7 @@
 
 		sd = &per_cpu(node_domains, i);
 		*sd = SD_NODE_INIT;
-		sd->span = sched_domain_node_span(node);
+		sd->span = sched_domain_node_span(cpu_to_node(i));
 		sd->parent = p;
 		cpus_and(sd->span, sd->span, cpu_default_map);
 #endif
=== arch/ia64/lib/bitop.c 1.2 vs edited ==--- 1.2/arch/ia64/lib/bitop.c	2004-10-20 01:37:14 -07:00
+++ edited/arch/ia64/lib/bitop.c	2005-01-14 22:07:50 -08:00
@@ -8,7 +8,8 @@
  * Find next zero bit in a bitmap reasonably efficiently..
  */
 
-int __find_next_zero_bit (void *addr, unsigned long size, unsigned long offset)
+int __find_next_zero_bit (const void *addr, unsigned long size,
+			  unsigned long offset)
 {
 	unsigned long *p = ((unsigned long *) addr) + (offset >> 6);
 	unsigned long result = offset & ~63UL;
=== include/asm-ia64/bitops.h 1.17 vs edited ==--- 1.17/include/asm-ia64/bitops.h	2004-06-04 09:10:31 -07:00
+++ edited/include/asm-ia64/bitops.h	2005-01-14 22:07:17 -08:00
@@ -359,7 +359,7 @@
 
 #endif /* __KERNEL__ */
 
-extern int __find_next_zero_bit (void *addr, unsigned long size,
+extern int __find_next_zero_bit (const void *addr, unsigned long size,
 			unsigned long offset);
 extern int __find_next_bit(const void *addr, unsigned long size,
 			unsigned long offset);

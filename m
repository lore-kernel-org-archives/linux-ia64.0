From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:41 +0000
Subject: [PATCH 22/35] cpumask: cpumask_first/cpumask_next
Message-Id: <20081020170322.646161000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Pointer-taking variants of first_cpu/next_cpu.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |   18 +++++++++---------
 lib/cpumask.c           |   10 +++++-----
 2 files changed, 14 insertions(+), 14 deletions(-)

--- test-compile.orig/include/linux/cpumask.h
+++ test-compile/include/linux/cpumask.h
@@ -46,8 +46,8 @@
  * void cpumask_shift_right(dst, src, n) Shift right
  * void cpumask_shift_left(dst, src, n)	Shift left
  *
- * int first_cpu(mask)			Number lowest set bit or nr_cpumask_bits
- * int next_cpu(cpu, mask)		Next cpu past 'cpu', or nr_cpumask_bits
+ * int cpumask_first(mask)		Number lowest set bit or nr_cpumask_bits
+ * int cpumask_next(cpu, mask)		Next cpu past 'cpu', or nr_cpumask_bits
  *
  * void cpumask_copy(dmask, smask)	dmask = smask
  *
@@ -200,6 +200,8 @@ extern cpumask_t _unused_cpumask_arg_;
 #define for_each_cpu_mask(cpu, mask)	for_each_cpu(cpu, &(mask))
 #define for_each_cpu_mask_and(cpu, mask, and)	\
 		for_each_cpu_and(cpu, &(mask), &(and))
+#define first_cpu(src)		cpumask_first(&(src))
+#define next_cpu(n, src)	cpumask_next((n), &(src))
 /* End deprecated region. */
 
 static inline void cpumask_set_cpu(int cpu, volatile struct cpumask *dstp)
@@ -448,8 +450,8 @@ extern cpumask_t cpu_mask_all;
 
 #if NR_CPUS = 1
 
-#define first_cpu(src)			({ (void)(src); 0; })
-#define next_cpu(n, src)		({ (void)(src); 1; })
+#define cpumask_first(src)		({ (void)(src); 0; })
+#define cpumask_next(n, src)		({ (void)(src); 1; })
 #define cpumask_next_and(n, srcp, andp)	({ (void)(srcp), (void)(andp); 1; })
 #define any_online_cpu(mask)		0
 
@@ -460,18 +462,16 @@ extern cpumask_t cpu_mask_all;
 
 #else /* NR_CPUS > 1 */
 
-int __first_cpu(const cpumask_t *srcp);
-int __next_cpu(int n, const cpumask_t *srcp);
+int cpumask_first(const cpumask_t *srcp);
+int cpumask_next(int n, const cpumask_t *srcp);
 int cpumask_next_and(int n, const cpumask_t *srcp, const cpumask_t *andp);
 int __any_online_cpu(const cpumask_t *mask);
 
-#define first_cpu(src)		__first_cpu(&(src))
-#define next_cpu(n, src)	__next_cpu((n), &(src))
 #define any_online_cpu(mask) __any_online_cpu(&(mask))
 
 #define for_each_cpu(cpu, mask)				\
 	for ((cpu) = -1;				\
-		(cpu) = __next_cpu((cpu), (mask)),	\
+		(cpu) = cpumask_next((cpu), (mask)),	\
 		(cpu) < nr_cpumask_bits;)
 #define for_each_cpu_and(cpu, mask, and)			\
 	for ((cpu) = -1;					\
--- test-compile.orig/lib/cpumask.c
+++ test-compile/lib/cpumask.c
@@ -3,21 +3,21 @@
 #include <linux/cpumask.h>
 #include <linux/module.h>
 
-int __first_cpu(const cpumask_t *srcp)
+int cpumask_first(const cpumask_t *srcp)
 {
 	return find_first_bit(cpumask_bits(srcp), nr_cpumask_bits);
 }
-EXPORT_SYMBOL(__first_cpu);
+EXPORT_SYMBOL(cpumask_first);
 
-int __next_cpu(int n, const cpumask_t *srcp)
+int cpumask_next(int n, const cpumask_t *srcp)
 {
 	return find_next_bit(cpumask_bits(srcp), nr_cpumask_bits, n+1);
 }
-EXPORT_SYMBOL(__next_cpu);
+EXPORT_SYMBOL(cpumask_next);
 
 int cpumask_next_and(int n, const cpumask_t *srcp, const cpumask_t *andp)
 {
-	while ((n = next_cpu(n, *srcp)) < nr_cpumask_bits)
+	while ((n = cpumask_next(n, srcp)) < nr_cpu_ids)
 		if (cpumask_test_cpu(n, andp))
 			break;
 	return n;

-- 

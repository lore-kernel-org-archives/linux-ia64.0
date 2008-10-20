From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:37 +0000
Subject: [PATCH 18/35] cpumask: add nr_cpumask_bits
Message-Id: <20081020170322.090531000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

When nr_cpu_ids is set to CONFIG_NR_CPUS then references to nr_cpu_ids
will return the maximum index of the configured NR_CPUS (+1) instead
of the maximum index of the possible number of cpus (+1).  This results
in extra unused memory being allocated by functions that are setting up
arrays of structs to keep track of per cpu items.

Since we do want to keep the ability to use constants for the cpu bit
operators on smaller systems (which are generally much faster assembler
ops), we introduce a separate "nr_cpumask_bits" to replace "nr_cpu_ids"
only for the inline assembly ops.  This will be a constant when
CONFIG_CPUMASK_OFFSTACK is undefined and a variable when it is defined.

Thus "nr_cpu_ids" reverts back to being a variable representing the
maximum possible cpu (+1), except in the non-SMP case where it is a
constant value of 1.  The relationship between the related variables
and constants is: (1 <= nr_cpu_ids <= nr_cpumask_bits <= NR_CPUS).

Signed-of-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/setup_percpu.c |    7 +--
 include/linux/cpumask.h        |   94 +++++++++++++++++++++++------------------
 init/main.c                    |   17 +++----
 lib/cpumask.c                  |    8 +--
 4 files changed, 72 insertions(+), 54 deletions(-)

--- test-compile.orig/arch/x86/kernel/setup_percpu.c
+++ test-compile/arch/x86/kernel/setup_percpu.c
@@ -155,6 +155,10 @@ void __init setup_per_cpu_areas(void)
 	printk(KERN_INFO "PERCPU: Allocating %zd bytes of per cpu data\n",
 			  size);
 
+	printk(KERN_DEBUG
+		"NR_CPUS:%d nr_cpumask_bits:%d nr_cpu_ids:%d nr_node_ids:%d\n",
+		NR_CPUS, nr_cpumask_bits, nr_cpu_ids, nr_node_ids);
+
 	for_each_possible_cpu(cpu) {
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 		ptr = __alloc_bootmem(size, align,
@@ -183,9 +187,6 @@ void __init setup_per_cpu_areas(void)
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 	}
 
-	printk(KERN_DEBUG "NR_CPUS: %d, nr_cpu_ids: %d, nr_node_ids %d\n",
-		NR_CPUS, nr_cpu_ids, nr_node_ids);
-
 	/* Setup percpu data maps */
 	setup_per_cpu_maps();
 
--- test-compile.orig/include/linux/cpumask.h
+++ test-compile/include/linux/cpumask.h
@@ -4,7 +4,7 @@
 /*
  * Cpumasks provide a bitmap suitable for representing the
  * set of CPU's in a system, one bit position per CPU number up to
- * nr_cpu_ids (<= NR_CPUS).
+ * nr_cpumask_bits (<= NR_CPUS).
  *
  * Old-style uses "cpumask_t", but new ops are "struct cpumask *";
  * don't put "struct cpumask"s on the stack.
@@ -46,8 +46,8 @@
  * void cpumask_shift_right(dst, src, n) Shift right
  * void cpumask_shift_left(dst, src, n)	Shift left
  *
- * int first_cpu(mask)			Number lowest set bit, or nr_cpu_ids
- * int next_cpu(cpu, mask)		Next cpu past 'cpu', or nr_cpu_ids
+ * int first_cpu(mask)			Number lowest set bit or nr_cpumask_bits
+ * int next_cpu(cpu, mask)		Next cpu past 'cpu', or nr_cpumask_bits
  *
  * void cpumask_copy(dmask, smask)	dmask = smask
  *
@@ -98,7 +98,8 @@
  * void cpumask_onto(dst, orig, relmap)	*dst = orig relative to relmap
  * void cpumask_fold(dst, orig, sz)	dst bits = orig bits mod sz
  *
- * for_each_cpu_mask(cpu, mask)		for-loop cpu over mask using nr_cpu_ids
+ * for_each_cpu_mask(cpu, mask)		for-loop cpu over mask
+ *						using nr_cpumask_bits
  * for_each_cpu_mask_and(cpu, mask, and) for-loop cpu over (mask & and).
  *
  * int num_online_cpus()		Number of online CPUs
@@ -136,11 +137,34 @@ struct cpumask
 };
 #define cpumask_bits(maskp) ((maskp)->bits)
 
+/*
+ * nr_cpu_ids: max cpu index (+1)
+ * nr_cpumask_bits: number of bits in a struct cpumask
+ * 1 <= nr_cpu_ids <= nr_cpumask_bits <= NR_CPUS
+ *
+ * Use CONFIG_CPUMASK_OFFSTACK to force variable length struct cpumask
+ */
+#if NR_CPUS = 1
+#define nr_cpumask_bits NR_CPUS
+#define nr_cpu_ids NR_CPUS
+#else
+
+#ifdef CONFIG_CPUMASK_OFFSTACK
+extern int nr_cpumask_bits;
+extern int nr_cpu_ids;
+#else
+
+#define nr_cpumask_bits NR_CPUS
+extern int nr_cpu_ids;
+#endif
+#endif
+
 static inline ssize_t cpumask_size(void)
 {
-	return BITS_TO_LONGS(nr_cpu_ids) * sizeof(long);
+	return BITS_TO_LONGS(nr_cpumask_bits) * sizeof(long);
 }
 
+
 /* Deprecated. */
 typedef struct cpumask cpumask_t;
 extern cpumask_t _unused_cpumask_arg_;
@@ -182,14 +206,6 @@ extern cpumask_t _unused_cpumask_arg_;
 #define for_each_cpu_mask_nr(cpu, mask)	for_each_cpu_mask(cpu, mask)
 /* End deprecated region. */
 
-#if NR_CPUS <= BITS_PER_LONG
-/* Constant is usually more efficient than a variable for small NR_CPUS */
-#define nr_cpu_ids NR_CPUS
-#else
-/* Starts at NR_CPUS until we know better. */
-extern int nr_cpu_ids;
-#endif /* NR_CPUS > BITS_PER_LONG */
-
 static inline void cpumask_set_cpu(int cpu, volatile struct cpumask *dstp)
 {
 	set_bit(cpu, dstp->bits);
@@ -210,73 +226,73 @@ static inline int cpumask_test_and_set_c
 
 static inline void cpumask_setall(struct cpumask *dstp)
 {
-	bitmap_fill(dstp->bits, nr_cpu_ids);
+	bitmap_fill(dstp->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_clear(struct cpumask *dstp)
 {
-	bitmap_zero(dstp->bits, nr_cpu_ids);
+	bitmap_zero(dstp->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_and(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
-	bitmap_and(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
+	bitmap_and(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_or(struct cpumask *dstp, const struct cpumask *src1p,
 			      const struct cpumask *src2p)
 {
-	bitmap_or(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
+	bitmap_or(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_xor(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
-	bitmap_xor(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
+	bitmap_xor(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_andnot(struct cpumask *dstp,
 				  const struct cpumask *src1p,
 				  const struct cpumask *src2p)
 {
-	bitmap_andnot(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
+	bitmap_andnot(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_complement(struct cpumask *dstp,
 				      const struct cpumask *srcp)
 {
-	bitmap_complement(dstp->bits, srcp->bits, nr_cpu_ids);
+	bitmap_complement(dstp->bits, srcp->bits, nr_cpumask_bits);
 }
 
 static inline int cpumask_equal(const struct cpumask *src1p,
 				const struct cpumask *src2p)
 {
-	return bitmap_equal(src1p->bits, src2p->bits, nr_cpu_ids);
+	return bitmap_equal(src1p->bits, src2p->bits, nr_cpumask_bits);
 }
 
 static inline int cpumask_intersects(const struct cpumask *src1p,
 				     const struct cpumask *src2p)
 {
-	return bitmap_intersects(src1p->bits, src2p->bits, nr_cpu_ids);
+	return bitmap_intersects(src1p->bits, src2p->bits, nr_cpumask_bits);
 }
 
 static inline int cpumask_subset(const struct cpumask *src1p,
 				 const struct cpumask *src2p)
 {
-	return bitmap_subset(src1p->bits, src2p->bits, nr_cpu_ids);
+	return bitmap_subset(src1p->bits, src2p->bits, nr_cpumask_bits);
 }
 
 static inline int cpumask_empty(const struct cpumask *srcp)
 {
-	return bitmap_empty(srcp->bits, nr_cpu_ids);
+	return bitmap_empty(srcp->bits, nr_cpumask_bits);
 }
 
 static inline int cpumask_full(const struct cpumask *srcp)
 {
-	return bitmap_full(srcp->bits, nr_cpu_ids);
+	return bitmap_full(srcp->bits, nr_cpumask_bits);
 }
 
 static inline int __cpus_weight(const cpumask_t *srcp, int nbits)
@@ -286,49 +302,49 @@ static inline int __cpus_weight(const cp
 
 static inline int cpumask_weight(const struct cpumask *srcp)
 {
-	return bitmap_weight(srcp->bits, nr_cpu_ids);
+	return bitmap_weight(srcp->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_shift_right(struct cpumask *dstp,
 				       const struct cpumask *srcp, int n)
 {
-	bitmap_shift_right(dstp->bits, srcp->bits, n, nr_cpu_ids);
+	bitmap_shift_right(dstp->bits, srcp->bits, n, nr_cpumask_bits);
 }
 
 static inline void cpumask_shift_left(struct cpumask *dstp,
 				      const struct cpumask *srcp, int n)
 {
-	bitmap_shift_left(dstp->bits, srcp->bits, n, nr_cpu_ids);
+	bitmap_shift_left(dstp->bits, srcp->bits, n, nr_cpumask_bits);
 }
 
 static inline int cpumask_scnprintf(char *buf, int len,
 				    const struct cpumask *srcp)
 {
-	return bitmap_scnprintf(buf, len, srcp->bits, nr_cpu_ids);
+	return bitmap_scnprintf(buf, len, srcp->bits, nr_cpumask_bits);
 }
 
 static inline int cpumask_parse_user(const char __user *buf, int len,
 				     struct cpumask *dstp)
 {
-	return bitmap_parse_user(buf, len, dstp->bits, nr_cpu_ids);
+	return bitmap_parse_user(buf, len, dstp->bits, nr_cpumask_bits);
 }
 
 static inline int cpulist_scnprintf(char *buf, int len,
 				    const struct cpumask *srcp)
 {
-	return bitmap_scnlistprintf(buf, len, srcp->bits, nr_cpu_ids);
+	return bitmap_scnlistprintf(buf, len, srcp->bits, nr_cpumask_bits);
 }
 
 static inline int cpulist_parse(const char *buf, struct cpumask *dstp)
 {
-	return bitmap_parselist(buf, dstp->bits, nr_cpu_ids);
+	return bitmap_parselist(buf, dstp->bits, nr_cpumask_bits);
 }
 
 static inline int cpumask_cpuremap(int oldbit,
 				   const struct cpumask *oldp,
 				   const struct cpumask *newp)
 {
-	return bitmap_bitremap(oldbit, oldp->bits, newp->bits, nr_cpu_ids);
+	return bitmap_bitremap(oldbit, oldp->bits, newp->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_remap(struct cpumask *dstp,
@@ -337,26 +353,26 @@ static inline void cpumask_remap(struct 
 				 const struct cpumask *newp)
 {
 	bitmap_remap(dstp->bits, srcp->bits, oldp->bits, newp->bits,
-		     nr_cpu_ids);
+		     nr_cpumask_bits);
 }
 
 static inline void cpumask_onto(struct cpumask *dstp,
 				const struct cpumask *origp,
 				const struct cpumask *relmapp)
 {
-	bitmap_onto(dstp->bits, origp->bits, relmapp->bits, nr_cpu_ids);
+	bitmap_onto(dstp->bits, origp->bits, relmapp->bits, nr_cpumask_bits);
 }
 
 static inline void cpumask_fold(struct cpumask *dstp,
 				const struct cpumask *origp, int sz)
 {
-	bitmap_fold(dstp->bits, origp->bits, sz, nr_cpu_ids);
+	bitmap_fold(dstp->bits, origp->bits, sz, nr_cpumask_bits);
 }
 
 static inline void cpumask_copy(struct cpumask *dstp,
 				const struct cpumask *srcp)
 {
-	bitmap_copy(cpumask_bits(dstp), cpumask_bits(srcp), nr_cpu_ids);
+	bitmap_copy(cpumask_bits(dstp), cpumask_bits(srcp), nr_cpumask_bits);
 }
 
 /*
@@ -454,11 +470,11 @@ int __any_online_cpu(const cpumask_t *ma
 #define for_each_cpu_mask(cpu, mask)			\
 	for ((cpu) = -1;				\
 		(cpu) = next_cpu((cpu), (mask)),	\
-		(cpu) < nr_cpu_ids;)
+		(cpu) < nr_cpumask_bits;)
 #define for_each_cpu_mask_and(cpu, mask, and)				\
 	for ((cpu) = -1;						\
 		(cpu) = cpumask_next_and((cpu), &(mask), &(and)),	\
-		(cpu) < nr_cpu_ids;)
+		(cpu) < nr_cpumask_bits;)
 #endif
 
 #define cpumask_first_and(mask, and) cpumask_next_and(-1, (mask), (and))
--- test-compile.orig/init/main.c
+++ test-compile/init/main.c
@@ -373,10 +373,13 @@ EXPORT_SYMBOL(cpu_mask_all);
 #endif
 
 /* Setup number of possible processor ids */
-/* nr_cpu_ids is a real variable for large NR_CPUS. */
-#ifndef nr_cpu_ids
+/* nr_cpumask_bits is a real variable for large NR_CPUS. */
+#ifndef nr_cpumask_bits
+int nr_cpumask_bits __read_mostly = NR_CPUS;
+EXPORT_SYMBOL(nr_cpumask_bits);
+#endif
+
 int nr_cpu_ids __read_mostly = NR_CPUS;
-EXPORT_SYMBOL(nr_cpu_ids);
 
 /* An arch may set nr_cpu_ids earlier if needed, so this would be redundant */
 void __init setup_nr_cpu_ids(void)
@@ -387,12 +390,10 @@ void __init setup_nr_cpu_ids(void)
 		highest_cpu = cpu;
 
 	nr_cpu_ids = highest_cpu + 1;
+#ifndef nr_cpumask_bits
+	nr_cpumask_bits = highest_cpu + 1;
+#endif
 }
-#else
-void __init setup_nr_cpu_ids(void)
-{
-}
-#endif /* ... nr_cpu_ids is a constant. */
 
 #ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
--- test-compile.orig/lib/cpumask.c
+++ test-compile/lib/cpumask.c
@@ -5,19 +5,19 @@
 
 int __first_cpu(const cpumask_t *srcp)
 {
-	return find_first_bit(srcp->bits, nr_cpu_ids);
+	return find_first_bit(srcp->bits, nr_cpumask_bits);
 }
 EXPORT_SYMBOL(__first_cpu);
 
 int __next_cpu(int n, const cpumask_t *srcp)
 {
-	return find_next_bit(srcp->bits, nr_cpu_ids, n+1);
+	return find_next_bit(srcp->bits, nr_cpumask_bits, n+1);
 }
 EXPORT_SYMBOL(__next_cpu);
 
 int cpumask_next_and(int n, const cpumask_t *srcp, const cpumask_t *andp)
 {
-	while ((n = next_cpu(n, *srcp)) < nr_cpu_ids)
+	while ((n = next_cpu(n, *srcp)) < nr_cpumask_bits)
 		if (cpumask_test_cpu(n, andp))
 			break;
 	return n;
@@ -41,7 +41,7 @@ EXPORT_SYMBOL(__any_online_cpu);
 bool alloc_cpumask_var(cpumask_var_t *mask, gfp_t flags)
 {
 	if (likely(slab_is_available()))
-		*mask = kmalloc(BITS_TO_LONGS(nr_cpu_ids)*sizeof(long), flags);
+		*mask = kmalloc(cpumask_size(), flags);
 	else {
 #ifdef CONFIG_DEBUG_PER_CPU_MAPS
 		printk(KERN_ERR

-- 

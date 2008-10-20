From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:36 +0000
Subject: [PATCH 17/35] cpumask: make nr_cpu_ids the actual limit on bitmap size
Message-Id: <20081020170321.952382000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

nr_cpu_ids is the (badly named) runtime limit on possible CPU numbers;
ie. the variable version of NR_CPUS.

If we use this in *all* the cpu ops it simplifies the API, and will
be possible to allocate cpumasks of the minimal length at runtime.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h  |  110 +++++++++++++++++------------------------------
 include/linux/seq_file.h |    2
 include/linux/cpumask.h  |  114 ++++++++++++++++-------------------------------
 include/linux/seq_file.h |    2 
 lib/cpumask.c            |   14 +----
 3 files changed, 45 insertions(+), 85 deletions(-)

--- test-compile.orig/include/linux/cpumask.h
+++ test-compile/include/linux/cpumask.h
@@ -3,7 +3,8 @@
 
 /*
  * Cpumasks provide a bitmap suitable for representing the
- * set of CPU's in a system, one bit position per CPU number.
+ * set of CPU's in a system, one bit position per CPU number up to
+ * nr_cpu_ids (<= NR_CPUS).
  *
  * Old-style uses "cpumask_t", but new ops are "struct cpumask *";
  * don't put "struct cpumask"s on the stack.
@@ -20,20 +21,6 @@
  * For details of cpumask_onto(), see bitmap_onto in lib/bitmap.c.
  * For details of cpumask_fold(), see bitmap_fold in lib/bitmap.c.
  *
- * . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
- * Note: The alternate operations with the suffix "_nr" are used
- *       to limit the range of the loop to nr_cpu_ids instead of
- *       NR_CPUS when NR_CPUS > 64 for performance reasons.
- *       If NR_CPUS is <= 64 then most assembler bitmask
- *       operators execute faster with a constant range, so
- *       the operator will continue to use NR_CPUS.
- *
- *       Another consideration is that nr_cpu_ids is initialized
- *       to NR_CPUS and isn't lowered until the possible cpus are
- *       discovered (including any disabled cpus).  So early uses
- *       will span the entire range of NR_CPUS.
- * . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
- *
  * The available cpumask operations are:
  *
  * void cpumask_set_cpu(cpu, mask)	turn on bit 'cpu' in mask
@@ -55,14 +42,12 @@
  * int cpumask_empty(mask)		Is mask empty (no bits sets)?
  * int cpumask_full(mask)		Is mask full (all bits sets)?
  * int cpumask_weight(mask)		Hamming weigh - number of set bits
- * int cpumask_weight_nr(mask)		Same using nr_cpu_ids instead of NR_CPUS
  *
  * void cpumask_shift_right(dst, src, n) Shift right
  * void cpumask_shift_left(dst, src, n)	Shift left
  *
- * int first_cpu(mask)			Number lowest set bit, or NR_CPUS
- * int next_cpu(cpu, mask)		Next cpu past 'cpu', or NR_CPUS
- * int next_cpu_nr(cpu, mask)		Next cpu past 'cpu', or nr_cpu_ids
+ * int first_cpu(mask)			Number lowest set bit, or nr_cpu_ids
+ * int next_cpu(cpu, mask)		Next cpu past 'cpu', or nr_cpu_ids
  *
  * void cpumask_copy(dmask, smask)	dmask = smask
  *
@@ -113,8 +98,7 @@
  * void cpumask_onto(dst, orig, relmap)	*dst = orig relative to relmap
  * void cpumask_fold(dst, orig, sz)	dst bits = orig bits mod sz
  *
- * for_each_cpu_mask(cpu, mask)		for-loop cpu over mask using NR_CPUS
- * for_each_cpu_mask_nr(cpu, mask)	for-loop cpu over mask using nr_cpu_ids
+ * for_each_cpu_mask(cpu, mask)		for-loop cpu over mask using nr_cpu_ids
  * for_each_cpu_mask_and(cpu, mask, and) for-loop cpu over (mask & and).
  *
  * int num_online_cpus()		Number of online CPUs
@@ -154,7 +138,7 @@ struct cpumask
 
 static inline ssize_t cpumask_size(void)
 {
-	return BITS_TO_LONGS(NR_CPUS) * sizeof(long);
+	return BITS_TO_LONGS(nr_cpu_ids) * sizeof(long);
 }
 
 /* Deprecated. */
@@ -193,6 +177,9 @@ extern cpumask_t _unused_cpumask_arg_;
 #define cpus_fold(dst, orig, sz) \
 		cpumask_fold(&(dst), &(orig), sz)
 #define cpus_addr(src) ((src).bits)
+#define next_cpu_nr(n, src)		next_cpu(n, src)
+#define cpus_weight_nr(cpumask)		cpus_weight(cpumask)
+#define for_each_cpu_mask_nr(cpu, mask)	for_each_cpu_mask(cpu, mask)
 /* End deprecated region. */
 
 #if NR_CPUS <= BITS_PER_LONG
@@ -223,73 +210,73 @@ static inline int cpumask_test_and_set_c
 
 static inline void cpumask_setall(struct cpumask *dstp)
 {
-	bitmap_fill(dstp->bits, NR_CPUS);
+	bitmap_fill(dstp->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_clear(struct cpumask *dstp)
 {
-	bitmap_zero(dstp->bits, NR_CPUS);
+	bitmap_zero(dstp->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_and(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
-	bitmap_and(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
+	bitmap_and(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_or(struct cpumask *dstp, const struct cpumask *src1p,
 			      const struct cpumask *src2p)
 {
-	bitmap_or(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
+	bitmap_or(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_xor(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
-	bitmap_xor(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
+	bitmap_xor(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_andnot(struct cpumask *dstp,
 				  const struct cpumask *src1p,
 				  const struct cpumask *src2p)
 {
-	bitmap_andnot(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
+	bitmap_andnot(dstp->bits, src1p->bits, src2p->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_complement(struct cpumask *dstp,
 				      const struct cpumask *srcp)
 {
-	bitmap_complement(dstp->bits, srcp->bits, NR_CPUS);
+	bitmap_complement(dstp->bits, srcp->bits, nr_cpu_ids);
 }
 
 static inline int cpumask_equal(const struct cpumask *src1p,
 				const struct cpumask *src2p)
 {
-	return bitmap_equal(src1p->bits, src2p->bits, NR_CPUS);
+	return bitmap_equal(src1p->bits, src2p->bits, nr_cpu_ids);
 }
 
 static inline int cpumask_intersects(const struct cpumask *src1p,
 				     const struct cpumask *src2p)
 {
-	return bitmap_intersects(src1p->bits, src2p->bits, NR_CPUS);
+	return bitmap_intersects(src1p->bits, src2p->bits, nr_cpu_ids);
 }
 
 static inline int cpumask_subset(const struct cpumask *src1p,
 				 const struct cpumask *src2p)
 {
-	return bitmap_subset(src1p->bits, src2p->bits, NR_CPUS);
+	return bitmap_subset(src1p->bits, src2p->bits, nr_cpu_ids);
 }
 
 static inline int cpumask_empty(const struct cpumask *srcp)
 {
-	return bitmap_empty(srcp->bits, NR_CPUS);
+	return bitmap_empty(srcp->bits, nr_cpu_ids);
 }
 
 static inline int cpumask_full(const struct cpumask *srcp)
 {
-	return bitmap_full(srcp->bits, NR_CPUS);
+	return bitmap_full(srcp->bits, nr_cpu_ids);
 }
 
 static inline int __cpus_weight(const cpumask_t *srcp, int nbits)
@@ -299,49 +286,49 @@ static inline int __cpus_weight(const cp
 
 static inline int cpumask_weight(const struct cpumask *srcp)
 {
-	return bitmap_weight(srcp->bits, NR_CPUS);
+	return bitmap_weight(srcp->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_shift_right(struct cpumask *dstp,
 				       const struct cpumask *srcp, int n)
 {
-	bitmap_shift_right(dstp->bits, srcp->bits, n, NR_CPUS);
+	bitmap_shift_right(dstp->bits, srcp->bits, n, nr_cpu_ids);
 }
 
 static inline void cpumask_shift_left(struct cpumask *dstp,
 				      const struct cpumask *srcp, int n)
 {
-	bitmap_shift_left(dstp->bits, srcp->bits, n, NR_CPUS);
+	bitmap_shift_left(dstp->bits, srcp->bits, n, nr_cpu_ids);
 }
 
 static inline int cpumask_scnprintf(char *buf, int len,
 				    const struct cpumask *srcp)
 {
-	return bitmap_scnprintf(buf, len, srcp->bits, NR_CPUS);
+	return bitmap_scnprintf(buf, len, srcp->bits, nr_cpu_ids);
 }
 
 static inline int cpumask_parse_user(const char __user *buf, int len,
 				     struct cpumask *dstp)
 {
-	return bitmap_parse_user(buf, len, dstp->bits, NR_CPUS);
+	return bitmap_parse_user(buf, len, dstp->bits, nr_cpu_ids);
 }
 
 static inline int cpulist_scnprintf(char *buf, int len,
 				    const struct cpumask *srcp)
 {
-	return bitmap_scnlistprintf(buf, len, srcp->bits, NR_CPUS);
+	return bitmap_scnlistprintf(buf, len, srcp->bits, nr_cpu_ids);
 }
 
 static inline int cpulist_parse(const char *buf, struct cpumask *dstp)
 {
-	return bitmap_parselist(buf, dstp->bits, NR_CPUS);
+	return bitmap_parselist(buf, dstp->bits, nr_cpu_ids);
 }
 
 static inline int cpumask_cpuremap(int oldbit,
 				   const struct cpumask *oldp,
 				   const struct cpumask *newp)
 {
-	return bitmap_bitremap(oldbit, oldp->bits, newp->bits, NR_CPUS);
+	return bitmap_bitremap(oldbit, oldp->bits, newp->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_remap(struct cpumask *dstp,
@@ -349,26 +336,27 @@ static inline void cpumask_remap(struct 
 				 const struct cpumask *oldp,
 				 const struct cpumask *newp)
 {
-	bitmap_remap(dstp->bits, srcp->bits, oldp->bits, newp->bits, NR_CPUS);
+	bitmap_remap(dstp->bits, srcp->bits, oldp->bits, newp->bits,
+		     nr_cpu_ids);
 }
 
 static inline void cpumask_onto(struct cpumask *dstp,
 				const struct cpumask *origp,
 				const struct cpumask *relmapp)
 {
-	bitmap_onto(dstp->bits, origp->bits, relmapp->bits, NR_CPUS);
+	bitmap_onto(dstp->bits, origp->bits, relmapp->bits, nr_cpu_ids);
 }
 
 static inline void cpumask_fold(struct cpumask *dstp,
 				const struct cpumask *origp, int sz)
 {
-	bitmap_fold(dstp->bits, origp->bits, sz, NR_CPUS);
+	bitmap_fold(dstp->bits, origp->bits, sz, nr_cpu_ids);
 }
 
 static inline void cpumask_copy(struct cpumask *dstp,
 				const struct cpumask *srcp)
 {
-	bitmap_copy(cpumask_bits(dstp), cpumask_bits(srcp), NR_CPUS);
+	bitmap_copy(cpumask_bits(dstp), cpumask_bits(srcp), nr_cpu_ids);
 }
 
 /*
@@ -465,7 +453,7 @@ int __any_online_cpu(const cpumask_t *ma
 #define for_each_cpu_mask(cpu, mask)			\
 	for ((cpu) = -1;				\
 		(cpu) = next_cpu((cpu), (mask)),	\
-		(cpu) < NR_CPUS;)
+		(cpu) < nr_cpu_ids;)
 #define for_each_cpu_mask_and(cpu, mask, and)				\
 	for ((cpu) = -1;						\
 		(cpu) = cpumask_next_and((cpu), &(mask), &(and)),	\
@@ -474,26 +462,6 @@ int __any_online_cpu(const cpumask_t *ma
 
 #define cpumask_first_and(mask, and) cpumask_next_and(-1, (mask), (and))
 
-#if NR_CPUS <= 64
-
-#define next_cpu_nr(n, src)		next_cpu(n, src)
-#define cpus_weight_nr(cpumask)		cpus_weight(cpumask)
-#define for_each_cpu_mask_nr(cpu, mask)	for_each_cpu_mask(cpu, mask)
-
-#else /* NR_CPUS > 64 */
-
-int __next_cpu_nr(int n, const cpumask_t *srcp);
-
-#define next_cpu_nr(n, src)		__next_cpu_nr((n), &(src))
-#define cpus_weight_nr(cpumask)		__cpus_weight(&(cpumask), nr_cpu_ids)
-
-#define for_each_cpu_mask_nr(cpu, mask)			\
-	for ((cpu) = -1;				\
-		(cpu) = next_cpu_nr((cpu), (mask)),	\
-		(cpu) < nr_cpu_ids;)
-
-#endif /* NR_CPUS > 64 */
-
 /*
  * cpumask_var_t: struct cpumask for stack usage.
  *
@@ -593,9 +561,9 @@ extern cpumask_t cpu_present_map;
 extern cpumask_t cpu_active_map;
 
 #if NR_CPUS > 1
-#define num_online_cpus()	cpus_weight_nr(cpu_online_map)
-#define num_possible_cpus()	cpus_weight_nr(cpu_possible_map)
-#define num_present_cpus()	cpus_weight_nr(cpu_present_map)
+#define num_online_cpus()	cpus_weight(cpu_online_map)
+#define num_possible_cpus()	cpus_weight(cpu_possible_map)
+#define num_present_cpus()	cpus_weight(cpu_present_map)
 #define cpu_online(cpu)		cpu_isset((cpu), cpu_online_map)
 #define cpu_possible(cpu)	cpu_isset((cpu), cpu_possible_map)
 #define cpu_present(cpu)	cpu_isset((cpu), cpu_present_map)
@@ -612,9 +580,9 @@ extern cpumask_t cpu_active_map;
 
 #define cpu_is_offline(cpu)	unlikely(!cpu_online(cpu))
 
-#define for_each_possible_cpu(cpu) for_each_cpu_mask_nr((cpu), cpu_possible_map)
-#define for_each_online_cpu(cpu)   for_each_cpu_mask_nr((cpu), cpu_online_map)
-#define for_each_present_cpu(cpu)  for_each_cpu_mask_nr((cpu), cpu_present_map)
+#define for_each_possible_cpu(cpu) for_each_cpu_mask((cpu), cpu_possible_map)
+#define for_each_online_cpu(cpu)   for_each_cpu_mask((cpu), cpu_online_map)
+#define for_each_present_cpu(cpu)  for_each_cpu_mask((cpu), cpu_present_map)
 
 /* Arch-specific code may call this to initialize nr_cpu_ids based on
  * the cpu_possible_map. */
--- test-compile.orig/include/linux/seq_file.h
+++ test-compile/include/linux/seq_file.h
@@ -52,7 +52,7 @@ int seq_path_root(struct seq_file *m, st
 int seq_bitmap(struct seq_file *m, unsigned long *bits, unsigned int nr_bits);
 static inline int seq_cpumask(struct seq_file *m, cpumask_t *mask)
 {
-	return seq_bitmap(m, mask->bits, NR_CPUS);
+	return seq_bitmap(m, mask->bits, nr_cpu_ids);
 }
 
 static inline int seq_nodemask(struct seq_file *m, nodemask_t *mask)
--- test-compile.orig/lib/cpumask.c
+++ test-compile/lib/cpumask.c
@@ -5,33 +5,25 @@
 
 int __first_cpu(const cpumask_t *srcp)
 {
-	return find_first_bit(srcp->bits, NR_CPUS);
+	return find_first_bit(srcp->bits, nr_cpu_ids);
 }
 EXPORT_SYMBOL(__first_cpu);
 
 int __next_cpu(int n, const cpumask_t *srcp)
 {
-	return find_next_bit(srcp->bits, NR_CPUS, n+1);
+	return find_next_bit(srcp->bits, nr_cpu_ids, n+1);
 }
 EXPORT_SYMBOL(__next_cpu);
 
 int cpumask_next_and(int n, const cpumask_t *srcp, const cpumask_t *andp)
 {
-	while ((n = next_cpu_nr(n, *srcp)) < nr_cpu_ids)
+	while ((n = next_cpu(n, *srcp)) < nr_cpu_ids)
 		if (cpumask_test_cpu(n, andp))
 			break;
 	return n;
 }
 EXPORT_SYMBOL(cpumask_next_and);
 
-#if NR_CPUS > 64
-int __next_cpu_nr(int n, const cpumask_t *srcp)
-{
-	return find_next_bit(srcp->bits, nr_cpu_ids, n+1);
-}
-EXPORT_SYMBOL(__next_cpu_nr);
-#endif
-
 int __any_online_cpu(const cpumask_t *mask)
 {
 	int cpu;

-- 

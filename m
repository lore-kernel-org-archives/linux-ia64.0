From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:25 +0000
Subject: [PATCH 06/35] cpumask: introduce struct cpumask.
Message-Id: <20081020170320.427003000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

We want to move cpumasks off the stack: no local decls, no passing by
copy.  We also don't want to allow assignment of them, so we can later
partially allocate them (ie. not all NR_CPUS bits).

Unfortunately, all the cpus_* functions are written perversely to take
cpumask_t not cpumask_t *; although they are in fact wrapper macros.
This sets a bad example.  Also, we want to eventually make cpumasks an
undefined struct, so we can catch on-stack usage with a compile error.

So we create a 'struct cpumask', typedef cpumask_t to it during the
transition, and cleanup all the cpumask operators to be normal
functions (cpus_ -> cpumask_).  Note that two functions already use
variants of the new names: they are fixed in the next patch.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |  357 +++++++++++++++++++++++++-----------------------
 lib/cpumask.c           |    2 
 2 files changed, 192 insertions(+), 167 deletions(-)

--- linux-2.6.28.orig/include/linux/cpumask.h
+++ linux-2.6.28/include/linux/cpumask.h
@@ -5,17 +5,20 @@
  * Cpumasks provide a bitmap suitable for representing the
  * set of CPU's in a system, one bit position per CPU number.
  *
+ * Old-style uses "cpumask_t", but new ops are "struct cpumask *";
+ * don't put "struct cpumask"s on the stack.
+ *
  * See detailed comments in the file linux/bitmap.h describing the
  * data type on which these cpumasks are based.
  *
  * For details of cpumask_scnprintf() and cpumask_parse_user(),
- * see bitmap_scnprintf() and bitmap_parse_user() in lib/bitmap.c.
- * For details of cpulist_scnprintf() and cpulist_parse(), see
- * bitmap_scnlistprintf() and bitmap_parselist(), also in bitmap.c.
- * For details of cpu_remap(), see bitmap_bitremap in lib/bitmap.c
- * For details of cpus_remap(), see bitmap_remap in lib/bitmap.c.
- * For details of cpus_onto(), see bitmap_onto in lib/bitmap.c.
- * For details of cpus_fold(), see bitmap_fold in lib/bitmap.c.
+ *     see bitmap_scnprintf() and bitmap_parse_user() in lib/bitmap.c.
+ * For details of cpulist_scnprintf() and cpulist_parse(),
+ *     see bitmap_scnlistprintf() and bitmap_parselist(), in lib/bitmap.c.
+ * For details of cpumask_cpuremap(), see bitmap_bitremap in lib/bitmap.c
+ * For details of cpumask_remap(), see bitmap_remap in lib/bitmap.c.
+ * For details of cpumask_onto(), see bitmap_onto in lib/bitmap.c.
+ * For details of cpumask_fold(), see bitmap_fold in lib/bitmap.c.
  *
  * . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
  * Note: The alternate operations with the suffix "_nr" are used
@@ -33,29 +36,29 @@
  *
  * The available cpumask operations are:
  *
- * void cpu_set(cpu, mask)		turn on bit 'cpu' in mask
- * void cpu_clear(cpu, mask)		turn off bit 'cpu' in mask
- * void cpus_setall(mask)		set all bits
- * void cpus_clear(mask)		clear all bits
- * int cpu_isset(cpu, mask)		true iff bit 'cpu' set in mask
- * int cpu_test_and_set(cpu, mask)	test and set bit 'cpu' in mask
- *
- * void cpus_and(dst, src1, src2)	dst = src1 & src2  [intersection]
- * void cpus_or(dst, src1, src2)	dst = src1 | src2  [union]
- * void cpus_xor(dst, src1, src2)	dst = src1 ^ src2
- * void cpus_andnot(dst, src1, src2)	dst = src1 & ~src2
- * void cpus_complement(dst, src)	dst = ~src
- *
- * int cpus_equal(mask1, mask2)		Does mask1 = mask2?
- * int cpus_intersects(mask1, mask2)	Do mask1 and mask2 intersect?
- * int cpus_subset(mask1, mask2)	Is mask1 a subset of mask2?
- * int cpus_empty(mask)			Is mask empty (no bits sets)?
- * int cpus_full(mask)			Is mask full (all bits sets)?
- * int cpus_weight(mask)		Hamming weigh - number of set bits
- * int cpus_weight_nr(mask)		Same using nr_cpu_ids instead of NR_CPUS
+ * void cpumask_set_cpu(cpu, mask)	turn on bit 'cpu' in mask
+ * void cpumask_clear_cpu(cpu, mask)	turn off bit 'cpu' in mask
+ * int cpumask_test_and_set_cpu(cpu, mask) test and set bit 'cpu' in mask
+ * int cpumask_test_cpu(cpu, mask)	true iff bit 'cpu' set in mask
+ * void cpumask_setall(mask)		set all bits
+ * void cpumask_clear(mask)		clear all bits
+ *
+ * void cpumask_and(dst, src1, src2)	dst = src1 & src2  [intersection]
+ * void cpumask_or(dst, src1, src2)	dst = src1 | src2  [union]
+ * void cpumask_xor(dst, src1, src2)	dst = src1 ^ src2
+ * void cpumask_andnot(dst, src1, src2)	dst = src1 & ~src2
+ * void cpumask_complement(dst, src)	dst = ~src
+ *
+ * int cpumask_equal(mask1, mask2)	Does mask1 = mask2?
+ * int cpumask_intersects(mask1, mask2)	Do mask1 and mask2 intersect?
+ * int cpumask_subset(mask1, mask2)	Is mask1 a subset of mask2?
+ * int cpumask_empty(mask)		Is mask empty (no bits sets)?
+ * int cpumask_full(mask)		Is mask full (all bits sets)?
+ * int cpumask_weight(mask)		Hamming weigh - number of set bits
+ * int cpumask_weight_nr(mask)		Same using nr_cpu_ids instead of NR_CPUS
  *
- * void cpus_shift_right(dst, src, n)	Shift right
- * void cpus_shift_left(dst, src, n)	Shift left
+ * void cpumask_shift_right(dst, src, n) Shift right
+ * void cpumask_shift_left(dst, src, n)	Shift left
  *
  * int first_cpu(mask)			Number lowest set bit, or NR_CPUS
  * int next_cpu(cpu, mask)		Next cpu past 'cpu', or NR_CPUS
@@ -65,7 +68,7 @@
  *					(can be used as an lvalue)
  * CPU_MASK_ALL				Initializer - all bits set
  * CPU_MASK_NONE			Initializer - no bits set
- * unsigned long *cpus_addr(mask)	Array of unsigned long's in mask
+ * unsigned long *cpumask_bits(mask)	Array of unsigned long's in mask
  *
  * CPUMASK_ALLOC kmalloc's a structure that is a composite of many cpumask_t
  * variables, and CPUMASK_PTR provides pointers to each field.
@@ -100,12 +103,12 @@
  *
  * int cpumask_scnprintf(buf, len, mask) Format cpumask for printing
  * int cpumask_parse_user(ubuf, ulen, mask)	Parse ascii string as cpumask
- * int cpulist_scnprintf(buf, len, mask) Format cpumask as list for printing
- * int cpulist_parse(buf, map)		Parse ascii string as cpulist
+ * int cpumask_scnprintf(buf, len, mask) Format cpumask as list for printing
+ * int cpumask_parse(buf, map)		Parse ascii string as cpumask
  * int cpu_remap(oldbit, old, new)	newbit = map(old, new)(oldbit)
- * void cpus_remap(dst, src, old, new)	*dst = map(old, new)(src)
- * void cpus_onto(dst, orig, relmap)	*dst = orig relative to relmap
- * void cpus_fold(dst, orig, sz)	dst bits = orig bits mod sz
+ * void cpumask_remap(dst, src, old, new)	*dst = map(old, new)(src)
+ * void cpumask_onto(dst, orig, relmap)	*dst = orig relative to relmap
+ * void cpumask_fold(dst, orig, sz)	dst bits = orig bits mod sz
  *
  * for_each_cpu_mask(cpu, mask)		for-loop cpu over mask using NR_CPUS
  * for_each_cpu_mask_nr(cpu, mask)	for-loop cpu over mask using nr_cpu_ids
@@ -139,131 +142,217 @@
 #include <linux/threads.h>
 #include <linux/bitmap.h>
 
-typedef struct { DECLARE_BITMAP(bits, NR_CPUS); } cpumask_t;
+struct cpumask
+{
+	DECLARE_BITMAP(bits, NR_CPUS);
+};
+#define cpumask_bits(maskp) ((maskp)->bits)
+
+/* Deprecated. */
+typedef struct cpumask cpumask_t;
 extern cpumask_t _unused_cpumask_arg_;
 
-#define cpu_set(cpu, dst) __cpu_set((cpu), &(dst))
-static inline void __cpu_set(int cpu, volatile cpumask_t *dstp)
+#define cpu_set(cpu, dst) cpumask_set_cpu((cpu), &(dst))
+#define cpu_clear(cpu, dst) cpumask_clear_cpu((cpu), &(dst))
+#define cpu_test_and_set(cpu, mask) cpumask_test_and_set_cpu((cpu), &(mask))
+/* No static inline type checking - see Subtlety (1) above. */
+#define cpu_isset(cpu, cpumask) test_bit((cpu), (cpumask).bits)
+#define cpus_setall(dst) cpumask_setall(&(dst))
+#define cpus_clear(dst) cpumask_clear(&(dst))
+#define cpus_and(dst, src1, src2) cpumask_and(&(dst), &(src1), &(src2))
+#define cpus_or(dst, src1, src2) cpumask_or(&(dst), &(src1), &(src2))
+#define cpus_xor(dst, src1, src2) cpumask_xor(&(dst), &(src1), &(src2))
+#define cpus_andnot(dst, src1, src2) \
+				cpumask_andnot(&(dst), &(src1), &(src2))
+#define cpus_complement(dst, src) cpumask_complement(&(dst), &(src))
+#define cpus_equal(src1, src2) cpumask_equal(&(src1), &(src2))
+#define cpus_intersects(src1, src2) cpumask_intersects(&(src1), &(src2))
+#define cpus_subset(src1, src2) cpumask_subset(&(src1), &(src2))
+#define cpus_empty(src) cpumask_empty(&(src))
+#define cpus_full(cpumask) cpumask_full(&(cpumask))
+#define cpus_weight(cpumask) cpumask_weight(&(cpumask))
+#define cpus_shift_right(dst, src, n) \
+			cpumask_shift_right(&(dst), &(src), (n))
+#define cpus_shift_left(dst, src, n) \
+			cpumask_shift_left(&(dst), &(src), (n))
+#define cpumask_scnprintf(buf, len, src) \
+			__cpumask_scnprintf((buf), (len), &(src))
+#define cpumask_parse_user(ubuf, ulen, dst) \
+			__cpumask_parse_user((ubuf), (ulen), &(dst))
+#define cpulist_scnprintf(buf, len, src) \
+			__cpulist_scnprintf((buf), (len), &(src))
+#define cpulist_parse(buf, dst) __cpulist_parse((buf), &(dst))
+#define cpu_remap(oldbit, old, new) \
+		cpumask_cpuremap((oldbit), &(old), &(new))
+#define cpus_remap(dst, src, old, new) \
+		cpumask_remap(&(dst), &(src), &(old), &(new))
+#define cpus_onto(dst, orig, relmap) \
+		cpumask_onto(&(dst), &(orig), &(relmap))
+#define cpus_fold(dst, orig, sz) \
+		cpumask_fold(&(dst), &(orig), sz)
+#define cpus_addr(src) ((src).bits)
+/* End deprecated region. */
+
+static inline void cpumask_set_cpu(int cpu, volatile struct cpumask *dstp)
 {
 	set_bit(cpu, dstp->bits);
 }
 
-#define cpu_clear(cpu, dst) __cpu_clear((cpu), &(dst))
-static inline void __cpu_clear(int cpu, volatile cpumask_t *dstp)
+static inline void cpumask_clear_cpu(int cpu, volatile struct cpumask *dstp)
 {
 	clear_bit(cpu, dstp->bits);
 }
 
-#define cpus_setall(dst) __cpus_setall(&(dst), NR_CPUS)
-static inline void __cpus_setall(cpumask_t *dstp, int nbits)
+/* No static inline type checking - see Subtlety (1) above. */
+#define cpumask_test_cpu(cpu, cpumask) test_bit((cpu), (cpumask)->bits)
+
+static inline int cpumask_test_and_set_cpu(int cpu, struct cpumask *addr)
 {
-	bitmap_fill(dstp->bits, nbits);
+	return test_and_set_bit(cpu, addr->bits);
 }
 
-#define cpus_clear(dst) __cpus_clear(&(dst), NR_CPUS)
-static inline void __cpus_clear(cpumask_t *dstp, int nbits)
+static inline void cpumask_setall(struct cpumask *dstp)
 {
-	bitmap_zero(dstp->bits, nbits);
+	bitmap_fill(dstp->bits, NR_CPUS);
 }
 
-/* No static inline type checking - see Subtlety (1) above. */
-#define cpu_isset(cpu, cpumask) test_bit((cpu), (cpumask).bits)
-
-#define cpu_test_and_set(cpu, cpumask) __cpu_test_and_set((cpu), &(cpumask))
-static inline int __cpu_test_and_set(int cpu, cpumask_t *addr)
+static inline void cpumask_clear(struct cpumask *dstp)
 {
-	return test_and_set_bit(cpu, addr->bits);
+	bitmap_zero(dstp->bits, NR_CPUS);
 }
 
-#define cpus_and(dst, src1, src2) __cpus_and(&(dst), &(src1), &(src2), NR_CPUS)
-static inline void __cpus_and(cpumask_t *dstp, const cpumask_t *src1p,
-					const cpumask_t *src2p, int nbits)
+static inline void cpumask_and(struct cpumask *dstp,
+			       const struct cpumask *src1p,
+			       const struct cpumask *src2p)
 {
-	bitmap_and(dstp->bits, src1p->bits, src2p->bits, nbits);
+	bitmap_and(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
 }
 
-#define cpus_or(dst, src1, src2) __cpus_or(&(dst), &(src1), &(src2), NR_CPUS)
-static inline void __cpus_or(cpumask_t *dstp, const cpumask_t *src1p,
-					const cpumask_t *src2p, int nbits)
+static inline void cpumask_or(struct cpumask *dstp, const struct cpumask *src1p,
+			      const struct cpumask *src2p)
 {
-	bitmap_or(dstp->bits, src1p->bits, src2p->bits, nbits);
+	bitmap_or(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
 }
 
-#define cpus_xor(dst, src1, src2) __cpus_xor(&(dst), &(src1), &(src2), NR_CPUS)
-static inline void __cpus_xor(cpumask_t *dstp, const cpumask_t *src1p,
-					const cpumask_t *src2p, int nbits)
+static inline void cpumask_xor(struct cpumask *dstp,
+			       const struct cpumask *src1p,
+			       const struct cpumask *src2p)
 {
-	bitmap_xor(dstp->bits, src1p->bits, src2p->bits, nbits);
+	bitmap_xor(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
 }
 
-#define cpus_andnot(dst, src1, src2) \
-				__cpus_andnot(&(dst), &(src1), &(src2), NR_CPUS)
-static inline void __cpus_andnot(cpumask_t *dstp, const cpumask_t *src1p,
-					const cpumask_t *src2p, int nbits)
+static inline void cpumask_andnot(struct cpumask *dstp,
+				  const struct cpumask *src1p,
+				  const struct cpumask *src2p)
 {
-	bitmap_andnot(dstp->bits, src1p->bits, src2p->bits, nbits);
+	bitmap_andnot(dstp->bits, src1p->bits, src2p->bits, NR_CPUS);
 }
 
-#define cpus_complement(dst, src) __cpus_complement(&(dst), &(src), NR_CPUS)
-static inline void __cpus_complement(cpumask_t *dstp,
-					const cpumask_t *srcp, int nbits)
+static inline void cpumask_complement(struct cpumask *dstp,
+				      const struct cpumask *srcp)
 {
-	bitmap_complement(dstp->bits, srcp->bits, nbits);
+	bitmap_complement(dstp->bits, srcp->bits, NR_CPUS);
 }
 
-#define cpus_equal(src1, src2) __cpus_equal(&(src1), &(src2), NR_CPUS)
-static inline int __cpus_equal(const cpumask_t *src1p,
-					const cpumask_t *src2p, int nbits)
+static inline int cpumask_equal(const struct cpumask *src1p,
+				const struct cpumask *src2p)
 {
-	return bitmap_equal(src1p->bits, src2p->bits, nbits);
+	return bitmap_equal(src1p->bits, src2p->bits, NR_CPUS);
 }
 
-#define cpus_intersects(src1, src2) __cpus_intersects(&(src1), &(src2), NR_CPUS)
-static inline int __cpus_intersects(const cpumask_t *src1p,
-					const cpumask_t *src2p, int nbits)
+static inline int cpumask_intersects(const struct cpumask *src1p,
+				     const struct cpumask *src2p)
 {
-	return bitmap_intersects(src1p->bits, src2p->bits, nbits);
+	return bitmap_intersects(src1p->bits, src2p->bits, NR_CPUS);
 }
 
-#define cpus_subset(src1, src2) __cpus_subset(&(src1), &(src2), NR_CPUS)
-static inline int __cpus_subset(const cpumask_t *src1p,
-					const cpumask_t *src2p, int nbits)
+static inline int cpumask_subset(const struct cpumask *src1p,
+				 const struct cpumask *src2p)
 {
-	return bitmap_subset(src1p->bits, src2p->bits, nbits);
+	return bitmap_subset(src1p->bits, src2p->bits, NR_CPUS);
 }
 
-#define cpus_empty(src) __cpus_empty(&(src), NR_CPUS)
-static inline int __cpus_empty(const cpumask_t *srcp, int nbits)
+static inline int cpumask_empty(const struct cpumask *srcp)
 {
-	return bitmap_empty(srcp->bits, nbits);
+	return bitmap_empty(srcp->bits, NR_CPUS);
 }
 
-#define cpus_full(cpumask) __cpus_full(&(cpumask), NR_CPUS)
-static inline int __cpus_full(const cpumask_t *srcp, int nbits)
+static inline int cpumask_full(const struct cpumask *srcp)
 {
-	return bitmap_full(srcp->bits, nbits);
+	return bitmap_full(srcp->bits, NR_CPUS);
 }
 
-#define cpus_weight(cpumask) __cpus_weight(&(cpumask), NR_CPUS)
 static inline int __cpus_weight(const cpumask_t *srcp, int nbits)
 {
 	return bitmap_weight(srcp->bits, nbits);
 }
 
-#define cpus_shift_right(dst, src, n) \
-			__cpus_shift_right(&(dst), &(src), (n), NR_CPUS)
-static inline void __cpus_shift_right(cpumask_t *dstp,
-					const cpumask_t *srcp, int n, int nbits)
+static inline int cpumask_weight(const struct cpumask *srcp)
 {
-	bitmap_shift_right(dstp->bits, srcp->bits, n, nbits);
+	return bitmap_weight(srcp->bits, NR_CPUS);
 }
 
-#define cpus_shift_left(dst, src, n) \
-			__cpus_shift_left(&(dst), &(src), (n), NR_CPUS)
-static inline void __cpus_shift_left(cpumask_t *dstp,
-					const cpumask_t *srcp, int n, int nbits)
+static inline void cpumask_shift_right(struct cpumask *dstp,
+				       const struct cpumask *srcp, int n)
+{
+	bitmap_shift_right(dstp->bits, srcp->bits, n, NR_CPUS);
+}
+
+static inline void cpumask_shift_left(struct cpumask *dstp,
+				      const struct cpumask *srcp, int n)
 {
-	bitmap_shift_left(dstp->bits, srcp->bits, n, nbits);
+	bitmap_shift_left(dstp->bits, srcp->bits, n, NR_CPUS);
+}
+
+static inline int __cpumask_scnprintf(char *buf, int len,
+				      const struct cpumask *srcp)
+{
+	return bitmap_scnprintf(buf, len, srcp->bits, NR_CPUS);
+}
+
+static inline int __cpumask_parse_user(const char __user *buf, int len,
+				       struct cpumask *dstp)
+{
+	return bitmap_parse_user(buf, len, dstp->bits, NR_CPUS);
+}
+
+static inline int __cpulist_scnprintf(char *buf, int len,
+				      const struct cpumask *srcp)
+{
+	return bitmap_scnlistprintf(buf, len, srcp->bits, NR_CPUS);
+}
+
+static inline int __cpulist_parse(const char *buf, struct cpumask *dstp)
+{
+	return bitmap_parselist(buf, dstp->bits, NR_CPUS);
+}
+
+static inline int cpumask_cpuremap(int oldbit,
+				   const struct cpumask *oldp,
+				   const struct cpumask *newp)
+{
+	return bitmap_bitremap(oldbit, oldp->bits, newp->bits, NR_CPUS);
+}
+
+static inline void cpumask_remap(struct cpumask *dstp,
+				 const struct cpumask *srcp,
+				 const struct cpumask *oldp,
+				 const struct cpumask *newp)
+{
+	bitmap_remap(dstp->bits, srcp->bits, oldp->bits, newp->bits, NR_CPUS);
+}
+
+static inline void cpumask_onto(struct cpumask *dstp,
+				const struct cpumask *origp,
+				const struct cpumask *relmapp)
+{
+	bitmap_onto(dstp->bits, origp->bits, relmapp->bits, NR_CPUS);
+}
+
+static inline void cpumask_fold(struct cpumask *dstp,
+				const struct cpumask *origp, int sz)
+{
+	bitmap_fold(dstp->bits, origp->bits, sz, NR_CPUS);
 }
 
 /*
@@ -326,8 +415,6 @@ extern cpumask_t cpu_mask_all;
 	[0] =  1UL							\
 } }
 
-#define cpus_addr(src) ((src).bits)
-
 #if NR_CPUS > BITS_PER_LONG
 #define	CPUMASK_ALLOC(m)	struct m *m = kmalloc(sizeof(*m), GFP_KERNEL)
 #define	CPUMASK_FREE(m)		kfree(m)
@@ -337,68 +424,6 @@ extern cpumask_t cpu_mask_all;
 #endif
 #define	CPUMASK_PTR(v, m) 	cpumask_t *v = &(m->v)
 
-#define cpumask_scnprintf(buf, len, src) \
-			__cpumask_scnprintf((buf), (len), &(src), NR_CPUS)
-static inline int __cpumask_scnprintf(char *buf, int len,
-					const cpumask_t *srcp, int nbits)
-{
-	return bitmap_scnprintf(buf, len, srcp->bits, nbits);
-}
-
-#define cpumask_parse_user(ubuf, ulen, dst) \
-			__cpumask_parse_user((ubuf), (ulen), &(dst), NR_CPUS)
-static inline int __cpumask_parse_user(const char __user *buf, int len,
-					cpumask_t *dstp, int nbits)
-{
-	return bitmap_parse_user(buf, len, dstp->bits, nbits);
-}
-
-#define cpulist_scnprintf(buf, len, src) \
-			__cpulist_scnprintf((buf), (len), &(src), NR_CPUS)
-static inline int __cpulist_scnprintf(char *buf, int len,
-					const cpumask_t *srcp, int nbits)
-{
-	return bitmap_scnlistprintf(buf, len, srcp->bits, nbits);
-}
-
-#define cpulist_parse(buf, dst) __cpulist_parse((buf), &(dst), NR_CPUS)
-static inline int __cpulist_parse(const char *buf, cpumask_t *dstp, int nbits)
-{
-	return bitmap_parselist(buf, dstp->bits, nbits);
-}
-
-#define cpu_remap(oldbit, old, new) \
-		__cpu_remap((oldbit), &(old), &(new), NR_CPUS)
-static inline int __cpu_remap(int oldbit,
-		const cpumask_t *oldp, const cpumask_t *newp, int nbits)
-{
-	return bitmap_bitremap(oldbit, oldp->bits, newp->bits, nbits);
-}
-
-#define cpus_remap(dst, src, old, new) \
-		__cpus_remap(&(dst), &(src), &(old), &(new), NR_CPUS)
-static inline void __cpus_remap(cpumask_t *dstp, const cpumask_t *srcp,
-		const cpumask_t *oldp, const cpumask_t *newp, int nbits)
-{
-	bitmap_remap(dstp->bits, srcp->bits, oldp->bits, newp->bits, nbits);
-}
-
-#define cpus_onto(dst, orig, relmap) \
-		__cpus_onto(&(dst), &(orig), &(relmap), NR_CPUS)
-static inline void __cpus_onto(cpumask_t *dstp, const cpumask_t *origp,
-		const cpumask_t *relmapp, int nbits)
-{
-	bitmap_onto(dstp->bits, origp->bits, relmapp->bits, nbits);
-}
-
-#define cpus_fold(dst, orig, sz) \
-		__cpus_fold(&(dst), &(orig), sz, NR_CPUS)
-static inline void __cpus_fold(cpumask_t *dstp, const cpumask_t *origp,
-		int sz, int nbits)
-{
-	bitmap_fold(dstp->bits, origp->bits, sz, nbits);
-}
-
 #if NR_CPUS = 1
 
 #define nr_cpu_ids		1
--- linux-2.6.28.orig/lib/cpumask.c
+++ linux-2.6.28/lib/cpumask.c
@@ -18,7 +18,7 @@ EXPORT_SYMBOL(__next_cpu);
 int cpumask_next_and(int n, const cpumask_t *srcp, const cpumask_t *andp)
 {
 	while ((n = next_cpu_nr(n, *srcp)) < nr_cpu_ids)
-		if (cpu_isset(n, *andp))
+		if (cpumask_test_cpu(n, andp))
 			break;
 	return n;
 }

-- 

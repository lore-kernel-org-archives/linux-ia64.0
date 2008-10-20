From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:38 +0000
Subject: [PATCH 19/35] cpumask: use cpumask_bits() everywhere.
Message-Id: <20081020170322.226973000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Instead of accessing ->bits, we use cpumask_bits().  This will be very
useful when 'struct cpumask' has a hidden definition.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h  |   70 ++++++++++++++++++++++++++++-------------------
 include/linux/seq_file.h |    2 -
 kernel/time/timer_list.c |    4 +-
 lib/cpumask.c            |    4 +-
 4 files changed, 47 insertions(+), 33 deletions(-)

--- linux-2.6.28.orig/include/linux/cpumask.h
+++ linux-2.6.28/include/linux/cpumask.h
@@ -191,12 +191,12 @@ extern int nr_cpu_ids;
 
 static inline void cpumask_set_cpu(int cpu, volatile struct cpumask *dstp)
 {
-	set_bit(cpu, dstp->bits);
+	set_bit(cpu, cpumask_bits(dstp));
 }
 
 static inline void cpumask_clear_cpu(int cpu, volatile struct cpumask *dstp)
 {
-	clear_bit(cpu, dstp->bits);
+	clear_bit(cpu, cpumask_bits(dstp));
 }
 
 /* No static inline type checking - see Subtlety (1) above. */
@@ -204,130 +204,142 @@ static inline void cpumask_clear_cpu(int
 
 static inline int cpumask_test_and_set_cpu(int cpu, struct cpumask *addr)
 {
-	return test_and_set_bit(cpu, addr->bits);
+	return test_and_set_bit(cpu, cpumask_bits(addr));
 }
 
 static inline void cpumask_setall(struct cpumask *dstp)
 {
-	bitmap_fill(dstp->bits, nr_cpumask_bits);
+	bitmap_fill(cpumask_bits(dstp), nr_cpumask_bits);
 }
 
 static inline void cpumask_clear(struct cpumask *dstp)
 {
-	bitmap_zero(dstp->bits, nr_cpumask_bits);
+	bitmap_zero(cpumask_bits(dstp), nr_cpumask_bits);
 }
 
 static inline void cpumask_and(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
-	bitmap_and(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
+	bitmap_and(cpumask_bits(dstp), cpumask_bits(src1p),
+				       cpumask_bits(src2p), nr_cpumask_bits);
 }
 
 static inline void cpumask_or(struct cpumask *dstp, const struct cpumask *src1p,
 			      const struct cpumask *src2p)
 {
-	bitmap_or(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
+	bitmap_or(cpumask_bits(dstp), cpumask_bits(src1p),
+				      cpumask_bits(src2p), nr_cpumask_bits);
 }
 
 static inline void cpumask_xor(struct cpumask *dstp,
 			       const struct cpumask *src1p,
 			       const struct cpumask *src2p)
 {
-	bitmap_xor(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
+	bitmap_xor(cpumask_bits(dstp), cpumask_bits(src1p),
+				       cpumask_bits(src2p), nr_cpumask_bits);
 }
 
 static inline void cpumask_andnot(struct cpumask *dstp,
 				  const struct cpumask *src1p,
 				  const struct cpumask *src2p)
 {
-	bitmap_andnot(dstp->bits, src1p->bits, src2p->bits, nr_cpumask_bits);
+	bitmap_andnot(cpumask_bits(dstp), cpumask_bits(src1p),
+					  cpumask_bits(src2p), nr_cpumask_bits);
 }
 
 static inline void cpumask_complement(struct cpumask *dstp,
 				      const struct cpumask *srcp)
 {
-	bitmap_complement(dstp->bits, srcp->bits, nr_cpumask_bits);
+	bitmap_complement(cpumask_bits(dstp), cpumask_bits(srcp),
+					      nr_cpumask_bits);
 }
 
 static inline int cpumask_equal(const struct cpumask *src1p,
 				const struct cpumask *src2p)
 {
-	return bitmap_equal(src1p->bits, src2p->bits, nr_cpumask_bits);
+	return bitmap_equal(cpumask_bits(src1p), cpumask_bits(src2p),
+						 nr_cpumask_bits);
 }
 
 static inline int cpumask_intersects(const struct cpumask *src1p,
 				     const struct cpumask *src2p)
 {
-	return bitmap_intersects(src1p->bits, src2p->bits, nr_cpumask_bits);
+	return bitmap_intersects(cpumask_bits(src1p), cpumask_bits(src2p),
+						      nr_cpumask_bits);
 }
 
 static inline int cpumask_subset(const struct cpumask *src1p,
 				 const struct cpumask *src2p)
 {
-	return bitmap_subset(src1p->bits, src2p->bits, nr_cpumask_bits);
+	return bitmap_subset(cpumask_bits(src1p), cpumask_bits(src2p),
+						  nr_cpumask_bits);
 }
 
 static inline int cpumask_empty(const struct cpumask *srcp)
 {
-	return bitmap_empty(srcp->bits, nr_cpumask_bits);
+	return bitmap_empty(cpumask_bits(srcp), nr_cpumask_bits);
 }
 
 static inline int cpumask_full(const struct cpumask *srcp)
 {
-	return bitmap_full(srcp->bits, nr_cpumask_bits);
+	return bitmap_full(cpumask_bits(srcp), nr_cpumask_bits);
 }
 
 static inline int __cpus_weight(const cpumask_t *srcp, int nbits)
 {
-	return bitmap_weight(srcp->bits, nbits);
+	return bitmap_weight(cpumask_bits(srcp), nbits);
 }
 
 static inline int cpumask_weight(const struct cpumask *srcp)
 {
-	return bitmap_weight(srcp->bits, nr_cpumask_bits);
+	return bitmap_weight(cpumask_bits(srcp), nr_cpumask_bits);
 }
 
 static inline void cpumask_shift_right(struct cpumask *dstp,
 				       const struct cpumask *srcp, int n)
 {
-	bitmap_shift_right(dstp->bits, srcp->bits, n, nr_cpumask_bits);
+	bitmap_shift_right(cpumask_bits(dstp), cpumask_bits(srcp), n,
+					       nr_cpumask_bits);
 }
 
 static inline void cpumask_shift_left(struct cpumask *dstp,
 				      const struct cpumask *srcp, int n)
 {
-	bitmap_shift_left(dstp->bits, srcp->bits, n, nr_cpumask_bits);
+	bitmap_shift_left(cpumask_bits(dstp), cpumask_bits(srcp), n,
+					      nr_cpumask_bits);
 }
 
 static inline int cpumask_scnprintf(char *buf, int len,
 				    const struct cpumask *srcp)
 {
-	return bitmap_scnprintf(buf, len, srcp->bits, nr_cpumask_bits);
+	return bitmap_scnprintf(buf, len, cpumask_bits(srcp), nr_cpumask_bits);
 }
 
 static inline int cpumask_parse_user(const char __user *buf, int len,
 				     struct cpumask *dstp)
 {
-	return bitmap_parse_user(buf, len, dstp->bits, nr_cpumask_bits);
+	return bitmap_parse_user(buf, len, cpumask_bits(dstp), nr_cpumask_bits);
 }
 
 static inline int cpulist_scnprintf(char *buf, int len,
 				    const struct cpumask *srcp)
 {
-	return bitmap_scnlistprintf(buf, len, srcp->bits, nr_cpumask_bits);
+	return bitmap_scnlistprintf(buf, len, cpumask_bits(srcp),
+					      nr_cpumask_bits);
 }
 
 static inline int cpulist_parse(const char *buf, struct cpumask *dstp)
 {
-	return bitmap_parselist(buf, dstp->bits, nr_cpumask_bits);
+	return bitmap_parselist(buf, cpumask_bits(dstp), nr_cpumask_bits);
 }
 
 static inline int cpumask_cpuremap(int oldbit,
 				   const struct cpumask *oldp,
 				   const struct cpumask *newp)
 {
-	return bitmap_bitremap(oldbit, oldp->bits, newp->bits, nr_cpumask_bits);
+	return bitmap_bitremap(oldbit, cpumask_bits(oldp), cpumask_bits(newp),
+							   nr_cpumask_bits);
 }
 
 static inline void cpumask_remap(struct cpumask *dstp,
@@ -335,21 +347,23 @@ static inline void cpumask_remap(struct 
 				 const struct cpumask *oldp,
 				 const struct cpumask *newp)
 {
-	bitmap_remap(dstp->bits, srcp->bits, oldp->bits, newp->bits,
-		     nr_cpumask_bits);
+	bitmap_remap(cpumask_bits(dstp), cpumask_bits(srcp),
+		     cpumask_bits(oldp), cpumask_bits(newp), nr_cpumask_bits);
 }
 
 static inline void cpumask_onto(struct cpumask *dstp,
 				const struct cpumask *origp,
 				const struct cpumask *relmapp)
 {
-	bitmap_onto(dstp->bits, origp->bits, relmapp->bits, nr_cpumask_bits);
+	bitmap_onto(cpumask_bits(dstp), cpumask_bits(origp),
+					cpumask_bits(relmapp), nr_cpumask_bits);
 }
 
 static inline void cpumask_fold(struct cpumask *dstp,
 				const struct cpumask *origp, int sz)
 {
-	bitmap_fold(dstp->bits, origp->bits, sz, nr_cpumask_bits);
+	bitmap_fold(cpumask_bits(dstp), cpumask_bits(origp), sz,
+					nr_cpumask_bits);
 }
 
 static inline void cpumask_copy(struct cpumask *dstp,
--- linux-2.6.28.orig/include/linux/seq_file.h
+++ linux-2.6.28/include/linux/seq_file.h
@@ -52,7 +52,7 @@ int seq_path_root(struct seq_file *m, st
 int seq_bitmap(struct seq_file *m, unsigned long *bits, unsigned int nr_bits);
 static inline int seq_cpumask(struct seq_file *m, cpumask_t *mask)
 {
-	return seq_bitmap(m, mask->bits, nr_cpu_ids);
+	return seq_bitmap(m, cpumask_bits(mask), nr_cpu_ids);
 }
 
 static inline int seq_nodemask(struct seq_file *m, nodemask_t *mask)
--- linux-2.6.28.orig/kernel/time/timer_list.c
+++ linux-2.6.28/kernel/time/timer_list.c
@@ -226,10 +226,10 @@ static void timer_list_show_tickdevices(
 #ifdef CONFIG_GENERIC_CLOCKEVENTS_BROADCAST
 	print_tickdevice(m, tick_get_broadcast_device());
 	SEQ_printf(m, "tick_broadcast_mask: %08lx\n",
-		   tick_get_broadcast_mask()->bits[0]);
+		   cpumask_bits(tick_get_broadcast_mask())[0]);
 #ifdef CONFIG_TICK_ONESHOT
 	SEQ_printf(m, "tick_broadcast_oneshot_mask: %08lx\n",
-		   tick_get_broadcast_oneshot_mask()->bits[0]);
+		   cpumask_bits(tick_get_broadcast_oneshot_mask())[0]);
 #endif
 	SEQ_printf(m, "\n");
 #endif
--- linux-2.6.28.orig/lib/cpumask.c
+++ linux-2.6.28/lib/cpumask.c
@@ -5,13 +5,13 @@
 
 int __first_cpu(const cpumask_t *srcp)
 {
-	return find_first_bit(srcp->bits, nr_cpumask_bits);
+	return find_first_bit(cpumask_bits(srcp), nr_cpumask_bits);
 }
 EXPORT_SYMBOL(__first_cpu);
 
 int __next_cpu(int n, const cpumask_t *srcp)
 {
-	return find_next_bit(srcp->bits, nr_cpumask_bits, n+1);
+	return find_next_bit(cpumask_bits(srcp), nr_cpumask_bits, n+1);
 }
 EXPORT_SYMBOL(__next_cpu);
 

-- 

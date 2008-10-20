From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:52 +0000
Subject: [PATCH 33/35] cpumask: reorder header to minimize separate #ifdefs
Message-Id: <20081020170324.146129000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

cpumask.h is pretty chaotic.  Now we've replaced most of it, let's
group things together a bit better.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |   72 ++++++++++++++++++++++--------------------------
 1 file changed, 34 insertions(+), 38 deletions(-)

--- test-compile.orig/include/linux/cpumask.h
+++ test-compile/include/linux/cpumask.h
@@ -134,6 +134,8 @@ static inline ssize_t cpumask_size(void)
 }
 
 
+#define cpumask_size() (BITS_TO_LONGS(nr_cpumask_bits) * sizeof(long))
+
 /* Deprecated. */
 typedef struct cpumask cpumask_t;
 extern cpumask_t _unused_cpumask_arg_;
@@ -200,6 +202,22 @@ extern cpumask_t _unused_cpumask_arg_;
 #define cpu_mask_all		(*(cpumask_t *)cpu_all_mask)
 /* End deprecated region. */
 
+/* static cpumask initializers */
+#define CPU_MASK_LAST_WORD BITMAP_LAST_WORD_MASK(CONFIG_NR_CPUS)
+#if CONFIG_NR_CPUS <= BITS_PER_LONG
+#define CPU_BITS_ALL						\
+{								\
+	[BITS_TO_LONGS(CONFIG_NR_CPUS)-1] = CPU_MASK_LAST_WORD	\
+}
+#else
+#define CPU_BITS_ALL						\
+{								\
+	[0 ... BITS_TO_LONGS(CONFIG_NR_CPUS)-2] = ~0UL,		\
+	[BITS_TO_LONGS(CONFIG_NR_CPUS)-1] = CPU_MASK_LAST_WORD	\
+}
+#endif /* CONFIG_NR_CPUS > BITS_PER_LONG */
+
+/* cpumask_* operators */
 static inline void cpumask_set_cpu(int cpu, volatile struct cpumask *dstp)
 {
 	set_bit(cpu, cpumask_bits(dstp));
@@ -414,25 +432,6 @@ static inline const struct cpumask *cpum
 	return (const struct cpumask *)p;
 }
 
-#define CPU_MASK_LAST_WORD BITMAP_LAST_WORD_MASK(NR_CPUS)
-
-#if NR_CPUS <= BITS_PER_LONG
-
-#define CPU_BITS_ALL						\
-{								\
-	[BITS_TO_LONGS(CONFIG_NR_CPUS)-1] = CPU_MASK_LAST_WORD	\
-}
-
-#else
-
-#define CPU_BITS_ALL						\
-{								\
-	[0 ... BITS_TO_LONGS(CONFIG_NR_CPUS)-2] = ~0UL,		\
-	[BITS_TO_LONGS(CONFIG_NR_CPUS)-1] = CPU_MASK_LAST_WORD	\
-}
-
-#endif
-
 #define CPU_BITS_NONE						\
 {								\
 	[0 ... BITS_TO_LONGS(CONFIG_NR_CPUS)-1] = 0UL		\
@@ -455,6 +454,13 @@ static inline const struct cpumask *cpum
 #define for_each_cpu_and(cpu, mask, and)	\
 	for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask, (void)and)
 
+#define num_online_cpus()	1
+#define num_possible_cpus()	1
+#define num_present_cpus()	1
+#define cpu_online(cpu)		((cpu) = 0)
+#define cpu_possible(cpu)	((cpu) = 0)
+#define cpu_present(cpu)	((cpu) = 0)
+#define cpu_active(cpu)		((cpu) = 0)
 #else /* NR_CPUS > 1 */
 
 int cpumask_first(const cpumask_t *srcp);
@@ -470,7 +476,15 @@ int cpumask_any_but(const struct cpumask
 	for ((cpu) = -1;					\
 		(cpu) = cpumask_next_and((cpu), (mask), (and)),	\
 		(cpu) < nr_cpumask_bits;)
-#endif
+
+#define num_online_cpus()	cpus_weight(cpu_online_map)
+#define num_possible_cpus()	cpus_weight(cpu_possible_map)
+#define num_present_cpus()	cpus_weight(cpu_present_map)
+#define cpu_online(cpu)		cpu_isset((cpu), cpu_online_map)
+#define cpu_possible(cpu)	cpu_isset((cpu), cpu_possible_map)
+#define cpu_present(cpu)	cpu_isset((cpu), cpu_present_map)
+#define cpu_active(cpu)		cpu_isset((cpu), cpu_active_map)
+#endif /* NR_CPUS */
 
 #define cpumask_first_and(mask, and) cpumask_next_and(-1, (mask), (and))
 
@@ -563,24 +577,6 @@ extern const DECLARE_BITMAP(cpu_all_bits
 /* First bits of cpu_bit_bitmap are in fact unset. */
 #define cpu_none_mask to_cpumask(cpu_bit_bitmap[0])
 
-#if NR_CPUS > 1
-#define num_online_cpus()	cpus_weight(cpu_online_map)
-#define num_possible_cpus()	cpus_weight(cpu_possible_map)
-#define num_present_cpus()	cpus_weight(cpu_present_map)
-#define cpu_online(cpu)		cpu_isset((cpu), cpu_online_map)
-#define cpu_possible(cpu)	cpu_isset((cpu), cpu_possible_map)
-#define cpu_present(cpu)	cpu_isset((cpu), cpu_present_map)
-#define cpu_active(cpu)		cpu_isset((cpu), cpu_active_map)
-#else
-#define num_online_cpus()	1
-#define num_possible_cpus()	1
-#define num_present_cpus()	1
-#define cpu_online(cpu)		((cpu) = 0)
-#define cpu_possible(cpu)	((cpu) = 0)
-#define cpu_present(cpu)	((cpu) = 0)
-#define cpu_active(cpu)		((cpu) = 0)
-#endif
-
 /* Wrappers to manipulate otherwise-constant masks. */
 void set_cpu_possible(unsigned int cpu, bool possible);
 void set_cpu_present(unsigned int cpu, bool present);

-- 

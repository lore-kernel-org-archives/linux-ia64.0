From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:44 +0000
Subject: [PATCH 25/35] cpumask: Deprecate CPUMASK_ALLOC etc in favor of cpumask_var_t.
Message-Id: <20081020170323.056637000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Remove CPUMASK_ALLOC() in favor of alloc_cpumask_var().

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |   46 ++++++++--------------------------------------
 1 file changed, 8 insertions(+), 38 deletions(-)

--- linux-2.6.28.orig/include/linux/cpumask.h
+++ linux-2.6.28/include/linux/cpumask.h
@@ -57,35 +57,6 @@
  * CPU_MASK_NONE			Initializer - no bits set
  * unsigned long *cpumask_bits(mask)	Array of unsigned long's in mask
  *
- * CPUMASK_ALLOC kmalloc's a structure that is a composite of many cpumask_t
- * variables, and CPUMASK_PTR provides pointers to each field.
- *
- * The structure should be defined something like this:
- * struct my_cpumasks {
- *	cpumask_t mask1;
- *	cpumask_t mask2;
- * };
- *
- * Usage is then:
- *	CPUMASK_ALLOC(my_cpumasks);
- *	CPUMASK_PTR(mask1, my_cpumasks);
- *	CPUMASK_PTR(mask2, my_cpumasks);
- *
- *	--- DO NOT reference cpumask_t pointers until this check ---
- *	if (my_cpumasks = NULL)
- *		"kmalloc failed"...
- *
- * References are now pointers to the cpumask_t variables (*mask1, ...)
- *
- *if NR_CPUS > BITS_PER_LONG
- *   CPUMASK_ALLOC(m)			Declares and allocates struct m *m - *						kmalloc(sizeof(*m), GFP_KERNEL)
- *   CPUMASK_FREE(m)			Macro for kfree(m)
- *else
- *   CPUMASK_ALLOC(m)			Declares struct m _m, *m = &_m
- *   CPUMASK_FREE(m)			Nop
- *endif
- *   CPUMASK_PTR(v, m)			Declares cpumask_t *v = &(m->v)
  * ------------------------------------------------------------------------
  *
  * int cpumask_scnprintf(buf, len, mask) Format cpumask for printing
@@ -184,6 +155,14 @@ extern cpumask_t _unused_cpumask_arg_;
 #define first_cpu(src)		cpumask_first(&(src))
 #define next_cpu(n, src)	cpumask_next((n), &(src))
 #define any_online_cpu(mask)	cpumask_any_and(&(mask), &cpu_online_map)
+#if NR_CPUS > BITS_PER_LONG
+#define	CPUMASK_ALLOC(m)	struct m *m = kmalloc(sizeof(*m), GFP_KERNEL)
+#define	CPUMASK_FREE(m)		kfree(m)
+#else
+#define	CPUMASK_ALLOC(m)	struct m _m, *m = &_m
+#define	CPUMASK_FREE(m)
+#endif
+#define	CPUMASK_PTR(v, m) 	cpumask_t *v = &(m->v)
 /* End deprecated region. */
 
 #if NR_CPUS <= BITS_PER_LONG
@@ -435,15 +414,6 @@ extern cpumask_t cpu_mask_all;
 	[0] =  1UL							\
 } }
 
-#if NR_CPUS > BITS_PER_LONG
-#define	CPUMASK_ALLOC(m)	struct m *m = kmalloc(sizeof(*m), GFP_KERNEL)
-#define	CPUMASK_FREE(m)		kfree(m)
-#else
-#define	CPUMASK_ALLOC(m)	struct m _m, *m = &_m
-#define	CPUMASK_FREE(m)
-#endif
-#define	CPUMASK_PTR(v, m) 	cpumask_t *v = &(m->v)
-
 #if NR_CPUS = 1
 
 #define cpumask_first(src)	({ (void)(src); 0; })

-- 

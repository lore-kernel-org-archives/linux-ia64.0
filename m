From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:43 +0000
Subject: [PATCH 24/35] cpumask: cpumask_any_but()
Message-Id: <20081020170322.922269000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

There's a common case where we want any online cpu except a particular
one.  This creates a helper to do that, otherwise we need a temp var
and cpumask_andnot().

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |    3 +++
 lib/cpumask.c           |   10 ++++++++++
 2 files changed, 13 insertions(+)

--- test-compile.orig/include/linux/cpumask.h
+++ test-compile/include/linux/cpumask.h
@@ -111,6 +111,7 @@
  *
  * int cpumask_any(mask)		Any cpu in mask
  * int cpumask_any_and(mask1,mask2)	Any cpu in both masks
+ * int cpumask_any_but(mask,cpu)	Any cpu in mask except cpu
  *
  * for_each_possible_cpu(cpu)		for-loop cpu over cpu_possible_map
  * for_each_online_cpu(cpu)		for-loop cpu over cpu_online_map
@@ -458,6 +459,7 @@ extern cpumask_t cpu_mask_all;
 #define cpumask_first(src)		({ (void)(src); 0; })
 #define cpumask_next(n, src)		({ (void)(src); 1; })
 #define cpumask_next_and(n, srcp, andp)	({ (void)(srcp), (void)(andp); 1; })
+#define cpumask_any_but(mask, cpu)	({ (void)(mask); (void)(cpu); 0; })
 
 #define for_each_cpu(cpu, mask)			\
 	for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
@@ -469,6 +471,7 @@ extern cpumask_t cpu_mask_all;
 int cpumask_first(const cpumask_t *srcp);
 int cpumask_next(int n, const cpumask_t *srcp);
 int cpumask_next_and(int n, const cpumask_t *srcp, const cpumask_t *andp);
+int cpumask_any_but(const struct cpumask *mask, unsigned int cpu);
 
 #define for_each_cpu(cpu, mask)				\
 	for ((cpu) = -1;				\
--- test-compile.orig/lib/cpumask.c
+++ test-compile/lib/cpumask.c
@@ -24,6 +24,16 @@ int cpumask_next_and(int n, const cpumas
 }
 EXPORT_SYMBOL(cpumask_next_and);
 
+int cpumask_any_but(const struct cpumask *mask, unsigned int cpu)
+{
+	unsigned int i;
+
+	for_each_cpu(i, mask)
+		if (i != cpu)
+			break;
+	return i;
+}
+
 /* These are not inline because of header tangles. */
 #ifdef CONFIG_CPUMASK_OFFSTACK
 bool alloc_cpumask_var(cpumask_var_t *mask, gfp_t flags)

-- 

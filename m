From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:54 +0000
Subject: [PATCH 35/35] cpumask: smp_call_function_many()
Message-Id: <20081020170324.412681000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Transition from cpumask_t-taking smp_call_function_mask() to a new
smp_call_function_many() which takes a struct cpumask *.

(Naming is inspired by smp_call_function_single).

Note that the new one returns void: the old one couldn't fail either
unless there was a logic bug.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/s390/include/asm/smp.h |    3 -
 arch/s390/kernel/smp.c      |   30 +++++++++++--------
 include/linux/smp.h         |   13 +++++++-
 kernel/smp.c                |   68 +++++++++++++++++++++++---------------------
 4 files changed, 64 insertions(+), 50 deletions(-)

--- test-compile.orig/arch/s390/include/asm/smp.h
+++ test-compile/arch/s390/include/asm/smp.h
@@ -90,9 +90,6 @@ extern int __cpu_up (unsigned int cpu);
 
 extern struct mutex smp_cpu_state_mutex;
 extern int smp_cpu_polarization[];
-
-extern int smp_call_function_mask(cpumask_t mask, void (*func)(void *),
-	void *info, int wait);
 #endif
 
 #ifndef CONFIG_SMP
--- test-compile.orig/arch/s390/kernel/smp.c
+++ test-compile/arch/s390/kernel/smp.c
@@ -103,7 +103,7 @@ static void do_call_function(void)
 }
 
 static void __smp_call_function_map(void (*func) (void *info), void *info,
-				    int wait, cpumask_t map)
+				    int wait, struct cpumask *map)
 {
 	struct call_data_struct data;
 	int cpu, local = 0;
@@ -163,14 +163,16 @@ out:
  * You must not call this function with disabled interrupts, from a
  * hardware interrupt handler or from a bottom half.
  */
+
+/* protected by call_lock */
+static DEFINE_BITMAP(smp_call_map, CONFIG_NR_CPUS);
+
 int smp_call_function(void (*func) (void *info), void *info, int wait)
 {
-	cpumask_t map;
-
 	spin_lock(&call_lock);
-	map = cpu_online_map;
-	cpu_clear(smp_processor_id(), map);
-	__smp_call_function_map(func, info, wait, map);
+	cpumask_copy(to_cpumask(smp_call_map), cpu_online_mask);
+	cpumask_clear_cpu(smp_processor_id(), to_cpumask(smp_call_map));
+	__smp_call_function_map(func, info, wait, to_cpumask(smp_call_map));
 	spin_unlock(&call_lock);
 	return 0;
 }
@@ -192,14 +194,15 @@ int smp_call_function_single(int cpu, vo
 			     int wait)
 {
 	spin_lock(&call_lock);
-	__smp_call_function_map(func, info, wait, cpumask_of_cpu(cpu));
+	cpumask_copy(to_cpumask(smp_call_map), cpumask_of(cpu));
+	__smp_call_function_map(func, info, wait, cpumask_of(cpu));
 	spin_unlock(&call_lock);
 	return 0;
 }
 EXPORT_SYMBOL(smp_call_function_single);
 
 /**
- * smp_call_function_mask(): Run a function on a set of other CPUs.
+ * smp_call_function_many(): Run a function on a set of other CPUs.
  * @mask: The set of cpus to run on.  Must not include the current cpu.
  * @func: The function to run. This must be fast and non-blocking.
  * @info: An arbitrary pointer to pass to the function.
@@ -213,16 +216,17 @@ EXPORT_SYMBOL(smp_call_function_single);
  * You must not call this function with disabled interrupts or from a
  * hardware interrupt handler or from a bottom half handler.
  */
-int smp_call_function_mask(cpumask_t mask, void (*func)(void *), void *info,
-			   int wait)
+int smp_call_function_many(const struct cpumask *mask,
+			   void (*func)(void *), void *info, bool wait)
 {
 	spin_lock(&call_lock);
-	cpu_clear(smp_processor_id(), mask);
-	__smp_call_function_map(func, info, wait, mask);
+	cpumask_copy(to_cpumask(smp_call_map), cpu_online_mask);
+	cpumask_clear_cpu(smp_processor_id(), to_cpumask(smp_call_map));
+	__smp_call_function_map(func, info, wait, to_cpumask(smp_call_map));
 	spin_unlock(&call_lock);
 	return 0;
 }
-EXPORT_SYMBOL(smp_call_function_mask);
+EXPORT_SYMBOL(smp_call_function_many);
 
 void smp_send_stop(void)
 {
--- test-compile.orig/include/linux/smp.h
+++ test-compile/include/linux/smp.h
@@ -62,12 +62,21 @@ extern void smp_cpus_done(unsigned int m
  * Call a function on all other processors
  */
 int smp_call_function(void(*func)(void *info), void *info, int wait);
-int smp_call_function_mask(cpumask_t mask, void(*func)(void *info), void *info,
-				int wait);
+void smp_call_function_many(const struct cpumask *mask,
+			    void(*func)(void *info), void *info, bool wait);
 int smp_call_function_single(int cpuid, void (*func) (void *info), void *info,
 				int wait);
 void __smp_call_function_single(int cpuid, struct call_single_data *data);
 
+/* Use smp_call_function_many, which takes a pointer to the mask. */
+static inline int __deprecated
+smp_call_function_mask(cpumask_t mask, void(*func)(void *info), void *info,
+		       int wait)
+{
+	smp_call_function_many(&mask, func, info, wait);
+	return 0;
+}
+
 /*
  * Generic and arch helpers
  */
--- test-compile.orig/kernel/smp.c
+++ test-compile/kernel/smp.c
@@ -24,7 +24,7 @@ struct call_function_data {
 	struct call_single_data csd;
 	spinlock_t lock;
 	unsigned int refs;
-	cpumask_t cpumask;
+	struct cpumask *cpumask;
 	struct rcu_head rcu_head;
 };
 
@@ -109,13 +109,13 @@ void generic_smp_call_function_interrupt
 	list_for_each_entry_rcu(data, &call_function_queue, csd.list) {
 		int refs;
 
-		if (!cpu_isset(cpu, data->cpumask))
+		if (!cpumask_test_cpu(cpu, data->cpumask))
 			continue;
 
 		data->csd.func(data->csd.info);
 
 		spin_lock(&data->lock);
-		cpu_clear(cpu, data->cpumask);
+		cpumask_clear_cpu(cpu, data->cpumask);
 		WARN_ON(data->refs = 0);
 		data->refs--;
 		refs = data->refs;
@@ -273,7 +273,7 @@ static void quiesce_dummy(void *unused)
 /*
  * Ensure stack based data used in call function mask is safe to free.
  *
- * This is needed by smp_call_function_mask when using on-stack data, because
+ * This is needed by smp_call_function_many when using on-stack data, because
  * a single call function queue is shared by all CPUs, and any CPU may pick up
  * the data item on the queue at any time before it is deleted. So we need to
  * ensure that all CPUs have transitioned through a quiescent state after
@@ -287,7 +287,7 @@ static void quiesce_dummy(void *unused)
  * If a faster scheme can be made, we could go back to preferring stack based
  * data -- the data allocation/free is non-zero cost.
  */
-static void smp_call_function_mask_quiesce_stack(cpumask_t mask)
+static void smp_call_function_mask_quiesce_stack(const struct cpumask *mask)
 {
 	struct call_single_data data;
 	int cpu;
@@ -295,21 +295,19 @@ static void smp_call_function_mask_quies
 	data.func = quiesce_dummy;
 	data.info = NULL;
 
-	for_each_cpu_mask(cpu, mask) {
+	for_each_cpu(cpu, mask) {
 		data.flags = CSD_FLAG_WAIT;
 		generic_exec_single(cpu, &data);
 	}
 }
 
 /**
- * smp_call_function_mask(): Run a function on a set of other CPUs.
- * @mask: The set of cpus to run on.
+ * smp_call_function_many(): Run a function on a set of other CPUs.
+ * @mask: The set of cpus to run on (only runs on online subset).
  * @func: The function to run. This must be fast and non-blocking.
  * @info: An arbitrary pointer to pass to the function.
  * @wait: If true, wait (atomically) until function has completed on other CPUs.
  *
- * Returns 0 on success, else a negative status code.
- *
  * If @wait is true, then returns once @func has returned. Note that @wait
  * will be implicitly turned on in case of allocation failures, since
  * we fall back to on-stack allocation.
@@ -318,12 +316,13 @@ static void smp_call_function_mask_quies
  * hardware interrupt handler or from a bottom half handler. Preemption
  * must be disabled when calling this function.
  */
-int smp_call_function_mask(cpumask_t mask, void (*func)(void *), void *info,
-			   int wait)
+void smp_call_function_many(const struct cpumask *mask,
+			    void (*func)(void *), void *info,
+			    bool wait)
 {
 	struct call_function_data d;
 	struct call_function_data *data = NULL;
-	cpumask_t allbutself;
+	cpumask_var_t allbutself;
 	unsigned long flags;
 	int cpu, num_cpus;
 	int slowpath = 0;
@@ -331,21 +330,28 @@ int smp_call_function_mask(cpumask_t mas
 	/* Can deadlock when called with interrupts disabled */
 	WARN_ON(irqs_disabled());
 
-	cpu = smp_processor_id();
-	allbutself = cpu_online_map;
-	cpu_clear(cpu, allbutself);
-	cpus_and(mask, mask, allbutself);
-	num_cpus = cpus_weight(mask);
+	if (!alloc_cpumask_var(&allbutself, GFP_ATOMIC)) {
+		/* Slow path. */
+		for_each_online_cpu(cpu) {
+			if (cpumask_test_cpu(cpu, mask))
+				smp_call_function_single(cpu, func, info, wait);
+		}
+		return;
+	}
+	cpumask_and(allbutself, cpu_online_mask, mask);
+	cpumask_clear_cpu(smp_processor_id(), allbutself);
+	num_cpus = cpumask_weight(allbutself);
 
 	/*
 	 * If zero CPUs, return. If just a single CPU, turn this request
 	 * into a targetted single call instead since it's faster.
 	 */
 	if (!num_cpus)
-		return 0;
+		return;
 	else if (num_cpus = 1) {
-		cpu = first_cpu(mask);
-		return smp_call_function_single(cpu, func, info, wait);
+		cpu = cpumask_first(allbutself);
+		smp_call_function_single(cpu, func, info, wait);
+		goto out;
 	}
 
 	data = kmalloc(sizeof(*data), GFP_ATOMIC);
@@ -364,25 +370,25 @@ int smp_call_function_mask(cpumask_t mas
 	data->csd.func = func;
 	data->csd.info = info;
 	data->refs = num_cpus;
-	data->cpumask = mask;
+	data->cpumask = allbutself;
 
 	spin_lock_irqsave(&call_function_lock, flags);
 	list_add_tail_rcu(&data->csd.list, &call_function_queue);
 	spin_unlock_irqrestore(&call_function_lock, flags);
 
 	/* Send a message to all CPUs in the map */
-	arch_send_call_function_ipi(mask);
+	arch_send_call_function_ipi((cpumask_t)*allbutself);
 
 	/* optionally wait for the CPUs to complete */
 	if (wait) {
 		csd_flag_wait(&data->csd);
 		if (unlikely(slowpath))
-			smp_call_function_mask_quiesce_stack(mask);
+			smp_call_function_mask_quiesce_stack(allbutself);
 	}
-
-	return 0;
+out:
+	free_cpumask_var(allbutself);
 }
-EXPORT_SYMBOL(smp_call_function_mask);
+EXPORT_SYMBOL(smp_call_function_many);
 
 /**
  * smp_call_function(): Run a function on all other CPUs.
@@ -390,7 +396,7 @@ EXPORT_SYMBOL(smp_call_function_mask);
  * @info: An arbitrary pointer to pass to the function.
  * @wait: If true, wait (atomically) until function has completed on other CPUs.
  *
- * Returns 0 on success, else a negative status code.
+ * Returns 0.
  *
  * If @wait is true, then returns once @func has returned; otherwise
  * it returns just before the target cpu calls @func. In case of allocation
@@ -401,12 +407,10 @@ EXPORT_SYMBOL(smp_call_function_mask);
  */
 int smp_call_function(void (*func)(void *), void *info, int wait)
 {
-	int ret;
-
 	preempt_disable();
-	ret = smp_call_function_mask(cpu_online_map, func, info, wait);
+	smp_call_function_many(cpu_online_mask, func, info, wait);
 	preempt_enable();
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL(smp_call_function);
 

-- 

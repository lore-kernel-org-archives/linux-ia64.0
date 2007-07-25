From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 25 Jul 2007 08:59:22 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <1185353962.3917.38.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Doug,

2007-07-25 (水) の 01:09 -0400 に Doug Chapman さんは書きました:
> Yasuaki,
> 
> I added a bunch of printk's to try to better understand this.
> ia64_mv.setup does get initialized properly but then gets overwritten.
> It appears that it gets overwritten in __bind_irq_vector but I have not
> narrowed down exactly where.  I put a printk at the top and bottom of
> this function to show what ia64_mv.setup is and I am finding that on the
> 3rd call to this function it causes ia64_mv.setup to get set to -1.
> 
> It is getting way too late for me (1AM here).  I will try to dig into
> this more tomorrow but at least I have narrowed it down to a bit of code
> that actually is touched by the commit that causes the panic.
> 
> - Doug

I found a bug which causes wrong access to vector_table[] array.
I guess ia64_mv.setup was destroyed by this. Could you try the
attached patch?

Thanks,
Kenji Kaneshige
---

Fix wrong access to vector_table[].

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

Index: linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
@@ -85,8 +85,8 @@ DEFINE_PER_CPU(int[IA64_NUM_VECTORS], ve
 	[0 ... IA64_NUM_VECTORS - 1] = IA64_SPURIOUS_INT_VECTOR
 };
 
-static cpumask_t vector_table[IA64_MAX_DEVICE_VECTORS] = {
-	[0 ... IA64_MAX_DEVICE_VECTORS - 1] = CPU_MASK_NONE
+static cpumask_t vector_table[IA64_NUM_VECTORS] = {
+	[0 ... IA64_NUM_VECTORS - 1] = CPU_MASK_NONE
 };
 
 static int irq_status[NR_IRQS] = {
@@ -123,17 +123,18 @@ static inline int find_unassigned_irq(vo
 static inline int find_unassigned_vector(cpumask_t domain)
 {
 	cpumask_t mask;
-	int pos;
+	int pos, vector;
 
 	cpus_and(mask, domain, cpu_online_map);
 	if (cpus_empty(mask))
 		return -EINVAL;
 
 	for (pos = 0; pos < IA64_NUM_DEVICE_VECTORS; pos++) {
-		cpus_and(mask, domain, vector_table[pos]);
+		vector = IA64_FIRST_DEVICE_VECTOR + pos;
+		cpus_and(mask, domain, vector_table[vector]);
 		if (!cpus_empty(mask))
 			continue;
-		return IA64_FIRST_DEVICE_VECTOR + pos;
+		return vector;
 	}
 	return -ENOSPC;
 }
@@ -141,7 +142,7 @@ static inline int find_unassigned_vector
 static int __bind_irq_vector(int irq, int vector, cpumask_t domain)
 {
 	cpumask_t mask;
-	int cpu, pos;
+	int cpu;
 	struct irq_cfg *cfg = &irq_cfg[irq];
 
 	cpus_and(mask, domain, cpu_online_map);
@@ -156,8 +157,7 @@ static int __bind_irq_vector(int irq, in
 	cfg->vector = vector;
 	cfg->domain = domain;
 	irq_status[irq] = IRQ_USED;
-	pos = vector - IA64_FIRST_DEVICE_VECTOR;
-	cpus_or(vector_table[pos], vector_table[pos], domain);
+	cpus_or(vector_table[vector], vector_table[vector], domain);
 	return 0;
 }
 
@@ -174,7 +174,7 @@ int bind_irq_vector(int irq, int vector,
 
 static void __clear_irq_vector(int irq)
 {
-	int vector, cpu, pos;
+	int vector, cpu;
 	cpumask_t mask;
 	cpumask_t domain;
 	struct irq_cfg *cfg = &irq_cfg[irq];
@@ -189,8 +189,7 @@ static void __clear_irq_vector(int irq)
 	cfg->vector = IRQ_VECTOR_UNASSIGNED;
 	cfg->domain = CPU_MASK_NONE;
 	irq_status[irq] = IRQ_UNUSED;
-	pos = vector - IA64_FIRST_DEVICE_VECTOR;
-	cpus_andnot(vector_table[pos], vector_table[pos], domain);
+	cpus_andnot(vector_table[vector], vector_table[vector], domain);
 }
 
 static void clear_irq_vector(int irq)



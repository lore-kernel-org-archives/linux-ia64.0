From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Tue, 31 Jul 2007 22:13:56 +0000
Subject: "Add support for vector domain" breaks boot on x355
Message-Id: <20070731221356.GA31324@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: isimatu.yasuaki@jp.fujitsu.com
Cc: kaneshige.kenji@jp.fujitsu.com, tony.luck@intel.com, torvalds@linux-foundation.org, ryhodges@us.ibm.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

The following commit (4994be1b3fe9120c88022ff5c0c33f6312b17adb) broke
Linus' Tree between 2.6.22-git15 and 2.6.22-git16 on a 2-node 8-way x455
(Madison procs). Thanks to Ryan Hodges for bisecting down to this
commit.

Bisection log:
git-bisect start
# bad: [c4d198d5183ec7bbf8b53216cfc5ded7ebb0ec0c] KVM: MMU: Fix cleaning
# up the shadow page allocation cache
git-bisect bad c4d198d5183ec7bbf8b53216cfc5ded7ebb0ec0c
# good: [c1158e63dfeb3928e94c768f0a403b3e0e799f70] KVM: MMU: Fix oopses
# with SLUB
git-bisect good c1158e63dfeb3928e94c768f0a403b3e0e799f70
# bad: [1b2232ab879993fcf5b9391c3febf6ab5d78201e] V4L/DVB (5880):
# wm8775/wm8739: Fix memory leak when unloading module
git-bisect bad 1b2232ab879993fcf5b9391c3febf6ab5d78201e
# bad: [efa7e8673c78cc6de2d6c367eb6f50449c57ed90] Merge branch 'release'
# of git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6
git-bisect bad efa7e8673c78cc6de2d6c367eb6f50449c57ed90
# bad: [f4fbfb0dda5577075a049eec7fb7ad38abca1912] Pull vector-domain
# into release branch
git-bisect bad f4fbfb0dda5577075a049eec7fb7ad38abca1912
# good: [e1b30a392835e92581db09a4e8b4b2ad53a0c370] [IA64] Add mapping
# table between irq and vector
git-bisect good e1b30a392835e92581db09a4e8b4b2ad53a0c370
# bad: [e5bd762bda0d9aba8739a35f898479dc12e288a1] [IA64] Enable percpu
# vector domain for IA64_DIG
git-bisect bad e5bd762bda0d9aba8739a35f898479dc12e288a1
# bad: [cd378f18cf73d92bf0b6e1e6b5759b5dd729a9f2] [IA64] Support irq
# migration across domain
git-bisect bad cd378f18cf73d92bf0b6e1e6b5759b5dd729a9f2
# bad: [4994be1b3fe9120c88022ff5c0c33f6312b17adb] [IA64] Add support for
# vector domain
git-bisect bad 4994be1b3fe9120c88022ff5c0c33f6312b17adb

commit 4994be1b3fe9120c88022ff5c0c33f6312b17adb
Author: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date:   Tue Jul 17 21:22:33 2007 +0900

    [IA64] Add support for vector domain
    
    Add fundamental support for multiple vector domain. There still exists
    only one vector domain even with this patch. IRQ migration across
    domain is not supported yet by this patch.
    
    Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
    Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index cf27cfb..e647254 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -354,6 +354,8 @@ iosapic_set_affinity (unsigned int irq, cpumask_t mask)
 
 	irq &= (~IA64_IRQ_REDIRECTED);
 
+	/* IRQ migration across domain is not supported yet */
+	cpus_and(mask, mask, irq_to_domain(irq));
 	if (cpus_empty(mask))
 		return;
 
@@ -663,6 +665,7 @@ get_target_cpu (unsigned int gsi, int irq)
 #ifdef CONFIG_SMP
 	static int cpu = -1;
 	extern int cpe_vector;
+	cpumask_t domain = irq_to_domain(irq);
 
 	/*
 	 * In case of vector shared by multiple RTEs, all RTEs that
@@ -701,7 +704,7 @@ get_target_cpu (unsigned int gsi, int irq)
 			goto skip_numa_setup;
 
 		cpu_mask = node_to_cpumask(iosapic_lists[iosapic_index].node);
-
+		cpus_and(cpu_mask, cpu_mask, domain);
 		for_each_cpu_mask(numa_cpu, cpu_mask) {
 			if (!cpu_online(numa_cpu))
 				cpu_clear(numa_cpu, cpu_mask);
@@ -731,7 +734,7 @@ skip_numa_setup:
 	do {
 		if (++cpu >= NR_CPUS)
 			cpu = 0;
-	} while (!cpu_online(cpu));
+	} while (!cpu_online(cpu) || !cpu_isset(cpu, domain));
 
 	return cpu_physical_id(cpu);
 #else  /* CONFIG_SMP */
@@ -900,7 +903,7 @@ iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
 	switch (int_type) {
 	      case ACPI_INTERRUPT_PMI:
 		irq = vector = iosapic_vector;
-		bind_irq_vector(irq, vector);
+		bind_irq_vector(irq, vector, CPU_MASK_ALL);
 		/*
 		 * since PMI vector is alloc'd by FW(ACPI) not by kernel,
 		 * we need to make sure the vector is available
@@ -917,7 +920,7 @@ iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
 		break;
 	      case ACPI_INTERRUPT_CPEI:
 		irq = vector = IA64_CPE_VECTOR;
-		BUG_ON(bind_irq_vector(irq, vector));
+		BUG_ON(bind_irq_vector(irq, vector, CPU_MASK_ALL));
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		mask = 1;
 		break;
@@ -953,7 +956,7 @@ iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 	unsigned int dest = cpu_physical_id(smp_processor_id());
 
 	irq = vector = isa_irq_to_vector(isa_irq);
-	BUG_ON(bind_irq_vector(irq, vector));
+	BUG_ON(bind_irq_vector(irq, vector, CPU_MASK_ALL));
 	register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
 
 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 072427c..a366763 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -60,6 +60,8 @@ int ia64_last_device_vector = IA64_DEF_LAST_DEVICE_VECTOR;
 void __iomem *ipi_base_addr = ((void __iomem *)
 			       (__IA64_UNCACHED_OFFSET | IA64_IPI_DEFAULT_BASE_ADDR));
 
+static cpumask_t vector_allocation_domain(int cpu);
+
 /*
  * Legacy IRQ to IA-64 vector translation table.
  */
@@ -73,13 +75,20 @@ EXPORT_SYMBOL(isa_irq_to_vector_map);
 DEFINE_SPINLOCK(vector_lock);
 
 struct irq_cfg irq_cfg[NR_IRQS] __read_mostly = {
-	[0 ... NR_IRQS - 1] = { .vector = IRQ_VECTOR_UNASSIGNED }
+	[0 ... NR_IRQS - 1] = {
+		.vector = IRQ_VECTOR_UNASSIGNED,
+		.domain = CPU_MASK_NONE
+	}
 };
 
 DEFINE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq) = {
 	[0 ... IA64_NUM_VECTORS - 1] = IA64_SPURIOUS_INT_VECTOR
 };
 
+static cpumask_t vector_table[IA64_MAX_DEVICE_VECTORS] = {
+	[0 ... IA64_MAX_DEVICE_VECTORS - 1] = CPU_MASK_NONE
+};
+
 static int irq_status[NR_IRQS] = {
 	[0 ... NR_IRQS -1] = IRQ_UNUSED
 };
@@ -111,39 +120,54 @@ static inline int find_unassigned_irq(void)
 	return -ENOSPC;
 }
 
-static inline int find_unassigned_vector(void)
+static inline int find_unassigned_vector(cpumask_t domain)
 {
-	int vector;
+	cpumask_t mask;
+	int pos;
+
+	cpus_and(mask, domain, cpu_online_map);
+	if (cpus_empty(mask))
+		return -EINVAL;
 
-	for (vector = IA64_FIRST_DEVICE_VECTOR;
-	     vector <= IA64_LAST_DEVICE_VECTOR; vector++)
-		if (__get_cpu_var(vector_irq[vector]) = IA64_SPURIOUS_INT_VECTOR)
-			return vector;
+	for (pos = 0; pos < IA64_NUM_DEVICE_VECTORS; pos++) {
+		cpus_and(mask, domain, vector_table[pos]);
+		if (!cpus_empty(mask))
+			continue;
+		return IA64_FIRST_DEVICE_VECTOR + pos;
+	}
 	return -ENOSPC;
 }
 
-static int __bind_irq_vector(int irq, int vector)
+static int __bind_irq_vector(int irq, int vector, cpumask_t domain)
 {
-	int cpu;
+	cpumask_t mask;
+	int cpu, pos;
+	struct irq_cfg *cfg = &irq_cfg[irq];
 
-	if (irq_to_vector(irq) = vector)
+	cpus_and(mask, domain, cpu_online_map);
+	if (cpus_empty(mask))
+		return -EINVAL;
+	if ((cfg->vector = vector) && cpus_equal(cfg->domain, domain))
 		return 0;
-	if (irq_to_vector(irq) != IRQ_VECTOR_UNASSIGNED)
+	if (cfg->vector != IRQ_VECTOR_UNASSIGNED)
 		return -EBUSY;
-	for_each_online_cpu(cpu)
+	for_each_cpu_mask(cpu, mask)
 		per_cpu(vector_irq, cpu)[vector] = irq;
-	irq_cfg[irq].vector = vector;
+	cfg->vector = vector;
+	cfg->domain = domain;
 	irq_status[irq] = IRQ_USED;
+	pos = vector - IA64_FIRST_DEVICE_VECTOR;
+	cpus_or(vector_table[pos], vector_table[pos], domain);
 	return 0;
 }
 
-int bind_irq_vector(int irq, int vector)
+int bind_irq_vector(int irq, int vector, cpumask_t domain)
 {
 	unsigned long flags;
 	int ret;
 
 	spin_lock_irqsave(&vector_lock, flags);
-	ret = __bind_irq_vector(irq, vector);
+	ret = __bind_irq_vector(irq, vector, domain);
 	spin_unlock_irqrestore(&vector_lock, flags);
 	return ret;
 }
@@ -151,16 +175,24 @@ int bind_irq_vector(int irq, int vector)
 static void clear_irq_vector(int irq)
 {
 	unsigned long flags;
-	int vector, cpu;
+	int vector, cpu, pos;
+	cpumask_t mask;
+	cpumask_t domain;
+	struct irq_cfg *cfg = &irq_cfg[irq];
 
 	spin_lock_irqsave(&vector_lock, flags);
 	BUG_ON((unsigned)irq >= NR_IRQS);
-	BUG_ON(irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED);
-	vector = irq_cfg[irq].vector;
-	for_each_online_cpu(cpu)
+	BUG_ON(cfg->vector = IRQ_VECTOR_UNASSIGNED);
+	vector = cfg->vector;
+	domain = cfg->domain;
+	cpus_and(mask, cfg->domain, cpu_online_map);
+	for_each_cpu_mask(cpu, mask)
 		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
-	irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED;
+	cfg->vector = IRQ_VECTOR_UNASSIGNED;
+	cfg->domain = CPU_MASK_NONE;
 	irq_status[irq] = IRQ_UNUSED;
+	pos = vector - IA64_FIRST_DEVICE_VECTOR;
+	cpus_andnot(vector_table[pos], vector_table[pos], domain);
 	spin_unlock_irqrestore(&vector_lock, flags);
 }
 
@@ -168,18 +200,26 @@ int
 assign_irq_vector (int irq)
 {
 	unsigned long flags;
-	int vector = -ENOSPC;
+	int vector, cpu;
+	cpumask_t domain;
+
+	vector = -ENOSPC;
 
+	spin_lock_irqsave(&vector_lock, flags);
 	if (irq < 0) {
 		goto out;
 	}
-	spin_lock_irqsave(&vector_lock, flags);
-	vector = find_unassigned_vector();
+	for_each_online_cpu(cpu) {
+		domain = vector_allocation_domain(cpu);
+		vector = find_unassigned_vector(domain);
+		if (vector >= 0)
+			break;
+	}
 	if (vector < 0)
 		goto out;
-	BUG_ON(__bind_irq_vector(irq, vector));
-	spin_unlock_irqrestore(&vector_lock, flags);
+	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
+	spin_unlock_irqrestore(&vector_lock, flags);
 	return vector;
 }
 
@@ -198,7 +238,7 @@ reserve_irq_vector (int vector)
 	if (vector < IA64_FIRST_DEVICE_VECTOR ||
 	    vector > IA64_LAST_DEVICE_VECTOR)
 		return -EINVAL;
-	return !!bind_irq_vector(vector, vector);
+	return !!bind_irq_vector(vector, vector, CPU_MASK_ALL);
 }
 
 /*
@@ -214,11 +254,19 @@ void __setup_vector_irq(int cpu)
 		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
 	/* Mark the inuse vectors */
 	for (irq = 0; irq < NR_IRQS; ++irq) {
-		if ((vector = irq_to_vector(irq)) != IRQ_VECTOR_UNASSIGNED)
-			per_cpu(vector_irq, cpu)[vector] = irq;
+		if (!cpu_isset(cpu, irq_cfg[irq].domain))
+			continue;
+		vector = irq_to_vector(irq);
+		per_cpu(vector_irq, cpu)[vector] = irq;
 	}
 }
 
+static cpumask_t vector_allocation_domain(int cpu)
+{
+	return CPU_MASK_ALL;
+}
+
+
 void destroy_and_reserve_irq(unsigned int irq)
 {
 	dynamic_irq_cleanup(irq);
@@ -233,17 +281,23 @@ void destroy_and_reserve_irq(unsigned int irq)
 int create_irq(void)
 {
 	unsigned long flags;
-	int irq, vector;
+	int irq, vector, cpu;
+	cpumask_t domain;
 
-	irq = -ENOSPC;
+	irq = vector = -ENOSPC;
 	spin_lock_irqsave(&vector_lock, flags);
-	vector = find_unassigned_vector();
+	for_each_online_cpu(cpu) {
+		domain = vector_allocation_domain(cpu);
+		vector = find_unassigned_vector(domain);
+		if (vector >= 0)
+			break;
+	}
 	if (vector < 0)
 		goto out;
 	irq = find_unassigned_irq();
 	if (irq < 0)
 		goto out;
-	BUG_ON(__bind_irq_vector(irq, vector));
+	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
 	spin_unlock_irqrestore(&vector_lock, flags);
 	if (irq >= 0)
@@ -434,7 +488,7 @@ register_percpu_irq (ia64_vector vec, struct irqaction *action)
 	unsigned int irq;
 
 	irq = vec;
-	BUG_ON(bind_irq_vector(irq, vec));
+	BUG_ON(bind_irq_vector(irq, vec, CPU_MASK_ALL));
 	desc = irq_desc + irq;
 	desc->status |= IRQ_PER_CPU;
 	desc->chip = &irq_type_ia64_lsapic;
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index c81080d..1d22670 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -52,6 +52,11 @@ static void ia64_set_msi_irq_affinity(unsigned int irq, cpumask_t cpu_mask)
 	struct msi_msg msg;
 	u32 addr;
 
+	/* IRQ migration across domain is not supported yet */
+	cpus_and(cpu_mask, cpu_mask, irq_to_domain(irq));
+	if (cpus_empty(cpu_mask))
+		return;
+
 	read_msi_msg(irq, &msg);
 
 	addr = msg.address_lo;
@@ -69,13 +74,15 @@ int ia64_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 	struct msi_msg	msg;
 	unsigned long	dest_phys_id;
 	int	irq, vector;
+	cpumask_t mask;
 
 	irq = create_irq();
 	if (irq < 0)
 		return irq;
 
 	set_irq_msi(irq, desc);
-	dest_phys_id = cpu_physical_id(first_cpu(cpu_online_map));
+	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
+	dest_phys_id = cpu_physical_id(first_cpu(mask));
 	vector = irq_to_vector(irq);
 
 	msg.address_hi = 0;
diff --git a/include/asm-ia64/hw_irq.h b/include/asm-ia64/hw_irq.h
index 4eff7ff..97ea390 100644
--- a/include/asm-ia64/hw_irq.h
+++ b/include/asm-ia64/hw_irq.h
@@ -92,14 +92,16 @@ extern __u8 isa_irq_to_vector_map[16];
 
 struct irq_cfg {
 	ia64_vector vector;
+	cpumask_t domain;
 };
 extern spinlock_t vector_lock;
 extern struct irq_cfg irq_cfg[NR_IRQS];
+#define irq_to_domain(x)	irq_cfg[(x)].domain
 DECLARE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq);
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
-extern int bind_irq_vector(int irq, int vector);
+extern int bind_irq_vector(int irq, int vector, cpumask_t domain);
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
 extern void free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
diff --git a/include/asm-ia64/irq.h b/include/asm-ia64/irq.h
index 6722161..35b360b 100644
--- a/include/asm-ia64/irq.h
+++ b/include/asm-ia64/irq.h
@@ -14,8 +14,13 @@
 #include <linux/types.h>
 #include <linux/cpumask.h>
 
-#define NR_IRQS		256
-#define NR_IRQ_VECTORS	NR_IRQS
+#define NR_VECTORS	256
+
+#if (NR_VECTORS + 32 * NR_CPUS) < 1024
+#define NR_IRQS (NR_VECTORS + 32 * NR_CPUS)
+#else
+#define NR_IRQS 1024
+#endif
 
 static __inline__ int
 irq_canonicalize (int irq)

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

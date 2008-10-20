From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:23 +0000
Subject: [PATCH 04/35] x86 smp: modify send_IPI_mask interface to accept cpumask_t pointers
Message-Id: <20081020170320.150294000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

  * Change genapic interfaces to accept cpumask_t pointers where possible.

  * Modify external callers to use cpumask_t pointers in function calls.

  * Create new send_IPI_mask_allbutself which is the same as the
    send_IPI_mask functions but removes smp_processor_id() from list.
    This removes another common need for a temporary cpumask_t variable.

  * Functions that used a temp cpumask_t variable for:

	cpumask_t allbutme = cpu_online_map;

	cpu_clear(smp_processor_id(), allbutme);
	if (!cpus_empty(allbutme))
		...

    become:

	if (!cpus_equal(cpu_online_map, cpumask_of_cpu(cpu)))
		...

  * Other minor code optimizations (like using cpus_clear instead of
    CPU_MASK_NONE, etc.)


Applies to linux-2.6.tip/master.

Signed-off-by: Mike Travis <travis@sgi.com>
Acked-by: Rusty Russell <rusty@rustcorp.com.au>
---
 arch/x86/kernel/apic.c                   |    2 
 arch/x86/kernel/crash.c                  |    5 -
 arch/x86/kernel/genapic_flat_64.c        |   76 +++++++++++++------
 arch/x86/kernel/genx2apic_cluster.c      |   60 ++++++++++-----
 arch/x86/kernel/genx2apic_phys.c         |   54 +++++++++-----
 arch/x86/kernel/genx2apic_uv_x.c         |   43 ++++++-----
 arch/x86/kernel/io_apic.c                |  118 ++++++++++++++-----------------
 arch/x86/kernel/ipi.c                    |   26 ++++--
 arch/x86/kernel/smp.c                    |    8 +-
 arch/x86/kernel/tlb_32.c                 |    2 
 arch/x86/kernel/tlb_64.c                 |    2 
 arch/x86/mach-generic/bigsmp.c           |    5 -
 arch/x86/mach-generic/es7000.c           |    5 -
 arch/x86/mach-generic/numaq.c            |    5 -
 arch/x86/mach-generic/summit.c           |    5 -
 arch/x86/xen/smp.c                       |   17 ++--
 include/asm-x86/bigsmp/apic.h            |   14 +--
 include/asm-x86/bigsmp/ipi.h             |    9 +-
 include/asm-x86/es7000/apic.h            |   18 ++--
 include/asm-x86/es7000/ipi.h             |    9 +-
 include/asm-x86/genapic_32.h             |   11 +-
 include/asm-x86/genapic_64.h             |   11 +-
 include/asm-x86/ipi.h                    |   21 ++++-
 include/asm-x86/mach-default/mach_apic.h |   17 ++--
 include/asm-x86/mach-default/mach_ipi.h  |   18 ++--
 include/asm-x86/numaq/apic.h             |    4 -
 include/asm-x86/numaq/ipi.h              |    9 +-
 include/asm-x86/smp.h                    |    6 -
 include/asm-x86/summit/apic.h            |   12 +--
 include/asm-x86/summit/ipi.h             |    9 +-
 30 files changed, 350 insertions(+), 251 deletions(-)

--- linux-2.6.28.orig/arch/x86/kernel/apic.c
+++ linux-2.6.28/arch/x86/kernel/apic.c
@@ -456,7 +456,7 @@ static void lapic_timer_setup(enum clock
 static void lapic_timer_broadcast(cpumask_t mask)
 {
 #ifdef CONFIG_SMP
-	send_IPI_mask(mask, LOCAL_TIMER_VECTOR);
+	send_IPI_mask(&mask, LOCAL_TIMER_VECTOR);
 #endif
 }
 
--- linux-2.6.28.orig/arch/x86/kernel/crash.c
+++ linux-2.6.28/arch/x86/kernel/crash.c
@@ -77,10 +77,7 @@ static int crash_nmi_callback(struct not
 
 static void smp_send_nmi_allbutself(void)
 {
-	cpumask_t mask = cpu_online_map;
-	cpu_clear(safe_smp_processor_id(), mask);
-	if (!cpus_empty(mask))
-		send_IPI_mask(mask, NMI_VECTOR);
+	send_IPI_allbutself(NMI_VECTOR);
 }
 
 static struct notifier_block crash_nmi_nb = {
--- linux-2.6.28.orig/arch/x86/kernel/genapic_flat_64.c
+++ linux-2.6.28/arch/x86/kernel/genapic_flat_64.c
@@ -30,12 +30,12 @@ static int __init flat_acpi_madt_oem_che
 	return 1;
 }
 
-static cpumask_t flat_target_cpus(void)
+static const cpumask_t *flat_target_cpus(void)
 {
-	return cpu_online_map;
+	return &cpu_online_map;
 }
 
-static cpumask_t flat_vector_allocation_domain(int cpu)
+static void flat_vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
 	/* Careful. Some cpus do not strictly honor the set of cpus
 	 * specified in the interrupt destination when using lowest
@@ -45,8 +45,7 @@ static cpumask_t flat_vector_allocation_
 	 * deliver interrupts to the wrong hyperthread when only one
 	 * hyperthread was specified in the interrupt desitination.
 	 */
-	cpumask_t domain = { { [0] = APIC_ALL_CPUS, } };
-	return domain;
+	*retmask = (cpumask_t) { {[0] = APIC_ALL_CPUS, } };
 }
 
 /*
@@ -69,9 +68,8 @@ static void flat_init_apic_ldr(void)
 	apic_write(APIC_LDR, val);
 }
 
-static void flat_send_IPI_mask(cpumask_t cpumask, int vector)
+static inline void _flat_send_IPI_mask(unsigned long mask, int vector)
 {
-	unsigned long mask = cpus_addr(cpumask)[0];
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -79,20 +77,40 @@ static void flat_send_IPI_mask(cpumask_t
 	local_irq_restore(flags);
 }
 
+static void flat_send_IPI_mask(const cpumask_t *cpumask, int vector)
+{
+	unsigned long mask = cpus_addr(*cpumask)[0];
+
+	_flat_send_IPI_mask(mask, vector);
+}
+
+static void flat_send_IPI_mask_allbutself(const cpumask_t *cpumask, int vector)
+{
+	unsigned long mask = cpus_addr(*cpumask)[0];
+	int cpu = smp_processor_id();
+
+	if (cpu < BITS_PER_LONG)
+		clear_bit(cpu, &mask);
+	_flat_send_IPI_mask(mask, vector);
+}
+
 static void flat_send_IPI_allbutself(int vector)
 {
+	int cpu = smp_processor_id();
 #ifdef	CONFIG_HOTPLUG_CPU
 	int hotplug = 1;
 #else
 	int hotplug = 0;
 #endif
 	if (hotplug || vector = NMI_VECTOR) {
-		cpumask_t allbutme = cpu_online_map;
+		if (!cpus_equal(cpu_online_map, cpumask_of_cpu(cpu))) {
+			unsigned long mask = cpus_addr(cpu_online_map)[0];
 
-		cpu_clear(smp_processor_id(), allbutme);
+			if (cpu < BITS_PER_LONG)
+				clear_bit(cpu, &mask);
 
-		if (!cpus_empty(allbutme))
-			flat_send_IPI_mask(allbutme, vector);
+			_flat_send_IPI_mask(mask, vector);
+		}
 	} else if (num_online_cpus() > 1) {
 		__send_IPI_shortcut(APIC_DEST_ALLBUT, vector,APIC_DEST_LOGICAL);
 	}
@@ -101,7 +119,7 @@ static void flat_send_IPI_allbutself(int
 static void flat_send_IPI_all(int vector)
 {
 	if (vector = NMI_VECTOR)
-		flat_send_IPI_mask(cpu_online_map, vector);
+		flat_send_IPI_mask(&cpu_online_map, vector);
 	else
 		__send_IPI_shortcut(APIC_DEST_ALLINC, vector, APIC_DEST_LOGICAL);
 }
@@ -135,9 +153,9 @@ static int flat_apic_id_registered(void)
 	return physid_isset(read_xapic_id(), phys_cpu_present_map);
 }
 
-static unsigned int flat_cpu_mask_to_apicid(cpumask_t cpumask)
+static unsigned int flat_cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
-	return cpus_addr(cpumask)[0] & APIC_ALL_CPUS;
+	return cpus_addr(*cpumask)[0] & APIC_ALL_CPUS;
 }
 
 static unsigned int phys_pkg_id(int index_msb)
@@ -157,6 +175,7 @@ struct genapic apic_flat =  {
 	.send_IPI_all = flat_send_IPI_all,
 	.send_IPI_allbutself = flat_send_IPI_allbutself,
 	.send_IPI_mask = flat_send_IPI_mask,
+	.send_IPI_mask_allbutself = flat_send_IPI_mask_allbutself,
 	.send_IPI_self = apic_send_IPI_self,
 	.cpu_mask_to_apicid = flat_cpu_mask_to_apicid,
 	.phys_pkg_id = phys_pkg_id,
@@ -188,35 +207,39 @@ static int __init physflat_acpi_madt_oem
 	return 0;
 }
 
-static cpumask_t physflat_target_cpus(void)
+static const cpumask_t *physflat_target_cpus(void)
 {
-	return cpu_online_map;
+	return &cpu_online_map;
 }
 
-static cpumask_t physflat_vector_allocation_domain(int cpu)
+static void physflat_vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
-	return cpumask_of_cpu(cpu);
+	cpus_clear(*retmask);
+	cpu_set(cpu, *retmask);
 }
 
-static void physflat_send_IPI_mask(cpumask_t cpumask, int vector)
+static void physflat_send_IPI_mask(const cpumask_t *cpumask, int vector)
 {
 	send_IPI_mask_sequence(cpumask, vector);
 }
 
-static void physflat_send_IPI_allbutself(int vector)
+static void physflat_send_IPI_mask_allbutself(const cpumask_t *cpumask,
+					      int vector)
 {
-	cpumask_t allbutme = cpu_online_map;
+	send_IPI_mask_allbutself(cpumask, vector);
+}
 
-	cpu_clear(smp_processor_id(), allbutme);
-	physflat_send_IPI_mask(allbutme, vector);
+static void physflat_send_IPI_allbutself(int vector)
+{
+	send_IPI_mask_allbutself(&cpu_online_map, vector);
 }
 
 static void physflat_send_IPI_all(int vector)
 {
-	physflat_send_IPI_mask(cpu_online_map, vector);
+	physflat_send_IPI_mask(&cpu_online_map, vector);
 }
 
-static unsigned int physflat_cpu_mask_to_apicid(cpumask_t cpumask)
+static unsigned int physflat_cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	int cpu;
 
@@ -224,7 +247,7 @@ static unsigned int physflat_cpu_mask_to
 	 * We're using fixed IRQ delivery, can only return one phys APIC ID.
 	 * May as well be the first.
 	 */
-	cpu = first_cpu(cpumask);
+	cpu = first_cpu(*cpumask);
 	if ((unsigned)cpu < nr_cpu_ids)
 		return per_cpu(x86_cpu_to_apicid, cpu);
 	else
@@ -243,6 +266,7 @@ struct genapic apic_physflat =  {
 	.send_IPI_all = physflat_send_IPI_all,
 	.send_IPI_allbutself = physflat_send_IPI_allbutself,
 	.send_IPI_mask = physflat_send_IPI_mask,
+	.send_IPI_mask_allbutself = physflat_send_IPI_mask_allbutself,
 	.send_IPI_self = apic_send_IPI_self,
 	.cpu_mask_to_apicid = physflat_cpu_mask_to_apicid,
 	.phys_pkg_id = phys_pkg_id,
--- linux-2.6.28.orig/arch/x86/kernel/genx2apic_cluster.c
+++ linux-2.6.28/arch/x86/kernel/genx2apic_cluster.c
@@ -22,19 +22,18 @@ static int __init x2apic_acpi_madt_oem_c
 
 /* Start with all IRQs pointing to boot CPU.  IRQ balancing will shift them. */
 
-static cpumask_t x2apic_target_cpus(void)
+static const cpumask_t *x2apic_target_cpus(void)
 {
-	return cpumask_of_cpu(0);
+	return &cpumask_of_cpu(0);
 }
 
 /*
  * for now each logical cpu is in its own vector allocation domain.
  */
-static cpumask_t x2apic_vector_allocation_domain(int cpu)
+static void x2apic_vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
-	cpumask_t domain = CPU_MASK_NONE;
-	cpu_set(cpu, domain);
-	return domain;
+	cpus_clear(*retmask);
+	cpu_set(cpu, *retmask);
 }
 
 static void __x2apic_send_IPI_dest(unsigned int apicid, int vector,
@@ -56,32 +55,52 @@ static void __x2apic_send_IPI_dest(unsig
  * at once. We have 16 cpu's in a cluster. This will minimize IPI register
  * writes.
  */
-static void x2apic_send_IPI_mask(cpumask_t mask, int vector)
+static void x2apic_send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	unsigned long flags;
 	unsigned long query_cpu;
 
 	local_irq_save(flags);
-	for_each_cpu_mask(query_cpu, mask) {
-		__x2apic_send_IPI_dest(per_cpu(x86_cpu_to_logical_apicid, query_cpu),
-				       vector, APIC_DEST_LOGICAL);
-	}
+	for_each_cpu_mask_nr(query_cpu, *mask)
+		__x2apic_send_IPI_dest(
+			per_cpu(x86_cpu_to_logical_apicid, query_cpu),
+			vector, APIC_DEST_LOGICAL);
 	local_irq_restore(flags);
 }
 
-static void x2apic_send_IPI_allbutself(int vector)
+static void x2apic_send_IPI_mask_allbutself(const cpumask_t *mask, int vector)
 {
-	cpumask_t mask = cpu_online_map;
+	unsigned long flags;
+	unsigned long query_cpu;
+	unsigned long this_cpu = smp_processor_id();
 
-	cpu_clear(smp_processor_id(), mask);
+	local_irq_save(flags);
+	for_each_cpu_mask_nr(query_cpu, *mask)
+		if (query_cpu != this_cpu)
+			__x2apic_send_IPI_dest(
+				per_cpu(x86_cpu_to_logical_apicid, query_cpu),
+				vector, APIC_DEST_LOGICAL);
+	local_irq_restore(flags);
+}
 
-	if (!cpus_empty(mask))
-		x2apic_send_IPI_mask(mask, vector);
+static void x2apic_send_IPI_allbutself(int vector)
+{
+	unsigned long flags;
+	unsigned long query_cpu;
+	unsigned long this_cpu = smp_processor_id();
+
+	local_irq_save(flags);
+	for_each_online_cpu(query_cpu)
+		if (query_cpu != this_cpu)
+			__x2apic_send_IPI_dest(
+				per_cpu(x86_cpu_to_logical_apicid, query_cpu),
+				vector, APIC_DEST_LOGICAL);
+	local_irq_restore(flags);
 }
 
 static void x2apic_send_IPI_all(int vector)
 {
-	x2apic_send_IPI_mask(cpu_online_map, vector);
+	x2apic_send_IPI_mask(&cpu_online_map, vector);
 }
 
 static int x2apic_apic_id_registered(void)
@@ -89,7 +108,7 @@ static int x2apic_apic_id_registered(voi
 	return 1;
 }
 
-static unsigned int x2apic_cpu_mask_to_apicid(cpumask_t cpumask)
+static unsigned int x2apic_cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	int cpu;
 
@@ -97,8 +116,8 @@ static unsigned int x2apic_cpu_mask_to_a
 	 * We're using fixed IRQ delivery, can only return one phys APIC ID.
 	 * May as well be the first.
 	 */
-	cpu = first_cpu(cpumask);
-	if ((unsigned)cpu < NR_CPUS)
+	cpu = first_cpu(*cpumask);
+	if ((unsigned)cpu < nr_cpu_ids)
 		return per_cpu(x86_cpu_to_logical_apicid, cpu);
 	else
 		return BAD_APICID;
@@ -150,6 +169,7 @@ struct genapic apic_x2apic_cluster = {
 	.send_IPI_all = x2apic_send_IPI_all,
 	.send_IPI_allbutself = x2apic_send_IPI_allbutself,
 	.send_IPI_mask = x2apic_send_IPI_mask,
+	.send_IPI_mask_allbutself = x2apic_send_IPI_mask_allbutself,
 	.send_IPI_self = x2apic_send_IPI_self,
 	.cpu_mask_to_apicid = x2apic_cpu_mask_to_apicid,
 	.phys_pkg_id = phys_pkg_id,
--- linux-2.6.28.orig/arch/x86/kernel/genx2apic_phys.c
+++ linux-2.6.28/arch/x86/kernel/genx2apic_phys.c
@@ -29,16 +29,15 @@ static int __init x2apic_acpi_madt_oem_c
 
 /* Start with all IRQs pointing to boot CPU.  IRQ balancing will shift them. */
 
-static cpumask_t x2apic_target_cpus(void)
+static const cpumask_t *x2apic_target_cpus(void)
 {
-	return cpumask_of_cpu(0);
+	return &cpumask_of_cpu(0);
 }
 
-static cpumask_t x2apic_vector_allocation_domain(int cpu)
+static void x2apic_vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
-	cpumask_t domain = CPU_MASK_NONE;
-	cpu_set(cpu, domain);
-	return domain;
+	cpus_clear(*retmask);
+	cpu_set(cpu, *retmask);
 }
 
 static void __x2apic_send_IPI_dest(unsigned int apicid, int vector,
@@ -54,32 +53,52 @@ static void __x2apic_send_IPI_dest(unsig
 	x2apic_icr_write(cfg, apicid);
 }
 
-static void x2apic_send_IPI_mask(cpumask_t mask, int vector)
+static void x2apic_send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	unsigned long flags;
 	unsigned long query_cpu;
 
 	local_irq_save(flags);
-	for_each_cpu_mask(query_cpu, mask) {
+	for_each_cpu_mask_nr(query_cpu, *mask) {
 		__x2apic_send_IPI_dest(per_cpu(x86_cpu_to_apicid, query_cpu),
 				       vector, APIC_DEST_PHYSICAL);
 	}
 	local_irq_restore(flags);
 }
 
-static void x2apic_send_IPI_allbutself(int vector)
+static void x2apic_send_IPI_mask_allbutself(const cpumask_t *mask, int vector)
 {
-	cpumask_t mask = cpu_online_map;
+	unsigned long flags;
+	unsigned long query_cpu;
+	unsigned long this_cpu = smp_processor_id();
+
+	local_irq_save(flags);
+	for_each_cpu_mask_nr(query_cpu, *mask) {
+		if (query_cpu != this_cpu)
+			__x2apic_send_IPI_dest(
+				per_cpu(x86_cpu_to_apicid, query_cpu),
+				vector, APIC_DEST_PHYSICAL);
+	}
+	local_irq_restore(flags);
+}
 
-	cpu_clear(smp_processor_id(), mask);
+static void x2apic_send_IPI_allbutself(int vector)
+{
+	unsigned long flags;
+	unsigned long query_cpu;
+	unsigned long this_cpu = smp_processor_id();
 
-	if (!cpus_empty(mask))
-		x2apic_send_IPI_mask(mask, vector);
+	local_irq_save(flags);
+	for_each_online_cpu(query_cpu)
+		if (query_cpu != this_cpu)
+		__x2apic_send_IPI_dest(per_cpu(x86_cpu_to_apicid, query_cpu),
+				       vector, APIC_DEST_PHYSICAL);
+	local_irq_restore(flags);
 }
 
 static void x2apic_send_IPI_all(int vector)
 {
-	x2apic_send_IPI_mask(cpu_online_map, vector);
+	x2apic_send_IPI_mask(&cpu_online_map, vector);
 }
 
 static int x2apic_apic_id_registered(void)
@@ -87,7 +106,7 @@ static int x2apic_apic_id_registered(voi
 	return 1;
 }
 
-static unsigned int x2apic_cpu_mask_to_apicid(cpumask_t cpumask)
+static unsigned int x2apic_cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	int cpu;
 
@@ -95,8 +114,8 @@ static unsigned int x2apic_cpu_mask_to_a
 	 * We're using fixed IRQ delivery, can only return one phys APIC ID.
 	 * May as well be the first.
 	 */
-	cpu = first_cpu(cpumask);
-	if ((unsigned)cpu < NR_CPUS)
+	cpu = first_cpu(*cpumask);
+	if ((unsigned)cpu < nr_cpu_ids)
 		return per_cpu(x86_cpu_to_apicid, cpu);
 	else
 		return BAD_APICID;
@@ -145,6 +164,7 @@ struct genapic apic_x2apic_phys = {
 	.send_IPI_all = x2apic_send_IPI_all,
 	.send_IPI_allbutself = x2apic_send_IPI_allbutself,
 	.send_IPI_mask = x2apic_send_IPI_mask,
+	.send_IPI_mask_allbutself = x2apic_send_IPI_mask_allbutself,
 	.send_IPI_self = x2apic_send_IPI_self,
 	.cpu_mask_to_apicid = x2apic_cpu_mask_to_apicid,
 	.phys_pkg_id = phys_pkg_id,
--- linux-2.6.28.orig/arch/x86/kernel/genx2apic_uv_x.c
+++ linux-2.6.28/arch/x86/kernel/genx2apic_uv_x.c
@@ -76,16 +76,15 @@ EXPORT_SYMBOL(sn_rtc_cycles_per_second);
 
 /* Start with all IRQs pointing to boot CPU.  IRQ balancing will shift them. */
 
-static cpumask_t uv_target_cpus(void)
+static const cpumask_t *uv_target_cpus(void)
 {
-	return cpumask_of_cpu(0);
+	return &cpumask_of_cpu(0);
 }
 
-static cpumask_t uv_vector_allocation_domain(int cpu)
+static void uv_vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
-	cpumask_t domain = CPU_MASK_NONE;
-	cpu_set(cpu, domain);
-	return domain;
+	cpus_clear(*retmask);
+	cpu_set(cpu, *retmask);
 }
 
 int uv_wakeup_secondary(int phys_apicid, unsigned int start_rip)
@@ -124,28 +123,37 @@ static void uv_send_IPI_one(int cpu, int
 	uv_write_global_mmr64(pnode, UVH_IPI_INT, val);
 }
 
-static void uv_send_IPI_mask(cpumask_t mask, int vector)
+static void uv_send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	unsigned int cpu;
 
-	for_each_possible_cpu(cpu)
-		if (cpu_isset(cpu, mask))
+	for_each_cpu_mask_nr(cpu, *mask)
+		uv_send_IPI_one(cpu, vector);
+}
+
+static void uv_send_IPI_mask_allbutself(const cpumask_t *mask, int vector)
+{
+	unsigned int cpu;
+	unsigned int this_cpu = smp_processor_id();
+
+	for_each_cpu_mask_nr(cpu, *mask)
+		if (cpu != this_cpu)
 			uv_send_IPI_one(cpu, vector);
 }
 
 static void uv_send_IPI_allbutself(int vector)
 {
-	cpumask_t mask = cpu_online_map;
-
-	cpu_clear(smp_processor_id(), mask);
+	unsigned int cpu;
+	unsigned int this_cpu = smp_processor_id();
 
-	if (!cpus_empty(mask))
-		uv_send_IPI_mask(mask, vector);
+	for_each_online_cpu(cpu)
+		if (cpu != this_cpu)
+			uv_send_IPI_one(cpu, vector);
 }
 
 static void uv_send_IPI_all(int vector)
 {
-	uv_send_IPI_mask(cpu_online_map, vector);
+	uv_send_IPI_mask(&cpu_online_map, vector);
 }
 
 static int uv_apic_id_registered(void)
@@ -157,7 +165,7 @@ static void uv_init_apic_ldr(void)
 {
 }
 
-static unsigned int uv_cpu_mask_to_apicid(cpumask_t cpumask)
+static unsigned int uv_cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	int cpu;
 
@@ -165,7 +173,7 @@ static unsigned int uv_cpu_mask_to_apici
 	 * We're using fixed IRQ delivery, can only return one phys APIC ID.
 	 * May as well be the first.
 	 */
-	cpu = first_cpu(cpumask);
+	cpu = first_cpu(*cpumask);
 	if ((unsigned)cpu < nr_cpu_ids)
 		return per_cpu(x86_cpu_to_apicid, cpu);
 	else
@@ -219,6 +227,7 @@ struct genapic apic_x2apic_uv_x = {
 	.send_IPI_all = uv_send_IPI_all,
 	.send_IPI_allbutself = uv_send_IPI_allbutself,
 	.send_IPI_mask = uv_send_IPI_mask,
+	.send_IPI_mask_allbutself = uv_send_IPI_mask_allbutself,
 	.send_IPI_self = uv_send_IPI_self,
 	.cpu_mask_to_apicid = uv_cpu_mask_to_apicid,
 	.phys_pkg_id = phys_pkg_id,
--- linux-2.6.28.orig/arch/x86/kernel/io_apic.c
+++ linux-2.6.28/arch/x86/kernel/io_apic.c
@@ -531,7 +531,7 @@ static void __target_IO_APIC_irq(unsigne
 	}
 }
 
-static int assign_irq_vector(int irq, cpumask_t mask);
+static int assign_irq_vector(int irq, const cpumask_t *mask);
 
 static void set_ioapic_affinity_irq(unsigned int irq, cpumask_t mask)
 {
@@ -545,12 +545,12 @@ static void set_ioapic_affinity_irq(unsi
 	if (cpus_empty(tmp))
 		return;
 
-	cfg = irq_cfg(irq);
-	if (assign_irq_vector(irq, mask))
+	if (assign_irq_vector(irq, &mask))
 		return;
 
+	cfg = irq_cfg(irq);
 	cpus_and(tmp, cfg->domain, mask);
-	dest = cpu_mask_to_apicid(tmp);
+	dest = cpu_mask_to_apicid(&tmp);
 	/*
 	 * Only the high 8 bits are valid.
 	 */
@@ -1206,7 +1206,7 @@ void unlock_vector_lock(void)
 	spin_unlock(&vector_lock);
 }
 
-static int __assign_irq_vector(int irq, cpumask_t mask)
+static int __assign_irq_vector(int irq, const cpumask_t *mask)
 {
 	/*
 	 * NOTE! The local APIC isn't very good at handling
@@ -1223,37 +1223,33 @@ static int __assign_irq_vector(int irq, 
 	unsigned int old_vector;
 	int cpu;
 	struct irq_cfg *cfg;
+	cpumask_t tmp_mask;
 
 	cfg = irq_cfg(irq);
-
-	/* Only try and allocate irqs on cpus that are present */
-	cpus_and(mask, mask, cpu_online_map);
-
 	if ((cfg->move_in_progress) || cfg->move_cleanup_count)
 		return -EBUSY;
 
 	old_vector = cfg->vector;
 	if (old_vector) {
-		cpumask_t tmp;
-		cpus_and(tmp, cfg->domain, mask);
-		if (!cpus_empty(tmp))
+		cpus_and(tmp_mask, *mask, cpu_online_map);
+		cpus_and(tmp_mask, cfg->domain, tmp_mask);
+		if (!cpus_empty(tmp_mask))
 			return 0;
 	}
 
-	for_each_cpu_mask_nr(cpu, mask) {
-		cpumask_t domain, new_mask;
+	/* Only try and allocate irqs on cpus that are present */
+	for_each_cpu_mask_and(cpu, *mask, cpu_online_map) {
 		int new_cpu;
 		int vector, offset;
 
-		domain = vector_allocation_domain(cpu);
-		cpus_and(new_mask, domain, cpu_online_map);
+		vector_allocation_domain(cpu, &tmp_mask);
 
 		vector = current_vector;
 		offset = current_offset;
 next:
 		vector += 8;
 		if (vector >= first_system_vector) {
-			/* If we run out of vectors on large boxen, must share them. */
+			/* If out of vectors on large boxen, must share them. */
 			offset = (offset + 1) % 8;
 			vector = FIRST_DEVICE_VECTOR + offset;
 		}
@@ -1266,7 +1262,7 @@ next:
 		if (vector = SYSCALL_VECTOR)
 			goto next;
 #endif
-		for_each_cpu_mask_nr(new_cpu, new_mask)
+		for_each_cpu_mask_and(new_cpu, tmp_mask, cpu_online_map)
 			if (per_cpu(vector_irq, new_cpu)[vector] != -1)
 				goto next;
 		/* Found one! */
@@ -1276,16 +1272,16 @@ next:
 			cfg->move_in_progress = 1;
 			cfg->old_domain = cfg->domain;
 		}
-		for_each_cpu_mask_nr(new_cpu, new_mask)
+		for_each_cpu_mask_and(new_cpu, tmp_mask, cpu_online_map)
 			per_cpu(vector_irq, new_cpu)[vector] = irq;
 		cfg->vector = vector;
-		cfg->domain = domain;
+		cfg->domain = tmp_mask;
 		return 0;
 	}
 	return -ENOSPC;
 }
 
-static int assign_irq_vector(int irq, cpumask_t mask)
+static int assign_irq_vector(int irq, const cpumask_t *mask)
 {
 	int err;
 	unsigned long flags;
@@ -1485,8 +1481,8 @@ static void setup_IO_APIC_irq(int apic, 
 
 	cfg = irq_cfg(irq);
 
-	mask = TARGET_CPUS;
-	if (assign_irq_vector(irq, mask))
+	mask = *TARGET_CPUS;
+	if (assign_irq_vector(irq, &mask))
 		return;
 
 	cpus_and(mask, cfg->domain, mask);
@@ -1499,7 +1495,7 @@ static void setup_IO_APIC_irq(int apic, 
 
 
 	if (setup_ioapic_entry(mp_ioapics[apic].mp_apicid, irq, &entry,
-			       cpu_mask_to_apicid(mask), trigger, polarity,
+			       cpu_mask_to_apicid(&mask), trigger, polarity,
 			       cfg->vector)) {
 		printk("Failed to setup ioapic entry for ioapic  %d, pin %d\n",
 		       mp_ioapics[apic].mp_apicid, pin);
@@ -2205,7 +2201,7 @@ static int ioapic_retrigger_irq(unsigned
 	unsigned long flags;
 
 	spin_lock_irqsave(&vector_lock, flags);
-	send_IPI_mask(cpumask_of_cpu(first_cpu(cfg->domain)), cfg->vector);
+	send_IPI_mask(&cpumask_of_cpu(first_cpu(cfg->domain)), cfg->vector);
 	spin_unlock_irqrestore(&vector_lock, flags);
 
 	return 1;
@@ -2254,18 +2250,18 @@ static DECLARE_DELAYED_WORK(ir_migration
  * as simple as edge triggered migration and we can do the irq migration
  * with a simple atomic update to IO-APIC RTE.
  */
-static void migrate_ioapic_irq(int irq, cpumask_t mask)
+static void migrate_ioapic_irq(int irq, const cpumask_t *mask)
 {
 	struct irq_cfg *cfg;
 	struct irq_desc *desc;
-	cpumask_t tmp, cleanup_mask;
+	cpumask_t tmpmask;
 	struct irte irte;
 	int modify_ioapic_rte;
 	unsigned int dest;
 	unsigned long flags;
 
-	cpus_and(tmp, mask, cpu_online_map);
-	if (cpus_empty(tmp))
+	cpus_and(tmpmask, *mask, cpu_online_map);
+	if (cpus_empty(tmpmask))
 		return;
 
 	if (get_irte(irq, &irte))
@@ -2275,8 +2271,8 @@ static void migrate_ioapic_irq(int irq, 
 		return;
 
 	cfg = irq_cfg(irq);
-	cpus_and(tmp, cfg->domain, mask);
-	dest = cpu_mask_to_apicid(tmp);
+	cpus_and(tmpmask, cfg->domain, *mask);
+	dest = cpu_mask_to_apicid(&tmpmask);
 
 	desc = irq_to_desc(irq);
 	modify_ioapic_rte = desc->status & IRQ_LEVEL;
@@ -2295,13 +2291,13 @@ static void migrate_ioapic_irq(int irq, 
 	modify_irte(irq, &irte);
 
 	if (cfg->move_in_progress) {
-		cpus_and(cleanup_mask, cfg->old_domain, cpu_online_map);
-		cfg->move_cleanup_count = cpus_weight(cleanup_mask);
-		send_IPI_mask(cleanup_mask, IRQ_MOVE_CLEANUP_VECTOR);
+		cpus_and(tmpmask, cfg->old_domain, cpu_online_map);
+		cfg->move_cleanup_count = cpus_weight(tmpmask);
+		send_IPI_mask(&tmpmask, IRQ_MOVE_CLEANUP_VECTOR);
 		cfg->move_in_progress = 0;
 	}
 
-	desc->affinity = mask;
+	desc->affinity = *mask;
 }
 
 static int migrate_irq_remapped_level(int irq)
@@ -2323,7 +2319,7 @@ static int migrate_irq_remapped_level(in
 	}
 
 	/* everthing is clear. we have right of way */
-	migrate_ioapic_irq(irq, desc->pending_mask);
+	migrate_ioapic_irq(irq, &desc->pending_mask);
 
 	ret = 0;
 	desc->status &= ~IRQ_MOVE_PENDING;
@@ -2371,7 +2367,7 @@ static void set_ir_ioapic_affinity_irq(u
 		return;
 	}
 
-	migrate_ioapic_irq(irq, mask);
+	migrate_ioapic_irq(irq, &mask);
 }
 #endif
 
@@ -2427,7 +2423,7 @@ static void irq_complete_move(unsigned i
 
 		cpus_and(cleanup_mask, cfg->old_domain, cpu_online_map);
 		cfg->move_cleanup_count = cpus_weight(cleanup_mask);
-		send_IPI_mask(cleanup_mask, IRQ_MOVE_CLEANUP_VECTOR);
+		send_IPI_mask(&cleanup_mask, IRQ_MOVE_CLEANUP_VECTOR);
 		cfg->move_in_progress = 0;
 	}
 }
@@ -3132,14 +3128,14 @@ static int msi_compose_msg(struct pci_de
 	unsigned dest;
 	cpumask_t tmp;
 
-	tmp = TARGET_CPUS;
-	err = assign_irq_vector(irq, tmp);
+	tmp = *TARGET_CPUS;
+	err = assign_irq_vector(irq, &tmp);
 	if (err)
 		return err;
 
 	cfg = irq_cfg(irq);
 	cpus_and(tmp, cfg->domain, tmp);
-	dest = cpu_mask_to_apicid(tmp);
+	dest = cpu_mask_to_apicid(&tmp);
 
 #ifdef CONFIG_INTR_REMAP
 	if (irq_remapped(irq)) {
@@ -3205,12 +3201,12 @@ static void set_msi_irq_affinity(unsigne
 	if (cpus_empty(tmp))
 		return;
 
-	if (assign_irq_vector(irq, mask))
+	if (assign_irq_vector(irq, &mask))
 		return;
 
 	cfg = irq_cfg(irq);
 	cpus_and(tmp, cfg->domain, mask);
-	dest = cpu_mask_to_apicid(tmp);
+	dest = cpu_mask_to_apicid(&tmp);
 
 	read_msi_msg(irq, &msg);
 
@@ -3244,12 +3240,12 @@ static void ir_set_msi_irq_affinity(unsi
 	if (get_irte(irq, &irte))
 		return;
 
-	if (assign_irq_vector(irq, mask))
+	if (assign_irq_vector(irq, &mask))
 		return;
 
 	cfg = irq_cfg(irq);
 	cpus_and(tmp, cfg->domain, mask);
-	dest = cpu_mask_to_apicid(tmp);
+	dest = cpu_mask_to_apicid(&tmp);
 
 	irte.vector = cfg->vector;
 	irte.dest_id = IRTE_DEST(dest);
@@ -3267,7 +3263,7 @@ static void ir_set_msi_irq_affinity(unsi
 	if (cfg->move_in_progress) {
 		cpus_and(cleanup_mask, cfg->old_domain, cpu_online_map);
 		cfg->move_cleanup_count = cpus_weight(cleanup_mask);
-		send_IPI_mask(cleanup_mask, IRQ_MOVE_CLEANUP_VECTOR);
+		send_IPI_mask(&cleanup_mask, IRQ_MOVE_CLEANUP_VECTOR);
 		cfg->move_in_progress = 0;
 	}
 
@@ -3486,12 +3482,12 @@ static void dmar_msi_set_affinity(unsign
 	if (cpus_empty(tmp))
 		return;
 
-	if (assign_irq_vector(irq, mask))
+	if (assign_irq_vector(irq, &mask))
 		return;
 
 	cfg = irq_cfg(irq);
 	cpus_and(tmp, cfg->domain, mask);
-	dest = cpu_mask_to_apicid(tmp);
+	dest = cpu_mask_to_apicid(&tmp);
 
 	dmar_msi_read(irq, &msg);
 
@@ -3547,12 +3543,12 @@ static void hpet_msi_set_affinity(unsign
 	if (cpus_empty(tmp))
 		return;
 
-	if (assign_irq_vector(irq, mask))
+	if (assign_irq_vector(irq, &mask))
 		return;
 
 	cfg = irq_cfg(irq);
 	cpus_and(tmp, cfg->domain, mask);
-	dest = cpu_mask_to_apicid(tmp);
+	dest = cpu_mask_to_apicid(&tmp);
 
 	hpet_msi_read(irq, &msg);
 
@@ -3628,12 +3624,12 @@ static void set_ht_irq_affinity(unsigned
 	if (cpus_empty(tmp))
 		return;
 
-	if (assign_irq_vector(irq, mask))
+	if (assign_irq_vector(irq, &mask))
 		return;
 
 	cfg = irq_cfg(irq);
 	cpus_and(tmp, cfg->domain, mask);
-	dest = cpu_mask_to_apicid(tmp);
+	dest = cpu_mask_to_apicid(&tmp);
 
 	target_ht_irq(irq, dest, cfg->vector);
 	desc = irq_to_desc(irq);
@@ -3658,15 +3654,15 @@ int arch_setup_ht_irq(unsigned int irq, 
 	int err;
 	cpumask_t tmp;
 
-	tmp = TARGET_CPUS;
-	err = assign_irq_vector(irq, tmp);
+	tmp = *TARGET_CPUS;
+	err = assign_irq_vector(irq, &tmp);
 	if (!err) {
 		struct ht_irq_msg msg;
 		unsigned dest;
 
 		cfg = irq_cfg(irq);
 		cpus_and(tmp, cfg->domain, tmp);
-		dest = cpu_mask_to_apicid(tmp);
+		dest = cpu_mask_to_apicid(&tmp);
 
 		msg.address_hi = HT_IRQ_HIGH_DEST_ID(dest);
 
@@ -3702,7 +3698,7 @@ int arch_setup_ht_irq(unsigned int irq, 
 int arch_enable_uv_irq(char *irq_name, unsigned int irq, int cpu, int mmr_blade,
 		       unsigned long mmr_offset)
 {
-	const cpumask_t *eligible_cpu = get_cpu_mask(cpu);
+	const cpumask_t *eligible_cpu = &cpumask_of_cpu(cpu);
 	struct irq_cfg *cfg;
 	int mmr_pnode;
 	unsigned long mmr_value;
@@ -3710,8 +3706,8 @@ int arch_enable_uv_irq(char *irq_name, u
 	unsigned long flags;
 	int err;
 
-	err = assign_irq_vector(irq, *eligible_cpu);
-	if (err != 0)
+	err = assign_irq_vector(irq, eligible_cpu);
+	if (err)
 		return err;
 
 	spin_lock_irqsave(&vector_lock, flags);
@@ -3731,7 +3727,7 @@ int arch_enable_uv_irq(char *irq_name, u
 	entry->polarity = 0;
 	entry->trigger = 0;
 	entry->mask = 0;
-	entry->dest = cpu_mask_to_apicid(*eligible_cpu);
+	entry->dest = cpu_mask_to_apicid(eligible_cpu);
 
 	mmr_pnode = uv_blade_to_pnode(mmr_blade);
 	uv_write_global_mmr64(mmr_pnode, mmr_offset, mmr_value);
@@ -3962,10 +3958,10 @@ void __init setup_ioapic_dest(void)
 						  irq_polarity(irq_entry));
 #ifdef CONFIG_INTR_REMAP
 			else if (intr_remapping_enabled)
-				set_ir_ioapic_affinity_irq(irq, TARGET_CPUS);
+				set_ir_ioapic_affinity_irq(irq, *TARGET_CPUS);
 #endif
 			else
-				set_ioapic_affinity_irq(irq, TARGET_CPUS);
+				set_ioapic_affinity_irq(irq, *TARGET_CPUS);
 		}
 
 	}
--- linux-2.6.28.orig/arch/x86/kernel/ipi.c
+++ linux-2.6.28/arch/x86/kernel/ipi.c
@@ -116,9 +116,9 @@ static inline void __send_IPI_dest_field
 /*
  * This is only used on smaller machines.
  */
-void send_IPI_mask_bitmask(cpumask_t cpumask, int vector)
+void send_IPI_mask_bitmask(const cpumask_t *cpumask, int vector)
 {
-	unsigned long mask = cpus_addr(cpumask)[0];
+	unsigned long mask = cpus_addr(*cpumask)[0];
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -127,7 +127,7 @@ void send_IPI_mask_bitmask(cpumask_t cpu
 	local_irq_restore(flags);
 }
 
-void send_IPI_mask_sequence(cpumask_t mask, int vector)
+void send_IPI_mask_sequence(const cpumask_t *mask, int vector)
 {
 	unsigned long flags;
 	unsigned int query_cpu;
@@ -139,12 +139,24 @@ void send_IPI_mask_sequence(cpumask_t ma
 	 */
 
 	local_irq_save(flags);
-	for_each_possible_cpu(query_cpu) {
-		if (cpu_isset(query_cpu, mask)) {
+	for_each_cpu_mask_nr(query_cpu, *mask)
+		__send_IPI_dest_field(cpu_to_logical_apicid(query_cpu), vector);
+	local_irq_restore(flags);
+}
+
+void send_IPI_mask_allbutself(const cpumask_t *mask, int vector)
+{
+	unsigned long flags;
+	unsigned int query_cpu;
+	unsigned int this_cpu = smp_processor_id();
+
+	/* See Hack comment above */
+
+	local_irq_save(flags);
+	for_each_cpu_mask_nr(query_cpu, *mask)
+		if (query_cpu != this_cpu)
 			__send_IPI_dest_field(cpu_to_logical_apicid(query_cpu),
 					      vector);
-		}
-	}
 	local_irq_restore(flags);
 }
 
--- linux-2.6.28.orig/arch/x86/kernel/smp.c
+++ linux-2.6.28/arch/x86/kernel/smp.c
@@ -118,22 +118,22 @@ static void native_smp_send_reschedule(i
 		WARN_ON(1);
 		return;
 	}
-	send_IPI_mask(cpumask_of_cpu(cpu), RESCHEDULE_VECTOR);
+	send_IPI_mask(&cpumask_of_cpu(cpu), RESCHEDULE_VECTOR);
 }
 
 void native_send_call_func_single_ipi(int cpu)
 {
-	send_IPI_mask(cpumask_of_cpu(cpu), CALL_FUNCTION_SINGLE_VECTOR);
+	send_IPI_mask(&cpumask_of_cpu(cpu), CALL_FUNCTION_SINGLE_VECTOR);
 }
 
-void native_send_call_func_ipi(cpumask_t mask)
+void native_send_call_func_ipi(const cpumask_t *mask)
 {
 	cpumask_t allbutself;
 
 	allbutself = cpu_online_map;
 	cpu_clear(smp_processor_id(), allbutself);
 
-	if (cpus_equal(mask, allbutself) &&
+	if (cpus_equal(*mask, allbutself) &&
 	    cpus_equal(cpu_online_map, cpu_callout_map))
 		send_IPI_allbutself(CALL_FUNCTION_VECTOR);
 	else
--- linux-2.6.28.orig/arch/x86/kernel/tlb_32.c
+++ linux-2.6.28/arch/x86/kernel/tlb_32.c
@@ -158,7 +158,7 @@ void native_flush_tlb_others(const cpuma
 	 * We have to send the IPI only to
 	 * CPUs affected.
 	 */
-	send_IPI_mask(cpumask, INVALIDATE_TLB_VECTOR);
+	send_IPI_mask(&cpumask, INVALIDATE_TLB_VECTOR);
 
 	while (!cpus_empty(flush_cpumask))
 		/* nothing. lockup detection does not belong here */
--- linux-2.6.28.orig/arch/x86/kernel/tlb_64.c
+++ linux-2.6.28/arch/x86/kernel/tlb_64.c
@@ -186,7 +186,7 @@ void native_flush_tlb_others(const cpuma
 	 * We have to send the IPI only to
 	 * CPUs affected.
 	 */
-	send_IPI_mask(cpumask, INVALIDATE_TLB_VECTOR_START + sender);
+	send_IPI_mask(&cpumask, INVALIDATE_TLB_VECTOR_START + sender);
 
 	while (!cpus_empty(f->flush_cpumask))
 		cpu_relax();
--- linux-2.6.28.orig/arch/x86/mach-generic/bigsmp.c
+++ linux-2.6.28/arch/x86/mach-generic/bigsmp.c
@@ -41,9 +41,10 @@ static const struct dmi_system_id bigsmp
 	 { }
 };
 
-static cpumask_t vector_allocation_domain(int cpu)
+static void vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
-        return cpumask_of_cpu(cpu);
+	cpus_clear(*retmask);
+	cpu_set(cpu, *retmask);
 }
 
 static int probe_bigsmp(void)
--- linux-2.6.28.orig/arch/x86/mach-generic/es7000.c
+++ linux-2.6.28/arch/x86/mach-generic/es7000.c
@@ -75,7 +75,7 @@ static int __init acpi_madt_oem_check(ch
 }
 #endif
 
-static cpumask_t vector_allocation_domain(int cpu)
+static void vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
 	/* Careful. Some cpus do not strictly honor the set of cpus
 	 * specified in the interrupt destination when using lowest
@@ -85,8 +85,7 @@ static cpumask_t vector_allocation_domai
 	 * deliver interrupts to the wrong hyperthread when only one
 	 * hyperthread was specified in the interrupt desitination.
 	 */
-	cpumask_t domain = { { [0] = APIC_ALL_CPUS, } };
-	return domain;
+	*retmask = (cpumask_t){ { [0] = APIC_ALL_CPUS, } };
 }
 
 struct genapic __initdata_refok apic_es7000 = APIC_INIT("es7000", probe_es7000);
--- linux-2.6.28.orig/arch/x86/mach-generic/numaq.c
+++ linux-2.6.28/arch/x86/mach-generic/numaq.c
@@ -38,7 +38,7 @@ static int acpi_madt_oem_check(char *oem
 	return 0;
 }
 
-static cpumask_t vector_allocation_domain(int cpu)
+static void vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
 	/* Careful. Some cpus do not strictly honor the set of cpus
 	 * specified in the interrupt destination when using lowest
@@ -48,8 +48,7 @@ static cpumask_t vector_allocation_domai
 	 * deliver interrupts to the wrong hyperthread when only one
 	 * hyperthread was specified in the interrupt desitination.
 	 */
-	cpumask_t domain = { { [0] = APIC_ALL_CPUS, } };
-	return domain;
+	*retmask = (cpumask_t){ { [0] = APIC_ALL_CPUS, } };
 }
 
 struct genapic apic_numaq = APIC_INIT("NUMAQ", probe_numaq);
--- linux-2.6.28.orig/arch/x86/mach-generic/summit.c
+++ linux-2.6.28/arch/x86/mach-generic/summit.c
@@ -23,7 +23,7 @@ static int probe_summit(void)
 	return 0;
 }
 
-static cpumask_t vector_allocation_domain(int cpu)
+static void vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
 	/* Careful. Some cpus do not strictly honor the set of cpus
 	 * specified in the interrupt destination when using lowest
@@ -33,8 +33,7 @@ static cpumask_t vector_allocation_domai
 	 * deliver interrupts to the wrong hyperthread when only one
 	 * hyperthread was specified in the interrupt desitination.
 	 */
-	cpumask_t domain = { { [0] = APIC_ALL_CPUS, } };
-	return domain;
+	*retmask = (cpumask_t){ { [0] = APIC_ALL_CPUS, } };
 }
 
 struct genapic apic_summit = APIC_INIT("summit", probe_summit);
--- linux-2.6.28.orig/arch/x86/xen/smp.c
+++ linux-2.6.28/arch/x86/xen/smp.c
@@ -158,7 +158,7 @@ static void __init xen_fill_possible_map
 {
 	int i, rc;
 
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		rc = HYPERVISOR_vcpu_op(VCPUOP_is_up, i, NULL);
 		if (rc >= 0) {
 			num_processors++;
@@ -196,7 +196,7 @@ static void __init xen_smp_prepare_cpus(
 
 	/* Restrict the possible_map according to max_cpus. */
 	while ((num_possible_cpus() > 1) && (num_possible_cpus() > max_cpus)) {
-		for (cpu = NR_CPUS - 1; !cpu_possible(cpu); cpu--)
+		for (cpu = nr_cpu_ids - 1; !cpu_possible(cpu); cpu--)
 			continue;
 		cpu_clear(cpu, cpu_possible_map);
 	}
@@ -408,24 +408,22 @@ static void xen_smp_send_reschedule(int 
 	xen_send_IPI_one(cpu, XEN_RESCHEDULE_VECTOR);
 }
 
-static void xen_send_IPI_mask(cpumask_t mask, enum ipi_vector vector)
+static void xen_send_IPI_mask(const cpumask_t *mask, enum ipi_vector vector)
 {
 	unsigned cpu;
 
-	cpus_and(mask, mask, cpu_online_map);
-
-	for_each_cpu_mask_nr(cpu, mask)
+	for_each_cpu_mask_and(cpu, *mask, cpu_online_map)
 		xen_send_IPI_one(cpu, vector);
 }
 
-static void xen_smp_send_call_function_ipi(cpumask_t mask)
+static void xen_smp_send_call_function_ipi(const cpumask_t *mask)
 {
 	int cpu;
 
 	xen_send_IPI_mask(mask, XEN_CALL_FUNCTION_VECTOR);
 
 	/* Make sure other vcpus get a chance to run if they need to. */
-	for_each_cpu_mask_nr(cpu, mask) {
+	for_each_cpu_mask_nr(cpu, *mask) {
 		if (xen_vcpu_stolen(cpu)) {
 			HYPERVISOR_sched_op(SCHEDOP_yield, 0);
 			break;
@@ -435,7 +433,8 @@ static void xen_smp_send_call_function_i
 
 static void xen_smp_send_call_function_single_ipi(int cpu)
 {
-	xen_send_IPI_mask(cpumask_of_cpu(cpu), XEN_CALL_FUNCTION_SINGLE_VECTOR);
+	xen_send_IPI_mask(&cpumask_of_cpu(cpu),
+			  XEN_CALL_FUNCTION_SINGLE_VECTOR);
 }
 
 static irqreturn_t xen_call_function_interrupt(int irq, void *dev_id)
--- linux-2.6.28.orig/include/asm-x86/bigsmp/apic.h
+++ linux-2.6.28/include/asm-x86/bigsmp/apic.h
@@ -9,12 +9,12 @@ static inline int apic_id_registered(voi
 	return (1);
 }
 
-static inline cpumask_t target_cpus(void)
+static inline const cpumask_t *target_cpus(void)
 {
 #ifdef CONFIG_SMP
-        return cpu_online_map;
+        return &cpu_online_map;
 #else
-        return cpumask_of_cpu(0);
+        return &cpumask_of_cpu(0);
 #endif
 }
 
@@ -81,7 +81,7 @@ static inline int apicid_to_node(int log
 
 static inline int cpu_present_to_apicid(int mps_cpu)
 {
-	if (mps_cpu < NR_CPUS)
+	if (mps_cpu < nr_cpu_ids)
 		return (int) per_cpu(x86_bios_cpu_apicid, mps_cpu);
 
 	return BAD_APICID;
@@ -96,7 +96,7 @@ extern u8 cpu_2_logical_apicid[];
 /* Mapping from cpu number to logical apicid */
 static inline int cpu_to_logical_apicid(int cpu)
 {
-	if (cpu >= NR_CPUS)
+	if (cpu >= nr_cpu_ids)
 		return BAD_APICID;
 	return cpu_physical_id(cpu);
 }
@@ -121,12 +121,12 @@ static inline int check_phys_apicid_pres
 }
 
 /* As we are using single CPU as destination, pick only one CPU here */
-static inline unsigned int cpu_mask_to_apicid(cpumask_t cpumask)
+static inline unsigned int cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	int cpu;
 	int apicid;	
 
-	cpu = first_cpu(cpumask);
+	cpu = first_cpu(*cpumask);
 	apicid = cpu_to_logical_apicid(cpu);
 	return apicid;
 }
--- linux-2.6.28.orig/include/asm-x86/bigsmp/ipi.h
+++ linux-2.6.28/include/asm-x86/bigsmp/ipi.h
@@ -1,9 +1,10 @@
 #ifndef __ASM_MACH_IPI_H
 #define __ASM_MACH_IPI_H
 
-void send_IPI_mask_sequence(cpumask_t mask, int vector);
+void send_IPI_mask_sequence(const cpumask_t *mask, int vector);
+void send_IPI_mask_allbutself(const cpumask_t *mask, int vector);
 
-static inline void send_IPI_mask(cpumask_t mask, int vector)
+static inline void send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	send_IPI_mask_sequence(mask, vector);
 }
@@ -14,12 +15,12 @@ static inline void send_IPI_allbutself(i
 	cpu_clear(smp_processor_id(), mask);
 
 	if (!cpus_empty(mask))
-		send_IPI_mask(mask, vector);
+		send_IPI_mask(&mask, vector);
 }
 
 static inline void send_IPI_all(int vector)
 {
-	send_IPI_mask(cpu_online_map, vector);
+	send_IPI_mask(&cpu_online_map, vector);
 }
 
 #endif /* __ASM_MACH_IPI_H */
--- linux-2.6.28.orig/include/asm-x86/es7000/apic.h
+++ linux-2.6.28/include/asm-x86/es7000/apic.h
@@ -9,12 +9,12 @@ static inline int apic_id_registered(voi
 	        return (1);
 }
 
-static inline cpumask_t target_cpus(void)
+static inline const cpumask_t *target_cpus(void)
 {
 #if defined CONFIG_ES7000_CLUSTERED_APIC
-	return CPU_MASK_ALL;
+	return &CPU_MASK_ALL;
 #else
-	return cpumask_of_cpu(smp_processor_id());
+	return &cpumask_of_cpu(smp_processor_id());
 #endif
 }
 
@@ -98,7 +98,7 @@ static inline int cpu_present_to_apicid(
 {
 	if (!mps_cpu)
 		return boot_cpu_physical_apicid;
-	else if (mps_cpu < NR_CPUS)
+	else if (mps_cpu < nr_cpu_ids)
 		return (int) per_cpu(x86_bios_cpu_apicid, mps_cpu);
 	else
 		return BAD_APICID;
@@ -118,7 +118,7 @@ extern u8 cpu_2_logical_apicid[];
 static inline int cpu_to_logical_apicid(int cpu)
 {
 #ifdef CONFIG_SMP
-       if (cpu >= NR_CPUS)
+       if (cpu >= nr_cpu_ids)
 	       return BAD_APICID;
        return (int)cpu_2_logical_apicid[cpu];
 #else
@@ -144,14 +144,14 @@ static inline int check_phys_apicid_pres
 	return (1);
 }
 
-static inline unsigned int cpu_mask_to_apicid(cpumask_t cpumask)
+static inline unsigned int cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	int num_bits_set;
 	int cpus_found = 0;
 	int cpu;
 	int apicid;
 
-	num_bits_set = cpus_weight(cpumask);
+	num_bits_set = cpus_weight(*cpumask);
 	/* Return id to all */
 	if (num_bits_set = NR_CPUS)
 #if defined CONFIG_ES7000_CLUSTERED_APIC
@@ -163,10 +163,10 @@ static inline unsigned int cpu_mask_to_a
 	 * The cpus in the mask must all be on the apic cluster.  If are not
 	 * on the same apicid cluster return default value of TARGET_CPUS.
 	 */
-	cpu = first_cpu(cpumask);
+	cpu = first_cpu(*cpumask);
 	apicid = cpu_to_logical_apicid(cpu);
 	while (cpus_found < num_bits_set) {
-		if (cpu_isset(cpu, cpumask)) {
+		if (cpu_isset(cpu, *cpumask)) {
 			int new_apicid = cpu_to_logical_apicid(cpu);
 			if (apicid_cluster(apicid) ! 					apicid_cluster(new_apicid)){
--- linux-2.6.28.orig/include/asm-x86/es7000/ipi.h
+++ linux-2.6.28/include/asm-x86/es7000/ipi.h
@@ -1,9 +1,10 @@
 #ifndef __ASM_ES7000_IPI_H
 #define __ASM_ES7000_IPI_H
 
-void send_IPI_mask_sequence(cpumask_t mask, int vector);
+void send_IPI_mask_sequence(const cpumask_t *mask, int vector);
+void send_IPI_mask_allbutself(const cpumask_t *mask, int vector);
 
-static inline void send_IPI_mask(cpumask_t mask, int vector)
+static inline void send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	send_IPI_mask_sequence(mask, vector);
 }
@@ -13,12 +14,12 @@ static inline void send_IPI_allbutself(i
 	cpumask_t mask = cpu_online_map;
 	cpu_clear(smp_processor_id(), mask);
 	if (!cpus_empty(mask))
-		send_IPI_mask(mask, vector);
+		send_IPI_mask(&mask, vector);
 }
 
 static inline void send_IPI_all(int vector)
 {
-	send_IPI_mask(cpu_online_map, vector);
+	send_IPI_mask(&cpu_online_map, vector);
 }
 
 #endif /* __ASM_ES7000_IPI_H */
--- linux-2.6.28.orig/include/asm-x86/genapic_32.h
+++ linux-2.6.28/include/asm-x86/genapic_32.h
@@ -23,7 +23,7 @@ struct genapic {
 	int (*probe)(void);
 
 	int (*apic_id_registered)(void);
-	cpumask_t (*target_cpus)(void);
+	const cpumask_t *(*target_cpus)(void);
 	int int_delivery_mode;
 	int int_dest_mode;
 	int ESR_DISABLE;
@@ -56,12 +56,13 @@ struct genapic {
 
 	unsigned (*get_apic_id)(unsigned long x);
 	unsigned long apic_id_mask;
-	unsigned int (*cpu_mask_to_apicid)(cpumask_t cpumask);
-	cpumask_t (*vector_allocation_domain)(int cpu);
+	unsigned int (*cpu_mask_to_apicid)(const cpumask_t *cpumask);
+	void (*vector_allocation_domain)(int cpu, cpumask_t *retmask);
 
 #ifdef CONFIG_SMP
 	/* ipi */
-	void (*send_IPI_mask)(cpumask_t mask, int vector);
+	void (*send_IPI_mask)(const cpumask_t *mask, int vector);
+	void (*send_IPI_mask_allbutself)(const cpumask_t *mask, int vector);
 	void (*send_IPI_allbutself)(int vector);
 	void (*send_IPI_all)(int vector);
 #endif
@@ -105,7 +106,7 @@ struct genapic {
 	APICFUNC(get_apic_id)				\
 	.apic_id_mask = APIC_ID_MASK,			\
 	APICFUNC(cpu_mask_to_apicid)			\
-	APICFUNC(vector_allocation_domain)			\
+	APICFUNC(vector_allocation_domain)		\
 	APICFUNC(acpi_madt_oem_check)			\
 	IPIFUNC(send_IPI_mask)				\
 	IPIFUNC(send_IPI_allbutself)			\
--- linux-2.6.28.orig/include/asm-x86/genapic_64.h
+++ linux-2.6.28/include/asm-x86/genapic_64.h
@@ -1,6 +1,8 @@
 #ifndef ASM_X86__GENAPIC_64_H
 #define ASM_X86__GENAPIC_64_H
 
+#include <linux/cpumask.h>
+
 /*
  * Copyright 2004 James Cleverdon, IBM.
  * Subject to the GNU Public License, v.2
@@ -18,16 +20,17 @@ struct genapic {
 	u32 int_delivery_mode;
 	u32 int_dest_mode;
 	int (*apic_id_registered)(void);
-	cpumask_t (*target_cpus)(void);
-	cpumask_t (*vector_allocation_domain)(int cpu);
+	const cpumask_t *(*target_cpus)(void);
+	void (*vector_allocation_domain)(int cpu, cpumask_t *retmask);
 	void (*init_apic_ldr)(void);
 	/* ipi */
-	void (*send_IPI_mask)(cpumask_t mask, int vector);
+	void (*send_IPI_mask)(const cpumask_t *mask, int vector);
+	void (*send_IPI_mask_allbutself)(const cpumask_t *mask, int vector);
 	void (*send_IPI_allbutself)(int vector);
 	void (*send_IPI_all)(int vector);
 	void (*send_IPI_self)(int vector);
 	/* */
-	unsigned int (*cpu_mask_to_apicid)(cpumask_t cpumask);
+	unsigned int (*cpu_mask_to_apicid)(const cpumask_t *cpumask);
 	unsigned int (*phys_pkg_id)(int index_msb);
 	unsigned int (*get_apic_id)(unsigned long x);
 	unsigned long (*set_apic_id)(unsigned int id);
--- linux-2.6.28.orig/include/asm-x86/ipi.h
+++ linux-2.6.28/include/asm-x86/ipi.h
@@ -117,7 +117,7 @@ static inline void __send_IPI_dest_field
 	native_apic_mem_write(APIC_ICR, cfg);
 }
 
-static inline void send_IPI_mask_sequence(cpumask_t mask, int vector)
+static inline void send_IPI_mask_sequence(const cpumask_t *mask, int vector)
 {
 	unsigned long flags;
 	unsigned long query_cpu;
@@ -128,11 +128,28 @@ static inline void send_IPI_mask_sequenc
 	 * - mbligh
 	 */
 	local_irq_save(flags);
-	for_each_cpu_mask_nr(query_cpu, mask) {
+	for_each_cpu_mask_nr(query_cpu, *mask) {
 		__send_IPI_dest_field(per_cpu(x86_cpu_to_apicid, query_cpu),
 				      vector, APIC_DEST_PHYSICAL);
 	}
 	local_irq_restore(flags);
 }
 
+static inline void send_IPI_mask_allbutself(const cpumask_t *mask, int vector)
+{
+	unsigned long flags;
+	unsigned int query_cpu;
+	unsigned int this_cpu = smp_processor_id();
+
+	/* See Hack comment above */
+
+	local_irq_save(flags);
+	for_each_cpu_mask_nr(query_cpu, *mask)
+		if (query_cpu != this_cpu)
+			__send_IPI_dest_field(
+				per_cpu(x86_cpu_to_apicid, query_cpu),
+				vector, APIC_DEST_PHYSICAL);
+	local_irq_restore(flags);
+}
+
 #endif /* ASM_X86__IPI_H */
--- linux-2.6.28.orig/include/asm-x86/mach-default/mach_apic.h
+++ linux-2.6.28/include/asm-x86/mach-default/mach_apic.h
@@ -8,12 +8,12 @@
 
 #define APIC_DFR_VALUE	(APIC_DFR_FLAT)
 
-static inline cpumask_t target_cpus(void)
+static inline const cpumask_t *target_cpus(void)
 { 
 #ifdef CONFIG_SMP
-	return cpu_online_map;
+	return &cpu_online_map;
 #else
-	return cpumask_of_cpu(0);
+	return &cpumask_of_cpu(0);
 #endif
 } 
 
@@ -59,9 +59,9 @@ static inline int apic_id_registered(voi
 	return physid_isset(read_apic_id(), phys_cpu_present_map);
 }
 
-static inline unsigned int cpu_mask_to_apicid(cpumask_t cpumask)
+static inline unsigned int cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
-	return cpus_addr(cpumask)[0];
+	return cpus_addr(*cpumask)[0];
 }
 
 static inline u32 phys_pkg_id(u32 cpuid_apic, int index_msb)
@@ -86,7 +86,7 @@ static inline int apicid_to_node(int log
 #endif
 }
 
-static inline cpumask_t vector_allocation_domain(int cpu)
+static inline void vector_allocation_domain(int cpu, cpumask_t *retmask)
 {
         /* Careful. Some cpus do not strictly honor the set of cpus
          * specified in the interrupt destination when using lowest
@@ -96,8 +96,7 @@ static inline cpumask_t vector_allocatio
          * deliver interrupts to the wrong hyperthread when only one
          * hyperthread was specified in the interrupt desitination.
          */
-        cpumask_t domain = { { [0] = APIC_ALL_CPUS, } };
-        return domain;
+        *retmask = (cpumask_t){ { [0] = APIC_ALL_CPUS, } };
 }
 #endif
 
@@ -129,7 +128,7 @@ static inline int cpu_to_logical_apicid(
 
 static inline int cpu_present_to_apicid(int mps_cpu)
 {
-	if (mps_cpu < NR_CPUS && cpu_present(mps_cpu))
+	if (mps_cpu < nr_cpu_ids && cpu_present(mps_cpu))
 		return (int)per_cpu(x86_bios_cpu_apicid, mps_cpu);
 	else
 		return BAD_APICID;
--- linux-2.6.28.orig/include/asm-x86/mach-default/mach_ipi.h
+++ linux-2.6.28/include/asm-x86/mach-default/mach_ipi.h
@@ -4,7 +4,8 @@
 /* Avoid include hell */
 #define NMI_VECTOR 0x02
 
-void send_IPI_mask_bitmask(cpumask_t mask, int vector);
+void send_IPI_mask_bitmask(const cpumask_t *mask, int vector);
+void send_IPI_mask_allbutself(const cpumask_t *mask, int vector);
 void __send_IPI_shortcut(unsigned int shortcut, int vector);
 
 extern int no_broadcast;
@@ -12,28 +13,27 @@ extern int no_broadcast;
 #ifdef CONFIG_X86_64
 #include <asm/genapic.h>
 #define send_IPI_mask (genapic->send_IPI_mask)
+#define send_IPI_mask_allbutself (genapic->send_IPI_mask_allbutself)
 #else
-static inline void send_IPI_mask(cpumask_t mask, int vector)
+static inline void send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	send_IPI_mask_bitmask(mask, vector);
 }
+void send_IPI_mask_allbutself(const cpumask_t *mask, int vector);
 #endif
 
 static inline void __local_send_IPI_allbutself(int vector)
 {
-	if (no_broadcast || vector = NMI_VECTOR) {
-		cpumask_t mask = cpu_online_map;
-
-		cpu_clear(smp_processor_id(), mask);
-		send_IPI_mask(mask, vector);
-	} else
+	if (no_broadcast || vector = NMI_VECTOR)
+		send_IPI_mask_allbutself(&cpu_online_map, vector);
+	else
 		__send_IPI_shortcut(APIC_DEST_ALLBUT, vector);
 }
 
 static inline void __local_send_IPI_all(int vector)
 {
 	if (no_broadcast || vector = NMI_VECTOR)
-		send_IPI_mask(cpu_online_map, vector);
+		send_IPI_mask(&cpu_online_map, vector);
 	else
 		__send_IPI_shortcut(APIC_DEST_ALLINC, vector);
 }
--- linux-2.6.28.orig/include/asm-x86/numaq/apic.h
+++ linux-2.6.28/include/asm-x86/numaq/apic.h
@@ -7,7 +7,7 @@
 
 #define APIC_DFR_VALUE	(APIC_DFR_CLUSTER)
 
-static inline cpumask_t target_cpus(void)
+static inline const cpumask_t *target_cpus(void)
 {
 	return CPU_MASK_ALL;
 }
@@ -122,7 +122,7 @@ static inline void enable_apic_mode(void
  * We use physical apicids here, not logical, so just return the default
  * physical broadcast to stop people from breaking us
  */
-static inline unsigned int cpu_mask_to_apicid(cpumask_t cpumask)
+static inline unsigned int cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	return (int) 0xF;
 }
--- linux-2.6.28.orig/include/asm-x86/numaq/ipi.h
+++ linux-2.6.28/include/asm-x86/numaq/ipi.h
@@ -1,9 +1,10 @@
 #ifndef __ASM_NUMAQ_IPI_H
 #define __ASM_NUMAQ_IPI_H
 
-void send_IPI_mask_sequence(cpumask_t, int vector);
+void send_IPI_mask_sequence(const cpumask_t *mask, int vector);
+void send_IPI_mask_allbutself(const cpumask_t *mask, int vector);
 
-static inline void send_IPI_mask(cpumask_t mask, int vector)
+static inline void send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	send_IPI_mask_sequence(mask, vector);
 }
@@ -14,12 +15,12 @@ static inline void send_IPI_allbutself(i
 	cpu_clear(smp_processor_id(), mask);
 
 	if (!cpus_empty(mask))
-		send_IPI_mask(mask, vector);
+		send_IPI_mask(&mask, vector);
 }
 
 static inline void send_IPI_all(int vector)
 {
-	send_IPI_mask(cpu_online_map, vector);
+	send_IPI_mask(&cpu_online_map, vector);
 }
 
 #endif /* __ASM_NUMAQ_IPI_H */
--- linux-2.6.28.orig/include/asm-x86/smp.h
+++ linux-2.6.28/include/asm-x86/smp.h
@@ -60,7 +60,7 @@ struct smp_ops {
 	void (*cpu_die)(unsigned int cpu);
 	void (*play_dead)(void);
 
-	void (*send_call_func_ipi)(cpumask_t mask);
+	void (*send_call_func_ipi)(const cpumask_t *mask);
 	void (*send_call_func_single_ipi)(int cpu);
 };
 
@@ -125,7 +125,7 @@ static inline void arch_send_call_functi
 
 static inline void arch_send_call_function_ipi(cpumask_t mask)
 {
-	smp_ops.send_call_func_ipi(mask);
+	smp_ops.send_call_func_ipi(&mask);
 }
 
 void cpu_disable_common(void);
@@ -138,7 +138,7 @@ void native_cpu_die(unsigned int cpu);
 void native_play_dead(void);
 void play_dead_common(void);
 
-void native_send_call_func_ipi(cpumask_t mask);
+void native_send_call_func_ipi(const cpumask_t *mask);
 void native_send_call_func_single_ipi(int cpu);
 
 extern void prefill_possible_map(void);
--- linux-2.6.28.orig/include/asm-x86/summit/apic.h
+++ linux-2.6.28/include/asm-x86/summit/apic.h
@@ -14,13 +14,13 @@
 
 #define APIC_DFR_VALUE	(APIC_DFR_CLUSTER)
 
-static inline cpumask_t target_cpus(void)
+static inline const cpumask_t *target_cpus(void)
 {
 	/* CPU_MASK_ALL (0xff) has undefined behaviour with
 	 * dest_LowestPrio mode logical clustered apic interrupt routing
 	 * Just start on cpu 0.  IRQ balancing will spread load
 	 */
-	return cpumask_of_cpu(0);
+	return &cpumask_of_cpu(0);
 }
 
 #define INT_DELIVERY_MODE (dest_LowestPrio)
@@ -137,14 +137,14 @@ static inline void enable_apic_mode(void
 {
 }
 
-static inline unsigned int cpu_mask_to_apicid(cpumask_t cpumask)
+static inline unsigned int cpu_mask_to_apicid(const cpumask_t *cpumask)
 {
 	int num_bits_set;
 	int cpus_found = 0;
 	int cpu;
 	int apicid;
 
-	num_bits_set = cpus_weight(cpumask);
+	num_bits_set = cpus_weight(*cpumask);
 	/* Return id to all */
 	if (num_bits_set = NR_CPUS)
 		return (int) 0xFF;
@@ -152,10 +152,10 @@ static inline unsigned int cpu_mask_to_a
 	 * The cpus in the mask must all be on the apic cluster.  If are not
 	 * on the same apicid cluster return default value of TARGET_CPUS.
 	 */
-	cpu = first_cpu(cpumask);
+	cpu = first_cpu(*cpumask);
 	apicid = cpu_to_logical_apicid(cpu);
 	while (cpus_found < num_bits_set) {
-		if (cpu_isset(cpu, cpumask)) {
+		if (cpu_isset(cpu, *cpumask)) {
 			int new_apicid = cpu_to_logical_apicid(cpu);
 			if (apicid_cluster(apicid) ! 					apicid_cluster(new_apicid)){
--- linux-2.6.28.orig/include/asm-x86/summit/ipi.h
+++ linux-2.6.28/include/asm-x86/summit/ipi.h
@@ -1,9 +1,10 @@
 #ifndef __ASM_SUMMIT_IPI_H
 #define __ASM_SUMMIT_IPI_H
 
-void send_IPI_mask_sequence(cpumask_t mask, int vector);
+void send_IPI_mask_sequence(const cpumask_t *mask, int vector);
+void send_IPI_mask_allbutself(const cpumask_t *mask, int vector);
 
-static inline void send_IPI_mask(cpumask_t mask, int vector)
+static inline void send_IPI_mask(const cpumask_t *mask, int vector)
 {
 	send_IPI_mask_sequence(mask, vector);
 }
@@ -14,12 +15,12 @@ static inline void send_IPI_allbutself(i
 	cpu_clear(smp_processor_id(), mask);
 
 	if (!cpus_empty(mask))
-		send_IPI_mask(mask, vector);
+		send_IPI_mask(&mask, vector);
 }
 
 static inline void send_IPI_all(int vector)
 {
-	send_IPI_mask(cpu_online_map, vector);
+	send_IPI_mask(&cpu_online_map, vector);
 }
 
 #endif /* __ASM_SUMMIT_IPI_H */

-- 

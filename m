From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:34 +0000
Subject: [PATCH 15/35] cpumask: prepare for iterators to only go to nr_cpu_ids.
Message-Id: <20081020170321.671993000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

In fact, all cpumask ops will only be valid (in general) for bit
numbers < nr_cpu_ids.  So use that instead of NR_CPUS in various
places.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/alpha/kernel/irq.c                               |    3 ++-
 arch/alpha/kernel/smp.c                               |    8 ++++----
 arch/arm/kernel/irq.c                                 |    2 +-
 arch/cris/kernel/setup.c                              |    2 +-
 arch/frv/kernel/setup.c                               |    2 +-
 arch/h8300/kernel/setup.c                             |    2 +-
 arch/ia64/kernel/acpi.c                               |    2 +-
 arch/ia64/kernel/iosapic.c                            |    4 ++--
 arch/ia64/kernel/irq.c                                |    2 +-
 arch/ia64/kernel/mca.c                                |    6 +++---
 arch/ia64/kernel/perfmon.c                            |    4 ++--
 arch/ia64/kernel/salinfo.c                            |    6 +++---
 arch/ia64/kernel/setup.c                              |    4 ++--
 arch/ia64/sn/kernel/setup.c                           |    2 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c                     |    6 +++---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c                   |    2 +-
 arch/m32r/kernel/setup.c                              |    2 +-
 arch/m68knommu/kernel/setup.c                         |    2 +-
 arch/mips/kernel/irq-gic.c                            |    2 +-
 arch/mips/kernel/proc.c                               |    2 +-
 arch/mips/kernel/smp-cmp.c                            |    2 +-
 arch/mips/kernel/smtc.c                               |    6 +++---
 arch/mips/sibyte/bcm1480/irq.c                        |    2 +-
 arch/mips/sibyte/bcm1480/smp.c                        |    2 +-
 arch/mips/sibyte/sb1250/smp.c                         |    2 +-
 arch/mn10300/kernel/irq.c                             |    4 ++--
 arch/mn10300/kernel/setup.c                           |    2 +-
 arch/parisc/kernel/irq.c                              |    4 ++--
 arch/parisc/kernel/processor.c                        |    4 ++--
 arch/powerpc/include/asm/cputhreads.h                 |    2 +-
 arch/powerpc/kernel/irq.c                             |    2 +-
 arch/powerpc/kernel/machine_kexec_64.c                |    2 +-
 arch/powerpc/kernel/process.c                         |    2 +-
 arch/powerpc/kernel/setup-common.c                    |   10 +++++-----
 arch/powerpc/mm/numa.c                                |    4 ++--
 arch/powerpc/platforms/powermac/setup.c               |    2 +-
 arch/powerpc/platforms/powermac/smp.c                 |    4 ++--
 arch/powerpc/platforms/pseries/hotplug-cpu.c          |    2 +-
 arch/powerpc/platforms/pseries/rtasd.c                |    2 +-
 arch/powerpc/platforms/pseries/xics.c                 |    2 +-
 arch/powerpc/xmon/xmon.c                              |    4 ++--
 arch/s390/kernel/smp.c                                |   10 +++++-----
 arch/sh/kernel/setup.c                                |    2 +-
 arch/sparc/kernel/smp.c                               |   11 +++++------
 arch/sparc/kernel/sun4d_smp.c                         |    9 ++++-----
 arch/sparc/kernel/sun4m_smp.c                         |    8 +++-----
 arch/sparc/mm/srmmu.c                                 |    2 +-
 arch/sparc64/kernel/ds.c                              |    2 +-
 arch/sparc64/kernel/irq.c                             |    4 ++--
 arch/sparc64/mm/init.c                                |    2 +-
 arch/um/kernel/um_arch.c                              |    2 +-
 arch/x86/kernel/apic.c                                |    2 +-
 arch/x86/kernel/irq_32.c                              |    2 +-
 arch/x86/mach-voyager/voyager_smp.c                   |    2 +-
 arch/x86/mm/numa_64.c                                 |    4 ++--
 arch/x86/mm/srat_64.c                                 |    2 +-
 drivers/infiniband/hw/ehca/ehca_irq.c                 |    2 +-
 kernel/kexec.c                                        |    2 +-
 kernel/smp.c                                          |    2 +-
 net/core/neighbour.c                                  |    4 ++--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    4 ++--
 net/ipv4/route.c                                      |    4 ++--
 net/netfilter/nf_conntrack_standalone.c               |    4 ++--
 security/selinux/selinuxfs.c                          |    2 +-
 64 files changed, 108 insertions(+), 111 deletions(-)

--- test-compile.orig/arch/alpha/kernel/irq.c
+++ test-compile/arch/alpha/kernel/irq.c
@@ -50,8 +50,9 @@ int irq_select_affinity(unsigned int irq
 	if (!irq_desc[irq].chip->set_affinity || irq_user_affinity[irq])
 		return 1;
 
+	/* FIXME: This has an out-by-one error: inc then test! */
 	while (!cpu_possible(cpu) || !cpu_isset(cpu, irq_default_affinity))
-		cpu = (cpu < (NR_CPUS-1) ? cpu + 1 : 0);
+		cpu = (cpu < (nr_cpu_ids-1) ? cpu + 1 : 0);
 	last_cpu = cpu;
 
 	irq_desc[irq].affinity = cpumask_of_cpu(cpu);
--- test-compile.orig/arch/alpha/kernel/smp.c
+++ test-compile/arch/alpha/kernel/smp.c
@@ -502,7 +502,7 @@ smp_cpus_done(unsigned int max_cpus)
 	int cpu;
 	unsigned long bogosum = 0;
 
-	for(cpu = 0; cpu < NR_CPUS; cpu++) 
+	for(cpu = 0; cpu < nr_cpu_ids; cpu++)
 		if (cpu_online(cpu))
 			bogosum += cpu_data[cpu].loops_per_jiffy;
 	
@@ -703,7 +703,7 @@ flush_tlb_mm(struct mm_struct *mm)
 		flush_tlb_current(mm);
 		if (atomic_read(&mm->mm_users) <= 1) {
 			int cpu, this_cpu = smp_processor_id();
-			for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			for (cpu = 0; cpu < nr_cpu_ids; cpu++) {
 				if (!cpu_online(cpu) || cpu = this_cpu)
 					continue;
 				if (mm->context[cpu])
@@ -752,7 +752,7 @@ flush_tlb_page(struct vm_area_struct *vm
 		flush_tlb_current_page(mm, vma, addr);
 		if (atomic_read(&mm->mm_users) <= 1) {
 			int cpu, this_cpu = smp_processor_id();
-			for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			for (cpu = 0; cpu < nr_cpu_ids; cpu++) {
 				if (!cpu_online(cpu) || cpu = this_cpu)
 					continue;
 				if (mm->context[cpu])
@@ -808,7 +808,7 @@ flush_icache_user_range(struct vm_area_s
 		__load_new_mm_context(mm);
 		if (atomic_read(&mm->mm_users) <= 1) {
 			int cpu, this_cpu = smp_processor_id();
-			for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			for (cpu = 0; cpu < nr_cpu_ids; cpu++) {
 				if (!cpu_online(cpu) || cpu = this_cpu)
 					continue;
 				if (mm->context[cpu])
--- test-compile.orig/arch/arm/kernel/irq.c
+++ test-compile/arch/arm/kernel/irq.c
@@ -193,7 +193,7 @@ void migrate_irqs(void)
 		if (desc->cpu = cpu) {
 			unsigned int newcpu = any_online_cpu(desc->affinity);
 
-			if (newcpu = NR_CPUS) {
+			if (newcpu >= nr_cpu_ids) {
 				if (printk_ratelimit())
 					printk(KERN_INFO "IRQ%u no longer affine to CPU%u\n",
 					       i, cpu);
--- test-compile.orig/arch/cris/kernel/setup.c
+++ test-compile/arch/cris/kernel/setup.c
@@ -166,7 +166,7 @@ void __init setup_arch(char **cmdline_p)
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? (void *)(int)(*pos + 1): NULL;
+	return *pos < nr_cpu_ids ? (void *)(int)(*pos + 1) : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/frv/kernel/setup.c
+++ test-compile/arch/frv/kernel/setup.c
@@ -1100,7 +1100,7 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? (void *) 0x12345678 : NULL;
+	return *pos < nr_cpu_ids ? (void *) 0x12345678 : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/h8300/kernel/setup.c
+++ test-compile/arch/h8300/kernel/setup.c
@@ -224,7 +224,7 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? ((void *) 0x12345678) : NULL;
+	return *pos < nr_cpu_ids ? ((void *) 0x12345678) : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/ia64/kernel/acpi.c
+++ test-compile/arch/ia64/kernel/acpi.c
@@ -885,7 +885,7 @@ int acpi_map_lsapic(acpi_handle handle, 
 
 	cpus_complement(tmp_map, cpu_present_map);
 	cpu = first_cpu(tmp_map);
-	if (cpu >= NR_CPUS)
+	if (cpu >= nr_cpu_ids)
 		return -EINVAL;
 
 	acpi_map_cpu2node(handle, cpu, physid);
--- test-compile.orig/arch/ia64/kernel/iosapic.c
+++ test-compile/arch/ia64/kernel/iosapic.c
@@ -720,7 +720,7 @@ get_target_cpu (unsigned int gsi, int ir
 		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
 			numa_cpu = next_cpu(numa_cpu, cpu_mask);
 
-		if (numa_cpu != NR_CPUS)
+		if (numa_cpu < nr_cpus_ids)
 			return cpu_physical_id(numa_cpu);
 	}
 skip_numa_setup:
@@ -731,7 +731,7 @@ skip_numa_setup:
 	 * case of NUMA.)
 	 */
 	do {
-		if (++cpu >= NR_CPUS)
+		if (++cpu >= nr_cpu_ids)
 			cpu = 0;
 	} while (!cpu_online(cpu) || !cpu_isset(cpu, domain));
 
--- test-compile.orig/arch/ia64/kernel/irq.c
+++ test-compile/arch/ia64/kernel/irq.c
@@ -153,7 +153,7 @@ static void migrate_irqs(void)
 			continue;
 
 		cpus_and(mask, irq_desc[irq].affinity, cpu_online_map);
-		if (any_online_cpu(mask) = NR_CPUS) {
+		if (any_online_cpu(mask) >= nr_cpu_ids) {
 			/*
 			 * Save it for phase 2 processing
 			 */
--- test-compile.orig/arch/ia64/kernel/mca.c
+++ test-compile/arch/ia64/kernel/mca.c
@@ -1456,9 +1456,9 @@ ia64_mca_cmc_int_caller(int cmc_irq, voi
 
 	ia64_mca_cmc_int_handler(cmc_irq, arg);
 
-	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
+	cpuid = next_cpu(cpuid+1, cpu_online_map);
 
-	if (cpuid < NR_CPUS) {
+	if (cpuid < nr_cpu_ids) {
 		platform_send_ipi(cpuid, IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
 	} else {
 		/* If no log record, switch out of polling mode */
@@ -1525,7 +1525,7 @@ ia64_mca_cpe_int_caller(int cpe_irq, voi
 
 	ia64_mca_cpe_int_handler(cpe_irq, arg);
 
-	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
+	cpuid = next_cpu(cpuid+1, cpu_online_map);
 
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
--- test-compile.orig/arch/ia64/kernel/perfmon.c
+++ test-compile/arch/ia64/kernel/perfmon.c
@@ -5598,7 +5598,7 @@ pfm_interrupt_handler(int irq, void *arg
  * /proc/perfmon interface, for debug only
  */
 
-#define PFM_PROC_SHOW_HEADER	((void *)NR_CPUS+1)
+#define PFM_PROC_SHOW_HEADER	((void *)nr_cpu_ids+1)
 
 static void *
 pfm_proc_start(struct seq_file *m, loff_t *pos)
@@ -5607,7 +5607,7 @@ pfm_proc_start(struct seq_file *m, loff_
 		return PFM_PROC_SHOW_HEADER;
 	}
 
-	while (*pos <= NR_CPUS) {
+	while (*pos <= nr_cpu_ids) {
 		if (cpu_online(*pos - 1)) {
 			return (void *)*pos;
 		}
--- test-compile.orig/arch/ia64/kernel/salinfo.c
+++ test-compile/arch/ia64/kernel/salinfo.c
@@ -317,7 +317,7 @@ retry:
 	}
 
 	n = data->cpu_check;
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		if (cpu_isset(n, data->cpu_event)) {
 			if (!cpu_online(n)) {
 				cpu_clear(n, data->cpu_event);
@@ -326,7 +326,7 @@ retry:
 			cpu = n;
 			break;
 		}
-		if (++n = NR_CPUS)
+		if (++n = nr_cpu_ids)
 			n = 0;
 	}
 
@@ -337,7 +337,7 @@ retry:
 
 	/* for next read, start checking at next CPU */
 	data->cpu_check = cpu;
-	if (++data->cpu_check = NR_CPUS)
+	if (++data->cpu_check = nr_cpu_ids)
 		data->cpu_check = 0;
 
 	snprintf(cmd, sizeof(cmd), "read %d\n", cpu);
--- test-compile.orig/arch/ia64/kernel/setup.c
+++ test-compile/arch/ia64/kernel/setup.c
@@ -714,10 +714,10 @@ static void *
 c_start (struct seq_file *m, loff_t *pos)
 {
 #ifdef CONFIG_SMP
-	while (*pos < NR_CPUS && !cpu_isset(*pos, cpu_online_map))
+	while (*pos < nr_cpu_ids && !cpu_online(*pos))
 		++*pos;
 #endif
-	return *pos < NR_CPUS ? cpu_data(*pos) : NULL;
+	return *pos < nr_cpu_ids ? cpu_data(*pos) : NULL;
 }
 
 static void *
--- test-compile.orig/arch/ia64/sn/kernel/setup.c
+++ test-compile/arch/ia64/sn/kernel/setup.c
@@ -753,7 +753,7 @@ nasid_slice_to_cpuid(int nasid, int slic
 {
 	long cpu;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
+	for (cpu = 0; cpu < nr_cpu_ids; cpu++)
 		if (cpuid_to_nasid(cpu) = nasid &&
 					cpuid_to_slice(cpu) = slice)
 			return cpu;
--- test-compile.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ test-compile/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -461,7 +461,7 @@ bool sn_cpu_disable_allowed(int cpu)
 
 static void *sn2_ptc_seq_start(struct seq_file *file, loff_t * offset)
 {
-	if (*offset < NR_CPUS)
+	if (*offset < nr_cpu_ids)
 		return offset;
 	return NULL;
 }
@@ -469,7 +469,7 @@ static void *sn2_ptc_seq_start(struct se
 static void *sn2_ptc_seq_next(struct seq_file *file, void *data, loff_t * offset)
 {
 	(*offset)++;
-	if (*offset < NR_CPUS)
+	if (*offset < nr_cpu_ids)
 		return offset;
 	return NULL;
 }
@@ -491,7 +491,7 @@ static int sn2_ptc_seq_show(struct seq_f
 		seq_printf(file, "# ptctest %d, flushopt %d\n", sn2_ptctest, sn2_flush_opt);
 	}
 
-	if (cpu < NR_CPUS && cpu_online(cpu)) {
+	if (cpu < nr_cpu_ids && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
 		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
 				stat->change_rid, stat->shub_ptc_flushes, stat->nodes_flushed,
--- test-compile.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ test-compile/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -615,7 +615,7 @@ static int sn_hwperf_op_cpu(struct sn_hw
 	op_info->a->arg &= SN_HWPERF_ARG_OBJID_MASK;
 
 	if (cpu != SN_HWPERF_ARG_ANY_CPU) {
-		if (cpu >= NR_CPUS || !cpu_online(cpu)) {
+		if (cpu >= nr_cpu_ids || !cpu_online(cpu)) {
 			r = -EINVAL;
 			goto out;
 		}
--- test-compile.orig/arch/m32r/kernel/setup.c
+++ test-compile/arch/m32r/kernel/setup.c
@@ -356,7 +356,7 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? cpu_data + *pos : NULL;
+	return *pos < nr_cpu_ids ? cpu_data + *pos : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/m68knommu/kernel/setup.c
+++ test-compile/arch/m68knommu/kernel/setup.c
@@ -248,7 +248,7 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? ((void *) 0x12345678) : NULL;
+	return *pos < nr_cpu_ids ? ((void *) 0x12345678) : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/mips/kernel/irq-gic.c
+++ test-compile/arch/mips/kernel/irq-gic.c
@@ -182,7 +182,7 @@ static void gic_set_affinity(unsigned in
 		_intrmap[irq].cpunum = first_cpu(tmp);
 
 		/* Update the pcpu_masks */
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < nr_cpu_ids; i++)
 			clear_bit(irq, pcpu_masks[i].pcpu_mask);
 		set_bit(irq, pcpu_masks[first_cpu(tmp)].pcpu_mask);
 
--- test-compile.orig/arch/mips/kernel/proc.c
+++ test-compile/arch/mips/kernel/proc.c
@@ -86,7 +86,7 @@ static void *c_start(struct seq_file *m,
 {
 	unsigned long i = *pos;
 
-	return i < NR_CPUS ? (void *) (i + 1) : NULL;
+	return i < nr_cpu_ids ? (void *) (i + 1) : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/mips/kernel/smp-cmp.c
+++ test-compile/arch/mips/kernel/smp-cmp.c
@@ -224,7 +224,7 @@ void __init cmp_smp_setup(void)
 		cpu_set(0, mt_fpu_cpumask);
 #endif /* CONFIG_MIPS_MT_FPAFF */
 
-	for (i = 1; i < NR_CPUS; i++) {
+	for (i = 1; i < nr_cpu_ids; i++) {
 		if (amon_cpu_avail(i)) {
 			cpu_set(i, phys_cpu_present_map);
 			__cpu_number_map[i]	= ++ncpu;
--- test-compile.orig/arch/mips/kernel/smtc.c
+++ test-compile/arch/mips/kernel/smtc.c
@@ -303,7 +303,7 @@ int __init smtc_build_cpu_map(int start_
 	 * everything up so that "logical" = "physical".
 	 */
 	ntcs = ((read_c0_mvpconf0() & MVPCONF0_PTC) >> MVPCONF0_PTC_SHIFT) + 1;
-	for (i=start_cpu_slot; i<NR_CPUS && i<ntcs; i++) {
+	for (i = start_cpu_slot; i < nr_cpu_ids && i < ntcs; i++) {
 		cpu_set(i, phys_cpu_present_map);
 		__cpu_number_map[i] = i;
 		__cpu_logical_map[i] = i;
@@ -422,8 +422,8 @@ void smtc_prepare_cpus(int cpus)
 	if (vpelimit > 0 && nvpe > vpelimit)
 		nvpe = vpelimit;
 	ntc = ((val & MVPCONF0_PTC) >> MVPCONF0_PTC_SHIFT) + 1;
-	if (ntc > NR_CPUS)
-		ntc = NR_CPUS;
+	if (ntc > nr_cpu_ids)
+		ntc = nr_cpu_ids;
 	if (tclimit > 0 && ntc > tclimit)
 		ntc = tclimit;
 	slop = ntc % nvpe;
--- test-compile.orig/arch/mips/sibyte/bcm1480/irq.c
+++ test-compile/arch/mips/sibyte/bcm1480/irq.c
@@ -195,7 +195,7 @@ static void ack_bcm1480_irq(unsigned int
 		if (pending) {
 #ifdef CONFIG_SMP
 			int i;
-			for (i=0; i<NR_CPUS; i++) {
+			for (i=0; i < nr_cpu_ids; i++) {
 				/*
 				 * Clear for all CPUs so an affinity switch
 				 * doesn't find an old status
--- test-compile.orig/arch/mips/sibyte/bcm1480/smp.c
+++ test-compile/arch/mips/sibyte/bcm1480/smp.c
@@ -150,7 +150,7 @@ static void __init bcm1480_smp_setup(voi
 	__cpu_number_map[0] = 0;
 	__cpu_logical_map[0] = 0;
 
-	for (i = 1, num = 0; i < NR_CPUS; i++) {
+	for (i = 1, num = 0; i < nr_cpu_ids; i++) {
 		if (cfe_cpu_stop(i) = 0) {
 			cpu_set(i, phys_cpu_present_map);
 			__cpu_number_map[i] = ++num;
--- test-compile.orig/arch/mips/sibyte/sb1250/smp.c
+++ test-compile/arch/mips/sibyte/sb1250/smp.c
@@ -138,7 +138,7 @@ static void __init sb1250_smp_setup(void
 	__cpu_number_map[0] = 0;
 	__cpu_logical_map[0] = 0;
 
-	for (i = 1, num = 0; i < NR_CPUS; i++) {
+	for (i = 1, num = 0; i < nr_cpu_ids; i++) {
 		if (cfe_cpu_stop(i) = 0) {
 			cpu_set(i, phys_cpu_present_map);
 			__cpu_number_map[i] = ++num;
--- test-compile.orig/arch/mn10300/kernel/irq.c
+++ test-compile/arch/mn10300/kernel/irq.c
@@ -207,7 +207,7 @@ int show_interrupts(struct seq_file *p, 
 		/* display column title bar naming CPUs */
 	case 0:
 		seq_printf(p, "           ");
-		for (j = 0; j < NR_CPUS; j++)
+		for (j = 0; j < nr_cpu_ids; j++)
 			if (cpu_online(j))
 				seq_printf(p, "CPU%d       ", j);
 		seq_putc(p, '\n');
@@ -241,7 +241,7 @@ int show_interrupts(struct seq_file *p, 
 		/* polish off with NMI and error counters */
 	case NR_IRQS:
 		seq_printf(p, "NMI: ");
-		for (j = 0; j < NR_CPUS; j++)
+		for (j = 0; j < nr_cpu_ids; j++)
 			if (cpu_online(j))
 				seq_printf(p, "%10u ", nmi_count(j));
 		seq_putc(p, '\n');
--- test-compile.orig/arch/mn10300/kernel/setup.c
+++ test-compile/arch/mn10300/kernel/setup.c
@@ -276,7 +276,7 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? cpu_data + *pos : NULL;
+	return *pos < nr_cpu_ids ? cpu_data + *pos : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/parisc/kernel/irq.c
+++ test-compile/arch/parisc/kernel/irq.c
@@ -309,11 +309,11 @@ unsigned long txn_alloc_addr(unsigned in
 	next_cpu++; /* assign to "next" CPU we want this bugger on */
 
 	/* validate entry */
-	while ((next_cpu < NR_CPUS) && (!cpu_data[next_cpu].txn_addr || 
+	while ((next_cpu < nr_cpu_ids) && (!cpu_data[next_cpu].txn_addr ||
 		!cpu_online(next_cpu)))
 		next_cpu++;
 
-	if (next_cpu >= NR_CPUS) 
+	if (next_cpu >= nr_cpu_ids)
 		next_cpu = 0;	/* nothing else, assign monarch */
 
 	return txn_affinity_addr(virt_irq, next_cpu);
--- test-compile.orig/arch/parisc/kernel/processor.c
+++ test-compile/arch/parisc/kernel/processor.c
@@ -83,8 +83,8 @@ static int __cpuinit processor_probe(str
 	struct cpuinfo_parisc *p;
 
 #ifdef CONFIG_SMP
-	if (num_online_cpus() >= NR_CPUS) {
-		printk(KERN_INFO "num_online_cpus() >= NR_CPUS\n");
+	if (num_online_cpus() >= nr_cpu_ids) {
+		printk(KERN_INFO "num_online_cpus() >= nr_cpu_ids\n");
 		return 1;
 	}
 #else
--- test-compile.orig/arch/powerpc/include/asm/cputhreads.h
+++ test-compile/arch/powerpc/include/asm/cputhreads.h
@@ -34,7 +34,7 @@ static inline cpumask_t cpu_thread_mask_
 	int		i;
 
 	res = CPU_MASK_NONE;
-	for (i = 0; i < NR_CPUS; i += threads_per_core) {
+	for (i = 0; i < nr_cpu_ids; i += threads_per_core) {
 		cpus_shift_left(tmp, threads_core_mask, i);
 		if (cpus_intersects(threads, tmp))
 			cpu_set(i, res);
--- test-compile.orig/arch/powerpc/kernel/irq.c
+++ test-compile/arch/powerpc/kernel/irq.c
@@ -232,7 +232,7 @@ void fixup_irqs(cpumask_t map)
 			continue;
 
 		cpus_and(mask, irq_desc[irq].affinity, map);
-		if (any_online_cpu(mask) = NR_CPUS) {
+		if (any_online_cpu(mask) >= nr_cpu_ids) {
 			printk("Breaking affinity for irq %i\n", irq);
 			mask = map;
 		}
--- test-compile.orig/arch/powerpc/kernel/machine_kexec_64.c
+++ test-compile/arch/powerpc/kernel/machine_kexec_64.c
@@ -176,7 +176,7 @@ static void kexec_prepare_cpus(void)
 	my_cpu = get_cpu();
 
 	/* check the others cpus are now down (via paca hw cpu id = -1) */
-	for (i=0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		if (i = my_cpu)
 			continue;
 
--- test-compile.orig/arch/powerpc/kernel/process.c
+++ test-compile/arch/powerpc/kernel/process.c
@@ -941,7 +941,7 @@ static inline int valid_irq_stack(unsign
 	 * Avoid crashing if the stack has overflowed and corrupted
 	 * task_cpu(p), which is in the thread_info struct.
 	 */
-	if (cpu < NR_CPUS && cpu_possible(cpu)) {
+	if (cpu < nr_cpu_ids && cpu_possible(cpu)) {
 		stack_page = (unsigned long) hardirq_ctx[cpu];
 		if (sp >= stack_page + sizeof(struct thread_struct)
 		    && sp <= stack_page + THREAD_SIZE - nbytes)
--- test-compile.orig/arch/powerpc/kernel/setup-common.c
+++ test-compile/arch/powerpc/kernel/setup-common.c
@@ -166,7 +166,7 @@ static int show_cpuinfo(struct seq_file 
 	unsigned short maj;
 	unsigned short min;
 
-	if (cpu_id = NR_CPUS) {
+	if (cpu_id = nr_cpu_ids) {
 		struct device_node *root;
 		const char *model = NULL;
 #if defined(CONFIG_SMP) && defined(CONFIG_PPC32)
@@ -196,7 +196,7 @@ static int show_cpuinfo(struct seq_file 
 	/* We only show online cpus: disable preempt (overzealous, I
 	 * knew) to prevent cpu going down. */
 	preempt_disable();
-	if (!cpu_online(cpu_id)) {
+	if (cpu_id >= nr_cpu_ids || !cpu_online(cpu_id)) {
 		preempt_enable();
 		return 0;
 	}
@@ -307,7 +307,7 @@ static void *c_start(struct seq_file *m,
 {
 	unsigned long i = *pos;
 
-	return i <= NR_CPUS ? (void *)(i + 1) : NULL;
+	return i <= nr_cpu_ids ? (void *)(i + 1) : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
@@ -402,7 +402,7 @@ void __init smp_setup_cpu_maps(void)
 
 	DBG("smp_setup_cpu_maps()\n");
 
-	while ((dn = of_find_node_by_type(dn, "cpu")) && cpu < NR_CPUS) {
+	while ((dn = of_find_node_by_type(dn, "cpu")) && cpu < nr_cpu_ids) {
 		const int *intserv;
 		int j, len;
 
@@ -421,7 +421,7 @@ void __init smp_setup_cpu_maps(void)
 				intserv = &cpu;	/* assume logical = phys */
 		}
 
-		for (j = 0; j < nthreads && cpu < NR_CPUS; j++) {
+		for (j = 0; j < nthreads && cpu < nr_cpu_ids; j++) {
 			DBG("    thread %d -> cpu %d (hard id %d)\n",
 			    j, cpu, intserv[j]);
 			cpu_set(cpu, cpu_present_map);
--- test-compile.orig/arch/powerpc/mm/numa.c
+++ test-compile/arch/powerpc/mm/numa.c
@@ -765,7 +765,7 @@ void __init dump_numa_cpu_topology(void)
 		 * If we used a CPU iterator here we would miss printing
 		 * the holes in the cpumap.
 		 */
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		for (cpu = 0; cpu < nr_cpu_ids; cpu++) {
 			if (cpu_isset(cpu, numa_cpumask_lookup_table[node])) {
 				if (count = 0)
 					printk(" %u", cpu);
@@ -778,7 +778,7 @@ void __init dump_numa_cpu_topology(void)
 		}
 
 		if (count > 1)
-			printk("-%u", NR_CPUS - 1);
+			printk("-%u", nr_cpu_ids - 1);
 		printk("\n");
 	}
 }
--- test-compile.orig/arch/powerpc/platforms/powermac/setup.c
+++ test-compile/arch/powerpc/platforms/powermac/setup.c
@@ -365,7 +365,7 @@ static void __init pmac_setup_arch(void)
 		 */
 		int cpu;
 
-		for (cpu = 1; cpu < 4 && cpu < NR_CPUS; ++cpu)
+		for (cpu = 1; cpu < 4 && cpu < nr_cpu_ids; ++cpu)
 			cpu_set(cpu, cpu_possible_map);
 		smp_ops = &psurge_smp_ops;
 	}
--- test-compile.orig/arch/powerpc/platforms/powermac/smp.c
+++ test-compile/arch/powerpc/platforms/powermac/smp.c
@@ -314,8 +314,8 @@ static int __init smp_psurge_probe(void)
 	 * device tree for them, and smp_setup_cpu_maps hasn't
 	 * set their bits in cpu_possible_map and cpu_present_map.
 	 */
-	if (ncpus > NR_CPUS)
-		ncpus = NR_CPUS;
+	if (ncpus > nr_cpu_ids)
+		ncpus = nr_cpu_ids;
 	for (i = 1; i < ncpus ; ++i) {
 		cpu_set(i, cpu_present_map);
 		set_hard_smp_processor_id(i, i);
--- test-compile.orig/arch/powerpc/platforms/pseries/hotplug-cpu.c
+++ test-compile/arch/powerpc/platforms/pseries/hotplug-cpu.c
@@ -221,7 +221,7 @@ static void pseries_remove_processor(str
 			set_hard_smp_processor_id(cpu, -1);
 			break;
 		}
-		if (cpu = NR_CPUS)
+		if (cpu >= nr_cpu_ids)
 			printk(KERN_WARNING "Could not find cpu to remove "
 			       "with physical id 0x%x\n", intserv[i]);
 	}
--- test-compile.orig/arch/powerpc/platforms/pseries/rtasd.c
+++ test-compile/arch/powerpc/platforms/pseries/rtasd.c
@@ -400,7 +400,7 @@ static void do_event_scan_all_cpus(long 
 		get_online_cpus();
 
 		cpu = next_cpu(cpu, cpu_online_map);
-		if (cpu = NR_CPUS)
+		if (cpu >= nr_cpu_ids)
 			break;
 	}
 	put_online_cpus();
--- test-compile.orig/arch/powerpc/platforms/pseries/xics.c
+++ test-compile/arch/powerpc/platforms/pseries/xics.c
@@ -164,7 +164,7 @@ static int get_irq_server(unsigned int v
 
 		server = first_cpu(tmp);
 
-		if (server < NR_CPUS)
+		if (server < nr_cpu_ids)
 			return get_hard_smp_processor_id(server);
 
 		if (strict_check)
--- test-compile.orig/arch/powerpc/xmon/xmon.c
+++ test-compile/arch/powerpc/xmon/xmon.c
@@ -938,7 +938,7 @@ static int cpu_cmd(void)
 		/* print cpus waiting or in xmon */
 		printf("cpus stopped:");
 		count = 0;
-		for (cpu = 0; cpu < NR_CPUS; ++cpu) {
+		for (cpu = 0; cpu < nr_cpu_ids; ++cpu) {
 			if (cpu_isset(cpu, cpus_in_xmon)) {
 				if (count = 0)
 					printf(" %x", cpu);
@@ -950,7 +950,7 @@ static int cpu_cmd(void)
 			}
 		}
 		if (count > 1)
-			printf("-%x", NR_CPUS - 1);
+			printf("-%x", nr_cpu_ids - 1);
 		printf("\n");
 		return 0;
 	}
--- test-compile.orig/arch/s390/kernel/smp.c
+++ test-compile/arch/s390/kernel/smp.c
@@ -444,7 +444,7 @@ static int smp_rescan_cpus_sigp(cpumask_
 	int cpu_id, logical_cpu;
 
 	logical_cpu = first_cpu(avail);
-	if (logical_cpu = NR_CPUS)
+	if (logical_cpu >= nr_cpu_ids)
 		return 0;
 	for (cpu_id = 0; cpu_id <= 65535; cpu_id++) {
 		if (cpu_known(cpu_id))
@@ -456,7 +456,7 @@ static int smp_rescan_cpus_sigp(cpumask_
 		cpu_set(logical_cpu, cpu_present_map);
 		smp_cpu_state[logical_cpu] = CPU_STATE_CONFIGURED;
 		logical_cpu = next_cpu(logical_cpu, avail);
-		if (logical_cpu = NR_CPUS)
+		if (logical_cpu >= nr_cpu_ids)
 			break;
 	}
 	return 0;
@@ -469,7 +469,7 @@ static int smp_rescan_cpus_sclp(cpumask_
 	int rc;
 
 	logical_cpu = first_cpu(avail);
-	if (logical_cpu = NR_CPUS)
+	if (logical_cpu >= nr_cpu_ids)
 		return 0;
 	info = kmalloc(sizeof(*info), GFP_KERNEL);
 	if (!info)
@@ -491,7 +491,7 @@ static int smp_rescan_cpus_sclp(cpumask_
 		else
 			smp_cpu_state[logical_cpu] = CPU_STATE_CONFIGURED;
 		logical_cpu = next_cpu(logical_cpu, avail);
-		if (logical_cpu = NR_CPUS)
+		if (logical_cpu >= nr_cpu_ids)
 			break;
 	}
 out:
@@ -733,7 +733,7 @@ static int __init setup_possible_cpus(ch
 
 	pcpus = simple_strtoul(s, NULL, 0);
 	cpu_possible_map = cpumask_of_cpu(0);
-	for (cpu = 1; cpu < pcpus && cpu < NR_CPUS; cpu++)
+	for (cpu = 1; cpu < pcpus && cpu < nr_cpu_ids; cpu++)
 		cpu_set(cpu, cpu_possible_map);
 	return 0;
 }
--- test-compile.orig/arch/sh/kernel/setup.c
+++ test-compile/arch/sh/kernel/setup.c
@@ -507,7 +507,7 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? cpu_data + *pos : NULL;
+	return *pos < nr_cpu_ids ? cpu_data + *pos : NULL;
 }
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
 {
--- test-compile.orig/arch/sparc/kernel/smp.c
+++ test-compile/arch/sparc/kernel/smp.c
@@ -72,13 +72,12 @@ void __init smp_cpus_done(unsigned int m
 	extern void smp4m_smp_done(void);
 	extern void smp4d_smp_done(void);
 	unsigned long bogosum = 0;
-	int cpu, num;
+	int cpu, num = 0;
 
-	for (cpu = 0, num = 0; cpu < NR_CPUS; cpu++)
-		if (cpu_online(cpu)) {
-			num++;
-			bogosum += cpu_data(cpu).udelay_val;
-		}
+	for_each_online_cpu(cpu) {
+		num++;
+		bogosum += cpu_data(cpu).udelay_val;
+	}
 
 	printk("Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
 		num, bogosum/(500000/HZ),
--- test-compile.orig/arch/sparc/kernel/sun4d_smp.c
+++ test-compile/arch/sparc/kernel/sun4d_smp.c
@@ -228,11 +228,10 @@ void __init smp4d_smp_done(void)
 	/* setup cpu list for irq rotation */
 	first = 0;
 	prev = &first;
-	for (i = 0; i < NR_CPUS; i++)
-		if (cpu_online(i)) {
-			*prev = i;
-			prev = &cpu_data(i).next;
-		}
+	for_each_online_cpu(i) {
+		*prev = i;
+		prev = &cpu_data(i).next;
+	}
 	*prev = first;
 	local_flush_cache_all();
 
--- test-compile.orig/arch/sparc/kernel/sun4m_smp.c
+++ test-compile/arch/sparc/kernel/sun4m_smp.c
@@ -185,11 +185,9 @@ void __init smp4m_smp_done(void)
 	/* setup cpu list for irq rotation */
 	first = 0;
 	prev = &first;
-	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_online(i)) {
-			*prev = i;
-			prev = &cpu_data(i).next;
-		}
+	for_each_online_cpu(i) {
+		*prev = i;
+		prev = &cpu_data(i).next;
 	}
 	*prev = first;
 	local_flush_cache_all();
--- test-compile.orig/arch/sparc/mm/srmmu.c
+++ test-compile/arch/sparc/mm/srmmu.c
@@ -1427,7 +1427,7 @@ static void __init init_vac_layout(void)
 				min_line_size = vac_line_size;
 			//FIXME: cpus not contiguous!!
 			cpu++;
-			if (cpu >= NR_CPUS || !cpu_online(cpu))
+			if (cpu >= nr_cpu_ids || !cpu_online(cpu))
 				break;
 #else
 			break;
--- test-compile.orig/arch/sparc64/kernel/ds.c
+++ test-compile/arch/sparc64/kernel/ds.c
@@ -653,7 +653,7 @@ static void __cpuinit dr_cpu_data(struct
 		if (cpu_list[i] = CPU_SENTINEL)
 			continue;
 
-		if (cpu_list[i] < NR_CPUS)
+		if (cpu_list[i] < nr_cpu_ids)
 			cpu_set(cpu_list[i], mask);
 	}
 
--- test-compile.orig/arch/sparc64/kernel/irq.c
+++ test-compile/arch/sparc64/kernel/irq.c
@@ -260,12 +260,12 @@ static int irq_choose_cpu(unsigned int v
 		spin_lock_irqsave(&irq_rover_lock, flags);
 
 		while (!cpu_online(irq_rover)) {
-			if (++irq_rover >= NR_CPUS)
+			if (++irq_rover >= nr_cpu_ids)
 				irq_rover = 0;
 		}
 		cpuid = irq_rover;
 		do {
-			if (++irq_rover >= NR_CPUS)
+			if (++irq_rover >= nr_cpu_ids)
 				irq_rover = 0;
 		} while (!cpu_online(irq_rover));
 
--- test-compile.orig/arch/sparc64/mm/init.c
+++ test-compile/arch/sparc64/mm/init.c
@@ -1080,7 +1080,7 @@ static void __init numa_parse_mdesc_grou
 		if (strcmp(name, "cpu"))
 			continue;
 		id = mdesc_get_property(md, target, "id", NULL);
-		if (*id < NR_CPUS)
+		if (*id < nr_cpu_ids)
 			cpu_set(*id, *mask);
 	}
 }
--- test-compile.orig/arch/um/kernel/um_arch.c
+++ test-compile/arch/um/kernel/um_arch.c
@@ -80,7 +80,7 @@ static int show_cpuinfo(struct seq_file 
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < NR_CPUS ? cpu_data + *pos : NULL;
+	return *pos < nr_cpu_ids ? cpu_data + *pos : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
--- test-compile.orig/arch/x86/kernel/apic.c
+++ test-compile/arch/x86/kernel/apic.c
@@ -2106,7 +2106,7 @@ __cpuinit int apic_is_clustered_box(void
 	bios_cpu_apicid = early_per_cpu_ptr(x86_bios_cpu_apicid);
 	bitmap_zero(clustermap, NUM_APIC_CLUSTERS);
 
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		/* are we being called early in kernel startup? */
 		if (bios_cpu_apicid) {
 			id = bios_cpu_apicid[i];
--- test-compile.orig/arch/x86/kernel/irq_32.c
+++ test-compile/arch/x86/kernel/irq_32.c
@@ -246,7 +246,7 @@ void fixup_irqs(cpumask_t map)
 			continue;
 
 		cpus_and(mask, desc->affinity, map);
-		if (any_online_cpu(mask) = NR_CPUS) {
+		if (any_online_cpu(mask) >= nr_cpu_ids) {
 			printk("Breaking affinity for irq %i\n", irq);
 			mask = map;
 		}
--- test-compile.orig/arch/x86/mach-voyager/voyager_smp.c
+++ test-compile/arch/x86/mach-voyager/voyager_smp.c
@@ -668,7 +668,7 @@ void __init smp_boot_cpus(void)
 
 	/* loop over all the extended VIC CPUs and boot them.  The
 	 * Quad CPUs must be bootstrapped by their extended VIC cpu */
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		if (i = boot_cpu_id || !cpu_isset(i, phys_cpu_present_map))
 			continue;
 		do_boot_cpu(i);
--- test-compile.orig/arch/x86/mm/numa_64.c
+++ test-compile/arch/x86/mm/numa_64.c
@@ -278,7 +278,7 @@ void __init numa_init_array(void)
 	int rr, i;
 
 	rr = first_node(node_online_map);
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		if (early_cpu_to_node(i) != NUMA_NO_NODE)
 			continue;
 		numa_set_node(i, rr);
@@ -549,7 +549,7 @@ void __init initmem_init(unsigned long s
 	memnodemap[0] = 0;
 	node_set_online(0);
 	node_set(0, node_possible_map);
-	for (i = 0; i < NR_CPUS; i++)
+	for (i = 0; i < nr_cpu_ids; i++)
 		numa_set_node(i, 0);
 	e820_register_active_regions(0, start_pfn, last_pfn);
 	setup_node_bootmem(0, start_pfn << PAGE_SHIFT, last_pfn << PAGE_SHIFT);
--- test-compile.orig/arch/x86/mm/srat_64.c
+++ test-compile/arch/x86/mm/srat_64.c
@@ -382,7 +382,7 @@ int __init acpi_scan_nodes(unsigned long
 		if (!node_online(i))
 			setup_node_bootmem(i, nodes[i].start, nodes[i].end);
 
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		int node = early_cpu_to_node(i);
 
 		if (node = NUMA_NO_NODE)
--- test-compile.orig/drivers/infiniband/hw/ehca/ehca_irq.c
+++ test-compile/drivers/infiniband/hw/ehca/ehca_irq.c
@@ -922,7 +922,7 @@ void ehca_destroy_comp_pool(void)
 
 	unregister_hotcpu_notifier(&comp_pool_callback_nb);
 
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		if (cpu_online(i))
 			destroy_comp_task(pool, i);
 	}
--- test-compile.orig/kernel/kexec.c
+++ test-compile/kernel/kexec.c
@@ -1115,7 +1115,7 @@ void crash_save_cpu(struct pt_regs *regs
 	struct elf_prstatus prstatus;
 	u32 *buf;
 
-	if ((cpu < 0) || (cpu >= NR_CPUS))
+	if ((cpu < 0) || (cpu >= nr_cpu_ids))
 		return;
 
 	/* Using ELF notes here is opportunistic.
--- test-compile.orig/kernel/smp.c
+++ test-compile/kernel/smp.c
@@ -222,7 +222,7 @@ int smp_call_function_single(int cpu, vo
 		local_irq_save(flags);
 		func(info);
 		local_irq_restore(flags);
-	} else if ((unsigned)cpu < NR_CPUS && cpu_online(cpu)) {
+	} else if ((unsigned)cpu < nr_cpu_ids && cpu_online(cpu)) {
 		struct call_single_data *data = NULL;
 
 		if (!wait) {
--- test-compile.orig/net/core/neighbour.c
+++ test-compile/net/core/neighbour.c
@@ -2423,7 +2423,7 @@ static void *neigh_stat_seq_start(struct
 	if (*pos = 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
@@ -2438,7 +2438,7 @@ static void *neigh_stat_seq_next(struct 
 	struct neigh_table *tbl = pde->data;
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
--- test-compile.orig/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ test-compile/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -291,7 +291,7 @@ static void *ct_cpu_seq_start(struct seq
 	if (*pos = 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
@@ -306,7 +306,7 @@ static void *ct_cpu_seq_next(struct seq_
 	struct net *net = seq_file_net(seq);
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
--- test-compile.orig/net/ipv4/route.c
+++ test-compile/net/ipv4/route.c
@@ -427,7 +427,7 @@ static void *rt_cpu_seq_start(struct seq
 	if (*pos = 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
@@ -440,7 +440,7 @@ static void *rt_cpu_seq_next(struct seq_
 {
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
--- test-compile.orig/net/netfilter/nf_conntrack_standalone.c
+++ test-compile/net/netfilter/nf_conntrack_standalone.c
@@ -200,7 +200,7 @@ static void *ct_cpu_seq_start(struct seq
 	if (*pos = 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
@@ -215,7 +215,7 @@ static void *ct_cpu_seq_next(struct seq_
 	struct net *net = seq_file_net(seq);
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
--- test-compile.orig/security/selinux/selinuxfs.c
+++ test-compile/security/selinux/selinuxfs.c
@@ -1206,7 +1206,7 @@ static struct avc_cache_stats *sel_avc_g
 {
 	int cpu;
 
-	for (cpu = *idx; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *idx; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*idx = cpu + 1;

-- 

From: Christoph Lameter <cl@linux.com>
Date: Fri, 17 Jan 2014 15:18:44 +0000
Subject: [PATCH 32/41] ia64: Replace __get_cpu_var uses
Message-Id: <20140117151837.735181743@linux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140117151812.770437629@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

__get_cpu_var() is used for multiple purposes in the kernel source. One of
them is address calculation via the form &__get_cpu_var(x).  This calculates
the address for the instance of the percpu variable of the current processor
based on an offset.

Other use cases are for storing and retrieving data from the current
processors percpu area.  __get_cpu_var() can be used as an lvalue when
writing data or on the right side of an assignment.

__get_cpu_var() is defined as :


#define __get_cpu_var(var) (*this_cpu_ptr(&(var)))



__get_cpu_var() always only does an address determination. However, store
and retrieve operations could use a segment prefix (or global register on
other platforms) to avoid the address calculation.

this_cpu_write() and this_cpu_read() can directly take an offset into a
percpu area and use optimized assembly code to read and write per cpu
variables.


This patch converts __get_cpu_var into either an explicit address
calculation using this_cpu_ptr() or into a use of this_cpu operations that
use the offset.  Thereby address calculations are avoided and less registers
are used when code is generated.

At the end of the patch set all uses of __get_cpu_var have been removed so
the macro is removed too.

The patch set includes passes over all arches as well. Once these operations
are used throughout then specialized macros can be defined in non -x86
arches as well in order to optimize per cpu access by f.e.  using a global
register that may be set to the per cpu base.




Transformations done to __get_cpu_var()


1. Determine the address of the percpu instance of the current processor.

	DEFINE_PER_CPU(int, y);
	int *x = &__get_cpu_var(y);

    Converts to

	int *x = this_cpu_ptr(&y);


2. Same as #1 but this time an array structure is involved.

	DEFINE_PER_CPU(int, y[20]);
	int *x = __get_cpu_var(y);

    Converts to

	int *x = this_cpu_ptr(y);


3. Retrieve the content of the current processors instance of a per cpu
variable.

	DEFINE_PER_CPU(int, y);
	int x = __get_cpu_var(y)

   Converts to

	int x = __this_cpu_read(y);


4. Retrieve the content of a percpu struct

	DEFINE_PER_CPU(struct mystruct, y);
	struct mystruct x = __get_cpu_var(y);

   Converts to

	memcpy(&x, this_cpu_ptr(&y), sizeof(x));


5. Assignment to a per cpu variable

	DEFINE_PER_CPU(int, y)
	__get_cpu_var(y) = x;

   Converts to

	__this_cpu_write(y, x);


6. Increment/Decrement etc of a per cpu variable

	DEFINE_PER_CPU(int, y);
	__get_cpu_var(y)++

   Converts to

	__this_cpu_inc(y)


Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/arch/alpha/kernel/perf_event.c
=================================--- linux.orig/arch/alpha/kernel/perf_event.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/alpha/kernel/perf_event.c	2013-12-02 16:09:11.000000000 -0600
@@ -814,7 +814,7 @@ static void alpha_perf_event_irq_handler
 	struct hw_perf_event *hwc;
 	int idx, j;
 
-	__get_cpu_var(irq_pmi_count)++;
+	__this_cpu_inc(irq_pmi_count);
 	cpuc = &__get_cpu_var(cpu_hw_events);
 
 	/* Completely counting through the PMC's period to trigger a new PMC
Index: linux/arch/ia64/kernel/irq.c
=================================--- linux.orig/arch/ia64/kernel/irq.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/kernel/irq.c	2013-12-02 16:07:59.114374572 -0600
@@ -42,7 +42,7 @@ ia64_vector __ia64_irq_to_vector(int irq
 
 unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return __get_cpu_var(vector_irq)[vec];
+	return __this_cpu_read(vector_irq[vec]);
 }
 #endif
 
Index: linux/arch/ia64/kernel/irq_ia64.c
=================================--- linux.orig/arch/ia64/kernel/irq_ia64.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/kernel/irq_ia64.c	2013-12-02 16:07:59.114374572 -0600
@@ -338,7 +338,7 @@ static irqreturn_t smp_irq_move_cleanup_
 		int irq;
 		struct irq_desc *desc;
 		struct irq_cfg *cfg;
-		irq = __get_cpu_var(vector_irq)[vector];
+		irq = __this_cpu_read(vector_irq[vector]);
 		if (irq < 0)
 			continue;
 
@@ -352,7 +352,7 @@ static irqreturn_t smp_irq_move_cleanup_
 			goto unlock;
 
 		spin_lock_irqsave(&vector_lock, flags);
-		__get_cpu_var(vector_irq)[vector] = -1;
+		__this_cpu_write(vector_irq[vector], -1);
 		cpu_clear(me, vector_table[vector]);
 		spin_unlock_irqrestore(&vector_lock, flags);
 		cfg->move_cleanup_count--;
Index: linux/arch/ia64/kernel/kprobes.c
=================================--- linux.orig/arch/ia64/kernel/kprobes.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/kernel/kprobes.c	2013-12-02 16:07:59.114374572 -0600
@@ -396,7 +396,7 @@ static void __kprobes restore_previous_k
 {
 	unsigned int i;
 	i = atomic_read(&kcb->prev_kprobe_index);
-	__get_cpu_var(current_kprobe) = kcb->prev_kprobe[i-1].kp;
+	__this_cpu_write(current_kprobe, kcb->prev_kprobe[i-1].kp);
 	kcb->kprobe_status = kcb->prev_kprobe[i-1].status;
 	atomic_sub(1, &kcb->prev_kprobe_index);
 }
@@ -404,7 +404,7 @@ static void __kprobes restore_previous_k
 static void __kprobes set_current_kprobe(struct kprobe *p,
 			struct kprobe_ctlblk *kcb)
 {
-	__get_cpu_var(current_kprobe) = p;
+	__this_cpu_write(current_kprobe, p);
 }
 
 static void kretprobe_trampoline(void)
@@ -823,7 +823,7 @@ static int __kprobes pre_kprobes_handler
 			/*
 			 * jprobe instrumented function just completed
 			 */
-			p = __get_cpu_var(current_kprobe);
+			p = __this_cpu_read(current_kprobe);
 			if (p->break_handler && p->break_handler(p, regs)) {
 				goto ss_probe;
 			}
Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/kernel/mca.c	2013-12-02 16:07:59.114374572 -0600
@@ -1341,7 +1341,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 		ia64_mlogbuf_finish(1);
 	}
 
-	if (__get_cpu_var(ia64_mca_tr_reload)) {
+	if (__this_cpu_read(ia64_mca_tr_reload)) {
 		mca_insert_tr(0x1); /*Reload dynamic itrs*/
 		mca_insert_tr(0x2); /*Reload dynamic itrs*/
 	}
@@ -1874,14 +1874,14 @@ ia64_mca_cpu_init(void *cpu_data)
 		"MCA", cpu);
 	format_mca_init_stack(data, offsetof(struct ia64_mca_cpu, init_stack),
 		"INIT", cpu);
-	__get_cpu_var(ia64_mca_data) = __per_cpu_mca[cpu] = __pa(data);
+	__this_cpu_write(ia64_mca_data, (__per_cpu_mca[cpu] = __pa(data)));
 
 	/*
 	 * Stash away a copy of the PTE needed to map the per-CPU page.
 	 * We may need it during MCA recovery.
 	 */
-	__get_cpu_var(ia64_mca_per_cpu_pte) -		pte_val(mk_pte_phys(__pa(cpu_data), PAGE_KERNEL));
+	__this_cpu_write(ia64_mca_per_cpu_pte,
+		pte_val(mk_pte_phys(__pa(cpu_data), PAGE_KERNEL)));
 
 	/*
 	 * Also, stash away a copy of the PAL address and the PTE
@@ -1890,10 +1890,10 @@ ia64_mca_cpu_init(void *cpu_data)
 	pal_vaddr = efi_get_pal_addr();
 	if (!pal_vaddr)
 		return;
-	__get_cpu_var(ia64_mca_pal_base) -		GRANULEROUNDDOWN((unsigned long) pal_vaddr);
-	__get_cpu_var(ia64_mca_pal_pte) = pte_val(mk_pte_phys(__pa(pal_vaddr),
-							      PAGE_KERNEL));
+	__this_cpu_write(ia64_mca_pal_base,
+		GRANULEROUNDDOWN((unsigned long) pal_vaddr));
+	__this_cpu_write(ia64_mca_pal_pte, pte_val(mk_pte_phys(__pa(pal_vaddr),
+							      PAGE_KERNEL)));
 }
 
 static void ia64_mca_cmc_vector_adjust(void *dummy)
Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/kernel/process.c	2013-12-02 16:07:59.114374572 -0600
@@ -215,7 +215,7 @@ static inline void play_dead(void)
 	unsigned int this_cpu = smp_processor_id();
 
 	/* Ack it */
-	__get_cpu_var(cpu_state) = CPU_DEAD;
+	__this_cpu_write(cpu_state, CPU_DEAD);
 
 	max_xtp();
 	local_irq_disable();
@@ -273,7 +273,7 @@ ia64_save_extra (struct task_struct *tas
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) != 0)
 		pfm_save_regs(task);
 
-	info = __get_cpu_var(pfm_syst_info);
+	info = __this_cpu_read(pfm_syst_info);
 	if (info & PFM_CPUINFO_SYST_WIDE)
 		pfm_syst_wide_update_task(task, info, 0);
 #endif
@@ -293,7 +293,7 @@ ia64_load_extra (struct task_struct *tas
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) != 0)
 		pfm_load_regs(task);
 
-	info = __get_cpu_var(pfm_syst_info);
+	info = __this_cpu_read(pfm_syst_info);
 	if (info & PFM_CPUINFO_SYST_WIDE) 
 		pfm_syst_wide_update_task(task, info, 1);
 #endif
Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2013-12-02 16:07:59.114374572 -0600
@@ -134,8 +134,8 @@ sn2_ipi_flush_all_tlb(struct mm_struct *
 	itc = ia64_get_itc();
 	smp_flush_tlb_cpumask(*mm_cpumask(mm));
 	itc = ia64_get_itc() - itc;
-	__get_cpu_var(ptcstats).shub_ipi_flushes_itc_clocks += itc;
-	__get_cpu_var(ptcstats).shub_ipi_flushes++;
+	__this_cpu_add(ptcstats.shub_ipi_flushes_itc_clocks, itc);
+	__this_cpu_inc(ptcstats.shub_ipi_flushes);
 }
 
 /**
@@ -199,14 +199,14 @@ sn2_global_tlb_purge(struct mm_struct *m
 			start += (1UL << nbits);
 		} while (start < end);
 		ia64_srlz_i();
-		__get_cpu_var(ptcstats).ptc_l++;
+		__this_cpu_inc(ptcstats.ptc_l);
 		preempt_enable();
 		return;
 	}
 
 	if (atomic_read(&mm->mm_users) = 1 && mymm) {
 		flush_tlb_mm(mm);
-		__get_cpu_var(ptcstats).change_rid++;
+		__this_cpu_inc(ptcstats.change_rid);
 		preempt_enable();
 		return;
 	}
@@ -250,11 +250,11 @@ sn2_global_tlb_purge(struct mm_struct *m
 	spin_lock_irqsave(PTC_LOCK(shub1), flags);
 	itc2 = ia64_get_itc();
 
-	__get_cpu_var(ptcstats).lock_itc_clocks += itc2 - itc;
-	__get_cpu_var(ptcstats).shub_ptc_flushes++;
-	__get_cpu_var(ptcstats).nodes_flushed += nix;
+	__this_cpu_add(ptcstats.lock_itc_clocks, itc2 - itc);
+	__this_cpu_inc(ptcstats.shub_ptc_flushes);
+	__this_cpu_add(ptcstats.nodes_flushed, nix);
 	if (!mymm)
-		 __get_cpu_var(ptcstats).shub_ptc_flushes_not_my_mm++;
+		 __this_cpu_inc(ptcstats.shub_ptc_flushes_not_my_mm);
 
 	if (use_cpu_ptcga && !mymm) {
 		old_rr = ia64_get_rr(start);
@@ -299,9 +299,9 @@ sn2_global_tlb_purge(struct mm_struct *m
 
 done:
 	itc2 = ia64_get_itc() - itc2;
-	__get_cpu_var(ptcstats).shub_itc_clocks += itc2;
-	if (itc2 > __get_cpu_var(ptcstats).shub_itc_clocks_max)
-		__get_cpu_var(ptcstats).shub_itc_clocks_max = itc2;
+	__this_cpu_add(ptcstats)shub_itc_clocks, itc2);
+	if (itc2 > __this_cpu_read(ptcstats.shub_itc_clocks_max))
+		__this_cpu_write(ptcstats).shub_itc_clocks_max, itc2);
 
 	if (old_rr) {
 		ia64_set_rr(start, old_rr);
@@ -311,7 +311,7 @@ done:
 	spin_unlock_irqrestore(PTC_LOCK(shub1), flags);
 
 	if (flush_opt = 1 && deadlock) {
-		__get_cpu_var(ptcstats).deadlocks++;
+		__this_cpu_inc(ptcstats.deadlocks);
 		sn2_ipi_flush_all_tlb(mm);
 	}
 
@@ -334,7 +334,7 @@ sn2_ptc_deadlock_recovery(short *nasids,
 	short nasid, i;
 	unsigned long *piows, zeroval, n;
 
-	__get_cpu_var(ptcstats).deadlocks++;
+	__this_cpu_inc(ptcstats.deadlocks);
 
 	piows = (unsigned long *) pda->pio_write_status_addr;
 	zeroval = pda->pio_write_status_val;
@@ -349,7 +349,7 @@ sn2_ptc_deadlock_recovery(short *nasids,
 			ptc1 = CHANGE_NASID(nasid, ptc1);
 
 		n = sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
-		__get_cpu_var(ptcstats).deadlocks2 += n;
+		__this_cpu_add(ptcstats.deadlocks2, n);
 	}
 
 }
Index: linux/arch/ia64/include/asm/hw_irq.h
=================================--- linux.orig/arch/ia64/include/asm/hw_irq.h	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/include/asm/hw_irq.h	2013-12-02 16:07:59.114374572 -0600
@@ -160,7 +160,7 @@ static inline ia64_vector __ia64_irq_to_
 static inline unsigned int
 __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return __get_cpu_var(vector_irq)[vec];
+	return __this_cpu_read(vector_irq[vec]);
 }
 #endif
 
Index: linux/arch/ia64/include/asm/sn/nodepda.h
=================================--- linux.orig/arch/ia64/include/asm/sn/nodepda.h	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/include/asm/sn/nodepda.h	2013-12-02 16:07:59.114374572 -0600
@@ -70,7 +70,7 @@ typedef struct nodepda_s nodepda_t;
  */
 
 DECLARE_PER_CPU(struct nodepda_s *, __sn_nodepda);
-#define sn_nodepda		(__get_cpu_var(__sn_nodepda))
+#define sn_nodepda		__this_cpu_read(__sn_nodepda)
 #define	NODEPDA(cnodeid)	(sn_nodepda->pernode_pdaindr[cnodeid])
 
 /*
Index: linux/arch/ia64/include/asm/switch_to.h
=================================--- linux.orig/arch/ia64/include/asm/switch_to.h	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/include/asm/switch_to.h	2013-12-02 16:07:59.114374572 -0600
@@ -32,7 +32,7 @@ extern void ia64_load_extra (struct task
 
 #ifdef CONFIG_PERFMON
   DECLARE_PER_CPU(unsigned long, pfm_syst_info);
-# define PERFMON_IS_SYSWIDE() (__get_cpu_var(pfm_syst_info) & 0x1)
+# define PERFMON_IS_SYSWIDE() (__this_cpu_read(pfm_syst_info) & 0x1)
 #else
 # define PERFMON_IS_SYSWIDE() (0)
 #endif
Index: linux/arch/ia64/include/asm/sn/arch.h
=================================--- linux.orig/arch/ia64/include/asm/sn/arch.h	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/include/asm/sn/arch.h	2013-12-02 16:07:59.114374572 -0600
@@ -57,7 +57,7 @@ struct sn_hub_info_s {
 	u16 nasid_bitmask;
 };
 DECLARE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
-#define sn_hub_info 	(&__get_cpu_var(__sn_hub_info))
+#define sn_hub_info 	this_cpu_ptr(&__sn_hub_info)
 #define is_shub2()	(sn_hub_info->shub2)
 #define is_shub1()	(sn_hub_info->shub2 = 0)
 
@@ -72,7 +72,7 @@ DECLARE_PER_CPU(struct sn_hub_info_s, __
  * cpu.
  */
 DECLARE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
-#define sn_cnodeid_to_nasid	(&__get_cpu_var(__sn_cnodeid_to_nasid[0]))
+#define sn_cnodeid_to_nasid	this_cpu_ptr(&__sn_cnodeid_to_nasid[0])
 
 
 extern u8 sn_partition_id;
Index: linux/arch/ia64/include/asm/uv/uv_hub.h
=================================--- linux.orig/arch/ia64/include/asm/uv/uv_hub.h	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/include/asm/uv/uv_hub.h	2013-12-02 16:07:59.114374572 -0600
@@ -108,7 +108,7 @@ struct uv_hub_info_s {
 	unsigned char	n_val;
 };
 DECLARE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
-#define uv_hub_info 		(&__get_cpu_var(__uv_hub_info))
+#define uv_hub_info 		this_cpu_ptr(&__uv_hub_info)
 #define uv_cpu_hub_info(cpu)	(&per_cpu(__uv_hub_info, cpu))
 
 /*
Index: linux/arch/ia64/kernel/traps.c
=================================--- linux.orig/arch/ia64/kernel/traps.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/kernel/traps.c	2013-12-02 16:07:59.114374572 -0600
@@ -299,7 +299,7 @@ handle_fpu_swa (int fp_fault, struct pt_
 
 	if (!(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT))  {
 		unsigned long count, current_jiffies = jiffies;
-		struct fpu_swa_msg *cp = &__get_cpu_var(cpulast);
+		struct fpu_swa_msg *cp = this_cpu_ptr(&cpulast);
 
 		if (unlikely(current_jiffies > cp->time))
 			cp->count = 0;
Index: linux/arch/ia64/xen/time.c
=================================--- linux.orig/arch/ia64/xen/time.c	2013-12-02 16:07:59.114374572 -0600
+++ linux/arch/ia64/xen/time.c	2013-12-02 16:07:59.114374572 -0600
@@ -68,7 +68,7 @@ static void get_runstate_snapshot(struct
 
 	BUG_ON(preemptible());
 
-	state = &__get_cpu_var(xen_runstate);
+	state = this_cpu_ptr(&xen_runstate);
 
 	/*
 	 * The runstate info is always updated by the hypervisor on


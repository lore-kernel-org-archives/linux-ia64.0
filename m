From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Sep 2004 21:52:58 +0000
Subject: RFC - freeing up ar.k5
Message-Id: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Well, this is what a patch to free up ar.k5 by replacing its use
with a percpu variable looks like.

Downside is a possible cache miss reading the variable in 'schedule()'.

Upside is freeing up ar.k5 ... whose use would get rid of much ugliness
in the mca tlb recovery code (and in the impending per-cpu save areas
for INIT/MCA).

-Tony

=== arch/ia64/kernel/setup.c 1.79 vs edited ==--- 1.79/arch/ia64/kernel/setup.c	2004-08-04 18:08:05 +00:00
+++ edited/arch/ia64/kernel/setup.c	2004-09-16 21:17:38 +00:00
@@ -64,6 +64,7 @@
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
 DEFINE_PER_CPU(unsigned long, ia64_phys_stacked_size_p8);
+DEFINE_PER_CPU(struct task_struct *, ia64_fpu_owner);
 unsigned long ia64_cycles_per_usec;
 struct ia64_boot_param *ia64_boot_param;
 struct screen_info screen_info;
@@ -628,7 +629,7 @@
 	/* Clear the stack memory reserved for pt_regs: */
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
 
-	ia64_set_kr(IA64_KR_FPU_OWNER, 0);
+	__get_cpu_var(ia64_fpu_owner) = 0;
 
 	/*
 	 * Initialize default control register to defer all speculative faults.  The
=== arch/ia64/kernel/traps.c 1.46 vs edited ==--- 1.46/arch/ia64/kernel/traps.c	2004-09-08 06:32:57 +00:00
+++ edited/arch/ia64/kernel/traps.c	2004-09-16 21:18:09 +00:00
@@ -204,8 +204,7 @@
 	psr->dfh = 0;
 #ifndef CONFIG_SMP
 	{
-		struct task_struct *fpu_owner
-			= (struct task_struct *)ia64_get_kr(IA64_KR_FPU_OWNER);
+		struct task_struct *fpu_owner = __get_cpu_var(ia64_fpu_owner);
 
 		if (ia64_is_local_fpu_owner(current))
 			return;
=== include/asm-ia64/kregs.h 1.6 vs edited ==--- 1.6/include/asm-ia64/kregs.h	2003-06-06 14:20:51 +00:00
+++ edited/include/asm-ia64/kregs.h	2004-09-16 21:37:01 +00:00
@@ -15,7 +15,6 @@
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
-#define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
 #define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
 #define IA64_KR_PT_BASE		7	/* ar.k7: page table base address (physical) */
 
=== include/asm-ia64/processor.h 1.62 vs edited ==--- 1.62/include/asm-ia64/processor.h	2004-08-24 09:08:09 +00:00
+++ edited/include/asm-ia64/processor.h	2004-09-16 21:19:04 +00:00
@@ -423,20 +423,21 @@
  * The following three macros can't be inline functions because we don't have struct
  * task_struct at this point.
  */
+DECLARE_PER_CPU(struct task_struct *, ia64_fpu_owner);
 
 /* Return TRUE if task T owns the fph partition of the CPU we're running on. */
 #define ia64_is_local_fpu_owner(t)								\
 ({												\
 	struct task_struct *__ia64_islfo_task = (t);						\
 	(__ia64_islfo_task->thread.last_fph_cpu = smp_processor_id()				\
-	 && __ia64_islfo_task = (struct task_struct *) ia64_get_kr(IA64_KR_FPU_OWNER));	\
+	 && __ia64_islfo_task = __get_cpu_var(ia64_fpu_owner));						\
 })
 
 /* Mark task T as owning the fph partition of the CPU we're running on. */
 #define ia64_set_local_fpu_owner(t) do {						\
 	struct task_struct *__ia64_slfo_task = (t);					\
 	__ia64_slfo_task->thread.last_fph_cpu = smp_processor_id();			\
-	ia64_set_kr(IA64_KR_FPU_OWNER, (unsigned long) __ia64_slfo_task);		\
+	__get_cpu_var(ia64_fpu_owner) = __ia64_slfo_task;						\
 } while (0)
 
 /* Mark the fph partition of task T as being invalid on all CPUs.  */

From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:50 +0000
Subject: [PATCH 31/35] cpumask: switch over to cpu_online/possible/active/present_mask
Message-Id: <20081020170323.873181000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

In order to hide the definition of struct cpumask, we need to expose
only pointers.  Plus, it fits the new API far better to have pointers.

This deprecates the old _map versions, and defines them in terms of the
_mask versions.  It also centralizes the definitions (finally!).

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/alpha/kernel/smp.c             |    5 --
 arch/arm/kernel/smp.c               |   10 ----
 arch/cris/arch-v32/kernel/smp.c     |    4 -
 arch/ia64/kernel/smpboot.c          |    6 --
 arch/m32r/kernel/smpboot.c          |    6 --
 arch/mips/kernel/smp.c              |    2 
 arch/parisc/kernel/smp.c            |   15 ------
 arch/powerpc/kernel/smp.c           |    4 -
 arch/s390/kernel/smp.c              |    6 --
 arch/sh/kernel/smp.c                |    6 --
 arch/sparc/kernel/sparc_ksyms.c     |    2 
 arch/sparc64/kernel/smp.c           |    4 -
 arch/um/kernel/smp.c                |    7 --
 arch/x86/kernel/smpboot.c           |    6 --
 arch/x86/mach-voyager/voyager_smp.c |    7 --
 include/linux/cpumask.h             |   86 +++++++++++++++---------------------
 kernel/cpu.c                        |   67 ++++++++++++----------------
 17 files changed, 67 insertions(+), 176 deletions(-)

--- linux-2.6.28.orig/arch/alpha/kernel/smp.c
+++ linux-2.6.28/arch/alpha/kernel/smp.c
@@ -69,11 +69,6 @@ enum ipi_message_type {
 /* Set to a secondary's cpuid when it comes online.  */
 static int smp_secondary_alive __devinitdata = 0;
 
-/* Which cpus ids came online.  */
-cpumask_t cpu_online_map;
-
-EXPORT_SYMBOL(cpu_online_map);
-
 int smp_num_probed;		/* Internal processor count */
 int smp_num_cpus = 1;		/* Number that came online.  */
 EXPORT_SYMBOL(smp_num_cpus);
--- linux-2.6.28.orig/arch/arm/kernel/smp.c
+++ linux-2.6.28/arch/arm/kernel/smp.c
@@ -34,16 +34,6 @@
 #include <asm/ptrace.h>
 
 /*
- * bitmask of present and online CPUs.
- * The present bitmask indicates that the CPU is physically present.
- * The online bitmask indicates that the CPU is up and running.
- */
-cpumask_t cpu_possible_map;
-EXPORT_SYMBOL(cpu_possible_map);
-cpumask_t cpu_online_map;
-EXPORT_SYMBOL(cpu_online_map);
-
-/*
  * as from 2.5, kernels no longer have an init_tasks structure
  * so we need some other way of telling a new secondary core
  * where to place its SVC stack
--- linux-2.6.28.orig/arch/cris/arch-v32/kernel/smp.c
+++ linux-2.6.28/arch/cris/arch-v32/kernel/smp.c
@@ -29,11 +29,7 @@
 spinlock_t cris_atomic_locks[] = { [0 ... LOCK_COUNT - 1] = SPIN_LOCK_UNLOCKED};
 
 /* CPU masks */
-cpumask_t cpu_online_map = CPU_MASK_NONE;
-EXPORT_SYMBOL(cpu_online_map);
 cpumask_t phys_cpu_present_map = CPU_MASK_NONE;
-cpumask_t cpu_possible_map;
-EXPORT_SYMBOL(cpu_possible_map);
 EXPORT_SYMBOL(phys_cpu_present_map);
 
 /* Variables used during SMP boot */
--- linux-2.6.28.orig/arch/ia64/kernel/smpboot.c
+++ linux-2.6.28/arch/ia64/kernel/smpboot.c
@@ -131,12 +131,6 @@ struct task_struct *task_for_booting_cpu
  */
 DEFINE_PER_CPU(int, cpu_state);
 
-/* Bitmasks of currently online, and possible CPUs */
-cpumask_t cpu_online_map;
-EXPORT_SYMBOL(cpu_online_map);
-cpumask_t cpu_possible_map = CPU_MASK_NONE;
-EXPORT_SYMBOL(cpu_possible_map);
-
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
 EXPORT_SYMBOL(cpu_core_map);
 DEFINE_PER_CPU_SHARED_ALIGNED(cpumask_t, cpu_sibling_map);
--- linux-2.6.28.orig/arch/m32r/kernel/smpboot.c
+++ linux-2.6.28/arch/m32r/kernel/smpboot.c
@@ -72,17 +72,11 @@ static unsigned int bsp_phys_id = -1;
 /* Bitmask of physically existing CPUs */
 physid_mask_t phys_cpu_present_map;
 
-/* Bitmask of currently online CPUs */
-cpumask_t cpu_online_map;
-EXPORT_SYMBOL(cpu_online_map);
-
 cpumask_t cpu_bootout_map;
 cpumask_t cpu_bootin_map;
 static cpumask_t cpu_callin_map;
 cpumask_t cpu_callout_map;
 EXPORT_SYMBOL(cpu_callout_map);
-cpumask_t cpu_possible_map = CPU_MASK_ALL;
-EXPORT_SYMBOL(cpu_possible_map);
 
 /* Per CPU bogomips and other parameters */
 struct cpuinfo_m32r cpu_data[NR_CPUS] __cacheline_aligned;
--- linux-2.6.28.orig/arch/mips/kernel/smp.c
+++ linux-2.6.28/arch/mips/kernel/smp.c
@@ -46,12 +46,10 @@
 
 cpumask_t phys_cpu_present_map;		/* Bitmask of available CPUs */
 volatile cpumask_t cpu_callin_map;	/* Bitmask of started secondaries */
-cpumask_t cpu_online_map;		/* Bitmask of currently online CPUs */
 int __cpu_number_map[NR_CPUS];		/* Map physical to logical */
 int __cpu_logical_map[NR_CPUS];		/* Map logical to physical */
 
 EXPORT_SYMBOL(phys_cpu_present_map);
-EXPORT_SYMBOL(cpu_online_map);
 
 extern void cpu_idle(void);
 
--- linux-2.6.28.orig/arch/parisc/kernel/smp.c
+++ linux-2.6.28/arch/parisc/kernel/smp.c
@@ -67,21 +67,6 @@ static volatile int cpu_now_booting __re
 
 static int parisc_max_cpus __read_mostly = 1;
 
-/* online cpus are ones that we've managed to bring up completely
- * possible cpus are all valid cpu 
- * present cpus are all detected cpu
- *
- * On startup we bring up the "possible" cpus. Since we discover
- * CPUs later, we add them as hotplug, so the possible cpu mask is
- * empty in the beginning.
- */
-
-cpumask_t cpu_online_map   __read_mostly = CPU_MASK_NONE;	/* Bitmap of online CPUs */
-cpumask_t cpu_possible_map __read_mostly = CPU_MASK_ALL;	/* Bitmap of Present CPUs */
-
-EXPORT_SYMBOL(cpu_online_map);
-EXPORT_SYMBOL(cpu_possible_map);
-
 DEFINE_PER_CPU(spinlock_t, ipi_lock) = SPIN_LOCK_UNLOCKED;
 
 enum ipi_message_type {
--- linux-2.6.28.orig/arch/powerpc/kernel/smp.c
+++ linux-2.6.28/arch/powerpc/kernel/smp.c
@@ -60,13 +60,9 @@
 int smp_hw_index[NR_CPUS];
 struct thread_info *secondary_ti;
 
-cpumask_t cpu_possible_map = CPU_MASK_NONE;
-cpumask_t cpu_online_map = CPU_MASK_NONE;
 DEFINE_PER_CPU(cpumask_t, cpu_sibling_map) = CPU_MASK_NONE;
 DEFINE_PER_CPU(cpumask_t, cpu_core_map) = CPU_MASK_NONE;
 
-EXPORT_SYMBOL(cpu_online_map);
-EXPORT_SYMBOL(cpu_possible_map);
 EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 EXPORT_PER_CPU_SYMBOL(cpu_core_map);
 
--- linux-2.6.28.orig/arch/s390/kernel/smp.c
+++ linux-2.6.28/arch/s390/kernel/smp.c
@@ -52,12 +52,6 @@
 struct _lowcore *lowcore_ptr[NR_CPUS];
 EXPORT_SYMBOL(lowcore_ptr);
 
-cpumask_t cpu_online_map = CPU_MASK_NONE;
-EXPORT_SYMBOL(cpu_online_map);
-
-cpumask_t cpu_possible_map = CPU_MASK_ALL;
-EXPORT_SYMBOL(cpu_possible_map);
-
 static struct task_struct *current_set[NR_CPUS];
 
 static u8 smp_cpu_type;
--- linux-2.6.28.orig/arch/sh/kernel/smp.c
+++ linux-2.6.28/arch/sh/kernel/smp.c
@@ -30,12 +30,6 @@
 int __cpu_number_map[NR_CPUS];		/* Map physical to logical */
 int __cpu_logical_map[NR_CPUS];		/* Map logical to physical */
 
-cpumask_t cpu_possible_map;
-EXPORT_SYMBOL(cpu_possible_map);
-
-cpumask_t cpu_online_map;
-EXPORT_SYMBOL(cpu_online_map);
-
 static inline void __init smp_store_cpu_info(unsigned int cpu)
 {
 	struct sh_cpuinfo *c = cpu_data + cpu;
--- linux-2.6.28.orig/arch/sparc/kernel/sparc_ksyms.c
+++ linux-2.6.28/arch/sparc/kernel/sparc_ksyms.c
@@ -114,8 +114,6 @@ EXPORT_PER_CPU_SYMBOL(__cpu_data);
 /* IRQ implementation. */
 EXPORT_SYMBOL(synchronize_irq);
 
-/* CPU online map and active count. */
-EXPORT_SYMBOL(cpu_online_map);
 EXPORT_SYMBOL(phys_cpu_present_map);
 #endif
 
--- linux-2.6.28.orig/arch/sparc64/kernel/smp.c
+++ linux-2.6.28/arch/sparc64/kernel/smp.c
@@ -49,14 +49,10 @@
 
 int sparc64_multi_core __read_mostly;
 
-cpumask_t cpu_possible_map __read_mostly = CPU_MASK_NONE;
-cpumask_t cpu_online_map __read_mostly = CPU_MASK_NONE;
 DEFINE_PER_CPU(cpumask_t, cpu_sibling_map) = CPU_MASK_NONE;
 cpumask_t cpu_core_map[NR_CPUS] __read_mostly  	{ [0 ... NR_CPUS-1] = CPU_MASK_NONE };
 
-EXPORT_SYMBOL(cpu_possible_map);
-EXPORT_SYMBOL(cpu_online_map);
 EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 EXPORT_SYMBOL(cpu_core_map);
 
--- linux-2.6.28.orig/arch/um/kernel/smp.c
+++ linux-2.6.28/arch/um/kernel/smp.c
@@ -25,13 +25,6 @@ DEFINE_PER_CPU(struct mmu_gather, mmu_ga
 #include "irq_user.h"
 #include "os.h"
 
-/* CPU online map, set by smp_boot_cpus */
-cpumask_t cpu_online_map = CPU_MASK_NONE;
-cpumask_t cpu_possible_map = CPU_MASK_NONE;
-
-EXPORT_SYMBOL(cpu_online_map);
-EXPORT_SYMBOL(cpu_possible_map);
-
 /* Per CPU bogomips and other parameters
  * The only piece used here is the ipi pipe, which is set before SMP is
  * started and never changed.
--- linux-2.6.28.orig/arch/x86/kernel/smpboot.c
+++ linux-2.6.28/arch/x86/kernel/smpboot.c
@@ -101,14 +101,8 @@ EXPORT_SYMBOL(smp_num_siblings);
 /* Last level cache ID of each logical CPU */
 DEFINE_PER_CPU(u16, cpu_llc_id) = BAD_APICID;
 
-/* bitmap of online cpus */
-cpumask_t cpu_online_map __read_mostly;
-EXPORT_SYMBOL(cpu_online_map);
-
 cpumask_t cpu_callin_map;
 cpumask_t cpu_callout_map;
-cpumask_t cpu_possible_map;
-EXPORT_SYMBOL(cpu_possible_map);
 
 /* representing HT siblings of each logical CPU */
 DEFINE_PER_CPU(cpumask_t, cpu_sibling_map);
--- linux-2.6.28.orig/arch/x86/mach-voyager/voyager_smp.c
+++ linux-2.6.28/arch/x86/mach-voyager/voyager_smp.c
@@ -62,11 +62,6 @@ static int voyager_extended_cpus = 1;
 /* Used for the invalidate map that's also checked in the spinlock */
 static volatile unsigned long smp_invalidate_needed;
 
-/* Bitmask of currently online CPUs - used by setup.c for
-   /proc/cpuinfo, visible externally but still physical */
-cpumask_t cpu_online_map = CPU_MASK_NONE;
-EXPORT_SYMBOL(cpu_online_map);
-
 /* Bitmask of CPUs present in the system - exported by i386_syms.c, used
  * by scheduler but indexed physically */
 cpumask_t phys_cpu_present_map = CPU_MASK_NONE;
@@ -216,8 +211,6 @@ static cpumask_t smp_commenced_mask = CP
 /* This is for the new dynamic CPU boot code */
 cpumask_t cpu_callin_map = CPU_MASK_NONE;
 cpumask_t cpu_callout_map = CPU_MASK_NONE;
-cpumask_t cpu_possible_map = CPU_MASK_NONE;
-EXPORT_SYMBOL(cpu_possible_map);
 
 /* The per processor IRQ masks (these are usually kept in sync) */
 static __u16 vic_irq_mask[NR_CPUS] __cacheline_aligned;
--- linux-2.6.28.orig/include/linux/cpumask.h
+++ linux-2.6.28/include/linux/cpumask.h
@@ -88,9 +88,9 @@
  * int cpumask_any_and(mask1,mask2)	Any cpu in both masks
  * int cpumask_any_but(mask,cpu)	Any cpu in mask except cpu
  *
- * for_each_possible_cpu(cpu)		for-loop cpu over cpu_possible_map
- * for_each_online_cpu(cpu)		for-loop cpu over cpu_online_map
- * for_each_present_cpu(cpu)		for-loop cpu over cpu_present_map
+ * for_each_possible_cpu(cpu)		for-loop cpu over cpu_possible_mask
+ * for_each_online_cpu(cpu)		for-loop cpu over cpu_online_mask
+ * for_each_present_cpu(cpu)		for-loop cpu over cpu_present_mask
  *
  * Subtlety:
  * 1) The 'type-checked' form of cpu_isset() causes gcc (3.3.2, anyway)
@@ -161,7 +161,7 @@ extern cpumask_t _unused_cpumask_arg_;
 		for_each_cpu_and(cpu, &(mask), &(and))
 #define first_cpu(src)		cpumask_first(&(src))
 #define next_cpu(n, src)	cpumask_next((n), &(src))
-#define any_online_cpu(mask)	cpumask_any_and(&(mask), &cpu_online_map)
+#define any_online_cpu(mask)	cpumask_any_and(&(mask), cpu_online_mask)
 #if NR_CPUS > BITS_PER_LONG
 #define	CPUMASK_ALLOC(m)	struct m *m = kmalloc(sizeof(*m), GFP_KERNEL)
 #define	CPUMASK_FREE(m)		kfree(m)
@@ -170,6 +170,11 @@ extern cpumask_t _unused_cpumask_arg_;
 #define	CPUMASK_FREE(m)
 #endif
 #define	CPUMASK_PTR(v, m) 	cpumask_t *v = &(m->v)
+/* These strip const, as traditionally they weren't const. */
+#define cpu_possible_map	(*(cpumask_t *)cpu_possible_mask)
+#define cpu_online_map		(*(cpumask_t *)cpu_online_mask)
+#define cpu_present_map		(*(cpumask_t *)cpu_present_mask)
+#define cpu_active_map		(*(cpumask_t *)cpu_active_mask)
 /* End deprecated region. */
 
 #if NR_CPUS <= BITS_PER_LONG
@@ -530,65 +535,48 @@ static inline void free_cpumask_or_fallb
 
 /*
  * The following particular system cpumasks and operations manage
- * possible, present, active and online cpus.  Each of them is a fixed size
- * bitmap of size NR_CPUS.
+ * possible, present, active and online cpus.
  *
- *  #ifdef CONFIG_HOTPLUG_CPU
- *     cpu_possible_map - has bit 'cpu' set iff cpu is populatable
- *     cpu_present_map  - has bit 'cpu' set iff cpu is populated
- *     cpu_online_map   - has bit 'cpu' set iff cpu available to scheduler
- *     cpu_active_map   - has bit 'cpu' set iff cpu available to migration
- *  #else
- *     cpu_possible_map - has bit 'cpu' set iff cpu is populated
- *     cpu_present_map  - copy of cpu_possible_map
- *     cpu_online_map   - has bit 'cpu' set iff cpu available to scheduler
- *  #endif
- *
- *  In either case, NR_CPUS is fixed at compile time, as the static
- *  size of these bitmaps.  The cpu_possible_map is fixed at boot
- *  time, as the set of CPU id's that it is possible might ever
- *  be plugged in at anytime during the life of that system boot.
- *  The cpu_present_map is dynamic(*), representing which CPUs
- *  are currently plugged in.  And cpu_online_map is the dynamic
- *  subset of cpu_present_map, indicating those CPUs available
- *  for scheduling.
+ *     cpu_possible_mask- has bit 'cpu' set iff cpu is populatable
+ *     cpu_present_mask - has bit 'cpu' set iff cpu is populated
+ *     cpu_online_mask  - has bit 'cpu' set iff cpu available to scheduler
+ *     cpu_active_mask  - has bit 'cpu' set iff cpu available to migration
+ *
+ *  If !CONFIG_HOTPLUG_CPU, present = possible, and active = online.
+ *
+ *  The cpu_possible_mask is fixed at boot time, as the set of CPU id's
+ *  that it is possible might ever be plugged in at anytime during the
+ *  life of that system boot.  The cpu_present_mask is dynamic(*),
+ *  representing which CPUs are currently plugged in.  And
+ *  cpu_online_mask is the dynamic subset of cpu_present_mask,
+ *  indicating those CPUs available for scheduling.
  *
- *  If HOTPLUG is enabled, then cpu_possible_map is forced to have
+ *  If HOTPLUG is enabled, then cpu_possible_mask is forced to have
  *  all NR_CPUS bits set, otherwise it is just the set of CPUs that
  *  ACPI reports present at boot.
  *
- *  If HOTPLUG is enabled, then cpu_present_map varies dynamically,
+ *  If HOTPLUG is enabled, then cpu_present_mask varies dynamically,
  *  depending on what ACPI reports as currently plugged in, otherwise
- *  cpu_present_map is just a copy of cpu_possible_map.
+ *  cpu_present_mask is just a copy of cpu_possible_mask.
  *
- *  (*) Well, cpu_present_map is dynamic in the hotplug case.  If not
- *      hotplug, it's a copy of cpu_possible_map, hence fixed at boot.
+ *  (*) Well, cpu_present_mask is dynamic in the hotplug case.  If not
+ *      hotplug, it's a copy of cpu_possible_mask, hence fixed at boot.
  *
  * Subtleties:
  * 1) UP arch's (NR_CPUS = 1, CONFIG_SMP not defined) hardcode
  *    assumption that their single CPU is online.  The UP
- *    cpu_{online,possible,present}_maps are placebos.  Changing them
+ *    cpu_{online,possible,present}_masks are placebos.  Changing them
  *    will have no useful affect on the following num_*_cpus()
  *    and cpu_*() macros in the UP case.  This ugliness is a UP
  *    optimization - don't waste any instructions or memory references
  *    asking if you're online or how many CPUs there are if there is
  *    only one CPU.
- * 2) Most SMP arch's #define some of these maps to be some
- *    other map specific to that arch.  Therefore, the following
- *    must be #define macros, not inlines.  To see why, examine
- *    the assembly code produced by the following.  Note that
- *    set1() writes phys_x_map, but set2() writes x_map:
- *        int x_map, phys_x_map;
- *        #define set1(a) x_map = a
- *        inline void set2(int a) { x_map = a; }
- *        #define x_map phys_x_map
- *        main(){ set1(3); set2(5); }
  */
 
-extern cpumask_t cpu_possible_map;
-extern cpumask_t cpu_online_map;
-extern cpumask_t cpu_present_map;
-extern cpumask_t cpu_active_map;
+extern const struct cpumask *const cpu_possible_mask;
+extern const struct cpumask *const cpu_online_mask;
+extern const struct cpumask *const cpu_present_mask;
+extern const struct cpumask *const cpu_active_mask;
 
 #if NR_CPUS > 1
 #define num_online_cpus()	cpus_weight(cpu_online_map)
@@ -619,11 +607,11 @@ void init_cpu_online(const struct cpumas
 
 #define cpu_is_offline(cpu)	unlikely(!cpu_online(cpu))
 
-#define for_each_possible_cpu(cpu) for_each_cpu((cpu), &cpu_possible_map)
-#define for_each_online_cpu(cpu)   for_each_cpu((cpu), &cpu_online_map)
-#define for_each_present_cpu(cpu)  for_each_cpu((cpu), &cpu_present_map)
+#define for_each_possible_cpu(cpu) for_each_cpu((cpu), cpu_possible_mask)
+#define for_each_online_cpu(cpu)   for_each_cpu((cpu), cpu_online_mask)
+#define for_each_present_cpu(cpu)  for_each_cpu((cpu), cpu_present_mask)
 
 /* Arch-specific code may call this to initialize nr_cpu_ids based on
- * the cpu_possible_map. */
+ * the cpu_possible_mask. */
 void __init setup_nr_cpu_ids(void);
 #endif /* __LINUX_CPUMASK_H */
--- linux-2.6.28.orig/kernel/cpu.c
+++ linux-2.6.28/kernel/cpu.c
@@ -15,29 +15,8 @@
 #include <linux/stop_machine.h>
 #include <linux/mutex.h>
 
-/*
- * Represents all cpu's present in the system
- * In systems capable of hotplug, this map could dynamically grow
- * as new cpu's are detected in the system via any platform specific
- * method, such as ACPI for e.g.
- */
-cpumask_t cpu_present_map __read_mostly;
-EXPORT_SYMBOL(cpu_present_map);
-
-#ifndef CONFIG_SMP
-
-/*
- * Represents all cpu's that are currently online.
- */
-cpumask_t cpu_online_map __read_mostly = CPU_MASK_ALL;
-EXPORT_SYMBOL(cpu_online_map);
-
-cpumask_t cpu_possible_map __read_mostly = CPU_MASK_ALL;
-EXPORT_SYMBOL(cpu_possible_map);
-
-#else /* CONFIG_SMP */
-
-/* Serializes the updates to cpu_online_map, cpu_present_map */
+#ifdef CONFIG_SMP
+/* Serializes the updates to cpu_online_mask, cpu_present_mask */
 static DEFINE_MUTEX(cpu_add_remove_lock);
 
 static __cpuinitdata RAW_NOTIFIER_HEAD(cpu_chain);
@@ -64,8 +43,6 @@ void __init cpu_hotplug_init(void)
 	cpu_hotplug.refcount = 0;
 }
 
-cpumask_t cpu_active_map;
-
 #ifdef CONFIG_HOTPLUG_CPU
 
 void get_online_cpus(void)
@@ -96,7 +73,7 @@ EXPORT_SYMBOL_GPL(put_online_cpus);
 
 /*
  * The following two API's must be used when attempting
- * to serialize the updates to cpu_online_map, cpu_present_map.
+ * to serialize the updates to cpu_online_mask, cpu_present_mask.
  */
 void cpu_maps_update_begin(void)
 {
@@ -499,43 +476,59 @@ const unsigned long cpu_bit_bitmap[BITS_
 };
 EXPORT_SYMBOL_GPL(cpu_bit_bitmap);
 
+static DECLARE_BITMAP(cpu_possible_bits, CONFIG_NR_CPUS) __read_mostly;
+const struct cpumask *const cpu_possible_mask = to_cpumask(cpu_possible_bits);
+EXPORT_SYMBOL(cpu_possible_mask);
+
+static DECLARE_BITMAP(cpu_online_bits, CONFIG_NR_CPUS) __read_mostly;
+const struct cpumask *const cpu_online_mask = to_cpumask(cpu_online_bits);
+EXPORT_SYMBOL(cpu_online_mask);
+
+static DECLARE_BITMAP(cpu_present_bits, CONFIG_NR_CPUS) __read_mostly;
+const struct cpumask *const cpu_present_mask = to_cpumask(cpu_present_bits);
+EXPORT_SYMBOL(cpu_present_mask);
+
+static DECLARE_BITMAP(cpu_active_bits, CONFIG_NR_CPUS) __read_mostly;
+const struct cpumask *const cpu_active_mask = to_cpumask(cpu_active_bits);
+EXPORT_SYMBOL(cpu_active_mask);
+
 void set_cpu_possible(unsigned int cpu, bool possible)
 {
 	if (possible)
-		cpumask_set_cpu(cpu, &cpu_possible_map);
+		cpumask_set_cpu(cpu, to_cpumask(cpu_possible_bits));
 	else
-		cpumask_clear_cpu(cpu, &cpu_possible_map);
+		cpumask_clear_cpu(cpu, to_cpumask(cpu_possible_bits));
 }
 void set_cpu_present(unsigned int cpu, bool present)
 {
 	if (present)
-		cpumask_set_cpu(cpu, &cpu_present_map);
+		cpumask_set_cpu(cpu, to_cpumask(cpu_present_bits));
 	else
-		cpumask_clear_cpu(cpu, &cpu_present_map);
+		cpumask_clear_cpu(cpu, to_cpumask(cpu_present_bits));
 }
 void set_cpu_online(unsigned int cpu, bool online)
 {
 	if (online)
-		cpumask_set_cpu(cpu, &cpu_online_map);
+		cpumask_set_cpu(cpu, to_cpumask(cpu_online_bits));
 	else
-		cpumask_clear_cpu(cpu, &cpu_online_map);
+		cpumask_clear_cpu(cpu, to_cpumask(cpu_online_bits));
 }
 void set_cpu_active(unsigned int cpu, bool active)
 {
 	if (active)
-		cpumask_set_cpu(cpu, &cpu_active_map);
+		cpumask_set_cpu(cpu, to_cpumask(cpu_active_bits));
 	else
-		cpumask_clear_cpu(cpu, &cpu_active_map);
+		cpumask_clear_cpu(cpu, to_cpumask(cpu_active_bits));
 }
 void init_cpu_present(const struct cpumask *src)
 {
-	cpumask_copy(&cpu_present_map, src);
+	cpumask_copy(to_cpumask(cpu_present_bits), src);
 }
 void init_cpu_possible(const struct cpumask *src)
 {
-	cpumask_copy(&cpu_possible_map, src);
+	cpumask_copy(to_cpumask(cpu_possible_bits), src);
 }
 void init_cpu_online(const struct cpumask *src)
 {
-	cpumask_copy(&cpu_online_map, src);
+	cpumask_copy(to_cpumask(cpu_online_bits), src);
 }

-- 

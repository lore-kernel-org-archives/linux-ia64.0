From: akpm@osdl.org
Date: Tue, 12 Apr 2005 08:43:52 +0000
Subject: [patch 1/1] ia64: reduce cacheline bouncing in cpu_idle_wait
Message-Id: <200504120843.j3C8hx2Q000977@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


From: Zwane Mwaikambo <zwane@arm.linux.org.uk>

Andi noted that during normal runtime cpu_idle_map is bounced around a lot,
and occassionally at a higher frequency than the timer interrupt wakeup
which we normally exit pm_idle from.  So switch to a percpu variable.

I didn't move things to the slow path because it would involve adding
scheduler code to wakeup the idle thread on the cpus we're waiting for.

Signed-off-by: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/ia64/kernel/process.c |   41 +++++++++++++++++++++++--------------
 1 files changed, 26 insertions(+), 15 deletions(-)

diff -puN arch/ia64/kernel/process.c~ia64-reduce-cacheline-bouncing-in-cpu_idle_wait arch/ia64/kernel/process.c
--- 25/arch/ia64/kernel/process.c~ia64-reduce-cacheline-bouncing-in-cpu_idle_wait	Wed Mar 30 13:38:32 2005
+++ 25-akpm/arch/ia64/kernel/process.c	Wed Mar 30 13:38:35 2005
@@ -50,7 +50,7 @@
 #include "sigframe.h"
 
 void (*ia64_mark_idle)(int);
-static cpumask_t cpu_idle_map;
+static DEFINE_PER_CPU(unsigned int, cpu_idle_state);
 
 unsigned long boot_option_idle_override = 0;
 EXPORT_SYMBOL(boot_option_idle_override);
@@ -223,20 +223,31 @@ static inline void play_dead(void)
 }
 #endif /* CONFIG_HOTPLUG_CPU */
 
-
 void cpu_idle_wait(void)
 {
-        int cpu;
-        cpumask_t map;
+	unsigned int cpu, this_cpu = get_cpu();
+	cpumask_t map;
+
+	set_cpus_allowed(current, cpumask_of_cpu(this_cpu));
+	put_cpu();
 
-        for_each_online_cpu(cpu)
-                cpu_set(cpu, cpu_idle_map);
+	cpus_clear(map);
+	for_each_online_cpu(cpu) {
+		per_cpu(cpu_idle_state, cpu) = 1;
+		cpu_set(cpu, map);
+	}
 
-        wmb();
-        do {
-                ssleep(1);
-                cpus_and(map, cpu_idle_map, cpu_online_map);
-        } while (!cpus_empty(map));
+	__get_cpu_var(cpu_idle_state) = 0;
+
+	wmb();
+	do {
+		ssleep(1);
+		for_each_online_cpu(cpu) {
+			if (cpu_isset(cpu, map) && !per_cpu(cpu_idle_state, cpu))
+				cpu_clear(cpu, map);
+		}
+		cpus_and(map, map, cpu_online_map);
+	} while (!cpus_empty(map));
 }
 EXPORT_SYMBOL_GPL(cpu_idle_wait);
 
@@ -244,7 +255,6 @@ void __attribute__((noreturn))
 cpu_idle (void)
 {
 	void (*mark_idle)(int) = ia64_mark_idle;
-	int cpu = smp_processor_id();
 
 	/* endless idle loop with no priority at all */
 	while (1) {
@@ -255,12 +265,13 @@ cpu_idle (void)
 		while (!need_resched()) {
 			void (*idle)(void);
 
+			if (__get_cpu_var(cpu_idle_state))
+				__get_cpu_var(cpu_idle_state) = 0;
+
+			rmb();
 			if (mark_idle)
 				(*mark_idle)(1);
 
-			if (cpu_isset(cpu, cpu_idle_map))
-				cpu_clear(cpu, cpu_idle_map);
-			rmb();
 			idle = pm_idle;
 			if (!idle)
 				idle = default_idle;
_

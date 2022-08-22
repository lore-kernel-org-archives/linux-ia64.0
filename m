From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 22 Aug 2022 02:15:13 +0000
Subject: [RFC 03/10] cpu/hotplug: Introduce fast kexec reboot
Message-Id: <20220822021520.6996-4-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220822021520.6996-1-kernelfans@gmail.com>
In-Reply-To: <20220822021520.6996-1-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Price <steven.price@arm.com>, Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Frederic Weisbecker <frederic@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Peter Zijlstra <peterz@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>

*** Current situation 'slow kexec reboot' ***

At present, some architectures rely on smp_shutdown_nonboot_cpus() to
implement "kexec -e". Since smp_shutdown_nonboot_cpus() tears down the
cpus serially, it is very slow.

Take a close look, a cpu_down() processing on a single cpu can approximately be
divided into two stages:
-1. from CPUHP_ONLINE to CPUHP_TEARDOWN_CPU
-2. from CPUHP_TEARDOWN_CPU to CPUHP_AP_IDLE_DEAD
    which is by stop_machine_cpuslocked(take_cpu_down, NULL, cpumask_of(cpu));
    and runs on the teardown cpu.

If these processes can run in parallel, then, the reboot can be speeded
up. That is the aim of this patch.

*** Contrast to other implements ***

X86 and PowerPC have their own machine_shutdown(), which does not reply
on the cpu hot-removing mechanism. They just discriminate some critical
component and tears them down in per cpu NMI handler during the kexec
reboot. But for some architectures, let's say arm64, it is not easy to define
these critical component due to various chipmakers' implements.

As a result, sticking to the cpu hot-removing mechanism is the simplest
way to re-implement the parallel. It also renders an opportunity to
implement the cpu_down() in parallel in future (not done by this series).

*** Things worthy of consideration ***

1. The definition of a clean boundary between the first kernel and the new kernel
-1.1 firmware
     The firmware's internal state should enter into a proper state.
And this is achieved by the firmware's cpuhp_step's teardown interface
if any.

-1.2 CPU internal
     Whether the cache or PMU needs a clean shutdown before rebooting.

2. The dependency of each cpuhp_step
   The boundary of a clean cut involves only few cpuhp_step, but they
may propagate to other cpuhp_step by the way of the dependency. This
series does not bother to judge the dependency, instead, just iterate
downside each cpuhp_step. And this stragegy demands that each cpuhp_step's
teardown interface supports parallel.

*** Solution ***

Ideally, if the interface _cpu_down() can be enhanced to enable
parallel, then the fast reboot can be achieved.

But revisiting the two parts of the current cpu_down() process, the
second part 'stop_machine_cpuslocked()' is a blockade. Packed inside the
_cpu_down(), stop_machine_cpuslocked() only allow one cpu to execute the
teardown.

So this patch breaks down the process of _cpu_down(), and divides the
teardown into three steps.  And the exposed stop_machine_cpuslocked()
can be used to support parallel.
1. Bring each AP from CPUHP_ONLINE to CPUHP_TEARDOWN_CPU
   in parallel.
2. Sync on BP to wait all APs to enter CPUHP_TEARDOWN_CPU state
3. Bring each AP from CPUHP_TEARDOWN_CPU to CPUHP_AP_IDLE_DEAD by the
   interface of stop_machine_cpuslocked() in parallel.

Apparently, the step 2 is introduced in order to satisfy the condition
on which stop_machine_cpuslocked() can start on each cpu.

Then the rest issue is about how to support parallel in step 1&3.
Furtunately, each subsystem has its own carefully designed lock
mechanism. In each cpuhp_step teardown interface, adopting to the
subsystem's lock rule will make things work.

*** No rollback if failure ***

During kexec reboot, the devices have already been shutdown, there is no
way for system to roll back to a workable state. So this series also
does not consider the rollback issue.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Price <steven.price@arm.com>
Cc: Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Frederic Weisbecker <frederic@kernel.org>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: linux-arm-kernel@lists.infradead.org
To: linux-ia64@vger.kernel.org
To: linux-riscv@lists.infradead.org
To: linux-kernel@vger.kernel.org
---
 kernel/cpu.c | 139 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 129 insertions(+), 10 deletions(-)

diff --git a/kernel/cpu.c b/kernel/cpu.c
index 2be6ba811a01..94ab2727d6bb 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -1260,10 +1260,125 @@ EXPORT_SYMBOL_GPL(remove_cpu);
 
 #ifdef CONFIG_SHUTDOWN_NONBOOT_CPUS
 
-void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
+/*
+ * Push all of cpus to the state CPUHP_AP_ONLINE_IDLE.
+ * Since kexec-reboot has already shut down all devices, there is no way to
+ * roll back, the cpus' teardown also requires no rollback, instead, just throw
+ * warning.
+ */
+static void cpus_down_no_rollback(struct cpumask *cpus)
 {
+	struct cpuhp_cpu_state *st;
 	unsigned int cpu;
+
+	/* launch ap work one by one, but not wait for completion */
+	for_each_cpu(cpu, cpus) {
+		st = per_cpu_ptr(&cpuhp_state, cpu);
+		/*
+		 * If the current CPU state is in the range of the AP hotplug thread,
+		 * then we need to kick the thread.
+		 */
+		if (st->state > CPUHP_TEARDOWN_CPU) {
+			cpuhp_set_state(cpu, st, CPUHP_TEARDOWN_CPU);
+			/* In order to parallel, async. And there is no way to rollback */
+			cpuhp_kick_ap_work_async(cpu);
+		}
+	}
+
+	/* wait for all ap work completion */
+	for_each_cpu(cpu, cpus) {
+		st = per_cpu_ptr(&cpuhp_state, cpu);
+		wait_for_ap_thread(st, st->bringup);
+		if (st->result)
+			pr_warn("cpu %u refuses to offline due to %d\n", cpu, st->result);
+		else if (st->state > CPUHP_TEARDOWN_CPU)
+			pr_warn("cpu %u refuses to offline, state: %d\n", cpu, st->state);
+	}
+}
+
+static int __takedown_cpu_cleanup(unsigned int cpu)
+{
+	struct cpuhp_cpu_state *st = per_cpu_ptr(&cpuhp_state, cpu);
+
+	/*
+	 * The teardown callback for CPUHP_AP_SCHED_STARTING will have removed
+	 * all runnable tasks from the CPU, there's only the idle task left now
+	 * that the migration thread is done doing the stop_machine thing.
+	 *
+	 * Wait for the stop thread to go away.
+	 */
+	wait_for_ap_thread(st, false);
+	BUG_ON(st->state != CPUHP_AP_IDLE_DEAD);
+
+	hotplug_cpu__broadcast_tick_pull(cpu);
+	/* This actually kills the CPU. */
+	__cpu_die(cpu);
+
+	tick_cleanup_dead_cpu(cpu);
+	rcutree_migrate_callbacks(cpu);
+	return 0;
+}
+
+/*
+ * There is a sync that all ap threads are done before calling this func.
+ */
+static void takedown_cpus_no_rollback(struct cpumask *cpus)
+{
+	struct cpuhp_cpu_state *st;
+	unsigned int cpu;
+
+	for_each_cpu(cpu, cpus) {
+		st = per_cpu_ptr(&cpuhp_state, cpu);
+		WARN_ON(st->state != CPUHP_TEARDOWN_CPU);
+		/* No invoke to takedown_cpu(), so set the state by manual */
+		st->state = CPUHP_AP_ONLINE;
+		cpuhp_set_state(cpu, st, CPUHP_AP_OFFLINE);
+	}
+
+	irq_lock_sparse();
+	/* ask stopper kthreads to execute take_cpu_down() in parallel */
+	stop_machine_cpuslocked(take_cpu_down, NULL, cpus);
+
+	/* Finally wait for completion and clean up */
+	for_each_cpu(cpu, cpus)
+		__takedown_cpu_cleanup(cpu);
+	irq_unlock_sparse();
+}
+
+static bool check_quick_reboot(void)
+{
+	return false;
+}
+
+static struct cpumask kexec_ap_map;
+
+void smp_shutdown_nonboot_cpus_quick_path(unsigned int primary_cpu)
+{
+	struct cpumask *cpus = &kexec_ap_map;
+	/*
+	 * To prevent other subsystem from access to __cpu_online_mask, but internally,
+	 * __cpu_disable() accesses the bitmap in parral and needs its own local lock.
+	 */
+	cpus_write_lock();
+
+	cpumask_copy(cpus, cpu_online_mask);
+	cpumask_clear_cpu(primary_cpu, cpus);
+	cpus_down_no_rollback(cpus);
+	takedown_cpus_no_rollback(cpus);
+	/*
+	 * For some subsystems, there are still remains for offline cpus from
+	 * CPUHP_BRINGUP_CPU to CPUHP_OFFLINE. But since none of them interact
+	 * with hardwares or firmware, they have no effect on the new kernel.
+	 * So skipping the cpuhp callbacks in that range
+	 */
+
+	cpus_write_unlock();
+}
+
+void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
+{
 	int error;
+	unsigned int cpu;
 
 	cpu_maps_update_begin();
 
@@ -1275,15 +1390,19 @@ void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
 	if (!cpu_online(primary_cpu))
 		primary_cpu = cpumask_first(cpu_online_mask);
 
-	for_each_online_cpu(cpu) {
-		if (cpu = primary_cpu)
-			continue;
-
-		error = cpu_down_maps_locked(cpu, CPUHP_OFFLINE);
-		if (error) {
-			pr_err("Failed to offline CPU%d - error=%d",
-				cpu, error);
-			break;
+	if (check_quick_reboot()) {
+		smp_shutdown_nonboot_cpus_quick_path(primary_cpu);
+	} else {
+		for_each_online_cpu(cpu) {
+			if (cpu = primary_cpu)
+				continue;
+
+			error = cpu_down_maps_locked(cpu, CPUHP_OFFLINE);
+			if (error) {
+				pr_err("Failed to offline CPU%d - error=%d",
+					cpu, error);
+				break;
+			}
 		}
 	}
 
-- 
2.31.1

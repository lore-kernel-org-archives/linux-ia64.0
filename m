From: Erich Focht <focht@ess.nec.de>
Date: Tue, 05 Mar 2002 17:37:54 +0000
Subject: Re: [Linux-ia64] O(1) scheduler K3+ for IA64
Message-Id: <marc-linux-ia64-105590701905224@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905201@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905201@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jesse,

On Mon, 4 Mar 2002, Jesse Barnes wrote:

> I applied the fix below, but still get hangs at boot sometimes.
> Here's the output with one of the smpboot debug switches turned on,
> hope it helps.

here's another try, I expect this one to work because it doesn't rely
on any assumptions on the scheduler behavior. Instead it uses
migration_task on CPU #0 to reliably move the tasks to their targets.

Regards,
Erich

--- 2.4.17-ia64-kdbv2.1-K3+/kernel/sched.c.old	Tue Mar  5 18:08:47 2002
+++ 2.4.17-ia64-kdbv2.1-K3+/kernel/sched.c	Tue Mar  5 18:48:05 2002
@@ -1509,10 +1509,10 @@
 	down(&req.sem);
 }
 
-static volatile unsigned long migration_mask;
-
 static int migration_thread(void * unused)
 {
+	int bind_cpu = (int) (long) unused;
+	int cpu = cpu_logical_map(bind_cpu);
 	struct sched_param param = { sched_priority: 99 };
 	runqueue_t *rq;
 	int ret;
@@ -1520,31 +1520,19 @@
 	daemonize();
 	sigfillset(&current->blocked);
 	set_fs(KERNEL_DS);
-	ret = setscheduler(0, SCHED_FIFO, &param);
 
 	/*
-	 * We have to migrate manually - there is no migration thread
-	 * to do this for us yet :-)
-	 *
-	 * We use the following property of the Linux scheduler. At
-	 * this point no other task is running, so by keeping all
-	 * migration threads running, the load-balancer will distribute
-	 * them between all CPUs equally. At that point every migration
-	 * task binds itself to the current CPU.
+	 * The first migration task is started on CPU #0. This one can migrate
+	 * the tasks to their destination CPUs.
 	 */
-
-	/* wait for all migration threads to start up. */
-	while (!migration_mask)
-		yield();
-
-	for (;;) {
-		if (test_and_clear_bit(smp_processor_id(), &migration_mask))
-			current->cpus_allowed = 1 << smp_processor_id();
-		if (current->need_resched)
-			schedule();
-		if (!migration_mask)
-			break;
+	if (cpu != 0) {
+		while (!cpu_rq(cpu_logical_map(0))->migration_thread)
+			yield();
+		set_cpus_allowed(current, 1UL << cpu);
 	}
+	printk("migration_task %d on cpu=%d\n",cpu,smp_processor_id());
+	ret = setscheduler(0, SCHED_FIFO, &param);
+
 	rq = this_rq();
 	rq->migration_thread = current;
 
@@ -1602,21 +1590,16 @@
 {
 	int cpu;
 
+	current->cpus_allowed = 1UL << cpu_logical_map(0);
 	for (cpu = 0; cpu < smp_num_cpus; cpu++) {
-		current->cpus_allowed = 1UL << cpu_logical_map(cpu);
-		if (kernel_thread(migration_thread, NULL,
+		if (kernel_thread(migration_thread, (void *) (long) cpu,
 				CLONE_FS | CLONE_FILES | CLONE_SIGNAL) < 0)
 			BUG();
-		else
-			current->cpus_allowed = -1L;
 	}
-
-	migration_mask = (1 << smp_num_cpus) - 1;
+	current->cpus_allowed = -1L;
 
 	for (cpu = 0; cpu < smp_num_cpus; cpu++)
 		while (!cpu_rq(cpu)->migration_thread)
 			schedule_timeout(2);
-	if (migration_mask)
-		BUG();
 }
 #endif



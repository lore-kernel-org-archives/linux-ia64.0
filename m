From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Fri, 01 Jun 2012 09:25:43 +0000
Subject: [PATCH 15/27] ia64, smpboot: Use generic SMP booting infrastructure
Message-Id: <20120601091337.31979.89266.stgit@srivatsabhat.in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120601090952.31979.24799.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20120601090952.31979.24799.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tglx@linutronix.de, peterz@infradead.org, paulmck@linux.vnet.ibm.com
Cc: rusty@rustcorp.com.au, mingo@kernel.org, yong.zhang0@gmail.com, akpm@linux-foundation.org, vatsa@linux.vnet.ibm.com, rjw@sisk.pl, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, srivatsa.bhat@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Fenghua Yu <fenghua.yu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, Mike Frysinger <vapier@gentoo.org>, linux-ia64@vger.kernel.org

From: Nikunj A. Dadhania <nikunj@linux.vnet.ibm.com>

Convert ia64 to use the generic framework to boot secondary CPUs.

Notes:
1. ia64 manipulates the cpu_online_mask under vector_lock. So, while
converting over to the generic smp booting code, override arch_vector_lock()
and arch_vector_unlock() appropriately.

2. ia64 needs to enable interrupts before fully completing booting of
secondary CPU (as explicitly mentioned in the comment above the call to
ia64_sync_itc()). Luckily this won't pose much of a problem because it
is in post-online stage (and hence CPU_STARTING notifications have been
sent and cpu_online_mask is setup already) and moreover, we were going to
enable the interrupts shortly anyway.

Signed-off-by: Nikunj A. Dadhania <nikunj@linux.vnet.ibm.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/ia64/kernel/irq_ia64.c |   16 ++++++++++++++++
 arch/ia64/kernel/smpboot.c  |   40 ++++++++++++++++++++++------------------
 2 files changed, 38 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 6ac99c8..6a724f9 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -196,6 +196,22 @@ static void clear_irq_vector(int irq)
 	spin_unlock_irqrestore(&vector_lock, flags);
 }
 
+/*
+ * We need to hold vector_lock while manipulating cpu_online_mask so that the
+ * set of online cpus does not change while we are assigning vectors to cpus
+ * (assign_irq_vector()). Holding this lock ensures we don't half assign or
+ * remove an irq from a cpu.
+ */
+void arch_vector_lock(void)
+{
+	spin_lock(&vector_lock);
+}
+
+void arch_vector_unlock(void)
+{
+	spin_unlock(&vector_lock);
+}
+
 int
 ia64_native_assign_irq_vector (int irq)
 {
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 709ce07..0f00dc6 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -351,18 +351,10 @@ smp_setup_percpu_timer (void)
 static void __cpuinit
 smp_callin (void)
 {
-	int cpuid, phys_id, itc_master;
-	struct cpuinfo_ia64 *last_cpuinfo, *this_cpuinfo;
-	extern void ia64_init_itm(void);
-	extern volatile int time_keeper_id;
-
-#ifdef CONFIG_PERFMON
-	extern void pfm_init_percpu(void);
-#endif
+	unsigned int cpuid, phys_id;
 
 	cpuid = smp_processor_id();
 	phys_id = hard_smp_processor_id();
-	itc_master = time_keeper_id;
 
 	if (cpu_online(cpuid)) {
 		printk(KERN_ERR "huh, phys CPU#0x%x, CPU#0x%x already present??\n",
@@ -380,11 +372,21 @@ smp_callin (void)
 
 	/* Setup the per cpu irq handling data structures */
 	__setup_vector_irq(cpuid);
-	notify_cpu_starting(cpuid);
-	spin_lock(&vector_lock);
-	set_cpu_online(cpuid, true);
-	per_cpu(cpu_state, cpuid) = CPU_ONLINE;
-	spin_unlock(&vector_lock);
+}
+
+void __cpuinit __cpu_post_online(void *unused)
+{
+	unsigned int cpuid, itc_master;
+	struct cpuinfo_ia64 *last_cpuinfo, *this_cpuinfo;
+	extern void ia64_init_itm(void);
+	extern volatile int time_keeper_id;
+
+#ifdef CONFIG_PERFMON
+	extern void pfm_init_percpu(void);
+#endif
+
+	cpuid = smp_processor_id();
+	itc_master = time_keeper_id;
 
 	smp_setup_percpu_timer();
 
@@ -442,6 +444,12 @@ smp_callin (void)
 int __cpuinit
 start_secondary (void *unused)
 {
+	smpboot_start_secondary(unused);
+	return 0;
+}
+
+void __cpuinit __cpu_pre_starting(void *unused)
+{
 	/* Early console may use I/O ports */
 	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
 #ifndef CONFIG_PRINTK_TIME
@@ -449,11 +457,7 @@ start_secondary (void *unused)
 #endif
 	efi_map_pal_code();
 	cpu_init();
-	preempt_disable();
 	smp_callin();
-
-	cpu_idle();
-	return 0;
 }
 
 struct pt_regs * __cpuinit idle_regs(struct pt_regs *regs)


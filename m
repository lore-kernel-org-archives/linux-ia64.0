From: Julia Lawall <julia@diku.dk>
Date: Fri, 26 Mar 2010 22:02:23 +0000
Subject: [PATCH 2/7] arch/ia64/kernel: Use set_cpus_allowed_ptr
Message-Id: <Pine.LNX.4.64.1003262301510.6480@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org, mingo@elte.hu, tglx@linutronix.de, oleg@redhat.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use set_cpus_allowed_ptr rather than set_cpus_allowed.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression E1,E2;
@@

- set_cpus_allowed(E1, cpumask_of_cpu(E2))
+ set_cpus_allowed_ptr(E1, cpumask_of(E2))

@@
expression E;
identifier I;
@@

- set_cpus_allowed(E, I)
+ set_cpus_allowed_ptr(E, &I)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c |   10 +++++-----
 arch/ia64/kernel/salinfo.c              |    5 ++---
 arch/ia64/kernel/topology.c             |    4 ++--
 3 files changed, 9 insertions(+), 10 deletions(-)

diff -u -p a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
+++ b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
@@ -112,7 +112,7 @@ processor_get_freq (
 	dprintk("processor_get_freq\n");
 
 	saved_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	if (smp_processor_id() != cpu)
 		goto migrate_end;
 
@@ -120,7 +120,7 @@ processor_get_freq (
 	ret = processor_get_pstate(&value);
 
 	if (ret) {
-		set_cpus_allowed(current, saved_mask);
+		set_cpus_allowed_ptr(current, &saved_mask);
 		printk(KERN_WARNING "get performance failed with error %d\n",
 		       ret);
 		ret = 0;
@@ -130,7 +130,7 @@ processor_get_freq (
 	ret = (clock_freq*1000);
 
 migrate_end:
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed_ptr(current, &saved_mask);
 	return ret;
 }
 
@@ -150,7 +150,7 @@ processor_set_freq (
 	dprintk("processor_set_freq\n");
 
 	saved_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	if (smp_processor_id() != cpu) {
 		retval = -EAGAIN;
 		goto migrate_end;
@@ -207,7 +207,7 @@ processor_set_freq (
 	retval = 0;
 
 migrate_end:
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed_ptr(current, &saved_mask);
 	return (retval);
 }
 
diff -u -p a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -360,12 +360,12 @@ static int __cpuinit cache_add_dev(struc
 		return 0;
 
 	oldmask = current->cpus_allowed;
-	retval = set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	retval = set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	if (unlikely(retval))
 		return retval;
 
 	retval = cpu_cache_sysfs_init(cpu);
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed_ptr(current, &oldmask);
 	if (unlikely(retval < 0))
 		return retval;
 
diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index e6676fc..aa8b5fa 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -404,10 +404,9 @@ static void
 call_on_cpu(int cpu, void (*fn)(void *), void *arg)
 {
 	cpumask_t save_cpus_allowed = current->cpus_allowed;
-	cpumask_t new_cpus_allowed = cpumask_of_cpu(cpu);
-	set_cpus_allowed(current, new_cpus_allowed);
+	set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	(*fn)(arg);
-	set_cpus_allowed(current, save_cpus_allowed);
+	set_cpus_allowed_ptr(current, &save_cpus_allowed);
 }
 
 static void

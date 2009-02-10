From: Alex Chiang <achiang@hp.com>
Date: Tue, 10 Feb 2009 16:11:03 +0000
Subject: Re: [PATCH v2 0/2] ia64: prevent irq migration race in
Message-Id: <20090210161103.GA28371@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209181338.GD19064@ldl.fc.hp.com> <20090210123645.GA7542@linux.vnet.ibm.com>
In-Reply-To: <20090210123645.GA7542@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: tony.luck@intel.com, stable@kernel.org, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

* Paul E. McKenney <paulmck@linux.vnet.ibm.com>:
> On Mon, Feb 09, 2009 at 11:13:38AM -0700, Alex Chiang wrote:
> > This is v2 of my attempt to prevent an oops while offlining CPUs.
> > 
> > The change is that the patch becomes a full revert of Paul's
> > original patch, along with a long changelog that explains the
> > situation as best as I can determine. It's not 100% satisfactory
> > to me right now, but the testing we've done supports the patch.
> > 
> > The 2nd patch in the series is mostly cosmetic, and removes a
> > redundant call to cpu_clear() that we no longer need().
> > 
> > Tony, if you agree with the rationale in 1/2, then this series is
> > a candidate for .29.
> > 
> > stable team, if Tony pushes upstream for .29, then this series
> > should be applied to the .27 and .28 stable series.
> 
> OK, I'll bite...
> 
> Why not use cpu_active_map rather than cpu_online_map to select which
> CPU to migrate interrupts to?  That way, we can delay clearing the
> bit in cpu_online_map and avoid the questionable scenario where irqs
> are being handled by a CPU that appears to be offline.

I did explain a little bit yesterday here:

	http://lkml.org/lkml/2009/2/9/508

The upshot is that on ia64, in the cpu_down() path, in practice,
we're only seeing the timer interrupt fire, even on a heavily
loaded system with lots of I/O.

And in our timer interrupt routine, we're checking to make sure
that the CPU is online before handling the interrupt.

So at least empirically, we don't seem to allow any offline CPUs
to handle interrupts.

I played around with cpu_active_map yesterday, and realized the
patch I posted was incomplete. When I started fleshing it out a
bit more, I learned that we're simply not using cpu_active_map in
the kernel to the extent that we're using cpu_online_map, and I'm
a bit hesitant to start introducing regressions because I missed
a usage somewhere.

With this below patch, I can't even offline a single CPU, and the
patch is already twice as big as the revert. At this point, the
revert has held up to testing, and in my view, is the clear short
term winner.

I can keep exploring the cpu_active_mask option, but that would
be a .30 activity, and I'd like to get this particular oops fixed
for .29.

Seem like a reasonable way forward?

Thanks.

/ac


diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index a58f64c..9eaab3c 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -155,7 +155,7 @@ static void migrate_irqs(void)
 			 */
 			vectors_in_migration[irq] = irq;
 
-			new_cpu = cpumask_any(cpu_online_mask);
+			new_cpu = cpumask_any(cpu_active_mask);
 
 			/*
 			 * Al three are essential, currently WARN_ON.. maybe panic?
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 1146399..a08175b 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -396,7 +396,8 @@ smp_callin (void)
 	/* Setup the per cpu irq handling data structures */
 	__setup_vector_irq(cpuid);
 	notify_cpu_starting(cpuid);
-	cpu_set(cpuid, cpu_online_map);
+	set_cpu_online(cpuid, true);
+	set_cpu_active(cpuid, true);
 	per_cpu(cpu_state, cpuid) = CPU_ONLINE;
 	spin_unlock(&vector_lock);
 	ipi_call_unlock_irq();
@@ -694,7 +695,7 @@ int migrate_platform_irqs(unsigned int cpu)
 			/*
 			 * Now re-target the CPEI to a different processor
 			 */
-			new_cpei_cpu = any_online_cpu(cpu_online_map);
+			new_cpei_cpu = cpumask_any(cpu_active_mask);
 			mask = cpumask_of(new_cpei_cpu);
 			set_cpei_target_cpu(new_cpei_cpu);
 			desc = irq_desc + ia64_cpe_irq;
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index f0ebb34..f8ae866 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -158,7 +158,7 @@ timer_interrupt (int irq, void *dev_id)
 {
 	unsigned long new_itm;
 
-	if (unlikely(cpu_is_offline(smp_processor_id()))) {
+	if (unlikely(!cpu_active(smp_processor_id()))) {
 		return IRQ_HANDLED;
 	}
 
diff --git a/init/main.c b/init/main.c
index 8442094..c126d23 100644
--- a/init/main.c
+++ b/init/main.c
@@ -514,6 +514,7 @@ static void __init boot_cpu_init(void)
 	int cpu = smp_processor_id();
 	/* Mark the boot cpu "present", "online" etc for SMP and UP case */
 	set_cpu_online(cpu, true);
+	set_cpu_active(cpu, true);
 	set_cpu_present(cpu, true);
 	set_cpu_possible(cpu, true);
 }

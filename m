From: Alex Chiang <achiang@hp.com>
Date: Mon, 09 Feb 2009 21:17:43 +0000
Subject: Re: [PATCH v2 1/2] Revert "[IA64] prevent ia64 from invoking irq
Message-Id: <20090209211743.GA3939@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209181338.GD19064@ldl.fc.hp.com> <20090209181616.GE19064@ldl.fc.hp.com>
In-Reply-To: <20090209181616.GE19064@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, stable@kernel.org, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

Hi Tony,

* Alex Chiang <achiang@hp.com>:
> This reverts commit e7b140365b86aaf94374214c6f4e6decbee2eb0a.
> 
> Commit e7b14036 removes the targetted disabled CPU from the
> cpu_online_map after calls to migrate_platform_irqs and fixup_irqs.

I'm currently testing the patch below as a v3.

> Paul McKenney states that the reasoning behind the patch was to
> prevent irq handlers from running on CPUs marked offline because:
> 
> 	RCU happily ignores CPUs that don't have their bits set in
> 	cpu_online_map, so if there are RCU read-side critical sections
> 	in the irq handlers being run, RCU will ignore them.  If the
> 	other CPUs were running, they might sequence through the RCU
> 	state machine, which could result in data structures being
> 	yanked out from under those irq handlers, which in turn could
> 	result in oopses or worse.
> 
> Unfortunately, both ia64 functions above look at cpu_online_map to find
> a new CPU to migrate interrupts onto. This means we can potentially
> migrate an interrupt off ourself back to... ourself. Uh oh.

v3 uses cpu_active_mask to find an interrupt migration target.
This should fix both the oops we were seeing as well as avoid the
issues with RCU that Paul mentions above.

I also think that this fix is simpler for us to think through
rather than making Paul think through the implications of
changing RCU to use cpu_active_mask. :)

So far, it's survived ~45 minutes on my simple test bed (without
any patches, it usually crashes in < 15 minutes). I'm about to
start a longer run on our complex test system that runs under
heavy load.

Hopefully I'll have some results for tomorrow, in which case I'll
send a proper patch.

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
index 1146399..4e8765d 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -694,7 +694,7 @@ int migrate_platform_irqs(unsigned int cpu)
 			/*
 			 * Now re-target the CPEI to a different processor
 			 */
-			new_cpei_cpu = any_online_cpu(cpu_online_map);
+			new_cpei_cpu = cpumask_any(cpu_active_mask);
 			mask = cpumask_of(new_cpei_cpu);
 			set_cpei_target_cpu(new_cpei_cpu);
 			desc = irq_desc + ia64_cpe_irq;

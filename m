From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 12 Apr 2017 20:07:27 +0000
Subject: [patch 01/13] ia64/topology: Remove cpus_allowed manipulation
Message-Id: <20170412201042.174518069@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170412200726.941336635@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sebastian Siewior <bigeasy@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Herbert Xu <herbert@gondor.apana.org.au>, Lai Jiangshan <jiangshanlai@gmail.com>, Len Brown <lenb@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Viresh Kumar <viresh.kumar@linaro.org>, linux-ia64@vger.kernel.org

The CPU hotplug callback fiddles with the cpus_allowed pointer to pin the
calling thread on the plugged CPU. That's already guaranteed by the hotplug
core code.

Remove it.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/topology.c |    6 ------
 1 file changed, 6 deletions(-)

--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -355,18 +355,12 @@ static int cache_add_dev(unsigned int cp
 	unsigned long i, j;
 	struct cache_info *this_object;
 	int retval = 0;
-	cpumask_t oldmask;
 
 	if (all_cpu_cache_info[cpu].kobj.parent)
 		return 0;
 
-	oldmask = current->cpus_allowed;
-	retval = set_cpus_allowed_ptr(current, cpumask_of(cpu));
-	if (unlikely(retval))
-		return retval;
 
 	retval = cpu_cache_sysfs_init(cpu);
-	set_cpus_allowed_ptr(current, &oldmask);
 	if (unlikely(retval < 0))
 		return retval;
 



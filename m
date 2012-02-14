From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2012 21:47:50 +0000
Subject: Re: [PATCH] Avoid mask based num_possible_cpus and num_online_cpus -v5
Message-Id: <4F3AD3B6.8070409@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CABeCy1aPp4=v90v_wAsw-KWDwNs59CwwYSJ-36+4t8kMuCaK0w@mail.gmail.com> <1328055439-9441-1-git-send-email-venki@google.com> <20120201140125.c656df41.akpm@linux-foundation.org> <87d39xj955.fsf@rustcorp.com.au> <CA+8MBbJcTgj7X-7RZAgWk8a3Qyaz1FxFzu3ZLk-8LHKD7M8h-Q@mail.gmail.com> <4F3971A1.5010305@linux.vnet.ibm.com> <4F39763D.3070609@linux.vnet.ibm.com> <CA+8MBbLR+rcJqe2z9tAt7Oav4wqgZA3k8Te6zcXNOs+zv2wAaA@mail.gmail.com> <87wr7pbwbz.fsf@rustcorp.com.au>
In-Reply-To: <87wr7pbwbz.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mike Travis <travis@sgi.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Paul Gortmaker <paul.gortmaker@windriver.com>, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On 02/14/2012 02:55 PM, Rusty Russell wrote:

> On Mon, 13 Feb 2012 13:57:45 -0800, Tony Luck <tony.luck@gmail.com> wrote:
>> On Mon, Feb 13, 2012 at 12:44 PM, Srivatsa S. Bhat
>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>> IOW, what output do you see from the following printk from
>>> arch/ia64/kernel/smpboot.c?
>>>
>>> printk(KERN_INFO "Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
>>>         (int)num_online_cpus(), bogosum/(500000/HZ), (bogosum/(5000/HZ))%100);
>>
>> That is a complicated question - because linux-next also has patches
>> by Arjan that
>> change how (when) cpus are brought online. Initially I blamed his
>> patches and tried
>> reverting them ... and saw the symptom you are wondering about (message said
>> "Total of 1 processors", but the BogoMIPs was a number big enough to be all of
>> them. Thanks to you, I can now understand why.
>>
>> Fix will be to stop ia64 from messing directly with cpu_online_map?
> 
> Yes, and the other architectures.
> 


Right. And we should also ensure that nobody messes directly with
cpu_possible_map as well. I have written up a patch for ia64 (see below).
Sorry, I haven't even compile tested it - I neither have the toolchain nor the
hardware. I hope it works!

But don't expect the above printk statement to print the right value if you are
running a kernel which has the patch posted at https://lkml.org/lkml/2012/1/31/286
applied. That is another patch that can alter boot-up time and many related
things. So, it would be best to test Venki's patch + following fix without having
Arjan's patch applied.

---
From: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH] ia64: Don't use cpu_set()/cpu_clear() over cpu_[online|possible]_map

Directly using cpu_set() and cpu_clear() on cpu_online_map or cpu_possible_map
is strongly discouraged. Use the functions set_cpu_online() and
set_cpu_possible() instead. This also means that the new implementation of
num_[online|possible]_cpus can track all changes to cpu_[online|possible]_mask
and hence give the correct results always.

Reported-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 0 files changed, 0 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index cd57d73..4d1a550 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -486,7 +486,7 @@ mark_bsp_online (void)
 {
 #ifdef CONFIG_SMP
 	/* If we register an early console, allow CPU 0 to printk */
-	cpu_set(smp_processor_id(), cpu_online_map);
+	set_cpu_online(smp_processor_id(), true);
 #endif
 }
 
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 0bd537b..8551979 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -77,7 +77,7 @@ stop_this_cpu(void)
 	/*
 	 * Remove this CPU:
 	 */
-	cpu_clear(smp_processor_id(), cpu_online_map);
+	set_cpu_online(smp_processor_id(), false);
 	max_xtp();
 	local_irq_disable();
 	cpu_halt();
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 5590979..35f6e3c 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -401,7 +401,7 @@ smp_callin (void)
 	/* Setup the per cpu irq handling data structures */
 	__setup_vector_irq(cpuid);
 	notify_cpu_starting(cpuid);
-	cpu_set(cpuid, cpu_online_map);
+	set_cpu_online(cpuid, true);
 	per_cpu(cpu_state, cpuid) = CPU_ONLINE;
 	spin_unlock(&vector_lock);
 	ipi_call_unlock_irq();
@@ -548,7 +548,7 @@ do_rest:
 	if (!cpu_isset(cpu, cpu_callin_map)) {
 		printk(KERN_ERR "Processor 0x%x/0x%x is stuck.\n", cpu, sapicid);
 		ia64_cpu_to_sapicid[cpu] = -1;
-		cpu_clear(cpu, cpu_online_map);  /* was set in smp_callin() */
+		set_cpu_online(cpu, false);  /* was set in smp_callin() */
 		return -EINVAL;
 	}
 	return 0;
@@ -609,7 +609,7 @@ smp_prepare_cpus (unsigned int max_cpus)
 	/*
 	 * We have the boot CPU online for sure.
 	 */
-	cpu_set(0, cpu_online_map);
+	set_cpu_online(0, true);
 	cpu_set(0, cpu_callin_map);
 
 	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
@@ -633,7 +633,7 @@ smp_prepare_cpus (unsigned int max_cpus)
 
 void __devinit smp_prepare_boot_cpu(void)
 {
-	cpu_set(smp_processor_id(), cpu_online_map);
+	set_cpu_online(smp_processor_id(), true);
 	cpu_set(smp_processor_id(), cpu_callin_map);
 	set_numa_node(cpu_to_node_map[smp_processor_id()]);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
@@ -732,10 +732,10 @@ int __cpu_disable(void)
 			return -EBUSY;
 	}
 
-	cpu_clear(cpu, cpu_online_map);
+	set_cpu_online(cpu, false);
 
 	if (migrate_platform_irqs(cpu)) {
-		cpu_set(cpu, cpu_online_map);
+		set_cpu_online(cpu, true);
 		return -EBUSY;
 	}
 



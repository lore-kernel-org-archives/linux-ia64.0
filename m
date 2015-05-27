From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 27 May 2015 01:30:35 +0000
Subject: Re: [PATCH 06/16] ia64: fix up obsolete cpu function usage.
Message-Id: <87mw0qn7h0.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au> <1425296150-4722-6-git-send-email-rusty@rustcorp.com.au> <CA+8MBbJiQeP3SHoqM+D0v6q5oOvaDgwr7RnFNJZ=TS8oPpoa5A@mail.gmail.com>
In-Reply-To: <CA+8MBbJiQeP3SHoqM+D0v6q5oOvaDgwr7RnFNJZ=TS8oPpoa5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Tony Luck <tony.luck@gmail.com> writes:
> On Mon, Mar 2, 2015 at 3:35 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>> Thanks to spatch, then a sweep for for_each_cpu_mask => for_each_cpu.
>>
>> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> I'm seeing a bunch of warnings building the ia64 tree:

Indeed, here's the forgotten fix sitting in my patch collection.

> Should cpumask_set_cpu() and friends specify a volatile argument???

It's weird, but it turns out hardly anyone wants that.

Cheers,
Rusty.

ia64: make cpu_callin_map non-volatile.

cpumask_test_cpu() doesn't take volatile, unlike the obsoleted
cpu_isset.  The only place ia64 really cares is the spin waiting for a
bit; udelay() is probably a barrier but insert rmb() to be sure.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 15051e9c2c6f..629975b56608 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -127,7 +127,7 @@ int smp_num_siblings = 1;
 volatile int ia64_cpu_to_sapicid[NR_CPUS];
 EXPORT_SYMBOL(ia64_cpu_to_sapicid);
 
-static volatile cpumask_t cpu_callin_map;
+static cpumask_t cpu_callin_map;
 
 struct smp_boot_data smp_boot_data __initdata;
 
@@ -477,6 +477,7 @@ do_boot_cpu (int sapicid, int cpu, struct task_struct *idle)
 	for (timeout = 0; timeout < 100000; timeout++) {
 		if (cpumask_test_cpu(cpu, &cpu_callin_map))
 			break;  /* It has booted */
+		rmb(); /* Make sure we re-read cpu_callin_map */
 		udelay(100);
 	}
 	Dprintk("\n");

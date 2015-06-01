From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 01 Jun 2015 06:35:53 +0000
Subject: Re: [PATCH] ia64: make cpu_callin_map non-volatile.
Message-Id: <87twusgd52.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <646392f4ff5b292164cd53c2a08cbced6b96171e.1432850232.git.tony.luck@intel.com>
In-Reply-To: <646392f4ff5b292164cd53c2a08cbced6b96171e.1432850232.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:
> On Tue, May 26, 2015 at 6:18 PM, Luck, Tony <tony.luck@intel.com> wrote:
>>
>> cpumask_test_cpu() doesn't take volatile, unlike the obsoleted
>> cpu_isset.  The only place ia64 really cares is the spin waiting for a
>> bit; udelay() is probably a barrier but insert rmb() to be sure.
>
> Hmm. udelay() definitely should be a barrier, so this patch shouldn't
> matter. But even if it weren't, rmb() would be the wrong barrier to
> use here.
>
> rmb() is a "CPU or IO read barrier" to order reads wrt other cores or
> DMA, and needs to be paired with a wmb() on other cores (and for DMA
> it is assumed that there is sufficiently write ordering for the DMA
> itself).
>
> If it's about just other CPU's, it would be "smp_rmb()", which is
> often much cheaper (due to no IO serialization, particularly on
> POWER).
>
> But in this case it doesn't seem to be about other agents at all
> (CPU's or DMA), you literally are just looking for a compiler barrier
> to make sure the read doesn't get moved out of the loop. And the
> function for that is just "barrier()".
>
> So I'm skipping this patch, because I dont' think it changes anything
> real, and from a "let's be careful" standpoint it's actually doing the
> wrong thing.

Good point: the fact that other cpus are the ones setting the bit is a
red herring here.

Thanks,
Rusty.

From: Rusty Russell <rusty@rustcorp.com.au>
Subject: ia64: make cpu_callin_map non-volatile.

cpumask_test_cpu() doesn't take volatile, unlike the obsoleted
cpu_isset.  The only place ia64 really cares is the spin waiting for a
bit; udelay() is probably a barrier but insert barrier() to be sure.

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
+		barrier(); /* Make sure we re-read cpu_callin_map */
 		udelay(100);
 	}
 	Dprintk("\n");

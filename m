From: Jet Chen <jet.chen@intel.com>
Date: Mon, 12 May 2014 14:36:51 +0000
Subject: Re: [sched] BUG: unable to handle kernel paging request at 093cd001
Message-Id: <5370DC83.3030406@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <53708067.7050700@intel.com> <1399888324-2007-1-git-send-email-vincent.guittot@linaro.org>
In-Reply-To: <1399888324-2007-1-git-send-email-vincent.guittot@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vincent Guittot <vincent.guittot@linaro.org>
Cc: mingo@kernel.org, fengguang.wu@intel.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/12/2014 05:52 PM, Vincent Guittot wrote:
> Hi,
> 
> Does this patch solve your issue ?
> 

Sorry, this patch doesn't work. The issue is still there.

[    0.036000] x86: Booting SMP configuration:
[    0.036000] .... node  #0, CPUs:      #1
[    0.004000] Initializing CPU#1
[    0.008000] kvm-clock: cpu 1, msr 0:13ffb081, secondary cpu clock
[    0.008000] masked ExtINT on CPU#1
[    0.008000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.052085] x86: Booted up 1 node, 2 CPUs
[    0.052023] KVM setup async PF for cpu 1
[    0.052023] kvm-stealtime: cpu 1, msr 13851980
[    0.053075] smpboot: Total of 2 processors activated (10774.44 BogoMIPS)
[    0.053878] BUG: unable to handle kernel paging request at 02f63001
[    0.054403] IP: [<d026eba3>] build_sched_domains+0x252/0x1545
[    0.054863] *pdpt = 0000000000000000 *pde = f000ff53f000ff53
[    0.055337] Oops: 0000 [#1] SMP
[    0.055616] Modules linked in:
[    0.055871] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.15.0-rc2-00066-g7a15434 #1
[    0.056000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.056000] task: d3050000 ti: d304c000 task.ti: d304c000
[    0.056000] EIP: 0060:[<d026eba3>] EFLAGS: 00010202 CPU: 0
[    0.056000] EIP is at build_sched_domains+0x252/0x1545
[    0.056000] EAX: 00000001 EBX: d30031f0 ECX: 0000001e EDX: 02f63000
[    0.056000] ESI: 00000000 EDI: d30031f0 EBP: d304df44 ESP: d304dee0
[    0.056000]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    0.056000] CR0: 8005003b CR2: 02f63001 CR3: 108ed000 CR4: 000006f0
[    0.056000] Stack:
[    0.056000]  00000002 00000000 00000000 d026fd5f 000000d0 d30066d0 00000002 d03b9d70
[    0.056000]  d3003180 d3003200 d30066c0 d3006360 00000000 00000000 d30031d0 d30066c8
[    0.056000]  d30031c0 00000000 00000000 d3003200 d08e6d14 d3041000 d30066c0 00000008
[    0.056000] Call Trace:
[    0.056000]  [<d026fd5f>] ? build_sched_domains+0x140e/0x1545
[    0.056000]  [<d03b9d70>] ? alloc_cpumask_var_node+0x1f/0x77
[    0.056000]  [<d074ec9a>] sched_init_smp+0x350/0x3c9
[    0.056000]  [<d0737b85>] kernel_init_freeable+0x6e/0x187
[    0.056000]  [<d0266d9d>] ? finish_task_switch+0x3e/0xfa
[    0.056000]  [<d04fda4a>] kernel_init+0xb/0xcc
[    0.056000]  [<d05120c1>] ret_from_kernel_thread+0x21/0x30
[    0.056000]  [<d04fda3f>] ? rest_init+0xbf/0xbf
[    0.056000] Code: 00 31 73 d0 8b 0c 11 85 c9 74 0a f6 41 3d 20 0f 85 b9 00 00 00 8b 04 02 e8 80 5f 0b 00 8b 43 04 85 c0 74 0f 8b 14 b5 00 31 73 d0 <8b> 04 10 e8 6a 5f 0b 00 8b 43 08 85 c0 74 0f 8b 14 b5 00 31 73
[    0.056000] EIP: [<d026eba3>] build_sched_domains+0x252/0x1545 SS:ESP 0068:d304dee0
[    0.056000] CR2: 0000000002f63001
[    0.056000] ---[ end trace 528da1c27c66605c ]---
[    0.056000] Kernel panic - not syncing: Fatal exception


> A null line is missing at the end of the array for NUMA case.
> My test was passed thanks to a null data after the allocated array 
> 
> regards,
> Vincent
> ---
>  kernel/sched/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 4ea7b3f..941da33 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -6232,7 +6232,7 @@ static void sched_init_numa(void)
>  	}
>  
>  	/* Compute default topology size */
> -	for (i = 0; sched_domain_topology[i].mask; i++);
> +	for (i = 1; sched_domain_topology[i].mask; i++);
>  
>  	tl = kzalloc((i + level) *
>  			sizeof(struct sched_domain_topology_level), GFP_KERNEL);
> 

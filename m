From: Barret Rhoden <brho@google.com>
Date: Wed, 01 May 2019 19:12:32 +0000
Subject: Re: [PATCH 1/2] x86, numa: always initialize all possible nodes
Message-Id: <34f96661-41c2-27cc-422d-5a7aab526f87@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190212095343.23315-2-mhocko@kernel.org>
In-Reply-To: <20190212095343.23315-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.com>

Hi -

This patch triggered an oops for me (more below).

On 2/12/19 4:53 AM, Michal Hocko wrote:
[snip]
> Fix the issue by reworking how x86 initializes the memory less nodes.
> The current implementation is hacked into the workflow and it doesn't
> allow any flexibility. There is init_memory_less_node called for each
> offline node that has a CPU as already mentioned above. This will make
> sure that we will have a new online node without any memory. Much later
> on we build a zone list for this node and things seem to work, except
> they do not (e.g. due to nr_cpus). Not to mention that it doesn't really
> make much sense to consider an empty node as online because we just
> consider this node whenever we want to iterate nodes to use and empty
> node is obviously not the best candidate. This is all just too fragile.

The problem might be in here - I have a case with a 'memoryless' node 
that has CPUs that get onlined during SMP boot, but that onlining 
triggers a page fault during device registration.

I'm running on a NUMA machine but I marked all of the memory on node 1 
as type 12 (PRAM), using the memmap arg.  That makes node 1 appear to 
have no memory.

During SMP boot, the fault is in bus_add_device():

	error = sysfs_create_link(&bus->p->devices_kset->kobj,

bus->p is NULL.

That p is the subsys_private struct, and it should have been set in

	postcore_initcall(register_node_type);

But that happens after SMP boot.  This fault happens during SMP boot.

The old code had set this node online via alloc_node_data(), so when it 
came time to do_cpu_up() -> try_online_node(), the node was already up 
and nothing happened.

Now, it attempts to online the node, which registers the node with 
sysfs, but that can't happen before the 'node' subsystem is registered.

My modified e820 map looks like this:

> [    0.000000] user: [mem 0x0000000000000100-0x000000000009c7ff] usable
> [    0.000000] user: [mem 0x000000000009c800-0x000000000009ffff] reserved
> [    0.000000] user: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> [    0.000000] user: [mem 0x0000000000100000-0x0000000073216fff] usable
> [    0.000000] user: [mem 0x0000000073217000-0x0000000075316fff] reserved
> [    0.000000] user: [mem 0x0000000075317000-0x00000000754f8fff] ACPI data
> [    0.000000] user: [mem 0x00000000754f9000-0x0000000076057fff] ACPI NVS
> [    0.000000] user: [mem 0x0000000076058000-0x0000000077ae9fff] reserved
> [    0.000000] user: [mem 0x0000000077aea000-0x0000000077ffffff] usable
> [    0.000000] user: [mem 0x0000000078000000-0x000000008fffffff] reserved
> [    0.000000] user: [mem 0x00000000fd000000-0x00000000fe7fffff] reserved
> [    0.000000] user: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] user: [mem 0x0000000100000000-0x00000004ffffffff] usable
> [    0.000000] user: [mem 0x0000000500000000-0x000000603fffffff] persistent (type 12)

Which leads to an empty zone 1:

> [    0.016060] Initmem setup node 0 [mem 0x0000000000001000-0x00000004ffffffff]
> [    0.073310] Initmem setup node 1 [mem 0x0000000000000000-0x0000000000000000]

The backtrace:

> [    2.175327] Call Trace:
> [    2.175327]  device_add+0x43e/0x690
> [    2.175327]  device_register+0x107/0x110
> [    2.175327]  __register_one_node+0x72/0x150
> [    2.175327]  __try_online_node+0x8f/0xd0
> [    2.175327]  try_online_node+0x2b/0x50
> [    2.175327]  do_cpu_up+0x46/0xf0
> [    2.175327]  cpu_up+0x13/0x20
> [    2.175327]  smp_init+0x6e/0xd0
> [    2.175327]  kernel_init_freeable+0xe5/0x21f
> [    2.175327]  ? rest_init+0xb0/0xb0
> [    2.175327]  kernel_init+0xf/0x180
> [    2.175327]  ? rest_init+0xb0/0xb0
> [    2.175327]  ret_from_fork+0x1f/0x30

To get it booting again, I unconditionally node_set_online:

arch/x86/mm/numa.c
@@ -583,7 +583,7 @@ static int __init numa_register_memblks(struct 
numa_meminfo *mi)
                         continue;

                 alloc_node_data(nid);
-               if (end)
+               //if (end)
                         node_set_online(nid);
         }

A more elegant solution may be to avoid registering with sysfs during 
early boot, or something else entirely.  But I figured I'd ask for help 
at this point.  =)

Thanks,

Barret

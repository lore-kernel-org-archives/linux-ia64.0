From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 14 Mar 2005 04:49:39 +0000
Subject: Re: [PATCH] fix generic non-SMP builds
Message-Id: <200503132049.39708.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110765467.10208.9.camel@localhost>
In-Reply-To: <1110765467.10208.9.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday, March 13, 2005 5:57 pm, dann frazier wrote:
> +u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
> +EXPORT_SYMBOL(cpu_to_node_map);
> +
> +cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;

I'm trying to figure out why these are caheline aligned...  they're ready-only 
for after boot (hotplug aside), right?  Do we see that a lot of cpu/node 
local references to them occur?  OTOH, the wastage isn't that big either 
way...

> +	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
> +		node = -1;
> +		for (i = 0; i < NR_CPUS; ++i)
> +			if (cpu_physical_id(cpu) = node_cpuid[i].phys_id) {
> +				node = node_cpuid[i].nid;

Is there a for_each_node(n) now?

> +	for (cpu = 0; cpu < NR_CPUS; cpu++)
> +		per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];

for_each_cpu here I think.

Not sure when Tony had this queued up, so we may have to rediff in a week or 
two, otherwise it looks good.

Jess

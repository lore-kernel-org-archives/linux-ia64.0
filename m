From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 10 Jul 2006 00:34:18 +0000
Subject: Re: [PATCH] remove empty node at boot time
Message-Id: <20060710093418.be084931.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060601200436.6bf7c4e5.kamezawa.hiroyu@jp.fujitsu.com>
	<200607071726.31646.bjorn.helgaas@hp.com>
In-Reply-To: <200607071726.31646.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, akpm@osdl.org

On Fri, 7 Jul 2006 17:26:31 -0600
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> On Thursday 01 June 2006 05:04, KAMEZAWA Hiroyuki wrote:
> > Remove empty node -- a node which containes no cpu, no memory (and no I/O).
> > for ia64.
> > 
> > This patch online nodes which has available resouces and avoid onlining 
> > nodes which has only possible resouces.
> 
> This patch breaks my HP rx8640 box.  I suppose we have some unusual
> SRAT configuration.  I'll debug it more next week.  If there's something
> in particular I should look for, let me know.
> 
> Comparing old (working) with new (broken), I see:
> 
> - Number of logical nodes in system = 3
> + Number of logical nodes in system = 1
> 
> This box has two cells.  Each cell has four CPUs and some local memory.
> There is also an interleaved region that uses memory from both cells.
> I think firmware presents this as a logical node for each cell, plus
> one for the interleaved region.
> 
> This box is configured with minimal local memory on each cell (8MB).
> That's less than a granule, so we should discard it, leaving two nodes
> with CPUs but no memory, and a third node with all the interleaved
> memory but no CPUs.
> 

Then, your box has 
node 0 : cpu x 4, small memory
node 1 : cpu x 4, small memory
node 2 : big memory.

if above node 0 and node 1 disappears, it looks there are some bugs in
cpu detection.

> +	int i, cpu;
> +	/* online node if a node has available cpus */
> +	for (i = 0; i < srat_num_cpus; ++i)
> +		for (cpu = 0; cpu < available_cpus; ++cpu)
> +			if (smp_boot_data.cpu_phys_id[cpu] =
> +				node_cpuid[i].phys_id) {
> +				node_set_online(node_cpuid[i].nid);
> +				break;
> +			}

Note:
smp_boot_data.cpu_phys_id[i] is set by acpi_parse_lsapic().
node_cpuid[j].phys_id is set by acpi_numa_processor_affinity_init().

-Kame


 


From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 10 Jun 2004 23:23:10 +0000
Subject: Re: [PATCH] ia64_cleanup_topology_init
Message-Id: <1086909790.26658.51.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX409FRaqbC8wSA0000000c@orsmsx409.amr.corp.intel.com>
In-Reply-To: <ORSMSX409FRaqbC8wSA0000000c@orsmsx409.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-06-10 at 16:00, Keshavamurthy, Anil S wrote:
> Side-effects with this patch:
> With this patch register_cpu() is now called only for _online_ cpu's and
> not for all _possible_ cpu's as the code was doing in
> arch/ia64/dig/topology.c. The reason for this is when the new cpu or
> node gets hot added at that time one can dynamically call these register
> functions.

I personally like this a lot better than the current ppc64 scheme where
all possible cpus are brought online.  It's just confusing.  

> +static int __init topology_init(void)
> +{
> +	int i, err = 0;
> +
> +#ifdef CONFIG_NUMA
> +	sysfs_nodes = kmalloc(sizeof(struct node) * numnodes,
> GFP_KERNEL);
> +	if (!sysfs_nodes) {
> +		err = -ENOMEM;
> +		goto out;
> +	}
> +	memset(sysfs_nodes, 0, sizeof(struct node) * numnodes);
> +
> +	for (i = 0; i < numnodes; i++)
> +		if ((err = register_node(&sysfs_nodes[i], i, 0)))
> +			goto out;
> +#endif
...

I wonder there should be a numa_topology_init() function to do this
part, instead if ifdef'ing it here.  In fact, it might even be able to
be a completely generic function.

-- Dave


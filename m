From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 28 Jan 2004 21:17:59 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040128211759.A1918@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 28, 2004 at 02:59:12PM -0600, Jack Steiner wrote:
> +#ifdef CONFIG_NUMA
> +			cpus_clear(mm->cpu_vm_mask);
> +#endif

I really hate this ifdefs all over the place.  Does this really hurt that
much on non-NUMA systems?  Also SN2 seems to use this code always so
CONFIG_NUMA looks like the wrong ifdef to me.  

> +#ifdef CONFIG_NUMA
> +		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
> +			cpu_set(smp_processor_id(), mm->cpu_vm_mask);

cpu_test_and_set()?

> +/* When nodemask_t is available, delete the following definitions */
> +#define NODEMASK_WORDCOUNT       ((NR_NODES+(BITS_PER_LONG-1))/BITS_PER_LONG)
> +#define NODE_MASK_ALL    { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = ~0UL }
> +#define NODE_MASK_NONE   { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = 0 }
> +typedef unsigned long   nodemask_t[NODEMASK_WORDCOUNT];

Don't we have the generic bitmask code merged now?
>
> +	for (i=0, cpu=find_first_bit(&mm->cpu_vm_mask, NR_CPUS); cpu < NR_CPUS;
> +			i++, cpu=find_next_bit(&mm->cpu_vm_mask, NR_CPUS, ++cpu)) {

This assumes a specific cpumask_t implementation.  You should just use
for_each_cpu_mask()

> @@ -218,3 +265,4 @@
>  
>  	sn_send_IPI_phys(physid, vector, delivery_mode);
>  }
> +EXPORT_SYMBOL(sn2_send_IPI);

What's this?


From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 18 Jun 2004 17:17:37 +0000
Subject: Re: [PATCH] fix interrupt rerouting for Altix
Message-Id: <200406181317.37388.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406171546.i5HFk3wF407364@fsgi900.americas.sgi.com>
In-Reply-To: <200406171546.i5HFk3wF407364@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, June 17, 2004 11:46 am, Pat Gefre wrote:
> +static inline void move_irq(int irq)
> +{
> +	/* note - we hold desc->lock */
> +	cpumask_t tmp;
> +	irq_desc_t *desc = irq_descp(irq);
> +
> +	if (!cpus_empty(pending_irq_cpumask[irq])) {
> +		cpus_and(tmp, pending_irq_cpumask[irq], cpu_online_map);
> +		if (unlikely(!cpus_empty(tmp))) {
> +			desc->handler->set_affinity(irq, pending_irq_cpumask[irq]);
> +		}
> +		cpus_clear(pending_irq_cpumask[irq]);
> +	}
> +}

This looks like a duplicate of what's in iosapic.c.  Maybe we should just have 
one version of it in irq.c?  Ashok?

Thanks,
Jesse

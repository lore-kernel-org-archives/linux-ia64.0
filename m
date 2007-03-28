From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 28 Mar 2007 00:46:44 +0000
Subject: Re: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <1175042804.15565.9.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327193925.GA8615@sgi.com>
In-Reply-To: <20070327193925.GA8615@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2007-03-28 at 03:39, Jack Steiner wrote:

> This patch adds an optional method for purging the TLB on SN IA64 systems.
> The change should not affect any non-SN system.
> 
> 	Signed-off-by: Jack Steiner <steiner@sgi.com>
> 
> ---
> 
> +void
> +smp_flush_tlb_cpumask (cpumask_t xcpumask)
> +{
> +	unsigned short counts[NR_CPUS];
> +	cpumask_t cpumask = xcpumask;
> +	int count, mycpu, cpu, flush_mycpu = 0;
> +
> +	preempt_disable();
> +	mycpu = smp_processor_id();
> +
> +	for_each_cpu_mask(cpu, cpumask) {
> +		counts[cpu] = per_cpu(local_flush_count, cpu);
> +		mb();
> +		if (cpu = mycpu)
> +			flush_mycpu = 1;
> +		else
> +			smp_send_local_flush_tlb(cpu);
> +	}
> +
> +	if (flush_mycpu)
> +		smp_local_flush_tlb();
> +
> +	for_each_cpu_mask(cpu, cpumask) {
> +		count = 0;
> +		while(counts[cpu] = per_cpu(local_flush_count, cpu)) {

Due to 64k offset of percpu data, the same percpu variable on different
CPUs are very likely to be on the same cacheline of some levels of
cache.

So I think the operation on local_flush_count may be very cache
unfriendly...


Zou Nan hai





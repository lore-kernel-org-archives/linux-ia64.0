From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 12 Jul 2005 20:47:54 +0000
Subject: Re: [PATCH] fix call of smp_processor_id() by XPC while preemptible
Message-Id: <20050712204754.GA11356@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
In-Reply-To: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 12, 2005 at 02:30:45PM -0500, Dean Nelson wrote:
> XPC calls smp_processor_id() twice from xpc_setup_infrastructure() with
> preemption enabled, which gets flagged if 'DEBUG_PREEMPT=y'. This patch
> disables preemption around a now single call to smp_processor_id(). Note
> that it doesn't matter if the thread is moved to another processor once
> it has the processor ID.
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>
> 
> 
> Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
> =================================> --- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2005-07-12 12:09:14.026288661 -0500
> +++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2005-07-12 13:23:34.976151339 -0500
> @@ -72,7 +72,7 @@
>  enum xpc_retval
>  xpc_setup_infrastructure(struct xpc_partition *part)
>  {
> -	int ret;
> +	int ret, cpuid;
>  	struct timer_list *timer;
>  	partid_t partid = XPC_PARTID(part);
>  
> @@ -223,9 +223,13 @@
>  	xpc_vars_part[partid].openclose_args_pa >  					__pa(part->local_openclose_args);
>  	xpc_vars_part[partid].IPI_amo_pa = __pa(part->local_IPI_amo_va);
> -	xpc_vars_part[partid].IPI_nasid = cpuid_to_nasid(smp_processor_id());
> -	xpc_vars_part[partid].IPI_phys_cpuid > -					cpu_physical_id(smp_processor_id());
> +
> +	preempt_disable();
> +	cpuid = smp_processor_id();
> +	preempt_enable();

just use __smp_processor_id() (or the fashionable name of the day)
for it.


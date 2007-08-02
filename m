From: Russ Anderson <rja@sgi.com>
Date: Thu, 02 Aug 2007 20:27:25 +0000
Subject: Re: [RFC][PATCH 2/2] Implement platform_irq_to_vector() for SN
Message-Id: <200708022027.l72KRPGp140700746@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186029046.3875.17.camel@kane-linux>
In-Reply-To: <1186029046.3875.17.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenji Kaneshige wrote:
> 
> Implement platform_irq_to_vector() for SN platform.
> 
> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> 
> ---
>  arch/ia64/sn/kernel/irq.c      |    5 +++++
>  include/asm-ia64/machvec_sn2.h |    2 ++
>  2 files changed, 7 insertions(+)
> 
> Index: linux-2.6.23-rc1/arch/ia64/sn/kernel/irq.c
> =================================> --- linux-2.6.23-rc1.orig/arch/ia64/sn/kernel/irq.c
> +++ linux-2.6.23-rc1/arch/ia64/sn/kernel/irq.c
> @@ -256,6 +256,11 @@ struct irq_chip irq_type_sn = {
>  	.set_affinity	= sn_set_affinity_irq
>  };
>  
> +ia64_vector sn_irq_to_vector(int irq)
> +{
> +	return (ia64_vector)irq;
> +}
> +
>  unsigned int sn_local_vector_to_irq(u8 vector)
>  {
>  	return (CPU_VECTOR_TO_IRQ(smp_processor_id(), vector));

One thing to be aware of is ia64_vector is u8, which can hold
a value from 0-255.  NR_IRQS is 1024.

So sn_irq_to_vector() will truncate any IRQ > 255.



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

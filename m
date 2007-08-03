From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 03 Aug 2007 05:26:51 +0000
Subject: Re: [RFC][PATCH 2/2] Implement platform_irq_to_vector() for SN
Message-Id: <1186118811.3985.59.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186029046.3875.17.camel@kane-linux>
In-Reply-To: <1186029046.3875.17.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2007-08-02 (木) の 15:27 -0500 に Russ Anderson さんは書きました:
> Kenji Kaneshige wrote:
> > 
> > Implement platform_irq_to_vector() for SN platform.
> > 
> > Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> > 
> > ---
> >  arch/ia64/sn/kernel/irq.c      |    5 +++++
> >  include/asm-ia64/machvec_sn2.h |    2 ++
> >  2 files changed, 7 insertions(+)
> > 
> > Index: linux-2.6.23-rc1/arch/ia64/sn/kernel/irq.c
> > =================================> > --- linux-2.6.23-rc1.orig/arch/ia64/sn/kernel/irq.c
> > +++ linux-2.6.23-rc1/arch/ia64/sn/kernel/irq.c
> > @@ -256,6 +256,11 @@ struct irq_chip irq_type_sn = {
> >  	.set_affinity	= sn_set_affinity_irq
> >  };
> >  
> > +ia64_vector sn_irq_to_vector(int irq)
> > +{
> > +	return (ia64_vector)irq;
> > +}
> > +
> >  unsigned int sn_local_vector_to_irq(u8 vector)
> >  {
> >  	return (CPU_VECTOR_TO_IRQ(smp_processor_id(), vector));
> 
> One thing to be aware of is ia64_vector is u8, which can hold
> a value from 0-255.  NR_IRQS is 1024.
> 
> So sn_irq_to_vector() will truncate any IRQ > 255.
> 

What about this:

ia64_vector sn_irq_to_vector(int irq)
{
	if (irq >= IA64_NUM_VECTORS)
		return 0;
	return (ia64_vector)irq;
}

Thanks,
Kenji Kaneshige



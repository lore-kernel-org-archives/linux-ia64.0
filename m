From: Russ Anderson <rja@sgi.com>
Date: Fri, 03 Aug 2007 14:58:39 +0000
Subject: Re: [RFC][PATCH 0/2] SN platform needs platform_irq_to_vector?
Message-Id: <200708031458.l73EwdLI141241893@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186028871.3875.12.camel@kane-linux>
In-Reply-To: <1186028871.3875.12.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenji Kaneshige wrote:
> > There seems to be an issue with this for CPEs.  The net result is
> > when there is a correctable error, the interrupt does not get handled
> > resulting in this message:
> > 
> > -----------------------------------------------------------------
> > irq 30, desc: a000000100c37000, depth: 1, count: 0, unhandled: 0
> > ->handle_irq():  a0000001009a6a50, __end_rodata+0x5010/0x225c0
> > ->chip(): a000000100dfee80, irq_type_sn+0x0/0x80
> > ->action(): 0000000000000000
> >   IRQ_DISABLED set
> > Unexpected irq vector 0x1e on CPU 0!
> > -----------------------------------------------------------------
> > 
> > The CPE handler should be on irq 0x1e (30).  See IA64_CPE_VECTOR .
> > In ia64_mca_late_init() the line
> > 
> >            if (irq_to_vector(irq) = cpe_vector) {
> > 
> > is never true, so setup_irq(irq, &mca_cpe_irqaction); never gets called.
> > 
> 
> Could you please check if [PATCH 2/2] is applied on your kernel again?

Your patch [PATCH 2/2] fixes the problem.

> With [PATCH 2/2], irq_to_vector(irq) just returns the same value as
> vector. So the line
> 
> 	for (irq = 0; irq < NR_IRQS; ++irq)
> 		if (irq_to_vector(irq) = cpe_vector) {
> 
> should be true if cpe_vector is within 0 to NR_IRQ-1.
> 
> I'm sorry but the important thing was missing in my "FYI".
> I said like folows:
> 
> > The "irq = vector" is always true in the following cases:
> >     ...
> >     - Vectors outside FIRST_DEVICE_VECTOR to LAST_DEVICE_VECTOR
> 
> But if the irq is not initialized by __bind_irq_vector() through
> bind_irq_vector() or register_percpu_irq(), irq_to_vector(irq) returns 
> IRQ_VECTOR_UNASSIGNED, which is zero.
> 
> So if [PATCH 2/2] was not applied, irq_to_vector(IA64_CPE_VECTOR)
> may returns zero and "irq_to_vector(irq) = cpe_vector" would never
> be true.

Correct.

> BTW, as you pointed out in the other mail, sn_irq_to_vector() will
> truncate any IRQ > 255. Because of this, "if (irq_to_vector(irq) = 
> cpe_vector)" check will true several times. But I don't know if
> this is the cause of CPE problem, becasue CPE is still fine on my
> dig64 kernel even when the following debug patch applied.

That caused a different problem of the CPE handler getting 
registered on multiple irqs.

From /proc/interrupts:
 30:          1          0          0          0          SN hub  cpe_hndlr
286:          0          0          0          0          SN hub  cpe_hndlr
542:          0          0          0          0          SN hub  cpe_hndlr
798:          0          0          0          0          SN hub  cpe_hndlr

I have a patch in the works to clean up ia64_mca_late_init()
so the handler only gets registered for irq 30.  I will post
it shortly.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

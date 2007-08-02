From: Russ Anderson <rja@sgi.com>
Date: Thu, 02 Aug 2007 14:50:18 +0000
Subject: Re: [RFC][PATCH 0/2] SN platform needs platform_irq_to_vector?
Message-Id: <200708021450.l72EoI5w141174307@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186028871.3875.12.camel@kane-linux>
In-Reply-To: <1186028871.3875.12.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenji Kaneshige wrote:
> 
> Hi Jes-san, Russ-san, Christoph-san and SN platform developers,
> 
> I glanced over the SN code, and I found SN platform doesn't have SN
> specific irq_to_vector() function, though it has SN specific
> local_vector_to_irq() function. I guess it was OK because maybe SN
> platform depends on irq = vector and old generic irq_to_vector() was
> just returning the same value as irq.
> 
> The irq_to_vector() function, however, has been changed by vector
> domain support, and currently it can return the different value from
> irq, even when VECTOR_DOMAIN_PERCPU is not enabled. This can happen
> when an interrupt thorough I/O SAPIC is unregistered and another
> interupt is registered. So if my guess (SN platform depends on irq =
> vector) is true, something problem might happen on SN platform when
> PCI hotplugging or driver reloading.
> 
> If it is true that SN platform depends on irq = vector, we need to
> implement SN specific irq_to_vector() that returns the same value as
> irq, I think. I made sample patches to implement platform specific
> irq_to_vector() as follows. Note that [PATCH 2/2] is not tested yet
> because I don't have any SN platform unfortunately.

There seems to be an issue with this for CPEs.  The net result is
when there is a correctable error, the interrupt does not get handled
resulting in this message:

-----------------------------------------------------------------
irq 30, desc: a000000100c37000, depth: 1, count: 0, unhandled: 0
->handle_irq():  a0000001009a6a50, __end_rodata+0x5010/0x225c0
->chip(): a000000100dfee80, irq_type_sn+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0x1e on CPU 0!
-----------------------------------------------------------------

The CPE handler should be on irq 0x1e (30).  See IA64_CPE_VECTOR .
In ia64_mca_late_init() the line

           if (irq_to_vector(irq) = cpe_vector) {

is never true, so setup_irq(irq, &mca_cpe_irqaction); never gets called.


>     [PATCH 1/2] Add base support for platform_irq_to_vector()
>     [PATCH 2/2] Implement platform_irq_to_vector() for SN
> 
> Could you give me comments?
> 
> Thanks,
> Kenji Kaneshige
> 
> 


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

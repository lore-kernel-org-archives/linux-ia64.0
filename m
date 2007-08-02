From: John Keller <jpk@sgi.com>
Date: Thu, 02 Aug 2007 19:32:55 +0000
Subject: Re: [RFC][PATCH 0/2] SN platform needs platform_irq_to_vector?
Message-Id: <200708021932.l72JWuAi449202@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186028871.3875.12.camel@kane-linux>
In-Reply-To: <1186028871.3875.12.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Hi,
> 
> This is FYI.
> 
> If VECTOR_DOMAIN_PERCPU is NOT enabled:
> 
> The "irq = vector" is always true in the following cases:
>     - reserve_irq_vector(), which is used only by SN
>     - create_irq() used on the system that has NO I/O SAPIC

Could you say a bit more about this case. I see create_irq()
calling find_unassigned_vector() and find_unassigned_irq().
How is "irq = vector" guaranteed to be always true in this case?

John



>     - assign_irq_vector() with AUTO_ASSIGN specified
>     - Vectors outside FIRST_DEVICE_VECTOR to LAST_DEVICE_VECTOR
> 
> The "irq = vector" is not always true in the folliwng cases:
>     - create_irq() used on the system that has I/O SAPICs.
>     - assign_irq_vector() with the value other than AUTO_ASSIGN
>       specified on the system has I/O SAPICs.
> 
> And it is not ensured that those are true even in the future.
> 
> Yasuaki, could you check if it is correct?
> 
> Thanks,
> Kenji Kaneshige
> 
> 
> 
> 2007-08-02 (木) の 08:26 -0500 に John Keller さんは書きました:
> > Yes, we'll take a look at it.
> > 
> > John
> > 
> > 
> > > 
> > > Hi Kenji-san
> > > 
> > > I believe we need this property, but I am not 100% sure, so I am
> > > going to forward your patch to our team who maintain the IRQ code
> > > for Altix.
> > > 
> > > Mike, Aaron or John, would one of you have time to take a look at
> > > this?
> > > 
> > > Thanks,
> > > Jes
> > > 
> > > 
> > > Kenji Kaneshige wrote:
> > > > Hi Jes-san, Russ-san, Christoph-san and SN platform developers,
> > > > 
> > > > I glanced over the SN code, and I found SN platform doesn't have SN
> > > > specific irq_to_vector() function, though it has SN specific
> > > > local_vector_to_irq() function. I guess it was OK because maybe SN
> > > > platform depends on irq = vector and old generic irq_to_vector() was
> > > > just returning the same value as irq.
> > > > 
> > > > The irq_to_vector() function, however, has been changed by vector
> > > > domain support, and currently it can return the different value from
> > > > irq, even when VECTOR_DOMAIN_PERCPU is not enabled. This can happen
> > > > when an interrupt thorough I/O SAPIC is unregistered and another
> > > > interupt is registered. So if my guess (SN platform depends on irq =
> > > > vector) is true, something problem might happen on SN platform when
> > > > PCI hotplugging or driver reloading.
> > > > 
> > > > If it is true that SN platform depends on irq = vector, we need to
> > > > implement SN specific irq_to_vector() that returns the same value as
> > > > irq, I think. I made sample patches to implement platform specific
> > > > irq_to_vector() as follows. Note that [PATCH 2/2] is not tested yet
> > > > because I don't have any SN platform unfortunately.
> > > > 
> > > >     [PATCH 1/2] Add base support for platform_irq_to_vector()
> > > >     [PATCH 2/2] Implement platform_irq_to_vector() for SN
> > > > 
> > > > Could you give me comments?
> > > > 
> > > > Thanks,
> > > > Kenji Kaneshige
> > > > 
> > > 
> > > 
> > 
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


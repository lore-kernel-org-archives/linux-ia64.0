From: Grant Grundler <iod00d@hp.com>
Date: Thu, 05 Aug 2004 18:28:50 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <20040805182850.GF6526@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 05, 2004 at 10:58:50AM -0600, Eric W. Biederman wrote:
> Ok back onto the fastboot list since this is evolving into discussion
> again.

yes - sorry. I'll add linux-ia64 back again too.

> Grant Grundler <iod00d@hp.com> writes:
> > Yes - found it.
> > http://marc.theaimsgroup.com/?l=linux-ia64&m9088102013039&w=2
> > 
> > The patch in the above posting doesn't deal with inflight DMA and
> > "inflight DMA" is a real problem. 
> 
> Actually it can be totally avoided (see my other reply).
> 
> > parisc platforms have a firmware
> > call to deal with the reseting the IO subsystem and I've asked for
> > the same on ia64. It doesn't look like I'll get it. HP's thinking is
> > when we can't trust the OS, use firmware.
> 
> Ah, but we can get to a point where we can trust the OS even
> while ignoring in-flight DMA.  So that should not be a big deal.

Not true. The new kernel will attempt to reprogram the IOMMU
and either cause the system to crash fatally or redirect DMA to random
regions of memory. HP platforms will crash (as they should) if we
get and IOMMU lookup failure because of previous active DMA.

(well, not really random - page zero is most likely to get clobbered)

> My thinking: What is firmware doing on the Box after boot up?
> I would rather have code that can be updated and audited doing the
> work.

Firmware (a) knows platform/chipset specific bits and (b) is read-only.
ie it's not suspectible to corruption like code is.
I agree being able to audit and update the code is a good thing.

> > Is CPU syncronization (get all CPUs in rendevous) taken care of
> > else where? I didn't see anything dealing with it in the patch.
> 
> The strategy on the panic case is to send an IPI to the other cpus and
> hope they respond, if not timeout and progress anyway.

Ok - that's reasonable.

> If it was not
> desirable to get a register dump from them we could probably even
> handle this from the new kernel, using some kind of cpu INIT message.
> Having a reserved area of memory to run in keeps us safe from both
> in-flight DMA and largely from secondary cpus. 

If no IOMMU were involved, I agree the reserved mem would work fine.

> Beyond this we will likely need some actual experience so improve
> things and make them more robust.

*nod*.

thanks,
grant

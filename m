From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 26 Oct 2004 17:49:07 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <200410261049.07181.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, October 26, 2004 10:06 am, Linus Torvalds wrote:
> On Tue, 26 Oct 2004, Jesse Barnes wrote:
> > I'm pretty sure this is the case.  In fact when I last discussed this
> > with Linus he indicated that an ioread shouldn't guarantee DMA completion
> > either, which would mean we could reuse the read_relaxed stuff to
> > implement it.
>
> .. but other people disagreed with me.  I think the consensus was that DMA
> completion _should_ be honoured, but if SGI knows that their machines are
> not doing it right, and take on the responsibility for fixing drivers,
> that's _their_ problem. You only need to care about a few drivers, after
> all.
>
> In short, I think of that DMA completion issue as a SGI-private
> optimization, and _not_ a general rule.

What about the relaxed read then?  Should we have ioread_relaxed?  I thought 
we had agreed that it was easier to assume relaxed semantics for ioread and 
add a dma_sync interface.  Since PCI-X and PCI-Express have optional relaxed 
semantics that might make sense...

Thanks,
Jesse

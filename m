From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 16 May 2003 18:13:07 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705903@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2003-05-16 at 12:59, Grant Grundler wrote:
> On Fri, May 16, 2003 at 12:36:15PM -0500, James Bottomley wrote:
> > You mean we need an interface that is called when the CPU hands off the
> > region to the device and again when the CPU reclaims it (so we always
> > get the writeback or invalidate in the correct place).
> 
> yes
> 
> > How about just adding an ownership attribute to dma_sync..?  It would
> > either be DMA_OWNER_CPU or DMA_OWNER_DEVICE?
> 
> I prefer davem's suggestion of a different function call (*_to_cpu and
> *_to_dev) rather than making the same function do completely different
> things based on parameters. Keeps API documentation and resulting
> implementations for each smaller.

Hmm, another API vs adding properties.  I'm easy on this.  However, the
fact that data direction is an attribute does give me a preference for
having owner as an attribute too.

> > Of course, retrofitting something like this is going to be fun.
> 
> It's not so bad.
> It's really only needed for non-coherent machines.
> Folks who care about those platforms probably already know where
> those calls belong.

Well, it applies to partially coherent machines too.  However, the point
of the API is to make it so that the driver writer doesn't need to
understand where the calls go,  So the API encapsulates all the platform
quirks in a simple set of rules of thumb.

Thus:

    map region
    
    Use region in driver
    
    dma_sync ... DMA_OWNER_DEVICE  .. and direction
    
    device uses region (driver may not touch it)
    
    dma_sync ... DMA_OWNER_CPU .. and direction
    
    driver accesses region again (may repeat back to use region in
    driver)
    
    unmap region
    
That's unambiguous and simple to articulate.  The platform
implementation does the necessary magic.

James




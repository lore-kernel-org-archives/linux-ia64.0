From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 18 May 2003 15:53:20 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705936@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2003-05-17 at 16:09, Russell King wrote:
> On Sat, May 17, 2003 at 01:36:01PM -0500, James Bottomley wrote:
> > How would you feel about making this API change?
> 
> No problem.
> 
> > I take it you have a preference for using _to_cpu and _to_device
> > call variants?
> 
> Thinking about it some, these could be confused with the direction of
> DMA.
> 
> Would "dma_sync_for_device" and "dma_sync_for_cpu" fit better?

That's still a bit ambiguous.

I suppose dma_sync_ownership_to_device etc. would be descriptive but too
cumbersome...?

James




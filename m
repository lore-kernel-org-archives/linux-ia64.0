From: Jeremy Higdon <jeremy@sgi.com>
Date: Fri, 16 May 2003 07:48:12 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705895@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 07:32:26PM -0700, David S. Miller wrote:
>    From: James Bottomley <James.Bottomley@HansenPartnership.com>
>    Date: 15 May 2003 21:26:14 -0500
>    
>    It was my impression that a CPU cache invalidate cycle relinquishes the
>    cache line (and thus leaves the line free to be owned by the device). 
>    The DMA_TO_DEVICE of dma_sync.. does this, why isn't that sufficient?  I
>    grant that CPU does auto ownership, so if the CPU ever touches the data
>    again the cache line is pulled back in again.
>    
> What flushes the cpu cache after the cpu writes to 'buf'
> so that the device sees what the CPU wrote there?  Consider
> copy-back L2 caches like MIPS has.

Isn't that what dma_cache_wback_inv does?  It flushes cpu cache to memory
so that it is visible to devices.  Is there some additional semantic
desired?

jeremy


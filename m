From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 16 May 2003 02:26:14 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705887@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> You don't understand, a driver does:
> 
> 	pci_dma_sync_single(... buf);
> 
> This transfers ownership of the buffer from device back to the CPU.
> It guarentees that the CPU will see uptodate contents of the buffer
> and that it may make modifications to 'buf'.
> 
> Then it looks at 'buf', and decides that it wants to give the buffer
> back to the device.  What does it call to transfer ownership back from
> CPU to device?
> 
> Answer: No such API call exists.
> 
> This is a big problem for implementations that need to flush CPU
> caches in order to implement the cpu<-->device buffer ownership
> transfer properly.

It was my impression that a CPU cache invalidate cycle relinquishes the
cache line (and thus leaves the line free to be owned by the device). 
The DMA_TO_DEVICE of dma_sync.. does this, why isn't that sufficient?  I
grant that CPU does auto ownership, so if the CPU ever touches the data
again the cache line is pulled back in again.

Is the issue that we have no way of preventing the CPU from pulling in
the cache line if it is referenced?

James




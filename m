From: Grant Grundler <iod00d@hp.com>
Date: Fri, 16 May 2003 17:59:24 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 16, 2003 at 12:36:15PM -0500, James Bottomley wrote:
> You mean we need an interface that is called when the CPU hands off the
> region to the device and again when the CPU reclaims it (so we always
> get the writeback or invalidate in the correct place).

yes

> How about just adding an ownership attribute to dma_sync..?  It would
> either be DMA_OWNER_CPU or DMA_OWNER_DEVICE?

I prefer davem's suggestion of a different function call (*_to_cpu and
*_to_dev) rather than making the same function do completely different
things based on parameters. Keeps API documentation and resulting
implementations for each smaller.

> Of course, retrofitting something like this is going to be fun.

It's not so bad.
It's really only needed for non-coherent machines.
Folks who care about those platforms probably already know where
those calls belong.

grant


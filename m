From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 16 May 2003 17:36:15 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705900@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-05-15 at 21:32, David S. Miller wrote:
> The "issue" is that we need a pci_dma_sync_*_to_device() call added.
> We should also remane pci_dma_sync_*() to pci_dma_sync_*_to_cpu()
> to make all of the naming consistent and update all the drivers.

OK, I get it now (I was thinking really in terms of the old
writeback/invalidate interface where you had to know how to place them).

You mean we need an interface that is called when the CPU hands off the
region to the device and again when the CPU reclaims it (so we always
get the writeback or invalidate in the correct place).

How about just adding an ownership attribute to dma_sync..?  It would
either be DMA_OWNER_CPU or DMA_OWNER_DEVICE?

Of course, retrofitting something like this is going to be fun.

James




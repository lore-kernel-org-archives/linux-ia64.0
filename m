From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 02:32:26 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: James Bottomley <James.Bottomley@HansenPartnership.com>
   Date: 15 May 2003 21:26:14 -0500
   
   It was my impression that a CPU cache invalidate cycle relinquishes the
   cache line (and thus leaves the line free to be owned by the device). 
   The DMA_TO_DEVICE of dma_sync.. does this, why isn't that sufficient?  I
   grant that CPU does auto ownership, so if the CPU ever touches the data
   again the cache line is pulled back in again.
   
What flushes the cpu cache after the cpu writes to 'buf'
so that the device sees what the CPU wrote there?  Consider
copy-back L2 caches like MIPS has.

   Is the issue that we have no way of preventing the CPU from pulling in
   the cache line if it is referenced?
   
The "issue" is that we need a pci_dma_sync_*_to_device() call added.
We should also remane pci_dma_sync_*() to pci_dma_sync_*_to_cpu()
to make all of the naming consistent and update all the drivers.


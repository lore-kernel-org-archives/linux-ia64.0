From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 16 May 2003 00:29:05 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 04:27:33PM -0700, David S. Miller wrote:
>    From: Jesse Barnes <jbarnes@sgi.com>
>    Date: Thu, 15 May 2003 13:24:12 -0700
>    
>    How about this: drivers that support PCI-X cards are required to
>    program the full 64 bits of a pci_alloc_consistent DMA address, the
>    top 32 bits of which can be zero for most platforms.
> 
> How about this: you put the device attributes where they belong,
> in the device struct.

That's fine, it'll work for us.  I just wanted to make sure that
dma_alloc_consistent could return a 64 bit DMA addr.  Having a
consistent_dma_mask will allow us to do that for devices that support
it.  We'll have to switch devices that can't into PCI mode for them to
operate correctly on our hw.

Also, are you saying that tg3 doesn't support all 64 bits of the DMA
address?  If so, I'm not sure how it's working on our platform either,
unless we're forcing it into PCI mode; I'll have to check.

Thanks,
Jesse


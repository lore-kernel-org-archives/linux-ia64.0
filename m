From: Matthew Wilcox <willy@debian.org>
Date: Thu, 15 May 2003 21:29:18 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705848@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 01:24:12PM -0700, Jesse Barnes wrote:
> > All devices I am aware of do not support 64-bit addresses for their
> > descriptors, only 32-bit.
> 
> PCI-X devices are required to support 64 bit addrs.  They'll only
> generate SAC if the top 32 bits are 0, but our platform is incapable
> of handling this, since the IOMMU can't be used in PCI-X mode (i.e. we
> need high order bits for PCI-X devices).

I think you're missing Dave's point.  While the card is required to
support DAC that doesn't mean the device on the card is necessarily
capable of being handed a full 64-bit address to DMA into.

From the way he's talking, I'd surmise tg3 is a good example -- I suspect
the ring buffers only support 32-bit addresses.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk


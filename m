From: Grant Grundler <iod00d@hp.com>
Date: Fri, 16 May 2003 01:20:51 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705881@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 04:53:30PM -0700, David S. Miller wrote:
> But I am ever further confused, how do things like tg3 cards even
> function TODAY on any PCI-X systems.

They work just fine on most platforms with 32-bit addresses.
The issue is with what the SGI platform can support, not what
the PCI-X devices can support.

BTW, adding consistent_dma_mask to struct pci_dev and a
corresponding pci_set_consistent_dma_mask() is a good idea.
I think it would simplify our SBA code a bit.

thanks,
grant


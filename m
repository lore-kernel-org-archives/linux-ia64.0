From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 15 May 2003 14:44:33 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705822@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-05-15 at 08:17, Colin Ngam wrote:
> Anyway, to make a long story short, we like to "extend" these
> interfaces to return DMA addresses of 64 bits if and when the
> driver has the full capabality to support DAC - via it's
> DMA mask capability setting.
> 
> This extention will not break current usages of these interface,
> and as driver changes, this extension will enable platforms to
> support all of it's Physical Memory via the above 2 Interfaces
> without exhausting limited system mapping resources.

The intent of the dma_alloc_.. was to follow the PCI spec (i.e. lower 32
bits).  However, it does take the GFP_ flags, and thus could be adjusted
to use the region specifier portion of those.

We're currently debating this very issue, since it came up in the
context of the 2.6 must fix list.

James




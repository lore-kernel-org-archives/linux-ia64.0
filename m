From: Grant Grundler <iod00d@hp.com>
Date: Thu, 15 May 2003 19:16:37 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705841@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 08:17:58AM -0500, Colin Ngam wrote:
> Hi,
> 
> The Altix PCI-X Bridge chipset expects devices that runs in
> PCI-X mode to always be 64Bit DMA Address capable(DAC).  This
> requirement is directly in conflict with both the
> pci_alloc_consistent() and dma_alloc_coherent() interfaces.

I don't (yet) see the conflict.
Can't the 32-bit address can be extended to 64-bits as
described in the dma_alloc_coherent() interface?
Are you running out of 32-bit memory?


> Anyway, to make a long story short, we like to "extend" these
> interfaces to return DMA addresses of 64 bits if and when the
> driver has the full capabality to support DAC - via it's
> DMA mask capability setting.

jbarnes@sgi.com proposed this before.  On April 23, 2002, davem wrote:
| %99 of PCI chips out there do not support DAC addressing for things
| like descriptor tables etc.  So it's not a matter of "well" it's
| a matter of "at all".

If you want the complete thread, check ia64-linux 2002 mail archives.

hth,
grant


From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 15 May 2003 20:24:12 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 01:07:39PM -0700, David S. Miller wrote:
>    From: Colin Ngam <cngam@sgi.com>
>    Date: Thu, 15 May 2003 08:17:58 -0500
>    
>    Anyway, to make a long story short, we like to "extend" these
>    interfaces to return DMA addresses of 64 bits if and when the
>    driver has the full capabality to support DAC - via it's
>    DMA mask capability setting.
> 
> All devices I am aware of do not support 64-bit addresses for their
> descriptors, only 32-bit.

PCI-X devices are required to support 64 bit addrs.  They'll only
generate SAC if the top 32 bits are 0, but our platform is incapable
of handling this, since the IOMMU can't be used in PCI-X mode (i.e. we
need high order bits for PCI-X devices).

> There is a huge difference between using a "64-bit address" and
> requiring to generate a DAC cycle, the latter of which is
> probably what you need and that is independant of what kind of
> address pci_alloc_consistent() is giving you.

Unfortunately, we need both for PCI-X on Altix.  How about this:
drivers that support PCI-X cards are required to program the full 64
bits of a pci_alloc_consistent DMA address, the top 32 bits of which
can be zero for most platforms.  That means that the device will only
generate a SAC for most platforms, but on platforms like ours, the top
32 bits will contain useful information, so a DAC will be generated.

Thanks,
Jesse


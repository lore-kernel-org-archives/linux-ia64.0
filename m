From: Colin Ngam <cngam@sgi.com>
Date: Fri, 16 May 2003 00:36:55 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705878@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"David S. Miller" wrote:

>    From: Colin Ngam <cngam@sgi.com>
>    Date: Thu, 15 May 2003 18:57:09 -0500
>
>    It is in the PCI-X Spec that all PCI-X devices in PCI-X Mode have
>    to support DAC.
>
> Having to support DAC cycles does not mean that it must support full
> 64-bit DMA addresses in it's descriptors.

Hi David,

I do not believe it is within spec to perform DAC when the
Upper 32bits are 0s.  Current usage of pci_alloc_consistent(),
even if you want to do DAC, you cannot, because the interface
is defined to return only 32bits worth of addresses.

However, I think we are beyond this point now.

Thanks.

colin

>
>
> A cost sensitive PCI-X device may wish to use 32-bit addressing in
> it's descriptors in order to keep pin counts down etc.



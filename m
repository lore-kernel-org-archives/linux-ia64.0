From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 23:45:42 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705865@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"David S. Miller" wrote:

>    From: James Bottomley <James.Bottomley@HansenPartnership.com>
>    Date: 15 May 2003 17:47:04 -0500
>
>    OK, now you've confused me.
>
> Their hardware platform cannot guarentee low-32bit memory allocations
> to devices because each node can have physical memory starting at
> >4GB etc etc.

Hi,

Something else I do not understand .. in the PCI world, what does
Physical Memory Address got to do with 32Bit Mapped DMA
Bus Address?

Not only do we not guarantee that we cannot generate 32 Bit Memory
Allocations .. we plain old do not have Memory Addresses smaller
below 32Bits .. well, below 48 Bits for that matter .. I have
not seen any of the drivers broken yet - e.g. qlXXX, acenic, tg3 etc.

Thanks.

colin



From: Joerg Roedel <joro@8bytes.org>
Date: Fri, 23 Nov 2018 13:03:13 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181123130313.GI1586@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
 <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk>
 <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
 <20181123104918.GE1586@8bytes.org>
 <20181123110155.GR30658@n2100.armlinux.org.uk>
In-Reply-To: <20181123110155.GR30658@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Robin Murphy <robin.murphy@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, jdmason@kudzu.us, xen-devel@lists.xenproject.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Fri, Nov 23, 2018 at 11:01:55AM +0000, Russell King - ARM Linux wrote:
> Yuck.  So, if we have a 4GB non-PAE 32-bit system, or a PAE system
> where we have valid memory across the 4GB boundary and no IOMMU,
> we have to reserve the top 4K page in the first 4GB of RAM?

But that is only needed when dma_addr_t is 32bit anyway, no?

> Rather than inventing magic cookies like this, I'd much rather we
> sanitised the API so that we have functions that return success or
> an error code, rather than trying to shoe-horn some kind of magic
> error codes into dma_addr_t and subtly break systems in the process.

Sure, but is has the obvious downside that we need to touch every driver
that uses these functions, and that are probably a lot of drivers.


Regards,

	Joerg

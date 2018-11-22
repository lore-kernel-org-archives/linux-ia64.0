From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Nov 2018 17:55:25 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de> <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com>
 <20181122170715.GI30658@n2100.armlinux.org.uk> <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com>
 <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
In-Reply-To: <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: robin.murphy@arm.com
Cc: linux@armlinux.org.uk, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, joro@8bytes.org, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, jdmason@kudzu.us, xen-devel@lists.xenproject.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com

On Thu, Nov 22, 2018 at 9:52 AM Robin Murphy <robin.murphy@arm.com> wrote:
>
> Unfortunately, with things like the top-down IOVA allocator, and 32-bit
> systems in general, "the top 4095" values may well still be valid
> addresses -

Ugh.

> The only immediate benefit I can see is that we could distinguish cases
> like the first which can never possibly succeed, and thus callers could
> actually give up instead of doing what various subsystems currently do
> and retry the exact same mapping indefinitely on the apparent assumption
> that errors must be transient.

No, the big immediate benefit of allowing "return -EINVAL" etc is
simply legibility and error avoidance.

It's basically how pretty much all the rest of the kernel returns
errors, so not only is it very obvious, it's also what people do
without even thinking.. So it would be good to work.

                       Linus

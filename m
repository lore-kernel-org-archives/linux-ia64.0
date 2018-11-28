From: Christoph Hellwig <hch@lst.de>
Date: Wed, 28 Nov 2018 07:41:17 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181128074117.GA21126@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de> <CAHk-=wh=_T=A53+o4zLNbKio43LGqVDb0KCbWPDvAg54bRDmWw@mail.gmail.com> <20181122170715.GI30658@n2100.armlinux.org.uk> <CAHk-=wgfGzXuDAKFQPdzMib3QCRHfSTsy5=gLU-WCoya+Ym+1A@mail.gmail.com> <11829e3c-7302-f821-cf5c-863e5267a17b@arm.com> <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com> <20181123065511.GA17856@lst.de>
In-Reply-To: <20181123065511.GA17856@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>, the arch/x86 maintainers <x86@kernel.org>, linux@armlinux.org.uk, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, robin.murphy@arm.com, Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org

On Fri, Nov 23, 2018 at 07:55:11AM +0100, Christoph Hellwig wrote:
> On Thu, Nov 22, 2018 at 09:55:25AM -0800, Linus Torvalds wrote:
> > No, the big immediate benefit of allowing "return -EINVAL" etc is
> > simply legibility and error avoidance.
> 
> Well, I can tweak the last patch to return -EINVAL from dma_mapping_error
> instead of the old 1 is as bool true.  The callers should all be fine,
> although I'd have to audit them.  Still wouldn't help with being able to
> return different errors.

Any opinions?  I'd really like to make some forward progress on this
series.

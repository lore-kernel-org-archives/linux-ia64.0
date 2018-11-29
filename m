From: Christoph Hellwig <hch@lst.de>
Date: Thu, 29 Nov 2018 18:31:32 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181129183132.GA30281@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com> <20181123065511.GA17856@lst.de> <20181128074117.GA21126@lst.de> <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com> <20181128174545.GJ30658@n2100.armlinux.org.uk> <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com> <20181128180841.GM30658@n2100.armlinux.org.uk> <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com> <20181129162323.GA27068@lst.de> <CAHk-=wi2K7_+dgCbc-sAK9CST5Zh+pOuH7sVT9WW-kqs50HSzQ@mail.gmail.com>
In-Reply-To: <CAHk-=wi2K7_+dgCbc-sAK9CST5Zh+pOuH7sVT9WW-kqs50HSzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Thu, Nov 29, 2018 at 09:44:05AM -0800, Linus Torvalds wrote:
> No. Really. If there's no iotlb, then you just mark that one page
> reserved. It simply doesn't get used. It doesn't mean you suddenly
> need a swiotlb.

Sure, we could just skip that page entirely based on dma_to_phys.

> But whatever. It's independent from the patch series under discussion.
> Make dma_mapping_error() at least return a real error (eg -EINVAL, or
> whatever is the common error), and we can maybe do this later.

Ok, I'll do that.

> Or, better yet, plan on removing the single-page dma mappign entirely
> at a later date, and make the issue moot.

What would be the replacement?  Build a S/G list for every single page
mapping?  Not sure that would create a lot of happy campers..

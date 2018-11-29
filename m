From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 29 Nov 2018 18:53:32 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <CAHk-=wjjmtZAAGvB8c6hyKvABPHNTfE+b+eHu7iktdogDfTgMw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAHk-=whxf0zqutExPr_j1A625Z3gcL6k_ABzKo1BtzN4F93hkA@mail.gmail.com>
 <20181123065511.GA17856@lst.de> <20181128074117.GA21126@lst.de>
 <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com>
 <20181128174545.GJ30658@n2100.armlinux.org.uk> <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com>
 <20181128180841.GM30658@n2100.armlinux.org.uk> <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com>
 <20181129162323.GA27068@lst.de> <CAHk-=wi2K7_+dgCbc-sAK9CST5Zh+pOuH7sVT9WW-kqs50HSzQ@mail.gmail.com>
 <20181129183132.GA30281@lst.de>
In-Reply-To: <20181129183132.GA30281@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Thu, Nov 29, 2018 at 10:31 AM Christoph Hellwig <hch@lst.de> wrote:
>
> > Or, better yet, plan on removing the single-page dma mappign entirely
> > at a later date, and make the issue moot.
>
> What would be the replacement?  Build a S/G list for every single page
> mapping?  Not sure that would create a lot of happy campers..

It's what we ended up doing with some other cases, and it didn't
really end up hurting as much as I thought it would.

I'm thinking of the vfs functions that end up turning "buf, len" into

        struct iovec iov = { .iov_base = (void __user *)buf, .iov_len = len };

and then passing it around as a single-entry iov instead (not even
that - they end up being an iov_iter, which is not just the iov, but
the whole "what _kind_ of iov" indirection)

Maybe a very similar model could be used for just simplifying the core
dma mapping setup: sure, people will want to do single-area dma, but
how bad would it be to just turn them into single-entry SG lists on
stack, and then the dma-maping internally would just always see that?

Most of the high-performance IO is already using SG lists anyway, no?
Disk/networking/whatever.

But just an idea. And the "map_sg()" error handling isn't actually any
better, I think. It returns zero on error, no? So it's not improving
the error handling.

The whole dma-mapping layer seems full of those kinds of "inspired
error handling choices" ;)

                  Linus

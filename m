From: Christoph Hellwig <hch@lst.de>
Date: Thu, 29 Nov 2018 18:55:37 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V2
Message-Id: <20181129185537.GA30824@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181128074117.GA21126@lst.de> <CAHk-=wg5+rXK8dpjkSmK7tuz29VfxVWNEwmTVYB409mmyLkeew@mail.gmail.com> <20181128174545.GJ30658@n2100.armlinux.org.uk> <CAHk-=whnz4Kty6cas11bc2Gh=9zTzeeRS2k=dV9Hfc4B=xnHkQ@mail.gmail.com> <20181128180841.GM30658@n2100.armlinux.org.uk> <CAHk-=whcbiSxSUprsKjVPEdN5-+o8WnTGiKxEV-+HbKNDs=iNA@mail.gmail.com> <20181129162323.GA27068@lst.de> <CAHk-=wi2K7_+dgCbc-sAK9CST5Zh+pOuH7sVT9WW-kqs50HSzQ@mail.gmail.com> <20181129183132.GA30281@lst.de> <CAHk-=wjjmtZAAGvB8c6hyKvABPHNTfE+b+eHu7iktdogDfTgMw@mail.gmail.com>
In-Reply-To: <CAHk-=wjjmtZAAGvB8c6hyKvABPHNTfE+b+eHu7iktdogDfTgMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, robin.murphy@arm.com, the arch/x86 maintainers <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Thu, Nov 29, 2018 at 10:53:32AM -0800, Linus Torvalds wrote:
> Most of the high-performance IO is already using SG lists anyway, no?
> Disk/networking/whatever.

Networking basically never uses S/G lists.  Block I/O mostly uses it,
and graphics / media seems to have a fair amount of S/G uses, including
very, erm special ones.

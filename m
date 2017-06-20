From: Christoph Hellwig <hch@lst.de>
Date: Tue, 20 Jun 2017 13:15:03 +0000
Subject: Re: new dma-mapping tree, was Re: clean up and modularize arch dma_mapping interface V2
Message-Id: <20170620131503.GA30769@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170620124140.GA27163@lst.de>
 <6025d4d4-1975-9598-c16d-26d17d029ec7@arm.com>
In-Reply-To: <6025d4d4-1975-9598-c16d-26d17d029ec7@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, dri-devel@lists.freedesktop.org, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-samsung-soc@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, xen-devel@lists.xenproject.org, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org, openrisc@lists.librecores.org, linux-tegra@vger.kernel.org, linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, dmaengine@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jun 20, 2017 at 02:14:36PM +0100, Robin Murphy wrote:
> Hi Christoph,
> 
> On 20/06/17 13:41, Christoph Hellwig wrote:
> > On Fri, Jun 16, 2017 at 08:10:15PM +0200, Christoph Hellwig wrote:
> >> I plan to create a new dma-mapping tree to collect all this work.
> >> Any volunteers for co-maintainers, especially from the iommu gang?
> > 
> > Ok, I've created the new tree:
> > 
> >    git://git.infradead.org/users/hch/dma-mapping.git for-next
> > 
> > Gitweb:
> > 
> >    http://git.infradead.org/users/hch/dma-mapping.git/shortlog/refs/heads/for-next
> > 
> > And below is the patch to add the MAINTAINERS entry, additions welcome.
> 
> I'm happy to be a reviewer, since I've been working in this area for
> some time, particularly with the dma-iommu code and arm64 DMA ops.

Great, I'll add you!

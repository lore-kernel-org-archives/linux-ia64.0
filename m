From: Christoph Hellwig <hch@lst.de>
Date: Tue, 09 Jan 2018 15:38:26 +0000
Subject: Re: [PATCH 16/67] powerpc: rename dma_direct_ to dma_nommu_
Message-Id: <20180109153826.GA10086@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de> <20171229081911.2802-17-hch@lst.de> <878tdgtwzp.fsf@concordia.ellerman.id.au> <20180104084930.GB3251@lst.de>
In-Reply-To: <20180104084930.GB3251@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-snps-arc@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jan 04, 2018 at 09:49:30AM +0100, Christoph Hellwig wrote:
> On Tue, Jan 02, 2018 at 08:45:30PM +1100, Michael Ellerman wrote:
> > Christoph Hellwig <hch@lst.de> writes:
> > 
> > > We want to use the dma_direct_ namespace for a generic implementation,
> > > so rename powerpc to the second best choice: dma_nommu_.
> > 
> > I'm not a fan of "nommu". Some of the users of direct ops *are* using an
> > IOMMU, they're just setting up a 1:1 mapping once at init time, rather
> > than mapping dynamically.
> > 
> > Though I don't have a good idea for a better name, maybe "1to1",
> > "linear", "premapped" ?
> 
> It seems like a nice counter part to the dma_iommu_ops used just about
> anywhere else in ppc.
> 
> But I'll happily take any maintainer bike shed decision for the next
> series.  Remember that in a merge window or two it will hopefully
> go away in favor of the new generic dma_direct ops.

Michael, please suggest what name you want for the next iteration,
I don't want to hold up the series on a naming bikeshed.

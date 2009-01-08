From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 08 Jan 2009 01:55:04 +0000
Subject: Re: [PATCH 0/13] IA64: unifying ways to handle multiple sets of
Message-Id: <20090108105518B.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<20090107195646.GE4647@uranus.ravnborg.org>
In-Reply-To: <20090107195646.GE4647@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: sam@ravnborg.org
Cc: fujita.tomonori@lab.ntt.co.jp, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davem@davemloft.net

On Wed, 7 Jan 2009 20:56:46 +0100
Sam Ravnborg <sam@ravnborg.org> wrote:

> On Mon, Jan 05, 2009 at 11:36:05PM +0900, FUJITA Tomonori wrote:
> > This patchset is the first part of the unification of ways to handle
> > multiple sets of dma mapping API. The whole work consists of three
> > patchset. This is for IA64 and can be applied independently.
> > 
> > dma_mapping_ops (or dma_ops) struct is used to handle multiple sets of
> > dma mapping API by X86, SPARC, and POWER. IA64 also handle multiple
> > sets of dma mapping API but in a very different way (some define
> > magic).
> > 
> > X86 and IA64 share VT-d and SWIOTLB code. We need several workarounds
> > for it because of the deference of ways to handle multiple sets of dma
> > mapping API (e.g., X86 people can't freely change struct
> > dma_mapping_ops in x86's dma-mapping.h now because it could break
> > IA64).  Seems POWER will use SWIOTLB code soon. I think that it's time
> > to unify ways to handle multiple sets of dma mapping API. After
> > applying the whole work, we have struct dma_map_ops
> > include/linux/dma-mapping.h (I also dream of changing all the archs to
> > use SWIOTLB in order to remove the bounce code in the block and
> > network stacks...).
> > 
> > This patchset changes IA64 to handle multiple sets of dma mapping API
> > in the common way (as X86, SPARC, and POWER do):
> 
> Do you have any plans to update sparc too?
> Maybe it is not relevant.

I'll do after finishing IA64 and X86. It's not a huge gain since SPARC
doesn't share IOMMU code with other architectures. But I think that it
would be nice to remove arch/sparc/include/asm/dma-mapping_64.h

The long-term goal is removing the bounce code in the network and
block stacks, and some drivers (using sorta SWIOTLB on non IOMMU
systems instead). So I try to convert all the architectures to use
this generic mechanism (though I'm not sure all the arch maintainers
agree with it).

Thanks,

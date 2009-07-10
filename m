From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 10 Jul 2009 14:12:48 +0000
Subject: Re: [00/15] swiotlb cleanup
Message-Id: <20090710141248.GE26264@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp> <20090710051236.GA22218@elte.hu> <1247234512.4002.417.camel@zakaz.uk.xensource.com>
In-Reply-To: <1247234512.4002.417.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jeremy Fitzhardinge <jeremy@goop.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "x86@kernel.org" <x86@kernel.org>, "beckyb@kernel.crashing.org" <beckyb@kernel.crashing.org>, Joerg Roedel <joerg.roedel@amd.com>


* Ian Campbell <Ian.Campbell@eu.citrix.com> wrote:

> I've not examined the series in detail it looks OK but I don't 
> think it is quite sufficient. The Xen determination of whether a 
> buffer is dma_capable or not is based on the physical address 
> while dma_capable takes only the dma address.
> 
> I'm not sure we can "invert" our conditions to work back from dma 
> address to physical since given a start dma address and a length 
> we would need to check that dma_to_phys(dma+PAGE_SIZE) = 
> dma_to_phys(dma)+PAGE_SIZE etc. However dma+PAGE_SIZE might belong 
> to a different domain so translating it to a physical address in 
> isolation tells us nothing especially useful since it would give 
> us the physical address in that other guest which is useless to 
> us. If we could pass both physical and dma address to dma_capable 
> I think that would probably be sufficient for our purposes.
> 
> As well as that Xen needs some way to influence the allocation of 
> the actual bounce buffer itself since we need to arrange for it to 
> be machine address contiguous as well as physical address 
> contiguous. This series explicitly removes those hooks without 
> replacement. My most recent proposal was to have a new 
> swiotlb_init variant which was given a preallocated buffer which 
> this series doesn't necessarily preclude.
> 
> The phys_to_dma and dma_to_phys translation points are the last 
> piece Xen needs and seem to be preserved in this series.
> 
> However Fujita's objection to all of the previous swiotlb-for-xen 
> proposals was around the addition of the Xen hooks in whichever 
> location. Originally these hooks were via __weak functions and 
> later proposals implemented them via function pointer hooks in the 
> x86 implementations of the arch-abstract interfaces (phys<->dma 
> and dma_capable etc). I don't think this series addresses those 
> objections (fair enough -- it wasn't intended to) or leads to any 
> new approach to solving the issue, although I also don't think it 
> makes the issue any harder to address. I don't think it will be 
> possible to make progress on Xen usage of swiotlb until a solution 
> can be found to this conflict of opinion.
> 
> Fujita suggested that we export the core sync_single() 
> functionality and reimplemented the surrounding infrastructure in 
> terms of that (and incorporating our additional requirements). I 
> prototyped this (it is currently unworking, in fact it seems to 
> have developed rather a taste for filesystems :-() but the 
> diffstat of my WIP patch is:
>
>          arch/x86/kernel/pci-swiotlb.c |    6 
>          arch/x86/xen/pci-swiotlb.c    |    2 
>          drivers/pci/xen-iommu.c       |  385 ++++++++++++++++++++++++++++++++++++++++--
>          include/linux/swiotlb.h       |   12 +
>          lib/swiotlb.c                 |   10 -
>          5 files changed, 385 insertions(+), 30 deletions(-)
>
> where a fair number of the lines in xen-iommu.c are copies of 
> functions from swiotlb.c with minor modifications. As I say it 
> doesn't work yet but I think it's roughly indicative of what such 
> an approach would look like. I don't like it much but am happy to 
> run with it if it looks to be the most acceptable approach. [...]

+400 lines of code to avoid much fewer lines of generic code impact 
on the lib/swiotlb.c side sounds like a bad technical choice to me. 

It makes the swiotlb code less useful and basically forks a random 
implementation of it in drivers/pci/xen-iommu.c.

Fujita-san, can you think of a solution that avoids the whole-sale 
copying of hundreds of lines of code?

	Ingo

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 10 Jul 2009 05:35:10 +0000
Subject: Re: [00/15] swiotlb cleanup
Message-Id: <20090710143408A.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<20090710051236.GA22218@elte.hu>
In-Reply-To: <20090710051236.GA22218@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu
Cc: fujita.tomonori@lab.ntt.co.jp, Ian.Campbell@citrix.com, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, beckyb@kernel.crashing.org, joerg.roedel@amd.com

On Fri, 10 Jul 2009 07:12:36 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
> > - removes unused (and unnecessary) hooks in swiotlb.
> > 
> > - adds dma_capable() and converts swiotlb to use it. It can be used to
> > know if a memory area is dma capable or not. I added
> > is_buffer_dma_capable() for the same purpose long ago but it turned
> > out that the function doesn't work on POWERPC.
> > 
> > This can be applied cleanly to linux-next, -mm, and mainline. This
> > patchset touches multiple architectures (ia64, powerpc, x86) so I
> > guess that -mm is appropriate for this patchset (I don't care much
> > what tree would merge this though).
> > 
> > This is tested on x86 but only compile tested on POWERPC and IA64.
> > 
> > Thanks,
> > 
> > > >  arch/ia64/include/asm/dma-mapping.h    |   18 ++++++
> >  arch/powerpc/include/asm/dma-mapping.h |   23 +++++++
> >  arch/powerpc/kernel/dma-swiotlb.c      |   48 +---------------
> >  arch/x86/include/asm/dma-mapping.h     |   18 ++++++
> >  arch/x86/kernel/pci-dma.c              |    2 +-
> >  arch/x86/kernel/pci-gart_64.c          |    5 +-
> >  arch/x86/kernel/pci-nommu.c            |    2 +-
> >  arch/x86/kernel/pci-swiotlb.c          |   25 --------
> >  include/linux/dma-mapping.h            |    5 --
> >  include/linux/swiotlb.h                |   11 ----
> >  lib/swiotlb.c                          |  102 +++++++++-----------------------
> >  11 files changed, 92 insertions(+), 167 deletions(-)
> 
> Hm, the functions and facilities you remove here were added as part 
> of preparatory patches for Xen guest support. You were aware of 
> them, you were involved in discussions about those aspects with Ian 
> and Jeremy but still you chose not to Cc: either of them and you 
> failed to address that aspect in the changelogs.
> 
> I'd like the Xen code to become cleaner more than anyone else here i 
> guess, but patch submission methods like this are not really 
> helpful. A far better method is to be open about such disagreements, 
> to declare them, to Cc: everyone who disagrees, and to line out the 
> arguments in the changelogs as well - instead of just curtly 
> declaring those APIs 'unused' and failing to Cc: involved parties.
> 
> Alas, on the technical level the cleanups themselves look mostly 
> fine to me. Ian, Jeremy, the changes will alter Xen's use of 
> swiotlb, but can the Xen side still live with these new methods - in 
> particular is dma_capable() sufficient as a mechanism and can the 
> Xen side filter out DMA allocations to make them physically 
> continuous?

dma_capable() doesn't work for Xen in the way that Ian hopes.

As I said to him again and again, he tries to use arch code in the
very original way, and it's unacceptable (of course, he disagreed with
it).

I don't think that we need to take account of dom0 support; we don't
have a clear idea about an acceptable dom0 design (it needs to use
swiotlb code? I don't know yet), we don't even know we will have dom0
support in mainline. That's why I didn't CC this patchset to Xen
camp.

I think that it's more reasonable to think about how the code can
works for dom0 support when Xen people come with the new dom0 code.


> Ben, Tony, Becky, any objections wrt. the PowerPC / IA64 impact? If 
> everyone agrees i can apply them to the IOMMU tree, test it and push 
> it out to -next, etc.
> 
> 	Ingo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

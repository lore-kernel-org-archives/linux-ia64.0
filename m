From: Tomasz Figa <tfiga@chromium.org>
Date: Wed, 19 Aug 2020 14:22:29 +0000
Subject: Re: [PATCH 05/28] media/v4l2: remove V4L2-FLAG-MEMORY-NON-CONSISTENT
Message-Id: <CAAFQd5DrEq7UVi_aH=-DO4xYC3SbjJ3m1aQSbt=8THL-W+orMQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de> <20200819065555.1802761-6-hch@lst.de>
 <CAAFQd5COLxjydDYrfx47ht8tj-aNPiaVnC+WyQA7nvpW4gs=ww@mail.gmail.com>
 <62e4f4fc-c8a5-3ee8-c576-fe7178cb4356@arm.com> <CAAFQd5AcCTDguB2C9KyDiutXWoEvBL8tL7+a==Uo8vj_8CLOJw@mail.gmail.com>
 <2b32f1d8-16f7-3352-40a5-420993d52fb5@arm.com>
In-Reply-To: <2b32f1d8-16f7-3352-40a5-420993d52fb5@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, alsa-devel@alsa-project.org, linux-ia64@vger.kernel.org, Linux Doc Mailing List <linux-doc@vger.kernel.org>, nouveau@lists.freedesktop.org, linux-nvme@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc <linux-samsung-soc@vger.kernel.org>, Joonyoung Shim <jy0922.shim@samsung.com>, linux-scsi@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Matt Porter <mporter@kernel.crashing.org>, Linux Media Mailing List <linux-media@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, "list@263.net:IOMMU DRIVERS" <iommu@lists.linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <linux-arm-kernel@lists.infradead.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, Seung-Woo Kim <sw0312.kim@samsung.com>, linux-mips@vger.kernel.org

On Wed, Aug 19, 2020 at 4:07 PM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 2020-08-19 13:49, Tomasz Figa wrote:
> > On Wed, Aug 19, 2020 at 1:51 PM Robin Murphy <robin.murphy@arm.com> wrote:
> >>
> >> Hi Tomasz,
> >>
> >> On 2020-08-19 12:16, Tomasz Figa wrote:
> >>> Hi Christoph,
> >>>
> >>> On Wed, Aug 19, 2020 at 8:56 AM Christoph Hellwig <hch@lst.de> wrote:
> >>>>
> >>>> The V4L2-FLAG-MEMORY-NON-CONSISTENT flag is entirely unused,
> >>>
> >>> Could you explain what makes you think it's unused? It's a feature of
> >>> the UAPI generally supported by the videobuf2 framework and relied on
> >>> by Chromium OS to get any kind of reasonable performance when
> >>> accessing V4L2 buffers in the userspace.
> >>>
> >>>> and causes
> >>>> weird gymanstics with the DMA_ATTR_NON_CONSISTENT flag, which is
> >>>> unimplemented except on PARISC and some MIPS configs, and about to be
> >>>> removed.
> >>>
> >>> It is implemented by the generic DMA mapping layer [1], which is used
> >>> by a number of architectures including ARM64 and supposed to be used
> >>> by new architectures going forward.
> >>
> >> AFAICS all that V4L2_FLAG_MEMORY_NON_CONSISTENT does is end up
> >> controling whether DMA_ATTR_NON_CONSISTENT is added to vb2_queue::dma_attrs.
> >>
> >> Please can you point to where DMA_ATTR_NON_CONSISTENT does anything at
> >> all on arm64?
> >>
> >
> > With the default config it doesn't, but with
> > CONFIG_DMA_NONCOHERENT_CACHE_SYNC enabled it makes dma_pgprot() keep
> > the pgprot value as is, without enforcing coherence attributes.
>
> How active are the PA-RISC and MIPS ports of Chromium OS?

Not active. We enable CONFIG_DMA_NONCOHERENT_CACHE_SYNC for ARM64,
given the directions received back in April when discussing the
noncoherent memory functionality on the mailing list in the thread I
pointed out in my previous message and no clarification on why it is
disabled for ARM64 in upstream, despite making several attempts to get
some.

>
> Hacking CONFIG_DMA_NONCOHERENT_CACHE_SYNC into an architecture that
> doesn't provide dma_cache_sync() is wrong, since at worst it may break
> other drivers. If downstream is wildly misusing an API then so be it,
> but it's hardly a strong basis for an upstream argument.

I guess it means that we're wildly misusing the API, but it still does
work. Could you explain how it could break other drivers?

>
> >> Also, I posit that videobuf2 is not actually relying on
> >> DMA_ATTR_NON_CONSISTENT anyway, since it's clearly not using it properly:
> >>
> >> "By using this API, you are guaranteeing to the platform
> >> that you have all the correct and necessary sync points for this memory
> >> in the driver should it choose to return non-consistent memory."
> >>
> >> $ git grep dma_cache_sync drivers/media
> >> $
> >
> > AFAIK dma_cache_sync() isn't the only way to perform the cache
> > synchronization. The earlier patch series that I reviewed relied on
> > dma_get_sgtable() and then dma_sync_sg_*() (which existed in the
> > vb2-dc since forever [1]). However, it looks like with the final code
> > the sgtable isn't acquired and the synchronization isn't happening, so
> > you have a point.
>
> Using the streaming sync calls on coherent allocations has also always
> been wrong per the API, regardless of the bodies of code that have
> happened to get away with it for so long.
>
> > FWIW, I asked back in time what the plan is for non-coherent
> > allocations and it seemed like DMA_ATTR_NON_CONSISTENT and
> > dma_sync_*() was supposed to be the right thing to go with. [2] The
> > same thread also explains why dma_alloc_pages() isn't suitable for the
> > users of dma_alloc_attrs() and DMA_ATTR_NON_CONSISTENT.
>
> AFAICS even back then Christoph was implying getting rid of
> NON_CONSISTENT and *replacing* it with something streaming-API-based -

That's not how I read his reply from the thread I pointed to, but that
might of course be my misunderstanding.

> i.e. this series - not encouraging mixing the existing APIs. It doesn't
> seem impossible to implement a remapping version of this new
> dma_alloc_pages() for IOMMU-backed ops if it's really warranted
> (although at that point it seems like "non-coherent" vb2-dc starts to
> have significant conceptual overlap with vb2-sg).

No, there is no overlap between vb2-dc and vb2-sg. They differ on
another level - the former is to be used by devices without
scatter-gather or internal mapping capabilities and gives the driver a
single DMA address for the whole buffer, regardless of whether it's
IOVA-contiguous (for devices behind an IOMMU) or physically contiguous
(for the others), while the latter gives the driver an sgtable, which
of course may be DMA-contiguous internally, but doesn't have to and
usually isn't. This model makes it possible to hide the SoC
implementation details from particular drivers, since those are very
often reused on many SoCs which differ in the availability of IOMMU,
DMA addressing restrictions and so on.

Best regards,
Tomasz

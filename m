From: Boaz Harrosh <boaz@plexistor.com>
Date: Wed, 12 Aug 2015 12:42:47 +0000
Subject: Re: RFC: prepare for struct scatterlist entries without page backing
Message-Id: <55CB3F47.3000902@plexistor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvdimm-y27Ovi1pjclAfugRpC6u6w@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, egtvedt-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, hskinnemoen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, grundler-6jwH94ZQLHl74goWV3ctuw@public.gmane.org, realmz6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgupta-HKixBCOQz3hWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

On 08/12/2015 10:05 AM, Christoph Hellwig wrote:
> Dan Williams started to look into addressing I/O to and from
> Persistent Memory in his series from June:
> 
> 	http://thread.gmane.org/gmane.linux.kernel.cross-arch/27944
> 
> I've started looking into DMA mapping of these SGLs specifically instead
> of the map_pfn method in there.  In addition to supporting NVDIMM backed
> I/O I also suspect this would be highly useful for media drivers that
> go through nasty hoops to be able to DMA from/to their ioremapped regions,
> with vb2_dc_get_userptr in drivers/media/v4l2-core/videobuf2-dma-contig.c
> being a prime example for the unsafe hacks currently used.
> 

The support I have suggested and submitted for zone-less sections.
(In my add_persistent_memory() patchset)

Would work perfectly well and transparent for all such multimedia cases.
(All hacks removed). In fact I have loaded pmem (with-pages) on a VRAM
a few times and it is great easy fun. (I wanted to experiment with cached
memory over a pcie)

> It turns out most DMA mapping implementation can handle SGLs without
> page structures with some fairly simple mechanical work.  Most of it
> is just about consistently using sg_phys.  For implementations that
> need to flush caches we need a new helper that skips these cache
> flushes if a entry doesn't have a kernel virtual address.
> 
> However the ccio (parisc) and sba_iommu (parisc & ia64) IOMMUs seem
> to be operate mostly on virtual addresses.  It's a fairly odd concept
> that I don't fully grasp, so I'll need some help with those if we want
> to bring this forward.
> 
> Additional this series skips ARM entirely for now.  The reason is
> that most arm implementations of the .map_sg operation just iterate
> over all entries and call ->map_page for it, which means we'd need
> to convert those to a ->map_pfn similar to Dan's previous approach.
> 

All this endless work for nothing more than uglyfing the Kernel, and
It will never end. When a real and fully working solution is right
here for more then a year.

If you are really up for a deep audit and a mammoth testing effort,
why not do a more worthy, and order of magnitude smaller work and support
2M and 1G variable sized "pages". All the virtual-vs-phisical-vs-caching
just works.

Most of the core work is there. Block layer and lots of other subsytems
already support sending a single page-pointer with bvec_offset bvec_len
bigger then 4K. Other system will be small fixes sprinkled around but
not at all this endless stream of subsystem after another of patches.
And for why.

The novelty of pages is the section object, the section is reached
from page* from virtual as well as physical planes. And is a center
that translate from all plains to all plains. You keep this concept
only make 2M-page sections and 1G-page sections.

It is a bit of work but is worth while, and accelerating tremendously
lots of workloads. Not like this abomination which only branches
things more and more, and making things fatter and slower.

It all feels like a typhoon, the inertia of tones and tons of
men hours work, in a huge wave. How will you ever stop such a
rushing mass. I'm trying to dock under but, surly it makes me sad.

Thanks
Boaz


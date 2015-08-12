From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:19 +0000
Subject: RFC: prepare for struct scatterlist entries without page backing
Message-Id: <1439363150-8661-1-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Dan Williams started to look into addressing I/O to and from
Persistent Memory in his series from June:

	http://thread.gmane.org/gmane.linux.kernel.cross-arch/27944

I've started looking into DMA mapping of these SGLs specifically instead
of the map_pfn method in there.  In addition to supporting NVDIMM backed
I/O I also suspect this would be highly useful for media drivers that
go through nasty hoops to be able to DMA from/to their ioremapped regions,
with vb2_dc_get_userptr in drivers/media/v4l2-core/videobuf2-dma-contig.c
being a prime example for the unsafe hacks currently used.

It turns out most DMA mapping implementation can handle SGLs without
page structures with some fairly simple mechanical work.  Most of it
is just about consistently using sg_phys.  For implementations that
need to flush caches we need a new helper that skips these cache
flushes if a entry doesn't have a kernel virtual address.

However the ccio (parisc) and sba_iommu (parisc & ia64) IOMMUs seem
to be operate mostly on virtual addresses.  It's a fairly odd concept
that I don't fully grasp, so I'll need some help with those if we want
to bring this forward.

Additional this series skips ARM entirely for now.  The reason is
that most arm implementations of the .map_sg operation just iterate
over all entries and call ->map_page for it, which means we'd need
to convert those to a ->map_pfn similar to Dan's previous approach.


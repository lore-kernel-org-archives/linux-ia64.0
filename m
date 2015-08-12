From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 12 Aug 2015 17:00:07 +0000
Subject: Re: RFC: prepare for struct scatterlist entries without page backing
Message-Id: <1439398807.2825.51.camel@HansenPartnership.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: torvalds@linux-foundation.org, axboe@kernel.dk, dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

On Wed, 2015-08-12 at 09:05 +0200, Christoph Hellwig wrote:
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

I can explain that.  I think this doesn't apply to ia64 because it's
cache is PIPT, but on parisc, we have a VIPT cache.

On normal physically indexed architectures, when the iommu sees a DMA
transfer to/from physical memory, it also notifies the CPU to flush the
internal CPU caches of those lines.  This is usually an interlocking
step of the transfer to make sure the page is coherent before transfer
to/from the device (it's why the ia32 for instance is a coherent
architecture).  Because the system is physically indexed, there's no
need to worry about aliases.

On Virtually Indexed systems, like parisc, there is an aliasing problem.
The CCIO iommu unit (and all other iommu systems on parisc) have what's
called a local coherence index (LCI).  You program it as part of the
IOMMU page table and it tells the system which Virtual line in the cache
to flush as part of the IO transaction, thus still ensuring cache
coherence.  That's why we have to know the virtual as well as physical
addresses for the page.  The problem we have in Linux is that we have
two virtual addresses, which are often incoherent aliases: the user
virtual address and a kernel virtual address but we can only make the
page coherent with a single alias (only one LCI).  The way I/O on Linux
currently works is that get_user_pages actually flushes the user virtual
address, so that's expected to be coherent, so the address we program
into the VCI is the kernel virtual address.  Usually nothing in the
kernel has ever touched the page, so there's nothing to flush, but we do
it just in case.

In theory, for these non kernel page backed SG entries, we can make the
process more efficient by not flushing in gup and instead programming
the user virtual address into the local coherence index.  However,
simply zeroing the LCI will also work (except that poor VI zero line
will get flushed repeatedly, so it's probably best to pick a known
untouched line in the kernel).

James



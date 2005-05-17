From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 17 May 2005 23:05:36 +0000
Subject: Re: Queries on IA -64
Message-Id: <200505171705.36081.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050516114921.28015.qmail@web54008.mail.yahoo.com>
In-Reply-To: <20050516114921.28015.qmail@web54008.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 16 May 2005 5:49 am, Mohit Katiyar wrote:
> I am having a ZX MIO chip

I assume you mean an HP box with zx1 chipset.

> First in function paging_init 
> line    max_dma = virt_to_phys((void *)
> MAX_DMA_ADDRESS) >> PAGE_SHIFT;
> max_dma comes out to be 0x7fffffffffff and max low pfn
> = 0x103ffec
> Therefore all the pages move into DMA zone during
> initialization .
> QUESTION Why do we have such a large max_dma value.
> What is the use for that?

As Grant said, ia64 provides the illusion that any device
can DMA directly to any physical memory.  For devices that
can't do 64-bit DMA directly, HP and SGI chipsets have
hardware I/O TLBs that turn a 32-bit PCI bus address into
a 64-bit memory address.  For boxes without a hardware
I/O TLB, there's a software I/O TLB that provides similar
functionality using bounce buffers.

> Question In which case does trim bottom is called and
> in which case trim top will be called??

The identity-mapped kernel segment is mapped with large
pages (typically 16MB or 64MB).  The ia64 architecture
requires that we prevent attribute aliasing, so we can't
have one of those pages that contains both WB and UC
memory.  So trim_top() and trim_bottom() trim the memory
map so we ignore chunks that contain anything other than
WB memory.

> May 13 16:57:01 HORIZON kernel: range > [0x0000000000000000-0x0000000000001000] (0MB)
> 
> QUESTION>>>>>>>>Why does count_dma_pages skips this
> range as seen from start and end values indicated at
> the end of mail

This is removed because it's in the same 16MB granule
as the 0xa0000-0xc0000 VGA frame buffer region, which
is MMIO.  That MMIO region forces us to ignore any
WB memory in the first 16MB.

> May 13 16:57:02 HORIZON kernel: type = MemoryMappedIO 
> May 13 16:57:02 HORIZON kernel: attribute = 0x3 
> May 13 16:57:02 HORIZON kernel: range > [0x00000000000a0000-0x00000000000c0000] (0MB)

> If i compile my kernel with Virtual mem map off and
> NUMA off i my available free ram decreases by about 1
> GB . I am not able to figure it out??

My guess is that without virtual memmap, you just end
up wasting a huge amount of memory on page structures.
The zx1 chipset has huge holes in the physical memory
map, and I think that without virtual memmap, we allocate
page structures even for the holes.

This book is a great place to start for questions like
these:

    http://www.lia64.org/book/

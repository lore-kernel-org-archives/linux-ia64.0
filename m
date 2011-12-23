From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 23 Dec 2011 16:35:16 +0000
Subject: Re: [PATCH 00/14] DMA-mapping framework redesign preparation
Message-Id: <20111223163516.GO20129@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

On Fri, Dec 23, 2011 at 01:27:19PM +0100, Marek Szyprowski wrote:
> The first issue we identified is the fact that on some platform (again,
> mainly ARM) there are several functions for allocating DMA buffers:
> dma_alloc_coherent, dma_alloc_writecombine and dma_alloc_noncoherent

Is this write-combining from the point of view of the device (ie iommu),
or from the point of view of the CPU, or both?

> The next step in dma mapping framework update is the introduction of
> dma_mmap/dma_mmap_attrs() function. There are a number of drivers
> (mainly V4L2 and ALSA) that only exports the DMA buffers to user space.
> Creating a userspace mapping with correct page attributes is not an easy
> task for the driver. Also the DMA-mapping framework is the only place
> where the complete information about the allocated pages is available,
> especially if the implementation uses IOMMU controller to provide a
> contiguous buffer in DMA address space which is scattered in physical
> memory space.

Surely we only need a helper which drivrs can call from their mmap routine to solve this?

> Usually these drivers don't touch the buffer data at all, so the mapping
> in kernel virtual address space is not needed. We can introduce
> DMA_ATTRIB_NO_KERNEL_MAPPING attribute which lets kernel to skip/ignore
> creation of kernel virtual mapping. This way we can save previous
> vmalloc area and simply some mapping operation on a few architectures.

I really think this wants to be a separate function.  dma_alloc_coherent
is for allocating memory to be shared between the kernel and a driver;
we already have dma_map_sg for mapping userspace I/O as an alternative
interface.  This feels like it's something different again rather than
an option to dma_alloc_coherent.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

From: Grant Grundler <iod00d@hp.com>
Date: Mon, 16 May 2005 16:43:25 +0000
Subject: Re: Queries on IA -64
Message-Id: <20050516164325.GC29357@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050516114921.28015.qmail@web54008.mail.yahoo.com>
In-Reply-To: <20050516114921.28015.qmail@web54008.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 16, 2005 at 04:49:20AM -0700, Mohit Katiyar wrote:
> Hi,
> I am first time mailing regarding some booting
> procedure for IA-64 Linux . I am having a ZX MIO chip
> with 6 GB RAM and 16 KB of page size. I have compiled
> the kernel with NUMA off and Virtual mem map on
> 
> First in function paging_init 
> line    max_dma = virt_to_phys((void *)
> MAX_DMA_ADDRESS) >> PAGE_SHIFT;
> max_dma comes out to be 0x7fffffffffff and max low pfn
> = 0x103ffec
> Therefore all the pages move into DMA zone during
> initialization .
> QUESTION Why do we have such a large max_dma value.
> What is the use for that?

Avoid bounce buffers and support IOMMU bypass.
Any device can DMA to any physical address - either
directly or via IOMMU.

grant

From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 31 May 2002 01:00:51 +0000
Subject: Re: [Linux-ia64] Missing files in to-linus-2.5 BK tree; build problems
Message-Id: <marc-linux-ia64-105590701905622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905608@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905608@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Chubb wrote:
> Can you take a look at this and see if you think it's sane?
> I'm only doing this to get a clean compilation

Peter,
certainly.

> --- /tmp/geta3892	Thu May 30 14:53:10 2002
> +++ sba_iommu.c	Thu May 30 14:53:05 2002
> @@ -216,9 +216,10 @@
>  static int reserve_sba_gart = 1;
>  static struct pci_dev sac_only_dev;
>  
> -#define sba_sg_iova(sg) (sg->address)
> +#define sba_sg_iova(sg) (page_address((sg)->page) + (sg)->offset)
>  #define sba_sg_len(sg) (sg->length)
>  #define sba_sg_buffer(sg) (sg->orig_address)
> +#define sba_sg_clear_iova(sg) (sg->page = NULL,sg->offset = 0)

This isn't going to work. Later in the code:
		if ((u64)sba_sg_iova(startsg) & PIDE_FLAG) {
			u32 pide = (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
...


PIDE_FLAG was stuffed into address field in order to "mark" contiguous
DMA chunks. DMA coalescing was done in two passes on PARISC because DMA
coherency required knowing the virtual address each DMA was going to.
Obviously not true for ia64.

Maybe a single pass coalescing algorithm would obsolete
PIDE_FLAG (and the problem).
For HP ZX1, I'm really not happy with this algorithm.

Short term: Maybe use ->offset to stuff the PIDE_FLAG?

> @@ -1037,10 +1038,12 @@
>  		*/
>  		if ((u64)sba_sg_iova(startsg) & PIDE_FLAG) {
>  			u32 pide = (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
> +			char *vaddr;
>  			dma_offset = (unsigned long) pide & ~IOVP_MASK;
> -			sba_sg_iova(startsg) = 0;
>  			dma_sg++;
> -			sba_sg_iova(dma_sg) = (char *)(pide | ioc->ibase);
> +			vaddr = (char *)(pide | ioc->ibase);
> +			dma_sg->page = virt_to_page(vaddr);
> +			dma_sg->offset = (u64)vaddr * ~PAGE_MASK;
>  			pdirp = &(ioc->pdir_base[pide >> IOVP_SHIFT]);
>  			n_mappings++;
>  		}

This is where we "end" one DMA chunk and start the next.
Maybe "dma_sg->offset = dma_offset" instead of extracting offset again.


> @@ -1162,7 +1166,7 @@
>  				vcontig_end += sba_sg_len(startsg);
>  				dma_len     += sba_sg_len(startsg);
>  				sba_sg_buffer(startsg) = (char *)vaddr;
> -				sba_sg_iova(startsg) = 0;
> +				sba_sg_clear_iova(startsg);
>  				sba_sg_len(startsg) = 0;
>  				continue;
>  			}

GAH!
Anything related to vcontig_end should have been deleted.
It's an artifact from the parisc-linux port.

This really bugs me. I'll make some time in the next couple
of weeks to rewrite and test it, maybe sooner rather than later.
Note that my rewrite will be on 2.4 since that's what I can test.
I'll pickup the casts that were added in this patch.

Given the context, the rest of the changes look right.

thanks,
grant


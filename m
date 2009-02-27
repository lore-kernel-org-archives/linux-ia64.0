From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 27 Feb 2009 19:21:17 +0000
Subject: Re: [PATCH 1/1] Fix PCI DMA flag propagation on SN (Altix) with PICs
Message-Id: <20090227192116.GO16891@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090227093835.GA306198@sgi.com>
In-Reply-To: <20090227093835.GA306198@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeremy Higdon <jeremy@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, jesse.barnes@intel.com, habeck@sgi.com, linux-ia64@vger.kernel.org

On Fri, Feb 27, 2009 at 01:38:35AM -0800, Jeremy Higdon wrote:
> We recently discovered a problem with passing of DMA attributes on
> SN systems with the older PIC chips.

I think this should go in through the ia64 tree, not the PCI tree ...

> Signed-off-by: Jeremy Higdon <jeremy@sgi.com>
> 
> --- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2009-02-25 23:29:21.000000000 -0800
> +++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2009-02-25 23:29:09.318611870 -0800
> @@ -135,11 +135,10 @@ pcibr_dmatrans_direct64(struct pcidev_in
>  	if (SN_DMA_ADDRTYPE(dma_flags) = SN_DMA_ADDR_PHYS)
>  		pci_addr = IS_PIC_SOFT(pcibus_info) ?
>  				PHYS_TO_DMA(paddr) :
> -		    		PHYS_TO_TIODMA(paddr) | dma_attributes;
> +		    		PHYS_TO_TIODMA(paddr);
>  	else
> -		pci_addr = IS_PIC_SOFT(pcibus_info) ?
> -				paddr :
> -				paddr | dma_attributes;
> +		pci_addr = paddr;
> +	pci_addr |= dma_attributes;
>  
>  	/* Handle Bus mode */
>  	if (IS_PCIX(pcibus_info))
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

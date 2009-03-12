From: Jesse Barnes <jbarnes@virtuousgeek.org>
Date: Thu, 12 Mar 2009 17:15:47 +0000
Subject: Re: [patch for 2.6.29? 1/1] ia64: fix PCI DMA flag propagation on SN (Altix) with PICs
Message-Id: <200903121015.48578.jbarnes@virtuousgeek.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200903042009.n24K9kpC029740@imap1.linux-foundation.org>
In-Reply-To: <200903042009.n24K9kpC029740@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, March 4, 2009 12:09:46 pm akpm@linux-foundation.org wrote:
> From: Jeremy Higdon <jeremy@sgi.com>
>
> We recently discovered a problem with passing of DMA attributes on SN
> systems with the older PIC chips.
>
> [akpm@linux-foundation.org: coding-style fixes]
> Signed-off-by: Jeremy Higdon <jeremy@sgi.com>
> Cc: <habeck@sgi.com>
> Cc: "Luck, Tony" <tony.luck@intel.com>
> Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  arch/ia64/sn/pci/pcibr/pcibr_dma.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff -puN
> arch/ia64/sn/pci/pcibr/pcibr_dma.c~ia64-fix-pci-dma-flag-propagation-on-sn-
>altix-with-pics arch/ia64/sn/pci/pcibr/pcibr_dma.c ---
> a/arch/ia64/sn/pci/pcibr/pcibr_dma.c~ia64-fix-pci-dma-flag-propagation-on-s
>n-altix-with-pics +++ a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
> @@ -135,11 +135,10 @@ pcibr_dmatrans_direct64(struct pcidev_in
>  	if (SN_DMA_ADDRTYPE(dma_flags) = SN_DMA_ADDR_PHYS)
>  		pci_addr = IS_PIC_SOFT(pcibus_info) ?
>  				PHYS_TO_DMA(paddr) :
> -		    		PHYS_TO_TIODMA(paddr) | dma_attributes;
> +				PHYS_TO_TIODMA(paddr);
>  	else
> -		pci_addr = IS_PIC_SOFT(pcibus_info) ?
> -				paddr :
> -				paddr | dma_attributes;
> +		pci_addr = paddr;
> +	pci_addr |= dma_attributes;
>
>  	/* Handle Bus mode */
>  	if (IS_PCIX(pcibus_info))
> _

Tony, want to pick this up?

Acked-by: Jesse Barnes <jbarnes@virtuousgeek.org>

Thanks,
-- 
Jesse Barnes, Intel Open Source Technology Center

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 30 Jul 2003 22:52:00 +0000
Subject: Re: [PATCH] PCI domain support for 2.4
Message-Id: <marc-linux-ia64-105960572506775@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 25 June 2003 3:06 pm, Matthew Wilcox wrote:
> 
> 2.4 can support PCI domains with non-overlapping bus numbers.  While this
> isn't terribly useful, it may help some machine designs.  This is the
> minimum patch to support this for 2.4 -- a more invasive patch would
> replace PCI_SEGMENT with pci_controller_num throughout the ia64 code.
> 
> === include/asm-ia64/pci.h 1.12 vs edited ==> --- 1.12/include/asm-ia64/pci.h	Thu Mar  6 09:43:37 2003
> +++ edited/include/asm-ia64/pci.h	Fri Jun 20 09:41:13 2003
> @@ -82,8 +82,8 @@
>  #define pci_dac_dma_to_offset(dev,dma_addr)	((dma_addr) & ~PAGE_MASK)
>  #define pci_dac_dma_sync_single(dev,dma_addr,len,dir)	do { /* nothing */ } while (0)
>  
> -/* Return the index of the PCI controller for device PDEV. */
> -#define pci_controller_num(PDEV)	(0)
> +/* Return the PCI domain number */
> +#define pci_controller_num(pdev)	(PCI_SEGMENT(pdev))
>  
>  #define sg_dma_address(sg)	((sg)->dma_address)
>  #define sg_dma_len(sg)		((sg)->dma_length)

I applied this for 2.4.  Thanks!

Bjorn


From: Jesper Nilsson <jesper.nilsson@axis.com>
Date: Tue, 07 Jun 2016 08:04:30 +0000
Subject: Re: [PATCH v12 01/15] PCI: Let pci_mmap_page_range() take extra resource pointer
Message-Id: <20160607080430.GI3183@axis.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160604000642.28162-1-yinghai@kernel.org>
 <20160604000642.28162-2-yinghai@kernel.org>
In-Reply-To: <20160604000642.28162-2-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Fri, Jun 03, 2016 at 05:06:28PM -0700, Yinghai Lu wrote:
> This one is preparing patch for next one:
>   PCI: Let pci_mmap_page_range() take resource addr
> 
> We need to pass extra resource pointer to avoid searching that again
> for powerpc and microblaze prot set operation.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: linux-arm-kernel@lists.infradead.org

For the CRIS part:

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> diff --git a/arch/cris/arch-v32/drivers/pci/bios.c b/arch/cris/arch-v32/drivers/pci/bios.c
> index 64a5fb9..082efb9 100644
> --- a/arch/cris/arch-v32/drivers/pci/bios.c
> +++ b/arch/cris/arch-v32/drivers/pci/bios.c
> @@ -14,7 +14,8 @@ void pcibios_set_master(struct pci_dev *dev)
>  	pci_write_config_byte(dev, PCI_LATENCY_TIMER, lat);
>  }
>  
> -int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
> +int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
> +			struct vm_area_struct *vma,
>  			enum pci_mmap_state mmap_state, int write_combine)
>  {
>  	unsigned long prot;
> diff --git a/arch/cris/include/asm/pci.h b/arch/cris/include/asm/pci.h
> index b1b289d..65198cb 100644
> --- a/arch/cris/include/asm/pci.h
> +++ b/arch/cris/include/asm/pci.h
> @@ -42,9 +42,6 @@ struct pci_dev;
>  #define PCI_DMA_BUS_IS_PHYS	(1)
>  
>  #define HAVE_PCI_MMAP
> -extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
> -			       enum pci_mmap_state mmap_state, int write_combine);
> -
>  
>  #endif /* __KERNEL__ */

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

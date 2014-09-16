From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Date: Tue, 16 Sep 2014 11:35:53 +0000
Subject: Re: [PATCH v1 16/21] s390/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <alpine.LFD.2.11.1409161325280.1618@denkbrett>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com> <1409911806-10519-17-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1409911806-10519-17-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>

Hello,

On Fri, 5 Sep 2014, Yijing Wang wrote:
> Use MSI chip framework instead of arch MSI functions to configure
> MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  arch/s390/pci/pci.c |   18 ++++++++++++++----
>  1 files changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
> index 2fa7b14..da5316e 100644
> --- a/arch/s390/pci/pci.c
> +++ b/arch/s390/pci/pci.c
> @@ -358,7 +358,7 @@ static void zpci_irq_handler(struct airq_struct *airq)
>  	}
>  }
> 
> -int arch_setup_msi_irqs(struct pci_dev *pdev, int nvec, int type)
> +int zpci_setup_msi_irqs(struct pci_dev *pdev, int nvec, int type)
>  {
>  	struct zpci_dev *zdev = get_zdev(pdev);
>  	unsigned int hwirq, msi_vecs;
> @@ -434,7 +434,7 @@ out:
>  	return rc;
>  }
> 
> -void arch_teardown_msi_irqs(struct pci_dev *pdev)
> +static void zpci_teardown_msi_irqs(struct pci_dev *pdev)
>  {
>  	struct zpci_dev *zdev = get_zdev(pdev);
>  	struct msi_desc *msi;
> @@ -448,9 +448,9 @@ void arch_teardown_msi_irqs(struct pci_dev *pdev)
>  	/* Release MSI interrupts */
>  	list_for_each_entry(msi, &pdev->msi_list, list) {
>  		if (msi->msi_attrib.is_msix)
> -			default_msix_mask_irq(msi, 1);
> +			__msix_mask_irq(msi, 1);
>  		else
> -			default_msi_mask_irq(msi, 1, 1);
> +			__msi_mask_irq(msi, 1, 1);

The default_msi_mask_irq to __msi_mask_irq renaming is hidden in your
patch "x86/xen/MSI: Eliminate arch_msix_mask_irq() and arch_msi_mask_irq()"

This means that between that patch and this one s390 will not compile.
Could you please move this hunk to the other patch or even make an extra
patch with the renaming. Other than that:

Acked-by: Sebastian Ott <sebott@linux.vnet.ibm.com>

Regards,
Sebastian

>  		irq_set_msi_desc(msi->irq, NULL);
>  		irq_free_desc(msi->irq);
>  		msi->msg.address_lo = 0;
> @@ -464,6 +464,16 @@ void arch_teardown_msi_irqs(struct pci_dev *pdev)
>  	airq_iv_free_bit(zpci_aisb_iv, zdev->aisb);
>  }
> 
> +static struct msi_chip zpci_msi_chip = {
> +	.setup_irqs = zpci_setup_msi_irqs,
> +	.teardown_irqs = zpci_teardown_msi_irqs,
> +};
> +
> +struct msi_chip *arch_find_msi_chip(struct pci_dev *dev)
> +{
> +	return &zpci_msi_chip;
> +}
> +
>  static void zpci_map_resources(struct zpci_dev *zdev)
>  {
>  	struct pci_dev *pdev = zdev->pdev;
> -- 
> 1.7.1
> 
> 


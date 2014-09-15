From: Lucas Stach <l.stach@pengutronix.de>
Date: Mon, 15 Sep 2014 14:42:34 +0000
Subject: Re: [PATCH v1 05/21] PCI/MSI: Introduce weak arch_find_msi_chip() to find MSI chip
Message-Id: <1410792154.3314.7.camel@pengutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com>
	 <1409911806-10519-6-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1409911806-10519-6-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

Am Freitag, den 05.09.2014, 18:09 +0800 schrieb Yijing Wang:
> Introduce weak arch_find_msi_chip() to find the match msi_chip.
> Currently, MSI chip associates pci bus to msi_chip. Because in
> ARM platform, there may be more than one MSI controller in system.
> Associate pci bus to msi_chip help pci device to find the match
> msi_chip and setup MSI/MSI-X irq correctly. But in other platform,
> like in x86. we only need one MSI chip, because all device use
> the same MSI address/data and irq etc. So it's no need to associate
> pci bus to MSI chip, just use a arch function, arch_find_msi_chip()
> to return the MSI chip for simplicity. The default weak
> arch_find_msi_chip() used in ARM platform, find the MSI chip
> by pci bus.
> 
Hm, while one weak function sounds much better than the plethora we have
now, I wonder how much work it would be to associate the msi_chip with
the pci bus on other arches the same way as done on ARM. This way we
could kill this calling into arch specific functions which would make
things a bit clearer to follow I think.

Regards,
Lucas

> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/msi.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index a77e7f7..539c11d 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -29,9 +29,14 @@ static int pci_msi_enable = 1;
>  
>  /* Arch hooks */
>  
> +struct msi_chip * __weak arch_find_msi_chip(struct pci_dev *dev)
> +{
> +	return dev->bus->msi;
> +}
> +
>  int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
>  {
> -	struct msi_chip *chip = dev->bus->msi;
> +	struct msi_chip *chip = arch_find_msi_chip(dev);
>  	int err;
>  
>  	if (!chip || !chip->setup_irq)

-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |


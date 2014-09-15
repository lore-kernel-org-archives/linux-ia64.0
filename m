From: Lucas Stach <l.stach@pengutronix.de>
Date: Mon, 15 Sep 2014 14:00:48 +0000
Subject: Re: [PATCH v1 03/21] MSI: Remove the redundant irq_set_chip_data()
Message-Id: <1410789648.3314.5.camel@pengutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com>
	 <1409911806-10519-4-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1409911806-10519-4-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

Am Freitag, den 05.09.2014, 18:09 +0800 schrieb Yijing Wang:
> Currently, pcie-designware, pcie-rcar, pci-tegra drivers
> use irq chip_data to save the msi_chip pointer. They
> already call irq_set_chip_data() in their own MSI irq map
> functions. So irq_set_chip_data() in arch_setup_msi_irq()
> is useless.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/msi.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index f6cb317..d547f7f 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -41,8 +41,6 @@ int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
>  	if (err < 0)
>  		return err;
>  
> -	irq_set_chip_data(desc->irq, chip);
> -
>  	return 0;
>  }
>  

arch_teardown_msi_irq() expects to find the msi_chip in the irq
chip_data field. As this means drivers don't have any reasonable other
possibility to stuff things into this field, I think it would make sense
to do the cleanup the other way around: keep the irq_set_chip_data
arch_setup_msi_irq() and rip it out of the individual drivers.

Regards,
Lucas

-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |


From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 25 Mar 2015 08:55:02 +0000
Subject: Re: [PATCH v8 23/30] PCI/mvebu: Use pci_common_init_dev() to simplify code
Message-Id: <551277E6.1010307@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com> <1427168064-8657-24-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427168064-8657-24-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Jason Cooper <jason@lakedaemon.net>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

Hi Thomas and Jason,
   Do you have any comment for this patch ? In this series, pci_bus_add_devices()
has been ripped out from pci_scan_root_bus(), so I think the pci_scan_root_bus() is
almost the same as pci_create_root_bus + pci_scan_child_bus(). And in this series,
we try to unexport pci_create_root_bus(). It's even better if you could help test this changes.

Thanks!
Yijing.

On 2015/3/24 11:34, Yijing Wang wrote:
> Mvebu_pcie_scan_bus() is not necessary, we could use
> pci_common_init_dev() instead of pci_common_init(),
> and pass the device pointer as the parent. Then
> pci_scan_root_bus() will be called to scan the pci busses.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> CC: Jason Cooper <jason@lakedaemon.net>
> ---
>  drivers/pci/host/pci-mvebu.c |   18 +-----------------
>  1 files changed, 1 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/pci/host/pci-mvebu.c b/drivers/pci/host/pci-mvebu.c
> index 0cfc494..d5a2b70 100644
> --- a/drivers/pci/host/pci-mvebu.c
> +++ b/drivers/pci/host/pci-mvebu.c
> @@ -750,21 +750,6 @@ static int mvebu_pcie_setup(int nr, struct pci_sys_data *sys)
>  	return 1;
>  }
>  
> -static struct pci_bus *mvebu_pcie_scan_bus(int nr, struct pci_sys_data *sys)
> -{
> -	struct mvebu_pcie *pcie = sys_to_pcie(sys);
> -	struct pci_bus *bus;
> -
> -	bus = pci_create_root_bus(&pcie->pdev->dev, -1, sys->busnr,
> -				  &mvebu_pcie_ops, sys, &sys->resources);
> -	if (!bus)
> -		return NULL;
> -
> -	pci_scan_child_bus(bus);
> -
> -	return bus;
> -}
> -
>  static resource_size_t mvebu_pcie_align_resource(struct pci_dev *dev,
>  						 const struct resource *res,
>  						 resource_size_t start,
> @@ -808,12 +793,11 @@ static void mvebu_pcie_enable(struct mvebu_pcie *pcie)
>  	hw.nr_controllers = 1;
>  	hw.private_data   = (void **)&pcie;
>  	hw.setup          = mvebu_pcie_setup;
> -	hw.scan           = mvebu_pcie_scan_bus;
>  	hw.map_irq        = of_irq_parse_and_map_pci;
>  	hw.ops            = &mvebu_pcie_ops;
>  	hw.align_resource = mvebu_pcie_align_resource;
>  
> -	pci_common_init(&hw);
> +	pci_common_init_dev(&pcie->pdev->dev, &hw);
>  }
>  
>  /*
> 


-- 
Thanks!
Yijing


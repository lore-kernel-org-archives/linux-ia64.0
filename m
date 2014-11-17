From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Date: Mon, 17 Nov 2014 15:03:38 +0000
Subject: Re: [RFC PATCH 09/16] PCI: Associate .get_msi_ctrl() with pci_host_bridge
Message-Id: <20141117150338.GA22515@e102568-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
 <1416219710-26088-10-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-10-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "huxinwei@huawei.com" <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, Yijing Wang <wangyijing0307@gmail.com>, "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Nov 17, 2014 at 10:21:43AM +0000, Yijing Wang wrote:
> From: Yijing Wang <wangyijing0307@gmail.com>
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/host-bridge.c |    1 +
>  include/linux/pci.h       |    2 ++
>  2 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index 49b6c21..872cae1 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -58,6 +58,7 @@ struct pci_host_bridge *pci_create_host_bridge(
>  	host->dev.parent = parent;
>  	INIT_LIST_HEAD(&host->windows);
>  	host->dev.release = pci_release_host_bridge_dev;
> +	host->get_msi_ctrl = info->get_msi_ctrl;
>  
>  	/* this is hack, just for build, will be removed later*/
>  	b = kzalloc(sizeof(*b), GFP_KERNEL);
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index a51f5f5..af1ee86 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -408,6 +408,7 @@ struct pci_host_bridge {
>  	int domain;
>  	void *sysdata;
>  	struct pci_ops *ops;
> +	struct msi_controller *(*get_msi_ctrl)(struct pci_dev *pdev);
>  	void (*release_fn)(struct pci_host_bridge *);
>  	void *release_data;
>  };
> @@ -416,6 +417,7 @@ struct pci_host_info {
>  	u8 res_type;
>  	void *arg;
>  	struct list_head *resources; /*just for build, will clean up later */
> +	struct msi_controller *(*get_msi_ctrl)(struct pci_dev *pdev);
>  	int (*init_res)(struct pci_host_bridge *host, 
>  			struct pci_host_info *info);
>  };

Where would you use the get_msi_ctrl pointer then ? Wasn't it better
to wait for this patchset to take shape before adding more churn to
the ARM (and other archs) pci_sys_data structure and consequently add
another pcibios call to achieve what the get_msi_ctrl pointer is there to
achieve (ie making msi_controller retrieval arch independent ?)

I just do not see what the pci_sys_data intermediate step buys you if
we consider the approach taken in this patch as the proper solution.

Thanks,
Lorenzo


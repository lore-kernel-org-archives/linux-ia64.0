From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 03 Mar 2015 02:50:20 +0000
Subject: Re: [PATCH v4 12/30] PCI: Introduce pci_host_bridge_ops to support host specific operations
Message-Id: <20150303025020.GF11978@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
 <1424938344-4017-13-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424938344-4017-13-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Thu, Feb 26, 2015 at 04:12:06PM +0800, Yijing Wang wrote:
> Now we have weak functions like pcibios_root_bridge_prepare()
> to setup pci host bridge, We could introduce pci_host_bridge_ops
> which contain host bridge specific ops to setup pci_host_bridge.
> Then host bridge driver could add pci_host_bridge_ops hooks
> intead of weak function to setup pci_host_bridge.
> This patch add following pci_host_bridge_ops hooks:
> 
> pci_host_bridge_ops {
> 	/* set root bus speed, some platform need this like powerpc */
> 	void (*phb_set_root_bus_speed)(struct pci_host_bridge *host);
> 	/* setup pci_host_bridge before pci_host_bridge be added to driver core */
> 	int (*phb_prepare)(struct pci_host_bridge *host);
> 	/* platform specific of scan hook to scan pci device */
> 	void (*phb_of_scan_bus)(struct pci_host_bridge *);
> }
> We could easily extend it to support different host bridge
> specific operations.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/host-bridge.c |   12 ++++++++++--
>  drivers/pci/probe.c       |   17 +++++++++++------
>  include/linux/pci.h       |   12 ++++++++++--
>  3 files changed, 31 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index b42a4bb..4a2baa2 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -23,8 +23,8 @@ static void pci_release_host_bridge_dev(struct device *dev)
>  }
>  
>  struct pci_host_bridge *pci_create_host_bridge(
> -		struct device *parent, u32 db, 
> -		struct list_head *resources, void *sysdata)
> +		struct device *parent, u32 db, struct list_head *resources, 
> +		void *sysdata, struct pci_host_bridge_ops *ops)
>  {
>  	int error;
>  	int bus = PCI_BUSNUM(db);
> @@ -56,6 +56,7 @@ struct pci_host_bridge *pci_create_host_bridge(
>  		}
>  	mutex_unlock(&phb_mutex);
>  
> +	host->ops = ops;
>  	host->dev.parent = parent;
>  	INIT_LIST_HEAD(&host->windows);
>  	host->dev.release = pci_release_host_bridge_dev;
> @@ -63,6 +64,13 @@ struct pci_host_bridge *pci_create_host_bridge(
>  	dev_set_name(&host->dev, "pci%04x:%02x", host->domain, 
>  			host->busnum);
>  
> +	if (host->ops && host->ops->phb_prepare) {
> +		error = host->ops->phb_prepare(host);
> +		if(error) {

Whitespace error.

> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -400,6 +400,13 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
>  	return (pdev->error_state != pci_channel_io_normal);
>  }
>  
> +struct pci_host_bridge;
> +struct pci_host_bridge_ops {
> +	void (*phb_set_root_bus_speed)(struct pci_host_bridge *host);
> +	int (*phb_prepare)(struct pci_host_bridge *host);
> +	void (*phb_of_scan_bus)(struct pci_host_bridge *);

These function pointers don't need a "phb_" prefix.

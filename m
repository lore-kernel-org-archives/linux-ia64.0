From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 12 Mar 2015 03:23:41 +0000
Subject: Re: [PATCH v6 12/30] PCI: Introduce pci_host_bridge_ops to support host specific operations
Message-Id: <20150312032341.GE10949@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <1425868467-9667-13-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425868467-9667-13-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Mon, Mar 09, 2015 at 10:34:09AM +0800, Yijing Wang wrote:
> Now we have weak functions like pcibios_root_bridge_prepare()
> to setup pci host bridge, We could introduce pci_host_bridge_ops
> which contain host bridge specific ops to setup pci_host_bridge.
> Then host bridge driver could add pci_host_bridge_ops hooks
> intead of weak function to setup pci_host_bridge.
> This patch add following pci_host_bridge_ops hooks:
> 
> pci_host_bridge_ops {
> 	/* set root bus speed, some platform need this like powerpc */
> 	void (*set_root_bus_speed)(struct pci_host_bridge *host);
> 	/* setup pci_host_bridge before pci_host_bridge be added to driver core */
> 	int (*prepare)(struct pci_host_bridge *host);
> 	/* platform specific of scan hook to scan pci device */
> 	void (*scan_bus)(struct pci_host_bridge *);
> }
> We could easily extend it to support different host bridge
> specific operations.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  drivers/pci/host-bridge.c |   12 ++++++++++--
>  drivers/pci/pci.h         |    4 ++--
>  drivers/pci/probe.c       |   17 +++++++++++------
>  include/linux/pci.h       |    8 ++++++++
>  4 files changed, 31 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index 3c34c49..bc1de59 100644
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
> +	if (host->ops && host->ops->prepare) {
> +		error = host->ops->prepare(host);
> +		if (error) {
> +			kfree(host);
> +			return NULL;
> +		}
> +	}
>  	error = device_register(&host->dev);
>  	if (error) {
>  		put_device(&host->dev);
> diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
> index 79a8894..a1dc9f2 100644
> --- a/drivers/pci/pci.h
> +++ b/drivers/pci/pci.h
> @@ -324,8 +324,8 @@ static inline int pci_dev_specific_reset(struct pci_dev *dev, int probe)
>  #endif
>  
>  struct pci_host_bridge *pci_create_host_bridge(
> -		struct device *parent, u32 dombus,
> -		struct list_head *resources, void *sysdata);
> +		struct device *parent, u32 dombus, struct list_head *resources,
> +		void *sysdata, struct pci_host_bridge_ops *ops);
>  
>  void pci_free_host_bridge(struct pci_host_bridge *host);
>  #endif /* DRIVERS_PCI_H */
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index c8e074d..59d9be3 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -1889,6 +1889,8 @@ static struct pci_bus *__pci_create_root_bus(
>  
>  	bridge->bus = b;
>  	b->bridge = get_device(&bridge->dev);
> +	if (bridge->ops && bridge->ops->set_root_bus_speed)
> +		bridge->ops->set_root_bus_speed(bridge);

Before this patch, can you do this:

  - Rename the powerpc pcibios_root_bridge_prepare() to
    pcibios_set_root_bus_speed() and add a call to it here

  - Move the pcibios_root_bridge_prepare() call to pci_create_host_bridge()

Then this patch will make a lot more sense because it will look like this,
with the host bridge ops call right next to the matching pcibios call:

  +	if (host->ops && host->ops->prepare) {
  +		error = host->ops->prepare(host);
  +		...
  +	}
	pcibios_root_bridge_prepare(...);

  +	if (bridge->ops && bridge->ops->set_root_bus_speed)
  +		bridge->ops->set_root_bus_speed(bridge);
	pcibios_set_root_bus_speed(...);

>  	error = pcibios_root_bridge_prepare(bridge);
>  	if (error)
>  		goto err_out;
> @@ -1954,7 +1956,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
>  {
>  	struct pci_host_bridge *host;
>  
> -	host = pci_create_host_bridge(parent, db, resources, sysdata);
> +	host = pci_create_host_bridge(parent, db, resources, sysdata, NULL);
>  	if (!host)
>  		return NULL;
>  
> @@ -2051,10 +2053,13 @@ static struct pci_bus *__pci_scan_root_bus(
>  		pci_bus_insert_busn_res(b, b->number, 255);
>  	}
>  
> -	max = pci_scan_child_bus(b);
> -
> -	if (!found)
> -		pci_bus_update_busn_res_end(b, max);
> +	if (host->ops && host->ops->scan_bus) {
> +		host->ops->scan_bus(host);
> +	} else {
> +		max = pci_scan_child_bus(b);
> +		if (!found)
> +			pci_bus_update_busn_res_end(b, max);
> +	}

I think host->ops->scan_bus() should have the same prototype as
pci_scan_child_bus(), and it should return max, and you should do the same
busn update as when you call pci_scan_child_bus().  So the code would look
like this:

    if (host->ops && host->ops->scan_bus)
	max = host->ops->scan_bus(b);
    else
	max = pci_scan_child_bus(b);

    if (!found)
	pci_bus_update_busn_res_end(b, max);

>  
>  	return b;
>  }
> @@ -2064,7 +2069,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
>  {
>  	struct pci_host_bridge *host;
>  
> -	host = pci_create_host_bridge(parent, db, resources, sysdata);
> +	host = pci_create_host_bridge(parent, db, resources, sysdata, NULL);
>  	if (!host)
>  		return NULL;
>  
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index b621f5b..e9922b1 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -400,6 +400,13 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
>  	return (pdev->error_state != pci_channel_io_normal);
>  }
>  
> +struct pci_host_bridge;
> +struct pci_host_bridge_ops {
> +	void (*set_root_bus_speed)(struct pci_host_bridge *host);
> +	int (*prepare)(struct pci_host_bridge *host);
> +	void (*scan_bus)(struct pci_host_bridge *);

Needs an argument name to match the style of the other ops.

> +};
> +
>  struct pci_host_bridge {
>  	u16	domain;
>  	u16 busnum;
> @@ -407,6 +414,7 @@ struct pci_host_bridge {
>  	struct pci_bus *bus;		/* root bus */
>  	struct list_head windows;	/* resource_entry */
>  	struct list_head list;
> +	struct pci_host_bridge_ops *ops;
>  	void (*release_fn)(struct pci_host_bridge *);
>  	void *release_data;
>  };
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

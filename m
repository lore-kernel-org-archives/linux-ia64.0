From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 03 Mar 2015 02:37:50 +0000
Subject: Re: [PATCH v4 09/30] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <20150303023750.GE11978@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
 <1424938344-4017-10-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424938344-4017-10-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Thu, Feb 26, 2015 at 04:12:03PM +0800, Yijing Wang wrote:
> This patch separate pci_host_bridge creation out
> of pci_create_root_bus(), and try to make a generic
> pci_host_bridge, then we could place generic PCI
> infos like domain number in it. Also Ripping out
> pci_host_bridge creation from pci_create_root_bus()
> make code more better readability. Further more,
> we could use the generic pci_host_bridge to hold
> host bridge specific operations like
> pcibios_root_bridge_prepare(). The changes are
> transparent to platform host bridge drivers.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/host-bridge.c |   56 ++++++++++++++++++++++
>  drivers/pci/probe.c       |  114 ++++++++++++++++++++-------------------------
>  include/linux/pci.h       |    5 ++-
>  3 files changed, 110 insertions(+), 65 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index 39b2dbe..f304f26 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -8,6 +8,62 @@
>  
>  #include "pci.h"
>  
> +static void pci_release_host_bridge_dev(struct device *dev)
> +{
> +	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
> +
> +	if (bridge->release_fn)
> +		bridge->release_fn(bridge);
> +
> +	pci_free_resource_list(&bridge->windows);
> +	kfree(bridge);
> +}
> +
> +struct pci_host_bridge *pci_create_host_bridge(
> +		struct device *parent, u32 db, struct list_head *resources)
> +{
> +	int error;
> +	int bus = PCI_BUSNUM(db);
> +	int domain = PCI_DOMAIN(db);
> +	struct pci_host_bridge *host;
> +	struct resource_entry *window, *n;
> +
> +	host = kzalloc(sizeof(*host), GFP_KERNEL);
> +	if (!host)
> +		return NULL;
> +
> +	host->busnum = bus;
> +	host->domain = domain;
> +	/* If support CONFIG_PCI_DOMAINS_GENERIC, use
> +	 * pci_host_assign_domain_nr() to assign domain
> +	 * number instead PCI_DOMAIN(db).
> +	 */
> +	pci_host_assign_domain_nr(host);
> +
> +	host->dev.parent = parent;
> +	INIT_LIST_HEAD(&host->windows);
> +	host->dev.release = pci_release_host_bridge_dev;
> +	dev_set_name(&host->dev, "pci%04x:%02x", host->domain, 
> +			host->busnum);
> +
> +	error = device_register(&host->dev);
> +	if (error) {
> +		put_device(&host->dev);
> +		return NULL;
> +	}
> +
> +	resource_list_for_each_entry_safe(window, n, resources)
> +		list_move_tail(&window->node, &host->windows);
> +
> +	return host;
> +}
> +EXPORT_SYMBOL(pci_create_host_bridge);

Why does this need to be exported?  I don't want code outside drivers/pci
using something like this.

> +void pci_free_host_bridge(struct pci_host_bridge *host)
> +{
> +	device_unregister(&host->dev);
> +}
> +
>  static struct pci_bus *find_pci_root_bus(struct pci_bus *bus)
>  {
>  	while (bus->parent)
> ...

> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index efd9917..13b6b25 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -402,6 +402,7 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
>  
>  struct pci_host_bridge {
>  	u16	domain;
> +	u16 busnum;
>  	struct device dev;
>  	struct pci_bus *bus;		/* root bus */
>  	struct list_head windows;	/* resource_entry */
> @@ -415,7 +416,8 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
>  		     void *release_data);
>  
>  int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge);
> -
> +struct pci_host_bridge *pci_create_host_bridge(
> +		struct device *parent, u32 dombus, struct list_head *resources);

Can these function declarations go in drivers/pci/pci.h instead?  I'd
rather not expose them to the rest of the kernel unless we have to.

>  /*
>   * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
>   * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
> @@ -774,6 +776,7 @@ struct pci_bus *pci_scan_bus_legacy(u32 dombus, struct pci_ops *ops, void *sysda
>  struct pci_bus *pci_create_root_bus(struct device *parent, u32 dombus,
>  				    struct pci_ops *ops, void *sysdata,
>  				    struct list_head *resources);
> +void pci_free_host_bridge(struct pci_host_bridge *host);
>  int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
>  int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
>  void pci_bus_release_busn_res(struct pci_bus *b);
> -- 
> 1.7.1
> 

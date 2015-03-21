From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Date: Sat, 21 Mar 2015 23:21:55 +0000
Subject: Re: [PATCH v6 09/30] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <550DFD13.9080505@amd.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <1425868467-9667-10-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425868467-9667-10-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>



On 3/8/15 21:34, Yijing Wang wrote:
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
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>   drivers/pci/host-bridge.c |   55 ++++++++++++++++++++++
>   drivers/pci/pci.h         |    3 +
>   drivers/pci/probe.c       |  114 ++++++++++++++++++++-------------------------
>   include/linux/pci.h       |    1 +
>   4 files changed, 109 insertions(+), 64 deletions(-)
>
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index 39b2dbe..3bd45e7 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -8,6 +8,61 @@
>
>   #include "pci.h"
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

At this point, host->dev.parent has not been assigned. However, when 
calling pci_host_assign_domain_nr(host), it calls 
pci_assign_domain_nr(host->dev.parent), which uses parent->of_node 
directly w/o checking if parent is NULL. This ended up causing NULL 
pointer exception when I do the test.

I think we need to moveo host->dev.parent = parent before calling 
pci_host_assign_domain_nr(host).

Thanks,

Suravee

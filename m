From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 07 Apr 2015 21:38:39 +0000
Subject: Re: [PATCH v9 06/30] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <20150407213839.GJ10892@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
 <1428053164-28277-8-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-8-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Fri, Apr 03, 2015 at 05:25:40PM +0800, Yijing Wang wrote:
> This patch separate pci_host_bridge creation out
> of pci_create_root_bus(), and try to make a generic
> pci_host_bridge, then we could make it hold host
> bridge specific operations like
> pcibios_root_bridge_prepare(). The changes are
> transparent to platform host bridge drivers.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/host-bridge.c |   52 +++++++++++++++++++++
>  drivers/pci/pci.h         |    3 +
>  drivers/pci/probe.c       |  113 +++++++++++++++++++++------------------------
>  3 files changed, 108 insertions(+), 60 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index 39b2dbe..7d52a0a 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -8,6 +8,58 @@
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
> +		struct device *parent, int domain, int bus,
> +		struct list_head *resources)
> +{
> +	int error;
> +	struct pci_host_bridge *host;
> +	struct resource_entry *window, *n;
> +
> +	host = kzalloc(sizeof(*host), GFP_KERNEL);
> +	if (!host)
> +		return NULL;
> +
> +	host->dev.parent = parent;
> +	INIT_LIST_HEAD(&host->windows);
> +	resource_list_for_each_entry_safe(window, n, resources)
> +		list_move_tail(&window->node, &host->windows);
> +	/*
> +	 * If support CONFIG_PCI_DOMAINS_GENERIC, use
> +	 * pci_host_assign_domain_nr() to update domain
> +	 * number.
> +	 */
> +	host->domain = domain;
> +	pci_host_assign_domain_nr(host);

I think it's a bit confusing that there's another "host->domain ="
assignment buried inside pci_host_assign_domain_nr(), so the first
assignment is overwritten when CONFIG_PCI_DOMAINS_GENERIC is set.

Can you do something like this instead:

  int pci_host_assign_domain_nr(struct pci_host_bridge *host, int domain)
  {
  #ifdef CONFIG_PCI_DOMAINS_GENERIC
    host->domain = pci_assign_domain_nr(host->dev.parent);
  #else
    host->domain = domain;
  #endif
  }

Then the alternatives (CONFIG_PCI_DOMAINS_GENERIC=y and
CONFIG_PCI_DOMAINS_GENERIC being unset) are close together and right at the
#ifdef CONFIG_PCI_DOMAINS_GENERIC, so no extra comments are needed.

Bjorn

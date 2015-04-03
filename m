From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 03 Apr 2015 09:32:14 +0000
Subject: Re: [PATCH] PCI: Save sysdata in pci_host_bridge drvdata
Message-Id: <551E5E1E.6050209@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com> <1428053164-28277-2-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-2-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

Please ignore this one, it is the same as [PATCH v9 11/30] PCI: Save sysdata in pci_host_bridge drvdata.

Thanks!
Yijing.

On 2015/4/3 17:25, Yijing Wang wrote:
> Save platform specific sysdata in pci_host_bridge
> drvdata, host bridge specific operation need to
> access it before the pci bus creation.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/host-bridge.c |    3 ++-
>  drivers/pci/pci.h         |    2 +-
>  drivers/pci/probe.c       |   20 ++++++++++----------
>  3 files changed, 13 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index dffb345..98047c6 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -63,7 +63,7 @@ static bool pci_host_busn_res_overlap(
>  
>  struct pci_host_bridge *pci_create_host_bridge(
>  		struct device *parent, int domain, int bus,
> -		struct list_head *resources)
> +		void *sysdata, struct list_head *resources)
>  {
>  	int error;
>  	struct pci_host_bridge *host, *tmp;
> @@ -101,6 +101,7 @@ struct pci_host_bridge *pci_create_host_bridge(
>  	mutex_unlock(&pci_host_mutex);
>  
>  	host->dev.release = pci_release_host_bridge_dev;
> +	dev_set_drvdata(&host->dev, sysdata);
>  	dev_set_name(&host->dev, "pci%04x:%02x",
>  			host->domain, bus);
>  
> diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
> index 886d72f..aa8dff6 100644
> --- a/drivers/pci/pci.h
> +++ b/drivers/pci/pci.h
> @@ -335,7 +335,7 @@ static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
>  #endif
>  
>  struct pci_host_bridge *pci_create_host_bridge(struct device *parent,
> -		int domain, int bus, struct list_head *resources);
> +		int domain, int bus, void *sysdata, struct list_head *resources);
>  void pci_free_host_bridge(struct pci_host_bridge *host);
>  
>  static inline int pci_host_first_busnr(struct pci_host_bridge *host)
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index 8517d1b..0ac2bf6 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -1865,8 +1865,7 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
>  }
>  
>  static struct pci_bus *__pci_create_root_bus(
> -		struct pci_host_bridge *bridge, struct pci_ops *ops,
> -		void *sysdata)
> +		struct pci_host_bridge *bridge, struct pci_ops *ops)
>  {
>  	int error;
>  	struct pci_bus *b;
> @@ -1882,7 +1881,7 @@ static struct pci_bus *__pci_create_root_bus(
>  	if (!b)
>  		return NULL;
>  
> -	b->sysdata = sysdata;
> +	b->sysdata = dev_get_drvdata(&bridge->dev);
>  	b->ops = ops;
>  	b->number = b->busn_res.start >  		pci_host_first_busnr(bridge);
> @@ -1956,11 +1955,12 @@ struct pci_bus *pci_create_root_bus(struct device *parent,
>  {
>  	struct pci_host_bridge *host;
>  
> -	host = pci_create_host_bridge(parent, domain, bus, resources);
> +	host = pci_create_host_bridge(parent, domain, bus,
> +			sysdata, resources);
>  	if (!host)
>  		return NULL;
>  
> -	host->bus = __pci_create_root_bus(host, ops, sysdata);
> +	host->bus = __pci_create_root_bus(host, ops);
>  	if (!host->bus)
>  		pci_free_host_bridge(host);
>  
> @@ -2037,13 +2037,12 @@ void pci_bus_release_busn_res(struct pci_bus *b)
>  }
>  
>  static struct pci_bus *__pci_scan_root_bus(
> -		struct pci_host_bridge *host, struct pci_ops *ops,
> -		void *sysdata)
> +		struct pci_host_bridge *host, struct pci_ops *ops)
>  {
>  	struct pci_bus *b;
>  	int max;
>  
> -	b = __pci_create_root_bus(host, ops, sysdata);
> +	b = __pci_create_root_bus(host, ops);
>  	if (!b)
>  		return NULL;
>  
> @@ -2064,11 +2063,12 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
>  {
>  	struct pci_host_bridge *host;
>  
> -	host = pci_create_host_bridge(parent, domain, bus, resources);
> +	host = pci_create_host_bridge(parent, domain, bus,
> +			sysdata, resources);
>  	if (!host)
>  		return NULL;
>  
> -	host->bus = __pci_scan_root_bus(host, ops, sysdata);
> +	host->bus = __pci_scan_root_bus(host, ops);
>  	if (!host->bus)
>  		pci_free_host_bridge(host);
>  
> 


-- 
Thanks!
Yijing


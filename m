From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 12 Mar 2015 03:48:07 +0000
Subject: Re: [PATCH v6 30/30] PCI: Remove pci_bus_assign_domain_nr()
Message-Id: <20150312034807.GK10949@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <1425868467-9667-31-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425868467-9667-31-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Mon, Mar 09, 2015 at 10:34:27AM +0800, Yijing Wang wrote:
> Now we save the domain number in pci_host_bridge,
> we could remove pci_bus_assign_domain_nr() and
> clean the domain member in pci_bus.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  drivers/pci/pci.c   |    5 -----
>  drivers/pci/probe.c |   12 ++++--------
>  include/linux/pci.h |    3 ---
>  3 files changed, 4 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 2cf942b..4d8dfe4 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -4581,11 +4581,6 @@ void pci_host_assign_domain_nr(struct pci_host_bridge *host)
>  {
>  	host->domain = pci_assign_domain_nr(host->dev.parent);
>  }
> -
> -void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
> -{
> -	bus->domain_nr = pci_assign_domain_nr(parent);
> -}

I think you forgot to remove the empty pci_bus_assign_domain_nr()
definition from include/linux/pci.h.

I'm not sure how much value is left in CONFIG_PCI_DOMAINS_GENERIC.  You're
removed *almost* everything that uses it.  I wonder how hard it would be to
get rid of that last little bit.

>  #endif
>  #endif
>  
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index 196f08a..9cd3ca2 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -481,7 +481,7 @@ void pci_read_bridge_bases(struct pci_bus *child)
>  	}
>  }
>  
> -static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
> +static struct pci_bus *pci_alloc_bus(void)
>  {
>  	struct pci_bus *b;
>  
> @@ -496,10 +496,7 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
>  	INIT_LIST_HEAD(&b->resources);
>  	b->max_bus_speed = PCI_SPEED_UNKNOWN;
>  	b->cur_bus_speed = PCI_SPEED_UNKNOWN;
> -#ifdef CONFIG_PCI_DOMAINS_GENERIC
> -	if (parent)
> -		b->domain_nr = parent->domain_nr;
> -#endif
> +
>  	return b;
>  }
>  
> @@ -646,7 +643,7 @@ static struct pci_bus *pci_alloc_child_bus(struct pci_bus *parent,
>  	/*
>  	 * Allocate a new bus, and inherit stuff from the parent..
>  	 */
> -	child = pci_alloc_bus(parent);
> +	child = pci_alloc_bus();
>  	if (!child)
>  		return NULL;
>  
> @@ -1866,14 +1863,13 @@ static struct pci_bus *pci_create_root_bus(
>  	char *fmt;
>  
>  	parent = bridge->dev.parent;
> -	b = pci_alloc_bus(NULL);
> +	b = pci_alloc_bus();
>  	if (!b)
>  		return NULL;
>  
>  	b->sysdata = dev_get_drvdata(&bridge->dev);
>  	b->ops = ops;
>  	b->number = b->busn_res.start = bridge->busnum;
> -	pci_bus_assign_domain_nr(b, parent);
>  
>  	bridge->bus = b;
>  	b->bridge = get_device(&bridge->dev);
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index dc1c710..ebc70bb 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -467,9 +467,6 @@ struct pci_bus {
>  	unsigned char	primary;	/* number of primary bridge */
>  	unsigned char	max_bus_speed;	/* enum pci_bus_speed */
>  	unsigned char	cur_bus_speed;	/* enum pci_bus_speed */
> -#ifdef CONFIG_PCI_DOMAINS_GENERIC
> -	int		domain_nr;
> -#endif
>  
>  	char		name[48];
>  
> -- 
> 1.7.1
> 

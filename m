From: Liviu Dudau <Liviu.Dudau@arm.com>
Date: Tue, 18 Nov 2014 14:48:19 +0000
Subject: Re: [RFC PATCH 07/16] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <20141118144819.GK12037@e106497-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
 <1416219710-26088-8-git-send-email-wangyijing@huawei.com>
 <2507218.mHliopJb05@wuerfel>
 <546B041A.4060403@huawei.com>
In-Reply-To: <546B041A.4060403@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Arnd Bergmann <arnd@arndb.de>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "huxinwei@huawei.com" <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Nov 18, 2014 at 08:32:26AM +0000, Yijing Wang wrote:
> 
> >> +LIST_HEAD(pci_host_bridge_list);
> >> +DECLARE_RWSEM(pci_host_bridge_sem);
> > 
> > Unless the pci_host_bridge_sem is accessed thousands of times per second,
> > it's normally better to use a simple mutex instead.
> 
> OK, I will use simple mutex instead.
> 
> > 
> >> +static struct resource busn_resource = {
> >> +	.name	= "PCI busn",
> >> +	.start	= 0,
> >> +	.end	= 255,
> >> +	.flags	= IORESOURCE_BUS,
> >> +};
> > 
> > I think it would be better to require callers to pass the bus resource
> > down to the function.
> 
> Hmm, I think most of caller will provide the bus resource, but some others
> will not give any bus resource, extremely, no any resources :(. But we still
> need properly configure their resources for compatibility.
> 
> > 
> >> +struct pci_host_bridge *pci_create_host_bridge(
> >> +		struct device *parent, u32 db, 
> >> +		struct pci_ops *ops, void *sysdata, 
> >> +		struct list_head *resources)
> >> +{
> > 
> > Do we still need to pass the 'sysdata' in here? If we are guaranteed to
> > have a device pointer, we should always be able to get the driver
> > private data from dev_get_drvdata(host->dev->parent).
> 
> We need, some platforms pass NULL pointer as host bridge parent.

Yijing,

May I suggest a different approach here? Rather than having to pass an opaque
pointer that gets converted by the host bridge driver back to the private
structure, what about promoting a new style of usage, that is similar to the
way device drivers work? Lets try to promote the embedding of the generic
pci_host_bridge structure in the host bridge specific structure! Then we can
access the private data doing container_of().

Something like this:

struct pci_controller {
	struct pci_host_bridge bridge;
	/* private host bridge data here */
	.....
};

#define PCI_CONTROLLER(bus)	({
	struct pci_host_bridge *hb = to_pci_host_bridge(bus->bridge); \
	container_of(hb, struct pci_controller, bridge); })


Then we can retrieve the host bridge structure from everywhere we have a device.

Best regards,
Liviu

> 
> > 
> >> +	host = kzalloc(sizeof(*host), GFP_KERNEL);
> >> +	if (!host)
> >> +		return NULL;
> > 
> > devm_kzalloc maybe?
> 
> I don't know much detail about devm_kzalloc(), but we have no pci host driver
> here, and I found no devm_kzalloc() uses in core PCI code before.
> 
> > 
> >> +	if (!resources) {
> >> +		/* Use default IO/MEM/BUS resources*/
> >> +		pci_add_resource(&host->windows, &ioport_resource);
> >> +		pci_add_resource(&host->windows, &iomem_resource);
> >> +		pci_add_resource(&host->windows, &busn_resource);
> >> +	} else {
> >> +		list_for_each_entry_safe(window, n, resources, list)
> >> +			list_move_tail(&window->list, &host->windows);
> >> +	}
> > 
> > I think we should assume that the correct resources are passed. You
> > could add a wrapper around this function to convert old platforms
> > though.
> 
> OK, I will move these code out of pci_create_host_bridge, and add a wrapper
> to setup the default resources.
> 
> > 
> >> +EXPORT_SYMBOL(pci_create_host_bridge);
> > 
> > EXPORT_SYMBOL_GPL() maybe?
> 
> OK, will update it.
> 
> > 
> >> diff --git a/include/linux/pci.h b/include/linux/pci.h
> >> index 8b11b38..daa7f40 100644
> >> --- a/include/linux/pci.h
> >> +++ b/include/linux/pci.h
> >> @@ -402,7 +402,12 @@ struct pci_host_bridge_window {
> >>  struct pci_host_bridge {
> >>  	struct device dev;
> >>  	struct pci_bus *bus;		/* root bus */
> >> +	struct list_head list;
> >>  	struct list_head windows;	/* pci_host_bridge_windows */
> >> +	int busnum;
> > 
> > The busnum should already be implied through the bus resource.
> 
> Yes, I will consider remove it and introduce a helper function to get the root bus number, thanks!
> 
> Thanks!
> Yijing.
> 
> > 
> > 	Arnd
> > 
> > .
> > 
> 
> 
> -- 
> Thanks!
> Yijing
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
==========
| I would like to |
| fix the world,  |
| but they're not |
| giving me the   |
 \ source code!  /
  ---------------
    ¯\_(ツ)_/¯


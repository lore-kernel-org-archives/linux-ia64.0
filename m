From: Greg KH <greg@kroah.com>
Date: Fri, 13 May 2005 16:44:29 +0000
Subject: Re: [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <20050513164429.GH11089@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835EAB.7010905@sgi.com>
In-Reply-To: <42835EAB.7010905@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 12, 2005 at 08:46:03PM -0400, Prarit Bhargava wrote:
> +EXPORT_SYMBOL(sn_pci_fixup_slot);
> +EXPORT_SYMBOL(sn_pci_unfixup_slot);
> +EXPORT_SYMBOL(sn_pci_controller_fixup);
> +EXPORT_SYMBOL(sn_bus_store_sysdata);
> +EXPORT_SYMBOL(sn_bus_free_sysdata);

EXPORT_SYMBOL_GPL() please.


> +	for (func = 0; func < num_funcs;  func++) {
> +		dev = pci_get_slot(slot->pci_bus,
> +				   PCI_DEVFN(slot->device_num + 1,
> +					     PCI_FUNC(func)));
> +
> +
> +		if (dev) {

Unneeded 2 blank lines, only 1 please.

> +static int sn_pci_hotplug_init(void)
> +{
> +	struct pci_bus *pci_bus = NULL;
> +	int rc;
> +	int registered = 0;
> +
> +	INIT_LIST_HEAD(&sn_hp_list);
> +
> +	if (sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {
> +		printk(KERN_ERR "%s: PROM version must be greater than 4.05\n",
> +		       __FUNCTION__);
> +		return -EPERM;
> +	}
> +
> +	while ((pci_bus = pci_find_next_bus(pci_bus))) {
> +		if (!pci_bus->sysdata)
> +			continue;
> +
> +		rc = sn_pci_bus_valid(pci_bus);
> +		if (rc != 1) {
> +			dev_dbg(pci_bus->self, "not a valid hotplug bus\n");
> +			continue;
> +		}
> +		dev_dbg(pci_bus->self, "valid hotplug bus\n");
> +
> +		rc = sn_hotplug_slot_register(pci_bus);
> +		if (!rc)
> +			registered = 1;
> +		else {
> +			registered = 0;
> +			break;
> +		}
> +	}

How do you recover if you fail the second (or third, or fourth) hotplug bus register?  It
looks like the code will die a horrible death...

thanks,

greg k-h

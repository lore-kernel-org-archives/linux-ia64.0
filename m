From: Greg KH <gregkh@suse.de>
Date: Sat, 19 Mar 2005 05:14:46 +0000
Subject: Re: [patch 07/12] Make the PCI remove routines safe for failed hot-plug
Message-Id: <20050319051446.GD21485@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318133856.A878@unix-os.sc.intel.com> <20050318141143.G1145@unix-os.sc.intel.com>
In-Reply-To: <20050318141143.G1145@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rajesh Shah <rajesh.shah@intel.com>
Cc: tony.luck@intel.com, len.brown@intel.com, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net, linux-ia64@vger.kernel.org, acpi-devel@lists.sourceforge.net

On Fri, Mar 18, 2005 at 02:11:44PM -0800, Rajesh Shah wrote:
> diff -puN drivers/pci/remove.c~pci-remove-device-hotplug-safe drivers/pci/remove.c
> --- linux-2.6.11-mm4-iohp/drivers/pci/remove.c~pci-remove-device-hotplug-safe	2005-03-16 13:07:22.667319764 -0800
> +++ linux-2.6.11-mm4-iohp-rshah1/drivers/pci/remove.c	2005-03-16 13:07:22.775718200 -0800
> @@ -26,17 +26,21 @@ static void pci_free_resources(struct pc
>  
>  static void pci_destroy_dev(struct pci_dev *dev)
>  {
> -	pci_proc_detach_device(dev);
> -	pci_remove_sysfs_dev_files(dev);
> -	device_unregister(&dev->dev);
> +	if (!list_empty(&dev->global_list)) {
> +		pci_proc_detach_device(dev);
> +		pci_remove_sysfs_dev_files(dev);
> +		device_unregister(&dev->dev);
> +		spin_lock(&pci_bus_lock);
> +		list_del(&dev->global_list);
> +		dev->global_list.next = dev->global_list.prev = NULL;
> +		spin_unlock(&pci_bus_lock);
> +	}
>  
>  	/* Remove the device from the device lists, and prevent any further
>  	 * list accesses from this device */
>  	spin_lock(&pci_bus_lock);
>  	list_del(&dev->bus_list);
> -	list_del(&dev->global_list);
>  	dev->bus_list.next = dev->bus_list.prev = NULL;
> -	dev->global_list.next = dev->global_list.prev = NULL;
>  	spin_unlock(&pci_bus_lock);
>  
>  	pci_free_resources(dev);

I did have a comment about this code at first glance, but in reviewing
it again, nevermind, it looks fine...

thanks,

greg k-h

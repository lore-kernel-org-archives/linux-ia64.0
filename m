From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 07 Apr 2015 02:52:26 +0000
Subject: Re: [PATCH v9 19/30] powerpc/pci: Use pci_scan_host_bridge() for simplicity
Message-Id: <5523466A.3090500@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>	 <1428053164-28277-21-git-send-email-wangyijing@huawei.com> <1428363334.22268.9.camel@axtens.net>
In-Reply-To: <1428363334.22268.9.camel@axtens.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Axtens <dja@axtens.net>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, linuxppc-dev@lists.ozlabs.org

On 2015/4/7 7:35, Daniel Axtens wrote:
> I've been looking at this patch series for a while now, and I now
> believe it's ready on the PowerPC side.
> 
> I was originally concerned that it would break odd corner cases,
> particularly where similar code appears (namely kernel/pci_hotplug.c and
> kernel/pci_of_scan.c). However, upon further examination, talking with
> Yijing, and some testing, I'm now convinced that it is indeed restricted
> to the generic code, and doesn't change behaviour.
> 
> This is both a plus and a minus: because it's currently restricted to
> generic code, I'm confident it works, but the down side is that it
> doesn't yet simplify our arch-specific complexity. We'll need to do some
> more work on our side to reap the full benefits.
> 
> I tested this entire series on a PowerNV machine, including doing EEH
> injection to trigger PCI hotplug:
> Tested-by: Daniel Axtens <dja@axtens.net>
> For completeness, it would be good to test it on Cell, as they are the
> only remaining user of pci_of_scan.c
> 
> In conclusion, this patch is
> Reviewed-by: Daniel Axtens <dja@axtens.net>
> 


Thanks very much for your test and review.

Thanks!
Yijing.

> 
> 
> On Fri, 2015-04-03 at 17:25 +0800, Yijing Wang wrote:
>> Now we could use pci_scan_host_bridge() to scan
>> pci buses, provide powerpc specific pci_host_bridge_ops.
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: linuxppc-dev@lists.ozlabs.org
>> ---
>>  arch/powerpc/kernel/pci-common.c |   62 +++++++++++++++++++++++--------------
>>  1 files changed, 38 insertions(+), 24 deletions(-)
>>
>> diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
>> index 2c58200..50b32f6 100644
>> --- a/arch/powerpc/kernel/pci-common.c
>> +++ b/arch/powerpc/kernel/pci-common.c
>> @@ -773,6 +773,29 @@ void pcibios_set_root_bus_speed(struct pci_host_bridge *bridge)
>>  		return ppc_md.pcibios_set_root_bus_speed(bridge);
>>  }
>>  
>> +static int pci_host_scan_bus(struct pci_host_bridge *host)
>> +{
>> +	int mode = PCI_PROBE_NORMAL;
>> +	struct pci_bus *bus = host->bus;
>> +	struct pci_controller *hose = dev_get_drvdata(&host->dev);
>> +
>> +	/* Get probe mode and perform scan */
>> +	if (hose->dn && ppc_md.pci_probe_mode)
>> +		mode = ppc_md.pci_probe_mode(bus);
>> +
>> +	pr_debug("    probe mode: %d\n", mode);
>> +	if (mode = PCI_PROBE_DEVTREE)
>> +		of_scan_bus(hose->dn, bus);
>> +
>> +	if (mode = PCI_PROBE_NORMAL) {
>> +		pci_bus_update_busn_res_end(bus, 255);
>> +		hose->last_busno = pci_scan_child_bus(bus);
>> +		pci_bus_update_busn_res_end(bus, hose->last_busno);
>> +	}
>> +
>> +	return pci_bus_child_max_busnr(bus);
>> +}
>> +
>>  /* This header fixup will do the resource fixup for all devices as they are
>>   * probed, but not for bridge ranges
>>   */
>> @@ -1585,6 +1608,11 @@ struct device_node *pcibios_get_phb_of_node(struct pci_bus *bus)
>>  	return of_node_get(hose->dn);
>>  }
>>  
>> +static struct pci_host_bridge_ops pci_host_ops = {
>> +	.set_root_bus_speed = pcibios_set_root_bus_speed,
>> +	.scan_bus = pci_host_scan_bus,
>> +};
>> +
>>  /**
>>   * pci_scan_phb - Given a pci_controller, setup and scan the PCI bus
>>   * @hose: Pointer to the PCI host controller instance structure
>> @@ -1592,9 +1620,8 @@ struct device_node *pcibios_get_phb_of_node(struct pci_bus *bus)
>>  void pcibios_scan_phb(struct pci_controller *hose)
>>  {
>>  	LIST_HEAD(resources);
>> -	struct pci_bus *bus;
>> +	struct pci_host_bridge *host;
>>  	struct device_node *node = hose->dn;
>> -	int mode;
>>  
>>  	pr_debug("PCI: Scanning PHB %s\n", of_node_full_name(node));
>>  
>> @@ -1609,30 +1636,17 @@ void pcibios_scan_phb(struct pci_controller *hose)
>>  	hose->busn.flags = IORESOURCE_BUS;
>>  	pci_add_resource(&resources, &hose->busn);
>>  
>> +	pci_host_ops.pci_ops = hose->ops;
>>  	/* Create an empty bus for the toplevel */
>> -	bus = pci_create_root_bus(hose->parent, hose->global_number,
>> -			hose->first_busno, hose->ops, hose, &resources);
>> -	if (bus = NULL) {
>> -		pr_err("Failed to create bus for PCI domain %04x\n",
>> -			hose->global_number);
>> +	host = pci_scan_host_bridge(hose->parent, hose->global_number,
>> +			hose->first_busno, hose, &resources, &pci_host_ops);
>> +	if (host = NULL) {
>> +		pr_err("Failed to create host bridge for pci%04x:%02x\n",
>> +			hose->global_number, hose->first_busno);
>>  		pci_free_resource_list(&resources);
>>  		return;
>>  	}
>> -	hose->bus = bus;
>> -
>> -	/* Get probe mode and perform scan */
>> -	mode = PCI_PROBE_NORMAL;
>> -	if (node && ppc_md.pci_probe_mode)
>> -		mode = ppc_md.pci_probe_mode(bus);
>> -	pr_debug("    probe mode: %d\n", mode);
>> -	if (mode = PCI_PROBE_DEVTREE)
>> -		of_scan_bus(node, bus);
>> -
>> -	if (mode = PCI_PROBE_NORMAL) {
>> -		pci_bus_update_busn_res_end(bus, 255);
>> -		hose->last_busno = pci_scan_child_bus(bus);
>> -		pci_bus_update_busn_res_end(bus, hose->last_busno);
>> -	}
>> +	hose->bus = host->bus;
>>  
>>  	/* Platform gets a chance to do some global fixups before
>>  	 * we proceed to resource allocation
>> @@ -1641,9 +1655,9 @@ void pcibios_scan_phb(struct pci_controller *hose)
>>  		ppc_md.pcibios_fixup_phb(hose);
>>  
>>  	/* Configure PCI Express settings */
>> -	if (bus && !pci_has_flag(PCI_PROBE_ONLY)) {
>> +	if (host->bus && !pci_has_flag(PCI_PROBE_ONLY)) {
>>  		struct pci_bus *child;
>> -		list_for_each_entry(child, &bus->children, node)
>> +		list_for_each_entry(child, &host->bus->children, node)
>>  			pcie_bus_configure_settings(child);
>>  	}
>>  }
> 


-- 
Thanks!
Yijing


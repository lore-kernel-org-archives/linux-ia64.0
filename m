From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 16 Mar 2015 01:48:14 +0000
Subject: Re: [PATCH v6 00/30] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <5506365E.6020704@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com> <20150312212306.GH7346@google.com> <20150313113156.GA4739@bart.dudau.co.uk>
In-Reply-To: <20150313113156.GA4739@bart.dudau.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Liviu Dudau <liviu@dudau.co.uk>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On 2015/3/13 19:31, Liviu Dudau wrote:
> On Thu, Mar 12, 2015 at 04:23:06PM -0500, Bjorn Helgaas wrote:
>> On Mon, Mar 09, 2015 at 10:33:57AM +0800, Yijing Wang wrote:
>>> ...
>>> Yijing Wang (29):
>>>   PCI: Rip out pci_bus_add_devices() from pci_scan_bus()
>>>   PCI: Rip out pci_bus_add_devices() from pci_scan_root_bus()
>>>   sparc/PCI: Claim bus resources before pci_bus_add_devices()
>>
>> I put the above patches plus a cleanup patch on my pci/enumeration branch.
>> Please rebase your next revision to that.  If there's anything else
>> non-controversial that we can pull in to chip away at this, let me know.
> 
> Hi Bjorn and Yijing,
> 
> Sorry for not providing feedback earlier on this series (or any previous ones),
> I'm just crawling out from under a rock of doing graphics drivers :)
> 
> The patch ripping out pci_bus_add_devices() from pci_scan_root_bus() misses out
> the users of that function from drivers/pci/host. If Yijing is going to refresh
> the series it is probably worth starting with adding back the call into pcie-xilinx.c
> and pci-versatile.c.

Hi Liviu, thanks for your comment. I would add pci_bus_add_devices() for pci-versatile.c,
But for pcie-xilinx.c and other host drivers used for arm32, we do not need to add
pci_bus_add_devices() for them, because in arm32 pci enumeration, another pci_bus_add_devices()
would be called in pci_common_init_dev();

for arm32 pci enumeration:
pci_common_init_dev()
   pcibios_init_hw()
       hw->scan/pci_scan_root_bus()
   pci_bus_size_bridges()
   pci_bus_assign_resources()
   pci_bus_add_devices()

Is there something I have missed ?

Thanks!
Yijing.

> 
> Will try to review (and test) the rest of the series soon.
> 
> Best regards,
> Liviu
> 
>>
>>>   PCI: Export busn_resource to drivers/pci
>>>   PCI: Remove deprecated pci_scan_bus_parented()
>>>   PCI: Combine PCI domain and bus number in u32 arg
>>>   PCI: Pass PCI domain number combined with root bus number
>>>   PCI: Introduce pci_host_assign_domain_nr() to assign domain
>>>   PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
>>>   PCI: Introduce pci_host_bridge_list to manage host bridges
>>>   PCI: Save sysdata in pci_host_bridge drvdata
>>>   PCI: Introduce pci_host_bridge_ops to support host specific
>>>     operations
>>>   PCI: Introduce new scan function pci_scan_host_bridge()
>>>   x86/PCI: Refine pci_acpi_scan_root() with generic pci_host_bridge
>>>   ia64/PCI: Refine pci_acpi_scan_root() with generic pci_host_bridge
>>>   powerpc/pci: Rename pcibios_root_bridge_prepare()
>>>   powerpc/pci: Use pci_scan_host_bridge() for simplicity
>>>   PCI: Remove weak pcibios_root_bridge_prepare()
>>>   sparc/PCI: Use pci_scan_host_bridge() for simplicity
>>>   PCI: Introduce pci_bus_child_max_busnr()
>>>   parisc/PCI: Use pci_scan_root_bus() for simplicity
>>>   PCI/mvebu: Use pci_common_init_dev() to simplify code
>>>   PCI/tegra: Remove redundant tegra_pcie_scan_bus()
>>>   PCI/designware: Use pci_scan_root_bus() for simplicity
>>>   PCI/xgene: Use pci_scan_root_bus() instead of pci_create_root_bus()
>>>   PCI: Rename __pci_create_root_bus() to pci_create_root_bus()
>>>   PCI: Export find_pci_host_bridge() and rename to
>>>     pci_find_host_bridge()
>>>   PCI: Remove platform specific pci_domain_nr()
>>>   PCI: Remove pci_bus_assign_domain_nr()
>>
> 


-- 
Thanks!
Yijing


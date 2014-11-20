From: Tomasz Nowicki <tomasz.nowicki@linaro.org>
Date: Thu, 20 Nov 2014 11:54:48 +0000
Subject: Re: [RFC PATCH 00/16] Refine PCI host bridge scan interfaces
Message-Id: <546DD688.60705@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1463511.o4kE8TX3Bd@wuerfel>
In-Reply-To: <1463511.o4kE8TX3Bd@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Cc: Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Thierry Reding <thierry.reding@gmail.com>, Suravee.Suthikulpanit@amd.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Yijing Wang <wangyijing@huawei.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, linuxppc-dev@lists.ozlabs.org

On 17.11.2014 15:13, Arnd Bergmann wrote:
> On Monday 17 November 2014 18:21:34 Yijing Wang wrote:
>> This series is based Linux 3.18-rc1 and Lorenzo Pieralisi's
>> arm PCI domain cleanup patches, link:
>> https://patchwork.ozlabs.org/patch/407585/
>>
>> Current pci scan interfaces like pci_scan_root_bus() and directly
>> call pci_create_root_bus()/pci_scan_child_bus() lack flexiblity.
>> Some platform infos like PCI domain and msi_chip have to be
>> associated to PCI bus by some arch specific function.
>> We want to make a generic pci_host_bridge, and make it hold
>> the platform infos or hook. Then we could eliminate the lots
>> of arch pci_domain_nr, also we could associate some platform
>> ops something like pci_get_msi_chip(struct pci_dev *dev)
>> with pci_host_bridge to avoid introduce arch weak functions.
>>
>> This RFC version not for all platforms, just applied the new
>> scan interface in x86/arm/powerpc/ia64, I will refresh other
>> platforms after the core pci scan interfaces are ok.
>
> I think overall this is a good direction to take, in particular
> moving more things into struct pci_host_bridge so we can
> slim down the architecture specific code.
>
> I don't particularly like the way you use the 'pci_host_info'
> to pass callback pointers and some of the generic information.
> This duplicates some of the issues we are currently trying
> to untangle in the arm32 code to make drivers easier to share
> between architectures.
>
> As a general approach, I'd rather see generic helper functions
> being exported by the PCI core that a driver may or may not
> call.
> The way you split the interface between things that happen
> before scanning the buses (pci_create_host_bridge) and
> the actual scanning (__pci_create_root_bus, pci_scan_child_bus)
> seems very helpful and I think we can expand that concept further:
>
> - The normal pci_create_host_bridge() function can contain
>    all of the DT scanning functions (finding bus/mem/io resources,
>    finding the msi-parent), while drivers that don't depend on DT
>    for this information can call the same function and fill the
>    same things after they have the pci_host_bridge pointer.

How about finding PCI domain number (in the DT way) within 
pci_create_host_bridge() too ?

Tomasz

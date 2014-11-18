From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 18 Nov 2014 12:14:33 +0000
Subject: Re: [RFC PATCH 00/16] Refine PCI host bridge scan interfaces
Message-Id: <546B3829.9040209@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1463511.o4kE8TX3Bd@wuerfel> <546B2ACC.90304@huawei.com> <20535707.3sA6NjSINh@wuerfel> <20141118114518.GA3514@red-moon>
In-Reply-To: <20141118114518.GA3514@red-moon>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Arnd Bergmann <arnd@arndb.de>
Cc: Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "huxinwei@huawei.com" <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>, Bjorn Helgaas <bhelgaas@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2014/11/18 19:45, Lorenzo Pieralisi wrote:
> On Tue, Nov 18, 2014 at 11:30:11AM +0000, Arnd Bergmann wrote:
>> On Tuesday 18 November 2014 19:17:32 Yijing Wang wrote:
>>> On 2014/11/17 22:13, Arnd Bergmann wrote:
>>>> On Monday 17 November 2014 18:21:34 Yijing Wang wrote:
>>>>> This series is based Linux 3.18-rc1 and Lorenzo Pieralisi's
>>>>> arm PCI domain cleanup patches, link: 
>>>>> https://patchwork.ozlabs.org/patch/407585/
>>>>>
>>>>> Current pci scan interfaces like pci_scan_root_bus() and directly
>>>>> call pci_create_root_bus()/pci_scan_child_bus() lack flexiblity.
>>>>> Some platform infos like PCI domain and msi_chip have to be
>>>>> associated to PCI bus by some arch specific function.
>>>>> We want to make a generic pci_host_bridge, and make it hold
>>>>> the platform infos or hook. Then we could eliminate the lots
>>>>> of arch pci_domain_nr, also we could associate some platform 
>>>>> ops something like pci_get_msi_chip(struct pci_dev *dev)
>>>>> with pci_host_bridge to avoid introduce arch weak functions.
>>>>>
>>>>> This RFC version not for all platforms, just applied the new
>>>>> scan interface in x86/arm/powerpc/ia64, I will refresh other
>>>>> platforms after the core pci scan interfaces are ok.
>>>>
>>>> I think overall this is a good direction to take, in particular
>>>> moving more things into struct pci_host_bridge so we can
>>>> slim down the architecture specific code.
>>>
>>> Hi Arnd, thanks very much for your review and comments!
>>>
>>>>
>>>> I don't particularly like the way you use the 'pci_host_info'
>>>> to pass callback pointers and some of the generic information.
>>>> This duplicates some of the issues we are currently trying
>>>> to untangle in the arm32 code to make drivers easier to share
>>>> between architectures.
>>>
>>> What arm32 code you are trying to untangle for example ?
>>
>> We have a few problems that currently prevent us from using shared
>> drivers across arm32 and arm64:
>>
>> - arm32 has an architecture-defined pci_sys_data structure, but
>>   we really want to have one that is defined by the host bridge driver
>>   and that is architecture independent. Some core functions depend
>>   on this structure at the moment, which Lorenzo is trying to
>>   undo
> 
> Yes, and on this specific point I would like to understand why we
> are adding yet more pci_sys_data data in the last series that is
> already in -next:
> 
> https://lkml.org/lkml/2014/10/27/85
> 
> What does this buy us ? The cover letter says already that there *is*
> a better solution, why do not we work on that instead of adding more churn
> to arch specific code ?

In my plan, first save msi_chip in pci_sys_data, so we could remove the lots duplicate
pcibios_add_bus(), second, make a generic pci_host_bridge, and move the msi_chip in that,
so we could eliminate all MSI arch weak functions. And in arm I think it's no need to
associate msi_chip with PCI bus, because all pci devices under the same pci host bridge
share the same msi_chip.



> 
> Thanks,
> Lorenzo
> 
> .
> 


-- 
Thanks!
Yijing


From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:16:06 +0000
Subject: Re: [PATCH 00/13] Refactor pci_is_brdige() to simplify code
Message-Id: <5365BF06.7050108@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1398417515-8740-1-git-send-email-wangyijing@huawei.com> <CAErSpo4fa=fmajhxGA7PRm42S1fS2wV_7w+EWaVh_qiawRAQxA@mail.gmail.com>
In-Reply-To: <CAErSpo4fa=fmajhxGA7PRm42S1fS2wV_7w+EWaVh_qiawRAQxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, "x86@kernel.org" <x86@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

> This needs to be posted to the linux-pci list.  The fact that it
> wasn't means it's not in patchwork, so it's not on my to-do list.
> 
> Currently we have one interface: pci_is_bridge().
> 
> After your series, we would have two interfaces: pci_is_bridge() and
> pci_has_subordinate().  Presumably, both are used, and you should
> explain how you decided which to use at each place.
> 
> I assume the difference is that the old pci_is_bridge() is true for a
> bridge that has a subordinate bus.  The new pci_is_bridge() is true
> for any bridge, even if there is no subordinate bus.  When do we even
> have a bridge with no subordinate bus?  This is the sort of stuff you
> need to explain so we know why we should apply these patches.
> 

Hi Bjorn, sorry forgot to cc pci list, will resend the v2 patchset with
some new description for new pci_is_bridge().

> 
>> Yijing Wang (13):
>>   PCI: rename pci_is_bridge() to pci_has_subordinate()
>>   PCI: Introduce new pci_is_bridge() helper function
>>   PCI: Use new pci_is_bridge() to simplify code
>>   x86/PCI: Use new pci_is_bridge() to simplify code
>>   IA64/PCI: Use new pci_is_bridge() to simplify code
>>   powerpc/PCI: Use new pci_is_bridge() to simplify code
>>   sparc/PCI: Use new pci_is_bridge() to simplify code
>>   PCI, rpaphp: Use new pci_is_bridge() to simplify code
>>   PCI, shpchp: Use new pci_is_bridge() to simplify code
>>   PCI, cpcihp: Use new pci_is_bridge() to simplify code
>>   PCI, acpiphp: Use new pci_is_bridge() to simplify code
>>   PCI, pcmcia: Use new pci_is_bridge() to simplify code
>>   PCI, pciehp: Use new pci_is_bridge() to simplify code
>>
>>  arch/ia64/pci/fixup.c                  |    4 +---
>>  arch/powerpc/kernel/pci-hotplug.c      |    3 +--
>>  arch/powerpc/kernel/pci_of_scan.c      |    3 +--
>>  arch/sparc/kernel/pci.c                |    3 +--
>>  arch/x86/pci/fixup.c                   |    4 +---
>>  drivers/pci/hotplug/acpiphp_glue.c     |    3 +--
>>  drivers/pci/hotplug/cpci_hotplug_pci.c |    3 +--
>>  drivers/pci/hotplug/pciehp_pci.c       |    3 +--
>>  drivers/pci/hotplug/rpadlpar_core.c    |    3 +--
>>  drivers/pci/hotplug/shpchp_pci.c       |    3 +--
>>  drivers/pci/pci-acpi.c                 |    8 +-------
>>  drivers/pci/pci-driver.c               |    8 ++++----
>>  drivers/pci/pci.h                      |    2 +-
>>  drivers/pci/probe.c                    |    3 +--
>>  drivers/pci/setup-bus.c                |    4 +---
>>  drivers/pcmcia/cardbus.c               |    3 +--
>>  include/linux/pci.h                    |    6 ++++++
>>  17 files changed, 25 insertions(+), 41 deletions(-)
>>
>>
> 
> .
> 


-- 
Thanks!
Yijing


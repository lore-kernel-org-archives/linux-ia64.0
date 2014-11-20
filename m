From: Liviu Dudau <liviu@dudau.co.uk>
Date: Thu, 20 Nov 2014 16:39:18 +0000
Subject: Re: [RFC PATCH 00/16] Refine PCI host bridge scan interfaces
Message-Id: <20141120163918.GE9162@bart.dudau.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
 <1463511.o4kE8TX3Bd@wuerfel>
 <546DD688.60705@linaro.org>
 <20141120120850.GD9162@bart.dudau.co.uk>
 <546DE45C.6010306@linaro.org>
In-Reply-To: <546DE45C.6010306@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tomasz Nowicki <tomasz.nowicki@linaro.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Thierry Reding <thierry.reding@gmail.com>, Suravee.Suthikulpanit@amd.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Yijing Wang <wangyijing@huawei.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, linuxppc-dev@lists.ozlabs.org

On Thu, Nov 20, 2014 at 01:53:48PM +0100, Tomasz Nowicki wrote:
> On 20.11.2014 13:08, Liviu Dudau wrote:
> >On Thu, Nov 20, 2014 at 12:54:48PM +0100, Tomasz Nowicki wrote:
> >>On 17.11.2014 15:13, Arnd Bergmann wrote:
> >>>On Monday 17 November 2014 18:21:34 Yijing Wang wrote:
> >>>>This series is based Linux 3.18-rc1 and Lorenzo Pieralisi's
> >>>>arm PCI domain cleanup patches, link:
> >>>>https://patchwork.ozlabs.org/patch/407585/
> >>>>
> >>>>Current pci scan interfaces like pci_scan_root_bus() and directly
> >>>>call pci_create_root_bus()/pci_scan_child_bus() lack flexiblity.
> >>>>Some platform infos like PCI domain and msi_chip have to be
> >>>>associated to PCI bus by some arch specific function.
> >>>>We want to make a generic pci_host_bridge, and make it hold
> >>>>the platform infos or hook. Then we could eliminate the lots
> >>>>of arch pci_domain_nr, also we could associate some platform
> >>>>ops something like pci_get_msi_chip(struct pci_dev *dev)
> >>>>with pci_host_bridge to avoid introduce arch weak functions.
> >>>>
> >>>>This RFC version not for all platforms, just applied the new
> >>>>scan interface in x86/arm/powerpc/ia64, I will refresh other
> >>>>platforms after the core pci scan interfaces are ok.
> >>>
> >>>I think overall this is a good direction to take, in particular
> >>>moving more things into struct pci_host_bridge so we can
> >>>slim down the architecture specific code.
> >>>
> >>>I don't particularly like the way you use the 'pci_host_info'
> >>>to pass callback pointers and some of the generic information.
> >>>This duplicates some of the issues we are currently trying
> >>>to untangle in the arm32 code to make drivers easier to share
> >>>between architectures.
> >>>
> >>>As a general approach, I'd rather see generic helper functions
> >>>being exported by the PCI core that a driver may or may not
> >>>call.
> >>>The way you split the interface between things that happen
> >>>before scanning the buses (pci_create_host_bridge) and
> >>>the actual scanning (__pci_create_root_bus, pci_scan_child_bus)
> >>>seems very helpful and I think we can expand that concept further:
> >>>
> >>>- The normal pci_create_host_bridge() function can contain
> >>>   all of the DT scanning functions (finding bus/mem/io resources,
> >>>   finding the msi-parent), while drivers that don't depend on DT
> >>>   for this information can call the same function and fill the
> >>>   same things after they have the pci_host_bridge pointer.
> >>
> >>How about finding PCI domain number (in the DT way) within
> >>pci_create_host_bridge() too ?
> >
> >It is an idea worth pursuing for the 99% of the cases. I would like
> >to understand the 1% of the time when we want a domain number to be
> >shared between two host bridges or the time when we want more than
> >one domain per bridge.
> Even though we have shared domain, this should be resolved via DT calls, do
> I miss something ?

If we only going to hold one domain number per host bridge, then no, you're
not missing anything.

> 
> >
> >Is that possible? Is it useful? Is it already in practice?
> This is good question... IMO:
> 1. Two host bridges can shared domain number if they are children of the
> same parent host bridge.
> 2. But I can not find good explanation for more than one domain per bridge.

Splitting a root bus into two or more "segments" ?

Best regards,
Liviu

> 
> Tomasz
> 
> 

-- 
-------------------
   .oooO
   (   )
    \ (  Oooo.
     \_) (   )
          ) /
         (_/

 One small step
   for me ...


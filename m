From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Nov 2014 11:30:11 +0000
Subject: Re: [RFC PATCH 00/16] Refine PCI host bridge scan interfaces
Message-Id: <20535707.3sA6NjSINh@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1463511.o4kE8TX3Bd@wuerfel> <546B2ACC.90304@huawei.com>
In-Reply-To: <546B2ACC.90304@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: linux-arm-kernel@lists.infradead.org, Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, Suravee.Suthikulpanit@amd.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, linuxppc-dev@lists.ozlabs.org

On Tuesday 18 November 2014 19:17:32 Yijing Wang wrote:
> On 2014/11/17 22:13, Arnd Bergmann wrote:
> > On Monday 17 November 2014 18:21:34 Yijing Wang wrote:
> >> This series is based Linux 3.18-rc1 and Lorenzo Pieralisi's
> >> arm PCI domain cleanup patches, link: 
> >> https://patchwork.ozlabs.org/patch/407585/
> >>
> >> Current pci scan interfaces like pci_scan_root_bus() and directly
> >> call pci_create_root_bus()/pci_scan_child_bus() lack flexiblity.
> >> Some platform infos like PCI domain and msi_chip have to be
> >> associated to PCI bus by some arch specific function.
> >> We want to make a generic pci_host_bridge, and make it hold
> >> the platform infos or hook. Then we could eliminate the lots
> >> of arch pci_domain_nr, also we could associate some platform 
> >> ops something like pci_get_msi_chip(struct pci_dev *dev)
> >> with pci_host_bridge to avoid introduce arch weak functions.
> >>
> >> This RFC version not for all platforms, just applied the new
> >> scan interface in x86/arm/powerpc/ia64, I will refresh other
> >> platforms after the core pci scan interfaces are ok.
> > 
> > I think overall this is a good direction to take, in particular
> > moving more things into struct pci_host_bridge so we can
> > slim down the architecture specific code.
> 
> Hi Arnd, thanks very much for your review and comments!
> 
> > 
> > I don't particularly like the way you use the 'pci_host_info'
> > to pass callback pointers and some of the generic information.
> > This duplicates some of the issues we are currently trying
> > to untangle in the arm32 code to make drivers easier to share
> > between architectures.
> 
> What arm32 code you are trying to untangle for example ?

We have a few problems that currently prevent us from using shared
drivers across arm32 and arm64:

- arm32 has an architecture-defined pci_sys_data structure, but
  we really want to have one that is defined by the host bridge driver
  and that is architecture independent. Some core functions depend
  on this structure at the moment, which Lorenzo is trying to
  undo

- The pci_common_init interface on arm32 doesn't work well on
  loadable drivers, it does not return an error, and it is built
  around the assumption that you probe all pci host bridges at
  the same time, while the standard Linux driver model assumes
  that you probe one at a time.

- The way we pass a temporary structure (hw_pci) with function pointers
  into the architecture code makes it relatively hard to follow
  how the initialization sequence works.
 
> Introduce pci_host_info here because I want to make the PCI scan interfaces
> simple to host drviers, host drivers only need to call one scan
> interface(pci_scan_host_bridge), but from your comments,
> The combination pci_create_host_bridge() + pci_scan_xx()
> seems to be more popular.

Yes, I think a simpler interface structure would be better than trying
to minimize the amount of code needed in drivers at the expense of
interface complexity.

> > As a general approach, I'd rather see generic helper functions
> > being exported by the PCI core that a driver may or may not
> > call. 
> > The way you split the interface between things that happen
> > before scanning the buses (pci_create_host_bridge) and
> > the actual scanning (__pci_create_root_bus, pci_scan_child_bus)
> > seems very helpful and I think we can expand that concept further:
> > 
> > - The normal pci_create_host_bridge() function can contain
> >   all of the DT scanning functions (finding bus/mem/io resources, 
> >   finding the msi-parent), while drivers that don't depend on DT
> >   for this information can call the same function and fill the
> >   same things after they have the pci_host_bridge pointer.
> > 
> > - If a driver needs to set up mapping windows, it can do that after
> >   calling pci_create_host_bridge(). E.g. all the dw_pcie glue drivers
> >   can call a dw_pcie_setup_windows() function that takes the resources
> >   out of the pci_host_bridge pointer before the bus is scanned.
> > 
> > - The ACPI code can have a completely different way of creating
> >   a struct pci_host_bridge, which is also passed into the same
> >   bus scanning functions, but doesn't have to come from
> >   pci_create_host_bridge.
> 
> I hope platforms with ACPI or DT could both use pci_create_host_bridge().
> Why we need to use two different ways to process it ?

These are completely different use cases:

a) For DT, we want loadable device drivers that start by probing a host
   bridge device which was added through the DT platform code. The
   driver is self-contained, and eventually we want to be able to unload
   it. We have lots of different per-soc drivers that require different
   quirks

b) For ACPI, the interface is defined in the ACPI spec across architectures
   and SoCs, we don't have host bridge drivers and the code that initializes
   the PCI is required early during boot and called from architecture
   code. There is no parent device, as ACPI sees PCI as a fundamental building
   block by itself, and there are no drivers because the firmware does
   the initial hardware setup, so we only have to access the config space.

	Arnd

From: Liviu Dudau <liviu@dudau.co.uk>
Date: Mon, 29 Sep 2014 09:26:00 +0000
Subject: Re: [PATCH v2 00/22] Use MSI chip framework to configure MSI/MSI-X in all platforms
Message-Id: <20140929092600.GA15854@bart.dudau.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
 <20140925074235.GN12423@ulmo>
 <20140925144855.GB31157@bart.dudau.co.uk>
 <20140925164937.GB30382@ulmo>
 <5424E09F.50701@huawei.com>
 <20140926085030.GE31157@bart.dudau.co.uk>
 <54276F6C.5010705@huawei.com>
 <20140928112144.GA4671@bart.dudau.co.uk>
 <5428B971.50101@huawei.com>
In-Reply-To: <5428B971.50101@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Thierry Reding <thierry.reding@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On Mon, Sep 29, 2014 at 09:44:17AM +0800, Yijing Wang wrote:
> On 2014/9/28 19:21, Liviu Dudau wrote:
> > On Sun, Sep 28, 2014 at 10:16:12AM +0800, Yijing Wang wrote:
> >>>>>> What I would like to see is a way of creating the pci_host_bridge structure outside
> >>>>>> the pci_create_root_bus(). That would then allow us to pass this sort of platform
> >>>>>> details like associated msi_chip into the host bridge and the child busses will
> >>>>>> have an easy way of finding the information needed by finding the root bus and then
> >>>>>> the host bridge structure. Then the generic pci_scan_root_bus() can be used by (mostly)
> >>>>>> everyone and the drivers can remove their kludges that try to work around the
> >>>>>> current limitations.
> >>>>
> >>>> So I think maybe save msi chip in PCI arch sysdata is a good candidate.
> >>>
> >>> Except that arch sysdata at the moment is an opaque pointer. I am all in favour in
> >>> changing the type of sysdata from void* into pci_host_bridge* and arches can wrap their old
> >>> sysdata around the pci_host_bridge*.
> >>
> >> I inspected every arch and found there are almost no common stuff,
> > 
> > I will disagree here. Most (all?) of the structures that are passed as sysdata argument to
> 
> Most.
> 
> > pci_create_root_bus() or pci_scan_root_bus() have a set of resources for storing the MEM and
> > IO ranges, which struct pci_host_bridge already has. So that can be factored out of the
> > arch code. Same for pci_domain_nr. Then there are some variables that are used for communication
> > with the platform code due to convoluted way(s) in which PCI code gets instantiated.
> 
> Yes, currently some archs store MEM and IO resource in pci sysdata, and others not, move the MEM and IO
> resource to pci_host_bride could make code become simple, we can clean up the resource list argument in
> pci scan functions.
> 
> > 
> > What I am arguing here is not that the arch equivalent of pci_host_bridge structure is already
> > common, but that by moving the members that are common out of arch sysdata into pci_host_bridge
> > we will have more commonality and it will be easier to re-factor the code.
> 
> Now, I got it, thanks!
> 
> > 
> >> and generic data struct should
> >> be created in generic PCI code.
> > 
> > Not necessarily. What I have in mind is something like this:
> 
> This is a good idea, what I'm worried is this series is already large, so I think we need to post
> another series to do it.

I wasn't asking to do it here, I was just offering a suggestion (and sharing some experience) when
it comes to handling msi chip in an arch independent way.

> 
> 
> > 
> >  - drivers/pci/ exports pci_init_host_bridge() that does the initialisation of bridge->windows
> >    and anything else that is needed (like find_pci_host_bridge() function).
> >  - arch code does:
> > 
> > 	struct pci_controller {
> > 		struct pci_host_bridge bridge;
> > 		.....
> > 	};
> > 
> > 	#define to_pci_controller(bridge)	container_of(bridge, struct pci_controller, bridge)
> > 
> > 	static inline struct pci_controller *get_host_controller(const struct pci_bus *bus)
> > 	{
> > 		struct pci_host_bridge *bridge = find_pci_host_bridge(bus);
> > 		if (bridge)
> > 			return to_pci_controller(bridge);
> > 
> > 		return NULL;
> > 	}
> > 
> > 	int arch_pci_init(....)
> > 	{
> > 		struct pci_controller *hose;
> > 		....
> > 		hose = kzalloc(sizeof(*hose), GFP_KERNEL);
> > 		pci_init_host_bridge(&hose->bridge);
> > 		....
> > 		pci_scan_root_bus(...., &hose->bridge, &resources);
> > 		....
> > 		return 0;
> > 	}
> > 
> > Then finding the right structure will be easy.
> > 
> >> Another, I don't like associate msi chip and every PCI device, further more,
> >> almost all platforms except arm have only one MSI controller, and currently, PCI enumerating code doesn't need
> >> to know the MSI chip details, like for legacy IRQ, PCI device doesn't need to know which IRQ controller they
> >> should deliver IRQ to. I would think more about it, and hope other PCI guys can give some comments, especially from Bjorn.
> >>
> > 
> > I wasn't suggesing to associate an msi chip with every PCI device, but with the pci_host_bridge.
> > I don't expect a host bridge to have more than one msi chip, so that should be OK. Also, I'm
> > thinking that getting the associated msi chip should be some sort of pci_host_bridge ops function,
> > and for arches that don't care about MSI it doesn't get implemented.
> 
> Currently, a property "msi-parent" was introduced in arm, and all msi chip integrated in irq chip controller will
> be added to of_pci_msi_chip_list. PCI host driver find the match msi chip by its of_node.

OK. But as you might have seen that still implies open coding a separate version of pci_scan_root_bus().

Best regards,
Liviu

> 
> Thanks!
> Yijing.
> 
> > 
> > Best regards,
> > Liviu
> > 
> >  
> >> Thanks!
> >> Yijing.
> >>
> >>>
> >>> Best regards,
> >>> Liviu
> >>>
> >>>>
> >>>>>
> >>>>> I think both issues are orthogonal. Last time I checked a lot of work
> >>>>> was still necessary to unify host bridges enough so that it could be
> >>>>> shared across architectures. But perhaps some of that work has
> >>>>> happened in the meantime.
> >>>>>
> >>>>> But like I said, when you create the root bus, you can easily attach the
> >>>>> MSI chip to it.
> >>>>>
> >>>>> Thierry
> >>>>>
> >>>>
> >>>>
> >>>> -- 
> >>>> Thanks!
> >>>> Yijing
> >>>>
> >>>>
> >>>
> >>
> >>
> >> -- 
> >> Thanks!
> >> Yijing
> >>
> >>
> > 
> 
> 
> -- 
> Thanks!
> Yijing
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


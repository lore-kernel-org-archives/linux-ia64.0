From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Date: Tue, 15 Mar 2016 11:31:13 +0000
Subject: Re: [PATCH v2] PCI: ACPI: IA64: fix IO port generic range check
Message-Id: <20160315113113.GA10786@red-moon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1455212827-9382-1-git-send-email-lorenzo.pieralisi@arm.com>
 <20160308222125.GG27132@localhost>
 <CAJZ5v0gnDnF_4z_mtZp+Tq8-V3FgG6p7kMykqtVA+s44ukkuaA@mail.gmail.com>
 <20160309053332.GA22228@localhost>
 <20160309071406.GA19555@red-moon>
 <20160309153556.GA14873@localhost>
 <20160310074236.GA20478@red-moon>
 <20160314145322.GE6629@red-moon>
 <20160314192708.GB16621@localhost>
In-Reply-To: <20160314192708.GB16621@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Tomasz Nowicki <tn@semihalf.com>, Mark Salter <msalter@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Mon, Mar 14, 2016 at 02:27:08PM -0500, Bjorn Helgaas wrote:
> On Mon, Mar 14, 2016 at 02:53:22PM +0000, Lorenzo Pieralisi wrote:

[...]

> > Even if we do that, call to acpi_pci_root_validate_resources() for
> > IO space is wrong on IA64, we are comparing an IO resource against
> > ioport_resource there, but the Linux IO port space for the host
> > bridge is created in IA64 pci_acpi_root_prepare_resources() with
> > the call to add_io_space() which happens *after* the sequence above
> > is executed.
> > 
> > On IA64:
> > 
> > pci_acpi_root_prepare_resources()
> >  -> acpi_pci_probe_root_resources()
> >     -> acpi_dev_get_resources()
> >     -> acpi_pci_root_validate_resources()
> >  -> add_io_space() # this is where the Linux IO port space for the bridge is
> >                      created and that's when we can validate the IO
> > 		     resource against ioport_resource
> > 
> > I have no experience/knowledge of IA64 systems so I may be totally wrong,
> > I just want to understand.
> > 
> > Comments welcome, Hanjun proved my understanding by testing on IA64 and
> > current mainline just does not work (see commit log for failure messages),
> > feedback from IA64 people is really needed here, we have to get this fixed
> > please (and through that fix, getting it to work on ARM64 too).
> 
> I/O port translations makes my head hurt, but I think you're right.
> 
> The raw I/O resources from ACPI _CRS are definitely different from the
> Linux ioport spaces constructed by add_io_space(), so we shouldn't
> compare the two.
> 
> If we need to validate the raw I/O ports from _CRS, I suppose in
> theory we should be able to check that they're contained in the raw
> I/O port range of an upstream window.
> 
> I think the problem is that 3772aea7d6f3 started applying the
> x86-specific "[0-0xffff]" restriction to all arches, so if you want to 
> back that out so it applies only on x86 (but to all devices, not just
> PNP0A03), I think that would make sense.

I noticed there is already an X86 specific check in:

drivers/acpi/resource.c (ie valid_IRQ)

I can add something like code below there and be done with it:

#ifdef CONFIG_X86
static inline bool io_space_valid(struct resource *res)
{
	return res->end < 0x10003;
}
#else
static inline bool io_space_valid(struct resource *res) { return true; }
#endif

if Rafael is ok with that. Whatever I do requires an arch specific hook
(empty/always-true on !CONFIG_X86) to be called from
acpi_dev_ioresource_flags(), otherwise removing that check really becomes
a minefield.

Other solution is reverting back to not using acpi_dev_get_resources()
on IA64 and ARM64 which defeats the whole purpose of Jiang's consolidation,
so I won't go there.

Next step is removing (or refactoring) acpi_pci_root_validate_resources()
for IORESOURCE_IO from acpi_pci_probe_root_resources(), it is a bogus check
as our discussion above highlighted and does not work on ARM64 (it
probably does on IA64 since IO_SPACE_LIMIT = 0xffffffffffffffffUL, but
that's conceptually wrong regardless).


Thanks,
Lorenzo

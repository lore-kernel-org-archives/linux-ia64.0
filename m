From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Date: Mon, 14 Mar 2016 14:53:22 +0000
Subject: Re: [PATCH v2] PCI: ACPI: IA64: fix IO port generic range check
Message-Id: <20160314145322.GE6629@red-moon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1455212827-9382-1-git-send-email-lorenzo.pieralisi@arm.com>
 <20160308222125.GG27132@localhost>
 <CAJZ5v0gnDnF_4z_mtZp+Tq8-V3FgG6p7kMykqtVA+s44ukkuaA@mail.gmail.com>
 <20160309053332.GA22228@localhost>
 <20160309071406.GA19555@red-moon>
 <20160309153556.GA14873@localhost>
 <20160310074236.GA20478@red-moon>
In-Reply-To: <20160310074236.GA20478@red-moon>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Tomasz Nowicki <tn@semihalf.com>, Mark Salter <msalter@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Thu, Mar 10, 2016 at 07:42:36AM +0000, Lorenzo Pieralisi wrote:

[...]

> > > We can't do that, it may work on IA64 but the ioport_resource is a
> > > chunk of address space on IA64/ARM64 that has nothing to do with
> > > the physical address at which the root bridges decode IO space (which
> > > is what's contained in the resource).
> > 
> > I'm stumbling over "the physical address at which the root bridges
> > decode IO space (which is what's contained in the resource)".
> > 
> > x86 host bridges typically just forward CPU-generated I/O port
> > transactions to PCI with no address translation, so it sounds like
> > you're talking about ia64/ARM64 bridges that decode CPU MMIO space and
> > turn accesses into PCI I/O transactions.
> > 
> > If we start from a driver calling inb(), the driver supplies a Linux
> > ioport number "X".  On ia64 (and I assume ARM64 as well), inb()
> > performs an MMIO access to memory address "Y".  A host bridge consumes
> > that MMIO access and generates a corresponding PCI I/O transaction to
> > PCI ioport "Z".
> > 
> > It is indeed true that ioport_resource has nothing to do with memory
> > addresses like "Y".  But the driver (and this part of the ACPI
> > infrastructure) are dealing with ioport address "X", and that is
> > definitely in an IORESOURCE_IO struct resource.  The IORESOURCE_MEM_
> > struct resource that contains "Y" is internal to the host bridge
> > driver and invisible to the device driver that's using inb().
> 
> The problem is, that's the address like "Y" that are checked in
> acpi_dev_ioresource_flags() with current PCI initialization flow.
> 
> IO ports number "X" are created in (IA64) add_io_space() that is
> executed after acpi_pci_probe_root_resources() is called (see
> arch/ia64/pci/pci.c), that's the code that, IIUC, translates an
> IO resource containing a CPU physical address (which is the address
> that is ioremapped) to an IO resource containing a port number *and*
> a corresponding MEM resource.
> 
> The check that causes failures (>=0x10003) is carried out
> on the "raw" IO resource parsed from ACPI, not the one crafted
> in add_io_space().
> 
> The resource checked in acpi_dev_ioresource_flags() is created from
> ACPI IO descriptor and does contain CPU physical MMIO addresses,
> comparing it to a port number is bound to fail, they do NOT represent
> the same thing, happy be corrected.
> 
> That's the reason why currently IA64 IO space is not working, and
> this patch fixes it, please correct me if I am wrong.
> 
> I will write back next week with the commits sequence and logic that
> led to the current failure, sorry for not being able to respond
> more promptly and in a comprehensive way I need sometime to write up
> my understanding of the problem and commit logs, I will do that
> next week.

I had a further look and went through commit history and I think
my explanation above is correct, current code for IA64 PCI IO space
is wrong IMO and the failures started with:

commit 3772aea7d6f3 ("ia64/PCI/ACPI: Use common ACPI resource parsing
interface for host bridge")

because that's the commit that added IA64 PCI code to use
acpi_dev_get_resources(), let me add to that.

For the records, and for the same reason, let's imagine we can fix the
(>=0x10003) check in:

acpi_dev_ioresource_flags()

the code in acpi_pci_probe_root_resources() that checks the PCI IO
resources (ie acpi_pci_root_validate_resources()) is wrong, in that it
validates the PCI IO resources obtained from ACPI IO descriptors against
ioport_resource, and that's not correct, they do not represent the
same thing.

Code in acpi_dev_get_resources() walks the device (PCI host bridge in
this case) resources (ie _CRS) with acpi_dev_process_resource().

On IA64 IO space is memory mapped, therefore the CPU physical address
at which the PCI host bridge maps the IO space has to come from ACPI
IO descriptors.

IIUC, those descriptors are parsed through:

acpi_dev_resource_address_space()
acpi_dev_resource_ext_address_space()

which in turn call:

acpi_decode_space()

where the resource window is actually created, in particular the
acpi_address64_attribute value contains (on IA64, I verified with
ACPI spec working group through actual ACPI tables):

attr->minimum = PCI IO port min value
attr->translation_offset = offset to add to attr->minimum to obtain the
                           CPU physical address at which the PCI IO
			   bridge decodes IO space. Translation offset,
			   according to the ACPI specification has to
			   be used when resources on primary and
			   secondary sides of the PCI bridge are
			   different (IIUC secondary bus represents PCI
			   IO ports, primary bus CPU physical addresses
			   mapping IO ports in CPU physical address
			   space). This is the physical address that is
			   remapped in IA64 new_space(), to map the
			   bridge CPU physical address into the virtual
			   address space, and it has always been so, even
			   before 3772aea7d6f3.

Now, the resource window, in acpi_decode_space() is created as:

res->start = attr->minimum + attr->translation_offset;
res->end = attr->maximum + attr->translation_offset;

and that's the resource we have in acpi_dev_ioresource_flags(), if we
are comparing it against ioport_resource that's not correct since as I
already mentioned, they represent *different* things.

There is something we can do, which is, checking translation_type
in acpi_dev_ioresource_flags(), if it is = TypeTranslation (which
basically means that the IO space is MMIO) the >003 can be skipped,
but that's hackish (also because I am not sure IA64 platforms set
translation_type consistently in ACPI tables).

Even if we do that, call to acpi_pci_root_validate_resources() for
IO space is wrong on IA64, we are comparing an IO resource against
ioport_resource there, but the Linux IO port space for the host
bridge is created in IA64 pci_acpi_root_prepare_resources() with
the call to add_io_space() which happens *after* the sequence above
is executed.

On IA64:

pci_acpi_root_prepare_resources()
 -> acpi_pci_probe_root_resources()
    -> acpi_dev_get_resources()
    -> acpi_pci_root_validate_resources()
 -> add_io_space() # this is where the Linux IO port space for the bridge is
                     created and that's when we can validate the IO
		     resource against ioport_resource

I have no experience/knowledge of IA64 systems so I may be totally wrong,
I just want to understand.

Comments welcome, Hanjun proved my understanding by testing on IA64 and
current mainline just does not work (see commit log for failure messages),
feedback from IA64 people is really needed here, we have to get this fixed
please (and through that fix, getting it to work on ARM64 too).

Thanks,
Lorenzo

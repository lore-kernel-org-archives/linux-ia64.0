From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Date: Thu, 10 Mar 2016 07:42:36 +0000
Subject: Re: [PATCH v2] PCI: ACPI: IA64: fix IO port generic range check
Message-Id: <20160310074236.GA20478@red-moon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1455212827-9382-1-git-send-email-lorenzo.pieralisi@arm.com>
 <20160308222125.GG27132@localhost>
 <CAJZ5v0gnDnF_4z_mtZp+Tq8-V3FgG6p7kMykqtVA+s44ukkuaA@mail.gmail.com>
 <20160309053332.GA22228@localhost>
 <20160309071406.GA19555@red-moon>
 <20160309153556.GA14873@localhost>
In-Reply-To: <20160309153556.GA14873@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Tomasz Nowicki <tn@semihalf.com>, Mark Salter <msalter@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Wed, Mar 09, 2016 at 09:35:56AM -0600, Bjorn Helgaas wrote:
> On Wed, Mar 09, 2016 at 07:14:06AM +0000, Lorenzo Pieralisi wrote:
> > On Tue, Mar 08, 2016 at 11:33:32PM -0600, Bjorn Helgaas wrote:
> 
> > > Maybe acpi_dev_ioresource_flags() should instead check res->end
> > > against ioport_resource.end, as we already do in
> > > acpi_pci_root_validate_resources()?  Each arch already sets its own
> > > ioport_resource.end using IO_SPACE_LIMIT:
> > > 
> > >   arch/x86/include/asm/io.h   #define IO_SPACE_LIMIT 0xffff
> > >   arch/ia64/include/asm/io.h  #define IO_SPACE_LIMIT 0xffffffffffffffffUL
> 
> I suspect we're saying the same thing with slightly different words,
> so I apologize if I'm beating a dead horse.
> 
> ioport_resource defines the universe of Linux ioport space.  Every
> IORESOURCE_IO struct resource must be contained in ioport_resource.
> Such a resource contains Linux ioport numbers, i.e., things that could
> appear in /proc/ioports and could be passed as an argument to
> request_region() and the inb()/outb() functions.

That's agreed but that's not where the problem is on IA64/ARM64 IO
ACPI descriptors parsing.

> > We can't do that, it may work on IA64 but the ioport_resource is a
> > chunk of address space on IA64/ARM64 that has nothing to do with
> > the physical address at which the root bridges decode IO space (which
> > is what's contained in the resource).
> 
> I'm stumbling over "the physical address at which the root bridges
> decode IO space (which is what's contained in the resource)".
> 
> x86 host bridges typically just forward CPU-generated I/O port
> transactions to PCI with no address translation, so it sounds like
> you're talking about ia64/ARM64 bridges that decode CPU MMIO space and
> turn accesses into PCI I/O transactions.  
> 
> If we start from a driver calling inb(), the driver supplies a Linux
> ioport number "X".  On ia64 (and I assume ARM64 as well), inb()
> performs an MMIO access to memory address "Y".  A host bridge consumes
> that MMIO access and generates a corresponding PCI I/O transaction to
> PCI ioport "Z".
> 
> It is indeed true that ioport_resource has nothing to do with memory
> addresses like "Y".  But the driver (and this part of the ACPI
> infrastructure) are dealing with ioport address "X", and that is
> definitely in an IORESOURCE_IO struct resource.  The IORESOURCE_MEM_
> struct resource that contains "Y" is internal to the host bridge
> driver and invisible to the device driver that's using inb().

The problem is, that's the address like "Y" that are checked in
acpi_dev_ioresource_flags() with current PCI initialization flow.

IO ports number "X" are created in (IA64) add_io_space() that is
executed after acpi_pci_probe_root_resources() is called (see
arch/ia64/pci/pci.c), that's the code that, IIUC, translates an
IO resource containing a CPU physical address (which is the address
that is ioremapped) to an IO resource containing a port number *and*
a corresponding MEM resource.

The check that causes failures (>=0x10003) is carried out
on the "raw" IO resource parsed from ACPI, not the one crafted
in add_io_space().

The resource checked in acpi_dev_ioresource_flags() is created from
ACPI IO descriptor and does contain CPU physical MMIO addresses,
comparing it to a port number is bound to fail, they do NOT represent
the same thing, happy be corrected.

That's the reason why currently IA64 IO space is not working, and
this patch fixes it, please correct me if I am wrong.

I will write back next week with the commits sequence and logic that
led to the current failure, sorry for not being able to respond
more promptly and in a comprehensive way I need sometime to write up
my understanding of the problem and commit logs, I will do that
next week.

Thanks,
Lorenzo

> 
> For example, you could have something like this (with made-up
> addresses):
> 
>   [io  0x0000-0xffff]              # Linux ioport space
>   [mem 0x100000000-0x10000ffff]    # MMIO space consumed by host bridge
>   [bus 0x0000-0xffff]              # PCI bus I/O transaction space
> 
>   [io  0x10000-0x1ffff]            # Linux ioport space ("X")
>   [mem 0x200000000-0x20000ffff]    # MMIO space consumed by host bridge ("Y")
>   [bus 0x0000-0xffff]              # PCI bus I/O transaction space ("Z")
> 
> Bjorn
> 

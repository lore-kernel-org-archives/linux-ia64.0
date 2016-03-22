From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Tue, 22 Mar 2016 14:42:58 +0000
Subject: Re: [PATCH v3] PCI: ACPI: IA64: fix IO port generic range check
Message-Id: <6828228.erfiER1Ahm@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1458558775-6242-1-git-send-email-lorenzo.pieralisi@arm.com> <CAJZ5v0gvB8fHzmgrnz2wOPdLakJyuRg0eQ65oo13LP0_PHRAbg@mail.gmail.com> <20160322130219.GB19418@localhost>
In-Reply-To: <20160322130219.GB19418@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <bhelgaas@google.com>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hanjun Guo <hanjun.guo@linaro.org>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Tomasz Nowicki <tn@semihalf.com>, Mark Salter <msalter@redhat.com>

On Tuesday, March 22, 2016 08:02:19 AM Bjorn Helgaas wrote:
> On Mon, Mar 21, 2016 at 01:42:01PM +0100, Rafael J. Wysocki wrote:
> > On Mon, Mar 21, 2016 at 12:12 PM, Lorenzo Pieralisi

[cut]

> > >
> > > Fixes: 3772aea7d6f3 ("ia64/PCI/ACPI: Use common ACPI resource parsing
> > > interface for host bridge")
> > > Signed-off-by: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
> > > Cc: Bjorn Helgaas <bhelgaas@google.com>
> > > Cc: Hanjun Guo <hanjun.guo@linaro.org>
> > > Cc: Jiang Liu <jiang.liu@linux.intel.com>
> > > Cc: Tony Luck <tony.luck@intel.com>
> > > Cc: Tomasz Nowicki <tn@semihalf.com>
> > > Cc: Mark Salter <msalter@redhat.com>
> > > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > > ---
> > > v2 -> v3
> > >
> > > - Moved IO resource check to generic ACPI resource code
> > > - Dropped Tested-by tags
> > > - Rebased against v4.5
> > >
> > > v2: https://marc.info/?l=linux-acpi&m5521271330332&w=2
> > >
> > > v1 -> v2
> > >
> > > - Updated commit log to report missing IO resources
> > > - Fixed function ioport_valid() comment 16k/64k typo
> > >
> > > v1: https://marc.info/?l=linux-acpi&m5432228025354&w=2
> > >
> > >  drivers/acpi/resource.c | 14 +++++++++++++-
> > >  1 file changed, 13 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/drivers/acpi/resource.c b/drivers/acpi/resource.c
> > > index d02fd53..56241eb 100644
> > > --- a/drivers/acpi/resource.c
> > > +++ b/drivers/acpi/resource.c
> > > @@ -27,8 +27,20 @@
> > >
> > >  #ifdef CONFIG_X86
> > >  #define valid_IRQ(i) (((i) != 0) && ((i) != 2))
> > > +static inline bool acpi_iospace_resource_valid(struct resource *res)
> > > +{
> > > +       /* On X86 IO space is limited to the [0 - 64K] IO port range */
> > > +       return res->end < 0x10003;
> > > +}
> > >  #else
> > >  #define valid_IRQ(i) (true)
> > > +/*
> > > + * ACPI IO descriptors on arches other than X86 contain MMIO CPU physical
> > > + * addresses mapping IO space in CPU physical address space, IO space
> > > + * resources can be placed anywhere in the 64-bit physical address space.
> > > + */
> > > +static inline bool
> > > +acpi_iospace_resource_valid(struct resource *res) { return true; }
> > >  #endif
> > >
> > >  static bool acpi_dev_resource_len_valid(u64 start, u64 end, u64 len, bool io)
> > > @@ -127,7 +139,7 @@ static void acpi_dev_ioresource_flags(struct resource *res, u64 len,
> > >         if (!acpi_dev_resource_len_valid(res->start, res->end, len, true))
> > >                 res->flags |= IORESOURCE_DISABLED | IORESOURCE_UNSET;
> > >
> > > -       if (res->end >= 0x10003)
> > > +       if (!acpi_iospace_resource_valid(res))
> > >                 res->flags |= IORESOURCE_DISABLED | IORESOURCE_UNSET;
> > >
> > >         if (io_decode = ACPI_DECODE_16)
> > > --
> > 
> > This is fine by me.
> > 
> > Bjorn?
> 
> Looks good to me.

OK, thanks!

May I take this as an ACK? :-)


From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 13 Mar 2015 14:26:08 +0000
Subject: Re: [PATCH v6 04/30] xen/PCI: Don't use deprecated function pci_scan_bus_parented()
Message-Id: <CAErSpo69ytCxBK5AD79Nz05wy=GwzcOGV7WkiKFxpLDH4wtJXw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <1425868467-9667-5-git-send-email-wangyijing@huawei.com> <20150311223211.GB1082@google.com>
 <55017CA5.2010502@huawei.com> <20150312193505.GB7346@google.com>
 <55024D35.6050509@huawei.com> <CAErSpo4T7f9PNVMLrQbCvW2a=HnRauQR2eBz6H69B7Q2=ELNWw@mail.gmail.com>
 <20150313140132.GH5378@l.oracle.com>
In-Reply-To: <20150313140132.GH5378@l.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Yijing Wang <wangyijing@huawei.com>, Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>

On Fri, Mar 13, 2015 at 9:01 AM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Fri, Mar 13, 2015 at 08:24:58AM -0500, Bjorn Helgaas wrote:
>> On Thu, Mar 12, 2015 at 9:36 PM, Yijing Wang <wangyijing@huawei.com> wrote:
>> >>>>> +  pci_add_resource(&resources, &ioport_resource);
>> >>>>> +  pci_add_resource(&resources, &iomem_resource);
>> >>>>> +  pci_add_resource(&resources, &busn_resource);
>> >>>>
>> >>>> Since I don't want to export busn_resource, you might have to allocate your
>> >>>> own struct resource for it here.  And, of course, figure out the details of
>> >>>> which PCI domain you're in and whether you need to share one struct
>> >>>> resource across several host bridges in the same domain.
>> >>>
>> >>> Allocate its own resource here is ok for me, as I mentioned in previous reply,
>> >>> so do we still need to add additional info to figure out which domain own the bus resource ?
>> >>
>> >> That's up to the caller.  Only the platform knows which bridges it wants to
>> >> have in the same domain.  In principle, every host bridge could be in its
>> >> own domain, since each bridge is the root of a unique PCI hierarchy.  But
>> >> some platforms have firmware that assumes otherwise.  I have no idea what
>> >> xen assumes.
>> >
>> > I'm not xen guy, so I don't know much about it, but because it call pci_scan_bus_parented()
>> > before, and in which busn_resource is always shared for different host bridges(same domain or not),
>> > I think add a static bus resource(0,255) should be safe, at least, it would not introduce new risk.
>> >
>> > Something like:
>> >
>> > diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
>> > index b1ffebe..a69e529 100644
>> > --- a/drivers/pci/xen-pcifront.c
>> > +++ b/drivers/pci/xen-pcifront.c
>> > @@ -446,9 +446,15 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
>> >                                  unsigned int domain, unsigned int bus)
>> >  {
>> >         struct pci_bus *b;
>> > +       LIST_HEAD(resources);
>> >         struct pcifront_sd *sd = NULL;
>> >         struct pci_bus_entry *bus_entry = NULL;
>> >         int err = 0;
>> > +       static struct resource busn_res = {
>> > +               .start = 0,
>> > +               .end = 255,
>> > +               .flags = IORESOURCE_BUS,
>> > +       };
>> >
>> >  #ifndef CONFIG_PCI_DOMAINS
>> >         if (domain != 0) {
>> > @@ -470,17 +476,21 @@ static int pcifront_scan_root(struct pcifront_device *pdev,
>> >                 err = -ENOMEM;
>> >                 goto err_out;
>> >         }
>> > +       pci_add_resource(&resources, &ioport_resource);
>> > +       pci_add_resource(&resources, &iomem_resource);
>> > +       pci_add_resource(&resources, &busn_res);
>> >         pcifront_init_sd(sd, domain, bus, pdev);
>> >
>> >         pci_lock_rescan_remove();
>> >
>> > -       b = pci_scan_bus_parented(&pdev->xdev->dev, bus,
>> > -                                 &pcifront_bus_ops, sd);
>> > +       b = pci_scan_root_bus(&pdev->xdev->dev, bus,
>> > +                                 &pcifront_bus_ops, sd, &resources);
>> >         if (!b) {
>> >
>> > Bjorn, what do you think about ?
>>
>> That seems OK to me.  Probably still wrong, but no worse than it was before.
>
> Interesting. The mechanism for PCI passthrough can either synthesize
> and PCI bus number starting at zero (so first device is always 0:0:0.0)
> or it can replicate the backend PCI topology. That means you
> could have segment values passed in, so: ab:ff:00.1). I've to admin
> I hadn't tried the 'physical' replication on an machine with
> domains (err, segments).
>
> Is there an git tree with this so I can just try it out?

git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git
pci/enumeration-yw6 has similar code (it exports the single
busn_resource and makes xen use it).  That should be functionally
identical to what v4.0-rc1 does.

Yijing hasn't posted the static busn_res proposal above yet, so I
don't have a branch with that in it.

Bjorn

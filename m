From: Liviu Dudau <Liviu.Dudau@arm.com>
Date: Wed, 19 Nov 2014 16:37:26 +0000
Subject: Re: [RFC PATCH 07/16] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <20141119163726.GW12037@e106497-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
 <1416219710-26088-8-git-send-email-wangyijing@huawei.com>
 <20141118153020.GL12037@e106497-lin.cambridge.arm.com>
 <546BF59C.8060203@huawei.com>
In-Reply-To: <546BF59C.8060203@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "huxinwei@huawei.com" <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>

On Wed, Nov 19, 2014 at 01:42:52AM +0000, Yijing Wang wrote:
> On 2014/11/18 23:30, Liviu Dudau wrote:
> > On Mon, Nov 17, 2014 at 10:21:41AM +0000, Yijing Wang wrote:
> >> There are some common PCI infos like domain, msi_controller, these
> >> infos are saved in arch PCI sysdata, and lots arch specific functions
> >> like pci_domain_nr() and pcibios_msi_controller() required.
> >> We could separate pci_host_bridge creation out of pci_create_root_bus(),
> >> then we could put the common infos in, then we could eliminate
> >> the arch specifc functions.
> >>
> >
> > Please Cc: Yinghai Lu and Jiang Liu on future versions.
> >
> > More comments on the conversion of pci_create_root_bus():
> 
> That's my mistake, will add CC Yinghai and Jiang in next version.
> 
> >
> >> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> >> ---
> ...
> >> +
> >> +static void pci_release_host_bridge_dev(struct device *dev)
> >> +{
> >> +       struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
> >> +
> >> +       if (bridge->release_fn)
> >> +               bridge->release_fn(bridge);
> >> +       pci_free_resource_list(&bridge->windows);
> >> +       kfree(bridge);
> >> +}
> >> +
> >> +struct pci_host_bridge *pci_create_host_bridge(
> >> +               struct device *parent, u32 db,
> >> +               struct pci_ops *ops, void *sysdata,
> >
> > I don't thinks it is worth moving the buses' pci_ops into pci_host_bridge. It
> > might be more useful to have pci_host_bridge specific ops here.
> 
> Because we want to create pci_host_bridge before pci root bus creation,
> so when we scan the root bus and child buses, we use pci_host_bridge as
> the only argument, and another pci_host_info will be addes in later patch,
> which one support carry the pci_host_bridge ops.

But pci_create_root_bus() already has a pci_ops argument, I don't see the reason
to drop that.

pci_create_host_bridge() can get pci_host_bridge ops while pci_create_root_bus() gets
the bus ops. For find out the MSI controller, the domain number and any other HB
specific stuff, you use the HB ops. For config R/W acceses you use bus ops.

> 
> >
> >> +               struct list_head *resources)
> >> +{
> >> +       int error;
> >> +       struct pci_bus *b;
> >> +       struct pci_host_bridge *host, *h;
> ...
> >> -struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
> >> -               struct pci_ops *ops, void *sysdata, struct list_head *resources)
> >> +struct pci_bus *__pci_create_root_bus(struct pci_host_bridge *bridge)
> >>  {
> >>         int error;
> >> -       struct pci_host_bridge *bridge;
> >>         struct pci_bus *b, *b2;
> >> -       struct pci_host_bridge_window *window, *n;
> >> +       struct pci_host_bridge_window *window;
> >>         struct resource *res;
> >>         resource_size_t offset;
> >>         char bus_addr[64];
> >>         char *fmt;
> >> -       u8      bus = PCI_BUSNUM(db);
> >> +       struct device *parent = bridge->dev.parent;
> >>
> >>         b = pci_alloc_bus(NULL);
> >>         if (!b)
> >>                 return NULL;
> >>
> >> -       b->sysdata = sysdata;
> >> -       b->ops = ops;
> >> -       b->number = b->busn_res.start = bus;
> >> +       b->sysdata = bridge->sysdata;
> >
> > I think bridge should be the b->sysdata here.
> 
> ? what's the meaning?

Currently, bus->sysdata holds a pointer to the arch/driver host bridge structure, as passed
in pci_create_root_bus(). If you agree with my idea of wrapping the host bridge driver
structure around the pci_host_bridge, then we will always have a way of retrieving that
information; but for backwards compatibility we could set bus->sysdata to be the bridge.
Then existing macros that convert sysdata to pci_controller can be reused after being
updated.

Best regards,
Liviu

> 
> >
> >> +       b->ops = bridge->ops;
> >
> > See comment above why I don't think this is necessary.
> >
> >> +       b->number = b->busn_res.start = bridge->busnum;
> >>         pci_bus_assign_domain_nr(b, parent);
> >> -       b2 = pci_find_bus(pci_domain_nr(b), bus);
> >> +       bridge->domain = pci_domain_nr(b);
> >
> > Do you really want to overwrite the bridge's domain with the one from a bus that
> > could possibly be rejected a couple of lines further down?
> >
> > As an asside: if we are doing the split of pci_host_bridge from root bus creation
> > it is worth in my opinion to move the domain setup in pci_create_host_bridge()
> > and stop fiddling with it here.
> 
> 
> Hi Liviu, these lines just temporary, I will remove it after all host drivers
> save its domain in pci_host_bridge.
> 
> 
> >
> > Otherwise it looks to me like you are heading in the right direction.
> 
> Thanks!
> Yijing.
> 
> >
> > Best regards,
> > Liviu
> >
> >> +       b2 = pci_find_bus(pci_domain_nr(b), bridge->busnum);
> >>         if (b2) {
> >>                 /* If we already got to this bus through a different bridge, ignore it */
> >>                 dev_dbg(&b2->dev, "bus already known\n");
> >>                 goto err_out;
> >>         }
> >>
> >> -       bridge = pci_alloc_host_bridge(b);
> >> -       if (!bridge)
> >> -               goto err_out;
> >> -
> >> -       bridge->dev.parent = parent;
> >> -       bridge->dev.release = pci_release_host_bridge_dev;
> >> -       dev_set_name(&bridge->dev, "pci%04x:%02x", pci_domain_nr(b), bus);
> >> -       error = pcibios_root_bridge_prepare(bridge);
> >> -       if (error) {
> >> -               kfree(bridge);
> >> -               goto err_out;
> >> -       }
> >> -
> >> -       error = device_register(&bridge->dev);
> >> -       if (error) {
> >> -               put_device(&bridge->dev);
> >> -               goto err_out;
> >> -       }
> >>         b->bridge = get_device(&bridge->dev);
> >>         device_enable_async_suspend(b->bridge);
> >>         pci_set_bus_of_node(b);
> >> @@ -1950,7 +1899,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
> >>
> >>         b->dev.class = &pcibus_class;
> >>         b->dev.parent = b->bridge;
> >> -       dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), bus);
> >> +       dev_set_name(&b->dev, "%04x:%02x", pci_domain_nr(b), b->number);
> >>         error = device_register(&b->dev);
> >>         if (error)
> >>                 goto class_dev_reg_err;
> >> @@ -1966,12 +1915,11 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
> >>                 printk(KERN_INFO "PCI host bridge to bus %s\n", dev_name(&b->dev));
> >>
> >>         /* Add initial resources to the bus */
> >> -       list_for_each_entry_safe(window, n, resources, list) {
> >> -               list_move_tail(&window->list, &bridge->windows);
> >> +       list_for_each_entry(window, &bridge->windows, list) {
> >>                 res = window->res;
> >>                 offset = window->offset;
> >>                 if (res->flags & IORESOURCE_BUS)
> >> -                       pci_bus_insert_busn_res(b, bus, res->end);
> >> +                       pci_bus_insert_busn_res(b, b->number, res->end);
> >>                 else
> >>                         pci_bus_add_resource(b, res, 0);
> >>                 if (offset) {
> >> @@ -2001,6 +1949,25 @@ err_out:
> >>         return NULL;
> >>  }
> >>
> >> +struct pci_bus *pci_create_root_bus(struct device *parent, u32 bus,
> >> +               struct pci_ops *ops, void *sysdata, struct list_head *resources)
> >> +{
> >> +       struct pci_host_bridge *host;
> >> +
> >> +       host = pci_create_host_bridge(parent, bus, ops,
> >> +                       sysdata ,resources);
> >> +       if (!host)
> >> +               return NULL;
> >> +
> >> +       host->bus = __pci_create_root_bus(host);
> >> +       if (!host->bus) {
> >> +               pci_free_host_bridge(host);
> >> +               return NULL;
> >> +       }
> >> +
> >> +       return host->bus;
> >> +}
> >> +
> >>  int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int bus_max)
> >>  {
> >>         struct resource *res = &b->busn_res;
> >> @@ -2069,40 +2036,37 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
> >>  {
> >>         struct pci_host_bridge_window *window;
> >>         bool found = false;
> >> -       struct pci_bus *b;
> >> -       LIST_HEAD(default_res);
> >> +       struct pci_host_bridge *host;
> >>         int max;
> >>
> >> -       if (!resources) {
> >> -               pci_add_resource(&default_res, &ioport_resource);
> >> -               pci_add_resource(&default_res, &iomem_resource);
> >> -               pci_add_resource(&default_res, &busn_resource);
> >> -       } else {
> >> -               list_for_each_entry(window, resources, list)
> >> -                       if (window->res->flags & IORESOURCE_BUS) {
> >> -                               found = true;
> >> -                               break;
> >> -                       }
> >> -       }
> >> +       host = pci_create_host_bridge(parent, db, ops, sysdata, resources);
> >> +       if (!host)
> >> +               return NULL;
> >>
> >> -       b = pci_create_root_bus(parent, db, ops, sysdata,
> >> -                       resources ? resources : &default_res);
> >> -       if (!b)
> >> +       list_for_each_entry(window, &host->windows, list)
> >> +               if (window->res->flags & IORESOURCE_BUS) {
> >> +                       found = true;
> >> +                       break;
> >> +               }
> >> +
> >> +       host->bus = __pci_create_root_bus(host);
> >> +       if (!host->bus) {
> >> +               pci_free_host_bridge(host);
> >>                 return NULL;
> >> +       }
> >>
> >>         if (!found) {
> >> -               dev_info(&b->dev,
> >> +               dev_info(&host->bus->dev,
> >>                  "No busn resource found for root bus, will use [bus %02x-ff]\n",
> >>                         PCI_BUSNUM(db));
> >> -               pci_bus_insert_busn_res(b, PCI_BUSNUM(db), 255);
> >> +               pci_bus_insert_busn_res(host->bus, PCI_BUSNUM(db), 255);
> >>         }
> >>
> >> -       max = pci_scan_child_bus(b);
> >> -
> >> +       max = pci_scan_child_bus(host->bus);
> >>         if (!found)
> >> -               pci_bus_update_busn_res_end(b, max);
> >> +               pci_bus_update_busn_res_end(host->bus, max);
> >>
> >> -       return b;
> >> +       return host->bus;
> >>  }
> >>  EXPORT_SYMBOL(pci_scan_root_bus);
> >>
> >> diff --git a/include/linux/pci.h b/include/linux/pci.h
> >> index 8b11b38..daa7f40 100644
> >> --- a/include/linux/pci.h
> >> +++ b/include/linux/pci.h
> >> @@ -402,7 +402,12 @@ struct pci_host_bridge_window {
> >>  struct pci_host_bridge {
> >>         struct device dev;
> >>         struct pci_bus *bus;            /* root bus */
> >> +       struct list_head list;
> >>         struct list_head windows;       /* pci_host_bridge_windows */
> >> +       int busnum;
> >> +       int domain;
> >> +       void *sysdata;
> >> +       struct pci_ops *ops;
> >>         void (*release_fn)(struct pci_host_bridge *);
> >>         void *release_data;
> >>  };
> >> @@ -413,7 +418,9 @@ void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
> >>                      void *release_data);
> >>
> >>  int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge);
> >> -
> >> +struct pci_host_bridge *pci_create_host_bridge(
> >> +               struct device *parent, u32 db, struct pci_ops *ops,
> >> +               void *sys, struct list_head *resources);
> >>  /*
> >>   * The first PCI_BRIDGE_RESOURCE_NUM PCI bus resources (those that correspond
> >>   * to P2P or CardBus bridge windows) go in a table.  Additional ones (for
> >> @@ -770,6 +777,8 @@ void pci_bus_add_devices(const struct pci_bus *bus);
> >>  struct pci_bus *pci_create_root_bus(struct device *parent, u32 bus,
> >>                                     struct pci_ops *ops, void *sysdata,
> >>                                     struct list_head *resources);
> >> +struct pci_bus *__pci_create_root_bus(struct pci_host_bridge *host);
> >> +void pci_free_host_bridge(struct pci_host_bridge *host);
> >>  int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
> >>  int pci_bus_update_busn_res_end(struct pci_bus *b, int busmax);
> >>  void pci_bus_release_busn_res(struct pci_bus *b);
> >> --
> >> 1.7.1
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >
> 
> 
> --
> Thanks!
> Yijing
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
==========
| I would like to |
| fix the world,  |
| but they're not |
| giving me the   |
 \ source code!  /
  ---------------
    ¯\_(ツ)_/¯


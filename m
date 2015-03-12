From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 12 Mar 2015 19:49:27 +0000
Subject: Re: [PATCH v6 06/30] PCI: Combine PCI domain and bus number in u32 arg
Message-Id: <20150312194927.GC7346@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <1425868467-9667-7-git-send-email-wangyijing@huawei.com>
 <20150312012946.GA10949@google.com>
 <55018330.5050002@huawei.com>
In-Reply-To: <55018330.5050002@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Thu, Mar 12, 2015 at 08:14:40PM +0800, Yijing Wang wrote:
> On 2015/3/12 9:29, Bjorn Helgaas wrote:
> > On Mon, Mar 09, 2015 at 10:34:03AM +0800, Yijing Wang wrote:
> >> Currently, we use int type for bus number in
> >> pci_create_root_bus(), pci_scan_root_bus() and
> >> pci_scan_bus_legacy. Because PCI bus number
> >> always <= 255, so we could change the bus number
> >> argument type to u32, and combine PCI domain and
> >> bus number in one. 
> > 
> > This makes no sense.  Or rather, it only states the obvious: an 8-bit value
> > and a 16-bit value will both fit in a 32-bit value.  But it doesn't say
> > *why* you think it's a good idea to pass a single value that contains both
> > domain and bus numbers.  The obvious thing is to pass two separate values,
> > and you don't say why passing a single combined value is better.
> 
> Sorry for my poor description for this patch, I combined the domain and bus, because
> I think now we have too many args at pci_scan_root_bus() or other scan functions,
> 
> struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
> 		struct pci_ops *ops, void *sysdata, struct list_head *resources)
> 
> Now we have five args yet, plus the new introduced domain and pci_host_bridge_ops,
> it will become 7.
> 
> I thought introduced a new structure which contain the necessary info to scan root bus/ host bridge,
> 
> E.g
> 
> struct pci_scan_info {
> 	int bus;
> 	struct device *parent;
> 	struct pci_ops *ops;
> 	void *sysdata;
> 	struct list_head *resource;
> 	int domain;
> 	struct pci_host_bridge_ops;
> }
> 
> Do you like this one or keep it like now ?
> 
> pci_scan_root_bus(struct device *parent, int domain, int bus,
> 		struct pci_ops *ops, void *sysdata, struct list_head *resources, struct pci_host_bridge_ops *ops)

I don't think reducing the number of arguments is a good argument for
squashing some of them together.

I don't really want to add a structure like that because it adds management
complexity for all the callers because it contains per-bridge things (bus,
parent, domain, resource, sysdata).  Things like struct pci_ops and struct
pci_host_bridge_ops are much simpler because drivers can statically
allocate a single copy and use it for multiple devices.

I think it might make sense to put the struct pci_ops pointer inside struct
pci_host_bridge_ops.  That would get rid of one of the arguments.

You might also be able to get rid of the "bus" argument, since the caller
should be passing an IORESOURCE_BUS resource in the resource list, and
"bus" should be the same as res->start.

Bjorn

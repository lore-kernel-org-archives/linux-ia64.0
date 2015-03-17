From: Ian Campbell <ian.campbell@citrix.com>
Date: Tue, 17 Mar 2015 14:05:30 +0000
Subject: Re: [Xen-devel] [PATCH v6 07/30] PCI: Pass PCI domain number combined with root bus number
Message-Id: <1426601130.18247.238.camel@citrix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <1425868467-9667-8-git-send-email-wangyijing@huawei.com>
 <5507B88D.1020300@caviumnetworks.com>
In-Reply-To: <5507B88D.1020300@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Tue, 2015-03-17 at 10:45 +0530, Manish Jaggi wrote:
> On Monday 09 March 2015 08:04 AM, Yijing Wang wrote:
> > Now we could pass PCI domain combined with bus number
> > in u32 argu. Because in arm/arm64, PCI domain number
> > is assigned by pci_bus_assign_domain_nr(). So we leave
> > pci_scan_root_bus() and pci_create_root_bus() in arm/arm64
> > unchanged. A new function pci_host_assign_domain_nr()
> > will be introduced for arm/arm64 to assign domain number
> > in later patch.
> Hi,
> I think these changes might not be required. We have made very few 
> changes in the xen-pcifront to support PCI passthrough in arm64.
> As per xen architecture for a domU only a single pci virtual bus is 
> created and all passthrough devices are attached to it.

I guess you are only talking about the changes to xen-pcifront.c?
Otherwise you are ignoring the dom0 case which is exposed to the real
set of PCI root complexes and anyway I'm not sure how "not needed for
Xen domU" translates into not required, since it is clearly required for
other systems.

Strictly speaking the Xen pciif protocol does support multiple buses,
it's just that the tools, and perhaps kernels, have not yet felt any
need to actually make use of that.

There doesn't seem to be any harm in updating pcifront to follow this
generic API change.

Ian.


From: Greg KH <greg@kroah.com>
Date: Tue, 21 Dec 2004 21:44:42 +0000
Subject: Re: [PATCH] add legacy resources to sysfs
Message-Id: <20041221214442.GA10362@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412211247.44883.jbarnes@engr.sgi.com> <20041221212839.GF31261@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041221212839.GF31261@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, willy@debian.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bjorn Helgaas <bjorn.helgaas@hp.com>

On Tue, Dec 21, 2004 at 09:28:39PM +0000, Matthew Wilcox wrote:
> > === arch/ia64/sn/pci/pci_dma.c 1.2 vs edited ==> > +int sn_pci_get_legacy_mem(struct pci_bus *bus, unsigned long *addr)
> > +{
> > +	if (!SN_PCIBUS_BUSSOFT(bus))
> > +		return -ENODEV;
> > +
> > +	*addr = SN_PCIBUS_BUSSOFT(bus)->bs_legacy_mem | __IA64_UNCACHED_OFFSET;
> > +
> > +	return 0;
> > +}
> 
> int sn_pci_get_legacy_mem(struct pci_bus *bus)
> {
> 	if (!SN_PCIBUS_BUSSOFT(bus))
> 		return ERR_PTR(-ENODEV);

Huh?  A pointer doesn't fit into an int on all arches.  I think the
original was correct.

thanks,

greg k-h

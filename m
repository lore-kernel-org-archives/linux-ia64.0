From: Mark Maule <maule@sgi.com>
Date: Mon, 07 Feb 2005 16:22:14 +0000
Subject: Re: [PATCH 2.6.11-rc2 1/3] altix: pci dma abstraction
Message-Id: <Pine.SGI.3.96.1050207101332.29754669H-100000@daisy-e236.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213203.16671.94089.90028@attica.americas.sgi.com>
In-Reply-To: <20050204213203.16671.94089.90028@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Sun, Feb 06, 2005 at 04:28:10PM +0000, Matthew Wilcox wrote:

> On Fri, Feb 04, 2005 at 03:32:03PM -0600, Mark Maule wrote:
> > @@ -79,7 +78,7 @@
> >  {
> >  	void *cpuaddr;
> >  	unsigned long phys_addr;
> > -	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
> > +	struct pci_dev *pdev = to_pci_dev(dev);
> >  
> >  	BUG_ON(dev->bus != &pci_bus_type);
> >  
> > @@ -102,8 +101,7 @@
> >  	 * resources.
> >  	 */
> >  
> > -	*dma_handle = pcibr_dma_map(pcidev_info, phys_addr, size,
> > -				    SN_PCIDMA_CONSISTENT);
> > +	*dma_handle = (*SN_PCIDEV_BUSPROVIDER(pdev)->dma_map_consistent) (pdev, phys_addr, size);
> >  	if (!*dma_handle) {
> >  		printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
> >  		free_pages((unsigned long)cpuaddr, get_order(size));
> 
> I think this bit would be done better as ...
> 
> struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
> [...]
> 	*dma_handle = provider->dma_map_consistent(pdev, phys_addr, size);
> 
> Looks neater and reduces line length.

Agreed on the atyle comment.  Was originally done that way, but changed to
eliminiate the once-used local variable.

> 
> > +pcibr_dma_unmap(struct pci_dev *hwdev, dma_addr_t dma_handle, int direction)
> >  {
> > -	struct pcibus_info *pcibus_info = (struct pcibus_info *)pcidev_info->
> > -	    pdi_pcibus_info;
> > +	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(hwdev);
> > +	struct pcibus_info *pcibus_info > > +	    (struct pcibus_info *)pcidev_info->pdi_pcibus_info;
> 
> Why do you need to cast here?

The cast is necessary because pdi_pcibus_info is type struct pcibus_bussoft
which is a common struct header used by all sn pci providers
(e.g. pcibr and the new tioca) whereas struct pcibus_info is a
per-provider structure representing the pcibr provider (unfortunate naming).

I could use container_of() to make this more explicit if that's preferred:

attica$ bk diffs arch/ia64/sn/pci/pcibr/pcibr_dma.c
=== arch/ia64/sn/pci/pcibr/pcibr_dma.c 1.4 vs edited ==187c187,188
<           (struct pcibus_info *)pcidev_info->pdi_pcibus_info;
---
>               container_of(pcidev_info->pdi_pcibus_info,
>                            struct pcibus_info, pbi_buscommon);

Mark


From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 07 Feb 2005 10:09:05 +0000
Subject: Re: [PATCH 2.6.11-rc2 1/3] altix: pci dma abstraction
Message-Id: <20050207100905.GB11949@infradead.org>
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
> 	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
> [...]
> 	*dma_handle = provider->dma_map_consistent(pdev, phys_addr, size);
> 
> Looks neater and reduces line length.

Seconded.  It's the way we do it in Linux all over the place, too

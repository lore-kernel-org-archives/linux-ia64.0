From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 06 Feb 2005 16:28:10 +0000
Subject: Re: [PATCH 2.6.11-rc2 1/3] altix: pci dma abstraction
Message-Id: <20050206162810.GT20386@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213203.16671.94089.90028@attica.americas.sgi.com>
In-Reply-To: <20050204213203.16671.94089.90028@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 04, 2005 at 03:32:03PM -0600, Mark Maule wrote:
> @@ -79,7 +78,7 @@
>  {
>  	void *cpuaddr;
>  	unsigned long phys_addr;
> -	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(to_pci_dev(dev));
> +	struct pci_dev *pdev = to_pci_dev(dev);
>  
>  	BUG_ON(dev->bus != &pci_bus_type);
>  
> @@ -102,8 +101,7 @@
>  	 * resources.
>  	 */
>  
> -	*dma_handle = pcibr_dma_map(pcidev_info, phys_addr, size,
> -				    SN_PCIDMA_CONSISTENT);
> +	*dma_handle = (*SN_PCIDEV_BUSPROVIDER(pdev)->dma_map_consistent) (pdev, phys_addr, size);
>  	if (!*dma_handle) {
>  		printk(KERN_ERR "%s: out of ATEs\n", __FUNCTION__);
>  		free_pages((unsigned long)cpuaddr, get_order(size));

I think this bit would be done better as ...

	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
[...]
	*dma_handle = provider->dma_map_consistent(pdev, phys_addr, size);

Looks neater and reduces line length.

> +pcibr_dma_unmap(struct pci_dev *hwdev, dma_addr_t dma_handle, int direction)
>  {
> -	struct pcibus_info *pcibus_info = (struct pcibus_info *)pcidev_info->
> -	    pdi_pcibus_info;
> +	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(hwdev);
> +	struct pcibus_info *pcibus_info > +	    (struct pcibus_info *)pcidev_info->pdi_pcibus_info;

Why do you need to cast here?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 10 Jan 2005 21:21:56 +0000
Subject: Re: [patch 2/3] Replace pci_find_device with pci_get_device
Message-Id: <1105392116.29910.50.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050110194635.844AE1F203@trashy.coderock.org>
In-Reply-To: <20050110194635.844AE1F203@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-01-10 at 13:09 -0800, Jesse Barnes wrote:
> On Monday, January 10, 2005 11:46 am, domen@coderock.org wrote:
> > -  while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
> > +  while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
> >     acpi_pci_irq_enable(dev);
> 
> Shouldn't this be for_each_pci_dev(dev) acpi_pci_irq_enable(dev); instead?  
> Bjorn?

They're equivalent, right?  Looks OK to me either way.  I guess
if you switch to for_each_pci_dev(), you could switch the one
in sba_iommu.c, too.


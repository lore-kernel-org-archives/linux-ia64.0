From: Hanna Linder <hannal@us.ibm.com>
Date: Tue, 11 Jan 2005 00:23:50 +0000
Subject: Re: [patch 2/3] Replace pci_find_device with pci_get_device - sba_iommu.c
Message-Id: <178160000.1105403030@w-hlinder.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050110194635.844AE1F203@trashy.coderock.org>
In-Reply-To: <20050110194635.844AE1F203@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--On Monday, January 10, 2005 02:21:56 PM -0700 Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> On Mon, 2005-01-10 at 13:09 -0800, Jesse Barnes wrote:
>> On Monday, January 10, 2005 11:46 am, domen@coderock.org wrote:
>> > -  while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
>> > +  while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
>> >     acpi_pci_irq_enable(dev);
>> 
>> Shouldn't this be for_each_pci_dev(dev) acpi_pci_irq_enable(dev); instead?  
>> Bjorn?
> 
> They're equivalent, right?  Looks OK to me either way.  I guess
> if you switch to for_each_pci_dev(), you could switch the one
> in sba_iommu.c, too.

Here is the reroll of the sba_iommu.c patch to use for_each_pci_dev.

Signed-off-by: Hanna Linder <hannal@us.ibm.com>

diff -Nrup linux-2.6.10cln/arch/ia64/hp/common/sba_iommu.c linux-2.6.10p2/arch/ia64/hp/common/sba_iommu.c
--- linux-2.6.10cln/arch/ia64/hp/common/sba_iommu.c	2005-01-10 15:45:15.000000000 -0800
+++ linux-2.6.10p2/arch/ia64/hp/common/sba_iommu.c	2005-01-10 15:51:33.602913864 -0800
@@ -1557,7 +1557,7 @@ ioc_iova_init(struct ioc *ioc)
 	** We program the next pdir index after we stop w/ a key for
 	** the GART code to handshake on.
 	*/
-	while ((device = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, device)) != NULL)
+	for_each_pci_dev(device)	
 		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
 
 	if (agp_found && reserve_sba_gart) {


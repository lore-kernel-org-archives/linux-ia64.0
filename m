From: Hanna Linder <hannal@us.ibm.com>
Date: Tue, 11 Jan 2005 00:22:49 +0000
Subject: Re: [patch 2/3] Replace pci_find_device with pci_get_device - pci.c
Message-Id: <177680000.1105402969@w-hlinder.beaverton.ibm.com>
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


Ok. Here is the reroll of the original patch to us for_each_pci_dev:

Signed-off-by: Hanna Linder <hannal@us.ibm.com>

diff -Nrup linux-2.6.10cln/arch/ia64/pci/pci.c linux-2.6.10p/arch/ia64/pci/pci.c
--- linux-2.6.10cln/arch/ia64/pci/pci.c	2005-01-10 15:45:16.000000000 -0800
+++ linux-2.6.10p/arch/ia64/pci/pci.c	2005-01-10 15:54:35.564251536 -0800
@@ -154,7 +154,7 @@ extern acpi_status acpi_map_iosapic (acp
 		printk(KERN_INFO "** was specified.  If this was required to make a driver work,\n");
 		printk(KERN_INFO "** please email the output of \"lspci\" to bjorn.helgaas@hp.com\n");
 		printk(KERN_INFO "** so I can fix the driver.\n");
-		while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
+		for_each_pci_dev(dev)
 			acpi_pci_irq_enable(dev);
 	} else {
 		printk(KERN_INFO "** PCI interrupts are no longer routed automatically.  If this\n");




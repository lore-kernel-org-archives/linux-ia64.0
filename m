From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 16 May 2003 21:02:36 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705911@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David S Miller <davem@redhat.com> writes:

David> Anyways, now that I understand the problem, merely adding the
David> consistent_dma_mask attribute to the device struct will allow
David> drivers to indicate this capability just fine.  The driver
David> goes:

David> 	if (pci_set_consistent_dma_mask(pdev, ~(u64)0)) goto
David> probe_error;

David> and then the platform pci_alloc_consistent() can do whatever is
David> appropriate.

Hi Dave,

How does this patch look to you? It adds the generic code for setting
the mask, it will then be up to Colin to fix the SGI SN2 specific code
to honor it.

I also added a patch to the tg3 driver to set the mask as it seems to
work just dandy with 64 bit consistent addresses.

Tested on ia64, but I see no reason why it should fail elsewhere.

Cheers,
Jes

diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/drivers/net/tg3.c linux-2.5.69-pci/drivers/net/tg3.c
--- linux-2.5.69-030509-vanilla/drivers/net/tg3.c	Sun May  4 19:53:31 2003
+++ linux-2.5.69-pci/drivers/net/tg3.c	Fri May 16 15:42:55 2003
@@ -6743,6 +6743,12 @@
 	/* Configure DMA attributes. */
 	if (!pci_set_dma_mask(pdev, (u64) 0xffffffffffffffff)) {
 		pci_using_dac = 1;
+		if (pci_set_consistent_dma_mask(pdev,
+						(u64) 0xffffffffffffffff)) {
+			printk(KERN_ERR PFX "Unable to obtain 64 bit DMA "
+			       "for consistent allocations\n");
+			goto err_out_free_res;
+		}
 	} else {
 		err = pci_set_dma_mask(pdev, (u64) 0xffffffff);
 		if (err) {
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/drivers/pci/pci.c linux-2.5.69-pci/drivers/pci/pci.c
--- linux-2.5.69-030509-vanilla/drivers/pci/pci.c	Sun May  4 19:53:08 2003
+++ linux-2.5.69-pci/drivers/pci/pci.c	Fri May 16 15:43:44 2003
@@ -701,6 +701,17 @@
 	return 0;
 }
 
+int
+pci_set_consistent_dma_mask(struct pci_dev *dev, u64 mask)
+{
+	if (!pci_dma_supported(dev, mask))
+		return -EIO;
+
+	dev->consistent_dma_mask = mask;
+
+	return 0;
+}
+
 static int __devinit pci_init(void)
 {
 	struct pci_dev *dev;
@@ -751,6 +762,7 @@
 EXPORT_SYMBOL(pci_clear_mwi);
 EXPORT_SYMBOL(pci_set_dma_mask);
 EXPORT_SYMBOL(pci_dac_set_dma_mask);
+EXPORT_SYMBOL(pci_set_consistent_dma_mask);
 EXPORT_SYMBOL(pci_assign_resource);
 EXPORT_SYMBOL(pci_find_parent_resource);
 
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/drivers/pci/probe.c linux-2.5.69-pci/drivers/pci/probe.c
--- linux-2.5.69-030509-vanilla/drivers/pci/probe.c	Sun May  4 19:53:35 2003
+++ linux-2.5.69-pci/drivers/pci/probe.c	Fri May 16 15:44:40 2003
@@ -502,6 +502,7 @@
 	/* Assume 32-bit PCI; let 64-bit PCI cards (which are far rarer)
 	   set this higher, assuming the system even supports it.  */
 	dev->dma_mask = 0xffffffff;
+	dev->consistent_dma_mask = 0xffffffff;
 	if (pci_setup_device(dev) < 0) {
 		kfree(dev);
 		return NULL;
diff -urN -X /home/jes/exclude-linux linux-2.5.69-030509-vanilla/include/linux/pci.h linux-2.5.69-pci/include/linux/pci.h
--- linux-2.5.69-030509-vanilla/include/linux/pci.h	Sun May  4 19:53:14 2003
+++ linux-2.5.69-pci/include/linux/pci.h	Fri May 16 15:42:55 2003
@@ -390,6 +390,11 @@
 					   or supports 64-bit transfers.  */
 	struct list_head pools;		/* pci_pools tied to this device */
 
+	u64		consistent_dma_mask;/* Like dma_mask, but for
+					       pci_alloc_consistent mappings as
+					       not all hardware supports
+					       64 bit addresses for consistent
+					       allocations such descriptors. */
 	u32             current_state;  /* Current operating state. In ACPI-speak,
 					   this is D0-D3, D0 being fully functional,
 					   and D3 being off. */
@@ -614,6 +619,7 @@
 void pci_clear_mwi(struct pci_dev *dev);
 int pci_set_dma_mask(struct pci_dev *dev, u64 mask);
 int pci_dac_set_dma_mask(struct pci_dev *dev, u64 mask);
+int pci_set_consistent_dma_mask(struct pci_dev *dev, u64 mask);
 int pci_assign_resource(struct pci_dev *dev, int i);
 
 /* Power management related routines */


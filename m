From: Grant Grundler <grundler@parisc-linux.org>
Date: Sat, 14 Jan 2006 07:34:53 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <20060114073453.GA24259@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222171621.8240.71918.22618@lnx-maule.americas.sgi.com>
In-Reply-To: <20051222171621.8240.71918.22618@lnx-maule.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 12, 2006 at 09:17:09AM -0800, Greg KH wrote:
> -ENOCHANGELOGANDSIGNEDOFFBYLINE  :(

Clean up: move assignments outside of if() statements.
AFAICT, no functional change. Easier to read/understand.

Depends on "[PATCH 1/3] msi vector targeting abstractions"
by Mark Maule <maule@sgi.com>.
I expect one hunk to fail if applied against 2.6.15.

This is essentially Joe Perches' patch.
I've cleaned up the one instance added by Mark's patch.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

[ greg - If this has conflicts, please point me at the tree
  you'd like the diff against. ]

--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -110,9 +110,9 @@ static void set_msi_affinity(unsigned in
 	switch (entry->msi_attrib.type) {
 	case PCI_CAP_ID_MSI:
 	{
-		int pos;
+		int pos = pci_find_capability(entry->dev, PCI_CAP_ID_MSI);
 
-   		if (!(pos = pci_find_capability(entry->dev, PCI_CAP_ID_MSI)))
+		if (!pos)
 			return;
 
 		pci_read_config_dword(entry->dev, msi_upper_address_reg(pos),
@@ -336,9 +336,9 @@ static int assign_msi_vector(void)
 
 static int get_new_vector(void)
 {
-	int vector;
+	int vector = assign_msi_vector();
 
-	if ((vector = assign_msi_vector()) > 0)
+	if (vector > 0)
 		set_intr_gate(vector, interrupt[vector]);
 
 	return vector;
@@ -358,7 +358,8 @@ static int msi_init(void)
 		return status;
 	}
 
-	if ((status = msi_arch_init()) < 0) {
+	status = msi_arch_init();
+	if (status < 0) {
 		pci_msi_enable = 0;
 		printk(KERN_WARNING
 		       "PCI: MSI arch init failed.  MSI disabled.\n");
@@ -372,7 +373,8 @@ static int msi_init(void)
 		return status;
 	}
 
-	if ((status = msi_cache_init()) < 0) {
+	status = msi_cache_init();
+	if (status < 0) {
 		pci_msi_enable = 0;
 		printk(KERN_WARNING "PCI: MSI cache init failed\n");
 		return status;
@@ -526,10 +528,12 @@ static int msi_capability_init(struct pc
    	pos = pci_find_capability(dev, PCI_CAP_ID_MSI);
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
 	/* MSI Entry Initialization */
-	if (!(entry = alloc_msi_entry()))
+	entry = alloc_msi_entry();
+	if (!entry)
 		return -ENOMEM;
 
-	if ((vector = get_msi_vector(dev)) < 0) {
+	vector = get_msi_vector(dev);
+	if (vector < 0) {
 		kmem_cache_free(msi_cachep, entry);
 		return -EBUSY;
 	}
@@ -628,7 +632,8 @@ static int msix_capability_init(struct p
 		entry = alloc_msi_entry();
 		if (!entry)
 			break;
-		if ((vector = get_msi_vector(dev)) < 0)
+		vector = get_msi_vector(dev);
+		if (vector < 0)
 			break;
 
  		j = entries[i].entry;
@@ -711,10 +716,12 @@ int pci_enable_msi(struct pci_dev* dev)
 
 	temp = dev->irq;
 
-	if ((status = msi_init()) < 0)
+	status = msi_init();
+	if (status < 0)
 		return status;
 
-   	if (!(pos = pci_find_capability(dev, PCI_CAP_ID_MSI)))
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSI);
+	if (!pos)
 		return -EINVAL;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -738,7 +745,7 @@ int pci_enable_msi(struct pci_dev* dev)
 		dev->irq = temp;
 	}
 	/* Check whether driver already requested for MSI-X vectors */
-   	if ((pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)) > 0 &&
-		!msi_lookup_vector(dev, PCI_CAP_ID_MSIX)) {
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+	if (pos > 0 && !msi_lookup_vector(dev, PCI_CAP_ID_MSIX)) {
 			printk(KERN_INFO "PCI: %s: Can't enable MSI.  "
 			       "Device already has MSI-X vectors assigned\n",
@@ -765,7 +773,10 @@ void pci_disable_msi(struct pci_dev* dev
 	u16 control;
 	unsigned long flags;
 
-   	if (!dev || !(pos = pci_find_capability(dev, PCI_CAP_ID_MSI)))
+	if (!dev)
+		return;
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSI);
+	if (!pos)
 		return;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -936,10 +947,12 @@ int pci_enable_msix(struct pci_dev* dev,
 	if (!pci_msi_enable || !dev || !entries)
  		return -EINVAL;
 
-	if ((status = msi_init()) < 0)
+	status = msi_init();
+	if (status < 0)
 		return status;
 
-   	if (!(pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)))
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+	if (!pos)
  		return -EINVAL;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -1018,7 +1031,11 @@ void pci_disable_msix(struct pci_dev* de
 	int pos, temp;
 	u16 control;
 
-   	if (!dev || !(pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)))
+	if (!dev)
+		return;
+
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+	if (!pos)
 		return;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -1078,8 +1095,8 @@ void msi_remove_pci_irq_vectors(struct p
  		return;
 
 	temp = dev->irq;		/* Save IOAPIC IRQ */
-   	if ((pos = pci_find_capability(dev, PCI_CAP_ID_MSI)) > 0 &&
-		!msi_lookup_vector(dev, PCI_CAP_ID_MSI)) {
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSI);
+	if (pos > 0 && !msi_lookup_vector(dev, PCI_CAP_ID_MSI)) {
 		spin_lock_irqsave(&msi_lock, flags);
 		state = msi_desc[dev->irq]->msi_attrib.state;
 		spin_unlock_irqrestore(&msi_lock, flags);
@@ -1092,7 +1109,7 @@ void msi_remove_pci_irq_vectors(struct p
 			msi_free_vector(dev, dev->irq, 0);
 		dev->irq = temp;		/* Restore IOAPIC IRQ */
 	}
-   	if ((pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)) > 0 &&
-		!msi_lookup_vector(dev, PCI_CAP_ID_MSIX)) {
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+	if (pos > 0 && !msi_lookup_vector(dev, PCI_CAP_ID_MSIX)) {
 		int vector, head, tail = 0, warning = 0;
 		void __iomem *base = NULL;
diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index d2a633e..b6e3381 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -493,9 +493,8 @@ pci_enable_device_bars(struct pci_dev *d
 int
 pci_enable_device(struct pci_dev *dev)
 {
-	int err;
-
-	if ((err = pci_enable_device_bars(dev, (1 << PCI_NUM_RESOURCES) - 1)))
+	int err = pci_enable_device_bars(dev, (1 << PCI_NUM_RESOURCES) - 1);
+	if (err)
 		return err;
 	pci_fixup_device(pci_fixup_enable, dev);
 	dev->is_enabled = 1;

From: Joe Perches <joe@perches.com>
Date: Thu, 12 Jan 2006 16:55:15 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <1137084916.9940.30.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222171621.8240.71918.22618@lnx-maule.americas.sgi.com>
In-Reply-To: <20051222171621.8240.71918.22618@lnx-maule.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2006-01-12 at 00:33 -0700, Grant Grundler wrote:
> On Thu, Jan 12, 2006 at 04:47:27PM +1100, Paul Mackerras wrote:
> > Grant Grundler writes:
> > > > +	if ((status = msi_arch_init()) < 0) {
> > > Willy told me I should always complain about assignment in if() statements :)
> > We are getting incredibly politically correct these days, aren't we.
> I'm not asking greg to reject the patch nor dictating Mark Mauler change it.
> Since greg is willing to accept a patch to "fix" it, I'm willing to provide 
> the patch in this case. I think that's fairly normal way to clean things up.

(me too)

Here's a patch for drivers/pci

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 202b750..257dbbe 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -103,9 +103,9 @@ static void set_msi_affinity(unsigned in
 	switch (entry->msi_attrib.type) {
 	case PCI_CAP_ID_MSI:
 	{
-		int pos;
+		int pos = pci_find_capability(entry->dev, PCI_CAP_ID_MSI);
 
-   		if (!(pos = pci_find_capability(entry->dev, PCI_CAP_ID_MSI)))
+   		if (!pos)
 			return;
 
 		pci_read_config_dword(entry->dev, msi_lower_address_reg(pos),
@@ -345,9 +345,9 @@ static int assign_msi_vector(void)
 
 static int get_new_vector(void)
 {
-	int vector;
+	int vector = assign_msi_vector();
 
-	if ((vector = assign_msi_vector()) > 0)
+	if (vector > 0)
 		set_intr_gate(vector, interrupt[vector]);
 
 	return vector;
@@ -367,7 +367,8 @@ static int msi_init(void)
 		return status;
 	}
 
-	if ((status = msi_cache_init()) < 0) {
+	status = msi_cache_init();
+	if (status < 0) {
 		pci_msi_enable = 0;
 		printk(KERN_WARNING "PCI: MSI cache init failed\n");
 		return status;
@@ -519,10 +520,12 @@ static int msi_capability_init(struct pc
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
@@ -616,7 +619,8 @@ static int msix_capability_init(struct p
 		entry = alloc_msi_entry();
 		if (!entry)
 			break;
-		if ((vector = get_msi_vector(dev)) < 0)
+		vector = get_msi_vector(dev);
+		if (vector < 0)
 			break;
 
  		j = entries[i].entry;
@@ -697,10 +701,12 @@ int pci_enable_msi(struct pci_dev* dev)
 
 	temp = dev->irq;
 
-	if ((status = msi_init()) < 0)
+	status = msi_init();
+	if (status < 0)
 		return status;
 
-   	if (!(pos = pci_find_capability(dev, PCI_CAP_ID_MSI)))
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSI);
+   	if (!pos)
 		return -EINVAL;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -724,7 +730,8 @@ int pci_enable_msi(struct pci_dev* dev)
 		dev->irq = temp;
 	}
 	/* Check whether driver already requested for MSI-X vectors */
-   	if ((pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)) > 0 &&
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+   	if (pos > 0 &&
 		!msi_lookup_vector(dev, PCI_CAP_ID_MSIX)) {
 			printk(KERN_INFO "PCI: %s: Can't enable MSI.  "
 			       "Device already has MSI-X vectors assigned\n",
@@ -751,7 +758,10 @@ void pci_disable_msi(struct pci_dev* dev
 	u16 control;
 	unsigned long flags;
 
-   	if (!dev || !(pos = pci_find_capability(dev, PCI_CAP_ID_MSI)))
+   	if (!dev)
+		return;
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSI);
+	if (!pos)
 		return;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -920,10 +930,12 @@ int pci_enable_msix(struct pci_dev* dev,
 	if (!pci_msi_enable || !dev || !entries)
  		return -EINVAL;
 
-	if ((status = msi_init()) < 0)
+	status = msi_init();
+	if (status < 0)
 		return status;
 
-   	if (!(pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)))
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+   	if (!pos)
  		return -EINVAL;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -1002,7 +1014,11 @@ void pci_disable_msix(struct pci_dev* de
 	int pos, temp;
 	u16 control;
 
-   	if (!dev || !(pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)))
+   	if (!dev)
+		return;
+
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+	if (!pos)
 		return;
 
 	pci_read_config_word(dev, msi_control_reg(pos), &control);
@@ -1062,7 +1078,8 @@ void msi_remove_pci_irq_vectors(struct p
  		return;
 
 	temp = dev->irq;		/* Save IOAPIC IRQ */
-   	if ((pos = pci_find_capability(dev, PCI_CAP_ID_MSI)) > 0 &&
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSI);
+	if (pos > 0 &&
 		!msi_lookup_vector(dev, PCI_CAP_ID_MSI)) {
 		spin_lock_irqsave(&msi_lock, flags);
 		state = msi_desc[dev->irq]->msi_attrib.state;
@@ -1076,7 +1093,8 @@ void msi_remove_pci_irq_vectors(struct p
 			msi_free_vector(dev, dev->irq, 0);
 		dev->irq = temp;		/* Restore IOAPIC IRQ */
 	}
-   	if ((pos = pci_find_capability(dev, PCI_CAP_ID_MSIX)) > 0 &&
+	pos = pci_find_capability(dev, PCI_CAP_ID_MSIX);
+	if (pos > 0 &&
 		!msi_lookup_vector(dev, PCI_CAP_ID_MSIX)) {
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



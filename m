From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Thu, 31 Oct 2002 02:00:40 +0000
Subject: [Linux-ia64] PCI hotplug broken on IA64
Message-Id: <marc-linux-ia64-105590709805302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The PCI segment support which was introduced at 2.4.19-020821 ia64 patch
broke PCI hotplug core driver.  The way ia64 port does is using
ia64 specific 'pci_controller' structure, embedding a segment
number in it and making pci_bus->sysdata point to the structure.

All config space access functions refer to the structure so if
pci_controller structures are not setup correctly, all pci
configuration space acesss will fail.

I don't think the current way of accessing PCI configuration space
with temporary pci_dev and pci_bus is definitive answer but we
are depending on it now.

Could someone enlighten me?
Any ideas?

BTW, 2.5 is not affected (yet) because it doesn't include segment support.
Below is my dirty (and not correct) workaround.

Index: lia64-2.4/drivers/hotplug/pci_hotplug_util.c
diff -u lia64-2.4/drivers/hotplug/pci_hotplug_util.c:1.1.1.1 lia64-2.4/drivers/hotplug/pci_hotplug_util.c:1.1.1.1.2.1
--- lia64-2.4/drivers/hotplug/pci_hotplug_util.c:1.1.1.1	Tue Aug 20 16:41:38 2002
+++ lia64-2.4/drivers/hotplug/pci_hotplug_util.c	Thu Sep  5 16:49:49 2002
@@ -55,6 +55,9 @@
 {
 	struct pci_dev *my_dev;
 	struct pci_bus *my_bus;
+#ifdef CONFIG_IA64
+	struct pci_controller *controller;
+#endif
 
 	/* Some validity checks. */
 	if ((function > 7) ||
@@ -71,13 +74,29 @@
 		kfree (my_dev);
 		return -ENOMEM;
 	}
+#ifdef CONFIG_IA64
+	controller = kmalloc (sizeof (struct pci_controller), GFP_KERNEL);
+	if (!controller) {
+		kfree (my_bus);
+		kfree (my_dev);
+		return -ENOMEM;
+	}
+#endif
 	memset(my_dev, 0, sizeof(struct pci_dev));
 	memset(my_bus, 0, sizeof(struct pci_bus));
+#ifdef CONFIG_IA64
+	memset(controller, 0, sizeof(struct pci_controller));
+	/* assume seg is 0 */
+#endif
 
 	my_bus->number = bus;
 	my_bus->ops = ops;
 	my_dev->devfn = PCI_DEVFN(slot, function);
 	my_dev->bus = my_bus;
+#ifdef CONFIG_IA64
+	my_bus->sysdata = (void *)controller;
+	my_dev->sysdata = my_bus->sysdata;
+#endif
 	*pci_dev = my_dev;
 	return 0;
 }



Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>



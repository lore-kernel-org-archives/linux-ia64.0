From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 14 Apr 2003 20:56:37 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.67)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------5E1696C259755F3B889F0141"
Message-Id: <marc-linux-ia64-105590723705498@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------5E1696C259755F3B889F0141
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David Mosberger wrote:
> 
> >>>>> On Mon, 14 Apr 2003 21:55:19 +0900 (JST), Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp> said:
> 
>   Takayoshi> It seems that newly integrated PCI segment support is
>   Takayoshi> incomplete.
> 
> Argh.  Alex, can you work this out?  If fixing the segment support is
> too much effort right now, we need to revert the segment support so
> the kernel boots on Big Sur (and Tiger) again.
> 

   This patch makes it work on my i2000.  There's definitely still
some issues, but I'd rather get something out that works and go from
there, than revert it.  Please test and let me know what else you
find.  Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------5E1696C259755F3B889F0141
Content-Type: text/plain; charset=us-ascii;
 name="seg_fixes.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="seg_fixes.diff"

--- linux-2.5.67/arch/ia64/kernel/acpi.c~	Mon Apr 14 14:32:51 2003
+++ linux-2.5.67/arch/ia64/kernel/acpi.c	Mon Apr 14 14:33:45 2003
@@ -152,6 +152,10 @@
 		return NULL;
 
 	res = buf->pointer + *offset;
+
+	if (res->length <= 0)
+		return NULL;
+
 	*offset += res->length;
 	return res;
 }
--- linux-2.5.67/drivers/acpi/osl.c~	Mon Apr 14 14:32:59 2003
+++ linux-2.5.67/drivers/acpi/osl.c	Mon Apr 14 14:33:45 2003
@@ -461,6 +461,9 @@
 	int			result = 0;
 	int			size = 0;
 	struct pci_bus		bus;
+#ifdef CONFIG_IA64
+	struct pci_controller	ctrl;
+#endif
 
 	if (!value)
 		return AE_BAD_PARAMETER;
@@ -480,6 +483,10 @@
 	}
 
 	bus.number = pci_id->bus;
+#ifdef CONFIG_IA64
+	ctrl.segment = pci_id->segment;
+	bus.sysdata = &ctrl;
+#endif
 	result = pci_root_ops->read(&bus, PCI_DEVFN(pci_id->device,
 						    pci_id->function),
 				    reg, size, value);
@@ -497,6 +504,9 @@
 	int			result = 0;
 	int			size = 0;
 	struct pci_bus		bus;
+#ifdef CONFIG_IA64
+	struct pci_controller	ctrl;
+#endif
 
 	switch (width) {
 	case 8:
@@ -513,6 +523,10 @@
 	}
 
 	bus.number = pci_id->bus;
+#ifdef CONFIG_IA64
+	ctrl.segment = pci_id->segment;
+	bus.sysdata = &ctrl;
+#endif
 	result = pci_root_ops->write(&bus, PCI_DEVFN(pci_id->device,
 						     pci_id->function),
 				     reg, size, value);
--- linux-2.5.67/drivers/acpi/pci_irq.c~	Mon Apr 14 14:33:05 2003
+++ linux-2.5.67/drivers/acpi/pci_irq.c	Mon Apr 14 14:33:45 2003
@@ -293,7 +293,7 @@
 	while (!irq && bridge->bus->self) {
 		pin = (pin + PCI_SLOT(bridge->devfn)) % 4;
 		bridge = bridge->bus->self;
-		irq = acpi_pci_irq_lookup(0, bridge->bus->number, PCI_SLOT(bridge->devfn), pin);
+		irq = acpi_pci_irq_lookup(PCI_SEGMENT(bridge), bridge->bus->number, PCI_SLOT(bridge->devfn), pin);
 	}
 
 	if (!irq) {
@@ -336,7 +336,7 @@
 	 * First we check the PCI IRQ routing table (PRT) for an IRQ.  PRT
 	 * values override any BIOS-assigned IRQs set during boot.
 	 */
- 	irq = acpi_pci_irq_lookup(0, dev->bus->number, PCI_SLOT(dev->devfn), pin);
+ 	irq = acpi_pci_irq_lookup(PCI_SEGMENT(dev), dev->bus->number, PCI_SLOT(dev->devfn), pin);
  
 	/*
 	 * If no PRT entry was found, we'll try to derive an IRQ from the
--- linux-2.5.67/drivers/acpi/pci_root.c~	Mon Apr 14 14:35:35 2003
+++ linux-2.5.67/drivers/acpi/pci_root.c	Mon Apr 14 14:35:52 2003
@@ -202,8 +202,6 @@
 	switch (status) {
 	case AE_OK:
 		root->id.segment = (u16) value;
-		printk("_SEG exists! Unsupported. Abort.\n");
-		BUG();
 		break;
 	case AE_NOT_FOUND:
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO, 

--------------5E1696C259755F3B889F0141--



From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 18 Dec 2003 20:27:23 +0000
Subject: [PATCH] Remove extraneous printks
Message-Id: <marc-linux-ia64-107177939524650@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Remove extraneous printks (we already get the same information from ACPI).

(iosapic_init): Remove extraneous printk.
(pci_acpi_scan_root): Remove extraneous printk.

(To be complete, ACPI doesn't tell us the IOSAPIC version, so if you think
that's important, skip that patch.)

=== arch/ia64/kernel/iosapic.c 1.32 vs edited ==--- 1.32/arch/ia64/kernel/iosapic.c	Thu Aug 21 13:24:35 2003
+++ edited/arch/ia64/kernel/iosapic.c	Tue Nov 25 13:23:48 2003
@@ -628,9 +628,6 @@
 	iosapic_lists[num_iosapic].num_rte = num_rte;
 	num_iosapic++;
 
-	printk(KERN_INFO "  IOSAPIC v%x.%x, address 0x%lx, GSIs 0x%x-0x%x\n",
-	       (ver & 0xf0) >> 4, (ver & 0x0f), phys_addr, gsi_base, gsi_base + num_rte - 1);
-
 	if ((gsi_base = 0) && pcat_compat) {
 		/*
 		 * Map the legacy ISA devices into the IOSAPIC data.  Some of these may
=== arch/ia64/pci/pci.c 1.37 vs edited ==--- 1.37/arch/ia64/pci/pci.c	Thu Jul 31 17:47:19 2003
+++ edited/arch/ia64/pci/pci.c	Tue Nov 25 13:23:17 2003
@@ -260,7 +260,6 @@
 	unsigned int windows = 0;
 	char *name;
 
-	printk("PCI: Probing PCI hardware on bus (%04x:%02x)\n", domain, bus);
 	controller = alloc_pci_controller(domain);
 	if (!controller)
 		goto out1;


From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 23 Sep 2003 18:29:22 +0000
Subject: [PATCH] 2.4 Factor agp_generic_agp_enable()
Message-Id: <marc-linux-ia64-106434256108195@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's another in the series of patches to get all the IA64 AGP/DRM
stuff upstream in 2.4.

This just splits out parts of agp_generic_agp_enable() into two
new functions: agp_collect_device_status() and agp_device_command().
ZX1 can't use agp_generic_agp_enable() directly because its
AGP bridge is not a PCI device.  But the actual AGP *devices*
are PCI devices, of course, so this change lets ZX1 use the
relevant parts without duplicating all the code.

Essentially the same thing is in linux-2.5 (2.5 has more AGP 3.x
support, so it has some extra stuff related to that).

Bjorn

=== drivers/char/agp/agpgart_be.c 1.48 vs edited ==--- 1.48/drivers/char/agp/agpgart_be.c	Wed Sep 10 09:01:55 2003
+++ edited/drivers/char/agp/agpgart_be.c	Tue Sep 23 14:00:47 2003
@@ -397,97 +397,104 @@
 
 /* Generic Agp routines - Start */
 
-static void agp_generic_agp_enable(u32 mode)
+static u32 agp_collect_device_status(u32 mode, u32 command)
 {
-	struct pci_dev *device = NULL;
-	u32 command, scratch;
-	u8 cap_ptr;
+	struct pci_dev *device;
+	u8 agp;
+	u32 scratch;
 
-	pci_read_config_dword(agp_bridge.dev,
-			      agp_bridge.capndx + 4,
-			      &command);
+	pci_for_each_dev(device) {
+		agp = pci_find_capability(device, PCI_CAP_ID_AGP);
+		if (!agp)
+			continue;
+
+		/*
+		 * Ok, here we have a AGP device. Disable impossible 
+		 * settings, and adjust the readqueue to the minimum.
+		 */
+		pci_read_config_dword(device, agp + PCI_AGP_STATUS, &scratch);
+
+		/* adjust RQ depth */
+		command +		    ((command & ~0xff000000) |
+		     min_t(u32, (mode & 0xff000000),
+			 min_t(u32, (command & 0xff000000),
+			     (scratch & 0xff000000))));
+
+		/* disable SBA if it's not supported */
+		if (!((command & 0x00000200) &&
+		      (scratch & 0x00000200) &&
+		      (mode & 0x00000200)))
+			command &= ~0x00000200;
+
+		/* disable FW if it's not supported */
+		if (!((command & 0x00000010) &&
+		      (scratch & 0x00000010) &&
+		      (mode & 0x00000010)))
+			command &= ~0x00000010;
+
+		if (!((command & 4) &&
+		      (scratch & 4) &&
+		      (mode & 4)))
+			command &= ~0x00000004;
+
+		if (!((command & 2) &&
+		      (scratch & 2) &&
+		      (mode & 2)))
+			command &= ~0x00000002;
+
+		if (!((command & 1) &&
+		      (scratch & 1) &&
+		      (mode & 1)))
+			command &= ~0x00000001;
+	}
 
-	/*
-	 * PASS1: go throu all devices that claim to be
-	 *        AGP devices and collect their data.
-	 */
+	if (command & 4)
+		command &= ~3;	/* 4X */
+	if (command & 2)
+		command &= ~5;	/* 2X (8X for AGP3.0) */
+	if (command & 1)
+		command &= ~6;	/* 1X (4X for AGP3.0) */
 
+	return command;
+}
+
+static void agp_device_command(u32 command, int agp_v3)
+{
+	struct pci_dev *device;
+	int mode;
+
+	mode = command & 0x7;
+	if (agp_v3)
+		mode *= 4;
 
 	pci_for_each_dev(device) {
-		cap_ptr = pci_find_capability(device, PCI_CAP_ID_AGP);
-		if (cap_ptr != 0x00) {
-			/*
-			 * Ok, here we have a AGP device. Disable impossible 
-			 * settings, and adjust the readqueue to the minimum.
-			 */
-
-			pci_read_config_dword(device, cap_ptr + 4, &scratch);
-
-			/* adjust RQ depth */
-			command -			    ((command & ~0xff000000) |
-			     min_t(u32, (mode & 0xff000000),
-				 min_t(u32, (command & 0xff000000),
-				     (scratch & 0xff000000))));
-
-			/* disable SBA if it's not supported */
-			if (!((command & 0x00000200) &&
-			      (scratch & 0x00000200) &&
-			      (mode & 0x00000200)))
-				command &= ~0x00000200;
-
-			/* disable FW if it's not supported */
-			if (!((command & 0x00000010) &&
-			      (scratch & 0x00000010) &&
-			      (mode & 0x00000010)))
-				command &= ~0x00000010;
-
-			if (!((command & 4) &&
-			      (scratch & 4) &&
-			      (mode & 4)))
-				command &= ~0x00000004;
-
-			if (!((command & 2) &&
-			      (scratch & 2) &&
-			      (mode & 2)))
-				command &= ~0x00000002;
-
-			if (!((command & 1) &&
-			      (scratch & 1) &&
-			      (mode & 1)))
-				command &= ~0x00000001;
-		}
+		u8 agp = pci_find_capability(device, PCI_CAP_ID_AGP);
+		if (!agp)
+			continue;
+
+		printk(KERN_INFO PFX "Putting AGP V%d device at %s into %dx mode\n",
+				agp_v3 ? 3 : 2, device->slot_name, mode);
+		pci_write_config_dword(device, agp + PCI_AGP_COMMAND, command);
 	}
-	/*
-	 * PASS2: Figure out the 4X/2X/1X setting and enable the
-	 *        target (our motherboard chipset).
-	 */
+}
 
-	if (command & 4) {
-		command &= ~3;	/* 4X */
-	}
-	if (command & 2) {
-		command &= ~5;	/* 2X */
-	}
-	if (command & 1) {
-		command &= ~6;	/* 1X */
-	}
+static void agp_generic_agp_enable(u32 mode)
+{
+	u32 command;
+
+	pci_read_config_dword(agp_bridge.dev,
+			      agp_bridge.capndx + PCI_AGP_STATUS,
+			      &command);
+
+	command = agp_collect_device_status(mode, command);
 	command |= 0x00000100;
 
 	pci_write_config_dword(agp_bridge.dev,
-			       agp_bridge.capndx + 8,
+			       agp_bridge.capndx + PCI_AGP_COMMAND,
 			       command);
 
-	/*
-	 * PASS3: Go throu all AGP devices and update the
-	 *        command registers.
-	 */
-
-	pci_for_each_dev(device) {
-		cap_ptr = pci_find_capability(device, PCI_CAP_ID_AGP);
-		if (cap_ptr != 0x00)
-			pci_write_config_dword(device, cap_ptr + 8, command);
-	}
+	agp_device_command(command, 0);
 }
 
 static int agp_generic_create_gatt_table(void)


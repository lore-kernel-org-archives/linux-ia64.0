From: Hanna Linder <hannal@us.ibm.com>
Date: Wed, 21 Aug 2002 22:14:23 +0000
Subject: [Linux-ia64] Re: PCI Cleanup
Message-Id: <marc-linux-ia64-105590701905972@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905960@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905960@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Included is the snia64 portion of the ia64 port of the
pci_ops structure cleanup change that Matt Dobson 
originally did for i386.

Thanks to David Mosberger for sending me the 2.5.30 
version of the ia64 port I have been able to compile
this patch and the previous one to verify they compile.

This applies cleanly to bk://linuxusb.bkbits.net/pci_hp-2.5

Hanna

---------
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.558   -> 1.559  
#	arch/ia64/sn/io/pci.c	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/08/21	hlinder@w-hlinder.beaverton.ibm.com	1.559
# Port to ia64 of pci_ops cleanup
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/pci.c b/arch/ia64/sn/io/pci.c
--- a/arch/ia64/sn/io/pci.c	Wed Aug 21 13:49:06 2002
+++ b/arch/ia64/sn/io/pci.c	Wed Aug 21 13:49:06 2002
@@ -44,22 +44,21 @@
 extern devfs_handle_t devfn_to_vertex(unsigned char bus, unsigned char devfn);
 
 /*
- * snia64_read_config_byte - Read a byte from the config area of the device.
+ * snia64_read - Read from the config area of the device.
  */
-static int snia64_read_config_byte (struct pci_dev *dev,
-                                   int where, unsigned char *val)
+static int snia64_read (struct pci_bus *bus, unsigned char devfn,
+                                   int where, int size, unsigned char *val)
 {
 	unsigned long res = 0;
-	unsigned size = 1;
 	devfs_handle_t device_vertex;
 
-	if ( (dev = (struct pci_dev *)0) || (val = (unsigned char *)0) ) {
+	if ( (bus->dev = (struct pci_dev *)0) || (val = (unsigned char *)0) ) {
 		return PCIBIOS_DEVICE_NOT_FOUND;
 	}
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
+	device_vertex = devfn_to_vertex(bus->number, devfn);
 	if (!device_vertex) {
 		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+		__FUNCTION__, bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn));
 		return(-1);
 	}
 	res = pciio_config_get(device_vertex, (unsigned) where, size);
@@ -68,160 +67,38 @@
 }
 
 /*
- * snia64_read_config_word - Read 2 bytes from the config area of the device.
+ * snia64_write - Writes to the config area of the device.
  */
-static int snia64_read_config_word (struct pci_dev *dev,
-                                   int where, unsigned short *val)
+static int snia64_write (struct pci_bus *bus, unsigned char devfn,
+                                    int where, int size, unsigned char val)
 {
-	unsigned long res = 0;
-	unsigned size = 2; /* 2 bytes */
-	devfs_handle_t device_vertex;
-
-	if ( (dev = (struct pci_dev *)0) || (val = (unsigned short *)0) ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	res = pciio_config_get(device_vertex, (unsigned) where, size);
-	*val = (unsigned short) res;
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_read_config_dword - Read 4 bytes from the config area of the device.
- */
-static int snia64_read_config_dword (struct pci_dev *dev,
-                                    int where, unsigned int *val)
-{
-	unsigned long res = 0;
-	unsigned size = 4; /* 4 bytes */
 	devfs_handle_t device_vertex;
 
-	if (where & 3) {
-		return PCIBIOS_BAD_REGISTER_NUMBER;
-	}
-	if ( (dev = (struct pci_dev *)0) || (val = (unsigned int *)0) ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	res = pciio_config_get(device_vertex, (unsigned) where, size);
-	*val = (unsigned int) res;
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_write_config_byte - Writes 1 byte to the config area of the device.
- */
-static int snia64_write_config_byte (struct pci_dev *dev,
-                                    int where, unsigned char val)
-{
-	devfs_handle_t device_vertex;
-
-	if ( dev = (struct pci_dev *)0 ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	/* 
-	 * if it's an IOC3 then we bail out, we special
-	 * case them with pci_fixup_ioc3
-	 */
-	if (dev->vendor = PCI_VENDOR_ID_SGI && 
-	    dev->device = PCI_DEVICE_ID_SGI_IOC3 )
-		return PCIBIOS_SUCCESSFUL;
-
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	pciio_config_set( device_vertex, (unsigned)where, 1, (uint64_t) val);
-
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_write_config_word - Writes 2 bytes to the config area of the device.
- */
-static int snia64_write_config_word (struct pci_dev *dev,
-                                    int where, unsigned short val)
-{
-	devfs_handle_t device_vertex = NULL;
-
-	if (where & 1) {
-		return PCIBIOS_BAD_REGISTER_NUMBER;
-	}
-	if ( dev = (struct pci_dev *)0 ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	/* 
-	 * if it's an IOC3 then we bail out, we special
-	 * case them with pci_fixup_ioc3
-	 */
-	if (dev->vendor = PCI_VENDOR_ID_SGI && 
-	    dev->device = PCI_DEVICE_ID_SGI_IOC3)
-		return PCIBIOS_SUCCESSFUL;
-
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	pciio_config_set( device_vertex, (unsigned)where, 2, (uint64_t) val);
-
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_write_config_dword - Writes 4 bytes to the config area of the device.
- */
-static int snia64_write_config_dword (struct pci_dev *dev,
-                                     int where, unsigned int val)
-{
-	devfs_handle_t device_vertex;
-
-	if (where & 3) {
-		return PCIBIOS_BAD_REGISTER_NUMBER;
-	}
-	if ( dev = (struct pci_dev *)0 ) {
+	if ( bus->dev = (struct pci_dev *)0 ) {
 		return PCIBIOS_DEVICE_NOT_FOUND;
 	}
 	/* 
 	 * if it's an IOC3 then we bail out, we special
 	 * case them with pci_fixup_ioc3
 	 */
-	if (dev->vendor = PCI_VENDOR_ID_SGI && 
-	    dev->device = PCI_DEVICE_ID_SGI_IOC3)
+	if (bus->dev->vendor = PCI_VENDOR_ID_SGI && 
+	    bus->dev->device = PCI_DEVICE_ID_SGI_IOC3 )
 		return PCIBIOS_SUCCESSFUL;
 
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
+	device_vertex = devfn_to_vertex(bus->number, devfn);
 	if (!device_vertex) {
 		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+		__FUNCTION__, bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn));
 		return(-1);
 	}
-	pciio_config_set( device_vertex, (unsigned)where, 4, (uint64_t) val);
+	pciio_config_set( device_vertex, (unsigned)where, size, (uint64_t) val);
 
 	return PCIBIOS_SUCCESSFUL;
 }
 
 static struct pci_ops snia64_pci_ops = {
-	snia64_read_config_byte,
-	snia64_read_config_word,
-	snia64_read_config_dword,
-	snia64_write_config_byte,
-	snia64_write_config_word,
-	snia64_write_config_dword
+	.read =		snia64_read,
+	.write = 	snia64_write,
 };
 
 /*



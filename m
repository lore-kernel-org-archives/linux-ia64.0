From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Sep 2003 14:21:18 +0000
Subject: [PATCH] avoid a layer of indirection in SN2 pci config space access
Message-Id: <marc-linux-ia64-106467249726651@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

only one instead of two filesystems lookup for config space access now..
The code still is a total mess, but I don't want to touch the lower
levels right now as the SGI I/O group wants to keep it in sync with
IRIX.


diff -Nru a/arch/ia64/sn/io/machvec/pci.c b/arch/ia64/sn/io/machvec/pci.c
--- a/arch/ia64/sn/io/machvec/pci.c	Sat Sep 27 16:18:23 2003
+++ b/arch/ia64/sn/io/machvec/pci.c	Sat Sep 27 16:18:23 2003
@@ -1,6 +1,5 @@
-/* 
- *
- * SNI64 specific PCI support for SNI IO.
+/*
+ * PCI config space access glue for SN2.
  *
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
@@ -8,47 +7,43 @@
  *
  * Copyright (c) 1997, 1998, 2000-2003 Silicon Graphics, Inc.  All rights reserved.
  */
-#include <linux/init.h>
-#include <linux/types.h>
-#include <linux/config.h>
+
 #include <linux/pci.h>
 #include <asm/sn/types.h>
-#include <asm/sn/sgi.h>
-#include <asm/sn/io.h>
-#include <asm/sn/driver.h>
-#include <asm/sn/iograph.h>
-#include <asm/param.h>
-#include <asm/sn/pio.h>
-#include <asm/sn/xtalk/xwidget.h>
-#include <asm/sn/sn_private.h>
-#include <asm/sn/addrs.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/hcl_util.h>
-#include <asm/sn/pci/pciio.h>
-#include <asm/sn/pci/pcibr.h>
 #include <asm/sn/pci/pcibr_private.h>
-#include <asm/sn/pci/bridge.h>
+
+
+extern vertex_hdl_t devfn_to_vertex(unsigned char bus, unsigned char devfn);
 
 /*
  * These routines are only used during sn_pci_init for probing each bus, and
  * can probably be removed with a little more cleanup now that the SAL routines
  * work on sn2.
  */
-extern vertex_hdl_t devfn_to_vertex(unsigned char bus, unsigned char devfn);
-
 int sn_read_config(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *val)
 {
-	unsigned long res = 0;
 	vertex_hdl_t device_vertex;
+	uint64_t	value = 0;
+	unsigned	shift = 0;
 
 	device_vertex = devfn_to_vertex(bus->number, devfn);
-
 	if (!device_vertex)
 		return PCIBIOS_DEVICE_NOT_FOUND;
 
-	res = pciio_config_get(device_vertex, (unsigned)where, size);
-	*val = (u32)res;
+	while (size > 0) {
+		unsigned	biw = 4 - (where&3);
+
+		if (biw > size)
+			biw = size;
+
+		value |= pcibr_config_get(device_vertex, where, biw) << shift;
+
+		shift += 8*biw;
+		where += biw;
+		size -= biw;
+	}
+
+	*val = (u32)value;
 	return PCIBIOS_SUCCESSFUL;
 }
 
@@ -57,11 +52,21 @@
 	vertex_hdl_t device_vertex;
 
 	device_vertex = devfn_to_vertex(bus->number, devfn);
-
 	if (!device_vertex)
 		return PCIBIOS_DEVICE_NOT_FOUND;
 
-	pciio_config_set(device_vertex, (unsigned)where, size, (uint64_t)val);
+	while (size > 0) {
+		unsigned biw = 4 - (where&3);
+		
+		if (biw > size)
+			biw = size;
+
+		pcibr_config_set(device_vertex, where, biw, (u_int64_t)val);
+		where += biw;
+		size -= biw;
+		val >>= biw * 8;
+	}
+
 	return PCIBIOS_SUCCESSFUL;
 }
 
diff -Nru a/arch/ia64/sn/io/sn2/pciio.c b/arch/ia64/sn/io/sn2/pciio.c
--- a/arch/ia64/sn/io/sn2/pciio.c	Sat Sep 27 16:18:24 2003
+++ b/arch/ia64/sn/io/sn2/pciio.c	Sat Sep 27 16:18:24 2003
@@ -797,66 +797,6 @@
 }
 
 /*
- * Read value of configuration register
- */
-uint64_t
-pciio_config_get(vertex_hdl_t	dev,
-		 unsigned	reg,
-		 unsigned	size)
-{
-    uint64_t	value = 0;
-    unsigned	shift = 0;
-
-    /* handle accesses that cross words here,
-     * since that's common code between all
-     * possible providers.
-     */
-    while (size > 0) {
-	unsigned	biw = 4 - (reg&3);
-	if (biw > size)
-	    biw = size;
-
-	value |= DEV_FUNC(dev, config_get)
-	    (dev, reg, biw) << shift;
-
-	shift += 8*biw;
-	reg += biw;
-	size -= biw;
-    }
-    return value;
-}
-
-/*
- * Change value of configuration register
- */
-void
-pciio_config_set(vertex_hdl_t	dev,
-		 unsigned	reg,
-		 unsigned	size,
-		 uint64_t	value)
-{
-    /* handle accesses that cross words here,
-     * since that's common code between all
-     * possible providers.
-     */
-    while (size > 0) {
-	unsigned	biw = 4 - (reg&3);
-	if (biw > size)
-	    biw = size;
-	    
-	DEV_FUNC(dev, config_set)
-	    (dev, reg, biw, value);
-	reg += biw;
-	size -= biw;
-	value >>= biw * 8;
-    }
-}
-
-/* ==================================- *          GENERIC PCI SUPPORT FUNCTIONS
- */
-
-/*
  * Issue a hardware reset to a card.
  */
 int

From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 09 Sep 2004 18:51:08 +0000
Subject: [PATCH] sn2: disable non-display ROM resources
Message-Id: <200409091151.08990.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_cYKQBOOJaVvCVdE"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_cYKQBOOJaVvCVdE
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch is needed to correctly support the new sysfs rom file.  On sn2, we 
only allocate PIO space for display option ROMs since PIO space is a 
relatively scarce resource (we've seen exhaustion when running with several 
qla cards in the same domain).  And without this patch we won't zero out 
non-display ROM resources which can lead to panics if anyone tries to use the 
bogus addresses left over there from the generic PCI probing code.  

Thanks,
Jesse

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

--Boundary-00=_cYKQBOOJaVvCVdE
Content-Type: text/plain;
  charset="us-ascii";
  name="disable-non-vga-roms.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="disable-non-vga-roms.patch"

===== arch/ia64/sn/io/machvec/pci_bus_cvlink.c 1.43 vs edited =====
--- 1.43/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	2004-08-18 09:38:41 -07:00
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	2004-09-09 09:43:10 -07:00
@@ -357,7 +357,20 @@
                         if (dev->resource[PCI_ROM_RESOURCE].flags & IORESOURCE_MEM)
                                 cmd |= PCI_COMMAND_MEMORY;
                 }
-        }
+        } else {
+		/*
+		 * Remove other ROM resources since they don't have valid
+		 * CPU addresses.
+		 */
+                size = dev->resource[PCI_ROM_RESOURCE].end -
+                        dev->resource[PCI_ROM_RESOURCE].start;
+
+		if (size) {
+			dev->resource[PCI_ROM_RESOURCE].start = 0;
+			dev->resource[PCI_ROM_RESOURCE].end = 0;
+			dev->resource[PCI_ROM_RESOURCE].flags = 0;
+		}
+	}
 
 	/*
 	 * Update the Command Word on the Card.

--Boundary-00=_cYKQBOOJaVvCVdE--

From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 21 Apr 2003 19:33:38 +0000
Subject: [Linux-ia64] [PATCH] 2.5.67 Don't init zx1 agpgart on non-AGP system
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------EFD671C7FA0B825D404E3BFA"
Message-Id: <marc-linux-ia64-105590723705580@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------EFD671C7FA0B825D404E3BFA
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   This fixes agp_hp_init() so that it doesn't try to register
the zx1 AGP driver when there is no AGP slot in the system.
Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------EFD671C7FA0B825D404E3BFA
Content-Type: text/plain; charset=us-ascii;
 name="hp-agp.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hp-agp.diff"

--- linux-2.5.67/drivers/char/agp/hp-agp.c~	2003-04-21 12:37:52.000000000 -0600
+++ linux-2.5.67/drivers/char/agp/hp-agp.c	2003-04-21 12:53:20.000000000 -0600
@@ -420,6 +420,9 @@
 	if (hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa))
 		return 1;
 
+	fake_bridge_dev.vendor = PCI_VENDOR_ID_HP;
+	fake_bridge_dev.device = PCI_DEVICE_ID_HP_ZX1_LBA;
+
 	return 0;
 }
 
@@ -435,16 +438,19 @@
 	status = acpi_get_devices("HWP0003", zx1_gart_probe, "HWP0003 AGP LBA", NULL);
 	if (!(ACPI_SUCCESS(status))) {
 		agp_bridge->type = NOT_SUPPORTED;
-		printk(KERN_INFO PFX "Didn't find an HP ZX1 Chipset.\n");
+		printk(KERN_INFO PFX "Failed to initialize zx1 AGP.\n");
 		return -ENODEV;
 	}
 
-	fake_bridge_dev.vendor = PCI_VENDOR_ID_HP;
-	fake_bridge_dev.device = PCI_DEVICE_ID_HP_ZX1_LBA;
-	hp_agp_driver.dev = &fake_bridge_dev;
-	agp_bridge->type = HP_ZX1;
-	agp_bridge->dev = &fake_bridge_dev;
-	return agp_register_driver(&hp_agp_driver);
+	if (fake_bridge_dev.vendor && !agp_bridge->type) {
+		hp_agp_driver.dev = &fake_bridge_dev;
+		agp_bridge->type = HP_ZX1;
+		agp_bridge->dev = &fake_bridge_dev;
+		return agp_register_driver(&hp_agp_driver);
+
+	} else {
+		return -ENODEV;
+	}
 }
 
 static void __exit

--------------EFD671C7FA0B825D404E3BFA--



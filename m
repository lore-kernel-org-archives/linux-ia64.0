From: <gregkh@suse.de>
Date: Tue, 10 Jan 2006 06:00:10 +0000
Subject: patch add-tiocx-bus_type-probe-remove-methods.patch added to gregkh-2.6 tree
Message-Id: <1EwCYF-2tk-00@press.kroah.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This is a note to let you know that I've just added the patch titled

     Subject: [CFT 9/29] Add tiocx bus_type probe/remove methods

to my gregkh-2.6 tree.  Its filename is

     add-tiocx-bus_type-probe-remove-methods.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


From rmk+greg=kroah.com@arm.linux.org.uk Thu Jan  5 06:37:15 2006
From: Russell King <rmk@arm.linux.org.uk>
CC: Greg K-H <greg@kroah.com>, IA64 <linux-ia64@vger.kernel.org>
Subject: [CFT 9/29] Add tiocx bus_type probe/remove methods
Date: Thu, 05 Jan 2006 14:34:06 +0000
Message-ID: <20060105142951.13.09@flint.arm.linux.org.uk>

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 arch/ia64/sn/kernel/tiocx.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- gregkh-2.6.orig/arch/ia64/sn/kernel/tiocx.c
+++ gregkh-2.6/arch/ia64/sn/kernel/tiocx.c
@@ -76,12 +76,6 @@ static void tiocx_bus_release(struct dev
 	kfree(to_cx_dev(dev));
 }
 
-struct bus_type tiocx_bus_type = {
-	.name = "tiocx",
-	.match = tiocx_match,
-	.uevent = tiocx_uevent,
-};
-
 /**
  * cx_device_match - Find cx_device in the id table.
  * @ids: id table from driver
@@ -148,6 +142,14 @@ static int cx_driver_remove(struct devic
 	return 0;
 }
 
+struct bus_type tiocx_bus_type = {
+	.name = "tiocx",
+	.match = tiocx_match,
+	.uevent = tiocx_uevent,
+	.probe = cx_device_probe,
+	.remove = cx_device_remove,
+};
+
 /**
  * cx_driver_register - Register the driver.
  * @cx_driver: driver table (cx_drv struct) from driver
@@ -161,8 +163,6 @@ int cx_driver_register(struct cx_drv *cx
 {
 	cx_driver->driver.name = cx_driver->name;
 	cx_driver->driver.bus = &tiocx_bus_type;
-	cx_driver->driver.probe = cx_device_probe;
-	cx_driver->driver.remove = cx_driver_remove;
 
 	return driver_register(&cx_driver->driver);
 }


Patches currently in gregkh-2.6 which might be from rmk@arm.linux.org.uk are

driver/add-bttv-sub-bus_type-probe-and-remove-methods.patch
driver/add-bus_type-probe-remove-shutdown-methods..patch
driver/add-ccwgroup_bus_type-probe-and-remove-methods.patch
driver/add-dio_bus_type-probe-and-remove-methods.patch
driver/add-ecard_bus_type-probe-remove-shutdown-methods.patch
driver/add-gameport-bus_type-probe-and-remove-methods.patch
driver/add-i2c_bus_type-probe-and-remove-methods.patch
driver/add-ide_bus_type-probe-and-remove-methods.patch
driver/add-locomo-bus_type-probe-remove-methods.patch
driver/add-logic-module-bus_type-probe-remove-methods.patch
driver/add-macio_bus_type-probe-and-remove-methods.patch
driver/add-mcp-bus_type-probe-and-remove-methods.patch
driver/add-mmc_bus_type-probe-and-remove-methods.patch
driver/add-ocp_bus_type-probe-and-remove-methods.patch
driver/add-of_platform_bus_type-probe-and-remove-methods.patch
driver/add-parisc_bus_type-probe-and-remove-methods.patch
driver/add-pci_bus_type-probe-and-remove-methods.patch
driver/add-pcmcia_bus_type-probe-and-remove-methods.patch
driver/add-pnp_bus_type-probe-and-remove-methods.patch
driver/add-pseudo-lld-bus_type-probe-and-remove-methods.patch
driver/add-rio_bus_type-probe-and-remove-methods.patch
driver/add-sa1111-bus_type-probe-remove-methods.patch
driver/add-serio-bus_type-probe-and-remove-methods.patch
driver/add-sh_bus_type-probe-and-remove-methods.patch
driver/add-superhyway_bus_type-probe-and-remove-methods.patch
driver/add-tiocx-bus_type-probe-remove-methods.patch
driver/add-usb_serial_bus_type-probe-and-remove-methods.patch
driver/add-vio_bus_type-probe-and-remove-methods.patch
driver/add-zorro_bus_type-probe-and-remove-methods.patch
driver/remove-usb-gadget-generic-driver-methods.patch

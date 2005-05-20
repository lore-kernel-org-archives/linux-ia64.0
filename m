From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 20 May 2005 13:12:29 +0000
Subject: [PATCH]: TIOCX: Do not autoload TIOCX & FPGA drivers
Message-Id: <20050520131215.19334.51045.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[PATCH]: ia64/sn : Do not autoload TIOCX & FPGA driver

When built-in the TIOCX driver has functions exposed to the FPGA driver
in the kernel.  If a TIOCX is not found, this can lead to an oops when the
FPGA attempts to register against the TIOCX driver.

This fix makes found_tiocx_device a static int which is queried when FPGA
driver(s) attempt to register against the TIOCX driver.  The functions
cx_driver_register and cx_driver_unregister now return -ENODEV and NULL
respectively if nr_tiocx_found = 0, preventing the FPGA driver from loading.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit afcdf951ae21cea0298292aab6cb9186bf700e12
tree d30090ea4fd3c7696509afbc070370e89d47f1eb
parent 88d7bd8cb9eb8d64bf7997600b0d64f7834047c5
author Prarit Bhargava <prarit@sgi.com> 1810817779 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810817779 -0400

Index: arch/ia64/sn/kernel/tiocx.c
=================================--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/arch/ia64/sn/kernel/tiocx.c  (mode:100644 sha1:ab9b5f35c2a72ba9bf6a398029e888dbeed3d129)
+++ d30090ea4fd3c7696509afbc070370e89d47f1eb/arch/ia64/sn/kernel/tiocx.c  (mode:100644 sha1:043f05399bcb9d9456f0abd61288e3bbc8ecdbd4)
@@ -38,6 +38,7 @@
 #define DBG(fmt...)
 #endif
 
+static int nr_tiocx_found = 0; /* number of tiocx's found */
 struct device_attribute dev_attr_cxdev_control;
 
 /**
@@ -159,6 +160,9 @@
  */
 int cx_driver_register(struct cx_drv *cx_driver)
 {
+	if (nr_tiocx_found = 0)
+		return -ENODEV;
+
 	cx_driver->driver.name = cx_driver->name;
 	cx_driver->driver.bus = &tiocx_bus_type;
 	cx_driver->driver.probe = cx_device_probe;
@@ -171,10 +175,12 @@
  * cx_driver_unregister - Unregister the driver.
  * @cx_driver: driver table (cx_drv struct) from driver
  */
-int cx_driver_unregister(struct cx_drv *cx_driver)
+void cx_driver_unregister(struct cx_drv *cx_driver)
 {
+	if (nr_tiocx_found = 0)
+		return;
+
 	driver_unregister(&cx_driver->driver);
-	return 0;
 }
 
 /**
@@ -500,6 +506,9 @@
 			if (widgetp->xwi_hwid.part_num = TIO_CE_ASIC_PARTNUM)
 				continue;
 
+			/* found a TIOCX brick */
+			nr_tiocx_found++;
+
 			tio_corelet_reset(nasid, TIOCX_CORELET);
 			tio_conveyor_enable(nasid);
 
@@ -515,6 +524,8 @@
 	/* It's ok if we find zero devices. */
 	DBG("found_tiocx_device= %d\n", found_tiocx_device);
 
+	if (nr_tiocx_found = 0)
+		return -ENODEV;
 	return 0;
 }
 
Index: include/asm-ia64/sn/tiocx.h
=================================--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/include/asm-ia64/sn/tiocx.h  (mode:100644 sha1:c5447a504509ba07cbd1646acb37295a7e981801)
+++ d30090ea4fd3c7696509afbc070370e89d47f1eb/include/asm-ia64/sn/tiocx.h  (mode:100644 sha1:377c5b84f0bee045e79a91ae05046b95c82c6e96)
@@ -60,7 +60,7 @@
 extern void tiocx_irq_free(struct sn_irq_info *);
 extern int cx_device_unregister(struct cx_dev *);
 extern int cx_device_register(nasid_t, int, int, struct hubdev_info *);
-extern int cx_driver_unregister(struct cx_drv *);
+extern void cx_driver_unregister(struct cx_drv *);
 extern int cx_driver_register(struct cx_drv *);
 extern uint64_t tiocx_dma_addr(uint64_t addr);
 extern uint64_t tiocx_swin_base(int nasid);

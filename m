From: Bruce Losure <blosure@sgi.com>
Date: Fri, 11 Feb 2005 14:03:21 +0000
Subject: [PATCH 2.6.11-rc2 1/1] altix: Device driver support for the CX port of SGI's TIO chip
Message-Id: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/10 10:48:05-06:00 blosure@attica.americas.sgi.com 
#   Add support for TIO CX port.  That port may be connected to FPGA-based
#   hardware.   This code provides support to device driver developers
#   for that hardware. 
# 
# 
diff -Nru a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
--- a/arch/ia64/configs/sn2_defconfig	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/configs/sn2_defconfig	2005-02-10 11:00:30 -06:00
@@ -573,6 +573,7 @@
 # CONFIG_N_HDLC is not set
 # CONFIG_STALDRV is not set
 CONFIG_SGI_SNSC=y
+# CONFIG_SGI_TIOCX is not set
 
 #
 # Serial drivers
diff -Nru a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
--- a/arch/ia64/sn/kernel/bte.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/kernel/bte.c	2005-02-10 11:00:30 -06:00
@@ -13,7 +13,7 @@
 #include <asm/sn/arch.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/pda.h>
-#include "shubio.h"
+#include <asm/sn/shubio.h>
 #include <asm/nodedata.h>
 #include <asm/delay.h>
 
diff -Nru a/arch/ia64/sn/kernel/bte_error.c b/arch/ia64/sn/kernel/bte_error.c
--- a/arch/ia64/sn/kernel/bte_error.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/kernel/bte_error.c	2005-02-10 11:00:30 -06:00
@@ -10,10 +10,10 @@
 #include <asm/sn/sn_sal.h>
 #include "ioerror.h"
 #include <asm/sn/addrs.h>
-#include "shubio.h"
+#include <asm/sn/shubio.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/bte.h>
 #include <asm/param.h>
 
diff -Nru a/arch/ia64/sn/kernel/huberror.c b/arch/ia64/sn/kernel/huberror.c
--- a/arch/ia64/sn/kernel/huberror.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/kernel/huberror.c	2005-02-10 11:00:30 -06:00
@@ -13,10 +13,10 @@
 #include <asm/sn/sn_sal.h>
 #include "ioerror.h"
 #include <asm/sn/addrs.h>
-#include "shubio.h"
+#include <asm/sn/shubio.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/bte.h>
 
 void hubiio_crb_error_handler(struct hubdev_info *hubdev_info);
diff -Nru a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/kernel/io_init.c	2005-02-10 11:00:30 -06:00
@@ -14,9 +14,9 @@
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/pcibr_provider.h"
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
 #include <asm/sn/geo.h>
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/io.h>
 #include <asm/sn/simulator.h>
 
diff -Nru a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/kernel/irq.c	2005-02-10 11:00:30 -06:00
@@ -12,7 +12,7 @@
 #include <asm/sn/intr.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/arch.h>
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/pcibr_provider.h"
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/kernel/setup.c	2005-02-10 11:00:30 -06:00
@@ -47,12 +47,13 @@
 #include <asm/sn/clksupport.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/klconfig.h>
 
 
 DEFINE_PER_CPU(struct pda_s, pda_percpu);
+EXPORT_PER_CPU_SYMBOL(pda_percpu);
 
 #define MAX_PHYS_MEMORY		(1UL << 49)	/* 1 TB */
 
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-10 11:00:30 -06:00
@@ -10,15 +10,15 @@
 #include <linux/pci.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/tiocp.h"
 #include "pci/pic.h"
 #include "pci/pcibr_provider.h"
 #include "pci/tiocp.h"
-#include "tio.h"
+#include <asm/sn/tio.h>
 #include <asm/sn/addrs.h>
 
 extern int sn_ioif_inited;
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-10 11:00:30 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-10 11:00:30 -06:00
@@ -10,9 +10,9 @@
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <asm/sn/sn_sal.h>
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
 #include <asm/sn/geo.h>
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/hubdev.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/pcibr_provider.h"
diff -Nru a/drivers/char/Kconfig b/drivers/char/Kconfig
--- a/drivers/char/Kconfig	2005-02-10 11:00:30 -06:00
+++ b/drivers/char/Kconfig	2005-02-10 11:00:30 -06:00
@@ -432,6 +432,13 @@
 	  controller communication from user space (you want this!),
 	  say Y.  Otherwise, say N.
 
+config SGI_TIOCX
+       tristate "SGI TIO CX driver support"
+       depends on (IA64_SGI_SN2 || IA64_GENERIC)
+       help
+         If you have an SGI Altix and you have fpga devices attached
+         to your TIO, say Y or M here, otherwise say N.
+
 source "drivers/serial/Kconfig"
 
 config UNIX98_PTYS
diff -Nru a/drivers/char/Makefile b/drivers/char/Makefile
--- a/drivers/char/Makefile	2005-02-10 11:00:30 -06:00
+++ b/drivers/char/Makefile	2005-02-10 11:00:30 -06:00
@@ -49,6 +49,7 @@
 obj-$(CONFIG_VIOCONS) += viocons.o
 obj-$(CONFIG_VIOTAPE)		+= viotape.o
 obj-$(CONFIG_HVCS)		+= hvcs.o
+obj-$(CONFIG_SGI_TIOCX)		+= tiocx.o
 
 obj-$(CONFIG_PRINTER) += lp.o
 obj-$(CONFIG_TIPAR) += tipar.o
diff -Nru a/drivers/char/tiocx.c b/drivers/char/tiocx.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/char/tiocx.c	2005-02-10 11:00:30 -06:00
@@ -0,0 +1,532 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/proc_fs.h>
+#include <linux/device.h>
+#include <linux/delay.h>
+#include <asm/uaccess.h>
+#include <asm/sn/sn_sal.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/io.h>
+#include <asm/sn/types.h>
+#include <asm/sn/shubio.h>
+#include <asm/sn/tio.h>
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
+#include "tiocx.h"
+
+#define CX_DEV_NONE 0
+#define DEVICE_NAME "tiocx"
+#define WIDGET_ID 0
+#define TIOCX_DEBUG 0
+
+#if TIOCX_DEBUG
+#define DBG(fmt...)    printk(KERN_ALERT fmt)
+#else
+#define DBG(fmt...)
+#endif
+
+static int tiocx_match(struct device *dev, struct device_driver *drv);
+static int tiocx_reload(struct cx_dev *);
+static void tio_corelet_reset(nasid_t nasid, int corelet);
+
+static int tiocx_hotplug(struct device *dev, char **envp, int num_envp,
+			 char *buffer, int buffer_size)
+{
+	return -ENODEV;
+}
+
+static void tiocx_bus_release(struct device *dev)
+{
+}
+
+struct bus_type tiocx_bus_type = {
+	.name = "tiocx",
+	.match = tiocx_match,
+	.hotplug = tiocx_hotplug,
+};
+
+static ssize_t show_cxdev_control(struct device *dev, char *buf)
+{
+	struct cx_dev *cx_dev = to_cx_dev(dev);
+
+	return sprintf(buf, "0x%x 0x%x 0x%x\n",
+		       cx_dev->cx_id.nasid,
+		       cx_dev->cx_id.part_num, cx_dev->cx_id.mfg_num);
+}
+
+static ssize_t store_cxdev_control(struct device *dev, const char *buf,
+				   size_t count)
+{
+	int n;
+	struct cx_dev *cx_dev = to_cx_dev(dev);
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (count <= 0)
+		return 0;
+
+	n = simple_strtoul(buf, NULL, 0);
+
+	switch (n) {
+	case 1:
+		tiocx_reload(cx_dev);
+		break;
+	case 3:
+		tio_corelet_reset(cx_dev->cx_id.nasid, TIOCX_CORELET);
+		break;
+	default:
+		break;
+	}
+
+	return count;
+}
+
+DEVICE_ATTR(cxdev_control, 0644, show_cxdev_control, store_cxdev_control);
+
+/**
+ * cx_device_match - Find cx_device in the id table.
+ * @ids: id table from driver
+ * @cx_device: part/mfg id for the device
+ *
+ */
+static const struct cx_device_id *cx_device_match(const struct cx_device_id
+						  *ids,
+						  struct cx_dev *cx_device)
+{
+	/*
+	 * NOTES: We may want to check for CX_ANY_ID too.
+	 *        Do we want to match against nasid too?
+	 *        CX_DEV_NONE = 0, if the driver tries to register for
+	 *        part/mfg = 0 we should return no-match (NULL) here.
+	 */
+	while (ids->part_num && ids->mfg_num) {
+		if (ids->part_num = cx_device->cx_id.part_num &&
+		    ids->mfg_num = cx_device->cx_id.mfg_num)
+			return ids;
+		ids++;
+	}
+
+	return NULL;
+}
+
+/**
+ * cx_device_probe - Look for matching device.
+ *			Call driver probe routine if found.
+ * @cx_driver: driver table (cx_drv struct) from driver
+ * @cx_device: part/mfg id for the device
+ */
+static int cx_device_probe(struct device *dev)
+{
+	const struct cx_device_id *id;
+	struct cx_drv *cx_drv = to_cx_driver(dev->driver);
+	struct cx_dev *cx_dev = to_cx_dev(dev);
+	int error = 0;
+
+	if (!cx_dev->driver && cx_drv->probe) {
+		id = cx_device_match(cx_drv->id_table, cx_dev);
+		if (id) {
+			if ((error = cx_drv->probe(cx_dev, id)) < 0)
+				return error;
+			else
+				cx_dev->driver = cx_drv;
+		}
+	}
+
+	return error;
+}
+
+/**
+ * cx_driver_remove - Remove driver from device struct.
+ * @dev: device
+ */
+static int cx_driver_remove(struct device *dev)
+{
+	struct cx_dev *cx_dev = to_cx_dev(dev);
+	cx_dev->driver = NULL;
+	return 0;
+}
+
+/**
+ * cx_driver_register - Register the driver.
+ * @cx_driver: driver table (cx_drv struct) from driver
+ * 
+ * Called from the driver init routine to register a driver.
+ * The cx_drv struct contains the driver name, a pointer to
+ * a table of part/mfg numbers and a pointer to the driver's
+ * probe/attach routine.
+ */
+int cx_driver_register(struct cx_drv *cx_driver)
+{
+	cx_driver->driver.name = cx_driver->name;
+	cx_driver->driver.bus = &tiocx_bus_type;
+	cx_driver->driver.probe = cx_device_probe;
+	cx_driver->driver.remove = cx_driver_remove;
+
+	return driver_register(&cx_driver->driver);
+}
+
+/**
+ * cx_driver_unregister - Unregister the driver.
+ * @cx_driver: driver table (cx_drv struct) from driver
+ */
+int cx_driver_unregister(struct cx_drv *cx_driver)
+{
+	driver_unregister(&cx_driver->driver);
+	return 0;
+}
+
+/**
+ * cx_device_register - Register a device.
+ * @nasid: device's nasid
+ * @part_num: device's part number
+ * @mfg_num: device's manufacturer number
+ * @hubdev: hub info associated with this device
+ *
+ */
+int
+cx_device_register(nasid_t nasid, int part_num, int mfg_num,
+		   struct hubdev_info *hubdev)
+{
+	struct cx_dev *cx_dev;
+
+	cx_dev = kcalloc(1, sizeof(struct cx_dev), GFP_KERNEL);
+	DBG("cx_dev= 0x%p\n", cx_dev);
+	if (cx_dev = NULL)
+		return -ENOMEM;
+
+	cx_dev->cx_id.part_num = part_num;
+	cx_dev->cx_id.mfg_num = mfg_num;
+	cx_dev->cx_id.nasid = nasid;
+	cx_dev->hubdev = hubdev;
+
+	cx_dev->dev.parent = NULL;
+	cx_dev->dev.bus = &tiocx_bus_type;
+	cx_dev->dev.release = tiocx_bus_release;
+	snprintf(cx_dev->dev.bus_id, BUS_ID_SIZE, "%d.0x%x",
+		 cx_dev->cx_id.nasid, cx_dev->cx_id.part_num);
+	device_register(&cx_dev->dev);
+	get_device(&cx_dev->dev);
+
+	device_create_file(&cx_dev->dev, &dev_attr_cxdev_control);
+
+	return 0;
+}
+
+/**
+ * cx_device_unregister - Unregister a device.
+ * @cx_dev: part/mfg id for the device
+ */
+int cx_device_unregister(struct cx_dev *cx_dev)
+{
+	put_device(&cx_dev->dev);
+	device_unregister(&cx_dev->dev);
+	kfree(cx_dev);
+	return 0;
+}
+
+/**
+ * cx_device_reload - Reload the device.
+ * @nasid: device's nasid
+ * @part_num: device's part number
+ * @mfg_num: device's manufacturer number
+ *
+ * Remove the device associated with 'nasid' from device list and then
+ * call device-register with the given part/mfg numbers.
+ */
+static int cx_device_reload(struct cx_dev *cx_dev)
+{
+	device_remove_file(&cx_dev->dev, &dev_attr_cxdev_control);
+	cx_device_unregister(cx_dev);
+	return cx_device_register(cx_dev->cx_id.nasid, cx_dev->cx_id.part_num,
+				  cx_dev->cx_id.mfg_num, cx_dev->hubdev);
+}
+
+static inline uint64_t tiocx_intr_alloc(nasid_t nasid, int widget,
+					u64 sn_irq_info,
+					int req_irq, nasid_t req_nasid,
+					int req_slice)
+{
+	struct ia64_sal_retval rv;
+	rv.status = 0;
+	rv.v0 = 0;
+
+	ia64_sal_oemcall_nolock(&rv, SN_SAL_IOIF_INTERRUPT,
+				SAL_INTR_ALLOC, nasid,
+				widget, sn_irq_info, req_irq,
+				req_nasid, req_slice);
+	return rv.status;
+}
+
+static inline void tiocx_intr_free(nasid_t nasid, int widget,
+				   struct sn_irq_info *sn_irq_info)
+{
+	struct ia64_sal_retval rv;
+	rv.status = 0;
+	rv.v0 = 0;
+
+	ia64_sal_oemcall_nolock(&rv, SN_SAL_IOIF_INTERRUPT,
+				SAL_INTR_FREE, nasid,
+				widget, sn_irq_info->irq_irq,
+				sn_irq_info->irq_cookie, 0, 0);
+}
+
+struct sn_irq_info *tiocx_irq_alloc(nasid_t nasid, int widget, int irq,
+				    nasid_t req_nasid, int slice)
+{
+	struct sn_irq_info *sn_irq_info;
+	int status;
+	int sn_irq_size = sizeof(struct sn_irq_info);
+
+	if ((nasid & 1) = 0)
+		return NULL;
+
+	sn_irq_info = kmalloc(sn_irq_size, GFP_KERNEL);
+	if (sn_irq_info = NULL)
+		return NULL;
+
+	memset(sn_irq_info, 0x0, sn_irq_size);
+
+	status = tiocx_intr_alloc(nasid, widget, __pa(sn_irq_info), irq,
+				  req_nasid, slice);
+	if (status) {
+		kfree(sn_irq_info);
+		return NULL;
+	} else {
+		return sn_irq_info;
+	}
+}
+
+void tiocx_irq_free(struct sn_irq_info *sn_irq_info)
+{
+	uint64_t bridge = (uint64_t) sn_irq_info->irq_bridge;
+	nasid_t nasid = NASID_GET(bridge);
+	int widget;
+
+	if ((nasid & 1) = 0)
+		return;
+
+	widget = TIO_SWIN_WIDGETNUM(bridge);
+
+	tiocx_intr_free(nasid, widget, sn_irq_info);
+
+	kfree(sn_irq_info);
+}
+
+EXPORT_SYMBOL(cx_driver_register);
+EXPORT_SYMBOL(cx_driver_unregister);
+EXPORT_SYMBOL(cx_device_register);
+EXPORT_SYMBOL(cx_device_unregister);
+EXPORT_SYMBOL(tiocx_irq_alloc);
+EXPORT_SYMBOL(tiocx_irq_free);
+
+/**
+ * tiocx_match - Try to match driver id list with device.
+ * @dev: device pointer
+ * @drv: driver pointer
+ *
+ * Returns 1 if match, 0 otherwise.
+ */
+static int tiocx_match(struct device *dev, struct device_driver *drv)
+{
+	struct cx_dev *cx_dev = to_cx_dev(dev);
+	struct cx_drv *cx_drv = to_cx_driver(drv);
+	const struct cx_device_id *ids = cx_drv->id_table;
+
+	if (!ids)
+		return 0;
+
+	while (ids->part_num) {
+		if (ids->part_num = cx_dev->cx_id.part_num)
+			return 1;
+		ids++;
+	}
+	return 0;
+
+}
+
+static uint64_t tiocx_get_hubdev_info(u64 handle, u64 address)
+{
+
+	struct ia64_sal_retval ret_stuff;
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+
+	ia64_sal_oemcall_nolock(&ret_stuff,
+				SN_SAL_IOIF_GET_HUBDEV_INFO,
+				handle, address, 0, 0, 0, 0, 0);
+	return ret_stuff.v0;
+}
+
+static void tio_conveyor_set(nasid_t nasid, int enable_flag)
+{
+	u_int64_t ice_frz;
+	u_int64_t disable_cb = (1ull << 61);
+
+	if (!(nasid & 1))
+		return;
+
+	ice_frz = REMOTE_HUB_L(nasid, TIO_ICE_FRZ_CFG);
+	if (enable_flag) {
+		if (!(ice_frz & disable_cb))	/* already enabled */
+			return;
+		ice_frz &= ~disable_cb;
+	} else {
+		if (ice_frz & disable_cb)	/* already disabled */
+			return;
+		ice_frz |= disable_cb;
+	}
+	DBG(KERN_ALERT "TIO_ICE_FRZ_CFG= 0x%lx\n", ice_frz);
+	REMOTE_HUB_S(nasid, TIO_ICE_FRZ_CFG, ice_frz);
+}
+
+#define tio_conveyor_enable(nasid) tio_conveyor_set(nasid, 1)
+#define tio_conveyor_disable(nasid) tio_conveyor_set(nasid, 0)
+
+static void tio_corelet_reset(nasid_t nasid, int corelet)
+{
+	if (!(nasid & 1))
+		return;
+
+	REMOTE_HUB_S(nasid, TIO_ICE_PMI_TX_CFG, 1 << corelet);
+	udelay(2000);
+	REMOTE_HUB_S(nasid, TIO_ICE_PMI_TX_CFG, 0);
+	udelay(2000);
+}
+
+static int fpga_attached(nasid_t nasid)
+{
+	u_int64_t cx_credits;
+
+	cx_credits = REMOTE_HUB_L(nasid, TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3);
+	cx_credits &= TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3_CREDIT_CNT_MASK;
+	DBG("cx_credits= 0x%lx\n", cx_credits);
+
+	return (cx_credits = 0xf) ? 1 : 0;
+}
+
+static int tiocx_reload(struct cx_dev *cx_dev)
+{
+	int part_num = CX_DEV_NONE;
+	int mfg_num = CX_DEV_NONE;
+	nasid_t nasid = cx_dev->cx_id.nasid;
+
+	if (fpga_attached(nasid)) {
+		u_int64_t cx_id;
+
+		cx_id +		    *(volatile int32_t *)(TIO_SWIN_BASE(nasid, TIOCX_CORELET) +
+					  WIDGET_ID);
+		part_num = XWIDGET_PART_NUM(cx_id);
+		mfg_num = XWIDGET_MFG_NUM(cx_id);
+		DBG("part= 0x%x, mfg= 0x%x\n", part_num, mfg_num);
+		/* just ignore it if it's a CE */
+		if (part_num = TIO_CE_ASIC_PARTNUM)
+			return 0;
+	}
+
+       cx_dev->cx_id.part_num = part_num;
+       cx_dev->cx_id.mfg_num = mfg_num;
+
+	/*
+	 * Delete old device and register the new one.  It's ok if
+	 * part_num/mfg_num = CX_DEV_NONE.  We want to register
+	 * devices in the table even if a bitstream isn't loaded.
+	 * That allows use to see that a bitstream isn't loaded via
+	 * TIOCX_IOCTL_DEV_LIST.
+	 */
+	return cx_device_reload(cx_dev);
+}
+
+static int __init tiocx_init(void)
+{
+	cnodeid_t cnodeid;
+	int found_tiocx_device = 0;
+
+	bus_register(&tiocx_bus_type);
+
+	for (cnodeid = 0; cnodeid < MAX_COMPACT_NODES; cnodeid++) {
+		nasid_t nasid;
+
+		if ((nasid = cnodeid_to_nasid(cnodeid)) < 0)
+			break;	/* No more nasids .. bail out of loop */
+
+		if (nasid & 0x1) {	/* TIO's are always odd */
+			struct hubdev_info *hubdev;
+			uint64_t status;
+			struct xwidget_info *widgetp;
+
+			DBG("Found TIO at nasid 0x%x\n", nasid);
+
+			hubdev +			    (struct hubdev_info *)(NODEPDA(cnodeid)->pdinfo);
+			status +			    tiocx_get_hubdev_info(nasid,
+						  (uint64_t) __pa(hubdev));
+			if (status)
+				continue;
+
+			widgetp = &hubdev->hdi_xwidget_info[TIOCX_CORELET];
+
+			/* The CE hangs off of the CX port but is not an FPGA */
+			if (widgetp->xwi_hwid.part_num = TIO_CE_ASIC_PARTNUM)
+				continue;
+
+			tio_corelet_reset(nasid, TIOCX_CORELET);
+			tio_conveyor_enable(nasid);
+
+			if (cx_device_register
+			    (nasid, widgetp->xwi_hwid.part_num,
+			     widgetp->xwi_hwid.mfg_num, hubdev) < 0)
+				return -ENXIO;
+			else
+				found_tiocx_device++;
+		}
+	}
+
+	/* It's ok if we find zero devices. */
+	DBG("found_tiocx_device= %d\n", found_tiocx_device);
+
+	return 0;
+}
+
+static void __exit tiocx_exit(void)
+{
+	struct device *dev;
+	struct device *tdev;
+
+	DBG("tiocx_exit\n");
+
+	/*
+	 * Unregister devices.
+	 */
+	list_for_each_entry_safe(dev, tdev, &tiocx_bus_type.devices.list,
+				 bus_list) {
+		if (dev) {
+			struct cx_dev *cx_dev = to_cx_dev(dev);
+			device_remove_file(dev, &dev_attr_cxdev_control);
+			cx_device_unregister(cx_dev);
+		}
+	}
+
+	bus_unregister(&tiocx_bus_type);
+}
+
+module_init(tiocx_init);
+module_exit(tiocx_exit);
+
+/************************************************************************
+ * Module licensing and description
+ ************************************************************************/
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Bruce Losure <blosure@sgi.com>");
+MODULE_DESCRIPTION("TIOCX module");
+MODULE_SUPPORTED_DEVICE(DEVICE_NAME);
diff -Nru a/drivers/char/tiocx.h b/drivers/char/tiocx.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/char/tiocx.h	2005-02-10 11:00:30 -06:00
@@ -0,0 +1,58 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#ifndef _ASM_IA64_SN_TIO_TIOCX_H
+#define _ASM_IA64_SN_TIO_TIOCX_H
+
+struct cx_id_s {
+	unsigned int part_num;
+	unsigned int mfg_num;
+	int nasid;
+};
+
+struct cx_dev {
+	struct cx_id_s cx_id;
+	struct hubdev_info *hubdev;
+	struct device dev;
+	struct cx_drv *driver;
+};
+
+struct cx_device_id {
+	unsigned int part_num;
+	unsigned int mfg_num;
+};
+
+struct cx_drv {
+	char *name;
+	const struct cx_device_id *id_table;
+	struct device_driver driver;
+	int (*probe) (struct cx_dev * dev, const struct cx_device_id * id);
+};
+
+/* create DMA address by stripping AS bits */
+#define TIOCX_DMA_ADDR(a) (uint64_t)((uint64_t)(a) & 0xffffcfffffffffUL)
+
+#define TIOCX_TO_TIOCX_DMA_ADDR(a) (uint64_t)(((uint64_t)(a) & 0xfffffffff) |  \
+                                  ((((uint64_t)(a)) & 0xffffc000000000UL) <<2))
+
+#define TIO_CE_ASIC_PARTNUM 0xce00
+#define TIOCX_CORELET 3
+
+/* These are taken from tio_mmr_as.h */
+#define TIO_ICE_FRZ_CFG               TIO_MMR_ADDR_MOD(0x00000000b0008100UL)
+#define TIO_ICE_PMI_TX_CFG            TIO_MMR_ADDR_MOD(0x00000000b000b100UL)
+#define TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3 TIO_MMR_ADDR_MOD(0x00000000b000be18UL)
+#define TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3_CREDIT_CNT_MASK 0x000000000000000fUL
+
+#define to_cx_dev(n) container_of(n, struct cx_dev, dev)
+#define to_cx_driver(drv) container_of(drv, struct cx_drv, driver)
+
+#endif				// _ASM_IA64_SN_TIO_TIOCX__
diff -Nru a/include/asm-ia64/sn/addrs.h b/include/asm-ia64/sn/addrs.h
--- a/include/asm-ia64/sn/addrs.h	2005-02-10 11:00:30 -06:00
+++ b/include/asm-ia64/sn/addrs.h	2005-02-10 11:00:30 -06:00
@@ -167,7 +167,9 @@
 #define TIO_BWIN_SIZE_BITS		30	/* big window size: 1G */
 #define NODE_SWIN_BASE(n, w)		((w = 0) ? NODE_BWIN_BASE((n), SWIN0_BIGWIN) \
 		: RAW_NODE_SWIN_BASE(n, w))
+#define TIO_SWIN_BASE(n, w) 		(TIO_IO_BASE(n) + ((u64) (w) << TIO_SWIN_SIZE_BITS))
 #define NODE_IO_BASE(n)			(GLOBAL_MMR_SPACE | NASID_SPACE(n))
+#define TIO_IO_BASE(n)                  (UNCACHED | NASID_SPACE(n))
 #define BWIN_SIZE			(1UL << BWIN_SIZE_BITS)
 #define NODE_BWIN_BASE0(n)		(NODE_IO_BASE(n) + BWIN_SIZE)
 #define NODE_BWIN_BASE(n, w)		(NODE_BWIN_BASE0(n) + ((u64) (w) << BWIN_SIZE_BITS))
@@ -177,8 +179,6 @@
 
 #define TIO_BWIN_WINDOW_SELECT_MASK	0x7
 #define TIO_BWIN_WINDOWNUM(x)		(((x) >> TIO_BWIN_SIZE_BITS) & TIO_BWIN_WINDOW_SELECT_MASK)
-
-
 
 /*
  * The following definitions pertain to the IO special address

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121

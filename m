From: Bruce Losure <blosure@sgi.com>
Date: Mon, 31 Jan 2005 21:11:01 +0000
Subject: [PATCH 2.6.11] Altix patch for device driver support for the CX port
Message-Id: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch provide support for the CX port of the SGI TIO chip.
The CX port of the SGI TIO chip may be connected to FPGA based
hardware.  The changes in this patch may be used in support of device
driver developers who are writing drivers for that FPGA hardware.
The module provides driver registration/unregistration routines, device
registration/unregistration routines, interrupt allocation/deallocation
and an ioctl.

Signed-off-by: Bruce Losure <blosure@sgi.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/31 14:53:12-06:00 blosure@attica.americas.sgi.com 
#   Add support for TIO CX port.  That port may be connected to FPGA-based
#   hardware.   This module provides support to device driver developers
#   for that hardware.   The module provides registration facilities similar
#   to pci.   It also provides interrupt allocation/deallocation and
#   an ioctl syscall for user space interaction.
# 
# arch/ia64/sn/kernel/tiocx.c
#   2005/01/31 14:53:00-06:00 blosure@attica.americas.sgi.com +564 -0
# 
# arch/ia64/sn/kernel/tiocx.c
#   2005/01/31 14:53:00-06:00 blosure@attica.americas.sgi.com +0 -0
#   BitKeeper file /data/lwork/attica1/blosure/bktrees/tiocx2_6_11/arch/ia64/sn/kernel/tiocx.c
# 
# arch/ia64/sn/include/tiocx.h
#   2005/01/31 14:52:59-06:00 blosure@attica.americas.sgi.com +69 -0
# 
# include/asm-ia64/sn/addrs.h
#   2005/01/31 14:52:59-06:00 blosure@attica.americas.sgi.com +2 -2
#   Add TIO base address and TIO small window base address macros.
# 
# arch/ia64/sn/kernel/setup.c
#   2005/01/31 14:52:59-06:00 blosure@attica.americas.sgi.com +1 -0
#   Export pda_percpu so that loadable modules can use cnodeid<->nasid
#   macros.
# 
# arch/ia64/sn/kernel/Makefile
#   2005/01/31 14:52:59-06:00 blosure@attica.americas.sgi.com +1 -0
#   Add tiocx module to Makefile.
# 
# arch/ia64/sn/include/tiocx.h
#   2005/01/31 14:52:59-06:00 blosure@attica.americas.sgi.com +0 -0
#   BitKeeper file /data/lwork/attica1/blosure/bktrees/tiocx2_6_11/arch/ia64/sn/include/tiocx.h
# 
diff -Nru a/arch/ia64/sn/include/tiocx.h b/arch/ia64/sn/include/tiocx.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/sn/include/tiocx.h	2005-01-31 14:54:21 -06:00
@@ -0,0 +1,69 @@
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
+#include <linux/ioctl.h>
+
+typedef struct cx_id_s {
+	unsigned int part_num;
+	unsigned int mfg_num;
+	int nasid;
+} cx_id_t;
+
+#define TIOCX_IOCTL_BASE	0xdd	// see Documentation/ioctl-number.txt
+#define TIOCX_IOCTL_CX_RELOAD   _IO(TIOCX_IOCTL_BASE, 1)
+#define TIOCX_IOCTL_DEV_LIST    _IO(TIOCX_IOCTL_BASE, 2)
+
+typedef struct cx_dev_ioctl_s {
+	int nelem;
+	cx_id_t *cx_dev_array;
+} cx_dev_ioctl_t;
+
+#ifdef __KERNEL__
+
+#include <linux/list.h>
+#include <asm-ia64/sn/types.h>
+
+struct cx_dev {
+	struct list_head global_list;	/* node in list of all cx devices */
+	cx_id_t cx_id;
+	struct hubdev_info *hubdev;
+	struct cx_drv *driver;
+};
+
+struct cx_device_id {
+	unsigned int part_num;
+	unsigned int mfg_num;
+};
+
+struct cx_drv {
+	struct list_head node;
+	char *name;
+	const struct cx_device_id *id_table;
+	int (*probe) (struct cx_dev * dev, const struct cx_device_id * id);
+};
+
+/* create DMA address by stripping AS bits */
+#define TIOCX_DMA_ADDR(a) (uint64_t)((uint64_t)(a) & 0xffffcfffffffff)
+
+#define TIOCX_TO_TIOCX_DMA_ADDR(a) (uint64_t)(((uint64_t)(a) & 0xfffffffff) |  \
+                                  ((((uint64_t)(a)) & 0xffffc000000000) <<2))
+
+#define TIO_CE_ASIC_PARTNUM 0xce00
+#define TIOCX_CORELET 3
+
+/* These are taken from tio_mmr_as.h */
+#define TIO_ICE_FRZ_CFG                    TIO_MMR_ADDR_MOD(0x00000000b0008100)
+#define TIO_ICE_PMI_TX_CFG                 TIO_MMR_ADDR_MOD(0x00000000b000b100)
+#define TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3 TIO_MMR_ADDR_MOD(0x00000000b000be18)
+#define TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3_CREDIT_CNT_MASK 0x000000000000000f
+
+#endif				//  __KERNEL__
+#endif				// _ASM_IA64_SN_TIO_TIOCX__
diff -Nru a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
--- a/arch/ia64/sn/kernel/Makefile	2005-01-31 14:54:21 -06:00
+++ b/arch/ia64/sn/kernel/Makefile	2005-01-31 14:54:21 -06:00
@@ -10,3 +10,4 @@
 obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
 				   huberror.o io_init.o iomv.o klconflib.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
+obj-m 				+= tiocx.o
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	2005-01-31 14:54:21 -06:00
+++ b/arch/ia64/sn/kernel/setup.c	2005-01-31 14:54:21 -06:00
@@ -53,6 +53,7 @@
 
 
 DEFINE_PER_CPU(struct pda_s, pda_percpu);
+EXPORT_PER_CPU_SYMBOL(pda_percpu);
 
 #define MAX_PHYS_MEMORY		(1UL << 49)	/* 1 TB */
 
diff -Nru a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/sn/kernel/tiocx.c	2005-01-31 14:54:21 -06:00
@@ -0,0 +1,564 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+#include <asm/sn/types.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/proc_fs.h>
+#include <asm/sn/sn_sal.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/io.h>
+#include "shubio.h"
+#include "tio.h"
+#include "tiocx.h"
+#include "xtalk/xwidgetdev.h"
+#include "xtalk/hubdev.h"
+#include <asm-ia64/delay.h>
+#include <asm/uaccess.h>
+
+#define CX_DEV_NONE 0
+#define DEVICE_NAME "tiocx"
+#define WIDGET_ID 0
+
+static int tiocx_debug;		/* debug switch */
+MODULE_PARM(tiocx_debug, "i");
+#define DBG(fmt...)    if (tiocx_debug) printk(KERN_ALERT fmt)
+
+static LIST_HEAD(cx_device_list);
+static DECLARE_MUTEX(cx_device_sem);
+static LIST_HEAD(cx_driver_list);
+static DECLARE_MUTEX(cx_driver_sem);
+static spinlock_t cx_device_spin;
+static spinlock_t cx_driver_spin;
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
+ * cx_device_announce - Look for matching device.
+ *			Call driver probe routine if found.
+ * @cx_driver: driver table (cx_drv struct) from driver
+ * @cx_device: part/mfg id for the device
+ */
+static int
+cx_device_announce(struct cx_drv *cx_driver, struct cx_dev *cx_device)
+{
+	const struct cx_device_id *id;
+	int ret = 0;
+
+	if (cx_driver->id_table) {
+		id = cx_device_match(cx_driver->id_table, cx_device);
+		if (!id) {
+			ret = 0;
+			goto out;
+		}
+	} else
+		id = NULL;	/* careful here. */
+	/* driver probe routine needs to know */
+
+	down_interruptible(&cx_driver_sem);
+
+	if (cx_driver->probe(cx_device, id) >= 0) {
+		cx_device->driver = cx_driver;
+		ret = 1;
+	}
+	up(&cx_driver_sem);
+      out:
+	return ret;
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
+	struct list_head *lp;
+	int count = 0;
+
+	spin_lock(&cx_driver_spin);
+	list_add_tail((struct list_head *)cx_driver, &cx_driver_list);
+	spin_unlock(&cx_driver_spin);
+	list_for_each(lp, &cx_device_list) {
+		count += cx_device_announce(cx_driver, (struct cx_dev *)lp);
+	}
+
+	return count;
+}
+
+/**
+ * cx_driver_unregister - Unregister the driver.
+ * @cx_driver: driver table (cx_drv struct) from driver
+ */
+int cx_driver_unregister(struct cx_drv *cx_driver)
+{
+	struct list_head *lp, *tmp;
+
+	/* remove driver from cx_driver_list */
+	spin_lock(&cx_driver_spin);
+	list_for_each_safe(lp, tmp, (struct list_head *)&cx_driver_list) {
+		if (lp = (struct list_head *)cx_driver) {
+			DBG("Deleting 0x%p from cx_driver_list\n", lp);
+			list_del((struct list_head *)lp);
+			break;
+		}
+	}
+	spin_unlock(&cx_driver_spin);
+
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
+ * Basically build a cx_dev struct and add it to the list.
+ */
+int
+cx_device_register(nasid_t nasid, int part_num, int mfg_num,
+		   struct hubdev_info *hubdev)
+{
+	struct cx_dev *cx_dev;
+
+	cx_dev = (struct cx_dev *)kmalloc(sizeof(struct cx_dev), GFP_KERNEL);
+	DBG("cx_dev= 0x%p\n", cx_dev);
+	if (cx_dev = NULL)
+		return -ENOMEM;
+
+	cx_dev->cx_id.part_num = part_num;
+	cx_dev->cx_id.mfg_num = mfg_num;
+	cx_dev->cx_id.nasid = nasid;
+	cx_dev->hubdev = hubdev;
+
+	spin_lock(&cx_device_spin);
+	list_add_tail((struct list_head *)cx_dev, &cx_device_list);
+	spin_unlock(&cx_device_spin);
+
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
+int cx_device_reload(nasid_t nasid, int part_num, int mfg_num)
+{
+	struct list_head *lp, *tmp;
+	struct hubdev_info *hubdev = NULL;
+
+	/* remove device from cx_device_list */
+	spin_lock(&cx_device_spin);
+	list_for_each_safe(lp, tmp, (struct list_head *)&cx_device_list) {
+		struct cx_dev *cx_dev = (struct cx_dev *)lp;
+		if (cx_dev->cx_id.nasid = nasid) {
+			hubdev = cx_dev->hubdev;
+			DBG("Deleting 0x%p from cx_device_list\n", lp);
+			list_del((struct list_head *)lp);
+			break;
+		}
+	}
+	spin_unlock(&cx_device_spin);
+
+	if (hubdev = NULL)
+		return -ENXIO;
+
+	return cx_device_register(nasid, part_num, mfg_num, hubdev);
+}
+
+/**
+ * cx_device_unregister - Unregister a device.
+ * @cx_dev: part/mfg id for the device
+ */
+int cx_device_unregister(struct cx_dev *cx_dev)
+{
+	struct list_head *lp, *tmp;
+
+	/* remove device from cx_device_list */
+	spin_lock(&cx_device_spin);
+	list_for_each_safe(lp, tmp, (struct list_head *)&cx_device_list) {
+		if (lp = (struct list_head *)cx_dev) {
+			DBG("Deleting 0x%p from cx_device_list\n", lp);
+			list_del((struct list_head *)lp);
+			break;
+		}
+	}
+	spin_unlock(&cx_device_spin);
+
+	return 0;
+}
+
+/**
+ * cx_devicelist_delete - Clean up at exit.
+ */
+static void cx_devicelist_delete(void)
+{
+	struct list_head *lp, *tmp;
+
+	/* remove device from cx_device_list */
+	spin_lock(&cx_device_spin);
+	list_for_each_safe(lp, tmp, (struct list_head *)&cx_device_list) {
+		DBG("Deleting 0x%p from cx_device_list\n", lp);
+		list_del((struct list_head *)lp);
+	}
+	spin_unlock(&cx_device_spin);
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
+	ia64_sal_oemcall_nolock(&rv, (u64) SN_SAL_IOIF_INTERRUPT,
+				(u64) SAL_INTR_ALLOC, (u64) nasid,
+				(u64) widget, (u64) sn_irq_info, (u64) req_irq,
+				(u64) req_nasid, (u64) req_slice);
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
+	ia64_sal_oemcall_nolock(&rv, (u64) SN_SAL_IOIF_INTERRUPT,
+				(u64) SAL_INTR_FREE, (u64) nasid,
+				(u64) widget, (u64) sn_irq_info->irq_irq,
+				(u64) sn_irq_info->irq_cookie, 0, 0);
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
+static uint64_t tiocx_get_hubdev_info(u64 handle, u64 address)
+{
+
+	struct ia64_sal_retval ret_stuff;
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+
+	ia64_sal_oemcall_nolock(&ret_stuff,
+				(u64) SN_SAL_IOIF_GET_HUBDEV_INFO,
+				(u64) handle, (u64) address, 0, 0, 0, 0, 0);
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
+static int tiocx_reload(nasid_t nasid)
+{
+	int part_num = CX_DEV_NONE;
+	int mfg_num = CX_DEV_NONE;
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
+	/*
+	 * Delete old device and register the new one.  It's ok if
+	 * part_num/mfg_num = CX_DEV_NONE.  We want to register
+	 * devices in the table even if a bitstream isn't loaded.
+	 * That allows use to see that a bitstream isn't loaded via
+	 * TIOCX_IOCTL_DEV_LIST.
+	 */
+	return cx_device_reload(nasid, part_num, mfg_num);
+}
+
+int tiocx_open(struct inode *ip, struct file *fp)
+{
+	if (ip = NULL) {
+		return -EINVAL;
+	}
+	if (fp = NULL) {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+ * tiocx_ioctl - ioctl interface for tiocx
+ *
+ * ioctl commands:
+ *	TIOCX_IOCTL_DEV_LIST:   List devices.
+ *      TIOCX_IOCTL_CX_RELOAD:  Reset and reload device list.   Update
+ *				the device list when bitstreams are reloaded.
+ */
+int
+tiocx_ioctl(struct inode *ip, struct file *filp, unsigned int cmd,
+	    unsigned long arg)
+{
+
+	switch (cmd) {
+	case TIOCX_IOCTL_DEV_LIST:
+		{
+			struct list_head *lp;
+			cx_dev_ioctl_t cx_devlist_ioctl;
+			int nelem, n;
+			char *p;
+			copy_from_user(&cx_devlist_ioctl, (void *)arg,
+				       sizeof(cx_dev_ioctl_t));
+			n = nelem = cx_devlist_ioctl.nelem;
+			if (nelem <= 0)
+				break;
+			p = (char *)cx_devlist_ioctl.cx_dev_array;
+			list_for_each(lp, &cx_device_list) {
+				copy_to_user(p, &((struct cx_dev *)lp)->cx_id,
+					     sizeof(cx_id_t));
+				p += sizeof(cx_id_t);
+				n--;
+				if (nelem <= 0)
+					break;
+			}
+			cx_devlist_ioctl.nelem = nelem - n;
+			copy_to_user((void *)arg, &cx_devlist_ioctl,
+				     sizeof(cx_dev_ioctl_t));
+		}
+		break;
+	case TIOCX_IOCTL_CX_RELOAD:
+		tiocx_reload((nasid_t) arg);
+		break;
+	}
+	return 0;
+}
+
+int tiocx_major = -1;
+struct file_operations tiocx_ops = {
+	.open = tiocx_open,
+	.ioctl = tiocx_ioctl,
+};
+
+static int __init tiocx_init(void)
+{
+	cnodeid_t cnodeid;
+	int found_tiocx_device = 0;
+	int rv;
+
+	rv = register_chrdev(0, DEVICE_NAME, &tiocx_ops);
+	if (rv < 0) {
+		printk(KERN_ALERT "tiocx_init: can't get major number. %d\n",
+		       rv);
+		return rv;
+	}
+	tiocx_major = rv;
+
+	DBG("tiocx_init: tiocx_major= %d\n", tiocx_major);
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
+			tio_corelet_reset(nasid, 3);
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
+	int rv;
+
+	DBG("tiocx_exit\n");
+
+	rv = unregister_chrdev(tiocx_major, DEVICE_NAME);
+	if (rv < 0)
+		printk(KERN_ALERT "Error in unregister_chrdev: %d\n", rv);
+
+	cx_devicelist_delete();
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
diff -Nru a/include/asm-ia64/sn/addrs.h b/include/asm-ia64/sn/addrs.h
--- a/include/asm-ia64/sn/addrs.h	2005-01-31 14:54:21 -06:00
+++ b/include/asm-ia64/sn/addrs.h	2005-01-31 14:54:21 -06:00
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


From: Christoph Hellwig <hch@lst.de>
Date: Thu, 25 Sep 2003 19:55:28 +0000
Subject: [PATCH] kill sn2 inventory stubs
Message-Id: <marc-linux-ia64-106451999732540@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just some crappy stubs that sneaked over from IRIX.


--- 1.1/arch/ia64/sn/io/hwgfs/Makefile	Fri May 16 20:50:50 2003
+++ edited/arch/ia64/sn/io/hwgfs/Makefile	Thu Sep 25 11:55:26 2003
@@ -9,5 +9,4 @@
 
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
-obj-y				+= hcl.o labelcl.o hcl_util.o invent_stub.o \
-				   ramfs.o interface.o
+obj-y		+= hcl.o labelcl.o hcl_util.o ramfs.o interface.o
--- 1.1/arch/ia64/sn/io/hwgfs/invent_stub.c	Fri May 16 20:50:50 2003
+++ edited/arch/ia64/sn/io/hwgfs/invent_stub.c	Thu Sep 25 11:55:26 2003
@@ -1,148 +0,0 @@
-/* $Id$
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992-1997,2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-
-/*
- * Hardware Inventory
- *
- * See sys/sn/invent.h for an explanation of the hardware inventory contents.
- *
- */
-#include <linux/types.h>
-#include <asm/sn/sgi.h>
-#include <asm/sn/hwgfs.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-#include <asm/sn/invent.h>
-
-void
-inventinit(void)
-{
-}
-
-/*
- * For initializing/updating an inventory entry.
- */
-void
-replace_in_inventory(
-	inventory_t *pinv, int class, int type,
-	int controller, int unit, int state)
-{
-}
-
-/*
- * Inventory addition 
- *
- * XXX NOTE: Currently must be called after dynamic memory allocator is
- * initialized.
- *
- */
-void
-add_to_inventory(int class, int type, int controller, int unit, int state)
-{
-}
-
-
-/*
- * Inventory retrieval 
- *
- * These two routines are intended to prevent the caller from having to know
- * the internal structure of the inventory table.
- *
- * The caller of get_next_inventory is supposed to call start_scan_invent
- * before the irst call to get_next_inventory, and the caller is required
- * to call end_scan_invent after the last call to get_next_inventory.
- */
-inventory_t *
-get_next_inventory(invplace_t *place)
-{
-	return((inventory_t *) NULL);
-}
-
-/* ARGSUSED */
-int
-get_sizeof_inventory(int abi)
-{
-	return sizeof(inventory_t);
-}
-
-/* Must be called prior to first call to get_next_inventory */
-void
-start_scan_inventory(invplace_t *iplace)
-{
-}
-
-/* Must be called after last call to get_next_inventory */
-void
-end_scan_inventory(invplace_t *iplace)
-{
-}
-
-/*
- * Hardware inventory scanner.
- *
- * Calls fun() for every entry in inventory list unless fun() returns something
- * other than 0.
- */
-int
-scaninvent(int (*fun)(inventory_t *, void *), void *arg)
-{
-	return 0;
-}
-
-/*
- * Find a particular inventory object
- *
- * pinv can be a pointer to an inventory entry and the search will begin from
- * there, or it can be 0 in which case the search starts at the beginning.
- * A -1 for any of the other arguments is a wildcard (i.e. it always matches).
- */
-inventory_t *
-find_inventory(inventory_t *pinv, int class, int type, int controller,
-	       int unit, int state)
-{
-	return((inventory_t *) NULL);
-}
-
-
-/*
-** Retrieve inventory data associated with a device.
-*/
-inventory_t *
-device_inventory_get_next(	vertex_hdl_t device,
-				invplace_t *invplace)
-{
-		return((inventory_t *) NULL);
-}
-
-
-/*
-** Associate canonical inventory information with a device (and
-** add it to the general inventory).
-*/
-void
-device_inventory_add(	vertex_hdl_t device,
-			int class, 
-			int type, 
-			major_t controller, 
-			minor_t unit, 
-			int state)
-{
-}
-
-int
-device_controller_num_get(vertex_hdl_t device)
-{
-	return (0);
-}
-
-void
-device_controller_num_set(vertex_hdl_t device, int contr_num)
-{
-}
--- 1.3/arch/ia64/sn/io/sn2/ml_iograph.c	Mon May 19 14:42:20 2003
+++ edited/arch/ia64/sn/io/sn2/ml_iograph.c	Thu Sep 25 11:56:27 2003
@@ -329,28 +329,6 @@
 	}
 }
 
-/* Add inventory information to the widget vertex 
- * Right now (module,slot,revision) is being
- * added as inventory information.
- */
-static void
-xwidget_inventory_add(vertex_hdl_t 		widgetv,
-		      lboard_t 			*board,
-		      struct xwidget_hwid_s 	hwid)
-{
-	if (!board)
-		return;
-	/* Donot add inventory information for the baseio
-	 * on a speedo with an xbox. It has already been
-	 * taken care of in SN00_vmc.
-	 * Speedo with xbox's baseio comes in at slot io1 (widget 9)
-	 */
-	device_inventory_add(widgetv,INV_IOBD,board->brd_type,
-			     geo_module(board->brd_geoid),
-			     SLOTNUM_GETSLOT(board->brd_slot),
-			     hwid.rev_num);
-}
-
 /*
  * io_xswitch_widget_init
  *	
@@ -494,10 +472,6 @@
 		hwid.part_num = XWIDGET_PART_NUM(widget_id);
 		hwid.rev_num = XWIDGET_REV_NUM(widget_id);
 		hwid.mfg_num = XWIDGET_MFG_NUM(widget_id);
-		/* Store some inventory information about
-		 * the xwidget in the hardware graph.
-		 */
-		xwidget_inventory_add(widgetv,board,hwid);
 
 		(void)xwidget_register(&hwid, widgetv, widgetnum,
 				       hubv, hub_widgetid);
--- 1.3/arch/ia64/sn/io/sn2/pciio.c	Thu Jul  3 21:55:24 2003
+++ edited/arch/ia64/sn/io/sn2/pciio.c	Thu Sep 25 11:56:48 2003
@@ -1254,24 +1254,6 @@
     hwgraph_vertex_destroy(pconn);
     
 }
-/* Add the pci card inventory information to the hwgraph
- */
-static void
-pciio_device_inventory_add(vertex_hdl_t pconn_vhdl)
-{
-    pciio_info_t	pciio_info = pciio_info_get(pconn_vhdl);
-
-    ASSERT(pciio_info);
-    ASSERT(pciio_info->c_vertex = pconn_vhdl);
-
-    /* Donot add inventory  for non-existent devices */
-    if ((pciio_info->c_vendor = PCIIO_VENDOR_ID_NONE)	||
-	(pciio_info->c_device = PCIIO_DEVICE_ID_NONE))
-	return;
-    device_inventory_add(pconn_vhdl,INV_IOBD,INV_PCIADAP,
-			 pciio_info->c_vendor,pciio_info->c_device,
-			 pciio_info->c_slot);
-}
 
 /*ARGSUSED */
 int
@@ -1283,7 +1265,6 @@
     pciio_device_id_t       device_id;
 
 
-    pciio_device_inventory_add(pconn);
     pciio_info = pciio_info_get(pconn);
 
     vendor_id = pciio_info->c_vendor;
--- 1.4/include/asm-ia64/sn/invent.h	Fri May 16 13:18:17 2003
+++ edited/include/asm-ia64/sn/invent.h	Thu Sep 25 11:55:26 2003
@@ -720,28 +720,14 @@
 extern invplace_t invplace_none;
 #define INVPLACE_NONE invplace_none
 
-extern void	    add_to_inventory(int, int, int, int, int);
-extern void	    replace_in_inventory(inventory_t *, int, int, int, int, int);
-extern void         start_scan_inventory(invplace_t *);
-extern inventory_t  *get_next_inventory(invplace_t *);
-extern void         end_scan_inventory(invplace_t *);
-extern inventory_t  *find_inventory(inventory_t *, int, int, int, int, int);
-extern int	    scaninvent(int (*)(inventory_t *, void *), void *);
-extern int	    get_sizeof_inventory(int);
-
-extern void device_inventory_add(	vertex_hdl_t device, 
+static inline void device_inventory_add(vertex_hdl_t device, 
 					int class, 
 					int type, 
 					major_t ctlr, 
 					minor_t unit, 
-					int state);
-
-
-extern inventory_t *device_inventory_get_next(	vertex_hdl_t device,
-						invplace_t *);
+					int state)
+{
+}
 
-extern void device_controller_num_set(	vertex_hdl_t,
-					int);
-extern int device_controller_num_get(	vertex_hdl_t);
 #endif /* __KERNEL__ */
 #endif /* _ASM_IA64_SN_INVENT_H */

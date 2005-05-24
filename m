From: Bruce Losure <blosure@americas.sgi.com>
Date: Tue, 24 May 2005 15:30:01 +0000
Subject: [PATCH 2.6] Altix patch to tiocx, add subsys_initcall
Message-Id: <Pine.LNX.4.44.0505241025340.25197-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

This patch fixes an ordering issue between the init code for the
tiocx bus driver and tiocx-related device drivers.   Also adds
a new brick to the list of known FPGA bricks.

Thanks,
-Bruce

Signed-off-by: Bruce Losure <blosure@sgi.com>

Index: linux-2.6.git/arch/ia64/sn/kernel/tiocx.c
=================================--- linux-2.6.git.orig/arch/ia64/sn/kernel/tiocx.c	2005-05-24 07:52:15.271630866 -0500
+++ linux-2.6.git/arch/ia64/sn/kernel/tiocx.c	2005-05-24 08:01:17.977721872 -0500
@@ -204,8 +204,8 @@
 	cx_dev->dev.parent = NULL;
 	cx_dev->dev.bus = &tiocx_bus_type;
 	cx_dev->dev.release = tiocx_bus_release;
-	snprintf(cx_dev->dev.bus_id, BUS_ID_SIZE, "%d.0x%x",
-		 cx_dev->cx_id.nasid, cx_dev->cx_id.part_num);
+	snprintf(cx_dev->dev.bus_id, BUS_ID_SIZE, "%d",
+		 cx_dev->cx_id.nasid);
 	device_register(&cx_dev->dev);
 	get_device(&cx_dev->dev);
 
@@ -236,7 +236,6 @@
  */
 static int cx_device_reload(struct cx_dev *cx_dev)
 {
-	device_remove_file(&cx_dev->dev, &dev_attr_cxdev_control);
 	cx_device_unregister(cx_dev);
 	return cx_device_register(cx_dev->cx_id.nasid, cx_dev->cx_id.part_num,
 				  cx_dev->cx_id.mfg_num, cx_dev->hubdev);
@@ -383,6 +382,7 @@
 	switch (tiocx_btchar_get(nasid)) {
 	case L1_BRICKTYPE_SA:
 	case L1_BRICKTYPE_ATHENA:
+	case L1_BRICKTYPE_DAYTONA:
 		return 1;
 	}
 	return 0;
@@ -409,7 +409,7 @@
 		uint64_t cx_id;
 
 		cx_id -		    *(volatile int32_t *)(TIO_SWIN_BASE(nasid, TIOCX_CORELET) +
+		    *(volatile uint64_t *)(TIO_SWIN_BASE(nasid, TIOCX_CORELET) +
 					  WIDGET_ID);
 		part_num = XWIDGET_PART_NUM(cx_id);
 		mfg_num = XWIDGET_MFG_NUM(cx_id);
@@ -458,6 +458,10 @@
 
 	switch (n) {
 	case 1:
+		tio_corelet_reset(cx_dev->cx_id.nasid, TIOCX_CORELET);
+		tiocx_reload(cx_dev);
+		break;
+	case 2:
 		tiocx_reload(cx_dev);
 		break;
 	case 3:
@@ -540,7 +544,7 @@
 	bus_unregister(&tiocx_bus_type);
 }
 
-module_init(tiocx_init);
+subsys_initcall(tiocx_init);
 module_exit(tiocx_exit);
 
 /************************************************************************
Index: linux-2.6.git/include/asm-ia64/sn/l1.h
=================================--- linux-2.6.git.orig/include/asm-ia64/sn/l1.h	2005-05-24 07:52:23.605509926 -0500
+++ linux-2.6.git/include/asm-ia64/sn/l1.h	2005-05-24 08:00:56.073697224 -0500
@@ -33,5 +33,6 @@
 #define L1_BRICKTYPE_PA		0x6a            /* j */
 #define L1_BRICKTYPE_IA		0x6b            /* k */
 #define L1_BRICKTYPE_ATHENA	0x2b            /* + */
+#define L1_BRICKTYPE_DAYTONA	0x7a            /* z */
 
 #endif /* _ASM_IA64_SN_L1_H */


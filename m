From: Bruce Losure <blosure@americas.sgi.com>
Date: Fri, 02 Sep 2005 20:16:35 +0000
Subject: [PATCH] Altix patch for fpga reset
Message-Id: <Pine.LNX.4.44.0509021513240.12217-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

Here is a patch to 1) workaround a h/w reset issue and 2) to improve the
determination of FPGA-based h/w in the arch/ia64/sn/kernel/tiocx code.

Thanks,
-Bruce

Signed-off-by: Bruce Losure <blosure@sgi.com>

Index: linux-2.6/arch/ia64/sn/kernel/tiocx.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/tiocx.c	2005-09-02 07:41:10.316907972 -0500
+++ linux-2.6/arch/ia64/sn/kernel/tiocx.c	2005-09-02 14:26:24.264710023 -0500
@@ -183,11 +183,12 @@
  * @part_num: device's part number
  * @mfg_num: device's manufacturer number
  * @hubdev: hub info associated with this device
+ * @bt: board type of the device
  *
  */
 int
 cx_device_register(nasid_t nasid, int part_num, int mfg_num,
-		   struct hubdev_info *hubdev)
+		   struct hubdev_info *hubdev, int bt)
 {
 	struct cx_dev *cx_dev;
 
@@ -200,6 +201,7 @@
 	cx_dev->cx_id.mfg_num = mfg_num;
 	cx_dev->cx_id.nasid = nasid;
 	cx_dev->hubdev = hubdev;
+	cx_dev->bt = bt;
 
 	cx_dev->dev.parent = NULL;
 	cx_dev->dev.bus = &tiocx_bus_type;
@@ -238,7 +240,8 @@
 {
 	cx_device_unregister(cx_dev);
 	return cx_device_register(cx_dev->cx_id.nasid, cx_dev->cx_id.part_num,
-				  cx_dev->cx_id.mfg_num, cx_dev->hubdev);
+				  cx_dev->cx_id.mfg_num, cx_dev->hubdev,
+				  cx_dev->bt);
 }
 
 static inline uint64_t tiocx_intr_alloc(nasid_t nasid, int widget,
@@ -365,26 +368,20 @@
 	udelay(2000);
 }
 
-static int tiocx_btchar_get(int nasid)
+static int is_fpga_tio(int nasid, int *bt)
 {
-	moduleid_t module_id;
-	geoid_t geoid;
-	int cnodeid;
+	int ioboard_type;
 
-	cnodeid = nasid_to_cnodeid(nasid);
-	geoid = cnodeid_get_geoid(cnodeid);
-	module_id = geo_module(geoid);
-	return MODULE_GET_BTCHAR(module_id);
-}
+	ioboard_type = ia64_sn_sysctl_ioboard_get(nasid);
 
-static int is_fpga_brick(int nasid)
-{
-	switch (tiocx_btchar_get(nasid)) {
+	switch (ioboard_type) {
 	case L1_BRICKTYPE_SA:
 	case L1_BRICKTYPE_ATHENA:
-	case L1_BRICKTYPE_DAYTONA:
+	case L1_BOARDTYPE_DAYTONA:
+		*bt = ioboard_type;
 		return 1;
 	}
+
 	return 0;
 }
 
@@ -407,16 +404,22 @@
 
 	if (bitstream_loaded(nasid)) {
 		uint64_t cx_id;
+		int rv;
 
-		cx_id -		    *(volatile uint64_t *)(TIO_SWIN_BASE(nasid, TIOCX_CORELET) +
+		rv = ia64_sn_sysctl_tio_clock_reset(nasid);
+		if (rv) {
+			printk(KERN_ALERT "CX port JTAG reset failed.\n");
+		} else {
+			cx_id = *(volatile uint64_t *)
+				(TIO_SWIN_BASE(nasid, TIOCX_CORELET) +
 					  WIDGET_ID);
-		part_num = XWIDGET_PART_NUM(cx_id);
-		mfg_num = XWIDGET_MFG_NUM(cx_id);
-		DBG("part= 0x%x, mfg= 0x%x\n", part_num, mfg_num);
-		/* just ignore it if it's a CE */
-		if (part_num = TIO_CE_ASIC_PARTNUM)
-			return 0;
+			part_num = XWIDGET_PART_NUM(cx_id);
+			mfg_num = XWIDGET_MFG_NUM(cx_id);
+			DBG("part= 0x%x, mfg= 0x%x\n", part_num, mfg_num);
+			/* just ignore it if it's a CE */
+			if (part_num = TIO_CE_ASIC_PARTNUM)
+				return 0;
+		}
 	}
 
 	cx_dev->cx_id.part_num = part_num;
@@ -436,10 +439,10 @@
 {
 	struct cx_dev *cx_dev = to_cx_dev(dev);
 
-	return sprintf(buf, "0x%x 0x%x 0x%x %d\n",
+	return sprintf(buf, "0x%x 0x%x 0x%x 0x%x\n",
 		       cx_dev->cx_id.nasid,
 		       cx_dev->cx_id.part_num, cx_dev->cx_id.mfg_num,
-		       tiocx_btchar_get(cx_dev->cx_id.nasid));
+		       cx_dev->bt);
 }
 
 static ssize_t store_cxdev_control(struct device *dev, struct device_attribute *attr, const char *buf,
@@ -488,11 +491,12 @@
 
 	for (cnodeid = 0; cnodeid < MAX_COMPACT_NODES; cnodeid++) {
 		nasid_t nasid;
+		int bt;
 
 		if ((nasid = cnodeid_to_nasid(cnodeid)) < 0)
 			break;	/* No more nasids .. bail out of loop */
 
-		if ((nasid & 0x1) && is_fpga_brick(nasid)) {
+		if ((nasid & 0x1) && is_fpga_tio(nasid, &bt)) {
 			struct hubdev_info *hubdev;
 			struct xwidget_info *widgetp;
 
@@ -512,7 +516,7 @@
 
 			if (cx_device_register
 			    (nasid, widgetp->xwi_hwid.part_num,
-			     widgetp->xwi_hwid.mfg_num, hubdev) < 0)
+			     widgetp->xwi_hwid.mfg_num, hubdev, bt) < 0)
 				return -ENXIO;
 			else
 				found_tiocx_device++;
Index: linux-2.6/include/asm-ia64/sn/l1.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/l1.h	2005-09-02 07:41:10.339366661 -0500
+++ linux-2.6/include/asm-ia64/sn/l1.h	2005-09-02 07:49:55.626594695 -0500
@@ -35,4 +35,16 @@
 #define L1_BRICKTYPE_ATHENA	0x2b            /* + */
 #define L1_BRICKTYPE_DAYTONA	0x7a            /* z */
 
+/* board type response codes */
+#define L1_BOARDTYPE_IP69       0x0100          /* CA */
+#define L1_BOARDTYPE_IP63       0x0200          /* CB */
+#define L1_BOARDTYPE_BASEIO     0x0300          /* IB */
+#define L1_BOARDTYPE_PCIE2SLOT  0x0400          /* IC */
+#define L1_BOARDTYPE_PCIX3SLOT  0x0500          /* ID */
+#define L1_BOARDTYPE_PCIXPCIE4SLOT 0x0600       /* IE */
+#define L1_BOARDTYPE_ABACUS     0x0700          /* AB */
+#define L1_BOARDTYPE_DAYTONA    0x0800          /* AD */
+#define L1_BOARDTYPE_INVAL      (-1)            /* invalid brick type */
+
+
 #endif /* _ASM_IA64_SN_L1_H */
Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2005-09-02 07:41:10.339366661 -0500
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h	2005-09-02 15:08:55.206196553 -0500
@@ -47,6 +47,7 @@
 #define  SN_SAL_CONSOLE_PUTB			   0x02000028
 #define  SN_SAL_CONSOLE_XMIT_CHARS		   0x0200002a
 #define  SN_SAL_CONSOLE_READC			   0x0200002b
+#define  SN_SAL_SYSCTL_OP			   0x02000030
 #define  SN_SAL_SYSCTL_MODID_GET	           0x02000031
 #define  SN_SAL_SYSCTL_GET                         0x02000032
 #define  SN_SAL_SYSCTL_IOBRICK_MODULE_GET          0x02000033
@@ -98,6 +99,13 @@
 #define SAL_INTR_FREE		2
 
 /*
+ * operations available on the generic SN_SAL_SYSCTL_OP
+ * runtime service
+ */
+#define SAL_SYSCTL_OP_IOBOARD		0x0001  /*  retrieve board type */
+#define SAL_SYSCTL_OP_TIO_JLCK_RST      0x0002  /* issue TIO clock reset */
+
+/*
  * IRouter (i.e. generalized system controller) operations
  */
 #define SAL_IROUTER_OPEN	0	/* open a subchannel */
@@ -876,6 +884,41 @@
         return (int) rv.v0;
 }
 
+/*
+ * Ask the system controller on the specified nasid to reset
+ * the CX corelet clock.  Only valid on TIO nodes.
+ */
+static inline int
+ia64_sn_sysctl_tio_clock_reset(nasid_t nasid)
+{
+	struct ia64_sal_retval rv;
+	SAL_CALL_REENTRANT(rv, SN_SAL_SYSCTL_OP, SAL_SYSCTL_OP_TIO_JLCK_RST,
+			nasid, 0, 0, 0, 0, 0);
+	if (rv.status != 0)
+		return (int)rv.status;
+	if (rv.v0 != 0)
+		return (int)rv.v0;
+
+	return 0;
+}
+
+/*
+ * Get the associated ioboard type for a given nasid.
+ */
+static inline int
+ia64_sn_sysctl_ioboard_get(nasid_t nasid)
+{
+        struct ia64_sal_retval rv;
+        SAL_CALL_REENTRANT(rv, SN_SAL_SYSCTL_OP, SAL_SYSCTL_OP_IOBOARD,
+                        nasid, 0, 0, 0, 0, 0);
+        if (rv.v0 != 0)
+                return (int)rv.v0;
+        if (rv.v1 != 0)
+                return (int)rv.v1;
+
+        return 0;
+}
+
 /**
  * ia64_sn_get_fit_compt - read a FIT entry from the PROM header
  * @nasid: NASID of node to read
Index: linux-2.6/include/asm-ia64/sn/tiocx.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/tiocx.h	2005-09-02 07:50:14.011471575 -0500
+++ linux-2.6/include/asm-ia64/sn/tiocx.h	2005-09-02 07:50:56.470108441 -0500
@@ -19,6 +19,7 @@
 
 struct cx_dev {
 	struct cx_id_s cx_id;
+	int bt;				/* board/blade type */
 	void *soft;			/* driver specific */
 	struct hubdev_info *hubdev;
 	struct device dev;
@@ -59,7 +60,7 @@
 extern struct sn_irq_info *tiocx_irq_alloc(nasid_t, int, int, nasid_t, int);
 extern void tiocx_irq_free(struct sn_irq_info *);
 extern int cx_device_unregister(struct cx_dev *);
-extern int cx_device_register(nasid_t, int, int, struct hubdev_info *);
+extern int cx_device_register(nasid_t, int, int, struct hubdev_info *, int);
 extern int cx_driver_unregister(struct cx_drv *);
 extern int cx_driver_register(struct cx_drv *);
 extern uint64_t tiocx_dma_addr(uint64_t addr);

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121


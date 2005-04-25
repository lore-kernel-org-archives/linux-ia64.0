From: Bruce Losure <blosure@americas.sgi.com>
Date: Mon, 25 Apr 2005 18:41:20 +0000
Subject: [PATCH 2.6.12] Altix patch to add bricktype knowledge to tiocx bus
Message-Id: <Pine.LNX.4.44.0504251338170.8952-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

Here is a patch to enable the SGI tiocx bus driver to distingush between
FPGA-attached h/w and non-FPGA-attached h/w.

Thanks,

Signed-off-by: Bruce Losure <blosure@sgi.com>

Index: athena-test-2.6.12/include/asm-ia64/sn/l1.h
=================================--- athena-test-2.6.12.orig/include/asm-ia64/sn/l1.h	2005-04-08 07:52:20.870806177 -0500
+++ athena-test-2.6.12/include/asm-ia64/sn/l1.h	2005-04-25 08:11:24.551131538 -0500
@@ -29,8 +29,9 @@
 #define L1_BRICKTYPE_CHI_CG     0x76            /* v */
 #define L1_BRICKTYPE_X          0x78            /* x */
 #define L1_BRICKTYPE_X2         0x79            /* y */
-#define L1_BRICKTYPE_SA		0x5e            /* ^ */ /* TIO bringup brick */
+#define L1_BRICKTYPE_SA		0x5e            /* ^ */
 #define L1_BRICKTYPE_PA		0x6a            /* j */
 #define L1_BRICKTYPE_IA		0x6b            /* k */
+#define L1_BRICKTYPE_ATHENA	0x2b            /* + */
 
 #endif /* _ASM_IA64_SN_L1_H */
Index: athena-test-2.6.12/arch/ia64/sn/kernel/tiocx.c
=================================--- athena-test-2.6.12.orig/arch/ia64/sn/kernel/tiocx.c	2005-04-25 07:58:07.584410880 -0500
+++ athena-test-2.6.12/arch/ia64/sn/kernel/tiocx.c	2005-04-25 08:18:44.712258170 -0500
@@ -21,6 +21,8 @@
 #include <asm/sn/types.h>
 #include <asm/sn/shubio.h>
 #include <asm/sn/tiocx.h>
+#include <asm/sn/l1.h>
+#include <asm/sn/module.h>
 #include "tio.h"
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
@@ -308,14 +310,12 @@
 	}
 }
 
-uint64_t
-tiocx_dma_addr(uint64_t addr)
+uint64_t tiocx_dma_addr(uint64_t addr)
 {
 	return PHYS_TO_TIODMA(addr);
 }
 
-uint64_t
-tiocx_swin_base(int nasid)
+uint64_t tiocx_swin_base(int nasid)
 {
 	return TIO_SWIN_BASE(nasid, TIOCX_CORELET);
 }
@@ -366,7 +366,29 @@
 	udelay(2000);
 }
 
-static int fpga_attached(nasid_t nasid)
+static int tiocx_btchar_get(int nasid)
+{
+	moduleid_t module_id;
+	geoid_t geoid;
+	int cnodeid;
+
+	cnodeid = nasid_to_cnodeid(nasid);
+	geoid = cnodeid_get_geoid(cnodeid);
+	module_id = geo_module(geoid);
+	return MODULE_GET_BTCHAR(module_id);
+}
+
+static int is_fpga_brick(int nasid)
+{
+	switch (tiocx_btchar_get(nasid)) {
+	case L1_BRICKTYPE_SA:
+	case L1_BRICKTYPE_ATHENA:
+		return 1;
+	}
+	return 0;
+}
+
+static int bitstream_loaded(nasid_t nasid)
 {
 	uint64_t cx_credits;
 
@@ -383,7 +405,7 @@
 	int mfg_num = CX_DEV_NONE;
 	nasid_t nasid = cx_dev->cx_id.nasid;
 
-	if (fpga_attached(nasid)) {
+	if (bitstream_loaded(nasid)) {
 		uint64_t cx_id;
 
 		cx_id @@ -414,9 +436,10 @@
 {
 	struct cx_dev *cx_dev = to_cx_dev(dev);
 
-	return sprintf(buf, "0x%x 0x%x 0x%x\n",
+	return sprintf(buf, "0x%x 0x%x 0x%x %d\n",
 		       cx_dev->cx_id.nasid,
-		       cx_dev->cx_id.part_num, cx_dev->cx_id.mfg_num);
+		       cx_dev->cx_id.part_num, cx_dev->cx_id.mfg_num,
+		       tiocx_btchar_get(cx_dev->cx_id.nasid));
 }
 
 static ssize_t store_cxdev_control(struct device *dev, const char *buf,
@@ -462,7 +485,7 @@
 		if ((nasid = cnodeid_to_nasid(cnodeid)) < 0)
 			break;	/* No more nasids .. bail out of loop */
 
-		if (nasid & 0x1) {	/* TIO's are always odd */
+		if ((nasid & 0x1) && is_fpga_brick(nasid)) {
 			struct hubdev_info *hubdev;
 			struct xwidget_info *widgetp;


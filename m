From: Christoph Hellwig <hch@lst.de>
Date: Thu, 25 Sep 2003 19:51:52 +0000
Subject: [PATCH] make sn2 devfs-clean
Message-Id: <marc-linux-ia64-106451958531961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SN2 stopped abusing devfs in 2.5, clean up the leftovers.


--- 1.5/arch/ia64/sn/io/drivers/ioconfig_bus.c	Mon Sep  8 22:51:18 2003
+++ edited/arch/ia64/sn/io/drivers/ioconfig_bus.c	Thu Sep 25 21:18:20 2003
@@ -17,8 +17,6 @@
 #include <linux/pci.h>
 
 #include <asm/sn/sgi.h>
-#include <linux/devfs_fs.h>
-#include <linux/devfs_fs_kernel.h>
 #include <asm/io.h>
 #include <asm/sn/iograph.h>
 #include <asm/sn/invent.h>
@@ -354,7 +352,7 @@
 
 /*
  * init_ifconfig_bus() - Boot time initialization.  Ensure that it is called 
- *	after devfs has been initialized.
+ *	after hwgfs has been initialized.
  *
  */
 int init_ioconfig_bus(void)
=== arch/ia64/sn/io/machvec/pci_dma.c 1.13 vs edited ==--- 1.13/arch/ia64/sn/io/machvec/pci_dma.c	Mon Sep  8 14:13:26 2003
+++ edited/arch/ia64/sn/io/machvec/pci_dma.c	Thu Sep 25 21:18:20 2003
@@ -15,7 +15,6 @@
 #include <linux/string.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
-#include <linux/devfs_fs_kernel.h>
 #include <linux/module.h>
 
 #include <asm/delay.h>
=== arch/ia64/sn/io/sn2/pciio.c 1.3 vs edited ==--- 1.3/arch/ia64/sn/io/sn2/pciio.c	Thu Jul  3 21:55:24 2003
+++ edited/arch/ia64/sn/io/sn2/pciio.c	Thu Sep 25 21:18:20 2003
@@ -947,15 +947,6 @@
 
     pciio_info = (pciio_info_t) hwgraph_fastinfo_get(pciio);
 
-#ifdef DEBUG_PCIIO
-    {
-	int pos;
-	char dname[256];
-	pos = devfs_generate_path(pciio, dname, 256);
-	printk("%s : path= %s\n", __FUNCTION__, &dname[pos]);
-    }
-#endif /* DEBUG_PCIIO */
-
     if ((pciio_info != NULL) &&
         (pciio_info->c_fingerprint != pciio_info_fingerprint)
         && (pciio_info->c_fingerprint != NULL)) {
@@ -1212,14 +1203,6 @@
 
     pciio_info->c_vertex = pconn;
     pciio_info_set(pconn, pciio_info);
-#ifdef DEBUG_PCIIO
-    {
-	int pos;
-	char dname[256];
-	pos = devfs_generate_path(pconn, dname, 256);
-	printk("%s : pconn path= %s \n", __FUNCTION__, &dname[pos]);
-    }
-#endif /* DEBUG_PCIIO */
 
     /*
      * create link to our pci provider
=== arch/ia64/sn/io/sn2/xbow.c 1.4 vs edited ==--- 1.4/arch/ia64/sn/io/sn2/xbow.c	Fri May 23 12:37:38 2003
+++ edited/arch/ia64/sn/io/sn2/xbow.c	Thu Sep 25 21:18:20 2003
@@ -257,7 +257,7 @@
      */
 
     /*
-     * Register a xbow driver with devfs.
+     * Register a xbow driver with hwgraph.
      * file ops.
      */
     vhdl = NULL;
=== include/asm-ia64/sn/hcl_util.h 1.3 vs edited ==--- 1.3/include/asm-ia64/sn/hcl_util.h	Fri May 16 13:18:17 2003
+++ edited/include/asm-ia64/sn/hcl_util.h	Thu Sep 25 21:18:22 2003
@@ -10,8 +10,6 @@
 #ifndef _ASM_IA64_SN_HCL_UTIL_H
 #define _ASM_IA64_SN_HCL_UTIL_H
 
-#include <linux/devfs_fs_kernel.h>
-
 extern char * dev_to_name(vertex_hdl_t, char *, uint);
 extern int device_master_set(vertex_hdl_t, vertex_hdl_t);
 extern vertex_hdl_t device_master_get(vertex_hdl_t);
=== include/asm-ia64/sn/ioerror_handling.h 1.4 vs edited ==--- 1.4/include/asm-ia64/sn/ioerror_handling.h	Fri May 16 13:18:18 2003
+++ edited/include/asm-ia64/sn/ioerror_handling.h	Thu Sep 25 21:18:22 2003
@@ -10,7 +10,6 @@
 
 #include <linux/config.h>
 #include <linux/types.h>
-#include <linux/devfs_fs_kernel.h>
 #include <asm/sn/sgi.h>
 
 #if __KERNEL__
=== include/asm-ia64/sn/labelcl.h 1.3 vs edited ==--- 1.3/include/asm-ia64/sn/labelcl.h	Fri May 16 13:18:18 2003
+++ edited/include/asm-ia64/sn/labelcl.h	Thu Sep 25 21:18:22 2003
@@ -40,7 +40,7 @@
 /*
  * Definition of the data structure that provides the link to 
  * the hwgraph fastinfo and the label entries associated with a 
- * particular devfs entry.
+ * particular hwgraph entry.
  */
 typedef struct labelcl_info_s {
 	unsigned long	hwcl_magic;
@@ -87,6 +87,5 @@
 			arbitrary_info_t *);
 extern int labelcl_info_connectpt_set(vertex_hdl_t, vertex_hdl_t);
 extern int labelcl_info_get_IDX(vertex_hdl_t, int, arbitrary_info_t *);
-extern struct devfs_handle_t device_info_connectpt_get(vertex_hdl_t);
 
 #endif /* _ASM_IA64_SN_LABELCL_H */
=== include/asm-ia64/sn/sgi.h 1.6 vs edited ==--- 1.6/include/asm-ia64/sn/sgi.h	Fri May 23 12:37:38 2003
+++ edited/include/asm-ia64/sn/sgi.h	Thu Sep 25 21:18:22 2003
@@ -16,7 +16,6 @@
 #include <asm/sn/types.h>
 #include <asm/uaccess.h>		/* for copy_??_user */
 #include <linux/mm.h>
-#include <linux/devfs_fs_kernel.h>
 #include <linux/fs.h>
 #include <asm/sn/hwgfs.h>
 
=== include/asm-ia64/sn/xtalk/xbow_info.h 1.3 vs edited ==--- 1.3/include/asm-ia64/sn/xtalk/xbow_info.h	Fri May 16 13:18:18 2003
+++ edited/include/asm-ia64/sn/xtalk/xbow_info.h	Thu Sep 25 21:18:22 2003
@@ -10,7 +10,6 @@
 #define _ASM_SN_XTALK_XBOW_INFO_H
 
 #include <linux/types.h>
-#include <linux/devfs_fs_kernel.h>
 
 #define XBOW_PERF_MODES	       0x03
 #define XBOW_PERF_COUNTERS     0x02
=== include/asm-ia64/sn/xtalk/xswitch.h 1.3 vs edited ==--- 1.3/include/asm-ia64/sn/xtalk/xswitch.h	Fri May 16 13:18:18 2003
+++ edited/include/asm-ia64/sn/xtalk/xswitch.h	Thu Sep 25 21:18:22 2003
@@ -17,7 +17,6 @@
 
 #ifndef __ASSEMBLY__
 
-#include <linux/devfs_fs_kernel.h>
 #include <asm/sn/xtalk/xtalk.h>
 
 typedef struct xswitch_info_s *xswitch_info_t;
=== include/asm-ia64/sn/xtalk/xtalk_private.h 1.5 vs edited ==--- 1.5/include/asm-ia64/sn/xtalk/xtalk_private.h	Fri May 16 13:18:18 2003
+++ edited/include/asm-ia64/sn/xtalk/xtalk_private.h	Thu Sep 25 21:18:22 2003
@@ -10,7 +10,6 @@
 #define _ASM_SN_XTALK_XTALK_PRIVATE_H
 
 #include <asm/sn/ioerror.h>        /* for error function and arg types */
-#include <linux/devfs_fs_kernel.h>
 #include <asm/sn/xtalk/xwidget.h>
 #include <asm/sn/xtalk/xtalk.h>
 

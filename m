From: Christoph Hellwig <hch@lst.de>
Date: Thu, 25 Sep 2003 20:00:49 +0000
Subject: [PATCH] kill .hcl entry in hwgfs
Message-Id: <marc-linux-ia64-106452051300736@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It only has noop file_operations and that since all the SN2 mess was
merged.


--- 1.6/arch/ia64/sn/io/hwgfs/hcl.c	Mon Aug  4 19:02:37 2003
+++ edited/arch/ia64/sn/io/hwgfs/hcl.c	Sun Aug 10 02:17:15 2003
@@ -53,11 +53,6 @@
 static unsigned int boot_options = OPTION_NONE;
 #endif
 
-/*
- * Some Global definitions.
- */
-vertex_hdl_t hcl_handle;
-
 invplace_t invplace_none = {
 	GRAPH_VERTEX_NONE,
 	GRAPH_VERTEX_PLACE_NONE,
@@ -65,62 +60,6 @@
 };
 
 /*
- * HCL device driver.
- * The purpose of this device driver is to provide a facility 
- * for User Level Apps e.g. hinv, ioconfig etc. an ioctl path 
- * to manipulate label entries without having to implement
- * system call interfaces.  This methodology will enable us to 
- * make this feature module loadable.
- */
-static int hcl_open(struct inode * inode, struct file * filp)
-{
-	if (hcl_debug) {
-        	printk("HCL: hcl_open called.\n");
-	}
-
-        return(0);
-
-}
-
-static int hcl_close(struct inode * inode, struct file * filp)
-{
-
-	if (hcl_debug) {
-        	printk("HCL: hcl_close called.\n");
-	}
-
-        return(0);
-
-}
-
-static int hcl_ioctl(struct inode * inode, struct file * file,
-        unsigned int cmd, unsigned long arg)
-{
-
-	if (hcl_debug) {
-		printk("HCL: hcl_ioctl called.\n");
-	}
-
-	switch (cmd) {
-		default:
-			if (hcl_debug) {
-				printk("HCL: hcl_ioctl cmd = 0x%x\n", cmd);
-			}
-	}
-
-	return(0);
-
-}
-
-struct file_operations hcl_fops = {
-	.owner = (struct module *)0,
-	.ioctl = hcl_ioctl,
-	.open = hcl_open,
-	.release = hcl_close,
-};
-
-
-/*
  * init_hcl() - Boot time initialization.
  *
  */
@@ -145,21 +84,6 @@
 	rv = hwgraph_path_add(NULL, EDGE_LBL_HW, &hwgraph_root);
 	if (rv)
 		printk ("WARNING: init_hcl: Failed to create hwgraph_root. Error = %d.\n", rv);
-
-	/*
-	 * Create the hcl driver to support inventory entry manipulations.
-	 *
-	 */
-	hcl_handle = hwgraph_register(hwgraph_root, ".hcl",
-		        0, 0,
-			0, 0,
-			S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
-			&hcl_fops, NULL);
-
-	if (hcl_handle = NULL) {
-		panic("HCL: Unable to create HCL Driver in init_hcl().\n");
-		return(0);
-	}
 
 	/*
 	 * Initialize the HCL string table.

From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 12 Mar 2004 00:32:36 +0000
Subject: Re: [PATCH] fix misc. sn2 warnings
Message-Id: <20040312003236.GB18851@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040311221149.GA17986@sgi.com>
In-Reply-To: <20040311221149.GA17986@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Please ignore that last one, it won't apply to your BK tree.  This one
will though.

This patch fixes a few warnings that have cropped up in the sn2 code:
  - hwgfs function prototype mismatch
  - pconn uninitialized in pciio.c
  - printk formatting fixes in pcibr_dvr.c
  - kill volatile qualifier in pcibr_intr.c

Jesse


=== arch/ia64/sn/io/hwgfs/ramfs.c 1.4 vs edited ==--- 1.4/arch/ia64/sn/io/hwgfs/ramfs.c	Sun Jan 18 22:36:01 2004
+++ edited/arch/ia64/sn/io/hwgfs/ramfs.c	Thu Mar 11 13:08:55 2004
@@ -84,7 +84,7 @@
 	return hwgfs_mknod(dir, dentry, mode | S_IFDIR, 0);
 }
 
-static int hwgfs_create(struct inode *dir, struct dentry *dentry, int mode)
+static int hwgfs_create(struct inode *dir, struct dentry *dentry, int mode, struct nameidata *unused)
 {
 	return hwgfs_mknod(dir, dentry, mode | S_IFREG, 0);
 }
=== arch/ia64/sn/io/sn2/pciio.c 1.15 vs edited ==--- 1.15/arch/ia64/sn/io/sn2/pciio.c	Fri Feb  6 00:30:16 2004
+++ edited/arch/ia64/sn/io/sn2/pciio.c	Thu Mar 11 13:08:56 2004
@@ -822,7 +822,7 @@
 			     pciio_info_t pciio_info)
 {
     char		name[32];
-    vertex_hdl_t	pconn;
+    vertex_hdl_t	pconn = NULL;
 
     if (!pciio_info)
 	return;
@@ -835,7 +835,6 @@
 
     hwgraph_vertex_unref(pconn);
     hwgraph_vertex_destroy(pconn);
-    
 }
 
 /*ARGSUSED */
=== arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c 1.29 vs edited ==--- 1.29/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Thu Feb 19 09:12:31 2004
+++ edited/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Thu Mar 11 13:08:56 2004
@@ -2501,7 +2501,7 @@
     if (pcibr_soft->bs_pcix_num_funcs) {
 	if (pcibr_soft->bs_pcix_num_funcs > NUM_RBAR) {
 	    printk(KERN_WARNING
-		"%lx: Must oversubscribe Read Buffer Attribute Registers"
+		"%s: Must oversubscribe Read Buffer Attribute Registers"
 		"(RBAR).  Bus has %d RBARs but %d funcs need them.\n",
 		pcibr_soft->bs_name, NUM_RBAR, pcibr_soft->bs_pcix_num_funcs);
 	    percent_allowed = 0;
@@ -2603,7 +2603,7 @@
 		memset(buffer, 0, 1024);
 		vsnprintf(buffer, 1024, format, ap);
 		va_end(ap);
-		printk("", "%s", buffer);
+		printk("%s", buffer);
 		kfree(buffer);
 	    }
         }
=== arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c 1.17 vs edited ==--- 1.17/arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c	Fri Feb 13 07:00:22 2004
+++ edited/arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c	Thu Mar 11 13:08:56 2004
@@ -101,7 +101,7 @@
 {
 	nasid_t nasid;
 	int wid_num;
-	volatile struct sn_flush_device_list *p;
+	struct sn_flush_device_list *p;
 	int i,j;
 	int bwin;
 	unsigned long flags;

From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Jun 2003 16:19:06 +0000
Subject: [PATCH] hwgfs fix for sn2
MIME-Version: 1
Content-Type: multipart/mixed; boundary="NklN7DEeGtkPCoo3"
Message-Id: <marc-linux-ia64-105595346915716@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--NklN7DEeGtkPCoo3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Small fix for hwgfs on sn2.

Thanks,
Jesse

--NklN7DEeGtkPCoo3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hwgfs-fix-2.5.69-ia64-bk.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1150  -> 1.1151 
#	arch/ia64/sn/io/hwgfs/hcl.c	1.2     -> 1.3    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	jbarnes@tomahawk.engr.sgi.com	1.1151
# fops update for hcl
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/hwgfs/hcl.c b/arch/ia64/sn/io/hwgfs/hcl.c
--- a/arch/ia64/sn/io/hwgfs/hcl.c	Tue Jun 17 14:47:51 2003
+++ b/arch/ia64/sn/io/hwgfs/hcl.c	Tue Jun 17 14:47:51 2003
@@ -113,22 +113,10 @@
 }
 
 struct file_operations hcl_fops = {
-	(struct module *)0,
-	NULL,		/* lseek - default */
-	NULL,		/* read - general block-dev read */
-	NULL,		/* write - general block-dev write */
-	NULL,		/* readdir - bad */
-	NULL,		/* poll */
-	hcl_ioctl,      /* ioctl */
-	NULL,		/* mmap */
-	hcl_open,	/* open */
-	NULL,		/* flush */
-	hcl_close,	/* release */
-	NULL,		/* fsync */
-	NULL,		/* fasync */
-	NULL,		/* lock */
-	NULL,		/* readv */
-	NULL,		/* writev */
+	.owner = (struct module *)0,
+	.ioctl = hcl_ioctl,
+	.open = hcl_open,
+	.release = hcl_close,
 };
 
 
@@ -258,6 +246,7 @@
 
 	if (!de) {
 		printk(KERN_WARNING "HCL: hwgraph_fastinfo_get handle given is NULL.\n");
+		dump_stack();
 		return(-1);
 	}
 

--NklN7DEeGtkPCoo3--

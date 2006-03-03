From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 03 Mar 2006 22:34:34 +0000
Subject: [PATCH] SGI SN drivers: don't report !sn2 hardware as an error
Message-Id: <200603031534.34456.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This stuff is all in the generic ia64 kernel, and the new initcall error
reporting complains about them.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm4/drivers/char/mmtimer.c
=================================--- work-mm4.orig/drivers/char/mmtimer.c	2006-03-03 15:10:21.000000000 -0700
+++ work-mm4/drivers/char/mmtimer.c	2006-03-03 15:12:48.000000000 -0700
@@ -675,7 +675,7 @@
 	cnodeid_t node, maxn = -1;
 
 	if (!ia64_platform_is("sn2"))
-		return -1;
+		return 0;
 
 	/*
 	 * Sanity check the cycles/sec variable
Index: work-mm4/drivers/serial/sn_console.c
=================================--- work-mm4.orig/drivers/serial/sn_console.c	2006-03-03 15:10:21.000000000 -0700
+++ work-mm4/drivers/serial/sn_console.c	2006-03-03 15:12:48.000000000 -0700
@@ -820,7 +820,7 @@
 	int retval;
 
 	if (!ia64_platform_is("sn2"))
-		return -ENODEV;
+		return 0;
 
 	printk(KERN_INFO "sn_console: Console driver init\n");
 

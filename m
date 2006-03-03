From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 03 Mar 2006 22:33:47 +0000
Subject: [PATCH] ia64: don't report !sn2 or !summit hardware as an error
Message-Id: <200603031533.47538.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This stuff is all in the generic ia64 kernel, and the new initcall error
reporting complains about them.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm4/arch/ia64/kernel/cyclone.c
=================================--- work-mm4.orig/arch/ia64/kernel/cyclone.c	2006-03-03 15:10:21.000000000 -0700
+++ work-mm4/arch/ia64/kernel/cyclone.c	2006-03-03 15:11:22.000000000 -0700
@@ -36,7 +36,7 @@
 	u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */
 
 	if (!use_cyclone)
-		return -ENODEV;
+		return 0;
 
 	printk(KERN_INFO "Summit chipset: Starting Cyclone Counter.\n");
 
Index: work-mm4/arch/ia64/sn/kernel/tiocx.c
=================================--- work-mm4.orig/arch/ia64/sn/kernel/tiocx.c	2006-03-03 15:10:21.000000000 -0700
+++ work-mm4/arch/ia64/sn/kernel/tiocx.c	2006-03-03 15:11:22.000000000 -0700
@@ -484,7 +484,7 @@
 	int found_tiocx_device = 0;
 
 	if (!ia64_platform_is("sn2"))
-		return -ENODEV;
+		return 0;
 
 	bus_register(&tiocx_bus_type);
 
Index: work-mm4/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- work-mm4.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2006-03-03 15:10:21.000000000 -0700
+++ work-mm4/arch/ia64/sn/kernel/sn2/sn2_smp.c	2006-03-03 15:11:22.000000000 -0700
@@ -467,7 +467,7 @@
 static int __init sn2_ptc_init(void)
 {
 	if (!ia64_platform_is("sn2"))
-		return -ENOSYS;
+		return 0;
 
 	if (!(proc_sn2_ptc = create_proc_entry(PTC_BASENAME, 0444, NULL))) {
 		printk(KERN_ERR "unable to create %s proc entry", PTC_BASENAME);

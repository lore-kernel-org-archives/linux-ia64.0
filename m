From: "David C. Hansen" <haveblue@us.ibm.com>
Date: Fri, 07 Sep 2001 22:01:40 +0000
Subject: [Linux-ia64] [PATCH] to remove unused hcl_spinlock
Message-Id: <marc-linux-ia64-105590698805147@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I was looking at spinlocks in the kernel and came across hcl_spinlock. 
If you look at this paper:
http://lse.sourceforge.net/lockhier/global-spin-lock , you can see a
part on hcl_spinlock.  It is initialized. but never used.  Was this lock
meant to guard something?  Is that thing still in the code?  If it
isn't, here is a patch to remove hcl_spinlock.

--- linux-2.4.9/arch/ia64/sn/io/hcl.c	Thu Apr  5 12:51:47 2001
+++ linux/arch/ia64/sn/io/hcl.c	Fri Sep  7 14:52:40 2001
@@ -49,7 +49,6 @@
 /*
  * Some Global definitions.
  */
-spinlock_t hcl_spinlock;
 devfs_handle_t hcl_handle = NULL;
 
 invplace_t invplace_none = {
@@ -152,8 +151,6 @@
 	printk ("%s: hcl_debug: 0x%0x\n", HCL_NAME, hcl_debug);
 	printk ("\n%s: boot_options: 0x%0x\n", HCL_NAME, boot_options);
 #endif
-
-	spin_lock_init(&hcl_spinlock);
 
 	/*
 	 * Create the hwgraph_root on devfs.
--- linux-2.4.9/include/asm-ia64/sn/hcl.h	Thu Apr  5 12:51:47 2001
+++ linux/include/asm-ia64/sn/hcl.h	Fri Sep  7 14:53:53 2001
@@ -10,7 +10,6 @@
 #ifndef _ASM_SN_HCL_H
 #define _ASM_SN_HCL_H
 
-extern spinlock_t hcl_spinlock;
 extern devfs_handle_t hcl_handle; /* HCL driver */
 extern devfs_handle_t hwgraph_root;
 extern devfs_handle_t linux_busnum;


--
David C. Hansen
haveblue@us.ibm.com
IBM LTC Base/OS Group
(503)578-4080


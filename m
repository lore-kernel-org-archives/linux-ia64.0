From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 09 Jun 2003 15:08:54 +0000
Subject: [Linux-ia64] [PATCH] 2.5 - No early printk for GENERIC
Message-Id: <marc-linux-ia64-105590723706196@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

Here is a patch to the ia64 Kconfig file that disables the
EARLY_PRINTK menu option if a GENERIC kernel is selected.

As we discussed last week, EARLY_PRINTK doesn't work for
GENERIC kernels anymore because readb/readl are now 
machvecs.

thanks
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1124  -> 1.1125 
#	   arch/ia64/Kconfig	1.25    -> 1.26   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/09	mort@green.i.bork.org	1.1125
# Early printk cannot be used for Generic kernels because
# it uses readb/readl, which are now machvecs and are 
# uninitialized when early printk is called very early
# in the boot.
# --------------------------------------------
#
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Mon Jun  9 11:06:30 2003
+++ b/arch/ia64/Kconfig	Mon Jun  9 11:06:30 2003
@@ -846,7 +846,7 @@
 
 config IA64_EARLY_PRINTK
 	bool "Early printk support"
-	depends on DEBUG_KERNEL
+	depends on DEBUG_KERNEL && !IA64_GENERIC
 	help
 	  Selecting this option uses the VGA screen or serial console for
 	  printk() output before the consoles are initialised.  It is useful


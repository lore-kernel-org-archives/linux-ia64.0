From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 11 Sep 2003 23:30:34 +0000
Subject: [PATCH] Re: salinfo.c
Message-Id: <marc-linux-ia64-106332321511150@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 11, 2003 at 04:01:26PM -0700, David Mosberger wrote:
> Hi Jesse,
> 
> Have you noticed that salinfo.c isn't hooked into the 2.6 kernel at
> all?  If it's not used, we should just remove it.  Otherwise, we
> should probably add CONFIG_IA64_SALINFO and mention salinfo.c in the
> Makefile... ;-)

Here's the fix.

Jesse

diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Thu Sep 11 16:29:20 2003
+++ b/arch/ia64/Kconfig	Thu Sep 11 16:29:20 2003
@@ -413,6 +413,16 @@
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
+config IA64_SALINFO
+	tristate "/proc/sal support"
+	help
+	  The /proc/sal directory exports the SAL (system abstraction layer)
+	  feature bits, like whether the platform is subject to ITC drift.  It
+	  is intended to be used by user programs that care about such things.
+
+	  To use this option, you have to ensure that the "/proc file system
+	  support" (CONFIG_PROC_FS) is enabled, too.
+
 config EFI_VARS
 	tristate "/proc/efi/vars support"
 	help
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	Thu Sep 11 16:29:20 2003
+++ b/arch/ia64/kernel/Makefile	Thu Sep 11 16:29:20 2003
@@ -14,6 +14,7 @@
 obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
 obj-$(CONFIG_IA64_MCA)		+= mca.o mca_asm.o
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
+obj-$(CONFIG_IA64_SALINFO)	+= salinfo.o
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
diff -Nru a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
--- a/arch/ia64/kernel/salinfo.c	Thu Sep 11 16:29:20 2003
+++ b/arch/ia64/kernel/salinfo.c	Thu Sep 11 16:29:20 2003
@@ -5,6 +5,7 @@
  *
  * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
  *
+ * 09/11/2003	jbarnes@sgi.com		updated for 2.6
  * 10/30/2001	jbarnes@sgi.com		copied much of Stephane's palinfo
  *					code to create this file
  */
@@ -59,7 +60,7 @@
 		*sdir = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
 						  salinfo_read, (void *)salinfo_entries[i].feature);
 		if (*sdir)
-			*sdir->owner = THIS_MODULE;
+			(*sdir)->owner = THIS_MODULE;
 		sdir++;
 	}
 	*sdir++ = salinfo_dir;

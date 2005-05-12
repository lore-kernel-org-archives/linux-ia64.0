From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Thu, 12 May 2005 23:59:11 +0000
Subject: [PATCH] arch/ia64/Kconfig shouldn't define CONFIG_ACPI
Message-Id: <20050512235911.GC404742@dragonfly.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, acpi-devel@lists.sourceforge.net

arch/ia64/Kconfig shouldn't define CONFIG_ACPI.  drivers/acpi/Kconfig
also defines it, and that's the right place for it.

Signed-off-by: Jason Uhlenkott <jasonuhl@sgi.com>


Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2005-05-12 15:59:33.531196032 -0700
+++ linux/arch/ia64/Kconfig	2005-05-12 16:17:59.020853156 -0700
@@ -348,11 +348,6 @@
 	  will issue the hlt instruction if nothing is to be done, thereby
 	  sending the processor to sleep and saving power.
 
-config ACPI
-	bool
-	depends on !IA64_HP_SIM
-	default y
-
 if !IA64_HP_SIM
 
 source "drivers/acpi/Kconfig"

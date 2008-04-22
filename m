From: Dean Nelson <dcn@sgi.com>
Date: Tue, 22 Apr 2008 19:46:56 +0000
Subject: [Patch 1/4] move XP and XPC to drivers/misc/sgi-xp -v4
Message-Id: <20080422194656.GA14628@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422194459.GB13086@sgi.com>
In-Reply-To: <20080422194459.GB13086@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Move XPC and XPNET from arch/ia64/sn/kernel to drivers/misc/sgi-xp.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

 arch/ia64/Kconfig                                  |   11 -----------
 arch/ia64/sn/kernel/Makefile                       |    7 +------
 drivers/misc/Kconfig                               |   12 ++++++++++++
 drivers/misc/Makefile                              |    1 +
 drivers/misc/sgi-xp/Makefile                       |   11 +++++++++++
 {include/asm-ia64/sn => drivers/misc/sgi-xp}/xp.h  |    8 ++++----
 .../sn/kernel => drivers/misc/sgi-xp}/xp_main.c    |    4 ++--
 .../sn/kernel => drivers/misc/sgi-xp}/xp_nofault.S |    2 +-
 {include/asm-ia64/sn => drivers/misc/sgi-xp}/xpc.h |   10 +++++-----
 .../kernel => drivers/misc/sgi-xp}/xpc_channel.c   |    4 ++--
 .../sn/kernel => drivers/misc/sgi-xp}/xpc_main.c   |    4 ++--
 .../kernel => drivers/misc/sgi-xp}/xpc_partition.c |    4 ++--
 .../ia64/sn/kernel => drivers/misc/sgi-xp}/xpnet.c |    4 ++--
 13 files changed, 45 insertions(+), 37 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index ed21737..cd13e13 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -266,17 +266,6 @@ config IOSAPIC
 	depends on !IA64_HP_SIM
 	default y
 
-config IA64_SGI_SN_XP
-	tristate "Support communication between SGI SSIs"
-	depends on IA64_GENERIC || IA64_SGI_SN2
-	select IA64_UNCACHED_ALLOCATOR
-	help
-	  An SGI machine can be divided into multiple Single System
-	  Images which act independently of each other and have
-	  hardware based memory protection from the others.  Enabling
-	  this feature will allow for direct communication between SSIs
-	  based on a network adapter and DMA messaging.
-
 config FORCE_MAX_ZONEORDER
 	int "MAX_ORDER (11 - 17)"  if !HUGETLB_PAGE
 	range 11 17  if !HUGETLB_PAGE
diff --git a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
index 688a3c2..0591038 100644
--- a/arch/ia64/sn/kernel/Makefile
+++ b/arch/ia64/sn/kernel/Makefile
@@ -4,7 +4,7 @@
 # License.  See the file "COPYING" in the main directory of this archive
 # for more details.
 #
-# Copyright (C) 1999,2001-2006 Silicon Graphics, Inc.  All Rights Reserved.
+# Copyright (C) 1999,2001-2006,2008 Silicon Graphics, Inc.  All Rights Reserved.
 #
 
 EXTRA_CFLAGS += -Iarch/ia64/sn/include
@@ -15,9 +15,4 @@ obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
 				   sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_SGI_TIOCX)		+= tiocx.o
-obj-$(CONFIG_IA64_SGI_SN_XP)	+= xp.o
-xp-y				:= xp_main.o xp_nofault.o
-obj-$(CONFIG_IA64_SGI_SN_XP)	+= xpc.o
-xpc-y				:= xpc_main.o xpc_channel.o xpc_partition.o
-obj-$(CONFIG_IA64_SGI_SN_XP)	+= xpnet.o
 obj-$(CONFIG_PCI_MSI)		+= msi_sn.o
diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index bb94ce7..297a48f 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -360,4 +360,16 @@ config ENCLOSURE_SERVICES
 	  driver (SCSI/ATA) which supports enclosures
 	  or a SCSI enclosure device (SES) to use these services.
 
+config SGI_XP
+	tristate "Support communication between SGI SSIs"
+	depends on IA64_GENERIC || IA64_SGI_SN2
+	select IA64_UNCACHED_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
+	select GENERIC_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
+	---help---
+	  An SGI machine can be divided into multiple Single System
+	  Images which act independently of each other and have
+	  hardware based memory protection from the others.  Enabling
+	  this feature will allow for direct communication between SSIs
+	  based on a network adapter and DMA messaging.
+
 endif # MISC_DEVICES
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 4581b25..5914da4 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_EEPROM_93CX6)	+= eeprom_93cx6.o
 obj-$(CONFIG_INTEL_MENLOW)	+= intel_menlow.o
 obj-$(CONFIG_ENCLOSURE_SERVICES) += enclosure.o
 obj-$(CONFIG_KGDB_TESTS)	+= kgdbts.o
+obj-$(CONFIG_SGI_XP)		+= sgi-xp/
diff --git a/drivers/misc/sgi-xp/Makefile b/drivers/misc/sgi-xp/Makefile
new file mode 100644
index 0000000..b6e40a7
--- /dev/null
+++ b/drivers/misc/sgi-xp/Makefile
@@ -0,0 +1,11 @@
+#
+# Makefile for SGI's XP devices.
+#
+
+obj-$(CONFIG_SGI_XP)		+= xp.o
+xp-y				:= xp_main.o xp_nofault.o
+
+obj-$(CONFIG_SGI_XP)		+= xpc.o
+xpc-y				:= xpc_main.o xpc_channel.o xpc_partition.o
+
+obj-$(CONFIG_SGI_XP)		+= xpnet.o
diff --git a/include/asm-ia64/sn/xp.h b/drivers/misc/sgi-xp/xp.h
similarity index 99%
rename from include/asm-ia64/sn/xp.h
rename to drivers/misc/sgi-xp/xp.h
index f7711b3..fb65981 100644
--- a/include/asm-ia64/sn/xp.h
+++ b/drivers/misc/sgi-xp/xp.h
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2004-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Silicon Graphics, Inc. All rights reserved.
  */
 
 
@@ -12,8 +12,8 @@
  */
 
 
-#ifndef _ASM_IA64_SN_XP_H
-#define _ASM_IA64_SN_XP_H
+#ifndef _DRIVERS_MISC_SGIXP_XP_H
+#define _DRIVERS_MISC_SGIXP_XP_H
 
 
 #include <linux/cache.h>
@@ -481,5 +481,5 @@ extern int xp_nofault_PIOR(void *);
 extern int xp_error_PIOR(void);
 
 
-#endif /* _ASM_IA64_SN_XP_H */
+#endif /* _DRIVERS_MISC_SGIXP_XP_H */
 
diff --git a/arch/ia64/sn/kernel/xp_main.c b/drivers/misc/sgi-xp/xp_main.c
similarity index 98%
rename from arch/ia64/sn/kernel/xp_main.c
rename to drivers/misc/sgi-xp/xp_main.c
index b7ea466..5f9f9c2 100644
--- a/arch/ia64/sn/kernel/xp_main.c
+++ b/drivers/misc/sgi-xp/xp_main.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -22,7 +22,7 @@
 #include <linux/mutex.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
-#include <asm/sn/xp.h>
+#include "xp.h"
 
 
 /*
diff --git a/arch/ia64/sn/kernel/xp_nofault.S b/drivers/misc/sgi-xp/xp_nofault.S
similarity index 95%
rename from arch/ia64/sn/kernel/xp_nofault.S
rename to drivers/misc/sgi-xp/xp_nofault.S
index 98e7c7d..c13a709 100644
--- a/arch/ia64/sn/kernel/xp_nofault.S
+++ b/drivers/misc/sgi-xp/xp_nofault.S
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
diff --git a/include/asm-ia64/sn/xpc.h b/drivers/misc/sgi-xp/xpc.h
similarity index 99%
rename from include/asm-ia64/sn/xpc.h
rename to drivers/misc/sgi-xp/xpc.h
index 3c0900a..14e70ee 100644
--- a/include/asm-ia64/sn/xpc.h
+++ b/drivers/misc/sgi-xp/xpc.h
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -11,8 +11,8 @@
  * Cross Partition Communication (XPC) structures and macros.
  */
 
-#ifndef _ASM_IA64_SN_XPC_H
-#define _ASM_IA64_SN_XPC_H
+#ifndef _DRIVERS_MISC_SGIXP_XPC_H
+#define _DRIVERS_MISC_SGIXP_XPC_H
 
 
 #include <linux/interrupt.h>
@@ -27,7 +27,7 @@
 #include <asm/sn/addrs.h>
 #include <asm/sn/mspec.h>
 #include <asm/sn/shub_mmr.h>
-#include <asm/sn/xp.h>
+#include "xp.h"
 
 
 /*
@@ -1263,5 +1263,5 @@ xpc_check_for_channel_activity(struct xpc_partition *part)
 }
 
 
-#endif /* _ASM_IA64_SN_XPC_H */
+#endif /* _DRIVERS_MISC_SGIXP_XPC_H */
 
diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/drivers/misc/sgi-xp/xpc_channel.c
similarity index 99%
rename from arch/ia64/sn/kernel/xpc_channel.c
rename to drivers/misc/sgi-xp/xpc_channel.c
index 44ccc0d..d7a215e 100644
--- a/arch/ia64/sn/kernel/xpc_channel.c
+++ b/drivers/misc/sgi-xp/xpc_channel.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -25,7 +25,7 @@
 #include <linux/completion.h>
 #include <asm/sn/bte.h>
 #include <asm/sn/sn_sal.h>
-#include <asm/sn/xpc.h>
+#include "xpc.h"
 
 
 /*
diff --git a/arch/ia64/sn/kernel/xpc_main.c b/drivers/misc/sgi-xp/xpc_main.c
similarity index 99%
rename from arch/ia64/sn/kernel/xpc_main.c
rename to drivers/misc/sgi-xp/xpc_main.c
index 9e0b164..bdb2cf1 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/drivers/misc/sgi-xp/xpc_main.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -59,7 +59,7 @@
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/uaccess.h>
-#include <asm/sn/xpc.h>
+#include "xpc.h"
 
 
 /* define two XPC debug device structures to be used with dev_dbg() et al */
diff --git a/arch/ia64/sn/kernel/xpc_partition.c b/drivers/misc/sgi-xp/xpc_partition.c
similarity index 99%
rename from arch/ia64/sn/kernel/xpc_partition.c
rename to drivers/misc/sgi-xp/xpc_partition.c
index 9e97c26..7412dc7 100644
--- a/arch/ia64/sn/kernel/xpc_partition.c
+++ b/drivers/misc/sgi-xp/xpc_partition.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -28,7 +28,7 @@
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/nodepda.h>
 #include <asm/sn/addrs.h>
-#include <asm/sn/xpc.h>
+#include "xpc.h"
 
 
 /* XPC is exiting flag */
diff --git a/arch/ia64/sn/kernel/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
similarity index 99%
rename from arch/ia64/sn/kernel/xpnet.c
rename to drivers/misc/sgi-xp/xpnet.c
index a5df672..38552f3 100644
--- a/arch/ia64/sn/kernel/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1999,2001-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1999-2008 Silicon Graphics, Inc. All rights reserved.
  */
 
 
@@ -38,7 +38,7 @@
 #include <asm/sn/sn_sal.h>
 #include <asm/types.h>
 #include <asm/atomic.h>
-#include <asm/sn/xp.h>
+#include "xp.h"
 
 
 /*

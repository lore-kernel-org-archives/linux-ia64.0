From: Christoph Hellwig <hch@lst.de>
Date: Thu, 25 Sep 2003 19:54:24 +0000
Subject: [PATCH] kill sn_ksyms.c
Message-Id: <marc-linux-ia64-106451999732538@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

None of the exported symbols is referenced by a module, even more
the file doesn't compile shen CONFIG_IA64_SGI_SN_DEBUG is set.


--- 1.15/arch/ia64/sn/kernel/Makefile	Wed Jul 30 13:40:14 2003
+++ edited/arch/ia64/sn/kernel/Makefile	Fri Aug 29 16:04:13 2003
@@ -11,4 +11,3 @@
 
 obj-y				+= probe.o setup.o bte.o irq.o mca.o idle.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
-obj-$(CONFIG_MODULES)           += sn_ksyms.o
--- 1.5/arch/ia64/sn/kernel/sn_ksyms.c	Mon Aug  4 19:02:37 2003
+++ edited/arch/ia64/sn/kernel/sn_ksyms.c	Fri Aug 29 16:04:42 2003
@@ -1,37 +0,0 @@
-/* 
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-
-
-/*
- * Architecture-specific kernel symbols
- */
-
-#include <linux/config.h>
-#include <linux/module.h>
-#include <linux/mm.h>
-#include <asm/machvec.h>
-#include <asm/sn/intr.h>
-#include <asm/sn/sgi.h>
-#include <asm/sn/types.h>
-#include <asm/sn/arch.h>
-#include <asm/sn/bte.h>
-#include <asm/sal.h>
-#include <asm/sn/sn_sal.h>
-
-#ifdef CONFIG_IA64_SGI_SN_DEBUG
-EXPORT_SYMBOL(__pa_debug);
-EXPORT_SYMBOL(__va_debug);
-#endif
-
-EXPORT_SYMBOL(bte_copy);
-EXPORT_SYMBOL(bte_unaligned_copy);
-EXPORT_SYMBOL(ia64_sal);
-EXPORT_SYMBOL(sal_lock);
-EXPORT_SYMBOL(sn_local_partid);
-
-

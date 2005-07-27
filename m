From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 27 Jul 2005 22:03:38 +0000
Subject: [PATCH] ia64: remove useless asm-ia64/segment.h includes
Message-Id: <200507271603.38034.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove references to asm-ia64/segment.h, which is empty.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work/arch/ia64/pci/pci.c
=================================--- work.orig/arch/ia64/pci/pci.c	2005-07-25 15:04:19.000000000 -0600
+++ work/arch/ia64/pci/pci.c	2005-07-25 15:10:55.000000000 -0600
@@ -24,7 +24,6 @@
 
 #include <asm/machvec.h>
 #include <asm/page.h>
-#include <asm/segment.h>
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/sal.h>
Index: work/arch/ia64/ia32/ia32_signal.c
=================================--- work.orig/arch/ia64/ia32/ia32_signal.c	2005-07-25 15:04:19.000000000 -0600
+++ work/arch/ia64/ia32/ia32_signal.c	2005-07-25 15:10:55.000000000 -0600
@@ -29,7 +29,6 @@
 #include <asm/uaccess.h>
 #include <asm/rse.h>
 #include <asm/sigcontext.h>
-#include <asm/segment.h>
 
 #include "ia32priv.h"
 
Index: work/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- work.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-07-25 15:04:19.000000000 -0600
+++ work/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-07-25 15:10:55.000000000 -0600
@@ -36,7 +36,6 @@
 #include <asm/topology.h>
 #include <asm/smp.h>
 #include <asm/semaphore.h>
-#include <asm/segment.h>
 #include <asm/uaccess.h>
 #include <asm/sal.h>
 #include <asm/sn/io.h>

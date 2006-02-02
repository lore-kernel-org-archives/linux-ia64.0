From: Jes Sorensen <jes@sgi.com>
Date: Thu, 02 Feb 2006 10:50:05 +0000
Subject: [patch] include/asm-ia64/sn/intr.h more sn2 housekeeping
Message-Id: <yq0oe1qnig2.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


House keeping - eliminate unneeded parenthesis in macro defines.

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 include/asm-ia64/sn/intr.h |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

Index: linux-2.6/include/asm-ia64/sn/intr.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/intr.h
+++ linux-2.6/include/asm-ia64/sn/intr.h
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #ifndef _ASM_IA64_SN_INTR_H
@@ -11,26 +11,26 @@
 
 #include <linux/rcupdate.h>
 
-#define SGI_UART_VECTOR		(0xe9)
+#define SGI_UART_VECTOR		0xe9
 
 /* Reserved IRQs : Note, not to exceed IA64_SN2_FIRST_DEVICE_VECTOR */
-#define SGI_XPC_ACTIVATE                (0x30)
-#define SGI_II_ERROR                    (0x31)
-#define SGI_XBOW_ERROR                  (0x32)
-#define SGI_PCIASIC_ERROR               (0x33)
-#define SGI_ACPI_SCI_INT                (0x34)
-#define SGI_TIOCA_ERROR                 (0x35)
-#define SGI_TIO_ERROR                   (0x36)
-#define SGI_TIOCX_ERROR                 (0x37)
-#define SGI_MMTIMER_VECTOR              (0x38)
-#define SGI_XPC_NOTIFY                  (0xe7)
-
-#define IA64_SN2_FIRST_DEVICE_VECTOR    (0x3c)
-#define IA64_SN2_LAST_DEVICE_VECTOR     (0xe6)
-
-#define SN2_IRQ_RESERVED        (0x1)
-#define SN2_IRQ_CONNECTED       (0x2)
-#define SN2_IRQ_SHARED          (0x4)
+#define SGI_XPC_ACTIVATE	0x30
+#define SGI_II_ERROR		0x31
+#define SGI_XBOW_ERROR		0x32
+#define SGI_PCIASIC_ERROR	0x33
+#define SGI_ACPI_SCI_INT	0x34
+#define SGI_TIOCA_ERROR		0x35
+#define SGI_TIO_ERROR		0x36
+#define SGI_TIOCX_ERROR		0x37
+#define SGI_MMTIMER_VECTOR	0x38
+#define SGI_XPC_NOTIFY		0xe7
+
+#define IA64_SN2_FIRST_DEVICE_VECTOR	0x3c
+#define IA64_SN2_LAST_DEVICE_VECTOR	0xe6
+
+#define SN2_IRQ_RESERVED	0x1
+#define SN2_IRQ_CONNECTED	0x2
+#define SN2_IRQ_SHARED		0x4
 
 // The SN PROM irq struct
 struct sn_irq_info {

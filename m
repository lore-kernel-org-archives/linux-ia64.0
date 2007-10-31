From: Russ Anderson <rja@sgi.com>
Date: Wed, 31 Oct 2007 16:10:38 +0000
Subject: [patch] Disable/re-enable CPE interrupts on Altix
Message-Id: <20071031161038.GA5321@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Disable/re-enable CPE interrupts on Altix

When the CPE handler encounters too many CPEs (such as a solid single
bit memory error), it sets up a polling timer and disables the CPE
interrupt (to avoid excessive overhead logging the stream of single
bit errors).  disable_irq_nosync() calls chip->disable() to provide
a chipset specifiec interface for disabling the interrupt.  This patch
adds the Altix specific support to disable and re-enable the CPE interrupt.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/mca.c    |    2 +-
 arch/ia64/sn/kernel/irq.c |    8 +++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

Index: test/arch/ia64/sn/kernel/irq.c
=================================--- test.orig/arch/ia64/sn/kernel/irq.c	2007-10-31 10:34:28.813022778 -0500
+++ test/arch/ia64/sn/kernel/irq.c	2007-10-31 10:44:15.605442886 -0500
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2007 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/irq.h>
@@ -85,12 +85,18 @@ static void sn_shutdown_irq(unsigned int
 {
 }
 
+extern void ia64_mca_register_cpev(int);
+
 static void sn_disable_irq(unsigned int irq)
 {
+	if (irq = local_vector_to_irq(IA64_CPE_VECTOR))
+		ia64_mca_register_cpev(0);
 }
 
 static void sn_enable_irq(unsigned int irq)
 {
+	if (irq = local_vector_to_irq(IA64_CPE_VECTOR))
+		ia64_mca_register_cpev(irq);
 }
 
 static void sn_ack_irq(unsigned int irq)
Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2007-10-31 10:34:28.817023274 -0500
+++ test/arch/ia64/kernel/mca.c	2007-10-31 10:34:32.045423392 -0500
@@ -571,7 +571,7 @@ out:
  *  Outputs
  *      None
  */
-static void __init
+void
 ia64_mca_register_cpev (int cpev)
 {
 	/* Register the CPE interrupt vector with SAL */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

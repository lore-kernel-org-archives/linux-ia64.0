From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Wed, 14 Apr 2004 01:18:42 +0000
Subject: [PATCH] 2.6-latest-bk. PCI MSI missing #define in include/asm-ia64/irq.h
Message-Id: <20040414011842.GA18829@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The auto build system at:
http://www.gelato.unsw.edu.au/kerncomp/
fails to compile all defconfigs due to a missing
#define.
This was due to this update:
http://linux.bkbits.net:8080/linux-2.5/diffs/drivers/pci/msi.c@1.6?nav=index.html|src/|src/drivers|src/drivers/pci|hist/drivers/pci/msi.c

The value set for NR_VECTORS may be wrong?

NOT tested for booting due to lack or resources.

Darren

# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1763  -> 1.1764 
#	include/asm-ia64/irq.h	1.6     -> 1.7    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/04/14	dsw@quasar.(none)	1.1764
# NR_VECTORS and NR_IRQ_VECTORS are both required for ia64 builds that include CONFIG_PCI_USE_VECTOR
# --------------------------------------------
#
diff -Nru a/include/asm-ia64/irq.h b/include/asm-ia64/irq.h
--- a/include/asm-ia64/irq.h	Wed Apr 14 10:47:56 2004
+++ b/include/asm-ia64/irq.h	Wed Apr 14 10:47:56 2004
@@ -12,6 +12,7 @@
  */
 
 #define NR_IRQS		256
+#define NR_VECTORS	NR_IRQS
 #define NR_IRQ_VECTORS	NR_IRQS
 
 static __inline__ int


--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------

From: Mark Maule <maule@sgi.com>
Date: Fri, 23 Sep 2005 17:31:53 +0000
Subject: [PATCH] altix: fix sn_pci_legacy_read/fix sn_pci_legacy_write
Message-Id: <20050923173153.7589.58108.17262@lnx-maule.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch adds a #define for SN_SAL_IOIF_PCI_SAFE and makes that the
preferred method of implementing sn_pci_legacy_read() and
sn_pci_legacy_write().

This SAL call has been present in SGI proms since version 4.10.  If the
SN_SAL_IOIF_PCI_SAFE call fails, revert to the previous code for compatability
with older proms.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: dorado/arch/ia64/sn/pci/pci_dma.c
=================================--- dorado.orig/arch/ia64/sn/pci/pci_dma.c	2005-09-23 12:18:11.725112579 -0500
+++ dorado/arch/ia64/sn/pci/pci_dma.c	2005-09-23 12:19:47.419570826 -0500
@@ -326,6 +326,29 @@
 {
 	unsigned long addr;
 	int ret;
+	struct ia64_sal_retval isrv;
+
+	/*
+	 * First, try the SN_SAL_IOIF_PCI_SAFE SAL call which can work
+	 * around hw issues at the pci bus level.  SGI proms older than
+	 * 4.10 don't implment this.
+	 */
+
+	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
+		pci_domain_nr(bus), bus->number,
+		0, /* io */
+		0, /* read */
+		port, size, __pa(val));
+
+	if (isrv.status = 0)
+		return size;
+
+	/*
+	 * If the above failed, retry using the SAL_PROBE call which should
+	 * be present in all proms (but which cannot work round PCI chipset
+	 * bugs).  This code is retained for compatability with old
+	 * pre-4.10 proms, and should be removed at some point in the future.
+	 */
 
 	if (!SN_PCIBUS_BUSSOFT(bus))
 		return -ENODEV;
@@ -349,6 +372,29 @@
 	int ret = size;
 	unsigned long paddr;
 	unsigned long *addr;
+	struct ia64_sal_retval isrv;
+
+	/*
+	 * First, try the SN_SAL_IOIF_PCI_SAFE SAL call which can work
+	 * around hw issues at the pci bus level.  SGI proms older than
+	 * 4.10 don't implment this.
+	 */
+
+	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
+		pci_domain_nr(bus), bus->number,
+		0, /* io */
+		1, /* write */
+		port, size, __pa(&val));
+
+	if (isrv.status = 0)
+		return size;
+
+	/*
+	 * If the above failed, retry using the SAL_PROBE call which should
+	 * be present in all proms (but which cannot work round PCI chipset
+	 * bugs).  This code is retained for compatability with old
+	 * pre-4.10 proms, and should be removed at some point in the future.
+	 */
 
 	if (!SN_PCIBUS_BUSSOFT(bus)) {
 		ret = -ENODEV;
Index: dorado/include/asm-ia64/sn/sn_sal.h
=================================--- dorado.orig/include/asm-ia64/sn/sn_sal.h	2005-09-23 12:18:40.739767187 -0500
+++ dorado/include/asm-ia64/sn/sn_sal.h	2005-09-23 12:19:47.423476682 -0500
@@ -68,7 +68,7 @@
 #define  SN_SAL_IOIF_INTERRUPT			   0x0200004a
 #define  SN_SAL_HWPERF_OP			   0x02000050   // lock
 #define  SN_SAL_IOIF_ERROR_INTERRUPT		   0x02000051
-
+#define  SN_SAL_IOIF_PCI_SAFE			   0x02000052
 #define  SN_SAL_IOIF_SLOT_ENABLE		   0x02000053
 #define  SN_SAL_IOIF_SLOT_DISABLE		   0x02000054
 #define  SN_SAL_IOIF_GET_HUBDEV_INFO		   0x02000055

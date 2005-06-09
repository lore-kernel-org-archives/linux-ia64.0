From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 09 Jun 2005 12:48:15 +0000
Subject: [PATCH 01/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42A83A8F.9020503@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com>
In-Reply-To: <42A8386F.2060100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

[This is 1 of 10 patches, "iochk-01-generic.patch"]

- It defines:
     a pair of function  : iochk_clear and iochk_read
     a function for init : iochk_init
     type of control var : iocookie
   and describe "no-ops" as its "generic" action.

- HAVE_ARCH_IOMAP_CHECK allows us to change whole definition
   of these functions and type from generic one to specific one.
   See next patch (2 of 10).

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---

  drivers/pci/pci.c           |    2 ++
  include/asm-generic/iomap.h |   16 ++++++++++++++++
  lib/iomap.c                 |   26 ++++++++++++++++++++++++++
  3 files changed, 44 insertions(+)

Index: linux-2.6.11.11/lib/iomap.c
=================================--- linux-2.6.11.11.orig/lib/iomap.c
+++ linux-2.6.11.11/lib/iomap.c
@@ -210,3 +210,29 @@ void pci_iounmap(struct pci_dev *dev, vo
  }
  EXPORT_SYMBOL(pci_iomap);
  EXPORT_SYMBOL(pci_iounmap);
+
+/*
+ * Clear/Read iocookie to check IO error while using iomap.
+ *
+ * Note that default iochk_clear-read pair interfaces don't have
+ * any effective error check, but some high-reliable platforms
+ * would provide useful information to you.
+ * And note that some action may be limited (ex. irq-unsafe)
+ * between the pair depend on the facility of the platform.
+ */
+#ifndef HAVE_ARCH_IOMAP_CHECK
+void iochk_init(void) { ; }
+
+void iochk_clear(iocookie *cookie, struct pci_dev *dev)
+{
+	/* no-ops */
+}
+
+int iochk_read(iocookie *cookie)
+{
+	/* no-ops */
+	return 0;
+}
+EXPORT_SYMBOL(iochk_clear);
+EXPORT_SYMBOL(iochk_read);
+#endif /* HAVE_ARCH_IOMAP_CHECK */
Index: linux-2.6.11.11/include/asm-generic/iomap.h
=================================--- linux-2.6.11.11.orig/include/asm-generic/iomap.h
+++ linux-2.6.11.11/include/asm-generic/iomap.h
@@ -60,4 +60,20 @@ struct pci_dev;
  extern void __iomem *pci_iomap(struct pci_dev *dev, int bar, unsigned long max);
  extern void pci_iounmap(struct pci_dev *dev, void __iomem *);

+/*
+ * IOMAP_CHECK provides additional interfaces for drivers to detect
+ * some IO errors, supports drivers having ability to recover errors.
+ *
+ * All works around iomap-check depends on the design of "iocookie"
+ * structure. Every architecture owning its iomap-check is free to
+ * define the actual design of iocookie to fit its special style.
+ */
+#ifndef HAVE_ARCH_IOMAP_CHECK
+typedef unsigned long iocookie;
+#endif
+
+extern void iochk_init(void);
+extern void iochk_clear(iocookie *cookie, struct pci_dev *dev);
+extern int  iochk_read(iocookie *cookie);
+
  #endif
Index: linux-2.6.11.11/drivers/pci/pci.c
=================================--- linux-2.6.11.11.orig/drivers/pci/pci.c
+++ linux-2.6.11.11/drivers/pci/pci.c
@@ -782,6 +782,8 @@ static int __devinit pci_init(void)
  	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
  		pci_fixup_device(pci_fixup_final, dev);
  	}
+
+	iochk_init();
  	return 0;
  }


From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 01 Sep 2005 05:42:10 +0000
Subject: [PATCH 2.6.13] IOCHK interface for I/O error handling/detecting
Message-Id: <431694B2.4040800@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel list <linux-kernel@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org

This patch implements IOCHK interfaces that enable PCI drivers to
detect error and make their error handling easier.

Please refer archives if you need, e.g. http://lwn.net/Articles/139240/

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---

  drivers/pci/pci.c           |    2 ++
  include/asm-generic/iomap.h |   32 ++++++++++++++++++++++++++++++++
  2 files changed, 34 insertions(+)

Index: linux-2.6.13/include/asm-generic/iomap.h
=================================--- linux-2.6.13.orig/include/asm-generic/iomap.h
+++ linux-2.6.13/include/asm-generic/iomap.h
@@ -65,4 +65,36 @@ struct pci_dev;
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
+/* Dummy definition of default iocookie */
+typedef int iocookie;
+#endif
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
+#ifdef HAVE_ARCH_IOMAP_CHECK
+extern void iochk_init(void);
+extern void iochk_clear(iocookie *cookie, struct pci_dev *dev);
+extern int iochk_read(iocookie *cookie);
+#else
+static inline void iochk_init(void) {}
+static inline void iochk_clear(iocookie *cookie, struct pci_dev *dev) {}
+static inline int iochk_read(iocookie *cookie) { return 0; }
+#endif
+
  #endif
Index: linux-2.6.13/drivers/pci/pci.c
=================================--- linux-2.6.13.orig/drivers/pci/pci.c
+++ linux-2.6.13/drivers/pci/pci.c
@@ -777,6 +777,8 @@ static int __devinit pci_init(void)
  	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
  		pci_fixup_device(pci_fixup_final, dev);
  	}
+
+	iochk_init();
  	return 0;
  }



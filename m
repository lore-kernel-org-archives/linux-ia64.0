From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 06 Jul 2005 10:15:02 +0000
Subject: Re: [PATCH 2.6.13-rc1 01/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42CBAF26.3070002@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <20050706.152627.68274440.yoshfuji@linux-ipv6.org>
In-Reply-To: <20050706.152627.68274440.yoshfuji@linux-ipv6.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yoshfuji@linux-ipv6.org
Cc: seto.hidetoshi@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, linas@austin.ibm.com, benh@kernel.crashing.org, tlnguyen@snoqualmie.dp.intel.com, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev@ozlabs.org

YOSHIFUJI Hideaki wrote:
>>Index: linux-2.6.13-rc1/lib/iomap.c
>>=================================>>--- linux-2.6.13-rc1.orig/lib/iomap.c
>>+++ linux-2.6.13-rc1/lib/iomap.c
>>@@ -230,3 +230,9 @@ void pci_iounmap(struct pci_dev *dev, vo
>>  }
>>  EXPORT_SYMBOL(pci_iomap);
>>  EXPORT_SYMBOL(pci_iounmap);
>>+
>>+#ifndef HAVE_ARCH_IOMAP_CHECK
>>+/* Since generic funcs are inlined and defined in header, just export */
>>+EXPORT_SYMBOL(iochk_clear);
>>+EXPORT_SYMBOL(iochk_read);
>>+#endif
:
> It looks strange to me.
> You cannot export "static inline" functions.
> You can export iochk_{init,clear,read} only
> if HAVE_ARCH_IOMAP_CHECK is defined.

Oh yes, I had such strange feel too.
I'm not sure there was a compile error or not (it seems good),
but if you right(suppose so) I should remove them.

Fortunately dropping these export doesn't affect any of other
following patches in this series.
Please replace only 01 patch to following new one, and reuse
rest 02 to 10 patches if this is actually strange.

Thanks,
H.Seto

---

  drivers/pci/pci.c           |    2 ++
  include/asm-generic/iomap.h |   32 ++++++++++++++++++++++++++++++++
  2 files changed, 34 insertions(+)

Index: linux-2.6.13-rc1/include/asm-generic/iomap.h
=================================--- linux-2.6.13-rc1.orig/include/asm-generic/iomap.h
+++ linux-2.6.13-rc1/include/asm-generic/iomap.h
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
Index: linux-2.6.13-rc1/drivers/pci/pci.c
=================================--- linux-2.6.13-rc1.orig/drivers/pci/pci.c
+++ linux-2.6.13-rc1/drivers/pci/pci.c
@@ -767,6 +767,8 @@ static int __devinit pci_init(void)
  	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
  		pci_fixup_device(pci_fixup_final, dev);
  	}
+
+	iochk_init();
  	return 0;
  }




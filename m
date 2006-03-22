From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 22 Mar 2006 09:44:06 +0000
Subject: [PATCH 1/4] PCIERR-IA64 : interfaces for synchronous I/O error detection
Message-Id: <44211C66.3040000@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch is 1/4 of PCIERR implementation for IA64.

This part enable us to switch IA64-specific PCIERR by config.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----

  arch/ia64/Kconfig            |   10 ++++++++++
  arch/ia64/lib/Makefile       |    1 +
  arch/ia64/lib/pcierr_check.c |   23 +++++++++++++++++++++++
  include/asm-ia64/pci.h       |    8 ++++++++
  4 files changed, 42 insertions(+)

Index: linux-2.6.16_WORK/arch/ia64/Kconfig
=================================--- linux-2.6.16_WORK.orig/arch/ia64/Kconfig	2006-03-22 14:27:04.000000000 +0900
+++ linux-2.6.16_WORK/arch/ia64/Kconfig	2006-03-22 14:41:02.000000000 +0900
@@ -410,6 +410,16 @@
  	bool
  	default PCI

+config PCIERR_CHECK
+	bool "Support pcierr interfaces for IO error detection."
+	depends on PCI
+	help
+	  Saying Y provides pcierr infrastructure for "RAS-aware" drivers
+	  to detect and recover some IO errors, which strongly required by
+	  some of very-high-reliable systems.
+
+	  If you don't know what to do here, say N.
+
  source "drivers/pci/Kconfig"

  source "drivers/pci/hotplug/Kconfig"
Index: linux-2.6.16_WORK/arch/ia64/lib/Makefile
=================================--- linux-2.6.16_WORK.orig/arch/ia64/lib/Makefile	2006-03-22 14:27:04.000000000 +0900
+++ linux-2.6.16_WORK/arch/ia64/lib/Makefile	2006-03-22 14:41:02.000000000 +0900
@@ -15,6 +15,7 @@
  lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
  lib-$(CONFIG_PERFMON)	+= carta_random.o
  lib-$(CONFIG_MD_RAID5)	+= xor.o
+lib-$(CONFIG_PCIERR_CHECK) += pcierr_check.o

  AFLAGS___divdi3.o	  AFLAGS___udivdi3.o	= -DUNSIGNED
Index: linux-2.6.16_WORK/include/asm-ia64/pci.h
=================================--- linux-2.6.16_WORK.orig/include/asm-ia64/pci.h	2006-03-22 14:27:04.000000000 +0900
+++ linux-2.6.16_WORK/include/asm-ia64/pci.h	2006-03-22 14:41:02.000000000 +0900
@@ -171,4 +171,12 @@

  #define pcibios_scan_all_fns(a, b)	0

+#ifdef CONFIG_PCIERR_CHECK
+/* Enable ia64 pcierr - See arch/ia64/lib/pcierr_check.c */
+#define HAVE_ARCH_PCIERR_CHECK
+typedef struct {
+	int dummy;
+} iocookie;
+#endif /* CONFIG_PCIERR_CHECK  */
+
  #endif /* _ASM_IA64_PCI_H */
Index: linux-2.6.16_WORK/arch/ia64/lib/pcierr_check.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.16_WORK/arch/ia64/lib/pcierr_check.c	2006-03-22 14:41:02.000000000 +0900
@@ -0,0 +1,23 @@
+/*
+ * File:    pcierr_check.c
+ * Purpose: Implement the IA64 specific pcierr interfaces for RAS-drivers
+ */
+
+#include <linux/pci.h>
+
+void pcierr_clear(iocookie *cookie, struct pci_dev *dev);
+int  pcierr_read(iocookie *cookie);
+
+void pcierr_clear(iocookie *cookie, struct pci_dev *dev)
+{
+	/* register device etc. */
+}
+
+int pcierr_read(iocookie *cookie)
+{
+	/* check error etc. */
+	return 0;
+}
+
+EXPORT_SYMBOL(pcierr_read);
+EXPORT_SYMBOL(pcierr_clear);


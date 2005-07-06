From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 06 Jul 2005 04:58:12 +0000
Subject: [PATCH 2.6.13-rc1 02/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42CB6566.8090804@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com>
In-Reply-To: <42CB63B2.6000505@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>
Cc: Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

[This is 2 of 10 patches, "iochk-02-ia64.patch"]

- Add "config IOMAP_CHECK" to change definitions from generic
   to specific.

- Defines ia64 version of:
     iochk_clear, iochk_read, iochk_init, and iocookie
   But they are no-ops yet. See next patch (3 of 10).

Changes from previous one for 2.6.11.11:
   - simplify define of iocookie structure.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---

  arch/ia64/Kconfig           |   13 +++++++++++++
  arch/ia64/lib/Makefile      |    1 +
  arch/ia64/lib/iomap_check.c |   30 ++++++++++++++++++++++++++++++
  include/asm-ia64/io.h       |   13 +++++++++++++
  4 files changed, 57 insertions(+)

Index: linux-2.6.13-rc1/arch/ia64/lib/Makefile
=================================--- linux-2.6.13-rc1.orig/arch/ia64/lib/Makefile
+++ linux-2.6.13-rc1/arch/ia64/lib/Makefile
@@ -16,6 +16,7 @@ lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.
  lib-$(CONFIG_PERFMON)	+= carta_random.o
  lib-$(CONFIG_MD_RAID5)	+= xor.o
  lib-$(CONFIG_HAVE_DEC_LOCK) += dec_and_lock.o
+lib-$(CONFIG_IOMAP_CHECK) += iomap_check.o

  AFLAGS___divdi3.o	  AFLAGS___udivdi3.o	= -DUNSIGNED
Index: linux-2.6.13-rc1/arch/ia64/Kconfig
=================================--- linux-2.6.13-rc1.orig/arch/ia64/Kconfig
+++ linux-2.6.13-rc1/arch/ia64/Kconfig
@@ -413,6 +413,19 @@ config PCI_DOMAINS
  	bool
  	default PCI

+config IOMAP_CHECK
+	bool "Support iochk interfaces for IO error detection."
+	depends on PCI && EXPERIMENTAL
+	---help---
+	  Saying Y provides iochk infrastructure for "RAS-aware" drivers
+	  to detect and recover some IO errors, which strongly required by
+	  some of very-high-reliable systems.
+	  The implementation of this infrastructure is highly depend on arch,
+	  bus system, chipset and so on.
+	  Currentry, very few drivers on few arch actually implements this.
+
+	  If you don't know what to do here, say N.
+
  source "drivers/pci/Kconfig"

  source "drivers/pci/hotplug/Kconfig"
Index: linux-2.6.13-rc1/arch/ia64/lib/iomap_check.c
=================================--- /dev/null
+++ linux-2.6.13-rc1/arch/ia64/lib/iomap_check.c
@@ -0,0 +1,30 @@
+/*
+ * File:    iomap_check.c
+ * Purpose: Implement the IA64 specific iomap recovery interfaces
+ */
+
+#include <linux/pci.h>
+
+void iochk_init(void);
+void iochk_clear(iocookie *cookie, struct pci_dev *dev);
+int  iochk_read(iocookie *cookie);
+
+void iochk_init(void)
+{
+	/* setup */
+}
+
+void iochk_clear(iocookie *cookie, struct pci_dev *dev)
+{
+	/* register device etc. */
+}
+
+int iochk_read(iocookie *cookie)
+{
+	/* check error etc. */
+
+	return 0;
+}
+
+EXPORT_SYMBOL(iochk_read);
+EXPORT_SYMBOL(iochk_clear);
Index: linux-2.6.13-rc1/include/asm-ia64/io.h
=================================--- linux-2.6.13-rc1.orig/include/asm-ia64/io.h
+++ linux-2.6.13-rc1/include/asm-ia64/io.h
@@ -70,6 +70,19 @@ extern unsigned int num_io_spaces;
  #include <asm/machvec.h>
  #include <asm/page.h>
  #include <asm/system.h>
+
+#ifdef CONFIG_IOMAP_CHECK
+
+/* ia64 iocookie */
+typedef struct {
+	int dummy;
+} iocookie;
+
+/* Enable ia64 iochk - See arch/ia64/lib/iomap_check.c */
+#define HAVE_ARCH_IOMAP_CHECK
+
+#endif /* CONFIG_IOMAP_CHECK  */
+
  #include <asm-generic/iomap.h>

  /*



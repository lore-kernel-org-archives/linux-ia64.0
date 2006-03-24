From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 24 Mar 2006 07:50:12 +0000
Subject: [PATCH 4/6] PCIERR : interfaces for synchronous I/O error detection
Message-Id: <4423A4B4.4080408@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44210D1B.7010806@jp.fujitsu.com> <20060322210157.GH12335@kroah.com>
In-Reply-To: <20060322210157.GH12335@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz

This patch is 3/4 of PCIERR implementation for IA64.

This part describes modifies in mca_drv.
If MCA happens and the error address was in resource of registered
RAS-aware driver, mca_drv notify the error to the driver and
restart the system. Soon notified driver will do its recovery.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----
  arch/ia64/kernel/mca_drv.c   |   81 +++++++++++++++++++++++++++++++++++++++++++
  arch/ia64/lib/pcierr_check.c |    1
  2 files changed, 82 insertions(+)

Index: linux-2.6.16_WORK/arch/ia64/kernel/mca_drv.c
=================================--- linux-2.6.16_WORK.orig/arch/ia64/kernel/mca_drv.c
+++ linux-2.6.16_WORK/arch/ia64/kernel/mca_drv.c
@@ -37,6 +37,11 @@

  #include "mca_drv.h"

+#ifdef CONFIG_PCIERR_CHECK
+#include <linux/pci.h>
+extern struct list_head pcierr_list;
+#endif
+
  /* max size of SAL error record (default) */
  static int sal_rec_max = 10000;

@@ -399,6 +404,76 @@
  	return MCA_IS_GLOBAL;
  }

+#ifdef CONFIG_PCIERR_CHECK
+
+/**
+ * get_target_identifier - get address of target_identifier
+ * @peidx:	pointer of index of processor error section
+ *
+ * Return value:
+ *	addr if valid / 0 if not valid
+ */
+static u64 get_target_identifier(peidx_table_t *peidx)
+{
+	sal_log_mod_error_info_t *smei;
+
+	smei = peidx_bus_check(peidx, 0);
+	if (smei->valid.target_identifier)
+		return (smei->target_identifier);
+	return 0;
+}
+
+#define isMEM64(resource) \
+(((resource).flags & (PCI_BASE_ADDRESS_SPACE|PCI_BASE_ADDRESS_MEM_TYPE_MASK)) \
+	= (PCI_BASE_ADDRESS_SPACE_MEMORY|PCI_BASE_ADDRESS_MEM_TYPE_64))
+
+/**
+ * pcierr_recovery - Check if MCA occur on transaction in pcierr_list.
+ * @peidx:	pointer of index of processor error section
+ *
+ * Return value:
+ *	1 if error could be caught in driver / 0 if not
+ */
+static int pcierr_recovery(peidx_table_t *peidx)
+{
+	u64 addr;
+	int i, loop = 0;
+	struct pci_dev *tdev;
+	iocookie *cookie;
+
+	if (list_empty(&pcierr_list))
+		return 0;
+
+	addr = get_target_identifier(peidx);
+	if (!addr)
+		return 0;
+
+	list_for_each_entry(cookie, &pcierr_list, list) {
+		/* MCA is non-maskable, be careful */
+		if (loop++ > 1024 || !cookie)
+			break;
+		/* double check */
+		if (pcierr_list.next = cookie->list.next)
+			break;
+		tdev = cookie->dev;
+		if (!tdev)
+			continue;
+		for (i = 0; i < PCI_ROM_RESOURCE; i++) {
+			if (tdev->resource[i].start <= addr
+				&& addr <= tdev->resource[i].end) {
+				cookie->error = 1;
+				return 1;
+			}
+			if (isMEM64(tdev->resource[i]))
+				i++;
+		}
+	}
+
+	return 0;
+}
+
+#endif /* CONFIG_PCIERR_CHECK */
+
  /**
   * recover_from_read_error - Try to recover the errors which type are "read"s.
   * @slidx:	pointer of index of SAL error record
@@ -473,6 +548,12 @@

  	}

+#ifdef CONFIG_PCIERR_CHECK
+	/* Are there any RAS-aware drivers? */
+	if (pcierr_recovery(peidx))
+		return 1;
+#endif
+
  	return 0;
  }

Index: linux-2.6.16_WORK/arch/ia64/lib/pcierr_check.c
=================================--- linux-2.6.16_WORK.orig/arch/ia64/lib/pcierr_check.c
+++ linux-2.6.16_WORK/arch/ia64/lib/pcierr_check.c
@@ -68,5 +68,6 @@
  	return 0;
  }

+EXPORT_SYMBOL(pcierr_list);	/* for MCA driver */
  EXPORT_SYMBOL(pcierr_read);
  EXPORT_SYMBOL(pcierr_clear);


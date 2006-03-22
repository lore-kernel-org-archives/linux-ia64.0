From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 22 Mar 2006 09:45:09 +0000
Subject: [PATCH 2/4] PCIERR-IA64 : interfaces for synchronous I/O error detection
Message-Id: <44211CA5.1010501@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch is 2/4 of PCIERR implementation for IA64.

This part describes base of IA64-specific PCIERR, registering
driver and checking status.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----

  arch/ia64/lib/pcierr_check.c |   53 +++++++++++++++++++++++++++++++++++++++++--
  include/asm-ia64/pci.h       |    4 ++-
  2 files changed, 54 insertions(+), 3 deletions(-)

Index: linux-2.6.16_WORK/arch/ia64/lib/pcierr_check.c
=================================--- linux-2.6.16_WORK.orig/arch/ia64/lib/pcierr_check.c	2006-03-22 14:41:02.000000000 +0900
+++ linux-2.6.16_WORK/arch/ia64/lib/pcierr_check.c	2006-03-22 14:41:03.000000000 +0900
@@ -8,14 +8,63 @@
  void pcierr_clear(iocookie *cookie, struct pci_dev *dev);
  int  pcierr_read(iocookie *cookie);

+LIST_HEAD(pcierr_list);		/* all iocookies are listed in this */
+DEFINE_SPINLOCK(pcierr_lock);	/* to protect list above */
+
+static int have_error(struct pci_dev *dev);
+
  void pcierr_clear(iocookie *cookie, struct pci_dev *dev)
  {
-	/* register device etc. */
+	unsigned long flag;
+
+	INIT_LIST_HEAD(&(cookie->list));
+
+	cookie->dev = dev;
+
+	spin_lock_irqsave(&pcierr_lock, flag);
+	list_add(&cookie->list, &pcierr_list);
+	spin_unlock_irqrestore(&pcierr_lock, flag);
+
+	cookie->error = 0;
  }

  int pcierr_read(iocookie *cookie)
  {
-	/* check error etc. */
+	unsigned long flag;
+	int ret = 0;
+
+	spin_lock_irqsave(&pcierr_lock, flag);
+	if (cookie->error || have_error(cookie->dev))
+		ret = 1;
+	list_del(&cookie->list);
+	spin_unlock_irqrestore(&pcierr_lock, flag);
+
+	return ret;
+}
+
+static int have_error(struct pci_dev *dev)
+{
+	u16 status;
+
+	/* check status */
+	switch (dev->hdr_type) {
+	case PCI_HEADER_TYPE_NORMAL: /* 0 */
+		pci_read_config_word(dev, PCI_STATUS, &status);
+		break;
+	case PCI_HEADER_TYPE_BRIDGE: /* 1 */
+		pci_read_config_word(dev, PCI_SEC_STATUS, &status);
+		break;
+	case PCI_HEADER_TYPE_CARDBUS: /* 2 */
+		return 0; /* FIX ME */
+	default:
+		BUG();
+	}
+
+	if ( (status & PCI_STATUS_REC_TARGET_ABORT)
+		|| (status & PCI_STATUS_REC_MASTER_ABORT)
+		|| (status & PCI_STATUS_DETECTED_PARITY) )
+		return 1;
+
  	return 0;
  }

Index: linux-2.6.16_WORK/include/asm-ia64/pci.h
=================================--- linux-2.6.16_WORK.orig/include/asm-ia64/pci.h	2006-03-22 14:41:02.000000000 +0900
+++ linux-2.6.16_WORK/include/asm-ia64/pci.h	2006-03-22 14:41:03.000000000 +0900
@@ -175,7 +175,9 @@
  /* Enable ia64 pcierr - See arch/ia64/lib/pcierr_check.c */
  #define HAVE_ARCH_PCIERR_CHECK
  typedef struct {
-	int dummy;
+	struct list_head	list;
+	struct pci_dev		*dev;	/* target device */
+	unsigned long		error;	/* error flag */
  } iocookie;
  #endif /* CONFIG_PCIERR_CHECK  */



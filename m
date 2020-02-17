From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Mon, 17 Feb 2020 13:44:05 +0000
Subject: [PATCH v2] tty/serial: cleanup after ioc*_serial driver removal
Message-Id: <20200217134405.19154-1-lukas.bulwahn@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>, Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Anatoly Pugachev <matorola@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Joe Perches <joe@perches.com>, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Lukas Bulwahn <lukas.bulwahn@gmail.com>

Commit 9c860e4cf708 ("tty/serial: remove the ioc3_serial driver") and
commit a017ef17cfd8 ("tty/serial: remove the ioc4_serial driver") removed
the ioc{3,4}_serial driver, but missed some files.

Fortunately, ./scripts/get_maintainer.pl --self-test complains:

  warning: no file matches F: drivers/tty/serial/ioc?_serial.c

The driver is gone, so remove the header and maintainer
entry as well.

The serial.rst Documentation might be useful, so we keep it and update
the maintainer entry to the document's actual maintainers.

Signed-off-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
---
Christoph, please ack. Tony, please pick this patch.
applies cleanly on 5.6-rc2 and next-20200217
only sanity-grep for filenames, no compile testing

 MAINTAINERS          |  9 +----
 include/linux/ioc3.h | 93 --------------------------------------------
 2 files changed, 1 insertion(+), 101 deletions(-)
 delete mode 100644 include/linux/ioc3.h

diff --git a/MAINTAINERS b/MAINTAINERS
index a0d86490c2c6..ffd51bb3ba7f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7945,6 +7945,7 @@ L:	linux-ia64@vger.kernel.org
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git
 S:	Maintained
 F:	arch/ia64/
+F:	Documentation/ia64/
 
 IBM Power 842 compression accelerator
 M:	Haren Myneni <haren@us.ibm.com>
@@ -15043,14 +15044,6 @@ M:	Dimitri Sivanich <sivanich@sgi.com>
 S:	Maintained
 F:	drivers/misc/sgi-gru/
 
-SGI SN-IA64 (Altix) SERIAL CONSOLE DRIVER
-M:	Pat Gefre <pfg@sgi.com>
-L:	linux-ia64@vger.kernel.org
-S:	Supported
-F:	Documentation/ia64/serial.rst
-F:	drivers/tty/serial/ioc?_serial.c
-F:	include/linux/ioc?.h
-
 SGI XP/XPC/XPNET DRIVER
 M:	Cliff Whickman <cpw@sgi.com>
 M:	Robin Holt <robinmholt@gmail.com>
diff --git a/include/linux/ioc3.h b/include/linux/ioc3.h
deleted file mode 100644
index 38b286e9a46c..000000000000
--- a/include/linux/ioc3.h
+++ /dev/null
@@ -1,93 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2005 Stanislaw Skowronek <skylark@linux-mips.org>
- */
-
-#ifndef _LINUX_IOC3_H
-#define _LINUX_IOC3_H
-
-#include <asm/sn/ioc3.h>
-
-#define IOC3_MAX_SUBMODULES	32
-
-#define IOC3_CLASS_NONE		0
-#define IOC3_CLASS_BASE_IP27	1
-#define IOC3_CLASS_BASE_IP30	2
-#define IOC3_CLASS_MENET_123	3
-#define IOC3_CLASS_MENET_4	4
-#define IOC3_CLASS_CADDUO	5
-#define IOC3_CLASS_SERIAL	6
-
-/* One of these per IOC3 */
-struct ioc3_driver_data {
-	struct list_head list;
-	int id;				/* IOC3 sequence number */
-	/* PCI mapping */
-	unsigned long pma;		/* physical address */
-	struct ioc3 __iomem *vma;	/* pointer to registers */
-	struct pci_dev *pdev;		/* PCI device */
-	/* IRQ stuff */
-	int dual_irq;			/* set if separate IRQs are used */
-	int irq_io, irq_eth;		/* IRQ numbers */
-	/* GPIO magic */
-	spinlock_t gpio_lock;
-	unsigned int gpdr_shadow;
-	/* NIC identifiers */
-	char nic_part[32];
-	char nic_serial[16];
-	char nic_mac[6];
-	/* submodule set */
-	int class;
-	void *data[IOC3_MAX_SUBMODULES];	/* for submodule use */
-	int active[IOC3_MAX_SUBMODULES];	/* set if probe succeeds */
-	/* is_ir_lock must be held while
-	 * modifying sio_ie values, so
-	 * we can be sure that sio_ie is
-	 * not changing when we read it
-	 * along with sio_ir.
-	 */
-	spinlock_t ir_lock;	/* SIO_IE[SC] mod lock */
-};
-
-/* One per submodule */
-struct ioc3_submodule {
-	char *name;		/* descriptive submodule name */
-	struct module *owner;	/* owning kernel module */
-	int ethernet;		/* set for ethernet drivers */
-	int (*probe) (struct ioc3_submodule *, struct ioc3_driver_data *);
-	int (*remove) (struct ioc3_submodule *, struct ioc3_driver_data *);
-	int id;			/* assigned by IOC3, index for the "data" array */
-	/* IRQ stuff */
-	unsigned int irq_mask;	/* IOC3 IRQ mask, leave clear for Ethernet */
-	int reset_mask;		/* non-zero if you want the ioc3.c module to reset interrupts */
-	int (*intr) (struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-	/* private submodule data */
-	void *data;		/* assigned by submodule */
-};
-
-/**********************************
- * Functions needed by submodules *
- **********************************/
-
-#define IOC3_W_IES		0
-#define IOC3_W_IEC		1
-
-/* registers a submodule for all existing and future IOC3 chips */
-extern int ioc3_register_submodule(struct ioc3_submodule *);
-/* unregisters a submodule */
-extern void ioc3_unregister_submodule(struct ioc3_submodule *);
-/* enables IRQs indicated by irq_mask for a specified IOC3 chip */
-extern void ioc3_enable(struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-/* ackowledges specified IRQs */
-extern void ioc3_ack(struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-/* disables IRQs indicated by irq_mask for a specified IOC3 chip */
-extern void ioc3_disable(struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-/* atomically sets GPCR bits */
-extern void ioc3_gpcr_set(struct ioc3_driver_data *, unsigned int);
-/* general ireg writer */
-extern void ioc3_write_ireg(struct ioc3_driver_data *idd, uint32_t value, int reg);
-
-#endif
-- 
2.17.1

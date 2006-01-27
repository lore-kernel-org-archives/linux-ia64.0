From: Mark Maule <maule@sgi.com>
Date: Fri, 27 Jan 2006 19:59:07 +0000
Subject: [PATCH] altix:  disable msi for all altix pci devices
Message-Id: <20060127195907.8398.91096.98219@lnx-maule.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Temporary patch to make pci_enable_msi() fail gracefully on altix.  Will be
removed after 2.6.16 releases and the msi abstraction patches start flowing.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: linux-2.6.14/arch/ia64/sn/kernel/io_init.c
=================================--- linux-2.6.14.orig/arch/ia64/sn/kernel/io_init.c	2006-01-10 09:29:57.172407877 -0600
+++ linux-2.6.14/arch/ia64/sn/kernel/io_init.c	2006-01-25 09:50:00.308356617 -0600
@@ -407,6 +407,13 @@
 		pcidev_info->pdi_sn_irq_info = NULL;
 		kfree(sn_irq_info);
 	}
+
+	/*
+	 * MSI currently not supported on altix.  Remove this when
+	 * the MSI abstraction patches are integrated into the kernel
+	 * (sometime after 2.6.16 releases)
+	 */
+	dev->no_msi = 1;
 }
 
 /*

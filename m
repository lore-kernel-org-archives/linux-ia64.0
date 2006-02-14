From: Mark Maule <maule@sgi.com>
Date: Tue, 14 Feb 2006 16:23:37 +0000
Subject: [PATCH] altix:  export sn_pcidev_info_get
Message-Id: <20060214162337.GA16954@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Export sn_pcidev_info_get.

Signed-off-by Mark Maule <maule@sgi.com>

Index: suse-patches/arch/ia64/sn/kernel/io_init.c
=================================--- suse-patches.orig/arch/ia64/sn/kernel/io_init.c	2006-02-14 09:54:34.000000000 -0600
+++ suse-patches/arch/ia64/sn/kernel/io_init.c	2006-02-14 09:57:40.095264008 -0600
@@ -734,3 +734,4 @@
 EXPORT_SYMBOL(sn_pci_controller_fixup);
 EXPORT_SYMBOL(sn_bus_store_sysdata);
 EXPORT_SYMBOL(sn_bus_free_sysdata);
+EXPORT_SYMBOL(sn_pcidev_info_get);

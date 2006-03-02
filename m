From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 02 Mar 2006 23:59:50 +0000
Subject: [PATCH] gensparse_defconfig: turn on PNPACPI
Message-Id: <200603021659.50082.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Turn on CONFIG_PNPACPI.  I recently removed 8250_acpi.c.  All devices
previously claimed by 8250_acpi.c should now be claimed by 8250_pnp.c.
This depends on having CONFIG_PNPACPI so ACPI devices show up as PNP
devices.

All other ia64 defconfigs either have CONFIG_PNPACPI already, or
don't have 8250 support turned on at all.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

diff -r e2b91b5a8109 arch/ia64/configs/gensparse_defconfig
--- a/arch/ia64/configs/gensparse_defconfig	Thu Mar  2 07:49:50 2006 +0800
+++ b/arch/ia64/configs/gensparse_defconfig	Thu Mar  2 16:53:03 2006 -0700
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
 # Linux kernel version: 2.6.16-rc5
-# Mon Feb 27 16:15:43 2006
+# Thu Mar  2 16:39:10 2006
 #
 
 #
@@ -312,7 +312,13 @@ CONFIG_FW_LOADER=m
 #
 # Plug and Play support
 #
-# CONFIG_PNP is not set
+CONFIG_PNP=y
+# CONFIG_PNP_DEBUG is not set
+
+#
+# Protocols
+#
+CONFIG_PNPACPI=y
 
 #
 # Block devices
@@ -357,6 +363,7 @@ CONFIG_BLK_DEV_IDESCSI=m
 # IDE chipset support/bugfixes
 #
 CONFIG_IDE_GENERIC=y
+# CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
 # CONFIG_IDEPCI_SHARE_IRQ is not set
 # CONFIG_BLK_DEV_OFFBOARD is not set
@@ -525,6 +532,7 @@ CONFIG_DUMMY=m
 # CONFIG_BONDING is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
+# CONFIG_NET_SB1000 is not set
 
 #
 # ARCnet devices

From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 20 Aug 2004 19:31:52 +0000
Subject: [PATCH] update sn2_defconfig
Message-Id: <200408201531.52786.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_oGlJB3JsV7mEUX1"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_oGlJB3JsV7mEUX1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

To make simulations a little easier, turn on CONFIG_EXT2 and IDE disk support.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_oGlJB3JsV7mEUX1
Content-Type: text/x-diff;
  charset="us-ascii";
  name="sn2-defconfig-update-4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-update-4.patch"

===== arch/ia64/configs/sn2_defconfig 1.10 vs edited =====
--- 1.10/arch/ia64/configs/sn2_defconfig	2004-08-09 16:41:34 -07:00
+++ edited/arch/ia64/configs/sn2_defconfig	2004-08-20 12:29:56 -07:00
@@ -7,7 +7,6 @@
 #
 CONFIG_EXPERIMENTAL=y
 CONFIG_CLEAN_COMPILE=y
-CONFIG_STANDALONE=y
 
 #
 # General setup
@@ -115,7 +114,7 @@
 #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
-# CONFIG_PCI_USE_VECTOR is not set
+# CONFIG_PCI_MSI is not set
 CONFIG_PCI_LEGACY_PROC=y
 CONFIG_PCI_NAMES=y
 
@@ -142,6 +141,7 @@
 #
 # Generic Driver Options
 #
+CONFIG_STANDALONE=y
 CONFIG_PREVENT_FIRMWARE_BUILD=y
 CONFIG_FW_LOADER=m
 # CONFIG_DEBUG_DRIVER is not set
@@ -185,7 +185,8 @@
 # Please see Documentation/ide.txt for help/info on IDE drives
 #
 # CONFIG_BLK_DEV_IDE_SATA is not set
-# CONFIG_BLK_DEV_IDEDISK is not set
+CONFIG_BLK_DEV_IDEDISK=y
+# CONFIG_IDEDISK_MULTI_MODE is not set
 CONFIG_BLK_DEV_IDECD=y
 # CONFIG_BLK_DEV_IDETAPE is not set
 # CONFIG_BLK_DEV_IDEFLOPPY is not set
@@ -716,7 +717,7 @@
 #
 # File systems
 #
-CONFIG_EXT2_FS=m
+CONFIG_EXT2_FS=y
 CONFIG_EXT2_FS_XATTR=y
 CONFIG_EXT2_FS_POSIX_ACL=y
 CONFIG_EXT2_FS_SECURITY=y
@@ -791,7 +792,6 @@
 # CONFIG_BEFS_FS is not set
 # CONFIG_BFS_FS is not set
 # CONFIG_EFS_FS is not set
-# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
 # CONFIG_CRAMFS is not set
 # CONFIG_VXFS_FS is not set
 # CONFIG_HPFS_FS is not set
@@ -820,6 +820,7 @@
 # CONFIG_SMB_NLS_DEFAULT is not set
 CONFIG_CIFS=m
 # CONFIG_CIFS_STATS is not set
+# CONFIG_CIFS_XATTR is not set
 # CONFIG_CIFS_POSIX is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
@@ -945,6 +946,7 @@
 # CONFIG_CRYPTO_CAST6 is not set
 # CONFIG_CRYPTO_TEA is not set
 # CONFIG_CRYPTO_ARC4 is not set
+# CONFIG_CRYPTO_KHAZAD is not set
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_CRC32C is not set

--Boundary-00=_oGlJB3JsV7mEUX1--

From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sat, 17 Jul 2004 21:04:08 +0000
Subject: [PATCH] update sn2_defconfig to include new console
Message-Id: <200407171704.08219.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_IRZ+AtkLHSQcYpx"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_IRZ+AtkLHSQcYpx
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Now that Linus' tree has the new sn2 console driver, make sn2_defconfig enable 
it by default.  The device is major 204, minor 40.  Note that you'll probably 
have to update your elilo.conf and inittab to use the new driver, as it's 
called ttySG0 rather than ttyS0.

David, can you send this update to Linus along with whatever else you're going 
to have him pull for 2.6.8?  That'll keep things from being inconsistent.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_IRZ+AtkLHSQcYpx
Content-Type: text/x-diff;
  charset="us-ascii";
  name="sn2-defconfig-console.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-console.patch"

===== arch/ia64/configs/sn2_defconfig 1.8 vs edited =====
--- 1.8/arch/ia64/configs/sn2_defconfig	2004-06-24 06:42:21 -07:00
+++ edited/arch/ia64/configs/sn2_defconfig	2004-07-17 09:24:59 -07:00
@@ -24,6 +24,7 @@
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 CONFIG_KALLSYMS_ALL=y
+CONFIG_KALLSYMS_EXTRA_PASS=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_IOSCHED_NOOP=y
@@ -85,6 +86,7 @@
 # Firmware Drivers
 #
 CONFIG_EFI_VARS=y
+# CONFIG_EFI_PCDP is not set
 CONFIG_BINFMT_ELF=y
 # CONFIG_BINFMT_MISC is not set
 
@@ -271,7 +273,6 @@
 # CONFIG_SCSI_AIC7XXX is not set
 # CONFIG_SCSI_AIC7XXX_OLD is not set
 # CONFIG_SCSI_AIC79XX is not set
-# CONFIG_SCSI_ADVANSYS is not set
 # CONFIG_SCSI_MEGARAID is not set
 CONFIG_SCSI_SATA=y
 # CONFIG_SCSI_SATA_SVW is not set
@@ -527,8 +528,6 @@
 # CONFIG_SYNCLINKMP is not set
 # CONFIG_N_HDLC is not set
 # CONFIG_STALDRV is not set
-CONFIG_SGI_L1_SERIAL=y
-CONFIG_SGI_L1_SERIAL_CONSOLE=y
 
 #
 # Serial drivers
@@ -538,6 +537,8 @@
 #
 # Non-8250 serial port support
 #
+CONFIG_SERIAL_CORE=y
+CONFIG_SERIAL_SGI_L1_CONSOLE=y
 CONFIG_UNIX98_PTYS=y
 CONFIG_LEGACY_PTYS=y
 CONFIG_LEGACY_PTY_COUNT=256
@@ -573,6 +574,11 @@
 # CONFIG_I2C is not set
 
 #
+# Dallas's 1-wire bus
+#
+# CONFIG_W1 is not set
+
+#
 # Misc devices
 #
 
@@ -751,6 +757,7 @@
 CONFIG_JOLIET=y
 # CONFIG_ZISOFS is not set
 CONFIG_UDF_FS=m
+CONFIG_UDF_NLS=y
 
 #
 # DOS/FAT/NT Filesystems
@@ -785,6 +792,7 @@
 # CONFIG_BEFS_FS is not set
 # CONFIG_BFS_FS is not set
 # CONFIG_EFS_FS is not set
+# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
 # CONFIG_CRAMFS is not set
 # CONFIG_VXFS_FS is not set
 # CONFIG_HPFS_FS is not set
@@ -885,6 +893,7 @@
 #
 # Library routines
 #
+# CONFIG_CRC_CCITT is not set
 CONFIG_CRC32=y
 # CONFIG_LIBCRC32C is not set
 CONFIG_ZLIB_INFLATE=m
@@ -935,6 +944,7 @@
 # CONFIG_CRYPTO_AES is not set
 # CONFIG_CRYPTO_CAST5 is not set
 # CONFIG_CRYPTO_CAST6 is not set
+# CONFIG_CRYPTO_TEA is not set
 # CONFIG_CRYPTO_ARC4 is not set
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set

--Boundary-00=_IRZ+AtkLHSQcYpx--

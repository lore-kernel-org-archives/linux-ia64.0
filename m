From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 19:16:03 +0000
Subject: [PATCH] defconfig update
Message-Id: <200501061116.03327.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_z5Y3B7Fv1iHOZoM"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_z5Y3B7Fv1iHOZoM
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This adds support for a few new modules (e.g. Infiniband, new ACPI stuff, 
etc.) and also enables initrd support (required for Fedora for example--it's 
really not that painful, I use the same initrd for most of my kernels).

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_z5Y3B7Fv1iHOZoM
Content-Type: text/plain;
  charset="us-ascii";
  name="generic-defconfig-update-5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="generic-defconfig-update-5.patch"

===== arch/ia64/defconfig 1.35 vs edited =====
--- 1.35/arch/ia64/defconfig	2004-11-02 13:17:17 -08:00
+++ edited/arch/ia64/defconfig	2005-01-06 11:13:15 -08:00
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.10-rc1
-# Tue Nov  2 11:47:56 2004
+# Linux kernel version: 2.6.10
+# Thu Jan  6 11:13:13 2005
 #
 
 #
@@ -59,6 +59,7 @@
 CONFIG_64BIT=y
 CONFIG_MMU=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
+CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
@@ -90,6 +91,7 @@
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
+CONFIG_ACPI_DEALLOCATE_IRQ=y
 
 #
 # Firmware Drivers
@@ -111,8 +113,10 @@
 CONFIG_ACPI_BOOT=y
 CONFIG_ACPI_INTERPRETER=y
 CONFIG_ACPI_BUTTON=m
+CONFIG_ACPI_VIDEO=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
+CONFIG_ACPI_HOTPLUG_CPU=y
 CONFIG_ACPI_THERMAL=m
 CONFIG_ACPI_NUMA=y
 CONFIG_ACPI_BLACKLIST_YEAR=0
@@ -121,6 +125,7 @@
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_PCI=y
 CONFIG_ACPI_SYSTEM=y
+CONFIG_ACPI_CONTAINER=m
 
 #
 # Bus options (PCI, PCMCIA)
@@ -176,6 +181,7 @@
 #
 # Plug and Play support
 #
+# CONFIG_PNP is not set
 
 #
 # Block devices
@@ -189,8 +195,10 @@
 CONFIG_BLK_DEV_NBD=m
 # CONFIG_BLK_DEV_SX8 is not set
 # CONFIG_BLK_DEV_UB is not set
-CONFIG_BLK_DEV_RAM=m
+CONFIG_BLK_DEV_RAM=y
+CONFIG_BLK_DEV_RAM_COUNT=16
 CONFIG_BLK_DEV_RAM_SIZE=4096
+CONFIG_BLK_DEV_INITRD=y
 CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_CDROM_PKTCDVD is not set
 
@@ -288,6 +296,7 @@
 #
 CONFIG_SCSI_SPI_ATTRS=y
 CONFIG_SCSI_FC_ATTRS=y
+# CONFIG_SCSI_ISCSI_ATTRS is not set
 
 #
 # SCSI low-level drivers
@@ -328,7 +337,6 @@
 CONFIG_SCSI_QLA2300=m
 CONFIG_SCSI_QLA2322=m
 # CONFIG_SCSI_QLA6312 is not set
-# CONFIG_SCSI_QLA6322 is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
 # CONFIG_SCSI_DEBUG is not set
@@ -345,6 +353,7 @@
 CONFIG_MD_RAID5=m
 CONFIG_MD_RAID6=m
 CONFIG_MD_MULTIPATH=m
+# CONFIG_MD_FAULTY is not set
 CONFIG_BLK_DEV_DM=m
 CONFIG_DM_CRYPT=m
 CONFIG_DM_SNAPSHOT=m
@@ -395,6 +404,7 @@
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
 CONFIG_IP_TCPDIAG=y
+# CONFIG_IP_TCPDIAG_IPV6 is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETFILTER is not set
 
@@ -573,6 +583,7 @@
 # CONFIG_SERIO_SERPORT is not set
 # CONFIG_SERIO_CT82C710 is not set
 # CONFIG_SERIO_PCIPS2 is not set
+CONFIG_SERIO_LIBPS2=y
 # CONFIG_SERIO_RAW is not set
 
 #
@@ -601,6 +612,7 @@
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
 # CONFIG_CYCLADES is not set
+# CONFIG_MOXA_SMARTIO is not set
 # CONFIG_SYNCLINK is not set
 # CONFIG_SYNCLINKMP is not set
 # CONFIG_N_HDLC is not set
@@ -651,7 +663,7 @@
 CONFIG_AGP=m
 CONFIG_AGP_I460=m
 CONFIG_AGP_HP_ZX1=m
-CONFIG_DRM=y
+CONFIG_DRM=m
 CONFIG_DRM_TDFX=m
 CONFIG_DRM_R128=m
 CONFIG_DRM_RADEON=m
@@ -810,6 +822,7 @@
 # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
 CONFIG_USB_OHCI_HCD=m
 CONFIG_USB_UHCI_HCD=m
+# CONFIG_USB_SL811_HCD is not set
 
 #
 # USB Device Class drivers
@@ -819,6 +832,10 @@
 # CONFIG_USB_MIDI is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
+
+#
+# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be needed; see USB_STORAGE Help for more information
+#
 CONFIG_USB_STORAGE=m
 # CONFIG_USB_STORAGE_DEBUG is not set
 # CONFIG_USB_STORAGE_RW_DETECT is not set
@@ -858,7 +875,6 @@
 #
 # CONFIG_USB_MDC800 is not set
 # CONFIG_USB_MICROTEK is not set
-# CONFIG_USB_HPUSBSCSI is not set
 
 #
 # USB Multimedia devices
@@ -870,7 +886,7 @@
 #
 
 #
-# USB Network adaptors
+# USB Network Adapters
 #
 # CONFIG_USB_CATC is not set
 # CONFIG_USB_KAWETH is not set
@@ -913,6 +929,20 @@
 # CONFIG_USB_GADGET is not set
 
 #
+# MMC/SD Card support
+#
+# CONFIG_MMC is not set
+
+#
+# InfiniBand support
+#
+CONFIG_INFINIBAND=m
+CONFIG_INFINIBAND_MTHCA=m
+# CONFIG_INFINIBAND_MTHCA_DEBUG is not set
+CONFIG_INFINIBAND_IPOIB=m
+# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
+
+#
 # File systems
 #
 CONFIG_EXT2_FS=y
@@ -1023,7 +1053,7 @@
 CONFIG_CIFS=m
 # CONFIG_CIFS_STATS is not set
 # CONFIG_CIFS_XATTR is not set
-# CONFIG_CIFS_POSIX is not set
+# CONFIG_CIFS_EXPERIMENTAL is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
@@ -1158,7 +1188,12 @@
 # CONFIG_CRYPTO_TEA is not set
 # CONFIG_CRYPTO_ARC4 is not set
 # CONFIG_CRYPTO_KHAZAD is not set
+# CONFIG_CRYPTO_ANUBIS is not set
 # CONFIG_CRYPTO_DEFLATE is not set
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_CRC32C is not set
 # CONFIG_CRYPTO_TEST is not set
+
+#
+# Hardware crypto devices
+#

--Boundary-00=_z5Y3B7Fv1iHOZoM--

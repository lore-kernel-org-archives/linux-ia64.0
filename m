From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 10 Jan 2005 21:59:38 +0000
Subject: [PATCH] update sn2_defconfig (fix initrd, add IB support)
Message-Id: <200501101359.38681.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Krv4BUvyPX0T1qH"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_Krv4BUvyPX0T1qH
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Don't know what happened to initrd support, but 'make sn2_defconfig' no longer 
enables it.  This patch should fix that, along with enabling modular IB 
support.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_Krv4BUvyPX0T1qH
Content-Type: text/plain;
  charset="us-ascii";
  name="sn2-defconfig-update-8.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-update-8.patch"

===== arch/ia64/configs/sn2_defconfig 1.15 vs edited =====
--- 1.15/arch/ia64/configs/sn2_defconfig	2004-11-02 12:42:19 -08:00
+++ edited/arch/ia64/configs/sn2_defconfig	2005-01-10 13:57:46 -08:00
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.10-rc1
-# Mon Nov  1 14:35:44 2004
+# Linux kernel version: 2.6.10
+# Mon Jan 10 13:57:35 2005
 #
 
 #
@@ -58,6 +58,7 @@
 CONFIG_64BIT=y
 CONFIG_MMU=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
+CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
@@ -75,6 +76,7 @@
 CONFIG_IA64_L1_CACHE_SHIFT=7
 CONFIG_NUMA=y
 CONFIG_VIRTUAL_MEM_MAP=y
+CONFIG_HOLES_IN_ZONE=y
 CONFIG_DISCONTIGMEM=y
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
@@ -90,6 +92,7 @@
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
+CONFIG_ACPI_DEALLOCATE_IRQ=y
 
 #
 # Firmware Drivers
@@ -110,6 +113,7 @@
 CONFIG_ACPI_BOOT=y
 CONFIG_ACPI_INTERPRETER=y
 # CONFIG_ACPI_BUTTON is not set
+CONFIG_ACPI_VIDEO=m
 # CONFIG_ACPI_FAN is not set
 # CONFIG_ACPI_PROCESSOR is not set
 CONFIG_ACPI_NUMA=y
@@ -119,6 +123,7 @@
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_PCI=y
 CONFIG_ACPI_SYSTEM=y
+# CONFIG_ACPI_CONTAINER is not set
 
 #
 # Bus options (PCI, PCMCIA)
@@ -174,6 +179,7 @@
 #
 # Plug and Play support
 #
+# CONFIG_PNP is not set
 
 #
 # Block devices
@@ -188,6 +194,7 @@
 # CONFIG_BLK_DEV_SX8 is not set
 # CONFIG_BLK_DEV_UB is not set
 CONFIG_BLK_DEV_RAM=y
+CONFIG_BLK_DEV_RAM_COUNT=16
 CONFIG_BLK_DEV_RAM_SIZE=4096
 CONFIG_BLK_DEV_INITRD=y
 CONFIG_INITRAMFS_SOURCE=""
@@ -200,6 +207,7 @@
 CONFIG_IOSCHED_AS=y
 CONFIG_IOSCHED_DEADLINE=y
 CONFIG_IOSCHED_CFQ=y
+CONFIG_ATA_OVER_ETH=m
 
 #
 # ATA/ATAPI/MFM/RLL support
@@ -287,6 +295,7 @@
 #
 CONFIG_SCSI_SPI_ATTRS=y
 CONFIG_SCSI_FC_ATTRS=y
+# CONFIG_SCSI_ISCSI_ATTRS is not set
 
 #
 # SCSI low-level drivers
@@ -333,7 +342,6 @@
 CONFIG_SCSI_QLA2300=y
 CONFIG_SCSI_QLA2322=y
 # CONFIG_SCSI_QLA6312 is not set
-# CONFIG_SCSI_QLA6322 is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
 # CONFIG_SCSI_DEBUG is not set
@@ -350,6 +358,7 @@
 CONFIG_MD_RAID5=y
 # CONFIG_MD_RAID6 is not set
 CONFIG_MD_MULTIPATH=y
+# CONFIG_MD_FAULTY is not set
 CONFIG_BLK_DEV_DM=y
 CONFIG_DM_CRYPT=m
 CONFIG_DM_SNAPSHOT=m
@@ -399,6 +408,8 @@
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
+CONFIG_IP_TCPDIAG=y
+# CONFIG_IP_TCPDIAG_IPV6 is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
 # CONFIG_INET6_AH is not set
@@ -478,6 +489,7 @@
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
 # CONFIG_S2IO_NAPI is not set
+# CONFIG_2BUFF_MODE is not set
 
 #
 # Token Ring devices
@@ -554,6 +566,8 @@
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
 # CONFIG_CYCLADES is not set
+# CONFIG_MOXA_SMARTIO is not set
+# CONFIG_ISI is not set
 # CONFIG_SYNCLINK is not set
 # CONFIG_SYNCLINKMP is not set
 # CONFIG_N_HDLC is not set
@@ -664,6 +678,7 @@
 # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
 CONFIG_USB_OHCI_HCD=m
 CONFIG_USB_UHCI_HCD=m
+# CONFIG_USB_SL811_HCD is not set
 
 #
 # USB Device Class drivers
@@ -671,6 +686,10 @@
 # CONFIG_USB_BLUETOOTH_TTY is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
+
+#
+# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be needed; see USB_STORAGE Help for more information
+#
 # CONFIG_USB_STORAGE is not set
 
 #
@@ -700,7 +719,6 @@
 #
 # CONFIG_USB_MDC800 is not set
 # CONFIG_USB_MICROTEK is not set
-# CONFIG_USB_HPUSBSCSI is not set
 
 #
 # USB Multimedia devices
@@ -712,7 +730,7 @@
 #
 
 #
-# USB Network adaptors
+# USB Network Adapters
 #
 # CONFIG_USB_CATC is not set
 # CONFIG_USB_KAWETH is not set
@@ -734,7 +752,6 @@
 #
 # CONFIG_USB_EMI62 is not set
 # CONFIG_USB_EMI26 is not set
-# CONFIG_USB_TIGL is not set
 # CONFIG_USB_AUERSWALD is not set
 # CONFIG_USB_RIO500 is not set
 # CONFIG_USB_LEGOTOWER is not set
@@ -754,6 +771,20 @@
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
@@ -864,7 +895,7 @@
 CONFIG_CIFS=m
 # CONFIG_CIFS_STATS is not set
 # CONFIG_CIFS_XATTR is not set
-# CONFIG_CIFS_POSIX is not set
+# CONFIG_CIFS_EXPERIMENTAL is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
@@ -958,6 +989,7 @@
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
 # CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
+# CONFIG_DEBUG_FS is not set
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
 # CONFIG_IA64_PRINT_HAZARDS is not set
@@ -994,7 +1026,12 @@
 # CONFIG_CRYPTO_TEA is not set
 # CONFIG_CRYPTO_ARC4 is not set
 # CONFIG_CRYPTO_KHAZAD is not set
+# CONFIG_CRYPTO_ANUBIS is not set
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_CRC32C is not set
 # CONFIG_CRYPTO_TEST is not set
+
+#
+# Hardware crypto devices
+#

--Boundary-00=_Krv4BUvyPX0T1qH--

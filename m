From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 01 Nov 2004 22:38:03 +0000
Subject: [PATCH] update sn2_defconfig
Message-Id: <200411011438.03513.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_LrrhBUqnxaZRhda"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_LrrhBUqnxaZRhda
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Update sn2_defconfig to reflect some new options:
  o enable MCA debugging of more than just TLB errors
  o enable tmpfs xattr support
  o enable kernel userspace events
  o defaults for other new options

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_LrrhBUqnxaZRhda
Content-Type: text/plain;
  charset="us-ascii";
  name="sn2-defconfig-update-7.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-update-7.patch"

===== arch/ia64/configs/sn2_defconfig 1.14 vs edited =====
--- 1.14/arch/ia64/configs/sn2_defconfig	2004-09-28 08:54:34 -07:00
+++ edited/arch/ia64/configs/sn2_defconfig	2004-11-01 14:35:55 -08:00
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.9-rc2
-# Fri Sep 24 08:59:00 2004
+# Linux kernel version: 2.6.10-rc1
+# Mon Nov  1 14:35:44 2004
 #
 
 #
@@ -9,6 +9,7 @@
 #
 CONFIG_EXPERIMENTAL=y
 CONFIG_CLEAN_COMPILE=y
+CONFIG_LOCK_KERNEL=y
 
 #
 # General setup
@@ -22,6 +23,7 @@
 # CONFIG_AUDIT is not set
 CONFIG_LOG_BUF_SHIFT=20
 CONFIG_HOTPLUG=y
+CONFIG_KOBJECT_UEVENT=y
 # CONFIG_IKCONFIG is not set
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
@@ -29,12 +31,12 @@
 # CONFIG_KALLSYMS_EXTRA_PASS is not set
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
-CONFIG_IOSCHED_NOOP=y
-CONFIG_IOSCHED_AS=y
-CONFIG_IOSCHED_DEADLINE=y
-CONFIG_IOSCHED_CFQ=y
 # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
 CONFIG_SHMEM=y
+CONFIG_CC_ALIGN_FUNCTIONS=0
+CONFIG_CC_ALIGN_LABELS=0
+CONFIG_CC_ALIGN_LOOPS=0
+CONFIG_CC_ALIGN_JUMPS=0
 # CONFIG_TINY_SHMEM is not set
 
 #
@@ -45,6 +47,7 @@
 # CONFIG_MODULE_FORCE_UNLOAD is not set
 CONFIG_OBSOLETE_MODPARM=y
 # CONFIG_MODVERSIONS is not set
+# CONFIG_MODULE_SRCVERSION_ALL is not set
 CONFIG_KMOD=y
 CONFIG_STOP_MACHINE=y
 
@@ -84,6 +87,7 @@
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
+CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
 
@@ -109,6 +113,7 @@
 # CONFIG_ACPI_FAN is not set
 # CONFIG_ACPI_PROCESSOR is not set
 CONFIG_ACPI_NUMA=y
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_BUS=y
 CONFIG_ACPI_POWER=y
@@ -136,9 +141,13 @@
 CONFIG_HOTPLUG_PCI_SGI=y
 
 #
-# PCMCIA/CardBus support
+# PCCARD (PCMCIA/CardBus) support
+#
+# CONFIG_PCCARD is not set
+
+#
+# PC-card bridges
 #
-# CONFIG_PCMCIA is not set
 
 #
 # Device Drivers
@@ -181,6 +190,16 @@
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_SIZE=4096
 CONFIG_BLK_DEV_INITRD=y
+CONFIG_INITRAMFS_SOURCE=""
+# CONFIG_CDROM_PKTCDVD is not set
+
+#
+# IO Schedulers
+#
+CONFIG_IOSCHED_NOOP=y
+CONFIG_IOSCHED_AS=y
+CONFIG_IOSCHED_DEADLINE=y
+CONFIG_IOSCHED_CFQ=y
 
 #
 # ATA/ATAPI/MFM/RLL support
@@ -199,7 +218,6 @@
 # CONFIG_BLK_DEV_IDEFLOPPY is not set
 # CONFIG_BLK_DEV_IDESCSI is not set
 # CONFIG_IDE_TASK_IOCTL is not set
-# CONFIG_IDE_TASKFILE_IO is not set
 
 #
 # IDE chipset support/bugfixes
@@ -283,6 +301,7 @@
 # CONFIG_MEGARAID_NEWGEN is not set
 # CONFIG_MEGARAID_LEGACY is not set
 CONFIG_SCSI_SATA=y
+# CONFIG_SCSI_SATA_AHCI is not set
 # CONFIG_SCSI_SATA_SVW is not set
 # CONFIG_SCSI_ATA_PIIX is not set
 # CONFIG_SCSI_SATA_NV is not set
@@ -290,6 +309,7 @@
 # CONFIG_SCSI_SATA_SX4 is not set
 # CONFIG_SCSI_SATA_SIL is not set
 # CONFIG_SCSI_SATA_SIS is not set
+# CONFIG_SCSI_SATA_ULI is not set
 # CONFIG_SCSI_SATA_VIA is not set
 CONFIG_SCSI_SATA_VITESSE=y
 # CONFIG_SCSI_BUSLOGIC is not set
@@ -299,12 +319,14 @@
 # CONFIG_SCSI_FUTURE_DOMAIN is not set
 # CONFIG_SCSI_GDTH is not set
 # CONFIG_SCSI_IPS is not set
+# CONFIG_SCSI_INITIO is not set
 # CONFIG_SCSI_INIA100 is not set
 # CONFIG_SCSI_SYM53C8XX_2 is not set
 # CONFIG_SCSI_IPR is not set
 # CONFIG_SCSI_QLOGIC_ISP is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
+# CONFIG_SCSI_QLOGIC_1280_1040 is not set
 CONFIG_SCSI_QLA2XXX=y
 # CONFIG_SCSI_QLA21XX is not set
 CONFIG_SCSI_QLA22XX=y
@@ -402,7 +424,6 @@
 # CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
-# CONFIG_NET_HW_FLOWCONTROL is not set
 
 #
 # QoS and/or fair queueing
@@ -632,6 +653,8 @@
 # CONFIG_USB_BANDWIDTH is not set
 # CONFIG_USB_DYNAMIC_MINORS is not set
 # CONFIG_USB_OTG is not set
+CONFIG_USB_ARCH_HAS_HCD=y
+CONFIG_USB_ARCH_HAS_OHCI=y
 
 #
 # USB Host Controller Drivers
@@ -651,7 +674,7 @@
 # CONFIG_USB_STORAGE is not set
 
 #
-# USB Human Interface Devices (HID)
+# USB Input Devices
 #
 CONFIG_USB_HID=m
 CONFIG_USB_HIDINPUT=y
@@ -718,9 +741,14 @@
 # CONFIG_USB_LCD is not set
 # CONFIG_USB_LED is not set
 # CONFIG_USB_CYTHERM is not set
+# CONFIG_USB_PHIDGETKIT is not set
 # CONFIG_USB_PHIDGETSERVO is not set
 
 #
+# USB ATM/DSL drivers
+#
+
+#
 # USB Gadget Support
 #
 # CONFIG_USB_GADGET is not set
@@ -758,6 +786,7 @@
 # CONFIG_QFMT_V1 is not set
 # CONFIG_QFMT_V2 is not set
 CONFIG_QUOTACTL=y
+CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=m
 CONFIG_AUTOFS4_FS=m
 
@@ -789,6 +818,8 @@
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
+CONFIG_TMPFS_XATTR=y
+CONFIG_TMPFS_SECURITY=y
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
@@ -921,9 +952,11 @@
 #
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
+# CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+# CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
@@ -936,6 +969,7 @@
 #
 # Security options
 #
+# CONFIG_KEYS is not set
 # CONFIG_SECURITY is not set
 
 #
@@ -949,7 +983,7 @@
 CONFIG_CRYPTO_SHA1=m
 # CONFIG_CRYPTO_SHA256 is not set
 # CONFIG_CRYPTO_SHA512 is not set
-# CONFIG_CRYPTO_WHIRLPOOL is not set
+# CONFIG_CRYPTO_WP512 is not set
 CONFIG_CRYPTO_DES=m
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set

--Boundary-00=_LrrhBUqnxaZRhda--

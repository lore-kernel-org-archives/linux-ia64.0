From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 29 Nov 2004 20:47:14 +0000
Subject: [PATCH] add CONFIG_SERIAL_8250_ACPI to bigsur_defconfig
Message-Id: <200411291347.14365.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Sr4qBT98ZyOjoI6"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_Sr4qBT98ZyOjoI6
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I recently removed the hard-coded assumption that if you don't have
an HCDP, you must have legacy COM ports at 0x3f8 and 0x2f8.  So
now CONFIG_SERIAL_8250_ACPI is *required* in order to find any
8250 serial devices on ia64.

--Boundary-00=_Sr4qBT98ZyOjoI6
Content-Type: text/x-diff;
  charset="us-ascii";
  name="diffs"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="diffs"

Add CONFIG_SERIAL_8250_ACPI so we can find serial devices.  In the
absence of an HCDP, we used to assume there were legacy COM ports
at 0x3f8 and 0x2f8, but I recently removed that assumption.

"console=ttyS0" still works (assuming you have CONFIG_SERIAL_8250_ACPI
turned on so you can find the ttyS0 device), but the console doesn't
start working until the serial driver initializes.  If you need an
early console and you know where it lives, something like
"console=uart,io,0x3f8" will start working very early.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

===== arch/ia64/configs/bigsur_defconfig 1.1 vs edited =====
--- 1.1/arch/ia64/configs/bigsur_defconfig	2004-09-29 11:01:43 -06:00
+++ edited/arch/ia64/configs/bigsur_defconfig	2004-11-29 13:30:49 -07:00
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.9-rc2
-# Tue Sep 28 13:26:53 2004
+# Linux kernel version: 2.6.10-rc2
+# Mon Nov 29 13:27:48 2004
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
 CONFIG_LOG_BUF_SHIFT=16
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
+# CONFIG_IA64_MCA_RECOVERY is not set
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
 
@@ -107,9 +111,11 @@
 CONFIG_ACPI_BOOT=y
 CONFIG_ACPI_INTERPRETER=y
 CONFIG_ACPI_BUTTON=m
+CONFIG_ACPI_VIDEO=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_THERMAL=m
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_BUS=y
 CONFIG_ACPI_POWER=y
@@ -131,9 +137,13 @@
 # CONFIG_HOTPLUG_PCI is not set
 
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
@@ -160,6 +170,7 @@
 #
 # Plug and Play support
 #
+# CONFIG_PNP is not set
 
 #
 # Block devices
@@ -175,6 +186,16 @@
 # CONFIG_BLK_DEV_UB is not set
 CONFIG_BLK_DEV_RAM=m
 CONFIG_BLK_DEV_RAM_SIZE=4096
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
@@ -193,7 +214,6 @@
 CONFIG_BLK_DEV_IDEFLOPPY=m
 # CONFIG_BLK_DEV_IDESCSI is not set
 # CONFIG_IDE_TASK_IOCTL is not set
-# CONFIG_IDE_TASKFILE_IO is not set
 
 #
 # IDE chipset support/bugfixes
@@ -282,12 +302,14 @@
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
 # CONFIG_SCSI_QLA22XX is not set
@@ -311,6 +333,7 @@
 CONFIG_MD_RAID5=m
 CONFIG_MD_RAID6=m
 CONFIG_MD_MULTIPATH=m
+# CONFIG_MD_FAULTY is not set
 CONFIG_BLK_DEV_DM=m
 CONFIG_DM_CRYPT=m
 CONFIG_DM_SNAPSHOT=m
@@ -357,6 +380,8 @@
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
+CONFIG_IP_TCPDIAG=y
+# CONFIG_IP_TCPDIAG_IPV6 is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETFILTER is not set
 
@@ -376,7 +401,6 @@
 # CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
-# CONFIG_NET_HW_FLOWCONTROL is not set
 
 #
 # QoS and/or fair queueing
@@ -437,7 +461,6 @@
 # CONFIG_EPIC100 is not set
 # CONFIG_SUNDANCE is not set
 # CONFIG_VIA_RHINE is not set
-# CONFIG_VIA_VELOCITY is not set
 
 #
 # Ethernet (1000 Mbit)
@@ -450,6 +473,7 @@
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
 # CONFIG_SK98LIN is not set
+# CONFIG_VIA_VELOCITY is not set
 # CONFIG_TIGON3 is not set
 
 #
@@ -549,7 +573,7 @@
 #
 CONFIG_SERIAL_8250=y
 CONFIG_SERIAL_8250_CONSOLE=y
-# CONFIG_SERIAL_8250_ACPI is not set
+CONFIG_SERIAL_8250_ACPI=y
 CONFIG_SERIAL_8250_NR_UARTS=4
 CONFIG_SERIAL_8250_EXTENDED=y
 CONFIG_SERIAL_8250_SHARE_IRQ=y
@@ -627,6 +651,7 @@
 # CONFIG_I2C_SIS5595 is not set
 # CONFIG_I2C_SIS630 is not set
 # CONFIG_I2C_SIS96X is not set
+# CONFIG_I2C_STUB is not set
 # CONFIG_I2C_VIA is not set
 # CONFIG_I2C_VIAPRO is not set
 # CONFIG_I2C_VOODOO3 is not set
@@ -644,14 +669,17 @@
 # CONFIG_SENSORS_FSCHER is not set
 # CONFIG_SENSORS_GL518SM is not set
 # CONFIG_SENSORS_IT87 is not set
+# CONFIG_SENSORS_LM63 is not set
 # CONFIG_SENSORS_LM75 is not set
 # CONFIG_SENSORS_LM77 is not set
 # CONFIG_SENSORS_LM78 is not set
 # CONFIG_SENSORS_LM80 is not set
 # CONFIG_SENSORS_LM83 is not set
 # CONFIG_SENSORS_LM85 is not set
+# CONFIG_SENSORS_LM87 is not set
 # CONFIG_SENSORS_LM90 is not set
 # CONFIG_SENSORS_MAX1619 is not set
+# CONFIG_SENSORS_PC87360 is not set
 # CONFIG_SENSORS_SMSC47M1 is not set
 # CONFIG_SENSORS_VIA686A is not set
 # CONFIG_SENSORS_W83781D is not set
@@ -773,7 +801,7 @@
 # CONFIG_SND_VX222 is not set
 
 #
-# ALSA USB devices
+# USB devices
 #
 # CONFIG_SND_USB_AUDIO is not set
 # CONFIG_SND_USB_USX2Y is not set
@@ -797,6 +825,8 @@
 # CONFIG_USB_DYNAMIC_MINORS is not set
 # CONFIG_USB_SUSPEND is not set
 # CONFIG_USB_OTG is not set
+CONFIG_USB_ARCH_HAS_HCD=y
+CONFIG_USB_ARCH_HAS_OHCI=y
 
 #
 # USB Host Controller Drivers
@@ -826,7 +856,7 @@
 # CONFIG_USB_STORAGE_JUMPSHOT is not set
 
 #
-# USB Human Interface Devices (HID)
+# USB Input Devices
 #
 CONFIG_USB_HID=m
 CONFIG_USB_HIDINPUT=y
@@ -864,7 +894,7 @@
 #
 
 #
-# USB Network adaptors
+# USB Network Adapters
 #
 # CONFIG_USB_CATC is not set
 # CONFIG_USB_KAWETH is not set
@@ -893,10 +923,15 @@
 # CONFIG_USB_LCD is not set
 # CONFIG_USB_LED is not set
 # CONFIG_USB_CYTHERM is not set
+# CONFIG_USB_PHIDGETKIT is not set
 # CONFIG_USB_PHIDGETSERVO is not set
 # CONFIG_USB_TEST is not set
 
 #
+# USB ATM/DSL drivers
+#
+
+#
 # USB Gadget Support
 #
 # CONFIG_USB_GADGET is not set
@@ -925,6 +960,7 @@
 # CONFIG_ROMFS_FS is not set
 # CONFIG_QUOTA is not set
 CONFIG_QUOTACTL=y
+CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=m
 CONFIG_AUTOFS4_FS=m
 
@@ -957,6 +993,7 @@
 CONFIG_DEVPTS_FS_XATTR=y
 CONFIG_DEVPTS_FS_SECURITY=y
 CONFIG_TMPFS=y
+# CONFIG_TMPFS_XATTR is not set
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
@@ -1087,9 +1124,11 @@
 #
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
+# CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+# CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_IA64_GRANULE_16MB is not set
 CONFIG_IA64_GRANULE_64MB=y
@@ -1102,6 +1141,7 @@
 #
 # Security options
 #
+# CONFIG_KEYS is not set
 # CONFIG_SECURITY is not set
 
 #
@@ -1115,7 +1155,7 @@
 # CONFIG_CRYPTO_SHA1 is not set
 # CONFIG_CRYPTO_SHA256 is not set
 # CONFIG_CRYPTO_SHA512 is not set
-# CONFIG_CRYPTO_WHIRLPOOL is not set
+# CONFIG_CRYPTO_WP512 is not set
 CONFIG_CRYPTO_DES=y
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set
@@ -1126,6 +1166,7 @@
 # CONFIG_CRYPTO_TEA is not set
 # CONFIG_CRYPTO_ARC4 is not set
 # CONFIG_CRYPTO_KHAZAD is not set
+# CONFIG_CRYPTO_ANUBIS is not set
 # CONFIG_CRYPTO_DEFLATE is not set
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_CRC32C is not set

--Boundary-00=_Sr4qBT98ZyOjoI6--

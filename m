From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 29 Dec 2004 15:55:30 +0000
Subject: [PATCH] Enable ForteMedia in zx1 defconfig
Message-Id: <20041229155530.GB8376@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The FM801 chip is built-in to the zx2000 workstation.  There's a lot
of noise in the patch because the defconfig hasn't been updated in a
few releases.

Index: linux/arch/ia64/configs/zx1_defconfig
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/configs/zx1_defconfig,v
retrieving revision 1.7
diff -u -p -r1.7 zx1_defconfig
--- linux/arch/ia64/configs/zx1_defconfig	30 Sep 2004 12:07:41 -0000	1.7
+++ linux/arch/ia64/configs/zx1_defconfig	29 Dec 2004 15:51:41 -0000
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.9-rc2-aegl
-# Mon Sep 27 19:03:13 2004
+# Linux kernel version: 2.6.10-pa1
+# Wed Dec 29 07:21:31 2004
 #
 
 #
@@ -11,6 +11,7 @@ CONFIG_EXPERIMENTAL=y
 # CONFIG_CLEAN_COMPILE is not set
 CONFIG_BROKEN=y
 CONFIG_BROKEN_ON_SMP=y
+CONFIG_LOCK_KERNEL=y
 
 #
 # General setup
@@ -25,6 +26,7 @@ CONFIG_SYSCTL=y
 # CONFIG_AUDIT is not set
 CONFIG_LOG_BUF_SHIFT
 CONFIG_HOTPLUG=y
+CONFIG_KOBJECT_UEVENT=y
 # CONFIG_IKCONFIG is not set
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
@@ -32,12 +34,12 @@ CONFIG_KALLSYMS=y
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
@@ -47,6 +49,7 @@ CONFIG_MODULES=y
 # CONFIG_MODULE_UNLOAD is not set
 CONFIG_OBSOLETE_MODPARM=y
 # CONFIG_MODVERSIONS is not set
+# CONFIG_MODULE_SRCVERSION_ALL is not set
 # CONFIG_KMOD is not set
 
 #
@@ -83,6 +86,7 @@ CONFIG_NR_CPUS
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
+# CONFIG_IA64_MCA_RECOVERY is not set
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
 
@@ -106,9 +110,11 @@ CONFIG_ACPI=y
 CONFIG_ACPI_BOOT=y
 CONFIG_ACPI_INTERPRETER=y
 CONFIG_ACPI_BUTTON=y
+CONFIG_ACPI_VIDEO=m
 CONFIG_ACPI_FAN=y
 CONFIG_ACPI_PROCESSOR=y
 CONFIG_ACPI_THERMAL=y
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_BUS=y
 CONFIG_ACPI_POWER=y
@@ -136,9 +142,14 @@ CONFIG_HOTPLUG_PCI_ACPI=y
 # CONFIG_HOTPLUG_PCI_SHPC is not set
 
 #
-# PCMCIA/CardBus support
+# PCCARD (PCMCIA/CardBus) support
 #
-# CONFIG_PCMCIA is not set
+# CONFIG_PCCARD is not set
+
+#
+# PC-card bridges
+#
+CONFIG_PCMCIA_PROBE_MEM=y
 
 #
 # Device Drivers
@@ -165,6 +176,7 @@ CONFIG_PREVENT_FIRMWARE_BUILD=y
 #
 # Plug and Play support
 #
+# CONFIG_PNP is not set
 
 #
 # Block devices
@@ -179,8 +191,19 @@ CONFIG_BLK_DEV_LOOP=y
 # CONFIG_BLK_DEV_SX8 is not set
 # CONFIG_BLK_DEV_UB is not set
 CONFIG_BLK_DEV_RAM=y
+CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
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
@@ -199,7 +222,6 @@ CONFIG_BLK_DEV_IDECD=y
 # CONFIG_BLK_DEV_IDEFLOPPY is not set
 # CONFIG_BLK_DEV_IDESCSI is not set
 # CONFIG_IDE_TASK_IOCTL is not set
-# CONFIG_IDE_TASKFILE_IO is not set
 
 #
 # IDE chipset support/bugfixes
@@ -303,6 +325,7 @@ CONFIG_SCSI_SYM53C8XX_MAX_TAGSd
 # CONFIG_SCSI_QLOGIC_ISP is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
+# CONFIG_SCSI_QLOGIC_1280_1040 is not set
 CONFIG_SCSI_QLA2XXX=y
 # CONFIG_SCSI_QLA21XX is not set
 # CONFIG_SCSI_QLA22XX is not set
@@ -362,6 +385,8 @@ CONFIG_IP_MULTICAST=y
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
+CONFIG_IP_TCPDIAG=y
+# CONFIG_IP_TCPDIAG_IPV6 is not set
 
 #
 # IP: Virtual Server Configuration
@@ -375,6 +400,7 @@ CONFIG_NETFILTER=y
 # IP: Netfilter Configuration
 #
 # CONFIG_IP_NF_CONNTRACK is not set
+# CONFIG_IP_NF_CONNTRACK_MARK is not set
 # CONFIG_IP_NF_QUEUE is not set
 # CONFIG_IP_NF_IPTABLES is not set
 CONFIG_IP_NF_ARPTABLES=y
@@ -399,7 +425,6 @@ CONFIG_IP_NF_ARPTABLES=y
 # CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
-# CONFIG_NET_HW_FLOWCONTROL is not set
 
 #
 # QoS and/or fair queueing
@@ -469,7 +494,6 @@ CONFIG_E100=y
 # CONFIG_EPIC100 is not set
 # CONFIG_SUNDANCE is not set
 # CONFIG_VIA_RHINE is not set
-# CONFIG_VIA_VELOCITY is not set
 
 #
 # Ethernet (1000 Mbit)
@@ -483,6 +507,7 @@ CONFIG_E1000=y
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
 # CONFIG_SK98LIN is not set
+# CONFIG_VIA_VELOCITY is not set
 CONFIG_TIGON3=y
 
 #
@@ -548,7 +573,6 @@ CONFIG_SOUND_GAMEPORT=y
 CONFIG_SERIO=y
 # CONFIG_SERIO_I8042 is not set
 # CONFIG_SERIO_SERPORT is not set
-# CONFIG_SERIO_CT82C710 is not set
 # CONFIG_SERIO_PCIPS2 is not set
 # CONFIG_SERIO_RAW is not set
 
@@ -653,6 +677,7 @@ CONFIG_I2C_ALGOPCF=y
 # CONFIG_I2C_SIS5595 is not set
 # CONFIG_I2C_SIS630 is not set
 # CONFIG_I2C_SIS96X is not set
+# CONFIG_I2C_STUB is not set
 # CONFIG_I2C_VIA is not set
 # CONFIG_I2C_VIAPRO is not set
 # CONFIG_I2C_VOODOO3 is not set
@@ -664,20 +689,24 @@ CONFIG_I2C_ALGOPCF=y
 # CONFIG_I2C_SENSOR is not set
 # CONFIG_SENSORS_ADM1021 is not set
 # CONFIG_SENSORS_ADM1025 is not set
+# CONFIG_SENSORS_ADM1026 is not set
 # CONFIG_SENSORS_ADM1031 is not set
 # CONFIG_SENSORS_ASB100 is not set
 # CONFIG_SENSORS_DS1621 is not set
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
@@ -708,7 +737,37 @@ CONFIG_I2C_ALGOPCF=y
 #
 # Multimedia devices
 #
-# CONFIG_VIDEO_DEV is not set
+CONFIG_VIDEO_DEV=y
+
+#
+# Video For Linux
+#
+
+#
+# Video Adapters
+#
+# CONFIG_VIDEO_BT848 is not set
+# CONFIG_VIDEO_CPIA is not set
+# CONFIG_VIDEO_SAA5246A is not set
+# CONFIG_VIDEO_SAA5249 is not set
+# CONFIG_TUNER_3036 is not set
+# CONFIG_VIDEO_STRADIS is not set
+# CONFIG_VIDEO_ZORAN is not set
+# CONFIG_VIDEO_ZR36120 is not set
+# CONFIG_VIDEO_SAA7134 is not set
+# CONFIG_VIDEO_MXB is not set
+# CONFIG_VIDEO_DPC is not set
+# CONFIG_VIDEO_HEXIUM_ORION is not set
+# CONFIG_VIDEO_HEXIUM_GEMINI is not set
+# CONFIG_VIDEO_CX88 is not set
+# CONFIG_VIDEO_OVCAMCHIP is not set
+
+#
+# Radio Adapters
+#
+# CONFIG_RADIO_GEMTEK_PCI is not set
+# CONFIG_RADIO_MAXIRADIO is not set
+# CONFIG_RADIO_MAESTRO is not set
 
 #
 # Digital Video Broadcasting Devices
@@ -720,6 +779,7 @@ CONFIG_I2C_ALGOPCF=y
 #
 CONFIG_FB=y
 CONFIG_FB_MODE_HELPERS=y
+# CONFIG_FB_TILEBLITTING is not set
 # CONFIG_FB_CIRRUS is not set
 # CONFIG_FB_PM2 is not set
 # CONFIG_FB_CYBER2000 is not set
@@ -733,6 +793,7 @@ CONFIG_FB_RADEON_I2C=y
 CONFIG_FB_RADEON_DEBUG=y
 # CONFIG_FB_ATY128 is not set
 # CONFIG_FB_ATY is not set
+# CONFIG_FB_SAVAGE is not set
 # CONFIG_FB_SIS is not set
 # CONFIG_FB_NEOMAGIC is not set
 # CONFIG_FB_KYRO is not set
@@ -763,7 +824,87 @@ CONFIG_LOGO_LINUX_CLUT224=y
 #
 # Sound
 #
-# CONFIG_SOUND is not set
+CONFIG_SOUND=y
+
+#
+# Advanced Linux Sound Architecture
+#
+CONFIG_SND=y
+CONFIG_SND_TIMER=y
+CONFIG_SND_PCM=y
+CONFIG_SND_HWDEP=y
+CONFIG_SND_RAWMIDI=y
+CONFIG_SND_SEQUENCER=y
+# CONFIG_SND_SEQ_DUMMY is not set
+CONFIG_SND_OSSEMUL=y
+CONFIG_SND_MIXER_OSS=y
+CONFIG_SND_PCM_OSS=y
+CONFIG_SND_SEQUENCER_OSS=y
+# CONFIG_SND_VERBOSE_PRINTK is not set
+# CONFIG_SND_DEBUG is not set
+
+#
+# Generic devices
+#
+CONFIG_SND_MPU401_UART=y
+CONFIG_SND_OPL3_LIB=y
+# CONFIG_SND_DUMMY is not set
+# CONFIG_SND_VIRMIDI is not set
+# CONFIG_SND_MTPAV is not set
+# CONFIG_SND_SERIAL_U16550 is not set
+# CONFIG_SND_MPU401 is not set
+
+#
+# PCI devices
+#
+CONFIG_SND_AC97_CODEC=y
+# CONFIG_SND_ALI5451 is not set
+# CONFIG_SND_ATIIXP is not set
+# CONFIG_SND_ATIIXP_MODEM is not set
+# CONFIG_SND_AU8810 is not set
+# CONFIG_SND_AU8820 is not set
+# CONFIG_SND_AU8830 is not set
+# CONFIG_SND_AZT3328 is not set
+# CONFIG_SND_BT87X is not set
+# CONFIG_SND_CS46XX is not set
+# CONFIG_SND_CS4281 is not set
+# CONFIG_SND_EMU10K1 is not set
+# CONFIG_SND_KORG1212 is not set
+# CONFIG_SND_MIXART is not set
+# CONFIG_SND_NM256 is not set
+# CONFIG_SND_RME32 is not set
+# CONFIG_SND_RME96 is not set
+# CONFIG_SND_RME9652 is not set
+# CONFIG_SND_HDSP is not set
+# CONFIG_SND_TRIDENT is not set
+# CONFIG_SND_YMFPCI is not set
+# CONFIG_SND_ALS4000 is not set
+# CONFIG_SND_CMIPCI is not set
+# CONFIG_SND_ENS1370 is not set
+# CONFIG_SND_ENS1371 is not set
+# CONFIG_SND_ES1938 is not set
+# CONFIG_SND_ES1968 is not set
+# CONFIG_SND_MAESTRO3 is not set
+CONFIG_SND_FM801=y
+CONFIG_SND_FM801_TEA575X=y
+# CONFIG_SND_ICE1712 is not set
+# CONFIG_SND_ICE1724 is not set
+# CONFIG_SND_INTEL8X0 is not set
+# CONFIG_SND_INTEL8X0M is not set
+# CONFIG_SND_SONICVIBES is not set
+# CONFIG_SND_VIA82XX is not set
+# CONFIG_SND_VX222 is not set
+
+#
+# USB devices
+#
+# CONFIG_SND_USB_AUDIO is not set
+# CONFIG_SND_USB_USX2Y is not set
+
+#
+# Open Sound System
+#
+# CONFIG_SOUND_PRIME is not set
 
 #
 # USB support
@@ -779,6 +920,8 @@ CONFIG_USB_BANDWIDTH=y
 # CONFIG_USB_DYNAMIC_MINORS is not set
 # CONFIG_USB_SUSPEND is not set
 # CONFIG_USB_OTG is not set
+CONFIG_USB_ARCH_HAS_HCD=y
+CONFIG_USB_ARCH_HAS_OHCI=y
 
 #
 # USB Host Controller Drivers
@@ -788,13 +931,20 @@ CONFIG_USB_EHCI_HCD=y
 # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
 CONFIG_USB_OHCI_HCD=y
 CONFIG_USB_UHCI_HCD=y
+# CONFIG_USB_SL811_HCD is not set
 
 #
 # USB Device Class drivers
 #
+# CONFIG_USB_AUDIO is not set
 # CONFIG_USB_BLUETOOTH_TTY is not set
+# CONFIG_USB_MIDI is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
+
+#
+# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be needed; see USB_STORAGE Help for more information
+#
 CONFIG_USB_STORAGE=y
 # CONFIG_USB_STORAGE_DEBUG is not set
 # CONFIG_USB_STORAGE_RW_DETECT is not set
@@ -808,7 +958,7 @@ CONFIG_USB_STORAGE=y
 # CONFIG_USB_STORAGE_JUMPSHOT is not set
 
 #
-# USB Human Interface Devices (HID)
+# USB Input Devices
 #
 CONFIG_USB_HID=y
 CONFIG_USB_HIDINPUT=y
@@ -834,13 +984,17 @@ CONFIG_USB_HIDDEV=y
 # USB Multimedia devices
 #
 # CONFIG_USB_DABUSB is not set
+# CONFIG_USB_VICAM is not set
+# CONFIG_USB_DSBR is not set
+# CONFIG_USB_IBMCAM is not set
+# CONFIG_USB_KONICAWC is not set
+# CONFIG_USB_OV511 is not set
+# CONFIG_USB_SE401 is not set
+# CONFIG_USB_SN9C102 is not set
+# CONFIG_USB_STV680 is not set
 
 #
-# Video4Linux support is needed for USB Multimedia device support
-#
-
-#
-# USB Network adaptors
+# USB Network Adapters
 #
 # CONFIG_USB_CATC is not set
 # CONFIG_USB_KAWETH is not set
@@ -869,14 +1023,24 @@ CONFIG_USB_HIDDEV=y
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
 
 #
+# MMC/SD Card support
+#
+# CONFIG_MMC is not set
+
+#
 # File systems
 #
 CONFIG_EXT2_FS=y
@@ -896,6 +1060,7 @@ CONFIG_FS_MBCACHE=y
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
 # CONFIG_QUOTA is not set
+CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=y
 # CONFIG_AUTOFS4_FS is not set
 
@@ -927,6 +1092,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
+# CONFIG_TMPFS_XATTR is not set
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
@@ -1053,9 +1219,11 @@ CONFIG_CRC32=y
 #
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
+# CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+# CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
@@ -1068,6 +1236,7 @@ CONFIG_SYSVIPC_COMPAT=y
 #
 # Security options
 #
+# CONFIG_KEYS is not set
 # CONFIG_SECURITY is not set
 
 #
@@ -1081,7 +1250,7 @@ CONFIG_CRYPTO_MD5=y
 # CONFIG_CRYPTO_SHA1 is not set
 # CONFIG_CRYPTO_SHA256 is not set
 # CONFIG_CRYPTO_SHA512 is not set
-# CONFIG_CRYPTO_WHIRLPOOL is not set
+# CONFIG_CRYPTO_WP512 is not set
 CONFIG_CRYPTO_DES=y
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set
@@ -1092,6 +1261,7 @@ CONFIG_CRYPTO_DES=y
 # CONFIG_CRYPTO_TEA is not set
 # CONFIG_CRYPTO_ARC4 is not set
 # CONFIG_CRYPTO_KHAZAD is not set
+# CONFIG_CRYPTO_ANUBIS is not set
 # CONFIG_CRYPTO_DEFLATE is not set
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_CRC32C is not set

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain

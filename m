From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 04 Aug 2004 17:24:01 +0000
Subject: [PATCH] update generic_defconfig
Message-Id: <200408041024.01791.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_xuREByZCbYj94NE"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_xuREByZCbYj94NE
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Alex's patch to fix the zx1 config reminded me that we're in need of a 
generic_defconfig update.  I just ran 'make oldconfig' against the existing 
one and turned on a few new options (some of which Altix needs).

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_xuREByZCbYj94NE
Content-Type: text/plain;
  charset="us-ascii";
  name="generic-defconfig-update-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="generic-defconfig-update-3.patch"

===== arch/ia64/configs/generic_defconfig 1.6 vs edited =====
--- 1.6/arch/ia64/configs/generic_defconfig	2004-03-31 14:27:06 -08:00
+++ edited/arch/ia64/configs/generic_defconfig	2004-08-04 10:13:47 -07:00
@@ -7,25 +7,30 @@
 #
 CONFIG_EXPERIMENTAL=y
 CONFIG_CLEAN_COMPILE=y
-CONFIG_STANDALONE=y
 
 #
 # General setup
 #
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
+CONFIG_POSIX_MQUEUE=y
 # CONFIG_BSD_PROCESS_ACCT is not set
 CONFIG_SYSCTL=y
+# CONFIG_AUDIT is not set
 CONFIG_LOG_BUF_SHIFT=20
+CONFIG_HOTPLUG=y
 CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
+CONFIG_KALLSYMS_ALL=y
+# CONFIG_KALLSYMS_EXTRA_PASS is not set
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_IOSCHED_NOOP=y
 CONFIG_IOSCHED_AS=y
 CONFIG_IOSCHED_DEADLINE=y
+CONFIG_IOSCHED_CFQ=y
 # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
 
 #
@@ -37,6 +42,7 @@
 CONFIG_OBSOLETE_MODPARM=y
 CONFIG_MODVERSIONS=y
 CONFIG_KMOD=y
+CONFIG_STOP_MACHINE=y
 
 #
 # Processor type and features
@@ -46,55 +52,54 @@
 CONFIG_MMU=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_TIME_INTERPOLATION=y
-# CONFIG_ITANIUM is not set
-CONFIG_MCKINLEY=y
+CONFIG_EFI=y
 CONFIG_IA64_GENERIC=y
 # CONFIG_IA64_DIG is not set
-# CONFIG_IA64_HP_SIM is not set
 # CONFIG_IA64_HP_ZX1 is not set
 # CONFIG_IA64_SGI_SN2 is not set
+# CONFIG_IA64_HP_SIM is not set
+# CONFIG_ITANIUM is not set
+CONFIG_MCKINLEY=y
 # CONFIG_IA64_PAGE_SIZE_4KB is not set
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
-CONFIG_ACPI=y
-CONFIG_ACPI_INTERPRETER=y
-CONFIG_ACPI_KERNEL_CONFIG=y
 CONFIG_IA64_L1_CACHE_SHIFT=7
-# CONFIG_MCKINLEY_ASTEP_SPECIFIC is not set
 CONFIG_NUMA=y
-CONFIG_DISCONTIGMEM=y
 CONFIG_VIRTUAL_MEM_MAP=y
-CONFIG_IA64_MCA=y
-CONFIG_PM=y
+CONFIG_DISCONTIGMEM=y
+CONFIG_IA64_CYCLONE=y
 CONFIG_IOSAPIC=y
 CONFIG_FORCE_MAX_ZONEORDER=18
-# CONFIG_HUGETLB_PAGE_SIZE_4GB is not set
-# CONFIG_HUGETLB_PAGE_SIZE_1GB is not set
-# CONFIG_HUGETLB_PAGE_SIZE_256MB is not set
-# CONFIG_HUGETLB_PAGE_SIZE_64MB is not set
-CONFIG_HUGETLB_PAGE_SIZE_16MB=y
-# CONFIG_HUGETLB_PAGE_SIZE_4MB is not set
-# CONFIG_HUGETLB_PAGE_SIZE_1MB is not set
-# CONFIG_HUGETLB_PAGE_SIZE_256KB is not set
-# CONFIG_IA64_PAL_IDLE is not set
 CONFIG_SMP=y
+CONFIG_NR_CPUS=512
+CONFIG_HOTPLUG_CPU=y
 # CONFIG_PREEMPT is not set
+CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
-CONFIG_HAVE_DEC_LOCK=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
-CONFIG_EFI=y
+
+#
+# Firmware Drivers
+#
 CONFIG_EFI_VARS=y
-CONFIG_NR_CPUS=512
+CONFIG_EFI_PCDP=y
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=m
 
 #
+# Power management and ACPI
+#
+CONFIG_PM=y
+CONFIG_ACPI=y
+
+#
 # ACPI (Advanced Configuration and Power Interface) Support
 #
 CONFIG_ACPI_BOOT=y
+CONFIG_ACPI_INTERPRETER=y
 CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
@@ -105,11 +110,15 @@
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_PCI=y
 CONFIG_ACPI_SYSTEM=y
+
+#
+# Bus options (PCI, PCMCIA)
+#
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
+# CONFIG_PCI_MSI is not set
 CONFIG_PCI_LEGACY_PROC=y
 CONFIG_PCI_NAMES=y
-CONFIG_HOTPLUG=y
 
 #
 # PCI Hotplug Support
@@ -118,6 +127,8 @@
 # CONFIG_HOTPLUG_PCI_FAKE is not set
 CONFIG_HOTPLUG_PCI_ACPI=m
 # CONFIG_HOTPLUG_PCI_CPCI is not set
+# CONFIG_HOTPLUG_PCI_PCIE is not set
+# CONFIG_HOTPLUG_PCI_SHPC is not set
 
 #
 # PCMCIA/CardBus support
@@ -125,14 +136,16 @@
 # CONFIG_PCMCIA is not set
 
 #
-# Parallel port support
+# Device Drivers
 #
-# CONFIG_PARPORT is not set
 
 #
 # Generic Driver Options
 #
+CONFIG_STANDALONE=y
+CONFIG_PREVENT_FIRMWARE_BUILD=y
 # CONFIG_FW_LOADER is not set
+# CONFIG_DEBUG_DRIVER is not set
 
 #
 # Memory Technology Devices (MTD)
@@ -140,14 +153,17 @@
 # CONFIG_MTD is not set
 
 #
+# Parallel port support
+#
+# CONFIG_PARPORT is not set
+
+#
 # Plug and Play support
 #
-# CONFIG_PNP is not set
 
 #
 # Block devices
 #
-# CONFIG_BLK_DEV_FD is not set
 # CONFIG_BLK_CPQ_DA is not set
 # CONFIG_BLK_CPQ_CISS_DA is not set
 # CONFIG_BLK_DEV_DAC960 is not set
@@ -155,9 +171,9 @@
 CONFIG_BLK_DEV_LOOP=m
 CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
+# CONFIG_BLK_DEV_SX8 is not set
 CONFIG_BLK_DEV_RAM=m
 CONFIG_BLK_DEV_RAM_SIZE=4096
-# CONFIG_BLK_DEV_INITRD is not set
 
 #
 # ATA/ATAPI/MFM/RLL support
@@ -168,9 +184,9 @@
 #
 # Please see Documentation/ide.txt for help/info on IDE drives
 #
+# CONFIG_BLK_DEV_IDE_SATA is not set
 CONFIG_BLK_DEV_IDEDISK=y
 # CONFIG_IDEDISK_MULTI_MODE is not set
-# CONFIG_IDEDISK_STROKE is not set
 CONFIG_BLK_DEV_IDECD=y
 # CONFIG_BLK_DEV_IDETAPE is not set
 CONFIG_BLK_DEV_IDEFLOPPY=y
@@ -181,6 +197,7 @@
 #
 # IDE chipset support/bugfixes
 #
+CONFIG_IDE_GENERIC=y
 CONFIG_BLK_DEV_IDEPCI=y
 # CONFIG_IDEPCI_SHARE_IRQ is not set
 # CONFIG_BLK_DEV_OFFBOARD is not set
@@ -207,47 +224,18 @@
 # CONFIG_BLK_DEV_PDC202XX_OLD is not set
 # CONFIG_BLK_DEV_PDC202XX_NEW is not set
 # CONFIG_BLK_DEV_SVWKS is not set
+CONFIG_BLK_DEV_SGIIOC4=y
 # CONFIG_BLK_DEV_SIIMAGE is not set
 # CONFIG_BLK_DEV_SLC90E66 is not set
 # CONFIG_BLK_DEV_TRM290 is not set
 # CONFIG_BLK_DEV_VIA82CXXX is not set
+# CONFIG_IDE_ARM is not set
 CONFIG_BLK_DEV_IDEDMA=y
 # CONFIG_IDEDMA_IVB is not set
 CONFIG_IDEDMA_AUTO=y
 # CONFIG_BLK_DEV_HD is not set
 
 #
-# IEEE 1394 (FireWire) support (EXPERIMENTAL)
-#
-# CONFIG_IEEE1394 is not set
-
-#
-# I2O device support
-#
-# CONFIG_I2O is not set
-
-#
-# Multi-device support (RAID and LVM)
-#
-CONFIG_MD=y
-CONFIG_BLK_DEV_MD=m
-CONFIG_MD_LINEAR=m
-CONFIG_MD_RAID0=m
-CONFIG_MD_RAID1=m
-CONFIG_MD_RAID5=m
-CONFIG_MD_MULTIPATH=m
-CONFIG_BLK_DEV_DM=m
-
-#
-# Fusion MPT device support
-#
-CONFIG_FUSION=y
-CONFIG_FUSION_BOOT=y
-CONFIG_FUSION_MAX_SGE=40
-# CONFIG_FUSION_ISENSE is not set
-# CONFIG_FUSION_CTL is not set
-
-#
 # SCSI device support
 #
 CONFIG_SCSI=y
@@ -267,24 +255,28 @@
 # Some SCSI devices (e.g. CD jukebox) support multiple LUNs
 #
 # CONFIG_SCSI_MULTI_LUN is not set
-CONFIG_SCSI_REPORT_LUNS=y
 # CONFIG_SCSI_CONSTANTS is not set
 # CONFIG_SCSI_LOGGING is not set
 
 #
+# SCSI Transport Attributes
+#
+CONFIG_SCSI_SPI_ATTRS=y
+CONFIG_SCSI_FC_ATTRS=y
+
+#
 # SCSI low-level drivers
 #
 # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
+# CONFIG_SCSI_3W_9XXX is not set
 # CONFIG_SCSI_ACARD is not set
 # CONFIG_SCSI_AACRAID is not set
 # CONFIG_SCSI_AIC7XXX is not set
 # CONFIG_SCSI_AIC7XXX_OLD is not set
 # CONFIG_SCSI_AIC79XX is not set
-# CONFIG_SCSI_ADVANSYS is not set
 # CONFIG_SCSI_MEGARAID is not set
 # CONFIG_SCSI_SATA is not set
 # CONFIG_SCSI_BUSLOGIC is not set
-# CONFIG_SCSI_CPQFCTS is not set
 # CONFIG_SCSI_DMX3191D is not set
 # CONFIG_SCSI_EATA is not set
 # CONFIG_SCSI_EATA_PIO is not set
@@ -297,16 +289,58 @@
 CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
 CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
 # CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set
+# CONFIG_SCSI_IPR is not set
 # CONFIG_SCSI_QLOGIC_ISP is not set
 CONFIG_SCSI_QLOGIC_FC=y
 # CONFIG_SCSI_QLOGIC_FC_FIRMWARE is not set
 CONFIG_SCSI_QLOGIC_1280=y
+CONFIG_SCSI_QLA2XXX=y
+CONFIG_SCSI_QLA21XX=m
+CONFIG_SCSI_QLA22XX=m
+CONFIG_SCSI_QLA2300=m
+CONFIG_SCSI_QLA2322=m
+# CONFIG_SCSI_QLA6312 is not set
+# CONFIG_SCSI_QLA6322 is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
-# CONFIG_SCSI_NSP32 is not set
 # CONFIG_SCSI_DEBUG is not set
 
 #
+# Multi-device support (RAID and LVM)
+#
+CONFIG_MD=y
+CONFIG_BLK_DEV_MD=m
+CONFIG_MD_LINEAR=m
+CONFIG_MD_RAID0=m
+CONFIG_MD_RAID1=m
+CONFIG_MD_RAID5=m
+CONFIG_MD_RAID6=m
+CONFIG_MD_MULTIPATH=m
+CONFIG_BLK_DEV_DM=m
+CONFIG_DM_CRYPT=m
+CONFIG_DM_SNAPSHOT=m
+CONFIG_DM_MIRROR=m
+CONFIG_DM_ZERO=m
+
+#
+# Fusion MPT device support
+#
+CONFIG_FUSION=y
+CONFIG_FUSION_MAX_SGE=40
+# CONFIG_FUSION_ISENSE is not set
+# CONFIG_FUSION_CTL is not set
+
+#
+# IEEE 1394 (FireWire) support
+#
+# CONFIG_IEEE1394 is not set
+
+#
+# I2O device support
+#
+# CONFIG_I2O is not set
+
+#
 # Networking support
 #
 CONFIG_NET=y
@@ -327,23 +361,21 @@
 # CONFIG_NET_IPGRE is not set
 # CONFIG_IP_MROUTE is not set
 CONFIG_ARPD=y
-# CONFIG_INET_ECN is not set
 CONFIG_SYN_COOKIES=y
 # CONFIG_INET_AH is not set
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_IPV6 is not set
-# CONFIG_DECNET is not set
-# CONFIG_BRIDGE is not set
 # CONFIG_NETFILTER is not set
 
 #
 # SCTP Configuration (EXPERIMENTAL)
 #
-CONFIG_IPV6_SCTP__=y
 # CONFIG_IP_SCTP is not set
 # CONFIG_ATM is not set
+# CONFIG_BRIDGE is not set
 # CONFIG_VLAN_8021Q is not set
+# CONFIG_DECNET is not set
 # CONFIG_LLC2 is not set
 # CONFIG_IPX is not set
 # CONFIG_ATALK is not set
@@ -359,17 +391,20 @@
 # QoS and/or fair queueing
 #
 # CONFIG_NET_SCHED is not set
+# CONFIG_NET_CLS_ROUTE is not set
 
 #
 # Network testing
 #
 # CONFIG_NET_PKTGEN is not set
+CONFIG_NETPOLL=y
+# CONFIG_NETPOLL_RX is not set
+# CONFIG_NETPOLL_TRAP is not set
+CONFIG_NET_POLL_CONTROLLER=y
+# CONFIG_HAMRADIO is not set
+# CONFIG_IRDA is not set
+# CONFIG_BT is not set
 CONFIG_NETDEVICES=y
-
-#
-# ARCnet devices
-#
-# CONFIG_ARCNET is not set
 CONFIG_DUMMY=m
 # CONFIG_BONDING is not set
 # CONFIG_EQUALIZER is not set
@@ -377,6 +412,11 @@
 # CONFIG_ETHERTAP is not set
 
 #
+# ARCnet devices
+#
+# CONFIG_ARCNET is not set
+
+#
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=y
@@ -393,6 +433,7 @@
 CONFIG_TULIP=m
 # CONFIG_TULIP_MWI is not set
 # CONFIG_TULIP_MMIO is not set
+# CONFIG_TULIP_NAPI is not set
 # CONFIG_DE4X5 is not set
 # CONFIG_WINBOND_840 is not set
 # CONFIG_DM9102 is not set
@@ -402,10 +443,12 @@
 # CONFIG_AMD8111_ETH is not set
 # CONFIG_ADAPTEC_STARFIRE is not set
 # CONFIG_B44 is not set
+# CONFIG_FORCEDETH is not set
 # CONFIG_DGRS is not set
 CONFIG_EEPRO100=m
 # CONFIG_EEPRO100_PIO is not set
 CONFIG_E100=m
+# CONFIG_E100_NAPI is not set
 # CONFIG_FEALNX is not set
 # CONFIG_NATSEMI is not set
 # CONFIG_NE2K_PCI is not set
@@ -415,6 +458,7 @@
 # CONFIG_EPIC100 is not set
 # CONFIG_SUNDANCE is not set
 # CONFIG_VIA_RHINE is not set
+# CONFIG_VIA_VELOCITY is not set
 
 #
 # Ethernet (1000 Mbit)
@@ -427,7 +471,6 @@
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
-# CONFIG_SIS190 is not set
 # CONFIG_SK98LIN is not set
 CONFIG_TIGON3=y
 
@@ -435,47 +478,39 @@
 # Ethernet (10000 Mbit)
 #
 # CONFIG_IXGB is not set
-# CONFIG_FDDI is not set
-# CONFIG_HIPPI is not set
-# CONFIG_PPP is not set
-# CONFIG_SLIP is not set
-
-#
-# Wireless LAN (non-hamradio)
-#
-# CONFIG_NET_RADIO is not set
+# CONFIG_S2IO is not set
 
 #
 # Token Ring devices
 #
 # CONFIG_TR is not set
-# CONFIG_NET_FC is not set
-# CONFIG_SHAPER is not set
-
-#
-# Wan interfaces
-#
-# CONFIG_WAN is not set
 
 #
-# Amateur Radio support
+# Wireless LAN (non-hamradio)
 #
-# CONFIG_HAMRADIO is not set
+# CONFIG_NET_RADIO is not set
 
 #
-# IrDA (infrared) support
+# Wan interfaces
 #
-# CONFIG_IRDA is not set
+# CONFIG_WAN is not set
+# CONFIG_FDDI is not set
+# CONFIG_HIPPI is not set
+# CONFIG_PPP is not set
+# CONFIG_SLIP is not set
+# CONFIG_NET_FC is not set
+# CONFIG_SHAPER is not set
+CONFIG_NETCONSOLE=y
 
 #
-# Bluetooth support
+# ISDN subsystem
 #
-# CONFIG_BT is not set
+# CONFIG_ISDN is not set
 
 #
-# ISDN subsystem
+# Telephony Support
 #
-# CONFIG_ISDN_BOOL is not set
+# CONFIG_PHONE is not set
 
 #
 # Input device support
@@ -517,11 +552,13 @@
 CONFIG_INPUT_KEYBOARD=y
 CONFIG_KEYBOARD_ATKBD=y
 # CONFIG_KEYBOARD_SUNKBD is not set
+# CONFIG_KEYBOARD_LKKBD is not set
 # CONFIG_KEYBOARD_XTKBD is not set
 # CONFIG_KEYBOARD_NEWTON is not set
 CONFIG_INPUT_MOUSE=y
 CONFIG_MOUSE_PS2=y
 # CONFIG_MOUSE_SERIAL is not set
+# CONFIG_MOUSE_VSXXXAA is not set
 # CONFIG_INPUT_JOYSTICK is not set
 # CONFIG_INPUT_TOUCHSCREEN is not set
 # CONFIG_INPUT_MISC is not set
@@ -534,12 +571,11 @@
 CONFIG_HW_CONSOLE=y
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
+# CONFIG_CYCLADES is not set
 # CONFIG_SYNCLINK is not set
 # CONFIG_SYNCLINKMP is not set
 # CONFIG_N_HDLC is not set
 # CONFIG_STALDRV is not set
-CONFIG_SGI_L1_SERIAL=y
-CONFIG_SGI_L1_SERIAL_CONSOLE=y
 
 #
 # Serial drivers
@@ -547,7 +583,6 @@
 CONFIG_SERIAL_8250=y
 CONFIG_SERIAL_8250_CONSOLE=y
 CONFIG_SERIAL_8250_ACPI=y
-CONFIG_SERIAL_8250_HCDP=y
 CONFIG_SERIAL_8250_NR_UARTS=6
 CONFIG_SERIAL_8250_EXTENDED=y
 CONFIG_SERIAL_8250_SHARE_IRQ=y
@@ -560,31 +595,10 @@
 #
 CONFIG_SERIAL_CORE=y
 CONFIG_SERIAL_CORE_CONSOLE=y
+CONFIG_SERIAL_SGI_L1_CONSOLE=y
 CONFIG_UNIX98_PTYS=y
-CONFIG_UNIX98_PTY_COUNT=256
-
-#
-# I2C support
-#
-# CONFIG_I2C is not set
-
-#
-# I2C Algorithms
-#
-
-#
-# I2C Hardware Bus support
-#
-
-#
-# I2C Hardware Sensors Chip support
-#
-# CONFIG_I2C_SENSOR is not set
-
-#
-# Mice
-#
-# CONFIG_BUSMOUSE is not set
+CONFIG_LEGACY_PTYS=y
+CONFIG_LEGACY_PTY_COUNT=256
 # CONFIG_QIC02_TAPE is not set
 
 #
@@ -597,8 +611,6 @@
 #
 # CONFIG_WATCHDOG is not set
 # CONFIG_HW_RANDOM is not set
-# CONFIG_NVRAM is not set
-# CONFIG_GEN_RTC is not set
 CONFIG_EFI_RTC=y
 # CONFIG_DTLK is not set
 # CONFIG_R3964 is not set
@@ -618,182 +630,34 @@
 CONFIG_DRM_MGA=m
 CONFIG_DRM_SIS=m
 CONFIG_RAW_DRIVER=m
+CONFIG_HPET=y
+# CONFIG_HPET_RTC_IRQ is not set
+CONFIG_HPET_MMAP=y
 CONFIG_MAX_RAW_DEVS=256
 
 #
-# Multimedia devices
-#
-# CONFIG_VIDEO_DEV is not set
-
-#
-# Digital Video Broadcasting Devices
-#
-# CONFIG_DVB is not set
-
-#
-# File systems
-#
-CONFIG_EXT2_FS=y
-CONFIG_EXT2_FS_XATTR=y
-CONFIG_EXT2_FS_POSIX_ACL=y
-CONFIG_EXT2_FS_SECURITY=y
-CONFIG_EXT3_FS=y
-CONFIG_EXT3_FS_XATTR=y
-CONFIG_EXT3_FS_POSIX_ACL=y
-CONFIG_EXT3_FS_SECURITY=y
-CONFIG_JBD=y
-# CONFIG_JBD_DEBUG is not set
-CONFIG_FS_MBCACHE=y
-CONFIG_REISERFS_FS=m
-# CONFIG_REISERFS_CHECK is not set
-# CONFIG_REISERFS_PROC_INFO is not set
-# CONFIG_JFS_FS is not set
-CONFIG_FS_POSIX_ACL=y
-CONFIG_XFS_FS=y
-# CONFIG_XFS_RT is not set
-# CONFIG_XFS_QUOTA is not set
-# CONFIG_XFS_POSIX_ACL is not set
-# CONFIG_MINIX_FS is not set
-# CONFIG_ROMFS_FS is not set
-# CONFIG_QUOTA is not set
-CONFIG_AUTOFS_FS=y
-CONFIG_AUTOFS4_FS=y
-
-#
-# CD-ROM/DVD Filesystems
-#
-CONFIG_ISO9660_FS=m
-CONFIG_JOLIET=y
-# CONFIG_ZISOFS is not set
-CONFIG_UDF_FS=m
-
-#
-# DOS/FAT/NT Filesystems
-#
-CONFIG_FAT_FS=y
-# CONFIG_MSDOS_FS is not set
-CONFIG_VFAT_FS=y
-CONFIG_NTFS_FS=m
-# CONFIG_NTFS_DEBUG is not set
-# CONFIG_NTFS_RW is not set
-
-#
-# Pseudo filesystems
+# I2C support
 #
-CONFIG_PROC_FS=y
-CONFIG_PROC_KCORE=y
-# CONFIG_DEVFS_FS is not set
-CONFIG_DEVPTS_FS=y
-# CONFIG_DEVPTS_FS_XATTR is not set
-CONFIG_TMPFS=y
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
-CONFIG_RAMFS=y
+# CONFIG_I2C is not set
 
 #
-# Miscellaneous filesystems
+# Dallas's 1-wire bus
 #
-# CONFIG_ADFS_FS is not set
-# CONFIG_AFFS_FS is not set
-# CONFIG_HFS_FS is not set
-# CONFIG_BEFS_FS is not set
-# CONFIG_BFS_FS is not set
-# CONFIG_EFS_FS is not set
-# CONFIG_CRAMFS is not set
-# CONFIG_VXFS_FS is not set
-# CONFIG_HPFS_FS is not set
-# CONFIG_QNX4FS_FS is not set
-# CONFIG_SYSV_FS is not set
-# CONFIG_UFS_FS is not set
+# CONFIG_W1 is not set
 
 #
-# Network File Systems
+# Misc devices
 #
-CONFIG_NFS_FS=m
-CONFIG_NFS_V3=y
-CONFIG_NFS_V4=y
-CONFIG_NFS_DIRECTIO=y
-CONFIG_NFSD=m
-CONFIG_NFSD_V3=y
-CONFIG_NFSD_V4=y
-CONFIG_NFSD_TCP=y
-CONFIG_LOCKD=m
-CONFIG_LOCKD_V4=y
-CONFIG_EXPORTFS=m
-CONFIG_SUNRPC=m
-# CONFIG_SUNRPC_GSS is not set
-CONFIG_SMB_FS=m
-CONFIG_SMB_NLS_DEFAULT=y
-CONFIG_SMB_NLS_REMOTE="cp437"
-CONFIG_CIFS=m
-# CONFIG_NCP_FS is not set
-# CONFIG_CODA_FS is not set
-# CONFIG_INTERMEZZO_FS is not set
-# CONFIG_AFS_FS is not set
 
 #
-# Partition Types
+# Multimedia devices
 #
-CONFIG_PARTITION_ADVANCED=y
-# CONFIG_ACORN_PARTITION is not set
-# CONFIG_OSF_PARTITION is not set
-# CONFIG_AMIGA_PARTITION is not set
-# CONFIG_ATARI_PARTITION is not set
-# CONFIG_MAC_PARTITION is not set
-CONFIG_MSDOS_PARTITION=y
-# CONFIG_BSD_DISKLABEL is not set
-# CONFIG_MINIX_SUBPARTITION is not set
-# CONFIG_SOLARIS_X86_PARTITION is not set
-# CONFIG_UNIXWARE_DISKLABEL is not set
-# CONFIG_LDM_PARTITION is not set
-# CONFIG_NEC98_PARTITION is not set
-CONFIG_SGI_PARTITION=y
-# CONFIG_ULTRIX_PARTITION is not set
-# CONFIG_SUN_PARTITION is not set
-CONFIG_EFI_PARTITION=y
+# CONFIG_VIDEO_DEV is not set
 
 #
-# Native Language Support
+# Digital Video Broadcasting Devices
 #
-CONFIG_NLS=y
-CONFIG_NLS_DEFAULT="iso8859-1"
-CONFIG_NLS_CODEPAGE_437=m
-CONFIG_NLS_CODEPAGE_737=m
-CONFIG_NLS_CODEPAGE_775=m
-CONFIG_NLS_CODEPAGE_850=m
-CONFIG_NLS_CODEPAGE_852=m
-CONFIG_NLS_CODEPAGE_855=m
-CONFIG_NLS_CODEPAGE_857=m
-CONFIG_NLS_CODEPAGE_860=m
-CONFIG_NLS_CODEPAGE_861=m
-CONFIG_NLS_CODEPAGE_862=m
-CONFIG_NLS_CODEPAGE_863=m
-CONFIG_NLS_CODEPAGE_864=m
-CONFIG_NLS_CODEPAGE_865=m
-CONFIG_NLS_CODEPAGE_866=m
-CONFIG_NLS_CODEPAGE_869=m
-CONFIG_NLS_CODEPAGE_936=m
-CONFIG_NLS_CODEPAGE_950=m
-CONFIG_NLS_CODEPAGE_932=m
-CONFIG_NLS_CODEPAGE_949=m
-CONFIG_NLS_CODEPAGE_874=m
-CONFIG_NLS_ISO8859_8=m
-CONFIG_NLS_CODEPAGE_1250=m
-CONFIG_NLS_CODEPAGE_1251=m
-CONFIG_NLS_ISO8859_1=m
-CONFIG_NLS_ISO8859_2=m
-CONFIG_NLS_ISO8859_3=m
-CONFIG_NLS_ISO8859_4=m
-CONFIG_NLS_ISO8859_5=m
-CONFIG_NLS_ISO8859_6=m
-CONFIG_NLS_ISO8859_7=m
-CONFIG_NLS_ISO8859_9=m
-CONFIG_NLS_ISO8859_13=m
-CONFIG_NLS_ISO8859_14=m
-CONFIG_NLS_ISO8859_15=m
-CONFIG_NLS_KOI8_R=m
-CONFIG_NLS_KOI8_U=m
-CONFIG_NLS_UTF8=m
+# CONFIG_DVB is not set
 
 #
 # Graphics support
@@ -816,6 +680,10 @@
 # Advanced Linux Sound Architecture
 #
 CONFIG_SND=m
+CONFIG_SND_TIMER=m
+CONFIG_SND_PCM=m
+CONFIG_SND_HWDEP=m
+CONFIG_SND_RAWMIDI=m
 CONFIG_SND_SEQUENCER=m
 CONFIG_SND_SEQ_DUMMY=m
 CONFIG_SND_OSSEMUL=y
@@ -828,6 +696,8 @@
 #
 # Generic devices
 #
+CONFIG_SND_MPU401_UART=m
+CONFIG_SND_OPL3_LIB=m
 CONFIG_SND_DUMMY=m
 CONFIG_SND_VIRMIDI=m
 CONFIG_SND_MTPAV=m
@@ -837,13 +707,20 @@
 #
 # PCI devices
 #
+CONFIG_SND_AC97_CODEC=m
 # CONFIG_SND_ALI5451 is not set
+# CONFIG_SND_ATIIXP is not set
+# CONFIG_SND_AU8810 is not set
+# CONFIG_SND_AU8820 is not set
+# CONFIG_SND_AU8830 is not set
 # CONFIG_SND_AZT3328 is not set
+# CONFIG_SND_BT87X is not set
 CONFIG_SND_CS46XX=m
 CONFIG_SND_CS46XX_NEW_DSP=y
 CONFIG_SND_CS4281=m
 CONFIG_SND_EMU10K1=m
 # CONFIG_SND_KORG1212 is not set
+# CONFIG_SND_MIXART is not set
 # CONFIG_SND_NM256 is not set
 # CONFIG_SND_RME32 is not set
 # CONFIG_SND_RME96 is not set
@@ -859,9 +736,11 @@
 # CONFIG_SND_ES1968 is not set
 # CONFIG_SND_MAESTRO3 is not set
 CONFIG_SND_FM801=m
+# CONFIG_SND_FM801_TEA575X is not set
 # CONFIG_SND_ICE1712 is not set
 # CONFIG_SND_ICE1724 is not set
 # CONFIG_SND_INTEL8X0 is not set
+# CONFIG_SND_INTEL8X0M is not set
 # CONFIG_SND_SONICVIBES is not set
 # CONFIG_SND_VIA82XX is not set
 # CONFIG_SND_VX222 is not set
@@ -893,6 +772,8 @@
 # USB Host Controller Drivers
 #
 CONFIG_USB_EHCI_HCD=m
+# CONFIG_USB_EHCI_SPLIT_ISO is not set
+# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
 CONFIG_USB_OHCI_HCD=m
 CONFIG_USB_UHCI_HCD=m
 
@@ -906,6 +787,7 @@
 # CONFIG_USB_PRINTER is not set
 CONFIG_USB_STORAGE=m
 # CONFIG_USB_STORAGE_DEBUG is not set
+# CONFIG_USB_STORAGE_RW_DETECT is not set
 # CONFIG_USB_STORAGE_DATAFAB is not set
 # CONFIG_USB_STORAGE_FREECOM is not set
 # CONFIG_USB_STORAGE_ISD200 is not set
@@ -932,13 +814,15 @@
 # CONFIG_USB_WACOM is not set
 # CONFIG_USB_KBTAB is not set
 # CONFIG_USB_POWERMATE is not set
+# CONFIG_USB_MTOUCH is not set
+# CONFIG_USB_EGALAX is not set
 # CONFIG_USB_XPAD is not set
+# CONFIG_USB_ATI_REMOTE is not set
 
 #
 # USB Imaging devices
 #
 # CONFIG_USB_MDC800 is not set
-# CONFIG_USB_SCANNER is not set
 # CONFIG_USB_MICROTEK is not set
 # CONFIG_USB_HPUSBSCSI is not set
 
@@ -972,18 +856,202 @@
 #
 # USB Miscellaneous drivers
 #
+# CONFIG_USB_EMI62 is not set
+# CONFIG_USB_EMI26 is not set
 # CONFIG_USB_TIGL is not set
 # CONFIG_USB_AUERSWALD is not set
 # CONFIG_USB_RIO500 is not set
 # CONFIG_USB_LEGOTOWER is not set
 # CONFIG_USB_LCD is not set
+# CONFIG_USB_LED is not set
+# CONFIG_USB_CYTHERM is not set
+# CONFIG_USB_PHIDGETSERVO is not set
 # CONFIG_USB_TEST is not set
+
+#
+# USB Gadget Support
+#
 # CONFIG_USB_GADGET is not set
 
 #
+# File systems
+#
+CONFIG_EXT2_FS=y
+CONFIG_EXT2_FS_XATTR=y
+CONFIG_EXT2_FS_POSIX_ACL=y
+CONFIG_EXT2_FS_SECURITY=y
+CONFIG_EXT3_FS=y
+CONFIG_EXT3_FS_XATTR=y
+CONFIG_EXT3_FS_POSIX_ACL=y
+CONFIG_EXT3_FS_SECURITY=y
+CONFIG_JBD=y
+# CONFIG_JBD_DEBUG is not set
+CONFIG_FS_MBCACHE=y
+CONFIG_REISERFS_FS=m
+# CONFIG_REISERFS_CHECK is not set
+# CONFIG_REISERFS_PROC_INFO is not set
+# CONFIG_REISERFS_FS_XATTR is not set
+# CONFIG_JFS_FS is not set
+CONFIG_FS_POSIX_ACL=y
+CONFIG_XFS_FS=y
+# CONFIG_XFS_RT is not set
+# CONFIG_XFS_QUOTA is not set
+# CONFIG_XFS_SECURITY is not set
+# CONFIG_XFS_POSIX_ACL is not set
+# CONFIG_MINIX_FS is not set
+# CONFIG_ROMFS_FS is not set
+# CONFIG_QUOTA is not set
+CONFIG_AUTOFS_FS=y
+CONFIG_AUTOFS4_FS=y
+
+#
+# CD-ROM/DVD Filesystems
+#
+CONFIG_ISO9660_FS=m
+CONFIG_JOLIET=y
+# CONFIG_ZISOFS is not set
+CONFIG_UDF_FS=m
+CONFIG_UDF_NLS=y
+
+#
+# DOS/FAT/NT Filesystems
+#
+CONFIG_FAT_FS=y
+# CONFIG_MSDOS_FS is not set
+CONFIG_VFAT_FS=y
+CONFIG_NTFS_FS=m
+# CONFIG_NTFS_DEBUG is not set
+# CONFIG_NTFS_RW is not set
+
+#
+# Pseudo filesystems
+#
+CONFIG_PROC_FS=y
+CONFIG_PROC_KCORE=y
+CONFIG_SYSFS=y
+# CONFIG_DEVFS_FS is not set
+# CONFIG_DEVPTS_FS_XATTR is not set
+CONFIG_TMPFS=y
+CONFIG_HUGETLBFS=y
+CONFIG_HUGETLB_PAGE=y
+CONFIG_RAMFS=y
+
+#
+# Miscellaneous filesystems
+#
+# CONFIG_ADFS_FS is not set
+# CONFIG_AFFS_FS is not set
+# CONFIG_HFS_FS is not set
+# CONFIG_HFSPLUS_FS is not set
+# CONFIG_BEFS_FS is not set
+# CONFIG_BFS_FS is not set
+# CONFIG_EFS_FS is not set
+# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
+# CONFIG_CRAMFS is not set
+# CONFIG_VXFS_FS is not set
+# CONFIG_HPFS_FS is not set
+# CONFIG_QNX4FS_FS is not set
+# CONFIG_SYSV_FS is not set
+# CONFIG_UFS_FS is not set
+
+#
+# Network File Systems
+#
+CONFIG_NFS_FS=m
+CONFIG_NFS_V3=y
+CONFIG_NFS_V4=y
+CONFIG_NFS_DIRECTIO=y
+CONFIG_NFSD=m
+CONFIG_NFSD_V3=y
+CONFIG_NFSD_V4=y
+CONFIG_NFSD_TCP=y
+CONFIG_LOCKD=m
+CONFIG_LOCKD_V4=y
+CONFIG_EXPORTFS=m
+CONFIG_SUNRPC=m
+CONFIG_SUNRPC_GSS=m
+CONFIG_RPCSEC_GSS_KRB5=m
+CONFIG_SMB_FS=m
+CONFIG_SMB_NLS_DEFAULT=y
+CONFIG_SMB_NLS_REMOTE="cp437"
+CONFIG_CIFS=m
+# CONFIG_CIFS_STATS is not set
+# CONFIG_CIFS_XATTR is not set
+# CONFIG_CIFS_POSIX is not set
+# CONFIG_NCP_FS is not set
+# CONFIG_CODA_FS is not set
+# CONFIG_AFS_FS is not set
+
+#
+# Partition Types
+#
+CONFIG_PARTITION_ADVANCED=y
+# CONFIG_ACORN_PARTITION is not set
+# CONFIG_OSF_PARTITION is not set
+# CONFIG_AMIGA_PARTITION is not set
+# CONFIG_ATARI_PARTITION is not set
+# CONFIG_MAC_PARTITION is not set
+CONFIG_MSDOS_PARTITION=y
+# CONFIG_BSD_DISKLABEL is not set
+# CONFIG_MINIX_SUBPARTITION is not set
+# CONFIG_SOLARIS_X86_PARTITION is not set
+# CONFIG_UNIXWARE_DISKLABEL is not set
+# CONFIG_LDM_PARTITION is not set
+CONFIG_SGI_PARTITION=y
+# CONFIG_ULTRIX_PARTITION is not set
+# CONFIG_SUN_PARTITION is not set
+CONFIG_EFI_PARTITION=y
+
+#
+# Native Language Support
+#
+CONFIG_NLS=y
+CONFIG_NLS_DEFAULT="iso8859-1"
+CONFIG_NLS_CODEPAGE_437=m
+CONFIG_NLS_CODEPAGE_737=m
+CONFIG_NLS_CODEPAGE_775=m
+CONFIG_NLS_CODEPAGE_850=m
+CONFIG_NLS_CODEPAGE_852=m
+CONFIG_NLS_CODEPAGE_855=m
+CONFIG_NLS_CODEPAGE_857=m
+CONFIG_NLS_CODEPAGE_860=m
+CONFIG_NLS_CODEPAGE_861=m
+CONFIG_NLS_CODEPAGE_862=m
+CONFIG_NLS_CODEPAGE_863=m
+CONFIG_NLS_CODEPAGE_864=m
+CONFIG_NLS_CODEPAGE_865=m
+CONFIG_NLS_CODEPAGE_866=m
+CONFIG_NLS_CODEPAGE_869=m
+CONFIG_NLS_CODEPAGE_936=m
+CONFIG_NLS_CODEPAGE_950=m
+CONFIG_NLS_CODEPAGE_932=m
+CONFIG_NLS_CODEPAGE_949=m
+CONFIG_NLS_CODEPAGE_874=m
+CONFIG_NLS_ISO8859_8=m
+CONFIG_NLS_CODEPAGE_1250=m
+CONFIG_NLS_CODEPAGE_1251=m
+# CONFIG_NLS_ASCII is not set
+CONFIG_NLS_ISO8859_1=m
+CONFIG_NLS_ISO8859_2=m
+CONFIG_NLS_ISO8859_3=m
+CONFIG_NLS_ISO8859_4=m
+CONFIG_NLS_ISO8859_5=m
+CONFIG_NLS_ISO8859_6=m
+CONFIG_NLS_ISO8859_7=m
+CONFIG_NLS_ISO8859_9=m
+CONFIG_NLS_ISO8859_13=m
+CONFIG_NLS_ISO8859_14=m
+CONFIG_NLS_ISO8859_15=m
+CONFIG_NLS_KOI8_R=m
+CONFIG_NLS_KOI8_U=m
+CONFIG_NLS_UTF8=m
+
+#
 # Library routines
 #
+# CONFIG_CRC_CCITT is not set
 CONFIG_CRC32=y
+# CONFIG_LIBCRC32C is not set
 
 #
 # HP Simulator drivers
@@ -1012,6 +1080,7 @@
 # CONFIG_IA64_DEBUG_CMPXCHG is not set
 # CONFIG_IA64_DEBUG_IRQ is not set
 # CONFIG_DEBUG_INFO is not set
+CONFIG_SYSVIPC_COMPAT=y
 
 #
 # Security options
@@ -1025,16 +1094,20 @@
 # CONFIG_CRYPTO_HMAC is not set
 # CONFIG_CRYPTO_NULL is not set
 # CONFIG_CRYPTO_MD4 is not set
-# CONFIG_CRYPTO_MD5 is not set
+CONFIG_CRYPTO_MD5=m
 # CONFIG_CRYPTO_SHA1 is not set
 # CONFIG_CRYPTO_SHA256 is not set
 # CONFIG_CRYPTO_SHA512 is not set
-# CONFIG_CRYPTO_DES is not set
+CONFIG_CRYPTO_DES=m
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set
 # CONFIG_CRYPTO_SERPENT is not set
-# CONFIG_CRYPTO_AES is not set
+# CONFIG_CRYPTO_AES_GENERIC is not set
 # CONFIG_CRYPTO_CAST5 is not set
 # CONFIG_CRYPTO_CAST6 is not set
+# CONFIG_CRYPTO_TEA is not set
+# CONFIG_CRYPTO_ARC4 is not set
 # CONFIG_CRYPTO_DEFLATE is not set
+# CONFIG_CRYPTO_MICHAEL_MIC is not set
+# CONFIG_CRYPTO_CRC32C is not set
 # CONFIG_CRYPTO_TEST is not set

--Boundary-00=_xuREByZCbYj94NE--

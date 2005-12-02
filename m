From: Robin Holt <holt@sgi.com>
Date: Fri, 02 Dec 2005 17:14:41 +0000
Subject: [Patch 1/1] Updates to the sn2_defconfig for 2.6.15.
Message-Id: <20051202171441.GB10211@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Please incorporate and push the following patch.  This updates the
sn2_defconfig file for the Altix 330 hardware, enables the AGP graphics
for the SGI Prism, and removes prompts for the remainder of the new
features..  Greg Edwards reviewed the changes and told me to forward
this on to you.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Greg Edwards <edwardsg@sgi.com>


Index: linux-2.6/arch/ia64/configs/sn2_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig	2005-11-11 20:06:47.000000000 -0600
+++ linux-2.6/arch/ia64/configs/sn2_defconfig	2005-12-02 10:33:51.382215069 -0600
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.13-rc6
-# Tue Aug 16 14:40:41 2005
+# Linux kernel version: 2.6.15-rc4
+# Fri Dec  2 10:33:48 2005
 #
 
 #
@@ -16,6 +16,7 @@ CONFIG_INIT_ENV_ARG_LIMIT2
 # General setup
 #
 CONFIG_LOCALVERSION=""
+# CONFIG_LOCALVERSION_AUTO is not set
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
@@ -26,6 +27,7 @@ CONFIG_HOTPLUG=y
 CONFIG_KOBJECT_UEVENT=y
 # CONFIG_IKCONFIG is not set
 CONFIG_CPUSETS=y
+CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 CONFIG_KALLSYMS_ALL=y
@@ -56,11 +58,29 @@ CONFIG_KMOD=y
 CONFIG_STOP_MACHINE=y
 
 #
+# Block layer
+#
+
+#
+# IO Schedulers
+#
+CONFIG_IOSCHED_NOOP=y
+CONFIG_IOSCHED_AS=y
+CONFIG_IOSCHED_DEADLINE=y
+CONFIG_IOSCHED_CFQ=y
+CONFIG_DEFAULT_AS=y
+# CONFIG_DEFAULT_DEADLINE is not set
+# CONFIG_DEFAULT_CFQ is not set
+# CONFIG_DEFAULT_NOOP is not set
+CONFIG_DEFAULT_IOSCHED="anticipatory"
+
+#
 # Processor type and features
 #
 CONFIG_IA64=y
 CONFIG_64BIT=y
 CONFIG_MMU=y
+CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
@@ -68,6 +88,7 @@ CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
 CONFIG_IA64_UNCACHED_ALLOCATOR=y
+CONFIG_ZONE_DMA_IS_DMA32=y
 # CONFIG_IA64_GENERIC is not set
 # CONFIG_IA64_DIG is not set
 # CONFIG_IA64_HP_ZX1 is not set
@@ -87,14 +108,10 @@ CONFIG_HZ_250=y
 # CONFIG_HZ_1000 is not set
 CONFIG_HZ%0
 CONFIG_IA64_L1_CACHE_SHIFT=7
-CONFIG_NUMA=y
-CONFIG_VIRTUAL_MEM_MAP=y
-CONFIG_HOLES_IN_ZONE=y
-CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
 CONFIG_IA64_SGI_SN_XP=m
-CONFIG_FORCE_MAX_ZONEORDER
+CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
 # CONFIG_HOTPLUG_CPU is not set
@@ -107,7 +124,17 @@ CONFIG_DISCONTIGMEM_MANUAL=y
 CONFIG_DISCONTIGMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
 CONFIG_NEED_MULTIPLE_NODES=y
-CONFIG_HAVE_DEC_LOCK=y
+# CONFIG_SPARSEMEM_STATIC is not set
+CONFIG_SPLIT_PTLOCK_CPUS=4
+CONFIG_ARCH_SELECT_MEMORY_MODEL=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
+CONFIG_ARCH_FLATMEM_ENABLE=y
+CONFIG_ARCH_SPARSEMEM_ENABLE=y
+CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
+CONFIG_NUMA=y
+CONFIG_VIRTUAL_MEM_MAP=y
+CONFIG_HOLES_IN_ZONE=y
+CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
@@ -126,28 +153,35 @@ CONFIG_BINFMT_ELF=y
 # Power management and ACPI
 #
 CONFIG_PM=y
-CONFIG_ACPI=y
+# CONFIG_PM_LEGACY is not set
+# CONFIG_PM_DEBUG is not set
 
 #
 # ACPI (Advanced Configuration and Power Interface) Support
 #
+CONFIG_ACPI=y
 # CONFIG_ACPI_BUTTON is not set
 # CONFIG_ACPI_FAN is not set
 # CONFIG_ACPI_PROCESSOR is not set
 CONFIG_ACPI_NUMA=y
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_SYSTEM=y
 # CONFIG_ACPI_CONTAINER is not set
 
 #
+# CPU Frequency scaling
+#
+# CONFIG_CPU_FREQ is not set
+
+#
 # Bus options (PCI, PCMCIA)
 #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
 # CONFIG_PCI_MSI is not set
 CONFIG_PCI_LEGACY_PROC=y
-CONFIG_PCI_NAMES=y
 # CONFIG_PCI_DEBUG is not set
 
 #
@@ -191,8 +225,8 @@ CONFIG_SYN_COOKIES=y
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
-CONFIG_IP_TCPDIAG=y
-# CONFIG_IP_TCPDIAG_IPV6 is not set
+CONFIG_INET_DIAG=m
+CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_BIC=y
 CONFIG_IPV6=m
@@ -205,6 +239,11 @@ CONFIG_IPV6=m
 # CONFIG_NETFILTER is not set
 
 #
+# DCCP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_DCCP is not set
+
+#
 # SCTP Configuration (EXPERIMENTAL)
 #
 # CONFIG_IP_SCTP is not set
@@ -220,8 +259,11 @@ CONFIG_IPV6=m
 # CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
+
+#
+# QoS and/or fair queueing
+#
 # CONFIG_NET_SCHED is not set
-# CONFIG_NET_CLS_ROUTE is not set
 
 #
 # Network testing
@@ -230,6 +272,7 @@ CONFIG_IPV6=m
 # CONFIG_HAMRADIO is not set
 # CONFIG_IRDA is not set
 # CONFIG_BT is not set
+# CONFIG_IEEE80211 is not set
 
 #
 # Device Drivers
@@ -244,6 +287,11 @@ CONFIG_FW_LOADER=y
 # CONFIG_DEBUG_DRIVER is not set
 
 #
+# Connector - unified userspace <-> kernelspace linker
+#
+# CONFIG_CONNECTOR is not set
+
+#
 # Memory Technology Devices (MTD)
 #
 # CONFIG_MTD is not set
@@ -275,16 +323,7 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
 CONFIG_BLK_DEV_INITRD=y
-CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_CDROM_PKTCDVD is not set
-
-#
-# IO Schedulers
-#
-CONFIG_IOSCHED_NOOP=y
-CONFIG_IOSCHED_AS=y
-CONFIG_IOSCHED_DEADLINE=y
-CONFIG_IOSCHED_CFQ=y
 CONFIG_ATA_OVER_ETH=m
 
 #
@@ -349,6 +388,7 @@ CONFIG_IDEDMA_AUTO=y
 #
 # SCSI device support
 #
+# CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
 CONFIG_SCSI_PROC_FS=y
 
@@ -375,11 +415,13 @@ CONFIG_SCSI_CONSTANTS=y
 #
 CONFIG_SCSI_SPI_ATTRS=y
 CONFIG_SCSI_FC_ATTRS=y
-# CONFIG_SCSI_ISCSI_ATTRS is not set
+CONFIG_SCSI_ISCSI_ATTRS=m
+CONFIG_SCSI_SAS_ATTRS=y
 
 #
 # SCSI low-level drivers
 #
+CONFIG_ISCSI_TCP=m
 # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
 # CONFIG_SCSI_3W_9XXX is not set
 # CONFIG_SCSI_ACARD is not set
@@ -389,15 +431,19 @@ CONFIG_SCSI_FC_ATTRS=y
 # CONFIG_SCSI_AIC79XX is not set
 # CONFIG_MEGARAID_NEWGEN is not set
 # CONFIG_MEGARAID_LEGACY is not set
+# CONFIG_MEGARAID_SAS is not set
 CONFIG_SCSI_SATA=y
 # CONFIG_SCSI_SATA_AHCI is not set
 # CONFIG_SCSI_SATA_SVW is not set
 # CONFIG_SCSI_ATA_PIIX is not set
+# CONFIG_SCSI_SATA_MV is not set
 # CONFIG_SCSI_SATA_NV is not set
-# CONFIG_SCSI_SATA_PROMISE is not set
+# CONFIG_SCSI_PDC_ADMA is not set
 # CONFIG_SCSI_SATA_QSTOR is not set
+# CONFIG_SCSI_SATA_PROMISE is not set
 # CONFIG_SCSI_SATA_SX4 is not set
 # CONFIG_SCSI_SATA_SIL is not set
+# CONFIG_SCSI_SATA_SIL24 is not set
 # CONFIG_SCSI_SATA_SIS is not set
 # CONFIG_SCSI_SATA_ULI is not set
 # CONFIG_SCSI_SATA_VIA is not set
@@ -411,7 +457,6 @@ CONFIG_SCSI_SATA_VITESSE=y
 # CONFIG_SCSI_IPR is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
-# CONFIG_SCSI_QLOGIC_1280_1040 is not set
 CONFIG_SCSI_QLA2XXX=y
 # CONFIG_SCSI_QLA21XX is not set
 CONFIG_SCSI_QLA22XX=y
@@ -451,6 +496,7 @@ CONFIG_DM_MULTIPATH_EMC=m
 CONFIG_FUSION=y
 CONFIG_FUSION_SPI=y
 CONFIG_FUSION_FC=y
+CONFIG_FUSION_SAS=y
 CONFIG_FUSION_MAX_SGE8
 CONFIG_FUSION_CTL=m
 
@@ -479,6 +525,10 @@ CONFIG_NETDEVICES=y
 # CONFIG_ARCNET is not set
 
 #
+# PHY device support
+#
+
+#
 # Ethernet (10 or 100Mbit)
 #
 # CONFIG_NET_ETHERNET is not set
@@ -493,6 +543,7 @@ CONFIG_NETDEVICES=y
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
+# CONFIG_SIS190 is not set
 # CONFIG_SKGE is not set
 # CONFIG_SK98LIN is not set
 CONFIG_TIGON3=y
@@ -501,10 +552,10 @@ CONFIG_TIGON3=y
 #
 # Ethernet (10000 Mbit)
 #
+CONFIG_CHELSIO_T1=m
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
 # CONFIG_S2IO_NAPI is not set
-# CONFIG_2BUFF_MODE is not set
 
 #
 # Token Ring devices
@@ -583,6 +634,7 @@ CONFIG_HW_CONSOLE=y
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
 # CONFIG_CYCLADES is not set
+# CONFIG_DIGIEPCA is not set
 # CONFIG_MOXA_SMARTIO is not set
 # CONFIG_ISI is not set
 # CONFIG_SYNCLINKMP is not set
@@ -629,7 +681,8 @@ CONFIG_EFI_RTC=y
 #
 # Ftape, the floppy tape device driver
 #
-# CONFIG_AGP is not set
+CONFIG_AGP=y
+CONFIG_AGP_SGI_TIOCA=y
 # CONFIG_DRM is not set
 CONFIG_RAW_DRIVER=m
 # CONFIG_HPET is not set
@@ -641,12 +694,12 @@ CONFIG_MMTIMER=y
 # TPM devices
 #
 # CONFIG_TCG_TPM is not set
+# CONFIG_TELCLOCK is not set
 
 #
 # I2C support
 #
 # CONFIG_I2C is not set
-# CONFIG_I2C_SENSOR is not set
 
 #
 # Dallas's 1-wire bus
@@ -657,12 +710,17 @@ CONFIG_MMTIMER=y
 # Hardware Monitoring support
 #
 # CONFIG_HWMON is not set
+# CONFIG_HWMON_VID is not set
 
 #
 # Misc devices
 #
 
 #
+# Multimedia Capabilities Port drivers
+#
+
+#
 # Multimedia devices
 #
 # CONFIG_VIDEO_DEV is not set
@@ -721,12 +779,15 @@ CONFIG_USB_UHCI_HCD=m
 #
 # USB Device Class drivers
 #
-# CONFIG_USB_BLUETOOTH_TTY is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
 
 #
-# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be needed; see USB_STORAGE Help for more information
+# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
+#
+
+#
+# may also be needed; see USB_STORAGE Help for more information
 #
 # CONFIG_USB_STORAGE is not set
 
@@ -751,9 +812,11 @@ CONFIG_USB_HIDINPUT=y
 # CONFIG_USB_MTOUCH is not set
 # CONFIG_USB_ITMTOUCH is not set
 # CONFIG_USB_EGALAX is not set
+# CONFIG_USB_YEALINK is not set
 # CONFIG_USB_XPAD is not set
 # CONFIG_USB_ATI_REMOTE is not set
 # CONFIG_USB_KEYSPAN_REMOTE is not set
+# CONFIG_USB_APPLETOUCH is not set
 
 #
 # USB Imaging devices
@@ -824,11 +887,13 @@ CONFIG_USB_MON=y
 # InfiniBand support
 #
 CONFIG_INFINIBAND=m
-CONFIG_INFINIBAND_USER_VERBS=m
+# CONFIG_INFINIBAND_USER_MAD is not set
+CONFIG_INFINIBAND_USER_ACCESS=m
 CONFIG_INFINIBAND_MTHCA=m
 # CONFIG_INFINIBAND_MTHCA_DEBUG is not set
 CONFIG_INFINIBAND_IPOIB=m
 # CONFIG_INFINIBAND_IPOIB_DEBUG is not set
+CONFIG_INFINIBAND_SRP=m
 
 #
 # SN Devices
@@ -858,16 +923,12 @@ CONFIG_REISERFS_FS_POSIX_ACL=y
 CONFIG_REISERFS_FS_SECURITY=y
 # CONFIG_JFS_FS is not set
 CONFIG_FS_POSIX_ACL=y
-
-#
-# XFS support
-#
 CONFIG_XFS_FS=y
 CONFIG_XFS_EXPORT=y
-CONFIG_XFS_RT=y
 CONFIG_XFS_QUOTA=y
 # CONFIG_XFS_SECURITY is not set
 CONFIG_XFS_POSIX_ACL=y
+CONFIG_XFS_RT=y
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
 CONFIG_INOTIFY=y
@@ -878,6 +939,7 @@ CONFIG_QUOTACTL=y
 CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=m
 CONFIG_AUTOFS4_FS=m
+CONFIG_FUSE_FS=m
 
 #
 # CD-ROM/DVD Filesystems
@@ -904,13 +966,11 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
-# CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-CONFIG_TMPFS_XATTR=y
-CONFIG_TMPFS_SECURITY=y
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
+CONFIG_RELAYFS_FS=m
 
 #
 # Miscellaneous filesystems
@@ -959,6 +1019,7 @@ CONFIG_CIFS=m
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
+# CONFIG_9P_FS is not set
 
 #
 # Partition Types
@@ -1028,18 +1089,21 @@ CONFIG_NLS_UTF8=y
 # Library routines
 #
 # CONFIG_CRC_CCITT is not set
+CONFIG_CRC16=m
 CONFIG_CRC32=y
-# CONFIG_LIBCRC32C is not set
+CONFIG_LIBCRC32C=m
 CONFIG_ZLIB_INFLATE=m
 CONFIG_ZLIB_DEFLATE=m
 CONFIG_GENERIC_ALLOCATOR=y
 CONFIG_GENERIC_HARDIRQS=y
 CONFIG_GENERIC_IRQ_PROBE=y
+CONFIG_GENERIC_PENDING_IRQ=y
 
 #
-# Profiling support
+# Instrumentation Support
 #
 # CONFIG_PROFILING is not set
+# CONFIG_KPROBES is not set
 
 #
 # Kernel hacking
@@ -1048,6 +1112,7 @@ CONFIG_GENERIC_IRQ_PROBE=y
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
 CONFIG_LOG_BUF_SHIFT 
+CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_PREEMPT=y
@@ -1056,7 +1121,8 @@ CONFIG_DEBUG_PREEMPT=y
 # CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
 # CONFIG_DEBUG_FS is not set
-# CONFIG_KPROBES is not set
+# CONFIG_DEBUG_VM is not set
+# CONFIG_RCU_TORTURE_TEST is not set
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
 # CONFIG_IA64_PRINT_HAZARDS is not set
@@ -1097,7 +1163,7 @@ CONFIG_CRYPTO_DES=m
 # CONFIG_CRYPTO_ANUBIS is not set
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
-# CONFIG_CRYPTO_CRC32C is not set
+CONFIG_CRYPTO_CRC32C=m
 # CONFIG_CRYPTO_TEST is not set
 
 #

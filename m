From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 14 Sep 2005 22:50:19 +0000
Subject: [PATCH] ia64: Update default configs
Message-Id: <200509141650.19927.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

PNP and PNPACPI turned on

    i8042 recently changed from ACPI to PNP detection.  Without PNP, it
    probes legacy I/O ports for the keyboard controller, which causes an
    MCA on HP boxes.

    Also, I'm about to remove 8250_acpi.c, so we'll need PNP to detect
    non-PCI serial ports.  Until 8250_acpi.c is removed, some systems
    will see serial ports reported twice (once from 8250_acpi.c and again
    from 8250_pnp.c).  This is harmless.

    PNPACPI is still marked EXPERIMENTAL, but I'm not aware of any
    outstanding issues on ia64.

IDE_GENERIC turned off (except for SGI simulator, all ia64 IDE is PCI)

    ide-generic probes compiled-in legacy I/O ports for IDE devices, which
    again causes an MCA.  It would be nicer to just get rid of all the
    legacy junk from include/asm-ia64/ide.h, but that is a bit riskier
    because it could break ide-cs and the HDIO_REGISTER_HWIF ioctl
    (http://www.ussg.iu.edu/hypermail/linux/kernel/0508.2/0049.html).

Here's the essence of the patch:

    -# CONFIG_PNP is not set
    +CONFIG_PNP=y
    +CONFIG_PNPACPI=y

    -CONFIG_IDE_GENERIC=y
    +# CONFIG_IDE_GENERIC is not set

Tested on tiger, bigsur, and zx1.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-vga2/arch/ia64/defconfig
=================================--- work-vga2.orig/arch/ia64/defconfig	2005-09-14 16:34:53.000000000 -0600
+++ work-vga2/arch/ia64/defconfig	2005-09-14 16:35:14.000000000 -0600
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.12
-# Tue Jun 21 11:30:42 2005
+# Linux kernel version: 2.6.14-rc1
+# Wed Sep 14 15:13:03 2005
 #
 
 #
@@ -16,6 +16,7 @@
 # General setup
 #
 CONFIG_LOCALVERSION=""
+CONFIG_LOCALVERSION_AUTO=y
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
@@ -27,6 +28,7 @@
 CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 # CONFIG_CPUSETS is not set
+CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 CONFIG_KALLSYMS_ALL=y
@@ -80,6 +82,10 @@
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
+# CONFIG_HZ_100 is not set
+CONFIG_HZ_250=y
+# CONFIG_HZ_1000 is not set
+CONFIG_HZ%0
 CONFIG_IA64_L1_CACHE_SHIFT=7
 CONFIG_NUMA=y
 CONFIG_VIRTUAL_MEM_MAP=y
@@ -87,12 +93,21 @@
 CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_IA64_CYCLONE=y
 CONFIG_IOSAPIC=y
+# CONFIG_IA64_SGI_SN_XP is not set
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
 CONFIG_HOTPLUG_CPU=y
 # CONFIG_SCHED_SMT is not set
 # CONFIG_PREEMPT is not set
+CONFIG_SELECT_MEMORY_MODEL=y
+# CONFIG_FLATMEM_MANUAL is not set
+CONFIG_DISCONTIGMEM_MANUAL=y
+# CONFIG_SPARSEMEM_MANUAL is not set
+CONFIG_DISCONTIGMEM=y
+CONFIG_FLAT_NODE_MEM_MAP=y
+CONFIG_NEED_MULTIPLE_NODES=y
+# CONFIG_SPARSEMEM_STATIC is not set
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
@@ -105,6 +120,7 @@
 #
 CONFIG_EFI_VARS=y
 CONFIG_EFI_PCDP=y
+# CONFIG_DELL_RBU is not set
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=m
 
@@ -112,30 +128,36 @@
 # Power management and ACPI
 #
 CONFIG_PM=y
-CONFIG_ACPI=y
+# CONFIG_PM_DEBUG is not set
 
 #
 # ACPI (Advanced Configuration and Power Interface) Support
 #
+CONFIG_ACPI=y
 CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_HOTPLUG_CPU=y
 CONFIG_ACPI_THERMAL=m
 CONFIG_ACPI_NUMA=y
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_SYSTEM=y
 CONFIG_ACPI_CONTAINER=m
 
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
@@ -147,6 +169,7 @@
 # CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
 # CONFIG_HOTPLUG_PCI_CPCI is not set
 # CONFIG_HOTPLUG_PCI_SHPC is not set
+# CONFIG_HOTPLUG_PCI_SGI is not set
 
 #
 # PCCARD (PCMCIA/CardBus) support
@@ -154,6 +177,73 @@
 # CONFIG_PCCARD is not set
 
 #
+# Networking
+#
+CONFIG_NET=y
+
+#
+# Networking options
+#
+CONFIG_PACKET=y
+# CONFIG_PACKET_MMAP is not set
+CONFIG_UNIX=y
+# CONFIG_NET_KEY is not set
+CONFIG_INET=y
+CONFIG_IP_MULTICAST=y
+# CONFIG_IP_ADVANCED_ROUTER is not set
+CONFIG_IP_FIB_HASH=y
+# CONFIG_IP_PNP is not set
+# CONFIG_NET_IPIP is not set
+# CONFIG_NET_IPGRE is not set
+# CONFIG_IP_MROUTE is not set
+CONFIG_ARPD=y
+CONFIG_SYN_COOKIES=y
+# CONFIG_INET_AH is not set
+# CONFIG_INET_ESP is not set
+# CONFIG_INET_IPCOMP is not set
+# CONFIG_INET_TUNNEL is not set
+CONFIG_INET_DIAG=y
+CONFIG_INET_TCP_DIAG=y
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_BIC=y
+# CONFIG_IPV6 is not set
+# CONFIG_NETFILTER is not set
+
+#
+# DCCP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_DCCP is not set
+
+#
+# SCTP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_SCTP is not set
+# CONFIG_ATM is not set
+# CONFIG_BRIDGE is not set
+# CONFIG_VLAN_8021Q is not set
+# CONFIG_DECNET is not set
+# CONFIG_LLC2 is not set
+# CONFIG_IPX is not set
+# CONFIG_ATALK is not set
+# CONFIG_X25 is not set
+# CONFIG_LAPB is not set
+# CONFIG_NET_DIVERT is not set
+# CONFIG_ECONET is not set
+# CONFIG_WAN_ROUTER is not set
+# CONFIG_NET_SCHED is not set
+# CONFIG_NET_CLS_ROUTE is not set
+
+#
+# Network testing
+#
+# CONFIG_NET_PKTGEN is not set
+# CONFIG_NETFILTER_NETLINK is not set
+# CONFIG_HAMRADIO is not set
+# CONFIG_IRDA is not set
+# CONFIG_BT is not set
+# CONFIG_IEEE80211 is not set
+
+#
 # Device Drivers
 #
 
@@ -162,10 +252,15 @@
 #
 CONFIG_STANDALONE=y
 CONFIG_PREVENT_FIRMWARE_BUILD=y
-# CONFIG_FW_LOADER is not set
+CONFIG_FW_LOADER=m
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
@@ -178,7 +273,13 @@
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
@@ -197,7 +298,6 @@
 CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
 CONFIG_BLK_DEV_INITRD=y
-CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_CDROM_PKTCDVD is not set
 
 #
@@ -230,7 +330,8 @@
 #
 # IDE chipset support/bugfixes
 #
-CONFIG_IDE_GENERIC=y
+# CONFIG_IDE_GENERIC is not set
+# CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
 # CONFIG_IDEPCI_SHARE_IRQ is not set
 # CONFIG_BLK_DEV_OFFBOARD is not set
@@ -252,6 +353,7 @@
 # CONFIG_BLK_DEV_HPT366 is not set
 # CONFIG_BLK_DEV_SC1200 is not set
 CONFIG_BLK_DEV_PIIX=y
+# CONFIG_BLK_DEV_IT821X is not set
 # CONFIG_BLK_DEV_NS87415 is not set
 # CONFIG_BLK_DEV_PDC202XX_OLD is not set
 # CONFIG_BLK_DEV_PDC202XX_NEW is not set
@@ -270,6 +372,7 @@
 #
 # SCSI device support
 #
+# CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
 CONFIG_SCSI_PROC_FS=y
 
@@ -297,6 +400,7 @@
 CONFIG_SCSI_SPI_ATTRS=y
 CONFIG_SCSI_FC_ATTRS=y
 # CONFIG_SCSI_ISCSI_ATTRS is not set
+# CONFIG_SCSI_SAS_ATTRS is not set
 
 #
 # SCSI low-level drivers
@@ -314,6 +418,7 @@
 # CONFIG_SCSI_SATA_AHCI is not set
 # CONFIG_SCSI_SATA_SVW is not set
 # CONFIG_SCSI_ATA_PIIX is not set
+# CONFIG_SCSI_SATA_MV is not set
 # CONFIG_SCSI_SATA_NV is not set
 # CONFIG_SCSI_SATA_PROMISE is not set
 # CONFIG_SCSI_SATA_QSTOR is not set
@@ -335,7 +440,6 @@
 # CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set
 # CONFIG_SCSI_IPR is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
-# CONFIG_SCSI_QLOGIC_FC_FIRMWARE is not set
 CONFIG_SCSI_QLOGIC_1280=y
 # CONFIG_SCSI_QLOGIC_1280_1040 is not set
 CONFIG_SCSI_QLA2XXX=y
@@ -344,6 +448,7 @@
 CONFIG_SCSI_QLA2300=m
 CONFIG_SCSI_QLA2322=m
 # CONFIG_SCSI_QLA6312 is not set
+# CONFIG_SCSI_QLA24XX is not set
 # CONFIG_SCSI_LPFC is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
@@ -390,74 +495,14 @@
 # CONFIG_I2O is not set
 
 #
-# Networking support
-#
-CONFIG_NET=y
-
-#
-# Networking options
-#
-CONFIG_PACKET=y
-# CONFIG_PACKET_MMAP is not set
-CONFIG_UNIX=y
-# CONFIG_NET_KEY is not set
-CONFIG_INET=y
-CONFIG_IP_MULTICAST=y
-# CONFIG_IP_ADVANCED_ROUTER is not set
-# CONFIG_IP_PNP is not set
-# CONFIG_NET_IPIP is not set
-# CONFIG_NET_IPGRE is not set
-# CONFIG_IP_MROUTE is not set
-CONFIG_ARPD=y
-CONFIG_SYN_COOKIES=y
-# CONFIG_INET_AH is not set
-# CONFIG_INET_ESP is not set
-# CONFIG_INET_IPCOMP is not set
-# CONFIG_INET_TUNNEL is not set
-CONFIG_IP_TCPDIAG=y
-# CONFIG_IP_TCPDIAG_IPV6 is not set
-# CONFIG_IPV6 is not set
-# CONFIG_NETFILTER is not set
-
-#
-# SCTP Configuration (EXPERIMENTAL)
-#
-# CONFIG_IP_SCTP is not set
-# CONFIG_ATM is not set
-# CONFIG_BRIDGE is not set
-# CONFIG_VLAN_8021Q is not set
-# CONFIG_DECNET is not set
-# CONFIG_LLC2 is not set
-# CONFIG_IPX is not set
-# CONFIG_ATALK is not set
-# CONFIG_X25 is not set
-# CONFIG_LAPB is not set
-# CONFIG_NET_DIVERT is not set
-# CONFIG_ECONET is not set
-# CONFIG_WAN_ROUTER is not set
-
+# Network device support
 #
-# QoS and/or fair queueing
-#
-# CONFIG_NET_SCHED is not set
-# CONFIG_NET_CLS_ROUTE is not set
-
-#
-# Network testing
-#
-# CONFIG_NET_PKTGEN is not set
-CONFIG_NETPOLL=y
-# CONFIG_NETPOLL_RX is not set
-# CONFIG_NETPOLL_TRAP is not set
-CONFIG_NET_POLL_CONTROLLER=y
-# CONFIG_HAMRADIO is not set
-# CONFIG_IRDA is not set
-# CONFIG_BT is not set
 CONFIG_NETDEVICES=y
 CONFIG_DUMMY=m
 # CONFIG_BONDING is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
+# CONFIG_NET_SB1000 is not set
 
 #
 # ARCnet devices
@@ -465,6 +510,11 @@
 # CONFIG_ARCNET is not set
 
 #
+# PHY device support
+#
+# CONFIG_PHYLIB is not set
+
+#
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=y
@@ -485,6 +535,7 @@
 # CONFIG_DE4X5 is not set
 # CONFIG_WINBOND_840 is not set
 # CONFIG_DM9102 is not set
+# CONFIG_ULI526X is not set
 # CONFIG_HP100 is not set
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
@@ -516,6 +567,7 @@
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
+# CONFIG_SIS190 is not set
 # CONFIG_SKGE is not set
 # CONFIG_SK98LIN is not set
 # CONFIG_VIA_VELOCITY is not set
@@ -525,6 +577,7 @@
 #
 # Ethernet (10000 Mbit)
 #
+# CONFIG_CHELSIO_T1 is not set
 # CONFIG_IXGB is not set
 # CONFIG_S2IO is not set
 
@@ -549,6 +602,10 @@
 # CONFIG_NET_FC is not set
 # CONFIG_SHAPER is not set
 CONFIG_NETCONSOLE=y
+CONFIG_NETPOLL=y
+# CONFIG_NETPOLL_RX is not set
+# CONFIG_NETPOLL_TRAP is not set
+CONFIG_NET_POLL_CONTROLLER=y
 
 #
 # ISDN subsystem
@@ -607,9 +664,7 @@
 # CONFIG_GAMEPORT_NS558 is not set
 # CONFIG_GAMEPORT_L4 is not set
 # CONFIG_GAMEPORT_EMU10K1 is not set
-# CONFIG_GAMEPORT_VORTEX is not set
 # CONFIG_GAMEPORT_FM801 is not set
-# CONFIG_GAMEPORT_CS461X is not set
 
 #
 # Character devices
@@ -620,6 +675,7 @@
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
 # CONFIG_CYCLADES is not set
+# CONFIG_DIGIEPCA is not set
 # CONFIG_MOXA_SMARTIO is not set
 # CONFIG_ISI is not set
 # CONFIG_SYNCLINKMP is not set
@@ -641,7 +697,6 @@
 CONFIG_SERIAL_8250_EXTENDED=y
 CONFIG_SERIAL_8250_SHARE_IRQ=y
 # CONFIG_SERIAL_8250_DETECT_IRQ is not set
-# CONFIG_SERIAL_8250_MULTIPORT is not set
 # CONFIG_SERIAL_8250_RSA is not set
 
 #
@@ -650,8 +705,8 @@
 CONFIG_SERIAL_CORE=y
 CONFIG_SERIAL_CORE_CONSOLE=y
 CONFIG_SERIAL_SGI_L1_CONSOLE=y
-CONFIG_SERIAL_SGI_IOC4=y
 # CONFIG_SERIAL_JSM is not set
+CONFIG_SERIAL_SGI_IOC4=y
 CONFIG_UNIX98_PTYS=y
 CONFIG_LEGACY_PTYS=y
 CONFIG_LEGACY_PTY_COUNT%6
@@ -684,6 +739,8 @@
 CONFIG_DRM_RADEON=m
 CONFIG_DRM_MGA=m
 CONFIG_DRM_SIS=m
+# CONFIG_DRM_VIA is not set
+# CONFIG_DRM_SAVAGE is not set
 CONFIG_RAW_DRIVER=m
 CONFIG_HPET=y
 # CONFIG_HPET_RTC_IRQ is not set
@@ -708,10 +765,21 @@
 # CONFIG_W1 is not set
 
 #
+# Hardware Monitoring support
+#
+CONFIG_HWMON=y
+# CONFIG_HWMON_VID is not set
+# CONFIG_HWMON_DEBUG_CHIP is not set
+
+#
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
@@ -753,6 +821,7 @@
 CONFIG_SND_SEQUENCER_OSS=y
 CONFIG_SND_VERBOSE_PRINTK=y
 # CONFIG_SND_DEBUG is not set
+CONFIG_SND_GENERIC_DRIVER=y
 
 #
 # Generic devices
@@ -764,11 +833,12 @@
 CONFIG_SND_MTPAV=m
 CONFIG_SND_SERIAL_U16550=m
 CONFIG_SND_MPU401=m
+CONFIG_SND_AC97_CODEC=m
+CONFIG_SND_AC97_BUS=m
 
 #
 # PCI devices
 #
-CONFIG_SND_AC97_CODEC=m
 # CONFIG_SND_ALI5451 is not set
 # CONFIG_SND_ATIIXP is not set
 # CONFIG_SND_ATIIXP_MODEM is not set
@@ -790,9 +860,10 @@
 # CONFIG_SND_RME96 is not set
 # CONFIG_SND_RME9652 is not set
 # CONFIG_SND_HDSP is not set
+# CONFIG_SND_HDSPM is not set
 # CONFIG_SND_TRIDENT is not set
 # CONFIG_SND_YMFPCI is not set
-# CONFIG_SND_ALS4000 is not set
+# CONFIG_SND_AD1889 is not set
 # CONFIG_SND_CMIPCI is not set
 # CONFIG_SND_ENS1370 is not set
 # CONFIG_SND_ENS1371 is not set
@@ -844,6 +915,7 @@
 CONFIG_USB_EHCI_HCD=m
 # CONFIG_USB_EHCI_SPLIT_ISO is not set
 # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
+# CONFIG_USB_ISP116X_HCD is not set
 CONFIG_USB_OHCI_HCD=m
 # CONFIG_USB_OHCI_BIG_ENDIAN is not set
 CONFIG_USB_OHCI_LITTLE_ENDIAN=y
@@ -853,9 +925,8 @@
 #
 # USB Device Class drivers
 #
-# CONFIG_USB_AUDIO is not set
+# CONFIG_OBSOLETE_OSS_USB_DRIVER is not set
 # CONFIG_USB_BLUETOOTH_TTY is not set
-# CONFIG_USB_MIDI is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
 
@@ -888,12 +959,17 @@
 # CONFIG_USB_MOUSE is not set
 # CONFIG_USB_AIPTEK is not set
 # CONFIG_USB_WACOM is not set
+# CONFIG_USB_ACECAD is not set
 # CONFIG_USB_KBTAB is not set
 # CONFIG_USB_POWERMATE is not set
 # CONFIG_USB_MTOUCH is not set
+# CONFIG_USB_ITMTOUCH is not set
 # CONFIG_USB_EGALAX is not set
+# CONFIG_USB_YEALINK is not set
 # CONFIG_USB_XPAD is not set
 # CONFIG_USB_ATI_REMOTE is not set
+# CONFIG_USB_KEYSPAN_REMOTE is not set
+# CONFIG_USB_APPLETOUCH is not set
 
 #
 # USB Imaging devices
@@ -918,7 +994,7 @@
 # CONFIG_USB_PEGASUS is not set
 # CONFIG_USB_RTL8150 is not set
 # CONFIG_USB_USBNET is not set
-CONFIG_USB_MON=m
+CONFIG_USB_MON=y
 
 #
 # USB port drivers
@@ -944,10 +1020,11 @@
 # CONFIG_USB_PHIDGETSERVO is not set
 # CONFIG_USB_IDMOUSE is not set
 # CONFIG_USB_SISUSBVGA is not set
+# CONFIG_USB_LD is not set
 # CONFIG_USB_TEST is not set
 
 #
-# USB ATM/DSL drivers
+# USB DSL modem support
 #
 
 #
@@ -964,6 +1041,8 @@
 # InfiniBand support
 #
 CONFIG_INFINIBAND=m
+# CONFIG_INFINIBAND_USER_MAD is not set
+# CONFIG_INFINIBAND_USER_ACCESS is not set
 CONFIG_INFINIBAND_MTHCA=m
 # CONFIG_INFINIBAND_MTHCA_DEBUG is not set
 CONFIG_INFINIBAND_IPOIB=m
@@ -981,6 +1060,7 @@
 CONFIG_EXT2_FS_XATTR=y
 CONFIG_EXT2_FS_POSIX_ACL=y
 CONFIG_EXT2_FS_SECURITY=y
+# CONFIG_EXT2_FS_XIP is not set
 CONFIG_EXT3_FS=y
 CONFIG_EXT3_FS_XATTR=y
 CONFIG_EXT3_FS_POSIX_ACL=y
@@ -996,22 +1076,20 @@
 CONFIG_REISERFS_FS_SECURITY=y
 # CONFIG_JFS_FS is not set
 CONFIG_FS_POSIX_ACL=y
-
-#
-# XFS support
-#
 CONFIG_XFS_FS=y
 CONFIG_XFS_EXPORT=y
-# CONFIG_XFS_RT is not set
 # CONFIG_XFS_QUOTA is not set
 # CONFIG_XFS_SECURITY is not set
 # CONFIG_XFS_POSIX_ACL is not set
+# CONFIG_XFS_RT is not set
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
+CONFIG_INOTIFY=y
 # CONFIG_QUOTA is not set
 CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=y
 CONFIG_AUTOFS4_FS=y
+# CONFIG_FUSE_FS is not set
 
 #
 # CD-ROM/DVD Filesystems
@@ -1040,14 +1118,11 @@
 CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
-# CONFIG_DEVFS_FS is not set
-# CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-CONFIG_TMPFS_XATTR=y
-CONFIG_TMPFS_SECURITY=y
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
+# CONFIG_RELAYFS_FS is not set
 
 #
 # Miscellaneous filesystems
@@ -1071,15 +1146,18 @@
 #
 CONFIG_NFS_FS=m
 CONFIG_NFS_V3=y
+# CONFIG_NFS_V3_ACL is not set
 CONFIG_NFS_V4=y
 CONFIG_NFS_DIRECTIO=y
 CONFIG_NFSD=m
 CONFIG_NFSD_V3=y
+# CONFIG_NFSD_V3_ACL is not set
 CONFIG_NFSD_V4=y
 CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=m
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y
+CONFIG_NFS_COMMON=y
 CONFIG_SUNRPC=m
 CONFIG_SUNRPC_GSS=m
 CONFIG_RPCSEC_GSS_KRB5=m
@@ -1094,6 +1172,7 @@
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
+# CONFIG_9P_FS is not set
 
 #
 # Partition Types
@@ -1163,10 +1242,12 @@
 # Library routines
 #
 # CONFIG_CRC_CCITT is not set
+# CONFIG_CRC16 is not set
 CONFIG_CRC32=y
 # CONFIG_LIBCRC32C is not set
 CONFIG_GENERIC_HARDIRQS=y
 CONFIG_GENERIC_IRQ_PROBE=y
+CONFIG_GENERIC_PENDING_IRQ=y
 
 #
 # HP Simulator drivers
@@ -1187,6 +1268,7 @@
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
 CONFIG_LOG_BUF_SHIFT 
+CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set
@@ -1194,6 +1276,7 @@
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
 # CONFIG_DEBUG_FS is not set
+# CONFIG_KPROBES is not set
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
 # CONFIG_IA64_PRINT_HAZARDS is not set
@@ -1215,7 +1298,7 @@
 # CONFIG_CRYPTO_HMAC is not set
 # CONFIG_CRYPTO_NULL is not set
 # CONFIG_CRYPTO_MD4 is not set
-CONFIG_CRYPTO_MD5=m
+CONFIG_CRYPTO_MD5=y
 # CONFIG_CRYPTO_SHA1 is not set
 # CONFIG_CRYPTO_SHA256 is not set
 # CONFIG_CRYPTO_SHA512 is not set
Index: work-vga2/arch/ia64/configs/zx1_defconfig
=================================--- work-vga2.orig/arch/ia64/configs/zx1_defconfig	2005-09-14 16:34:53.000000000 -0600
+++ work-vga2/arch/ia64/configs/zx1_defconfig	2005-09-14 16:35:14.000000000 -0600
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.13-rc6
-# Wed Aug 17 10:02:43 2005
+# Linux kernel version: 2.6.14-rc1
+# Wed Sep 14 15:15:01 2005
 #
 
 #
@@ -18,6 +18,7 @@
 # General setup
 #
 CONFIG_LOCALVERSION=""
+CONFIG_LOCALVERSION_AUTO=y
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 # CONFIG_POSIX_MQUEUE is not set
@@ -29,6 +30,7 @@
 CONFIG_KOBJECT_UEVENT=y
 # CONFIG_IKCONFIG is not set
 # CONFIG_CPUSETS is not set
+CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 # CONFIG_KALLSYMS_ALL is not set
@@ -103,6 +105,7 @@
 # CONFIG_SPARSEMEM_MANUAL is not set
 CONFIG_FLATMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
+# CONFIG_SPARSEMEM_STATIC is not set
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
@@ -115,6 +118,7 @@
 #
 CONFIG_EFI_VARS=y
 CONFIG_EFI_PCDP=y
+# CONFIG_DELL_RBU is not set
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=y
 
@@ -122,28 +126,34 @@
 # Power management and ACPI
 #
 CONFIG_PM=y
-CONFIG_ACPI=y
+# CONFIG_PM_DEBUG is not set
 
 #
 # ACPI (Advanced Configuration and Power Interface) Support
 #
+CONFIG_ACPI=y
 CONFIG_ACPI_BUTTON=y
 CONFIG_ACPI_FAN=y
 CONFIG_ACPI_PROCESSOR=y
 CONFIG_ACPI_THERMAL=y
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
@@ -187,8 +197,8 @@
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
-# CONFIG_IP_TCPDIAG is not set
-# CONFIG_IP_TCPDIAG_IPV6 is not set
+CONFIG_INET_DIAG=y
+CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_BIC=y
 
@@ -204,7 +214,6 @@
 # IP: Netfilter Configuration
 #
 # CONFIG_IP_NF_CONNTRACK is not set
-# CONFIG_IP_NF_CONNTRACK_MARK is not set
 # CONFIG_IP_NF_QUEUE is not set
 # CONFIG_IP_NF_IPTABLES is not set
 CONFIG_IP_NF_ARPTABLES=y
@@ -212,6 +221,11 @@
 # CONFIG_IP_NF_ARP_MANGLE is not set
 
 #
+# DCCP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_DCCP is not set
+
+#
 # SCTP Configuration (EXPERIMENTAL)
 #
 # CONFIG_IP_SCTP is not set
@@ -234,9 +248,11 @@
 # Network testing
 #
 # CONFIG_NET_PKTGEN is not set
+# CONFIG_NETFILTER_NETLINK is not set
 # CONFIG_HAMRADIO is not set
 # CONFIG_IRDA is not set
 # CONFIG_BT is not set
+# CONFIG_IEEE80211 is not set
 
 #
 # Device Drivers
@@ -251,6 +267,11 @@
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
@@ -263,7 +284,13 @@
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
@@ -282,7 +309,6 @@
 CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
 CONFIG_BLK_DEV_INITRD=y
-CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_CDROM_PKTCDVD is not set
 
 #
@@ -315,7 +341,8 @@
 #
 # IDE chipset support/bugfixes
 #
-CONFIG_IDE_GENERIC=y
+# CONFIG_IDE_GENERIC is not set
+# CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
 CONFIG_IDEPCI_SHARE_IRQ=y
 # CONFIG_BLK_DEV_OFFBOARD is not set
@@ -354,6 +381,7 @@
 #
 # SCSI device support
 #
+# CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
 CONFIG_SCSI_PROC_FS=y
 
@@ -381,6 +409,7 @@
 CONFIG_SCSI_SPI_ATTRS=y
 # CONFIG_SCSI_FC_ATTRS is not set
 # CONFIG_SCSI_ISCSI_ATTRS is not set
+# CONFIG_SCSI_SAS_ATTRS is not set
 
 #
 # SCSI low-level drivers
@@ -457,6 +486,7 @@
 # CONFIG_BONDING is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
+# CONFIG_NET_SB1000 is not set
 
 #
 # ARCnet devices
@@ -464,6 +494,11 @@
 # CONFIG_ARCNET is not set
 
 #
+# PHY device support
+#
+# CONFIG_PHYLIB is not set
+
+#
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=y
@@ -485,6 +520,7 @@
 # CONFIG_DE4X5 is not set
 # CONFIG_WINBOND_840 is not set
 # CONFIG_DM9102 is not set
+# CONFIG_ULI526X is not set
 # CONFIG_HP100 is not set
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
@@ -516,6 +552,7 @@
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
+# CONFIG_SIS190 is not set
 # CONFIG_SKGE is not set
 # CONFIG_SK98LIN is not set
 # CONFIG_VIA_VELOCITY is not set
@@ -525,6 +562,7 @@
 #
 # Ethernet (10000 Mbit)
 #
+# CONFIG_CHELSIO_T1 is not set
 # CONFIG_IXGB is not set
 # CONFIG_S2IO is not set
 
@@ -650,12 +688,12 @@
 CONFIG_AGP_HP_ZX1=y
 CONFIG_DRM=y
 # CONFIG_DRM_TDFX is not set
-# CONFIG_DRM_GAMMA is not set
 # CONFIG_DRM_R128 is not set
 CONFIG_DRM_RADEON=y
 # CONFIG_DRM_MGA is not set
 # CONFIG_DRM_SIS is not set
 # CONFIG_DRM_VIA is not set
+# CONFIG_DRM_SAVAGE is not set
 # CONFIG_RAW_DRIVER is not set
 # CONFIG_HPET is not set
 # CONFIG_HANGCHECK_TIMER is not set
@@ -689,7 +727,6 @@
 # CONFIG_I2C_I801 is not set
 # CONFIG_I2C_I810 is not set
 # CONFIG_I2C_PIIX4 is not set
-# CONFIG_I2C_ISA is not set
 # CONFIG_I2C_NFORCE2 is not set
 # CONFIG_I2C_PARPORT_LIGHT is not set
 # CONFIG_I2C_PROSAVAGE is not set
@@ -703,7 +740,6 @@
 # CONFIG_I2C_VIAPRO is not set
 # CONFIG_I2C_VOODOO3 is not set
 # CONFIG_I2C_PCA_ISA is not set
-# CONFIG_I2C_SENSOR is not set
 
 #
 # Miscellaneous I2C Chip support
@@ -730,12 +766,17 @@
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
 CONFIG_VIDEO_DEV=y
@@ -806,6 +847,7 @@
 # CONFIG_FB_KYRO is not set
 # CONFIG_FB_3DFX is not set
 # CONFIG_FB_VOODOO1 is not set
+# CONFIG_FB_CYBLA is not set
 # CONFIG_FB_TRIDENT is not set
 # CONFIG_FB_PM3 is not set
 # CONFIG_FB_S1D13XXX is not set
@@ -862,11 +904,12 @@
 # CONFIG_SND_MTPAV is not set
 # CONFIG_SND_SERIAL_U16550 is not set
 # CONFIG_SND_MPU401 is not set
+CONFIG_SND_AC97_CODEC=y
+CONFIG_SND_AC97_BUS=y
 
 #
 # PCI devices
 #
-CONFIG_SND_AC97_CODEC=y
 # CONFIG_SND_ALI5451 is not set
 # CONFIG_SND_ATIIXP is not set
 # CONFIG_SND_ATIIXP_MODEM is not set
@@ -890,7 +933,7 @@
 # CONFIG_SND_HDSPM is not set
 # CONFIG_SND_TRIDENT is not set
 # CONFIG_SND_YMFPCI is not set
-# CONFIG_SND_ALS4000 is not set
+# CONFIG_SND_AD1889 is not set
 # CONFIG_SND_CMIPCI is not set
 # CONFIG_SND_ENS1370 is not set
 # CONFIG_SND_ENS1371 is not set
@@ -952,9 +995,8 @@
 #
 # USB Device Class drivers
 #
-# CONFIG_USB_AUDIO is not set
+# CONFIG_OBSOLETE_OSS_USB_DRIVER is not set
 # CONFIG_USB_BLUETOOTH_TTY is not set
-# CONFIG_USB_MIDI is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
 
@@ -971,6 +1013,7 @@
 # CONFIG_USB_STORAGE_SDDR09 is not set
 # CONFIG_USB_STORAGE_SDDR55 is not set
 # CONFIG_USB_STORAGE_JUMPSHOT is not set
+# CONFIG_USB_STORAGE_ONETOUCH is not set
 
 #
 # USB Input Devices
@@ -987,9 +1030,11 @@
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
@@ -1088,10 +1133,6 @@
 # CONFIG_REISERFS_FS is not set
 # CONFIG_JFS_FS is not set
 # CONFIG_FS_POSIX_ACL is not set
-
-#
-# XFS support
-#
 # CONFIG_XFS_FS is not set
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
@@ -1100,6 +1141,7 @@
 CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=y
 # CONFIG_AUTOFS4_FS is not set
+# CONFIG_FUSE_FS is not set
 
 #
 # CD-ROM/DVD Filesystems
@@ -1126,13 +1168,11 @@
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
+# CONFIG_RELAYFS_FS is not set
 
 #
 # Miscellaneous filesystems
@@ -1177,6 +1217,7 @@
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
+# CONFIG_9P_FS is not set
 
 #
 # Partition Types
@@ -1246,10 +1287,12 @@
 # Library routines
 #
 # CONFIG_CRC_CCITT is not set
+# CONFIG_CRC16 is not set
 CONFIG_CRC32=y
 # CONFIG_LIBCRC32C is not set
 CONFIG_GENERIC_HARDIRQS=y
 CONFIG_GENERIC_IRQ_PROBE=y
+CONFIG_GENERIC_PENDING_IRQ=y
 
 #
 # Profiling support
@@ -1263,6 +1306,7 @@
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
 CONFIG_LOG_BUF_SHIFT
+CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set
Index: work-vga2/arch/ia64/configs/bigsur_defconfig
=================================--- work-vga2.orig/arch/ia64/configs/bigsur_defconfig	2005-09-14 16:34:53.000000000 -0600
+++ work-vga2/arch/ia64/configs/bigsur_defconfig	2005-09-14 16:35:14.000000000 -0600
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.10-rc2
-# Mon Nov 29 13:27:48 2004
+# Linux kernel version: 2.6.14-rc1
+# Wed Sep 14 15:18:49 2005
 #
 
 #
@@ -10,34 +10,40 @@
 CONFIG_EXPERIMENTAL=y
 CONFIG_CLEAN_COMPILE=y
 CONFIG_LOCK_KERNEL=y
+CONFIG_INIT_ENV_ARG_LIMIT2
 
 #
 # General setup
 #
 CONFIG_LOCALVERSION=""
+CONFIG_LOCALVERSION_AUTO=y
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
 # CONFIG_BSD_PROCESS_ACCT is not set
 CONFIG_SYSCTL=y
 # CONFIG_AUDIT is not set
-CONFIG_LOG_BUF_SHIFT
 CONFIG_HOTPLUG=y
 CONFIG_KOBJECT_UEVENT=y
 # CONFIG_IKCONFIG is not set
+# CONFIG_CPUSETS is not set
+CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 # CONFIG_KALLSYMS_ALL is not set
 # CONFIG_KALLSYMS_EXTRA_PASS is not set
+CONFIG_PRINTK=y
+CONFIG_BUG=y
+CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
-# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
 CONFIG_SHMEM=y
 CONFIG_CC_ALIGN_FUNCTIONS=0
 CONFIG_CC_ALIGN_LABELS=0
 CONFIG_CC_ALIGN_LOOPS=0
 CONFIG_CC_ALIGN_JUMPS=0
 # CONFIG_TINY_SHMEM is not set
+CONFIG_BASE_SMALL=0
 
 #
 # Loadable module support
@@ -58,12 +64,15 @@
 CONFIG_64BIT=y
 CONFIG_MMU=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
+CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
+CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
 # CONFIG_IA64_GENERIC is not set
 CONFIG_IA64_DIG=y
 # CONFIG_IA64_HP_ZX1 is not set
+# CONFIG_IA64_HP_ZX1_SWIOTLB is not set
 # CONFIG_IA64_SGI_SN2 is not set
 # CONFIG_IA64_HP_SIM is not set
 CONFIG_ITANIUM=y
@@ -72,17 +81,30 @@
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
+# CONFIG_HZ_100 is not set
+CONFIG_HZ_250=y
+# CONFIG_HZ_1000 is not set
+CONFIG_HZ%0
 CONFIG_IA64_BRL_EMU=y
 CONFIG_IA64_L1_CACHE_SHIFT=6
 # CONFIG_NUMA is not set
 # CONFIG_VIRTUAL_MEM_MAP is not set
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
+# CONFIG_IA64_SGI_SN_XP is not set
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUS=2
 # CONFIG_HOTPLUG_CPU is not set
+# CONFIG_SCHED_SMT is not set
 CONFIG_PREEMPT=y
+CONFIG_SELECT_MEMORY_MODEL=y
+CONFIG_FLATMEM_MANUAL=y
+# CONFIG_DISCONTIGMEM_MANUAL is not set
+# CONFIG_SPARSEMEM_MANUAL is not set
+CONFIG_FLATMEM=y
+CONFIG_FLAT_NODE_MEM_MAP=y
+# CONFIG_SPARSEMEM_STATIC is not set
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
@@ -95,6 +117,7 @@
 #
 CONFIG_EFI_VARS=y
 CONFIG_EFI_PCDP=y
+# CONFIG_DELL_RBU is not set
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=m
 
@@ -102,18 +125,26 @@
 # Power management and ACPI
 #
 CONFIG_PM=y
-CONFIG_ACPI=y
+# CONFIG_PM_DEBUG is not set
 
 #
 # ACPI (Advanced Configuration and Power Interface) Support
 #
+CONFIG_ACPI=y
 CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_THERMAL=m
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_SYSTEM=y
+# CONFIG_ACPI_CONTAINER is not set
+
+#
+# CPU Frequency scaling
+#
+# CONFIG_CPU_FREQ is not set
 
 #
 # Bus options (PCI, PCMCIA)
@@ -122,7 +153,7 @@
 CONFIG_PCI_DOMAINS=y
 # CONFIG_PCI_MSI is not set
 CONFIG_PCI_LEGACY_PROC=y
-CONFIG_PCI_NAMES=y
+# CONFIG_PCI_DEBUG is not set
 
 #
 # PCI Hotplug Support
@@ -135,8 +166,70 @@
 # CONFIG_PCCARD is not set
 
 #
-# PC-card bridges
+# Networking
+#
+CONFIG_NET=y
+
+#
+# Networking options
+#
+CONFIG_PACKET=y
+CONFIG_PACKET_MMAP=y
+CONFIG_UNIX=y
+# CONFIG_NET_KEY is not set
+CONFIG_INET=y
+# CONFIG_IP_MULTICAST is not set
+# CONFIG_IP_ADVANCED_ROUTER is not set
+CONFIG_IP_FIB_HASH=y
+# CONFIG_IP_PNP is not set
+# CONFIG_NET_IPIP is not set
+# CONFIG_NET_IPGRE is not set
+# CONFIG_ARPD is not set
+# CONFIG_SYN_COOKIES is not set
+# CONFIG_INET_AH is not set
+# CONFIG_INET_ESP is not set
+# CONFIG_INET_IPCOMP is not set
+# CONFIG_INET_TUNNEL is not set
+CONFIG_INET_DIAG=y
+CONFIG_INET_TCP_DIAG=y
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_BIC=y
+# CONFIG_IPV6 is not set
+# CONFIG_NETFILTER is not set
+
+#
+# DCCP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_DCCP is not set
+
+#
+# SCTP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_SCTP is not set
+# CONFIG_ATM is not set
+# CONFIG_BRIDGE is not set
+# CONFIG_VLAN_8021Q is not set
+# CONFIG_DECNET is not set
+# CONFIG_LLC2 is not set
+# CONFIG_IPX is not set
+# CONFIG_ATALK is not set
+# CONFIG_X25 is not set
+# CONFIG_LAPB is not set
+# CONFIG_NET_DIVERT is not set
+# CONFIG_ECONET is not set
+# CONFIG_WAN_ROUTER is not set
+# CONFIG_NET_SCHED is not set
+# CONFIG_NET_CLS_ROUTE is not set
+
+#
+# Network testing
 #
+# CONFIG_NET_PKTGEN is not set
+# CONFIG_NETFILTER_NETLINK is not set
+# CONFIG_HAMRADIO is not set
+# CONFIG_IRDA is not set
+# CONFIG_BT is not set
+# CONFIG_IEEE80211 is not set
 
 #
 # Device Drivers
@@ -151,6 +244,11 @@
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
@@ -163,7 +261,13 @@
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
@@ -172,14 +276,15 @@
 # CONFIG_BLK_CPQ_CISS_DA is not set
 # CONFIG_BLK_DEV_DAC960 is not set
 # CONFIG_BLK_DEV_UMEM is not set
+# CONFIG_BLK_DEV_COW_COMMON is not set
 CONFIG_BLK_DEV_LOOP=m
 CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 # CONFIG_BLK_DEV_SX8 is not set
 # CONFIG_BLK_DEV_UB is not set
 CONFIG_BLK_DEV_RAM=m
+CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
-CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_CDROM_PKTCDVD is not set
 
 #
@@ -189,6 +294,7 @@
 CONFIG_IOSCHED_AS=y
 CONFIG_IOSCHED_DEADLINE=y
 CONFIG_IOSCHED_CFQ=y
+# CONFIG_ATA_OVER_ETH is not set
 
 #
 # ATA/ATAPI/MFM/RLL support
@@ -211,7 +317,8 @@
 #
 # IDE chipset support/bugfixes
 #
-CONFIG_IDE_GENERIC=m
+# CONFIG_IDE_GENERIC is not set
+# CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
 CONFIG_IDEPCI_SHARE_IRQ=y
 # CONFIG_BLK_DEV_OFFBOARD is not set
@@ -233,6 +340,7 @@
 # CONFIG_BLK_DEV_HPT366 is not set
 # CONFIG_BLK_DEV_SC1200 is not set
 CONFIG_BLK_DEV_PIIX=m
+# CONFIG_BLK_DEV_IT821X is not set
 # CONFIG_BLK_DEV_NS87415 is not set
 # CONFIG_BLK_DEV_PDC202XX_OLD is not set
 # CONFIG_BLK_DEV_PDC202XX_NEW is not set
@@ -250,6 +358,7 @@
 #
 # SCSI device support
 #
+# CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
 CONFIG_SCSI_PROC_FS=y
 
@@ -261,6 +370,7 @@
 # CONFIG_CHR_DEV_OSST is not set
 # CONFIG_BLK_DEV_SR is not set
 # CONFIG_CHR_DEV_SG is not set
+# CONFIG_CHR_DEV_SCH is not set
 
 #
 # Some SCSI devices (e.g. CD jukebox) support multiple LUNs
@@ -274,6 +384,8 @@
 #
 CONFIG_SCSI_SPI_ATTRS=m
 # CONFIG_SCSI_FC_ATTRS is not set
+# CONFIG_SCSI_ISCSI_ATTRS is not set
+# CONFIG_SCSI_SAS_ATTRS is not set
 
 #
 # SCSI low-level drivers
@@ -288,18 +400,13 @@
 # CONFIG_MEGARAID_NEWGEN is not set
 # CONFIG_MEGARAID_LEGACY is not set
 # CONFIG_SCSI_SATA is not set
-# CONFIG_SCSI_BUSLOGIC is not set
 # CONFIG_SCSI_DMX3191D is not set
-# CONFIG_SCSI_EATA is not set
-# CONFIG_SCSI_EATA_PIO is not set
 # CONFIG_SCSI_FUTURE_DOMAIN is not set
-# CONFIG_SCSI_GDTH is not set
 # CONFIG_SCSI_IPS is not set
 # CONFIG_SCSI_INITIO is not set
 # CONFIG_SCSI_INIA100 is not set
 # CONFIG_SCSI_SYM53C8XX_2 is not set
 # CONFIG_SCSI_IPR is not set
-# CONFIG_SCSI_QLOGIC_ISP is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
 # CONFIG_SCSI_QLOGIC_1280_1040 is not set
@@ -309,7 +416,8 @@
 # CONFIG_SCSI_QLA2300 is not set
 # CONFIG_SCSI_QLA2322 is not set
 # CONFIG_SCSI_QLA6312 is not set
-# CONFIG_SCSI_QLA6322 is not set
+# CONFIG_SCSI_QLA24XX is not set
+# CONFIG_SCSI_LPFC is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
 # CONFIG_SCSI_DEBUG is not set
@@ -332,11 +440,14 @@
 CONFIG_DM_SNAPSHOT=m
 CONFIG_DM_MIRROR=m
 CONFIG_DM_ZERO=m
+# CONFIG_DM_MULTIPATH is not set
 
 #
 # Fusion MPT device support
 #
 # CONFIG_FUSION is not set
+# CONFIG_FUSION_SPI is not set
+# CONFIG_FUSION_FC is not set
 
 #
 # IEEE 1394 (FireWire) support
@@ -349,72 +460,14 @@
 # CONFIG_I2O is not set
 
 #
-# Networking support
+# Network device support
 #
-CONFIG_NET=y
-
-#
-# Networking options
-#
-CONFIG_PACKET=y
-CONFIG_PACKET_MMAP=y
-# CONFIG_NETLINK_DEV is not set
-CONFIG_UNIX=y
-# CONFIG_NET_KEY is not set
-CONFIG_INET=y
-# CONFIG_IP_MULTICAST is not set
-# CONFIG_IP_ADVANCED_ROUTER is not set
-# CONFIG_IP_PNP is not set
-# CONFIG_NET_IPIP is not set
-# CONFIG_NET_IPGRE is not set
-# CONFIG_ARPD is not set
-# CONFIG_SYN_COOKIES is not set
-# CONFIG_INET_AH is not set
-# CONFIG_INET_ESP is not set
-# CONFIG_INET_IPCOMP is not set
-# CONFIG_INET_TUNNEL is not set
-CONFIG_IP_TCPDIAG=y
-# CONFIG_IP_TCPDIAG_IPV6 is not set
-# CONFIG_IPV6 is not set
-# CONFIG_NETFILTER is not set
-
-#
-# SCTP Configuration (EXPERIMENTAL)
-#
-# CONFIG_IP_SCTP is not set
-# CONFIG_ATM is not set
-# CONFIG_BRIDGE is not set
-# CONFIG_VLAN_8021Q is not set
-# CONFIG_DECNET is not set
-# CONFIG_LLC2 is not set
-# CONFIG_IPX is not set
-# CONFIG_ATALK is not set
-# CONFIG_X25 is not set
-# CONFIG_LAPB is not set
-# CONFIG_NET_DIVERT is not set
-# CONFIG_ECONET is not set
-# CONFIG_WAN_ROUTER is not set
-
-#
-# QoS and/or fair queueing
-#
-# CONFIG_NET_SCHED is not set
-# CONFIG_NET_CLS_ROUTE is not set
-
-#
-# Network testing
-#
-# CONFIG_NET_PKTGEN is not set
-# CONFIG_NETPOLL is not set
-# CONFIG_NET_POLL_CONTROLLER is not set
-# CONFIG_HAMRADIO is not set
-# CONFIG_IRDA is not set
-# CONFIG_BT is not set
 CONFIG_NETDEVICES=y
 CONFIG_DUMMY=y
 # CONFIG_BONDING is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
+# CONFIG_NET_SB1000 is not set
 
 #
 # ARCnet devices
@@ -422,6 +475,11 @@
 # CONFIG_ARCNET is not set
 
 #
+# PHY device support
+#
+# CONFIG_PHYLIB is not set
+
+#
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=y
@@ -443,7 +501,6 @@
 # CONFIG_FORCEDETH is not set
 # CONFIG_DGRS is not set
 CONFIG_EEPRO100=y
-# CONFIG_EEPRO100_PIO is not set
 # CONFIG_E100 is not set
 # CONFIG_FEALNX is not set
 # CONFIG_NATSEMI is not set
@@ -465,13 +522,17 @@
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
+# CONFIG_SIS190 is not set
+# CONFIG_SKGE is not set
 # CONFIG_SK98LIN is not set
 # CONFIG_VIA_VELOCITY is not set
 # CONFIG_TIGON3 is not set
+# CONFIG_BNX2 is not set
 
 #
 # Ethernet (10000 Mbit)
 #
+# CONFIG_CHELSIO_T1 is not set
 # CONFIG_IXGB is not set
 # CONFIG_S2IO is not set
 
@@ -496,6 +557,8 @@
 # CONFIG_NET_FC is not set
 # CONFIG_SHAPER is not set
 # CONFIG_NETCONSOLE is not set
+# CONFIG_NETPOLL is not set
+# CONFIG_NET_POLL_CONTROLLER is not set
 
 #
 # ISDN subsystem
@@ -525,18 +588,6 @@
 # CONFIG_INPUT_EVBUG is not set
 
 #
-# Input I/O drivers
-#
-# CONFIG_GAMEPORT is not set
-CONFIG_SOUND_GAMEPORT=y
-CONFIG_SERIO=y
-CONFIG_SERIO_I8042=y
-CONFIG_SERIO_SERPORT=y
-# CONFIG_SERIO_CT82C710 is not set
-# CONFIG_SERIO_PCIPS2 is not set
-# CONFIG_SERIO_RAW is not set
-
-#
 # Input Device Drivers
 #
 CONFIG_INPUT_KEYBOARD=y
@@ -554,6 +605,17 @@
 # CONFIG_INPUT_MISC is not set
 
 #
+# Hardware I/O ports
+#
+CONFIG_SERIO=y
+CONFIG_SERIO_I8042=y
+CONFIG_SERIO_SERPORT=y
+# CONFIG_SERIO_PCIPS2 is not set
+CONFIG_SERIO_LIBPS2=y
+# CONFIG_SERIO_RAW is not set
+# CONFIG_GAMEPORT is not set
+
+#
 # Character devices
 #
 CONFIG_VT=y
@@ -571,7 +633,6 @@
 CONFIG_SERIAL_8250_EXTENDED=y
 CONFIG_SERIAL_8250_SHARE_IRQ=y
 # CONFIG_SERIAL_8250_DETECT_IRQ is not set
-# CONFIG_SERIAL_8250_MULTIPORT is not set
 # CONFIG_SERIAL_8250_RSA is not set
 
 #
@@ -579,6 +640,7 @@
 #
 CONFIG_SERIAL_CORE=y
 CONFIG_SERIAL_CORE_CONSOLE=y
+# CONFIG_SERIAL_JSM is not set
 CONFIG_UNIX98_PTYS=y
 CONFIG_LEGACY_PTYS=y
 CONFIG_LEGACY_PTY_COUNT%6
@@ -603,14 +665,22 @@
 #
 CONFIG_AGP=m
 CONFIG_AGP_I460=m
-CONFIG_DRM=y
+CONFIG_DRM=m
 # CONFIG_DRM_TDFX is not set
 CONFIG_DRM_R128=m
 # CONFIG_DRM_RADEON is not set
 # CONFIG_DRM_MGA is not set
 # CONFIG_DRM_SIS is not set
+# CONFIG_DRM_VIA is not set
+# CONFIG_DRM_SAVAGE is not set
 # CONFIG_RAW_DRIVER is not set
 # CONFIG_HPET is not set
+# CONFIG_HANGCHECK_TIMER is not set
+
+#
+# TPM devices
+#
+# CONFIG_TCG_TPM is not set
 
 #
 # I2C support
@@ -635,7 +705,7 @@
 # CONFIG_I2C_AMD8111 is not set
 # CONFIG_I2C_I801 is not set
 # CONFIG_I2C_I810 is not set
-# CONFIG_I2C_ISA is not set
+# CONFIG_I2C_PIIX4 is not set
 # CONFIG_I2C_NFORCE2 is not set
 # CONFIG_I2C_PARPORT_LIGHT is not set
 # CONFIG_I2C_PROSAVAGE is not set
@@ -651,16 +721,43 @@
 # CONFIG_I2C_PCA_ISA is not set
 
 #
-# Hardware Sensors Chip support
+# Miscellaneous I2C Chip support
 #
-# CONFIG_I2C_SENSOR is not set
+# CONFIG_SENSORS_DS1337 is not set
+# CONFIG_SENSORS_DS1374 is not set
+# CONFIG_SENSORS_EEPROM is not set
+# CONFIG_SENSORS_PCF8574 is not set
+# CONFIG_SENSORS_PCA9539 is not set
+# CONFIG_SENSORS_PCF8591 is not set
+# CONFIG_SENSORS_RTC8564 is not set
+# CONFIG_SENSORS_MAX6875 is not set
+# CONFIG_I2C_DEBUG_CORE is not set
+# CONFIG_I2C_DEBUG_ALGO is not set
+# CONFIG_I2C_DEBUG_BUS is not set
+# CONFIG_I2C_DEBUG_CHIP is not set
+
+#
+# Dallas's 1-wire bus
+#
+# CONFIG_W1 is not set
+
+#
+# Hardware Monitoring support
+#
+CONFIG_HWMON=y
+# CONFIG_HWMON_VID is not set
 # CONFIG_SENSORS_ADM1021 is not set
 # CONFIG_SENSORS_ADM1025 is not set
+# CONFIG_SENSORS_ADM1026 is not set
 # CONFIG_SENSORS_ADM1031 is not set
+# CONFIG_SENSORS_ADM9240 is not set
 # CONFIG_SENSORS_ASB100 is not set
+# CONFIG_SENSORS_ATXP1 is not set
 # CONFIG_SENSORS_DS1621 is not set
 # CONFIG_SENSORS_FSCHER is not set
+# CONFIG_SENSORS_FSCPOS is not set
 # CONFIG_SENSORS_GL518SM is not set
+# CONFIG_SENSORS_GL520SM is not set
 # CONFIG_SENSORS_IT87 is not set
 # CONFIG_SENSORS_LM63 is not set
 # CONFIG_SENSORS_LM75 is not set
@@ -671,33 +768,26 @@
 # CONFIG_SENSORS_LM85 is not set
 # CONFIG_SENSORS_LM87 is not set
 # CONFIG_SENSORS_LM90 is not set
+# CONFIG_SENSORS_LM92 is not set
 # CONFIG_SENSORS_MAX1619 is not set
 # CONFIG_SENSORS_PC87360 is not set
+# CONFIG_SENSORS_SIS5595 is not set
 # CONFIG_SENSORS_SMSC47M1 is not set
+# CONFIG_SENSORS_SMSC47B397 is not set
 # CONFIG_SENSORS_VIA686A is not set
 # CONFIG_SENSORS_W83781D is not set
+# CONFIG_SENSORS_W83792D is not set
 # CONFIG_SENSORS_W83L785TS is not set
 # CONFIG_SENSORS_W83627HF is not set
+# CONFIG_SENSORS_W83627EHF is not set
+# CONFIG_HWMON_DEBUG_CHIP is not set
 
 #
-# Other I2C Chip support
-#
-# CONFIG_SENSORS_EEPROM is not set
-# CONFIG_SENSORS_PCF8574 is not set
-# CONFIG_SENSORS_PCF8591 is not set
-# CONFIG_SENSORS_RTC8564 is not set
-# CONFIG_I2C_DEBUG_CORE is not set
-# CONFIG_I2C_DEBUG_ALGO is not set
-# CONFIG_I2C_DEBUG_BUS is not set
-# CONFIG_I2C_DEBUG_CHIP is not set
-
-#
-# Dallas's 1-wire bus
+# Misc devices
 #
-# CONFIG_W1 is not set
 
 #
-# Misc devices
+# Multimedia Capabilities Port drivers
 #
 
 #
@@ -752,11 +842,12 @@
 # CONFIG_SND_MTPAV is not set
 # CONFIG_SND_SERIAL_U16550 is not set
 # CONFIG_SND_MPU401 is not set
+CONFIG_SND_AC97_CODEC=m
+CONFIG_SND_AC97_BUS=m
 
 #
 # PCI devices
 #
-CONFIG_SND_AC97_CODEC=m
 # CONFIG_SND_ALI5451 is not set
 # CONFIG_SND_ATIIXP is not set
 # CONFIG_SND_ATIIXP_MODEM is not set
@@ -768,6 +859,8 @@
 # CONFIG_SND_CS46XX is not set
 CONFIG_SND_CS4281=m
 # CONFIG_SND_EMU10K1 is not set
+# CONFIG_SND_EMU10K1X is not set
+# CONFIG_SND_CA0106 is not set
 # CONFIG_SND_KORG1212 is not set
 # CONFIG_SND_MIXART is not set
 # CONFIG_SND_NM256 is not set
@@ -775,9 +868,10 @@
 # CONFIG_SND_RME96 is not set
 # CONFIG_SND_RME9652 is not set
 # CONFIG_SND_HDSP is not set
+# CONFIG_SND_HDSPM is not set
 # CONFIG_SND_TRIDENT is not set
 # CONFIG_SND_YMFPCI is not set
-# CONFIG_SND_ALS4000 is not set
+# CONFIG_SND_AD1889 is not set
 # CONFIG_SND_CMIPCI is not set
 # CONFIG_SND_ENS1370 is not set
 # CONFIG_SND_ENS1371 is not set
@@ -791,13 +885,14 @@
 # CONFIG_SND_INTEL8X0M is not set
 # CONFIG_SND_SONICVIBES is not set
 # CONFIG_SND_VIA82XX is not set
+# CONFIG_SND_VIA82XX_MODEM is not set
 # CONFIG_SND_VX222 is not set
+# CONFIG_SND_HDA_INTEL is not set
 
 #
 # USB devices
 #
 # CONFIG_SND_USB_AUDIO is not set
-# CONFIG_SND_USB_USX2Y is not set
 
 #
 # Open Sound System
@@ -807,6 +902,8 @@
 #
 # USB support
 #
+CONFIG_USB_ARCH_HAS_HCD=y
+CONFIG_USB_ARCH_HAS_OHCI=y
 CONFIG_USB=m
 # CONFIG_USB_DEBUG is not set
 
@@ -818,35 +915,38 @@
 # CONFIG_USB_DYNAMIC_MINORS is not set
 # CONFIG_USB_SUSPEND is not set
 # CONFIG_USB_OTG is not set
-CONFIG_USB_ARCH_HAS_HCD=y
-CONFIG_USB_ARCH_HAS_OHCI=y
 
 #
 # USB Host Controller Drivers
 #
 # CONFIG_USB_EHCI_HCD is not set
+# CONFIG_USB_ISP116X_HCD is not set
 # CONFIG_USB_OHCI_HCD is not set
 CONFIG_USB_UHCI_HCD=m
+# CONFIG_USB_SL811_HCD is not set
 
 #
 # USB Device Class drivers
 #
-CONFIG_USB_AUDIO=m
+# CONFIG_OBSOLETE_OSS_USB_DRIVER is not set
 CONFIG_USB_BLUETOOTH_TTY=m
-CONFIG_USB_MIDI=m
 CONFIG_USB_ACM=m
 CONFIG_USB_PRINTER=m
+
+#
+# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be needed; see USB_STORAGE Help for more information
+#
 CONFIG_USB_STORAGE=m
 # CONFIG_USB_STORAGE_DEBUG is not set
-# CONFIG_USB_STORAGE_RW_DETECT is not set
 # CONFIG_USB_STORAGE_DATAFAB is not set
 # CONFIG_USB_STORAGE_FREECOM is not set
 # CONFIG_USB_STORAGE_ISD200 is not set
 # CONFIG_USB_STORAGE_DPCM is not set
-# CONFIG_USB_STORAGE_HP8200e is not set
+# CONFIG_USB_STORAGE_USBAT is not set
 # CONFIG_USB_STORAGE_SDDR09 is not set
 # CONFIG_USB_STORAGE_SDDR55 is not set
 # CONFIG_USB_STORAGE_JUMPSHOT is not set
+# CONFIG_USB_STORAGE_ONETOUCH is not set
 
 #
 # USB Input Devices
@@ -863,19 +963,23 @@
 # CONFIG_USB_MOUSE is not set
 # CONFIG_USB_AIPTEK is not set
 # CONFIG_USB_WACOM is not set
+# CONFIG_USB_ACECAD is not set
 # CONFIG_USB_KBTAB is not set
 # CONFIG_USB_POWERMATE is not set
 # CONFIG_USB_MTOUCH is not set
+# CONFIG_USB_ITMTOUCH is not set
 # CONFIG_USB_EGALAX is not set
+# CONFIG_USB_YEALINK is not set
 # CONFIG_USB_XPAD is not set
 # CONFIG_USB_ATI_REMOTE is not set
+# CONFIG_USB_KEYSPAN_REMOTE is not set
+# CONFIG_USB_APPLETOUCH is not set
 
 #
 # USB Imaging devices
 #
 # CONFIG_USB_MDC800 is not set
 # CONFIG_USB_MICROTEK is not set
-# CONFIG_USB_HPUSBSCSI is not set
 
 #
 # USB Multimedia devices
@@ -894,6 +998,7 @@
 # CONFIG_USB_PEGASUS is not set
 # CONFIG_USB_RTL8150 is not set
 # CONFIG_USB_USBNET is not set
+CONFIG_USB_MON=y
 
 #
 # USB port drivers
@@ -909,7 +1014,6 @@
 #
 # CONFIG_USB_EMI62 is not set
 # CONFIG_USB_EMI26 is not set
-# CONFIG_USB_TIGL is not set
 # CONFIG_USB_AUERSWALD is not set
 # CONFIG_USB_RIO500 is not set
 # CONFIG_USB_LEGOTOWER is not set
@@ -918,10 +1022,12 @@
 # CONFIG_USB_CYTHERM is not set
 # CONFIG_USB_PHIDGETKIT is not set
 # CONFIG_USB_PHIDGETSERVO is not set
+# CONFIG_USB_IDMOUSE is not set
+# CONFIG_USB_LD is not set
 # CONFIG_USB_TEST is not set
 
 #
-# USB ATM/DSL drivers
+# USB DSL modem support
 #
 
 #
@@ -930,10 +1036,25 @@
 # CONFIG_USB_GADGET is not set
 
 #
+# MMC/SD Card support
+#
+# CONFIG_MMC is not set
+
+#
+# InfiniBand support
+#
+# CONFIG_INFINIBAND is not set
+
+#
+# SN Devices
+#
+
+#
 # File systems
 #
 CONFIG_EXT2_FS=y
 # CONFIG_EXT2_FS_XATTR is not set
+# CONFIG_EXT2_FS_XIP is not set
 CONFIG_EXT3_FS=y
 CONFIG_EXT3_FS_XATTR=y
 # CONFIG_EXT3_FS_POSIX_ACL is not set
@@ -945,17 +1066,20 @@
 # CONFIG_JFS_FS is not set
 CONFIG_FS_POSIX_ACL=y
 CONFIG_XFS_FS=y
-# CONFIG_XFS_RT is not set
+CONFIG_XFS_EXPORT=y
 CONFIG_XFS_QUOTA=y
 CONFIG_XFS_SECURITY=y
 CONFIG_XFS_POSIX_ACL=y
+# CONFIG_XFS_RT is not set
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
+CONFIG_INOTIFY=y
 # CONFIG_QUOTA is not set
 CONFIG_QUOTACTL=y
 CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=m
 CONFIG_AUTOFS4_FS=m
+# CONFIG_FUSE_FS is not set
 
 #
 # CD-ROM/DVD Filesystems
@@ -982,14 +1106,11 @@
 CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
-# CONFIG_DEVFS_FS is not set
-CONFIG_DEVPTS_FS_XATTR=y
-CONFIG_DEVPTS_FS_SECURITY=y
 CONFIG_TMPFS=y
-# CONFIG_TMPFS_XATTR is not set
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
+# CONFIG_RELAYFS_FS is not set
 
 #
 # Miscellaneous filesystems
@@ -1013,15 +1134,18 @@
 #
 CONFIG_NFS_FS=m
 CONFIG_NFS_V3=y
+# CONFIG_NFS_V3_ACL is not set
 CONFIG_NFS_V4=y
 # CONFIG_NFS_DIRECTIO is not set
 CONFIG_NFSD=m
 CONFIG_NFSD_V3=y
+# CONFIG_NFSD_V3_ACL is not set
 CONFIG_NFSD_V4=y
 CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=m
 CONFIG_LOCKD_V4=y
-CONFIG_EXPORTFS=m
+CONFIG_EXPORTFS=y
+CONFIG_NFS_COMMON=y
 CONFIG_SUNRPC=m
 CONFIG_SUNRPC_GSS=m
 CONFIG_RPCSEC_GSS_KRB5=m
@@ -1031,9 +1155,11 @@
 CONFIG_CIFS_STATS=y
 CONFIG_CIFS_XATTR=y
 CONFIG_CIFS_POSIX=y
+# CONFIG_CIFS_EXPERIMENTAL is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
+# CONFIG_9P_FS is not set
 
 #
 # Partition Types
@@ -1103,8 +1229,12 @@
 # Library routines
 #
 # CONFIG_CRC_CCITT is not set
+# CONFIG_CRC16 is not set
 CONFIG_CRC32=y
 # CONFIG_LIBCRC32C is not set
+CONFIG_GENERIC_HARDIRQS=y
+CONFIG_GENERIC_IRQ_PROBE=y
+CONFIG_GENERIC_PENDING_IRQ=y
 
 #
 # Profiling support
@@ -1115,14 +1245,20 @@
 #
 # Kernel hacking
 #
+# CONFIG_PRINTK_TIME is not set
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
+CONFIG_LOG_BUF_SHIFT
+CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
+CONFIG_DEBUG_PREEMPT=y
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
 # CONFIG_DEBUG_KOBJECT is not set
 # CONFIG_DEBUG_INFO is not set
+# CONFIG_DEBUG_FS is not set
+# CONFIG_KPROBES is not set
 # CONFIG_IA64_GRANULE_16MB is not set
 CONFIG_IA64_GRANULE_64MB=y
 # CONFIG_IA64_PRINT_HAZARDS is not set
@@ -1149,6 +1285,7 @@
 # CONFIG_CRYPTO_SHA256 is not set
 # CONFIG_CRYPTO_SHA512 is not set
 # CONFIG_CRYPTO_WP512 is not set
+# CONFIG_CRYPTO_TGR192 is not set
 CONFIG_CRYPTO_DES=y
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set
@@ -1164,3 +1301,7 @@
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_CRC32C is not set
 # CONFIG_CRYPTO_TEST is not set
+
+#
+# Hardware crypto devices
+#
Index: work-vga2/arch/ia64/configs/tiger_defconfig
=================================--- work-vga2.orig/arch/ia64/configs/tiger_defconfig	2005-09-14 16:34:53.000000000 -0600
+++ work-vga2/arch/ia64/configs/tiger_defconfig	2005-09-14 16:35:14.000000000 -0600
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.13-rc6-tiger-smp
-# Wed Aug 17 10:19:51 2005
+# Linux kernel version: 2.6.14-rc1
+# Wed Sep 14 15:17:57 2005
 #
 
 #
@@ -16,6 +16,7 @@
 # General setup
 #
 CONFIG_LOCALVERSION=""
+CONFIG_LOCALVERSION_AUTO=y
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
@@ -27,6 +28,7 @@
 CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 # CONFIG_CPUSETS is not set
+CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 CONFIG_KALLSYMS_ALL=y
@@ -103,6 +105,7 @@
 # CONFIG_SPARSEMEM_MANUAL is not set
 CONFIG_FLATMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
+# CONFIG_SPARSEMEM_STATIC is not set
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
@@ -115,6 +118,7 @@
 #
 CONFIG_EFI_VARS=y
 CONFIG_EFI_PCDP=y
+# CONFIG_DELL_RBU is not set
 CONFIG_BINFMT_ELF=y
 CONFIG_BINFMT_MISC=m
 
@@ -122,20 +126,27 @@
 # Power management and ACPI
 #
 CONFIG_PM=y
-CONFIG_ACPI=y
+# CONFIG_PM_DEBUG is not set
 
 #
 # ACPI (Advanced Configuration and Power Interface) Support
 #
+CONFIG_ACPI=y
 CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
-# CONFIG_ACPI_HOTPLUG_CPU is not set
+CONFIG_ACPI_HOTPLUG_CPU=y
 CONFIG_ACPI_THERMAL=m
+CONFIG_ACPI_BLACKLIST_YEAR=0
 # CONFIG_ACPI_DEBUG is not set
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_SYSTEM=y
-# CONFIG_ACPI_CONTAINER is not set
+CONFIG_ACPI_CONTAINER=m
+
+#
+# CPU Frequency scaling
+#
+# CONFIG_CPU_FREQ is not set
 
 #
 # Bus options (PCI, PCMCIA)
@@ -144,7 +155,6 @@
 CONFIG_PCI_DOMAINS=y
 # CONFIG_PCI_MSI is not set
 CONFIG_PCI_LEGACY_PROC=y
-CONFIG_PCI_NAMES=y
 # CONFIG_PCI_DEBUG is not set
 
 #
@@ -188,14 +198,19 @@
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_TUNNEL is not set
-CONFIG_IP_TCPDIAG=y
-# CONFIG_IP_TCPDIAG_IPV6 is not set
+CONFIG_INET_DIAG=y
+CONFIG_INET_TCP_DIAG=y
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_BIC=y
 # CONFIG_IPV6 is not set
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
@@ -218,9 +233,11 @@
 # Network testing
 #
 # CONFIG_NET_PKTGEN is not set
+# CONFIG_NETFILTER_NETLINK is not set
 # CONFIG_HAMRADIO is not set
 # CONFIG_IRDA is not set
 # CONFIG_BT is not set
+# CONFIG_IEEE80211 is not set
 
 #
 # Device Drivers
@@ -235,6 +252,11 @@
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
@@ -247,7 +269,13 @@
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
@@ -266,7 +294,6 @@
 CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
 CONFIG_BLK_DEV_INITRD=y
-CONFIG_INITRAMFS_SOURCE=""
 # CONFIG_CDROM_PKTCDVD is not set
 
 #
@@ -299,7 +326,8 @@
 #
 # IDE chipset support/bugfixes
 #
-CONFIG_IDE_GENERIC=y
+# CONFIG_IDE_GENERIC is not set
+# CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
 # CONFIG_IDEPCI_SHARE_IRQ is not set
 # CONFIG_BLK_DEV_OFFBOARD is not set
@@ -339,6 +367,7 @@
 #
 # SCSI device support
 #
+# CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
 CONFIG_SCSI_PROC_FS=y
 
@@ -366,6 +395,7 @@
 CONFIG_SCSI_SPI_ATTRS=y
 CONFIG_SCSI_FC_ATTRS=y
 # CONFIG_SCSI_ISCSI_ATTRS is not set
+# CONFIG_SCSI_SAS_ATTRS is not set
 
 #
 # SCSI low-level drivers
@@ -454,6 +484,7 @@
 # CONFIG_BONDING is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
+# CONFIG_NET_SB1000 is not set
 
 #
 # ARCnet devices
@@ -461,6 +492,11 @@
 # CONFIG_ARCNET is not set
 
 #
+# PHY device support
+#
+# CONFIG_PHYLIB is not set
+
+#
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=y
@@ -481,6 +517,7 @@
 # CONFIG_DE4X5 is not set
 # CONFIG_WINBOND_840 is not set
 # CONFIG_DM9102 is not set
+# CONFIG_ULI526X is not set
 # CONFIG_HP100 is not set
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
@@ -512,6 +549,7 @@
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
+# CONFIG_SIS190 is not set
 # CONFIG_SKGE is not set
 # CONFIG_SK98LIN is not set
 # CONFIG_VIA_VELOCITY is not set
@@ -521,6 +559,7 @@
 #
 # Ethernet (10000 Mbit)
 #
+# CONFIG_CHELSIO_T1 is not set
 # CONFIG_IXGB is not set
 # CONFIG_S2IO is not set
 
@@ -618,6 +657,7 @@
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
 # CONFIG_CYCLADES is not set
+# CONFIG_DIGIEPCA is not set
 # CONFIG_MOXA_SMARTIO is not set
 # CONFIG_ISI is not set
 # CONFIG_SYNCLINKMP is not set
@@ -675,6 +715,7 @@
 CONFIG_DRM_MGA=m
 CONFIG_DRM_SIS=m
 # CONFIG_DRM_VIA is not set
+# CONFIG_DRM_SAVAGE is not set
 CONFIG_RAW_DRIVER=m
 CONFIG_HPET=y
 # CONFIG_HPET_RTC_IRQ is not set
@@ -691,7 +732,6 @@
 # I2C support
 #
 # CONFIG_I2C is not set
-# CONFIG_I2C_SENSOR is not set
 
 #
 # Dallas's 1-wire bus
@@ -702,6 +742,7 @@
 # Hardware Monitoring support
 #
 CONFIG_HWMON=y
+# CONFIG_HWMON_VID is not set
 # CONFIG_HWMON_DEBUG_CHIP is not set
 
 #
@@ -709,6 +750,10 @@
 #
 
 #
+# Multimedia Capabilities Port drivers
+#
+
+#
 # Multimedia devices
 #
 # CONFIG_VIDEO_DEV is not set
@@ -800,9 +845,11 @@
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
@@ -902,16 +949,12 @@
 CONFIG_REISERFS_FS_SECURITY=y
 # CONFIG_JFS_FS is not set
 CONFIG_FS_POSIX_ACL=y
-
-#
-# XFS support
-#
 CONFIG_XFS_FS=y
 CONFIG_XFS_EXPORT=y
-# CONFIG_XFS_RT is not set
 # CONFIG_XFS_QUOTA is not set
 # CONFIG_XFS_SECURITY is not set
 # CONFIG_XFS_POSIX_ACL is not set
+# CONFIG_XFS_RT is not set
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
 CONFIG_INOTIFY=y
@@ -919,6 +962,7 @@
 CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=y
 CONFIG_AUTOFS4_FS=y
+# CONFIG_FUSE_FS is not set
 
 #
 # CD-ROM/DVD Filesystems
@@ -947,13 +991,11 @@
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
+# CONFIG_RELAYFS_FS is not set
 
 #
 # Miscellaneous filesystems
@@ -1003,6 +1045,7 @@
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
+# CONFIG_9P_FS is not set
 
 #
 # Partition Types
@@ -1072,10 +1115,12 @@
 # Library routines
 #
 # CONFIG_CRC_CCITT is not set
+# CONFIG_CRC16 is not set
 CONFIG_CRC32=y
 # CONFIG_LIBCRC32C is not set
 CONFIG_GENERIC_HARDIRQS=y
 CONFIG_GENERIC_IRQ_PROBE=y
+CONFIG_GENERIC_PENDING_IRQ=y
 
 #
 # Profiling support
@@ -1089,6 +1134,7 @@
 CONFIG_DEBUG_KERNEL=y
 CONFIG_MAGIC_SYSRQ=y
 CONFIG_LOG_BUF_SHIFT 
+CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set

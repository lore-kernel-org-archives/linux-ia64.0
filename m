From: "Yu, Luming" <luming.yu@intel.com>
Date: Fri, 24 Oct 2003 11:02:16 +0000
Subject: Mosberger Tree (2.6 IA64) + ACPI Testing  Report (boot fine)
Message-Id: <marc-linux-ia64-106699339104037@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Today I pulled change sets from http://lia64.bkbits.net/linux-ia64-2.5 and  http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 . 
Boot fine on lion.

Cheers,
Luming

Testing Report  detail:

============Hardware Configuration:
--------------------------------------------
System Name: acpi-lion

System Type: 4 way 800M Itanium, Lion

M/B revision: N/a 

Processor version: model 0, revision 6

Firmware Versions: EFI v1.02

I/O configuration (lspci):

00:03.0 ISA bridge: Intel Corp. 82372FB PIIX5 ISA (rev 01)
00:03.1 IDE interface: Intel Corp. 82372FB PIIX5 IDE (rev 01)
00:03.2 USB Controller: Intel Corp. 82372FB PIIX5 USB (rev 01)
00:03.3 SMBus: Intel Corp. 82372FB PIIX5 SMBus (rev 01)
00:04.0 PIC: Intel Corp. 683053 Programmable Interrupt Device (rev 01)
00:05.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)
00:06.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
00:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
01:02.0 SCSI storage controller: QLogic Corp. ISP12160 Dual Channel Ultra3 SCSI Processor (rev 06)
01:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
04:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
08:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
0c:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
0f:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
12:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
15:00.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:00.1 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:00.2 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:00.3 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:00.4 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:00.5 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:00.6 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:00.7 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.1 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.2 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.3 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.4 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.5 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.6 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:01.7 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:04.0 Host bridge: Intel Corp. 460GX - 84460GX System Data Controller (SDC) (rev 03)
15:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:10.1 Host bridge: Intel Corp. 450NX - 82454NX/84460GX PCI Expander Bridge (rev 05)
15:11.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:12.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:12.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
15:13.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:13.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
15:14.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:14.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
15:15.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:15.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
15:16.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:16.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
15:17.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
15:17.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)

==========Software Configuration:
------------------------------------

kernel tree version
2.6.0-test8

patches applied on top of kernel
bk pulled from http://lia64.bkbits.net/linux-ia64-2.5

==============ACPI Features Tested: (prioritized).
-------------------------------------------------

1. System Boot  fine

=============.config file
----------------------------------------------
#
# Automatically generated make config: don't edit
#

#
# Code maturity level options
#
CONFIG_EXPERIMENTAL=y
CONFIG_CLEAN_COMPILE=y
CONFIG_STANDALONE=y

#
# General setup
#
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_SYSCTL=y
CONFIG_LOG_BUF_SHIFT
# CONFIG_IKCONFIG is not set
# CONFIG_EMBEDDED is not set
CONFIG_KALLSYMS=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y

#
# Loadable module support
#
CONFIG_MODULES=y
# CONFIG_MODULE_UNLOAD is not set
CONFIG_OBSOLETE_MODPARM=y
CONFIG_MODVERSIONS=y
CONFIG_KMOD=y

#
# Processor type and features
#
CONFIG_IA64=y
CONFIG_64BIT=y
CONFIG_MMU=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_TIME_INTERPOLATION=y
CONFIG_ITANIUM=y
# CONFIG_MCKINLEY is not set
# CONFIG_IA64_GENERIC is not set
CONFIG_IA64_DIG=y
# CONFIG_IA64_HP_SIM is not set
# CONFIG_IA64_HP_ZX1 is not set
# CONFIG_IA64_SGI_SN2 is not set
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
CONFIG_IA64_PAGE_SIZE_16KB=y
# CONFIG_IA64_PAGE_SIZE_64KB is not set
CONFIG_ACPI=y
CONFIG_ACPI_EFI=y
CONFIG_ACPI_INTERPRETER=y
CONFIG_ACPI_KERNEL_CONFIG=y
CONFIG_IA64_BRL_EMU=y
# CONFIG_ITANIUM_BSTEP_SPECIFIC is not set
CONFIG_IA64_L1_CACHE_SHIFT=6
# CONFIG_NUMA is not set
CONFIG_VIRTUAL_MEM_MAP=y
# CONFIG_IA64_MCA is not set
CONFIG_PM=y
CONFIG_IOSAPIC=y
CONFIG_FORCE_MAX_ZONEORDER
# CONFIG_IA64_PAL_IDLE is not set
CONFIG_SMP=y
# CONFIG_PREEMPT is not set
CONFIG_IA32_SUPPORT=y
CONFIG_COMPAT=y
# CONFIG_PERFMON is not set
CONFIG_IA64_PALINFO=y
# CONFIG_IA64_SALINFO is not set
CONFIG_EFI_VARS=y
CONFIG_NR_CPUSd
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_MISC=y

#
# ACPI (Advanced Configuration and Power Interface) Support
#
CONFIG_ACPI_BOOT=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_BUS=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_PCI=y
CONFIG_ACPI_SYSTEM=y
CONFIG_ACPI_RELAXED_AML=y
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_LEGACY_PROC is not set
CONFIG_PCI_NAMES=y
# CONFIG_HOTPLUG is not set

#
# Parallel port support
#
# CONFIG_PARPORT is not set

#
# Generic Driver Options
#

#
# Memory Technology Devices (MTD)
#
# CONFIG_MTD is not set

#
# Plug and Play support
#
# CONFIG_PNP is not set

#
# Block devices
#
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=y
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_BLK_DEV_INITRD is not set

#
# ATA/ATAPI/MFM/RLL support
#
CONFIG_IDE=y
CONFIG_BLK_DEV_IDE=y

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_IDEDISK is not set
# CONFIG_BLK_DEV_IDECD is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEFLOPPY is not set
# CONFIG_BLK_DEV_IDESCSI is not set
# CONFIG_IDE_TASK_IOCTL is not set
# CONFIG_IDE_TASKFILE_IO is not set

#
# IDE chipset support/bugfixes
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_IDE_TCQ is not set
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
# CONFIG_IDEDMA_PCI_AUTO is not set
# CONFIG_IDEDMA_PCI_WIP is not set
CONFIG_BLK_DEV_ADMA=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_IDEDMA=y
# CONFIG_IDEDMA_IVB is not set
# CONFIG_IDEDMA_AUTO is not set
# CONFIG_DMA_NONPCI is not set
# CONFIG_BLK_DEV_HD is not set

#
# IEEE 1394 (FireWire) support (EXPERIMENTAL)
#
# CONFIG_IEEE1394 is not set

#
# I2O device support
#
# CONFIG_I2O is not set

#
# Multi-device support (RAID and LVM)
#
# CONFIG_MD is not set

#
# Fusion MPT device support
#
CONFIG_FUSION=y
CONFIG_FUSION_BOOT=y
CONFIG_FUSION_MAX_SGE@
# CONFIG_FUSION_ISENSE is not set
# CONFIG_FUSION_CTL is not set

#
# SCSI device support
#
CONFIG_SCSI=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_REPORT_LUNS=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y

#
# SCSI low-level drivers
#
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_MEGARAID is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_CPQFCTS is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_EATA_PIO is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_QLOGIC_ISP is not set
# CONFIG_SCSI_QLOGIC_FC is not set
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_DEBUG is not set

#
# Networking support
#
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
# CONFIG_NETLINK_DEV is not set
CONFIG_UNIX=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
# CONFIG_INET_ECN is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_IPV6 is not set
# CONFIG_DECNET is not set
# CONFIG_BRIDGE is not set
# CONFIG_NETFILTER is not set

#
# SCTP Configuration (EXPERIMENTAL)
#
CONFIG_IPV6_SCTP__=y
# CONFIG_IP_SCTP is not set
# CONFIG_ATM is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_NET_DIVERT is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_NET_FASTROUTE is not set
# CONFIG_NET_HW_FLOWCONTROL is not set

#
# QoS and/or fair queueing
#
# CONFIG_NET_SCHED is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_NETDEVICES=y

#
# ARCnet devices
#
# CONFIG_ARCNET is not set
CONFIG_DUMMY=y
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set

#
# Ethernet (10 or 100Mbit)
#
CONFIG_NET_ETHERNET=y
CONFIG_MII=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_NET_VENDOR_3COM is not set

#
# Tulip family network device support
#
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_B44 is not set
# CONFIG_DGRS is not set
CONFIG_EEPRO100=y
# CONFIG_EEPRO100_PIO is not set
# CONFIG_E100 is not set
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_VIA_RHINE is not set

#
# Ethernet (1000 Mbit)
#
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
CONFIG_E1000=y
# CONFIG_E1000_NAPI is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SK98LIN is not set
# CONFIG_TIGON3 is not set

#
# Ethernet (10000 Mbit)
#
# CONFIG_IXGB is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Wireless LAN (non-hamradio)
#
# CONFIG_NET_RADIO is not set

#
# Token Ring devices
#
# CONFIG_TR is not set
# CONFIG_NET_FC is not set
# CONFIG_SHAPER is not set

#
# Wan interfaces
#
# CONFIG_WAN is not set

#
# Amateur Radio support
#
# CONFIG_HAMRADIO is not set

#
# IrDA (infrared) support
#
# CONFIG_IRDA is not set

#
# Bluetooth support
#
# CONFIG_BT is not set

#
# ISDN subsystem
#
# CONFIG_ISDN_BOOL is not set

#
# Input device support
#
CONFIG_INPUT=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X24
CONFIG_INPUT_MOUSEDEV_SCREEN_Yv8
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_TSDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input I/O drivers
#
# CONFIG_GAMEPORT is not set
CONFIG_SOUND_GAMEPORT=y
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PCIPS2=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
# CONFIG_MOUSE_PS2_SYNAPTICS is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_SERIAL_NONSTANDARD is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_ACPI=y
# CONFIG_SERIAL_8250_HCDP is not set
CONFIG_SERIAL_8250_NR_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_UNIX98_PTYS=y
CONFIG_UNIX98_PTY_COUNT%6

#
# I2C support
#
# CONFIG_I2C is not set

#
# I2C Algorithms
#

#
# I2C Hardware Bus support
#

#
# I2C Hardware Sensors Chip support
#
# CONFIG_I2C_SENSOR is not set

#
# Mice
#
# CONFIG_BUSMOUSE is not set
# CONFIG_QIC02_TAPE is not set

#
# IPMI
#
# CONFIG_IPMI_HANDLER is not set

#
# Watchdog Cards
#
# CONFIG_WATCHDOG is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_GEN_RTC is not set
CONFIG_EFI_RTC=y
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# Ftape, the floppy tape device driver
#
# CONFIG_AGP is not set
# CONFIG_DRM is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS%6

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set

#
# Digital Video Broadcasting Devices
#
# CONFIG_DVB is not set

#
# File systems
#
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
# CONFIG_EXT3_FS_POSIX_ACL is not set
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_QUOTA is not set
CONFIG_AUTOFS_FS=y
# CONFIG_AUTOFS4_FS is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
# CONFIG_DEVFS_FS is not set
CONFIG_DEVPTS_FS=y
# CONFIG_DEVPTS_FS_XATTR is not set
# CONFIG_TMPFS is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_RAMFS=y

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
# CONFIG_NFS_FS is not set
# CONFIG_NFSD is not set
# CONFIG_EXPORTFS is not set
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_INTERMEZZO_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_NEC98_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
CONFIG_EFI_PARTITION=y
CONFIG_NLS=y

#
# Native Language Support
#
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_UTF8 is not set

#
# Graphics support
#
# CONFIG_FB is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_MDA_CONSOLE is not set
CONFIG_DUMMY_CONSOLE=y

#
# Sound
#
# CONFIG_SOUND is not set

#
# USB support
#
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_BANDWIDTH is not set
# CONFIG_USB_DYNAMIC_MINORS is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
# CONFIG_USB_UHCI_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_BLUETOOTH_TTY is not set
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_STORAGE is not set

#
# USB Human Interface Devices (HID)
#
# CONFIG_USB_HID is not set

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set
# CONFIG_USB_AIPTEK is not set
# CONFIG_USB_WACOM is not set
# CONFIG_USB_KBTAB is not set
# CONFIG_USB_POWERMATE is not set
# CONFIG_USB_XPAD is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_SCANNER is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_HPUSBSCSI is not set

#
# USB Multimedia devices
#
# CONFIG_USB_DABUSB is not set

#
# Video4Linux support is needed for USB Multimedia device support
#

#
# USB Network adaptors
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set

#
# USB port drivers
#

#
# USB Serial Converter support
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_TIGL is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_BRLVGER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_GADGET is not set

#
# Library routines
#
CONFIG_CRC32=y

#
# Profiling support
#
# CONFIG_PROFILING is not set

#
# Kernel hacking
#
# CONFIG_IA64_GRANULE_16MB is not set
CONFIG_IA64_GRANULE_64MB=y
CONFIG_DEBUG_KERNEL=y
CONFIG_IA64_PRINT_HAZARDS=y
# CONFIG_DISABLE_VHPT is not set
CONFIG_MAGIC_SYSRQ=y
# CONFIG_IA64_EARLY_PRINTK is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_IA64_DEBUG_CMPXCHG is not set
# CONFIG_IA64_DEBUG_IRQ is not set
# CONFIG_DEBUG_INFO is not set

#
# Security options
#
# CONFIG_SECURITY is not set

#
# Cryptographic options
#
# CONFIG_CRYPTO is not set

=========================Dmesg
------------------------------------------------------------------------------------------
Linux version 2.6.0-test8 (root@acpi-lion) (gcc version 3.2) #1 SMP Fri Oct 24 23:29:38 CST 2003
EFI v1.02 by INTEL: SALsystab=0x7ff26170 ACPI=0x7fe963e8 ACPI 2.0=0x7fe96630 MPS=0x7ffd0000 SMBIOS=0xf00a0
ACPI: RSDP (v002  INTEL                                    ) @ 0x000000007fe96630
ACPI: XSDT (v001  INTEL  SR460AC 0x00000003 MSFT 0x0100000a) @ 0x000000007fe96658
ACPI: FADT (v003  INTEL  SR460AC 0x00000006 MSFT 0x0100000a) @ 0x000000007fe96700
ACPI: MADT (v001  INTEL  SR460AC 0x0000000a MSFT 0x0100000a) @ 0x000000007fe96838
ACPI: DSDT (v001  INTEL SR460AC4 0x00000006 MSFT 0x0100000a) @ 0x0000000000000000
efi.trim_top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
efi.trim_top: ignoring 448KB of memory at 0x1000 due to granule hole at 0x0
efi.trim_top: ignoring 4KB of memory at 0x71000 due to granule hole at 0x0
efi.trim_top: ignoring 8KB of memory at 0x72000 due to granule hole at 0x0
efi.trim_top: ignoring 100KB of memory at 0x87000 due to granule hole at 0x0
efi.trim_bottom: ignoring 64512KB of memory at 0x100000 due to granule hole at 0x0
SAL v3.00: oem=INTEL   MSL     REF     SAL     , productSAL: entry: pal_proc=0x7ff48010, sal_proc=0x7feb53e0
SAL: Platform features BusLock IRQ_Redirection 
SAL: AP wakeup using external interrupt vector 0xf0
CPU 0: 51 virtual and 44 physical address bits
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address 0xc0000000fee00000
ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0x00] lsapic_eid[0x00] enabled)
CPU 0 (0x0000) enabled (BSP)
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0x01] lsapic_eid[0x00] enabled)
CPU 1 (0x0100) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0x03] lsapic_eid[0x00] enabled)
CPU 2 (0x0300) enabled
ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0x02] lsapic_eid[0x00] enabled)
CPU 3 (0x0200) enabled
ACPI: LSAPIC (acpi_id[0x04] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 4 (0xaa00) disabled
ACPI: LSAPIC (acpi_id[0x05] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 5 (0xaa00) disabled
ACPI: LSAPIC (acpi_id[0x06] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 6 (0xaa00) disabled
ACPI: LSAPIC (acpi_id[0x07] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 7 (0xaa00) disabled
ACPI: IOSAPIC (id[0x4] global_irq_base[0x0] address[00000000fec00000])
  IOSAPIC v2.1, address 0xfec00000, GSIs 0x0-0x3f
ACPI: PLAT_INT_SRC (polarity[0x3] trigger[0x1] type[0x1] id[0x0002] eid[0x0] iosapic_vector[0x2] global_irq[0x3d]
PLATFORM int 0x1: GSI 0x3d(low,edge) -> CPU 0x0200 vector 2
ACPI: PLAT_INT_SRC (polarity[0x3] trigger[0x3] type[0x3] id[0x0002] eid[0x0] iosapic_vector[0x1e] global_irq[0x3c]
PLATFORM int 0x3: GSI 0x3c(low,level) -> CPU 0x0200 vector 30
ACPI: INT_SRC_OVR (bus[0] irq[0x9] global_irq[0x9] polarity[0x1] trigger[0x3])
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 8 CPUs total
Registering legacy COM ports for serial console
On node 0 totalpages: 126742
  DMA zone: 126742 pages, LIFO batch:4
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
Building zonelist for node : 0
Kernel command line: BOOT_IMAGE=scsi0:EFI\redhat\vmlinu.26  root=/dev/sda2 ro
fpswa interface at 7fb36010 (rev 1.12)
PID hash table entries: 4096 (order 12: 65536 bytes)
CPU 0: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz+/--1ppm
Console: colour VGA+ 80x25
Placing software IO TLB between 0xe00000000550c000 - 0xe00000000570c000
Memory: 2003840k/2027872k available (4662k code, 23648k reserved, 2078k data, 416k init)
McKinley Errata 9 workaround not needed; disabling it
Calibrating delay loop... 797.80 BogoMIPS
Dentry cache hash table entries: 131072 (order: 6, 1048576 bytes)
Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0x0
task migration cache decay timeout: 10 msecs.
Starting migration thread for cpu 0
Bringing up 1
Processor 256/1 is spinning up...
CPU 1: 51 virtual and 44 physical address bits
CPU 1: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz+/--1ppm
Calibrating delay loop... 797.80 BogoMIPS
CPU 1: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 561 cycles)
CPU1: CPU has booted.
Processor 1 has spun up...
CPU 1 IS NOW UP!
Starting migration thread for cpu 1
Bringing up 2
Processor 768/2 is spinning up...
CPU 2: 51 virtual and 44 physical address bits
CPU 2: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz+/--1ppm
Calibrating delay loop... 795.24 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 561 cycles)
CPU2: CPU has booted.
Processor 2 has spun up...
CPU 2 IS NOW UP!
Starting migration thread for cpu 2
Bringing up 3
Processor 512/3 is spinning up...
CPU 3: 51 virtual and 44 physical address bits
CPU 3: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz+/--1ppm
Calibrating delay loop... 795.24 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 561 cycles)
CPU3: CPU has booted.
Processor 3 has spun up...
CPU 3 IS NOW UP!
Starting migration thread for cpu 3
CPUS done 64
Total of 4 processors activated (3185.08 BogoMIPS).
NET: Registered protocol family 16
ACPI: Subsystem revision 20031002
 tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully acquired
Parsing all Control Methods:..............................................................................................................................................................................
Table [DSDT](id F004) - 934 Objects with 101 Devices 174 Methods 19 Regions
ACPI Namespace successfully loaded at root a00000010061f288
evxfevnt-0093 [04] acpi_enable           : Transition to ACPI mode successful
evgpeblk-0748 [06] ev_create_gpe_block   : GPE 00 to 15 [_GPE] 2 regs at 0000000000000C0C on int 9
evgpeblk-0748 [06] ev_create_gpe_block   : GPE 16 to 31 [_GPE] 2 regs at 0000000000000C16 on int 9
Completing Region/Field/Buffer/Package initialization:.......................................................
Initialized 19/19 Regions 0/0 Fields 24/24 Buffers 12/12 Packages (942 nodes)
Executing all Device _STA and_INI methods:..............................................................................................
94 Devices found containing: 94 _STA, 7 _INI methods
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware on bus (0000:00)
alloc 0x0-0xcf7 from PCI IO for PCI Bus 0000:00 failed
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: Power Resource [URP1] (off)
ACPI: Power Resource [URP2] (off)
ACPI: Power Resource [FDDP] (off)
ACPI: Power Resource [LPTP] (off)
ACPI: PCI Root Bridge [PCI1] (00:01)
PCI: Probing PCI hardware on bus (0000:01)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
ACPI: PCI Root Bridge [PCI2] (00:04)
PCI: Probing PCI hardware on bus (0000:04)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
ACPI: PCI Root Bridge [PCI3] (00:08)
PCI: Probing PCI hardware on bus (0000:08)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3._PRT]
ACPI: PCI Root Bridge [PCI4] (00:0c)
PCI: Probing PCI hardware on bus (0000:0c)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4._PRT]
ACPI: PCI Root Bridge [PCI5] (00:0f)
PCI: Probing PCI hardware on bus (0000:0f)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI5._PRT]
ACPI: PCI Root Bridge [PCI6] (00:12)
PCI: Probing PCI hardware on bus (0000:12)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI6._PRT]
ACPI: PCI Root Bridge [CBN] (00:15)
PCI: Probing PCI hardware on bus (0000:15)
SCSI subsystem initialized
drivers/usb/core/usb.c: registered new driver usbfs
drivers/usb/core/usb.c: registered new driver hub
IOSAPIC: vector 54 -> CPU 0x0000, enabled
 pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for device 0000:00:03.3
ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3
IOSAPIC: vector 55 -> CPU 0x0000, enabled
IOSAPIC: vector 56 -> CPU 0x0000, enabled
IOSAPIC: vector 61 -> CPU 0x0000, enabled
IOSAPIC: vector 62 -> CPU 0x0000, enabled
IOSAPIC: vector 62 -> CPU 0x0000, enabled
IOSAPIC: vector 77 -> CPU 0x0000, enabled
IOSAPIC: vector 77 -> CPU 0x0000, enabled
IOSAPIC: vector 84 -> CPU 0x0000, enabled
IOSAPIC: vector 84 -> CPU 0x0000, enabled
PCI: Using ACPI for IRQ routing
EFI Variables Facility v0.06 2002-Dec-10
PAL Information Facility v0.5
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU0] (supports C1)
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
pty: 256 Unix98 ptys configured
EFI Time Services Driver v0.4
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 45) is a 16550A
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.20-k1
Copyright (c) 1999-2003 Intel Corporation.
eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
PCI: Found IRQ 55 for device 0000:00:05.0
IOSAPIC: vector 55 -> CPU 0x0000, enabled
eth0: 0000:00:05.0, 00:D0:B7:F9:F4:F6, IRQ 55.
  Board assembly 727095-004, Physical connectors present: RJ45
  Primary interface chip i82555 PHY #1.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x04f4518b).
piix: 450NX errata present, disabling IDE DMA.
piix: A BIOS update may resolve this.
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
PIIX4: IDE controller at PCI slot 0000:00:03.1
PCI: Found IRQ 0 for device 0000:00:03.1
PIIX4: chipset revision 1
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:DMA, hdd:pio
hda: LS-120 S200 01 UHD Floppy, ATAPI FLOPPY drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hdc: CD-224E, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 33
PCI: Found IRQ 61 for device 0000:01:02.0
IOSAPIC: vector 61 -> CPU 0x0000, enabled
qla1280: QLA12160 found on PCI bus 1, dev 2
scsi(0): Reading NVRAM
scsi(0:0): Resetting SCSI BUS
scsi(0:1): Resetting SCSI BUS
PCI: Found IRQ 61 for device 0000:01:02.0
IOSAPIC: vector 61 -> CPU 0x0000, enabled
scsi0 : QLogic QLA12160 PCI to SCSI Host Adapter: bus 1 device 2 irq 61
       Firmware version: 10.04.32, Driver version 3.23.37
  Vendor: SEAGATE   Model: ST39205LC         Rev: 5063
  Type:   Direct-Access                      ANSI SCSI revision: 03
scsi(0:0:0:0): Sync: period 9, offset 24, Wide, DT, Tagged queuing: depth 255
SCSI device sda: 17921835 512-byte hdwr sectors (9176 MB)
SCSI device sda: drive cache: write back
 sda: sda1 sda2 sda3
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0
Fusion MPT base driver 2.05.00.03
Copyright (c) 1999-2002 LSI Logic Corporation
mptbase: 0 MPT adapters found, 0 installed.
Fusion MPT SCSI Host driver 2.05.00.03
mice: PS/2 mouse device common for all mice
input: PS/2 Generic Mouse on isa0060/serio1
serio: i8042 AUX port at 0x60,0x64 irq 36
input: AT Raw Set 2 keyboard on isa0060/serio0
serio: i8042 KBD port at 0x60,0x64 irq 32
NET: Registered protocol family 2
IP: routing cache hash table of 32768 buckets, 512Kbytes
TCP: Hash tables configured (established 262144 bind 65536)
NET: Registered protocol family 1
NET: Registered protocol family 17
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 416kB freed
EXT3 FS on sda2, internal journal
Adding 2040208k swap on /dev/sda3.  Priority:-1 extents:1
kudzu: numerical sysctl 1 23 is obsolete.
kudzu(646): <sc1136(6000000000091820,5,60000fffffffb3a0,20)>
kudzu(646): <sc1136(4000000000034640,5,60000fffffffb3b0,20)>
kudzu(646): <sc1136(6000000000092100,5,60000fffffff6f90,20)>
kudzu(646): <sc1136(4000000000034260,5,60000fffffffb2c0,20)>
kudzu(646): <sc1136(4000000000034270,5,60000fffffffb2c0,20)>
kudzu(646): <sc1136(4000000000034068,5,60000fffffffa4b0,20)>
lsmod(673): <sc1136(0,0,0,0)>
lsmod(673): <sc1136(0,1,600000000000c010,100)>
lsmod(685): <sc1136(0,0,0,0)>
lsmod(685): <sc1136(0,1,600000000000c010,100)>

========================/proc/interrups
------------------------------------------------------------------------------------
           CPU0       CPU1       CPU2       CPU3       
 32:          0         10          0          0   IO-SAPIC-edge  i8042
 33:          0          2          0          0   IO-SAPIC-edge  ide1
 34:          0          2          0          0   IO-SAPIC-edge  ide0
 36:          0         53          0          0   IO-SAPIC-edge  i8042
 39:          0          0          0          0  IO-SAPIC-level  acpi
 45:          7          9          0          0   IO-SAPIC-edge  serial
 55:       2360        147          0         24  IO-SAPIC-level  eth0
 61:       3035         73          0          4  IO-SAPIC-level  qla1280
239:     372936     372753     372735     372711          LSAPIC  timer
254:         31         83         82         74          LSAPIC  IPI
NMI:          0          0          0          0 
ERR:          0

==========================
lspci -v
---------------------------------------------------------------------------------------------
00:03.0 ISA bridge: Intel Corp. 82372FB PIIX5 ISA (rev 01)
	Flags: bus master, medium devsel, latency 0

00:03.1 IDE interface: Intel Corp. 82372FB PIIX5 IDE (rev 01) (prog-if 80 [Master])
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: bus master, medium devsel, latency 64
	I/O ports at 1000 [size]

00:03.2 USB Controller: Intel Corp. 82372FB PIIX5 USB (rev 01) (prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: bus master, medium devsel, latency 64, IRQ 54
	I/O ports at 6f80 [size2]

00:03.3 SMBus: Intel Corp. 82372FB PIIX5 SMBus (rev 01)
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: medium devsel
	I/O ports at c000 [disabled] [size]

00:04.0 PIC: Intel Corp. 683053 Programmable Interrupt Device (rev 01) (prog-if 20 [IO(X)-APIC])
	Flags: bus master, medium devsel, latency 0

00:05.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)
	Subsystem: Intel Corp. 82559 Fast Ethernet LAN on Motherboard
	Flags: bus master, medium devsel, latency 64, IRQ 55
	Memory at 00000000fafe0000 (32-bit, non-prefetchable) [size=4K]
	I/O ports at 6f00 [sized]
	Memory at 00000000fae00000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [dc] Power Management version 2

00:06.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) (prog-if 00 [VGA])
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: bus master, stepping, medium devsel, latency 64, IRQ 56
	Memory at 00000000fb000000 (32-bit, non-prefetchable) [sizeM]
	I/O ports at 6800 [size%6]
	Memory at 00000000faff0000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at 00000000fafc0000 [disabled] [size8K]
	Capabilities: [5c] Power Management version 2

00:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

01:02.0 SCSI storage controller: QLogic Corp. ISP12160 Dual Channel Ultra3 SCSI Processor (rev 06)
	Subsystem: QLogic Corp.: Unknown device 0007
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 61
	I/O ports at 8800 [size%6]
	Memory at 00000000f1ff0000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at 00000000f1fc0000 [disabled] [size8K]
	Capabilities: [44] Power Management version 1

01:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 62
	Memory at 00000000f1fe0000 (32-bit, non-prefetchable) [size%6]

04:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 62
	Memory at 00000000e7ff0000 (32-bit, non-prefetchable) [size%6]

08:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 77
	Memory at 00000000ddff0000 (32-bit, non-prefetchable) [size%6]

0c:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 77
	Memory at 00000000d5ff0000 (32-bit, non-prefetchable) [size%6]

0f:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 84
	Memory at 00000000cdff0000 (32-bit, non-prefetchable) [size%6]

12:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 84
	Memory at 00000000c5ff0000 (32-bit, non-prefetchable) [size%6]

15:00.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:00.1 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:00.2 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:00.3 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:00.4 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:00.5 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:00.6 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:00.7 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.1 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.2 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.3 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.4 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.5 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.6 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:01.7 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:04.0 Host bridge: Intel Corp. 460GX - 84460GX System Data Controller (SDC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Data Controller (SDC)
	Flags: fast devsel

15:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:10.1 Host bridge: Intel Corp. 450NX - 82454NX/84460GX PCI Expander Bridge (rev 05)
	Subsystem: Intel Corp. 450NX - 82454NX/84460GX PCI Expander Bridge
	Flags: bus master, medium devsel, latency 128

15:11.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:12.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:12.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:13.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:13.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:14.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:14.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:15.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:15.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:16.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:16.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:17.0 Host bridge: Intel Corp. 460GX - 84460GX System Address Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller (SAC)
	Flags: fast devsel

15:17.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2


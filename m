From: "Yu, Luming" <luming.yu@intel.com>
Date: Fri, 24 Oct 2003 11:11:05 +0000
Subject: Bjorn Tree (2.4 IA64) + ACPI Testing  Report (boot fine)
Message-Id: <marc-linux-ia64-106699413304707@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Today I pulled change sets from  http://lia64.bkbits.net/linux-ia64-2.4 and http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22  .Boot fine on lion.

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
2.4.23-pre8

patches applied on top of kernel
bk pulled from http://lia64.bkbits.net/linux-ia64-2.4 and http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22  

==============ACPI Features Tested: (prioritized).
-------------------------------------------------

1. System Boot  fine

=============.config file
----------------------------------------------
#
# Automatically generated by make menuconfig: don't edit
#

#
# Code maturity level options
#
CONFIG_EXPERIMENTAL=y

#
# Loadable module support
#
CONFIG_MODULES=y
CONFIG_MODVERSIONS=y
# CONFIG_KMOD is not set

#
# General setup
#
CONFIG_IA64=y
# CONFIG_ISA is not set
# CONFIG_EISA is not set
# CONFIG_MCA is not set
# CONFIG_SBUS is not set
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ITANIUM=y
# CONFIG_MCKINLEY is not set
CONFIG_IA64_GENERIC=y
# CONFIG_IA64_DIG is not set
# CONFIG_IA64_HP_SIM is not set
# CONFIG_IA64_HP_ZX1 is not set
# CONFIG_IA64_SGI_SN2 is not set
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
CONFIG_IA64_PAGE_SIZE_16KB=y
CONFIG_IA64_BRL_EMU=y
# CONFIG_ITANIUM_BSTEP_SPECIFIC is not set
CONFIG_IA64_L1_CACHE_SHIFT=6
# CONFIG_NUMA is not set
# CONFIG_IA64_MCA is not set
CONFIG_PM=y
CONFIG_KCORE_ELF=y
CONFIG_FORCE_MAX_ZONEORDER
# CONFIG_HUGETLB_PAGE_SIZE_256MB is not set
# CONFIG_HUGETLB_PAGE_SIZE_64MB is not set
CONFIG_HUGETLB_PAGE_SIZE_16MB=y
# CONFIG_HUGETLB_PAGE_SIZE_4MB is not set
# CONFIG_HUGETLB_PAGE_SIZE_1MB is not set
# CONFIG_HUGETLB_PAGE_SIZE_256KB is not set
# CONFIG_IA64_PAL_IDLE is not set
CONFIG_SMP=y
CONFIG_NR_CPUS2
CONFIG_IA32_SUPPORT=y
# CONFIG_PERFMON is not set
CONFIG_IA64_PALINFO=y
CONFIG_EFI_VARS=y
CONFIG_NET=y
CONFIG_SYSVIPC=y
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_SYSCTL=y
CONFIG_BINFMT_ELF=y
# CONFIG_BINFMT_MISC is not set
CONFIG_ACPI=y
CONFIG_ACPI_EFI=y
CONFIG_ACPI_INTERPRETER=y
CONFIG_ACPI_KERNEL_CONFIG=y

#
# ACPI Support
#
CONFIG_ACPI_PCI=y
CONFIG_ACPI=y
CONFIG_ACPI_EFI=y
CONFIG_ACPI_BOOT=y
CONFIG_ACPI_BUS=y
CONFIG_ACPI_INTERPRETER=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_DEBUG=y
CONFIG_PCI=y
CONFIG_PCI_NAMES=y
# CONFIG_HOTPLUG is not set
# CONFIG_PCMCIA is not set

#
# Parallel port support
#
# CONFIG_PARPORT is not set

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
# CONFIG_NETLINK_DEV is not set
# CONFIG_NETFILTER is not set
CONFIG_FILTER=y
CONFIG_UNIX=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
# CONFIG_INET_ECN is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_IPV6 is not set
# CONFIG_KHTTPD is not set

#
#    SCTP Configuration (EXPERIMENTAL)
#
CONFIG_IPV6_SCTP__=y
# CONFIG_IP_SCTP is not set
# CONFIG_ATM is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set

#
# Appletalk devices
#
# CONFIG_DEV_APPLETALK is not set
# CONFIG_DECNET is not set
# CONFIG_BRIDGE is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_LLC is not set
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

#
# Memory Technology Devices (MTD)
#
# CONFIG_MTD is not set

#
# Plug and Play configuration
#
# CONFIG_PNP is not set
# CONFIG_ISAPNP is not set

#
# Block devices
#
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_XD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_CISS_SCSI_TAPE is not set
# CONFIG_CISS_MONITOR_THREAD is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=y
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_BLK_DEV_INITRD is not set
# CONFIG_BLK_STATS is not set

#
# IEEE 1394 (FireWire) support (EXPERIMENTAL)
#
# CONFIG_IEEE1394 is not set

#
# I2O device support
#
# CONFIG_I2O is not set
# CONFIG_I2O_PCI is not set
# CONFIG_I2O_BLOCK is not set
# CONFIG_I2O_LAN is not set
# CONFIG_I2O_SCSI is not set
# CONFIG_I2O_PROC is not set

#
# Multi-device support (RAID and LVM)
#
# CONFIG_MD is not set
# CONFIG_BLK_DEV_MD is not set
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
# CONFIG_MD_RAID1 is not set
# CONFIG_MD_RAID5 is not set
# CONFIG_MD_MULTIPATH is not set
# CONFIG_BLK_DEV_LVM is not set

#
# Fusion MPT device support
#
CONFIG_FUSION=y
CONFIG_FUSION_BOOT=y
CONFIG_FUSION_MAX_SGE@
# CONFIG_FUSION_ISENSE is not set
# CONFIG_FUSION_CTL is not set
# CONFIG_FUSION_LAN is not set

#
# ATA/IDE/MFM/RLL support
#
CONFIG_IDE=y

#
# IDE, ATA and ATAPI Block devices
#
CONFIG_BLK_DEV_IDE=y
# CONFIG_BLK_DEV_HD_IDE is not set
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_IDEDISK=y
CONFIG_IDEDISK_MULTI_MODE=y
# CONFIG_IDEDISK_STROKE is not set
# CONFIG_BLK_DEV_IDECS is not set
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDETAPE is not set
CONFIG_BLK_DEV_IDEFLOPPY=y
CONFIG_BLK_DEV_IDESCSI=y
# CONFIG_IDE_TASK_IOCTL is not set
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
# CONFIG_BLK_DEV_ISAPNP is not set
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_IDEPCI_SHARE_IRQ=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
# CONFIG_IDEDMA_PCI_AUTO is not set
# CONFIG_IDEDMA_ONLYDISK is not set
CONFIG_BLK_DEV_IDEDMA=y
# CONFIG_IDEDMA_PCI_WIP is not set
# CONFIG_BLK_DEV_ADMA100 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_WDC_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_AMD74XX_OVERRIDE is not set
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_HPT34X_AUTODMA is not set
# CONFIG_BLK_DEV_HPT366 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_PDC202XX_BURST is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SGIIOC4 is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_IDE_CHIPSETS is not set
# CONFIG_IDEDMA_AUTO is not set
# CONFIG_IDEDMA_IVB is not set
# CONFIG_DMA_NONPCI is not set
CONFIG_BLK_DEV_IDE_MODES=y
# CONFIG_BLK_DEV_ATARAID is not set
# CONFIG_BLK_DEV_ATARAID_PDC is not set
# CONFIG_BLK_DEV_ATARAID_HPT is not set
# CONFIG_BLK_DEV_ATARAID_SII is not set

#
# SCSI support
#
CONFIG_SCSI=y
CONFIG_BLK_DEV_SD=y
CONFIG_SD_EXTRA_DEVS@
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_SR_EXTRA_DEVS=2
CONFIG_CHR_DEV_SG=y
CONFIG_SCSI_DEBUG_QUEUES=y
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y

#
# SCSI low-level drivers
#
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_7000FASST is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AHA152X is not set
# CONFIG_SCSI_AHA1542 is not set
# CONFIG_SCSI_AHA1740 is not set
# CONFIG_SCSI_AACRAID is not set
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE%3
CONFIG_AIC7XXX_RESET_DELAY_MS000
# CONFIG_AIC7XXX_PROBE_EISA_VL is not set
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_IN2000 is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_MEGARAID is not set
# CONFIG_SCSI_MEGARAID2 is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_CPQFCTS is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_DTC3280 is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_EATA_DMA is not set
# CONFIG_SCSI_EATA_PIO is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_GENERIC_NCR5380 is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_NCR53C406A is not set
# CONFIG_SCSI_NCR53C7xx is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_NCR53C8XX is not set
CONFIG_SCSI_SYM53C8XX=y
CONFIG_SCSI_NCR53C8XX_DEFAULT_TAGS=8
CONFIG_SCSI_NCR53C8XX_MAX_TAGS2
CONFIG_SCSI_NCR53C8XX_SYNC 
# CONFIG_SCSI_NCR53C8XX_PROFILE is not set
# CONFIG_SCSI_NCR53C8XX_IOMAPPED is not set
# CONFIG_SCSI_NCR53C8XX_PQS_PDS is not set
# CONFIG_SCSI_NCR53C8XX_SYMBIOS_COMPAT is not set
# CONFIG_SCSI_PAS16 is not set
# CONFIG_SCSI_PCI2000 is not set
# CONFIG_SCSI_PCI2220I is not set
# CONFIG_SCSI_PSI240I is not set
# CONFIG_SCSI_QLOGIC_FAS is not set
# CONFIG_SCSI_QLOGIC_ISP is not set
# CONFIG_SCSI_QLOGIC_FC is not set
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_SIM710 is not set
# CONFIG_SCSI_SYM53C416 is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_T128 is not set
# CONFIG_SCSI_U14_34F is not set
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_DEBUG is not set

#
# Network device support
#
CONFIG_NETDEVICES=y

#
# ARCnet devices
#
# CONFIG_ARCNET is not set
CONFIG_DUMMY=y
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_ETHERTAP is not set

#
# Ethernet (10 or 100Mbit)
#
CONFIG_NET_ETHERNET=y
# CONFIG_SUNLANCE is not set
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNBMAC is not set
# CONFIG_SUNQE is not set
# CONFIG_SUNGEM is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_LANCE is not set
# CONFIG_NET_VENDOR_SMC is not set
# CONFIG_NET_VENDOR_RACAL is not set
# CONFIG_HP100 is not set
# CONFIG_NET_ISA is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_APRICOT is not set
# CONFIG_B44 is not set
# CONFIG_CS89x0 is not set
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
# CONFIG_DE4X5 is not set
# CONFIG_DGRS is not set
# CONFIG_DM9102 is not set
CONFIG_EEPRO100=y
# CONFIG_EEPRO100_PIO is not set
# CONFIG_E100 is not set
# CONFIG_LNE390 is not set
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_NE3210 is not set
# CONFIG_ES3210 is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_8139TOO_PIO is not set
# CONFIG_8139TOO_TUNE_TWISTER is not set
# CONFIG_8139TOO_8129 is not set
# CONFIG_8139_OLD_RX_RESET is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_SUNDANCE_MMIO is not set
# CONFIG_TLAN is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_RHINE_MMIO is not set
# CONFIG_WINBOND_840 is not set
# CONFIG_NET_POCKET is not set

#
# Ethernet (1000 Mbit)
#
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
CONFIG_E1000=y
# CONFIG_E1000_NAPI is not set
# CONFIG_MYRI_SBUS is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SK98LIN is not set
CONFIG_TIGON3=y
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PLIP is not set
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
# CONFIG_RCPCI is not set
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
# ISDN subsystem
#
# CONFIG_ISDN is not set

#
# CD-ROM drivers (not for SCSI or IDE/ATAPI drives)
#
# CONFIG_CD_NO_IDESCSI is not set

#
# Input core support
#
CONFIG_INPUT=y
CONFIG_INPUT_KEYBDEV=y
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X24
CONFIG_INPUT_MOUSEDEV_SCREEN_Yv8
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_SERIAL=y
CONFIG_SERIAL_CONSOLE=y
CONFIG_SERIAL_HCDP=y
CONFIG_SERIAL_ACPI=y
# CONFIG_SERIAL_EXTENDED is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_UNIX98_PTYS=y
CONFIG_UNIX98_PTY_COUNT%6

#
# I2C support
#
# CONFIG_I2C is not set

#
# Mice
#
# CONFIG_BUSMOUSE is not set
CONFIG_MOUSE=y
CONFIG_PSMOUSE=y
# CONFIG_82C710_MOUSE is not set
# CONFIG_PC110_PAD is not set
# CONFIG_MK712_MOUSE is not set

#
# Joysticks
#
# CONFIG_INPUT_GAMEPORT is not set
# CONFIG_INPUT_NS558 is not set
# CONFIG_INPUT_LIGHTNING is not set
# CONFIG_INPUT_PCIGAME is not set
# CONFIG_INPUT_CS461X is not set
# CONFIG_INPUT_EMU10K1 is not set
CONFIG_INPUT_SERIO=y
CONFIG_INPUT_SERPORT=y
# CONFIG_INPUT_ANALOG is not set
# CONFIG_INPUT_A3D is not set
# CONFIG_INPUT_ADI is not set
# CONFIG_INPUT_COBRA is not set
# CONFIG_INPUT_GF2K is not set
# CONFIG_INPUT_GRIP is not set
# CONFIG_INPUT_INTERACT is not set
# CONFIG_INPUT_TMDC is not set
# CONFIG_INPUT_SIDEWINDER is not set
# CONFIG_INPUT_IFORCE_USB is not set
# CONFIG_INPUT_IFORCE_232 is not set
# CONFIG_INPUT_WARRIOR is not set
# CONFIG_INPUT_MAGELLAN is not set
# CONFIG_INPUT_SPACEORB is not set
# CONFIG_INPUT_SPACEBALL is not set
# CONFIG_INPUT_STINGER is not set
# CONFIG_INPUT_DB9 is not set
# CONFIG_INPUT_GAMECON is not set
# CONFIG_INPUT_TURBOGRAFX is not set
# CONFIG_QIC02_TAPE is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_IPMI_PANIC_EVENT is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
# CONFIG_IPMI_KCS is not set
# CONFIG_IPMI_WATCHDOG is not set

#
# Watchdog Cards
#
# CONFIG_WATCHDOG is not set
# CONFIG_SCx200_GPIO is not set
# CONFIG_FETCHOP is not set
# CONFIG_INTEL_RNG is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_AMD_PM768 is not set
# CONFIG_NVRAM is not set
# CONFIG_RTC is not set
CONFIG_EFI_RTC=y
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# Ftape, the floppy tape device driver
#
# CONFIG_FTAPE is not set
CONFIG_AGP=y
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_I810 is not set
# CONFIG_AGP_VIA is not set
# CONFIG_AGP_AMD is not set
# CONFIG_AGP_AMD_K8 is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_ALI is not set
# CONFIG_AGP_SWORKS is not set
CONFIG_AGP_I460=y
CONFIG_AGP_HP_ZX1=y
# CONFIG_AGP_ATI is not set

#
# Direct Rendering Manager (XFree86 DRI support)
#
CONFIG_DRM=y
# CONFIG_DRM_OLD is not set
CONFIG_DRM_NEW=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_GAMMA is not set
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_I810 is not set
# CONFIG_DRM_I810_XFREE_41 is not set
# CONFIG_DRM_I830 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set

#
# Multimedia devices
#
CONFIG_VIDEO_DEV=y

#
# Video For Linux
#
CONFIG_VIDEO_PROC_FS=y
# CONFIG_I2C_PARPORT is not set
# CONFIG_VIDEO_BT848 is not set
# CONFIG_VIDEO_PMS is not set
# CONFIG_VIDEO_CPIA is not set
# CONFIG_VIDEO_SAA5249 is not set
# CONFIG_TUNER_3036 is not set
# CONFIG_VIDEO_STRADIS is not set
# CONFIG_VIDEO_ZORAN is not set
# CONFIG_VIDEO_ZORAN_BUZ is not set
# CONFIG_VIDEO_ZORAN_DC10 is not set
# CONFIG_VIDEO_ZORAN_LML33 is not set
# CONFIG_VIDEO_ZR36120 is not set
# CONFIG_VIDEO_MEYE is not set

#
# Radio Adapters
#
# CONFIG_RADIO_GEMTEK_PCI is not set
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_RADIO_MAESTRO is not set
# CONFIG_RADIO_MIROPCM20 is not set

#
# File systems
#
# CONFIG_QUOTA is not set
# CONFIG_QFMT_V2 is not set
CONFIG_AUTOFS_FS=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_REISERFS_FS is not set
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_ADFS_FS is not set
# CONFIG_ADFS_FS_RW is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BEFS_DEBUG is not set
# CONFIG_BFS_FS is not set
CONFIG_EXT3_FS=y
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_UMSDOS_FS is not set
CONFIG_VFAT_FS=y
# CONFIG_EFS_FS is not set
# CONFIG_JFFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_TMPFS is not set
CONFIG_RAMFS=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
# CONFIG_JFS_FS is not set
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_NTFS_FS is not set
# CONFIG_NTFS_RW is not set
# CONFIG_HPFS_FS is not set
CONFIG_PROC_FS=y
# CONFIG_DEVFS_FS is not set
# CONFIG_DEVFS_MOUNT is not set
# CONFIG_DEVFS_DEBUG is not set
CONFIG_DEVPTS_FS=y
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX4FS_RW is not set
# CONFIG_ROMFS_FS is not set
CONFIG_EXT2_FS=y
# CONFIG_SYSV_FS is not set
# CONFIG_UDF_FS is not set
# CONFIG_UDF_RW is not set
# CONFIG_UFS_FS is not set
# CONFIG_UFS_FS_WRITE is not set

#
# Network File Systems
#
# CONFIG_CODA_FS is not set
# CONFIG_INTERMEZZO_FS is not set
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_DIRECTIO is not set
# CONFIG_ROOT_NFS is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_TCP is not set
CONFIG_SUNRPC=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
# CONFIG_SMB_FS is not set
# CONFIG_NCP_FS is not set
# CONFIG_NCPFS_PACKET_SIGNING is not set
# CONFIG_NCPFS_IOCTL_LOCKING is not set
# CONFIG_NCPFS_STRONG is not set
# CONFIG_NCPFS_NFS_NS is not set
# CONFIG_NCPFS_OS2_NS is not set
# CONFIG_NCPFS_SMALLDOS is not set
# CONFIG_NCPFS_NLS is not set
# CONFIG_NCPFS_EXTRAS is not set
# CONFIG_ZISOFS_FS is not set

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
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SMB_NLS is not set
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
# Console drivers
#
CONFIG_VGA_CONSOLE=y

#
# Frame-buffer support
#
# CONFIG_FB is not set

#
# Sound
#
CONFIG_SOUND=y
# CONFIG_SOUND_ALI5455 is not set
# CONFIG_SOUND_BT878 is not set
# CONFIG_SOUND_CMPCI is not set
# CONFIG_SOUND_EMU10K1 is not set
# CONFIG_MIDI_EMU10K1 is not set
# CONFIG_SOUND_FUSION is not set
CONFIG_SOUND_CS4281=y
# CONFIG_SOUND_ES1370 is not set
# CONFIG_SOUND_ES1371 is not set
# CONFIG_SOUND_ESSSOLO1 is not set
# CONFIG_SOUND_MAESTRO is not set
# CONFIG_SOUND_MAESTRO3 is not set
# CONFIG_SOUND_FORTE is not set
# CONFIG_SOUND_ICH is not set
# CONFIG_SOUND_RME96XX is not set
# CONFIG_SOUND_SONICVIBES is not set
# CONFIG_SOUND_TRIDENT is not set
# CONFIG_SOUND_MSNDCLAS is not set
# CONFIG_SOUND_MSNDPIN is not set
# CONFIG_SOUND_VIA82CXXX is not set
# CONFIG_MIDI_VIA82CXXX is not set
# CONFIG_SOUND_OSS is not set
# CONFIG_SOUND_TVMIXER is not set
# CONFIG_SOUND_AD1980 is not set
# CONFIG_SOUND_WM97XX is not set

#
# USB support
#
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_BANDWIDTH is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_UHCI=y
# CONFIG_USB_UHCI_ALT is not set
CONFIG_USB_OHCI=y
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_BLUETOOTH is not set
# CONFIG_USB_MIDI is not set
# CONFIG_USB_STORAGE is not set
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_DPCM is not set
# CONFIG_USB_STORAGE_HP8200e is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
CONFIG_USB_HID=y
CONFIG_USB_HIDINPUT=y
CONFIG_USB_HIDDEV=y
# CONFIG_USB_AIPTEK is not set
# CONFIG_USB_WACOM is not set
# CONFIG_USB_KBTAB is not set
# CONFIG_USB_POWERMATE is not set
# CONFIG_USB_DC2XX is not set
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_SCANNER is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_HPUSBSCSI is not set
# CONFIG_USB_IBMCAM is not set
# CONFIG_USB_KONICAWC is not set
# CONFIG_USB_OV511 is not set
# CONFIG_USB_PWC is not set
# CONFIG_USB_SE401 is not set
# CONFIG_USB_STV680 is not set
# CONFIG_USB_VICAM is not set
# CONFIG_USB_DSBR is not set
# CONFIG_USB_DABUSB is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_CATC is not set
# CONFIG_USB_AX8817X is not set
# CONFIG_USB_CDCETHER is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_USS720 is not set

#
# USB Serial Converter support
#
# CONFIG_USB_SERIAL is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_TIGL is not set
# CONFIG_USB_BRLVGER is not set
# CONFIG_USB_LCD is not set

#
# Support for USB gadgets
#
# CONFIG_USB_GADGET is not set

#
# Cryptographic options
#
# CONFIG_CRYPTO is not set

#
# Library routines
#
# CONFIG_CRC32 is not set
# CONFIG_ZLIB_INFLATE is not set
# CONFIG_ZLIB_DEFLATE is not set

#
# Bluetooth support
#
# CONFIG_BLUEZ is not set

#
# Simulated drivers
#
# CONFIG_HP_SIMETH is not set
# CONFIG_HP_SIMSERIAL is not set
# CONFIG_HP_SIMSCSI is not set

#
# Kernel hacking
#
CONFIG_IA64_GRANULE_16MB=y
# CONFIG_IA64_GRANULE_64MB is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_IA64_PRINT_HAZARDS=y
# CONFIG_DISABLE_VHPT is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_IA64_EARLY_PRINTK=y
CONFIG_IA64_EARLY_PRINTK_UART=y
CONFIG_IA64_EARLY_PRINTK_UART_BASE=0
# CONFIG_IA64_EARLY_PRINTK_VGA is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_IA64_DEBUG_CMPXCHG is not set
# CONFIG_IA64_DEBUG_IRQ is not set
CONFIG_LOG_BUF_SHIFT=0


=========================Dmesg
------------------------------------------------------------------------------------------

Linux version 2.4.23-pre8 (root@acpi-lion) (gcc version 3.2) #1 SMP Fri Oct 24 22:02:29 CST 2003
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
efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule hole at 0x0
SAL v3.00: oem=INTEL   MSL     REF     SAL     , productSAL: entry: pal_proc=0x7ff48010, sal_proc=0x7feb53e0
SAL: Platform features BusLock IRQ_Redirection
SAL: AP wakeup using external interrupt vector 0xf0
booting generic kernel on platform dig
CPU 0: 51 virtual and 44 physical address bits
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address 0xc0000000fee00000
ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0x00] lsapic_eid[0x00] enabled)
CPU 0 (0x0000) enabled (BSP)
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0x03] lsapic_eid[0x00] enabled)
CPU 1 (0x0300) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0x02] lsapic_eid[0x00] enabled)
CPU 2 (0x0200) enabled
ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0x01] lsapic_eid[0x00] enabled)
CPU 3 (0x0100) enabled
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
ACPI: PLAT_INT_SRC (polarity[0x3] trigger[0x1] type[0x1] id[0x0001] eid[0x0] iosapic_vector[0x2] global_irq[0]
PLATFORM int 0x1: GSI 0x3d(low,edge) -> CPU 0x0100 vector 2
ACPI: PLAT_INT_SRC (polarity[0x3] trigger[0x3] type[0x3] id[0x0001] eid[0x0] iosapic_vector[0x1e] global_irq[]
PLATFORM int 0x3: GSI 0x3c(low,level) -> CPU 0x0100 vector 30
ACPI: INT_SRC_OVR (bus[0] irq[0x9] global_irq[0x9] polarity[0x1] trigger[0x3])
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 8 CPUs total
On node 0 totalpages: 129246
zone(0): 129246 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Building zonelist for node : 0
Kernel command line: BOOT_IMAGE=scsi0:EFI\redhat\vmlinu.24  root=/dev/sda2 console=ttyS0,9600n8 console=tty0 o
FPSWA interface at 0x7fb36010, revision 1.12
CPU 0: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz
Console: colour VGA+ 80x25
Calibrating delay loop... 797.80 BogoMIPS
Placing software IO TLB between 0xe000000001b0c000 - 0xe000000001d0c000
Memory: 2054560k/2067936k available (5905k code, 13424k reserved, 2875k data, 512k init)
Dentry cache hash table entries: 131072 (order: 7, 2097152 bytes)
Inode cache hash table entries: 131072 (order: 7, 2097152 bytes)
Mount cache hash table entries: 1024 (order: 0, 16384 bytes)
Buffer cache hash table entries: 131072 (order: 6, 1048576 bytes)
Page-cache hash table entries: 131072 (order: 6, 1048576 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0x0
SMP: starting up secondaries.
CPU 1: 51 virtual and 44 physical address bits
CPU 1: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz
Calibrating delay loop... 797.80 BogoMIPS
CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558 cycles)
CPU1: CPU has booted.
CPU 2: 51 virtual and 44 physical address bits
CPU 2: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz
Calibrating delay loop... 797.80 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558 cycles)
CPU2: CPU has booted.
CPU 3: 51 virtual and 44 physical address bits
CPU 3: base freq3.333MHz, ITC ratio/2, ITC freqy9.998MHz
Calibrating delay loop... 797.80 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558 cycles)
CPU3: CPU has booted.
Before bogomips.
Total of 4 processors activated (3189.20 BogoMIPS).
Waiting on wait_init_idle (map = 0xe)
All processors have done init_idle
ACPI: Subsystem revision 20031002
PCI: Using SAL to access configuration space
 tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully acquired
Parsing all Control Methods:..................................................................................
Table [DSDT](id F004) - 934 Objects with 101 Devices 174 Methods 19 Regions
ACPI Namespace successfully loaded at root e000000004c174a0
evxfevnt-0093 [04] acpi_enable           : Transition to ACPI mode successful
evgpeblk-0748 [06] ev_create_gpe_block   : GPE 00 to 15 [_GPE] 2 regs at 0000000000000C0C on int 9
evgpeblk-0748 [06] ev_create_gpe_block   : GPE 16 to 31 [_GPE] 2 regs at 0000000000000C16 on int 9
Completing Region/Field/Buffer/Package initialization:.......................................................
Initialized 19/19 Regions 0/0 Fields 24/24 Buffers 12/12 Packages (942 nodes)
Executing all Device _STA and_INI methods:....................................................................
94 Devices found containing: 94 _STA, 7 _INI methods
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: System [ACPI] (supports S0 S4 S5)
ACPI: PCI Root Bridge [PCI0] (00:00)
alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed
ACPI: Power Resource [URP1] (off)
ACPI: Power Resource [URP2] (off)
ACPI: Power Resource [FDDP] (off)
ACPI: Power Resource [LPTP] (off)
ACPI: PCI Root Bridge [PCI1] (00:01)
ACPI: PCI Root Bridge [PCI2] (00:04)
ACPI: PCI Root Bridge [PCI3] (00:08)
ACPI: PCI Root Bridge [PCI4] (00:0c)
ACPI: PCI Root Bridge [PCI5] (00:0f)
ACPI: PCI Root Bridge [PCI6] (00:12)
PCI->APIC IRQ transform: (00:03.2 INTD) -> CPU 0x0000 vector 48
PCI: no interrupt route for 00:00:03 pin B
PCI->APIC IRQ transform: (00:05.0 INTA) -> CPU 0x0000 vector 49
PCI->APIC IRQ transform: (00:06.0 INTA) -> CPU 0x0000 vector 50
PCI->APIC IRQ transform: (01:02.0 INTA) -> CPU 0x0000 vector 51
PCI->APIC IRQ transform: (01:0f.0 INTA) -> CPU 0x0000 vector 52
PCI->APIC IRQ transform: (04:0f.0 INTA) -> CPU 0x0000 vector 52
PCI->APIC IRQ transform: (08:0f.0 INTA) -> CPU 0x0000 vector 53
PCI->APIC IRQ transform: (0c:0f.0 INTA) -> CPU 0x0000 vector 53
PCI->APIC IRQ transform: (0f:0f.0 INTA) -> CPU 0x0000 vector 54
PCI->APIC IRQ transform: (12:0f.0 INTA) -> CPU 0x0000 vector 54
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
PAL Information Facility v0.5
EFI Variables Facility v0.06 2002-Dec-10
Total HugeTLB memory allocated, 0
Starting kswapd
Journalled Block Device driver loaded
Hugetlbfs mounted.
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU0] (supports C1)
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
pty: 256 Unix98 ptys configured
Serial driver version 5.05c (2001-07-08) with MANY_PORTS SHARE_IRQ DETECT_IRQ SERIAL_PCI SERIAL_ACPI enabled
?ttyS00 at 0x03f8 (irq = 44) is a 16550A
ttyS01 at 0x02f8 (irq = 45) is a 16550A
?ttyS00 at port 0x03f8 (irq = 44) is a 16550A
ttyS01 at port 0x02f8 (irq = 45) is a 16550A
EFI Time Services Driver v0.4
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.16-k2
Copyright (c) 1999-2003 Intel Corporation.
eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
PCI: Found IRQ 49 for device 00:05.0
eth0: Intel Corp. 82557/8/9 [Ethernet Pro 100], 00:D0:B7:F9:F4:F6, IRQ 49.
  Board assembly 727095-004, Physical connectors present: RJ45
  Primary interface chip i82555 PHY #1.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x04f4518b).
Linux agpgart interface v0.99 (c) Jeff Hartmann
agpgart: Maximum main memory to use for agp memory: 1892M
[drm] Initialized r128 2.2.0 20010917 on minor 0
[drm] Initialized radeon 1.7.0 20020828 on minor 1
Uniform Multi-Platform E-IDE driver Revision: 7.00beta4-2.4
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
PIIX4: IDE controller at PCI slot 00:03.1
PCI: Found IRQ 0 for device 00:03.1
PIIX4: chipset revision 1
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:DMA, hdd:pio
hda: LS-120 S200 01 UHD Floppy, ATAPI FLOPPY drive
hdc: CD-224E, ATAPI CD/DVD-ROM drive
global_restore_flags: 10084a6010 (e000000004aa8760)
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
global_restore_flags: 10084a2010 (e000000004aa8760)
ide1 at 0x170-0x177,0x376 on irq 33
hdc: attached ide-cdrom driver.
hdc: ATAPI 24X CD-ROM drive, 128kB Cache
Uniform CD-ROM driver Revision: 3.12
hda: attached ide-floppy driver.
hda: No disk in drive
hda: 123264kB, 963/8/32 CHS, 533 kBps, 512 sector size, 720 rpm
SCSI subsystem driver Revision: 1.00
PCI: Found IRQ 51 for device 01:02.0
qla1280: QLA12160 found on PCI bus 1, dev 2
scsi(0): Reading NVRAM
scsi(0:0): Resetting SCSI BUS
scsi(0:1): Resetting SCSI BUS
PCI: Found IRQ 51 for device 01:02.0
scsi0 : QLogic QLA12160 PCI to SCSI Host Adapter: bus 1 device 2 irq 51
       Firmware version: 10.04.32, Driver version 3.23.37
  Vendor: SEAGATE   Model: ST39205LC         Rev: 5063
  Type:   Direct-Access                      ANSI SCSI revision: 03
scsi(0:0:0:0): Sync: period 9, offset 24, Wide, DT, Tagged queuing: depth 255
scsi1 : SCSI host adapter emulation for IDE ATAPI devices
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
SCSI device sda: 17921835 512-byte hdwr sectors (9176 MB)
Partition check:
 sda: sda1 sda2 sda3
Fusion MPT base driver 2.05.05+
Copyright (c) 1999-2002 LSI Logic Corporation
mptbase: 0 MPT adapters found, 0 installed.
Fusion MPT SCSI Host driver 2.05.05+
cs4281: version v1.30.64 time 22:26:10 Oct 24 2003
cs4281: Unable to locate any cs4281 device with valid IDs 0x1013-0x6005
usb.c: registered new driver usbdevfs
usb.c: registered new driver hub
host/usb-uhci.c: $Revision: 1.275 $ time 22:27:27 Oct 24 2003
host/usb-uhci.c: High bandwidth mode enabled
PCI: Found IRQ 48 for device 00:03.2
host/usb-uhci.c: USB UHCI at I/O 0x6f80, IRQ 48
host/usb-uhci.c: Detected 2 ports
usb.c: new USB bus registered, assigned bus number 1
hub.c: USB hub found
hub.c: 2 ports detected
host/usb-uhci.c: v1.275:USB Universal Host Controller Interface driver
usb.c: registered new driver hiddev
usb.c: registered new driver hid
hid-core.c: v1.8.1 Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>
hid-core.c: USB HID support drivers
Linux video capture interface: v1.00
mice: PS/2 mouse device common for all mice
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 32768 buckets, 512Kbytes
TCP: Hash tables configured (established 262144 bind 65536)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 512kB freed


========================/proc/interrups
------------------------------------------------------------------------------------
           CPU0       CPU1       CPU2       CPU3       
 32:        376          0          2          0   IO-SAPIC-edge  keyboard
 33:          4          0          0          1   IO-SAPIC-edge  ide1
 34:          6          0          0          2   IO-SAPIC-edge  ide0
 36:         20          0          0          0   IO-SAPIC-edge  PS/2 Mouse
 39:          0          0          0          0  IO-SAPIC-level  acpi
 45:         17          0          0          1   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level  usb-uhci
 49:        102          0          0          6  IO-SAPIC-level  eth0
 51:       3141          6         19        192  IO-SAPIC-level  qla1280
239:     292862     291877     291578     282073          LSAPIC  timer
254:      12665      12194      12568      12817          LSAPIC  IPI
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
	Flags: bus master, medium devsel, latency 64, IRQ 48
	I/O ports at 6f80 [size2]

00:03.3 SMBus: Intel Corp. 82372FB PIIX5 SMBus (rev 01)
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: medium devsel
	I/O ports at c000 [disabled] [size]

00:04.0 PIC: Intel Corp. 683053 Programmable Interrupt Device (rev 01) (prog-if 20 [IO(X)-APIC])
	Flags: bus master, medium devsel, latency 0

00:05.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)
	Subsystem: Intel Corp. 82559 Fast Ethernet LAN on Motherboard
	Flags: bus master, medium devsel, latency 64, IRQ 49
	Memory at 00000000fafe0000 (32-bit, non-prefetchable) [size=4K]
	I/O ports at 6f00 [sized]
	Memory at 00000000fae00000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [dc] Power Management version 2

00:06.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) (prog-if 00 [VGA])
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: bus master, stepping, medium devsel, latency 64, IRQ 50
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
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 51
	I/O ports at 8800 [size%6]
	Memory at 00000000f1ff0000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at 00000000f1fc0000 [disabled] [size8K]
	Capabilities: [44] Power Management version 1

01:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 52
	Memory at 00000000f1fe0000 (32-bit, non-prefetchable) [size%6]

04:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 52
	Memory at 00000000e7ff0000 (32-bit, non-prefetchable) [size%6]

08:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 53
	Memory at 00000000ddff0000 (32-bit, non-prefetchable) [size%6]

0c:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 53
	Memory at 00000000d5ff0000 (32-bit, non-prefetchable) [size%6]

0f:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 54
	Memory at 00000000cdff0000 (32-bit, non-prefetchable) [size%6]

12:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 54
	Memory at 00000000c5ff0000 (32-bit, non-prefetchable) [size%6]


From: "Michael F. Brown" <mbrown@emc.com>
Date: Fri, 06 Apr 2001 15:53:50 +0000
Subject: [Linux-ia64] 2.4.3 ACPI build errors
Message-Id: <marc-linux-ia64-105590693005377@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

I'm trying to build the 2.4.3 kernel after applying the 2.4.3 ia64 patch.
I see the following build errors:

gcc -D__KERNEL__ -I/usr/src/linux-2.4.3/include -Wall -Wstrict-prototypes -=
g -O2 -fomit-frame-pointer -fno-strict-aliasing -pipe  -Wa,-x -ffixed-r13 -=
mfixed-range=F10-f15,f32-f127 -funwind-tables -falign-functions2 -mb-step -=
mconstant-gp   -c -o iosapic.o iosapic.c
iosapic.c: In function `iosapic_init':
iosapic.c:355: structure has no member named `pci_vectors'
iosapic.c:356: structure has no member named `num_pci_vectors'
make[1]: *** [iosapic.o] Error 1
make[1]: Leaving directory `/usr/src/linux-2.4.3/arch/ia64/kernel'
make: *** [_dir_arch/ia64/kernel] Error 2

The appropriate lines of code are:

#ifdef CONFIG_ACPI_KERNEL_CONFIG
		acpi_cf_get_pci_vectors(&pci_irq.route, &pci_irq.num_routes);
#else
		pci_irq.route 			(struct pci_vector_struct *) __va(ia64_boot_param->pci_v=
ectors);
		pci_irq.num_routes =3D ia64_boot_param->num_pci_vectors;
#endif

So to work around this, I've tried setting CONFIG_ACPI_KERNEL_CONFIG.
Using make xconfig, this option is greyed out or disabled.  So I tried
manually adding:

CONFIG_ACPI20=3Dy
CONFIG_ACPI_KERNEL_CONFIG=3Dy

to my .config.  Unfortunately the build process doesn't seem to pick this
up and so since CONFIG_ACPI_KERNEL_CONFIG is not defined when iosapic.c is
compiled the build fails.  Anyone else seen this?  Any pointers would be
helpful.  Below is my .config with the ACPI lines I added.  Let me know if
there is any more information I can provide.

#
# Automatically generated make config: don't edit
#

#
# Code maturity level options
#
CONFIG_EXPERIMENTAL=3Dy

#
# Loadable module support
#
CONFIG_MODULES=3Dy
CONFIG_MODVERSIONS=3Dy
CONFIG_KMOD=3Dy

#
# General setup
#
CONFIG_IA64=3Dy
# CONFIG_ISA is not set
# CONFIG_EISA is not set
# CONFIG_MCA is not set
# CONFIG_SBUS is not set
CONFIG_ITANIUM=3Dy
# CONFIG_MCKINLEY is not set
CONFIG_IA64_GENERIC=3Dy
# CONFIG_IA64_DIG is not set
# CONFIG_IA64_HP_SIM is not set
# CONFIG_IA64_SGI_SN1 is not set
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
CONFIG_IA64_PAGE_SIZE_16KB=3Dy
# CONFIG_IA64_PAGE_SIZE_64KB is not set
CONFIG_IA64_BRL_EMU=3Dy
# CONFIG_ITANIUM_ASTEP_SPECIFIC is not set
CONFIG_ITANIUM_BSTEP_SPECIFIC=3Dy
# CONFIG_ITANIUM_B0_SPECIFIC is not set
# CONFIG_ITANIUM_B1_SPECIFIC is not set
# CONFIG_ITANIUM_B2_SPECIFIC is not set
# CONFIG_ITANIUM_CSTEP_SPECIFIC is not set
CONFIG_ITANIUM_PTCG=3Dy
CONFIG_IA64_L1_CACHE_SHIFT=3D6
CONFIG_KCORE_ELF=3Dy
CONFIG_ACPI20=3Dy
CONFIG_ACPI_KERNEL_CONFIG=3Dy
# CONFIG_SMP is not set
# CONFIG_PERFMON is not set
CONFIG_IA64_PALINFO=3Dy
CONFIG_IA64_EFIVARS=3Dy
CONFIG_NET=3Dy
CONFIG_SYSVIPC=3Dy
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_SYSCTL=3Dy
CONFIG_BINFMT_ELF=3Dy
# CONFIG_BINFMT_MISC is not set
CONFIG_PCI=3Dy
CONFIG_PCI_NAMES=3Dy
CONFIG_HOTPLUG=3Dy

#
# PCMCIA/CardBus support
#
# CONFIG_PCMCIA is not set

#
# Parallel port support
#
# CONFIG_PARPORT is not set

#
# Networking options
#
CONFIG_PACKET=3Dy
# CONFIG_PACKET_MMAP is not set
CONFIG_NETLINK=3Dy
# CONFIG_RTNETLINK is not set
# CONFIG_NETLINK_DEV is not set
# CONFIG_NETFILTER is not set
# CONFIG_FILTER is not set
CONFIG_UNIX=3Dy
CONFIG_INET=3Dy
CONFIG_IP_MULTICAST=3Dy
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_INET_ECN is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_IPV6 is not set
# CONFIG_KHTTPD is not set
# CONFIG_ATM is not set

#
#
#
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
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
# Memory Technology Devices (MTD)
#
# CONFIG_MTD is not set

#
# Plug and Play configuration
#
CONFIG_PNP=3Dy
CONFIG_ISAPNP=3Dy

#
# Block devices
#
CONFIG_BLK_DEV_FD=3Dy
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
CONFIG_BLK_DEV_LOOP=3Dy
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_RAM is not set

#
# I2O device support
#
# CONFIG_I2O is not set

#
# Multi-device support (RAID and LVM)
#
# CONFIG_MD is not set

#
# ATA/IDE/MFM/RLL support
#
CONFIG_IDE=3Dy

#
# IDE, ATA and ATAPI Block devices
#
CONFIG_BLK_DEV_IDE=3Dy

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_HD_IDE is not set
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_IDEDISK=3Dy
# CONFIG_IDEDISK_MULTI_MODE is not set
# CONFIG_BLK_DEV_IDEDISK_VENDOR is not set
# CONFIG_BLK_DEV_COMMERIAL is not set
CONFIG_BLK_DEV_IDECD=3Dy
# CONFIG_BLK_DEV_IDETAPE is not set
CONFIG_BLK_DEV_IDEFLOPPY=3Dm
# CONFIG_BLK_DEV_IDESCSI is not set

#
# IDE chipset support/bugfixes
#
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_ISAPNP is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEPCI=3Dy
CONFIG_IDEPCI_SHARE_IRQ=3Dy
CONFIG_BLK_DEV_IDEDMA_PCI=3Dy
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_IDEDMA_PCI_AUTO=3Dy
CONFIG_BLK_DEV_IDEDMA=3Dy
# CONFIG_IDEDMA_PCI_WIP is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD7409 is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
CONFIG_BLK_DEV_PIIX=3Dy
CONFIG_PIIX_TUNING=3Dy
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_PDC202XX is not set
# CONFIG_BLK_DEV_OSB4 is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_IDE_CHIPSETS is not set
CONFIG_IDEDMA_AUTO=3Dy
# CONFIG_IDEDMA_IVB is not set
# CONFIG_DMA_NONPCI is not set
CONFIG_BLK_DEV_IDE_MODES=3Dy

#
# SCSI support
#
CONFIG_SCSI=3Dy

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dy
CONFIG_SD_EXTRA_DEVS@
CONFIG_CHR_DEV_ST=3Dm
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=3Dy
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_SR_EXTRA_DEVS=3D2
CONFIG_CHR_DEV_SG=3Dm

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
# CONFIG_SCSI_DEBUG_QUEUES is not set
CONFIG_SCSI_MULTI_LUN=3Dy
CONFIG_SCSI_CONSTANTS=3Dy
CONFIG_SCSI_LOGGING=3Dy

#
# SCSI low-level drivers
#
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_7000FASST is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AHA152X is not set
# CONFIG_SCSI_AHA1542 is not set
# CONFIG_SCSI_AHA1740 is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_IN2000 is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_MEGARAID is not set
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
# CONFIG_SCSI_NCR53C8XX is not set
# CONFIG_SCSI_SYM53C8XX is not set
# CONFIG_SCSI_PAS16 is not set
# CONFIG_SCSI_PCI2000 is not set
# CONFIG_SCSI_PCI2220I is not set
# CONFIG_SCSI_PSI240I is not set
# CONFIG_SCSI_QLOGIC_FAS is not set
# CONFIG_SCSI_QLOGIC_ISP is not set
# CONFIG_SCSI_QLOGIC_FC is not set
CONFIG_SCSI_QLOGIC_1280=3Dy
# CONFIG_SCSI_SIM710 is not set
CONFIG_SCSI_SYM53C416=3Dm
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_T128 is not set
# CONFIG_SCSI_U14_34F is not set
CONFIG_SCSI_DEBUG=3Dm

#
# Network device support
#
CONFIG_NETDEVICES=3Dy

#
# ARCnet devices
#
# CONFIG_ARCNET is not set
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_ETHERTAP is not set
# CONFIG_NET_SB1000 is not set

#
# Ethernet (10 or 100Mbit)
#
CONFIG_NET_ETHERNET=3Dy
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_SMC is not set
# CONFIG_NET_VENDOR_RACAL is not set
# CONFIG_AT1700 is not set
# CONFIG_DEPCA is not set
# CONFIG_HP100 is not set
CONFIG_NET_PCI=3Dy
# CONFIG_PCNET32 is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_APRICOT is not set
# CONFIG_TULIP is not set
# CONFIG_DE4X5 is not set
# CONFIG_DGRS is not set
# CONFIG_DM9102 is not set
CONFIG_EEPRO100=3Dy
# CONFIG_EEPRO100_PM is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139TOO is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_TLAN is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_WINBOND_840 is not set
# CONFIG_HAPPYMEAL is not set
# CONFIG_NET_POCKET is not set

#
# Ethernet (1000 Mbit)
#
# CONFIG_ACENIC is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_SK98LIN is not set
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
CONFIG_NET_FC=3Dy
CONFIG_IPHASE5526=3Dm
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
CONFIG_INPUT=3Dm
CONFIG_INPUT_KEYBDEV=3Dm
CONFIG_INPUT_MOUSEDEV=3Dm
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Yv8
CONFIG_INPUT_JOYDEV=3Dm
CONFIG_INPUT_EVDEV=3Dm

#
# Character devices
#
CONFIG_VT=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_SERIAL=3Dy
CONFIG_SERIAL_CONSOLE=3Dy
# CONFIG_SERIAL_EXTENDED is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_UNIX98_PTYS=3Dy
CONFIG_UNIX98_PTY_COUNT%6

#
# I2C support
#
# CONFIG_I2C is not set

#
# Mice
#
# CONFIG_BUSMOUSE is not set
CONFIG_MOUSE=3Dy
CONFIG_PSMOUSE=3Dy
# CONFIG_82C710_MOUSE is not set
# CONFIG_PC110_PAD is not set

#
# Joysticks
#
# CONFIG_JOYSTICK is not set

#
# Input core support is needed for joysticks
#
# CONFIG_QIC02_TAPE is not set

#
# Watchdog Cards
#
# CONFIG_WATCHDOG is not set
# CONFIG_INTEL_RNG is not set
# CONFIG_NVRAM is not set
# CONFIG_RTC is not set
CONFIG_EFI_RTC=3Dy
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# Ftape, the floppy tape device driver
#
# CONFIG_FTAPE is not set
CONFIG_AGP=3Dy
CONFIG_AGP_INTEL=3Dy
CONFIG_AGP_I460=3Dy
CONFIG_AGP_PTE_FIXUPS=3Dy
# CONFIG_AGP_I460_FULLRQ is not set
CONFIG_AGP_PTE_FIXUPS=3Dy
CONFIG_AGP_I810=3Dy
# CONFIG_AGP_VIA is not set
# CONFIG_AGP_AMD is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_ALI is not set
CONFIG_DRM=3Dy
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_GAMMA is not set
CONFIG_DRM_R128=3Dm
CONFIG_DRM_RADEON=3Dm
CONFIG_DRM_I810=3Dm
# CONFIG_DRM_MGA is not set

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set

#
# File systems
#
# CONFIG_QUOTA is not set
CONFIG_AUTOFS_FS=3Dm
CONFIG_AUTOFS4_FS=3Dm
CONFIG_REISERFS_FS=3Dm
# CONFIG_REISERFS_CHECK is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_BFS_FS is not set
CONFIG_FAT_FS=3Dy
CONFIG_MSDOS_FS=3Dy
# CONFIG_UMSDOS_FS is not set
CONFIG_VFAT_FS=3Dy
# CONFIG_EFS_FS is not set
CONFIG_JFFS_FS_VERBOSE=3D0
# CONFIG_CRAMFS is not set
# CONFIG_RAMFS is not set
CONFIG_ISO9660_FS=3Dy
CONFIG_JOLIET=3Dy
# CONFIG_MINIX_FS is not set
# CONFIG_NTFS_FS is not set
# CONFIG_HPFS_FS is not set
CONFIG_PROC_FS=3Dy
# CONFIG_DEVFS_FS is not set
CONFIG_DEVPTS_FS=3Dy
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_EXT2_FS=3Dy
# CONFIG_SYSV_FS is not set
# CONFIG_UDF_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
CONFIG_CODA_FS=3Dy
CONFIG_NFS_FS=3Dy
# CONFIG_NFS_V3 is not set
# CONFIG_NFSD is not set
CONFIG_SUNRPC=3Dy
CONFIG_LOCKD=3Dy
# CONFIG_SMB_FS is not set
# CONFIG_NCP_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=3Dy
# CONFIG_SMB_NLS is not set
CONFIG_NLS=3Dy

#
# Native Language Support
#
CONFIG_NLS_DEFAULT=3D"y"
CONFIG_NLS_CODEPAGE_437=3Dm
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
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_ISO8859_1=3Dm
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_UTF8 is not set

#
# Console drivers
#
CONFIG_VGA_CONSOLE=3Dy

#
# Frame-buffer support
#
# CONFIG_FB is not set

#
# Sound
#
# CONFIG_SOUND is not set

#
# USB support
#
# CONFIG_USB is not set

#
# Simulated drivers
#
# CONFIG_SIMETH is not set
# CONFIG_SIM_SERIAL is not set
# CONFIG_SCSI_SIM is not set

#
# Kernel hacking
#
CONFIG_IA32_SUPPORT=3Dm
# CONFIG_MATHEMU is not set
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_IA64_EARLY_PRINTK=3Dy
# CONFIG_IA64_DEBUG_CMPXCHG is not set
# CONFIG_IA64_DEBUG_IRQ is not set
CONFIG_IA64_PRINT_HAZARDS=3Dy
# CONFIG_DISABLE_VHPT is not set


-Michael F. Brown, Sym API - EMC Corp.

email:  mbrown@emc.com
phone:  (800) 445-2588   x11390

"In theory, there is no difference between theory and practice,
 but in practice, there is."       - Jan L.A. van de Snepscheut




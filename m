From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 10 Aug 2005 16:09:47 +0000
Subject: RE: 2.6.13-rc6 doesn't build with hotplug option off
Message-Id: <200508101609.j7AG9ug16129@unix-os.sc.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_0000_01C59D8B.4349C450"
List-Id: <linux-ia64.vger.kernel.org>
References: <200508100132.j7A1Wqg05828@unix-os.sc.intel.com>
In-Reply-To: <200508100132.j7A1Wqg05828@unix-os.sc.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0000_01C59D8B.4349C450
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Kenji Kaneshige wrote on Wednesday, August 10, 2005 2:49 AM
> Chen, Kenneth W wrote:
> > Using my favorite .config file, it happens that all the hotplug
> > options are off and the kernel doesn't build.
> > 
> >   LD      .tmp_vmlinux1
> > arch/ia64/kernel/built-in.o(.text+0x712): In function `acpi_unregister_ioapic':
> > : undefined reference to `iosapic_remove'
> > make: *** [.tmp_vmlinux1] Error 1
> > 
> > grep HOT .config
> > # CONFIG_HOTPLUG is not set
> > # CONFIG_HOTPLUG_CPU is not set
> > # CONFIG_HOTPLUG_PCI is not set
> > 
> 
> I think the following patch will remove this compile error.
> Could you try this? or could you send me your .config?
> Unfortunately, I don't have the .config in which
> CONFIG_HOTPLUG is not set.

Yeah, it should work now.  config file attached.

------=_NextPart_000_0000_01C59D8B.4349C450
Content-Type: application/octet-stream;
	name="config"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="config"

#=0A=
# Automatically generated make config: don't edit=0A=
# Linux kernel version: 2.6.13-rc6=0A=
# Wed Aug 10 09:08:09 2005=0A=
#=0A=
=0A=
#=0A=
# Code maturity level options=0A=
#=0A=
CONFIG_EXPERIMENTAL=3Dy=0A=
CONFIG_CLEAN_COMPILE=3Dy=0A=
CONFIG_LOCK_KERNEL=3Dy=0A=
CONFIG_INIT_ENV_ARG_LIMIT=3D32=0A=
=0A=
#=0A=
# General setup=0A=
#=0A=
CONFIG_LOCALVERSION=3D""=0A=
CONFIG_SWAP=3Dy=0A=
CONFIG_SYSVIPC=3Dy=0A=
# CONFIG_POSIX_MQUEUE is not set=0A=
# CONFIG_BSD_PROCESS_ACCT is not set=0A=
CONFIG_SYSCTL=3Dy=0A=
# CONFIG_AUDIT is not set=0A=
# CONFIG_HOTPLUG is not set=0A=
CONFIG_KOBJECT_UEVENT=3Dy=0A=
# CONFIG_IKCONFIG is not set=0A=
# CONFIG_CPUSETS is not set=0A=
# CONFIG_EMBEDDED is not set=0A=
CONFIG_KALLSYMS=3Dy=0A=
CONFIG_KALLSYMS_EXTRA_PASS=3Dy=0A=
CONFIG_PRINTK=3Dy=0A=
CONFIG_BUG=3Dy=0A=
CONFIG_BASE_FULL=3Dy=0A=
CONFIG_FUTEX=3Dy=0A=
CONFIG_EPOLL=3Dy=0A=
CONFIG_SHMEM=3Dy=0A=
CONFIG_CC_ALIGN_FUNCTIONS=3D0=0A=
CONFIG_CC_ALIGN_LABELS=3D0=0A=
CONFIG_CC_ALIGN_LOOPS=3D0=0A=
CONFIG_CC_ALIGN_JUMPS=3D0=0A=
# CONFIG_TINY_SHMEM is not set=0A=
CONFIG_BASE_SMALL=3D0=0A=
=0A=
#=0A=
# Loadable module support=0A=
#=0A=
CONFIG_MODULES=3Dy=0A=
CONFIG_MODULE_UNLOAD=3Dy=0A=
# CONFIG_MODULE_FORCE_UNLOAD is not set=0A=
CONFIG_OBSOLETE_MODPARM=3Dy=0A=
# CONFIG_MODVERSIONS is not set=0A=
# CONFIG_MODULE_SRCVERSION_ALL is not set=0A=
CONFIG_KMOD=3Dy=0A=
CONFIG_STOP_MACHINE=3Dy=0A=
=0A=
#=0A=
# Processor type and features=0A=
#=0A=
CONFIG_IA64=3Dy=0A=
CONFIG_64BIT=3Dy=0A=
CONFIG_MMU=3Dy=0A=
CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy=0A=
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy=0A=
CONFIG_TIME_INTERPOLATION=3Dy=0A=
CONFIG_EFI=3Dy=0A=
CONFIG_GENERIC_IOMAP=3Dy=0A=
CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=3Dy=0A=
CONFIG_IA64_GENERIC=3Dy=0A=
# CONFIG_IA64_DIG is not set=0A=
# CONFIG_IA64_HP_ZX1 is not set=0A=
# CONFIG_IA64_HP_ZX1_SWIOTLB is not set=0A=
# CONFIG_IA64_SGI_SN2 is not set=0A=
# CONFIG_IA64_HP_SIM is not set=0A=
# CONFIG_ITANIUM is not set=0A=
CONFIG_MCKINLEY=3Dy=0A=
# CONFIG_IA64_PAGE_SIZE_4KB is not set=0A=
# CONFIG_IA64_PAGE_SIZE_8KB is not set=0A=
CONFIG_IA64_PAGE_SIZE_16KB=3Dy=0A=
# CONFIG_IA64_PAGE_SIZE_64KB is not set=0A=
# CONFIG_HZ_100 is not set=0A=
CONFIG_HZ_250=3Dy=0A=
# CONFIG_HZ_1000 is not set=0A=
CONFIG_HZ=3D250=0A=
CONFIG_IA64_L1_CACHE_SHIFT=3D7=0A=
CONFIG_NUMA=3Dy=0A=
CONFIG_VIRTUAL_MEM_MAP=3Dy=0A=
CONFIG_HOLES_IN_ZONE=3Dy=0A=
CONFIG_ARCH_DISCONTIGMEM_ENABLE=3Dy=0A=
# CONFIG_IA64_CYCLONE is not set=0A=
CONFIG_IOSAPIC=3Dy=0A=
# CONFIG_IA64_SGI_SN_XP is not set=0A=
CONFIG_FORCE_MAX_ZONEORDER=3D18=0A=
CONFIG_SMP=3Dy=0A=
CONFIG_NR_CPUS=3D16=0A=
# CONFIG_HOTPLUG_CPU is not set=0A=
# CONFIG_SCHED_SMT is not set=0A=
# CONFIG_PREEMPT is not set=0A=
CONFIG_SELECT_MEMORY_MODEL=3Dy=0A=
# CONFIG_FLATMEM_MANUAL is not set=0A=
CONFIG_DISCONTIGMEM_MANUAL=3Dy=0A=
# CONFIG_SPARSEMEM_MANUAL is not set=0A=
CONFIG_DISCONTIGMEM=3Dy=0A=
CONFIG_FLAT_NODE_MEM_MAP=3Dy=0A=
CONFIG_NEED_MULTIPLE_NODES=3Dy=0A=
CONFIG_HAVE_DEC_LOCK=3Dy=0A=
# CONFIG_IA32_SUPPORT is not set=0A=
# CONFIG_IA64_MCA_RECOVERY is not set=0A=
# CONFIG_PERFMON is not set=0A=
CONFIG_IA64_PALINFO=3Dy=0A=
CONFIG_ACPI_DEALLOCATE_IRQ=3Dy=0A=
=0A=
#=0A=
# Firmware Drivers=0A=
#=0A=
# CONFIG_EFI_VARS is not set=0A=
# CONFIG_EFI_PCDP is not set=0A=
CONFIG_BINFMT_ELF=3Dy=0A=
# CONFIG_BINFMT_MISC is not set=0A=
=0A=
#=0A=
# Power management and ACPI=0A=
#=0A=
CONFIG_PM=3Dy=0A=
CONFIG_ACPI=3Dy=0A=
=0A=
#=0A=
# ACPI (Advanced Configuration and Power Interface) Support=0A=
#=0A=
CONFIG_ACPI_BOOT=3Dy=0A=
CONFIG_ACPI_INTERPRETER=3Dy=0A=
CONFIG_ACPI_BUTTON=3Dm=0A=
CONFIG_ACPI_VIDEO=3Dm=0A=
# CONFIG_ACPI_HOTKEY is not set=0A=
CONFIG_ACPI_FAN=3Dm=0A=
CONFIG_ACPI_PROCESSOR=3Dm=0A=
CONFIG_ACPI_THERMAL=3Dm=0A=
CONFIG_ACPI_NUMA=3Dy=0A=
CONFIG_ACPI_BLACKLIST_YEAR=3D0=0A=
# CONFIG_ACPI_DEBUG is not set=0A=
CONFIG_ACPI_BUS=3Dy=0A=
CONFIG_ACPI_POWER=3Dy=0A=
CONFIG_ACPI_PCI=3Dy=0A=
CONFIG_ACPI_SYSTEM=3Dy=0A=
# CONFIG_ACPI_CONTAINER is not set=0A=
=0A=
#=0A=
# Bus options (PCI, PCMCIA)=0A=
#=0A=
CONFIG_PCI=3Dy=0A=
CONFIG_PCI_DOMAINS=3Dy=0A=
# CONFIG_PCI_MSI is not set=0A=
# CONFIG_PCI_LEGACY_PROC is not set=0A=
# CONFIG_PCI_NAMES is not set=0A=
=0A=
#=0A=
# PCI Hotplug Support=0A=
#=0A=
# CONFIG_HOTPLUG_PCI is not set=0A=
=0A=
#=0A=
# PCCARD (PCMCIA/CardBus) support=0A=
#=0A=
# CONFIG_PCCARD is not set=0A=
=0A=
#=0A=
# Networking=0A=
#=0A=
CONFIG_NET=3Dy=0A=
=0A=
#=0A=
# Networking options=0A=
#=0A=
CONFIG_PACKET=3Dy=0A=
CONFIG_PACKET_MMAP=3Dy=0A=
CONFIG_UNIX=3Dy=0A=
# CONFIG_NET_KEY is not set=0A=
CONFIG_INET=3Dy=0A=
# CONFIG_IP_MULTICAST is not set=0A=
# CONFIG_IP_ADVANCED_ROUTER is not set=0A=
CONFIG_IP_FIB_HASH=3Dy=0A=
# CONFIG_IP_PNP is not set=0A=
# CONFIG_NET_IPIP is not set=0A=
# CONFIG_NET_IPGRE is not set=0A=
# CONFIG_ARPD is not set=0A=
# CONFIG_SYN_COOKIES is not set=0A=
# CONFIG_INET_AH is not set=0A=
# CONFIG_INET_ESP is not set=0A=
# CONFIG_INET_IPCOMP is not set=0A=
# CONFIG_INET_TUNNEL is not set=0A=
# CONFIG_IP_TCPDIAG is not set=0A=
# CONFIG_IP_TCPDIAG_IPV6 is not set=0A=
# CONFIG_TCP_CONG_ADVANCED is not set=0A=
CONFIG_TCP_CONG_BIC=3Dy=0A=
# CONFIG_IPV6 is not set=0A=
# CONFIG_NETFILTER is not set=0A=
=0A=
#=0A=
# SCTP Configuration (EXPERIMENTAL)=0A=
#=0A=
# CONFIG_IP_SCTP is not set=0A=
# CONFIG_ATM is not set=0A=
# CONFIG_BRIDGE is not set=0A=
# CONFIG_VLAN_8021Q is not set=0A=
# CONFIG_DECNET is not set=0A=
# CONFIG_LLC2 is not set=0A=
# CONFIG_IPX is not set=0A=
# CONFIG_ATALK is not set=0A=
# CONFIG_X25 is not set=0A=
# CONFIG_LAPB is not set=0A=
# CONFIG_NET_DIVERT is not set=0A=
# CONFIG_ECONET is not set=0A=
# CONFIG_WAN_ROUTER is not set=0A=
# CONFIG_NET_SCHED is not set=0A=
# CONFIG_NET_CLS_ROUTE is not set=0A=
=0A=
#=0A=
# Network testing=0A=
#=0A=
# CONFIG_NET_PKTGEN is not set=0A=
# CONFIG_HAMRADIO is not set=0A=
# CONFIG_IRDA is not set=0A=
# CONFIG_BT is not set=0A=
=0A=
#=0A=
# Device Drivers=0A=
#=0A=
=0A=
#=0A=
# Generic Driver Options=0A=
#=0A=
CONFIG_STANDALONE=3Dy=0A=
CONFIG_PREVENT_FIRMWARE_BUILD=3Dy=0A=
# CONFIG_FW_LOADER is not set=0A=
=0A=
#=0A=
# Memory Technology Devices (MTD)=0A=
#=0A=
# CONFIG_MTD is not set=0A=
=0A=
#=0A=
# Parallel port support=0A=
#=0A=
# CONFIG_PARPORT is not set=0A=
=0A=
#=0A=
# Plug and Play support=0A=
#=0A=
# CONFIG_PNP is not set=0A=
=0A=
#=0A=
# Block devices=0A=
#=0A=
# CONFIG_BLK_CPQ_DA is not set=0A=
# CONFIG_BLK_CPQ_CISS_DA is not set=0A=
# CONFIG_BLK_DEV_DAC960 is not set=0A=
# CONFIG_BLK_DEV_UMEM is not set=0A=
# CONFIG_BLK_DEV_COW_COMMON is not set=0A=
CONFIG_BLK_DEV_LOOP=3Dy=0A=
# CONFIG_BLK_DEV_CRYPTOLOOP is not set=0A=
# CONFIG_BLK_DEV_NBD is not set=0A=
# CONFIG_BLK_DEV_SX8 is not set=0A=
# CONFIG_BLK_DEV_UB is not set=0A=
CONFIG_BLK_DEV_RAM=3Dy=0A=
CONFIG_BLK_DEV_RAM_COUNT=3D16=0A=
CONFIG_BLK_DEV_RAM_SIZE=3D16384=0A=
CONFIG_BLK_DEV_INITRD=3Dy=0A=
CONFIG_INITRAMFS_SOURCE=3D""=0A=
# CONFIG_CDROM_PKTCDVD is not set=0A=
=0A=
#=0A=
# IO Schedulers=0A=
#=0A=
CONFIG_IOSCHED_NOOP=3Dy=0A=
CONFIG_IOSCHED_AS=3Dy=0A=
CONFIG_IOSCHED_DEADLINE=3Dy=0A=
CONFIG_IOSCHED_CFQ=3Dy=0A=
# CONFIG_ATA_OVER_ETH is not set=0A=
=0A=
#=0A=
# ATA/ATAPI/MFM/RLL support=0A=
#=0A=
# CONFIG_IDE is not set=0A=
=0A=
#=0A=
# SCSI device support=0A=
#=0A=
CONFIG_SCSI=3Dy=0A=
CONFIG_SCSI_PROC_FS=3Dy=0A=
=0A=
#=0A=
# SCSI support type (disk, tape, CD-ROM)=0A=
#=0A=
CONFIG_BLK_DEV_SD=3Dy=0A=
# CONFIG_CHR_DEV_ST is not set=0A=
# CONFIG_CHR_DEV_OSST is not set=0A=
# CONFIG_BLK_DEV_SR is not set=0A=
# CONFIG_CHR_DEV_SG is not set=0A=
# CONFIG_CHR_DEV_SCH is not set=0A=
=0A=
#=0A=
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs=0A=
#=0A=
# CONFIG_SCSI_MULTI_LUN is not set=0A=
# CONFIG_SCSI_CONSTANTS is not set=0A=
# CONFIG_SCSI_LOGGING is not set=0A=
=0A=
#=0A=
# SCSI Transport Attributes=0A=
#=0A=
# CONFIG_SCSI_SPI_ATTRS is not set=0A=
CONFIG_SCSI_FC_ATTRS=3Dy=0A=
# CONFIG_SCSI_ISCSI_ATTRS is not set=0A=
=0A=
#=0A=
# SCSI low-level drivers=0A=
#=0A=
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set=0A=
# CONFIG_SCSI_3W_9XXX is not set=0A=
# CONFIG_SCSI_ACARD is not set=0A=
# CONFIG_SCSI_AACRAID is not set=0A=
# CONFIG_SCSI_AIC7XXX is not set=0A=
# CONFIG_SCSI_AIC7XXX_OLD is not set=0A=
# CONFIG_SCSI_AIC79XX is not set=0A=
# CONFIG_MEGARAID_NEWGEN is not set=0A=
# CONFIG_MEGARAID_LEGACY is not set=0A=
# CONFIG_SCSI_SATA is not set=0A=
# CONFIG_SCSI_DMX3191D is not set=0A=
# CONFIG_SCSI_FUTURE_DOMAIN is not set=0A=
# CONFIG_SCSI_IPS is not set=0A=
# CONFIG_SCSI_INITIO is not set=0A=
# CONFIG_SCSI_INIA100 is not set=0A=
# CONFIG_SCSI_SYM53C8XX_2 is not set=0A=
# CONFIG_SCSI_IPR is not set=0A=
# CONFIG_SCSI_QLOGIC_FC is not set=0A=
# CONFIG_SCSI_QLOGIC_1280 is not set=0A=
CONFIG_SCSI_QLA2XXX=3Dy=0A=
# CONFIG_SCSI_QLA21XX is not set=0A=
# CONFIG_SCSI_QLA22XX is not set=0A=
# CONFIG_SCSI_QLA2300 is not set=0A=
# CONFIG_SCSI_QLA2322 is not set=0A=
# CONFIG_SCSI_QLA6312 is not set=0A=
# CONFIG_SCSI_QLA24XX is not set=0A=
# CONFIG_SCSI_LPFC is not set=0A=
# CONFIG_SCSI_DC395x is not set=0A=
# CONFIG_SCSI_DC390T is not set=0A=
# CONFIG_SCSI_DEBUG is not set=0A=
=0A=
#=0A=
# Multi-device support (RAID and LVM)=0A=
#=0A=
# CONFIG_MD is not set=0A=
=0A=
#=0A=
# Fusion MPT device support=0A=
#=0A=
CONFIG_FUSION=3Dy=0A=
CONFIG_FUSION_SPI=3Dy=0A=
# CONFIG_FUSION_FC is not set=0A=
CONFIG_FUSION_MAX_SGE=3D128=0A=
# CONFIG_FUSION_CTL is not set=0A=
=0A=
#=0A=
# IEEE 1394 (FireWire) support=0A=
#=0A=
# CONFIG_IEEE1394 is not set=0A=
=0A=
#=0A=
# I2O device support=0A=
#=0A=
# CONFIG_I2O is not set=0A=
=0A=
#=0A=
# Network device support=0A=
#=0A=
CONFIG_NETDEVICES=3Dy=0A=
# CONFIG_DUMMY is not set=0A=
# CONFIG_BONDING is not set=0A=
# CONFIG_EQUALIZER is not set=0A=
# CONFIG_TUN is not set=0A=
=0A=
#=0A=
# ARCnet devices=0A=
#=0A=
# CONFIG_ARCNET is not set=0A=
=0A=
#=0A=
# Ethernet (10 or 100Mbit)=0A=
#=0A=
# CONFIG_NET_ETHERNET is not set=0A=
=0A=
#=0A=
# Ethernet (1000 Mbit)=0A=
#=0A=
# CONFIG_ACENIC is not set=0A=
# CONFIG_DL2K is not set=0A=
CONFIG_E1000=3Dy=0A=
CONFIG_E1000_NAPI=3Dy=0A=
# CONFIG_NS83820 is not set=0A=
# CONFIG_HAMACHI is not set=0A=
# CONFIG_YELLOWFIN is not set=0A=
# CONFIG_R8169 is not set=0A=
# CONFIG_SKGE is not set=0A=
# CONFIG_SK98LIN is not set=0A=
# CONFIG_TIGON3 is not set=0A=
# CONFIG_BNX2 is not set=0A=
=0A=
#=0A=
# Ethernet (10000 Mbit)=0A=
#=0A=
# CONFIG_IXGB is not set=0A=
# CONFIG_S2IO is not set=0A=
=0A=
#=0A=
# Token Ring devices=0A=
#=0A=
# CONFIG_TR is not set=0A=
=0A=
#=0A=
# Wireless LAN (non-hamradio)=0A=
#=0A=
# CONFIG_NET_RADIO is not set=0A=
=0A=
#=0A=
# Wan interfaces=0A=
#=0A=
# CONFIG_WAN is not set=0A=
# CONFIG_FDDI is not set=0A=
# CONFIG_HIPPI is not set=0A=
# CONFIG_PPP is not set=0A=
# CONFIG_SLIP is not set=0A=
# CONFIG_NET_FC is not set=0A=
# CONFIG_SHAPER is not set=0A=
# CONFIG_NETCONSOLE is not set=0A=
# CONFIG_NETPOLL is not set=0A=
# CONFIG_NET_POLL_CONTROLLER is not set=0A=
=0A=
#=0A=
# ISDN subsystem=0A=
#=0A=
# CONFIG_ISDN is not set=0A=
=0A=
#=0A=
# Telephony Support=0A=
#=0A=
# CONFIG_PHONE is not set=0A=
=0A=
#=0A=
# Input device support=0A=
#=0A=
CONFIG_INPUT=3Dy=0A=
=0A=
#=0A=
# Userland interfaces=0A=
#=0A=
CONFIG_INPUT_MOUSEDEV=3Dy=0A=
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set=0A=
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024=0A=
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768=0A=
# CONFIG_INPUT_JOYDEV is not set=0A=
# CONFIG_INPUT_TSDEV is not set=0A=
CONFIG_INPUT_EVDEV=3Dy=0A=
# CONFIG_INPUT_EVBUG is not set=0A=
=0A=
#=0A=
# Input Device Drivers=0A=
#=0A=
CONFIG_INPUT_KEYBOARD=3Dy=0A=
# CONFIG_KEYBOARD_ATKBD is not set=0A=
# CONFIG_KEYBOARD_SUNKBD is not set=0A=
# CONFIG_KEYBOARD_LKKBD is not set=0A=
# CONFIG_KEYBOARD_XTKBD is not set=0A=
# CONFIG_KEYBOARD_NEWTON is not set=0A=
CONFIG_INPUT_MOUSE=3Dy=0A=
# CONFIG_MOUSE_PS2 is not set=0A=
# CONFIG_MOUSE_SERIAL is not set=0A=
# CONFIG_MOUSE_VSXXXAA is not set=0A=
# CONFIG_INPUT_JOYSTICK is not set=0A=
# CONFIG_INPUT_TOUCHSCREEN is not set=0A=
# CONFIG_INPUT_MISC is not set=0A=
=0A=
#=0A=
# Hardware I/O ports=0A=
#=0A=
# CONFIG_SERIO is not set=0A=
# CONFIG_GAMEPORT is not set=0A=
=0A=
#=0A=
# Character devices=0A=
#=0A=
CONFIG_VT=3Dy=0A=
CONFIG_VT_CONSOLE=3Dy=0A=
CONFIG_HW_CONSOLE=3Dy=0A=
# CONFIG_SERIAL_NONSTANDARD is not set=0A=
# CONFIG_SGI_SNSC is not set=0A=
# CONFIG_SGI_TIOCX is not set=0A=
=0A=
#=0A=
# Serial drivers=0A=
#=0A=
CONFIG_SERIAL_8250=3Dy=0A=
CONFIG_SERIAL_8250_CONSOLE=3Dy=0A=
CONFIG_SERIAL_8250_ACPI=3Dy=0A=
CONFIG_SERIAL_8250_NR_UARTS=3D4=0A=
# CONFIG_SERIAL_8250_EXTENDED is not set=0A=
=0A=
#=0A=
# Non-8250 serial port support=0A=
#=0A=
CONFIG_SERIAL_CORE=3Dy=0A=
CONFIG_SERIAL_CORE_CONSOLE=3Dy=0A=
# CONFIG_SERIAL_SGI_L1_CONSOLE is not set=0A=
# CONFIG_SERIAL_JSM is not set=0A=
CONFIG_UNIX98_PTYS=3Dy=0A=
# CONFIG_LEGACY_PTYS is not set=0A=
=0A=
#=0A=
# IPMI=0A=
#=0A=
# CONFIG_IPMI_HANDLER is not set=0A=
=0A=
#=0A=
# Watchdog Cards=0A=
#=0A=
# CONFIG_WATCHDOG is not set=0A=
# CONFIG_HW_RANDOM is not set=0A=
CONFIG_EFI_RTC=3Dy=0A=
# CONFIG_DTLK is not set=0A=
# CONFIG_R3964 is not set=0A=
# CONFIG_APPLICOM is not set=0A=
=0A=
#=0A=
# Ftape, the floppy tape device driver=0A=
#=0A=
# CONFIG_AGP is not set=0A=
# CONFIG_DRM is not set=0A=
CONFIG_RAW_DRIVER=3Dy=0A=
# CONFIG_HPET is not set=0A=
CONFIG_MAX_RAW_DEVS=3D256=0A=
# CONFIG_HANGCHECK_TIMER is not set=0A=
# CONFIG_MMTIMER is not set=0A=
=0A=
#=0A=
# TPM devices=0A=
#=0A=
# CONFIG_TCG_TPM is not set=0A=
=0A=
#=0A=
# I2C support=0A=
#=0A=
# CONFIG_I2C is not set=0A=
# CONFIG_I2C_SENSOR is not set=0A=
=0A=
#=0A=
# Dallas's 1-wire bus=0A=
#=0A=
# CONFIG_W1 is not set=0A=
=0A=
#=0A=
# Hardware Monitoring support=0A=
#=0A=
# CONFIG_HWMON is not set=0A=
=0A=
#=0A=
# Misc devices=0A=
#=0A=
=0A=
#=0A=
# Multimedia devices=0A=
#=0A=
# CONFIG_VIDEO_DEV is not set=0A=
=0A=
#=0A=
# Digital Video Broadcasting Devices=0A=
#=0A=
# CONFIG_DVB is not set=0A=
=0A=
#=0A=
# Graphics support=0A=
#=0A=
# CONFIG_FB is not set=0A=
=0A=
#=0A=
# Console display driver support=0A=
#=0A=
CONFIG_VGA_CONSOLE=3Dy=0A=
CONFIG_DUMMY_CONSOLE=3Dy=0A=
=0A=
#=0A=
# Sound=0A=
#=0A=
# CONFIG_SOUND is not set=0A=
=0A=
#=0A=
# USB support=0A=
#=0A=
CONFIG_USB_ARCH_HAS_HCD=3Dy=0A=
CONFIG_USB_ARCH_HAS_OHCI=3Dy=0A=
CONFIG_USB=3Dy=0A=
# CONFIG_USB_DEBUG is not set=0A=
=0A=
#=0A=
# Miscellaneous USB options=0A=
#=0A=
# CONFIG_USB_DEVICEFS is not set=0A=
# CONFIG_USB_BANDWIDTH is not set=0A=
# CONFIG_USB_DYNAMIC_MINORS is not set=0A=
# CONFIG_USB_SUSPEND is not set=0A=
# CONFIG_USB_OTG is not set=0A=
=0A=
#=0A=
# USB Host Controller Drivers=0A=
#=0A=
# CONFIG_USB_EHCI_HCD is not set=0A=
# CONFIG_USB_ISP116X_HCD is not set=0A=
# CONFIG_USB_OHCI_HCD is not set=0A=
CONFIG_USB_UHCI_HCD=3Dy=0A=
# CONFIG_USB_SL811_HCD is not set=0A=
=0A=
#=0A=
# USB Device Class drivers=0A=
#=0A=
# CONFIG_USB_BLUETOOTH_TTY is not set=0A=
# CONFIG_USB_ACM is not set=0A=
# CONFIG_USB_PRINTER is not set=0A=
=0A=
#=0A=
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support' may also be =
needed; see USB_STORAGE Help for more information=0A=
#=0A=
# CONFIG_USB_STORAGE is not set=0A=
=0A=
#=0A=
# USB Input Devices=0A=
#=0A=
CONFIG_USB_HID=3Dy=0A=
CONFIG_USB_HIDINPUT=3Dy=0A=
# CONFIG_HID_FF is not set=0A=
# CONFIG_USB_HIDDEV is not set=0A=
# CONFIG_USB_AIPTEK is not set=0A=
# CONFIG_USB_WACOM is not set=0A=
# CONFIG_USB_ACECAD is not set=0A=
# CONFIG_USB_KBTAB is not set=0A=
# CONFIG_USB_POWERMATE is not set=0A=
# CONFIG_USB_MTOUCH is not set=0A=
# CONFIG_USB_ITMTOUCH is not set=0A=
# CONFIG_USB_EGALAX is not set=0A=
# CONFIG_USB_XPAD is not set=0A=
# CONFIG_USB_ATI_REMOTE is not set=0A=
# CONFIG_USB_KEYSPAN_REMOTE is not set=0A=
=0A=
#=0A=
# USB Imaging devices=0A=
#=0A=
# CONFIG_USB_MDC800 is not set=0A=
# CONFIG_USB_MICROTEK is not set=0A=
=0A=
#=0A=
# USB Multimedia devices=0A=
#=0A=
# CONFIG_USB_DABUSB is not set=0A=
=0A=
#=0A=
# Video4Linux support is needed for USB Multimedia device support=0A=
#=0A=
=0A=
#=0A=
# USB Network Adapters=0A=
#=0A=
# CONFIG_USB_CATC is not set=0A=
# CONFIG_USB_KAWETH is not set=0A=
# CONFIG_USB_PEGASUS is not set=0A=
# CONFIG_USB_RTL8150 is not set=0A=
# CONFIG_USB_USBNET is not set=0A=
# CONFIG_USB_MON is not set=0A=
=0A=
#=0A=
# USB port drivers=0A=
#=0A=
=0A=
#=0A=
# USB Serial Converter support=0A=
#=0A=
# CONFIG_USB_SERIAL is not set=0A=
=0A=
#=0A=
# USB Miscellaneous drivers=0A=
#=0A=
# CONFIG_USB_EMI62 is not set=0A=
# CONFIG_USB_EMI26 is not set=0A=
# CONFIG_USB_AUERSWALD is not set=0A=
# CONFIG_USB_RIO500 is not set=0A=
# CONFIG_USB_LEGOTOWER is not set=0A=
# CONFIG_USB_LCD is not set=0A=
# CONFIG_USB_LED is not set=0A=
# CONFIG_USB_CYTHERM is not set=0A=
# CONFIG_USB_PHIDGETKIT is not set=0A=
# CONFIG_USB_PHIDGETSERVO is not set=0A=
# CONFIG_USB_IDMOUSE is not set=0A=
# CONFIG_USB_LD is not set=0A=
=0A=
#=0A=
# USB DSL modem support=0A=
#=0A=
=0A=
#=0A=
# USB Gadget Support=0A=
#=0A=
# CONFIG_USB_GADGET is not set=0A=
=0A=
#=0A=
# MMC/SD Card support=0A=
#=0A=
# CONFIG_MMC is not set=0A=
=0A=
#=0A=
# InfiniBand support=0A=
#=0A=
# CONFIG_INFINIBAND is not set=0A=
=0A=
#=0A=
# SN Devices=0A=
#=0A=
=0A=
#=0A=
# File systems=0A=
#=0A=
CONFIG_EXT2_FS=3Dy=0A=
# CONFIG_EXT2_FS_XATTR is not set=0A=
# CONFIG_EXT2_FS_XIP is not set=0A=
CONFIG_EXT3_FS=3Dy=0A=
# CONFIG_EXT3_FS_XATTR is not set=0A=
CONFIG_JBD=3Dy=0A=
# CONFIG_JBD_DEBUG is not set=0A=
# CONFIG_REISERFS_FS is not set=0A=
# CONFIG_JFS_FS is not set=0A=
# CONFIG_FS_POSIX_ACL is not set=0A=
=0A=
#=0A=
# XFS support=0A=
#=0A=
# CONFIG_XFS_FS is not set=0A=
# CONFIG_MINIX_FS is not set=0A=
# CONFIG_ROMFS_FS is not set=0A=
# CONFIG_INOTIFY is not set=0A=
# CONFIG_QUOTA is not set=0A=
CONFIG_DNOTIFY=3Dy=0A=
# CONFIG_AUTOFS_FS is not set=0A=
# CONFIG_AUTOFS4_FS is not set=0A=
=0A=
#=0A=
# CD-ROM/DVD Filesystems=0A=
#=0A=
# CONFIG_ISO9660_FS is not set=0A=
# CONFIG_UDF_FS is not set=0A=
=0A=
#=0A=
# DOS/FAT/NT Filesystems=0A=
#=0A=
CONFIG_FAT_FS=3Dy=0A=
CONFIG_MSDOS_FS=3Dy=0A=
CONFIG_VFAT_FS=3Dy=0A=
CONFIG_FAT_DEFAULT_CODEPAGE=3D437=0A=
CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"=0A=
# CONFIG_NTFS_FS is not set=0A=
=0A=
#=0A=
# Pseudo filesystems=0A=
#=0A=
CONFIG_PROC_FS=3Dy=0A=
CONFIG_PROC_KCORE=3Dy=0A=
CONFIG_SYSFS=3Dy=0A=
# CONFIG_DEVPTS_FS_XATTR is not set=0A=
CONFIG_TMPFS=3Dy=0A=
CONFIG_TMPFS_XATTR=3Dy=0A=
# CONFIG_TMPFS_SECURITY is not set=0A=
CONFIG_HUGETLBFS=3Dy=0A=
CONFIG_HUGETLB_PAGE=3Dy=0A=
CONFIG_RAMFS=3Dy=0A=
=0A=
#=0A=
# Miscellaneous filesystems=0A=
#=0A=
# CONFIG_ADFS_FS is not set=0A=
# CONFIG_AFFS_FS is not set=0A=
# CONFIG_HFS_FS is not set=0A=
# CONFIG_HFSPLUS_FS is not set=0A=
# CONFIG_BEFS_FS is not set=0A=
# CONFIG_BFS_FS is not set=0A=
# CONFIG_EFS_FS is not set=0A=
# CONFIG_CRAMFS is not set=0A=
# CONFIG_VXFS_FS is not set=0A=
# CONFIG_HPFS_FS is not set=0A=
# CONFIG_QNX4FS_FS is not set=0A=
# CONFIG_SYSV_FS is not set=0A=
# CONFIG_UFS_FS is not set=0A=
=0A=
#=0A=
# Network File Systems=0A=
#=0A=
# CONFIG_NFS_FS is not set=0A=
# CONFIG_NFSD is not set=0A=
# CONFIG_SMB_FS is not set=0A=
# CONFIG_CIFS is not set=0A=
# CONFIG_NCP_FS is not set=0A=
# CONFIG_CODA_FS is not set=0A=
# CONFIG_AFS_FS is not set=0A=
=0A=
#=0A=
# Partition Types=0A=
#=0A=
CONFIG_PARTITION_ADVANCED=3Dy=0A=
# CONFIG_ACORN_PARTITION is not set=0A=
# CONFIG_OSF_PARTITION is not set=0A=
# CONFIG_AMIGA_PARTITION is not set=0A=
# CONFIG_ATARI_PARTITION is not set=0A=
# CONFIG_MAC_PARTITION is not set=0A=
CONFIG_MSDOS_PARTITION=3Dy=0A=
# CONFIG_BSD_DISKLABEL is not set=0A=
# CONFIG_MINIX_SUBPARTITION is not set=0A=
# CONFIG_SOLARIS_X86_PARTITION is not set=0A=
# CONFIG_UNIXWARE_DISKLABEL is not set=0A=
# CONFIG_LDM_PARTITION is not set=0A=
# CONFIG_SGI_PARTITION is not set=0A=
# CONFIG_ULTRIX_PARTITION is not set=0A=
# CONFIG_SUN_PARTITION is not set=0A=
CONFIG_EFI_PARTITION=3Dy=0A=
=0A=
#=0A=
# Native Language Support=0A=
#=0A=
CONFIG_NLS=3Dy=0A=
CONFIG_NLS_DEFAULT=3D"iso8859-1"=0A=
CONFIG_NLS_CODEPAGE_437=3Dy=0A=
# CONFIG_NLS_CODEPAGE_737 is not set=0A=
# CONFIG_NLS_CODEPAGE_775 is not set=0A=
# CONFIG_NLS_CODEPAGE_850 is not set=0A=
# CONFIG_NLS_CODEPAGE_852 is not set=0A=
# CONFIG_NLS_CODEPAGE_855 is not set=0A=
# CONFIG_NLS_CODEPAGE_857 is not set=0A=
# CONFIG_NLS_CODEPAGE_860 is not set=0A=
# CONFIG_NLS_CODEPAGE_861 is not set=0A=
# CONFIG_NLS_CODEPAGE_862 is not set=0A=
# CONFIG_NLS_CODEPAGE_863 is not set=0A=
# CONFIG_NLS_CODEPAGE_864 is not set=0A=
# CONFIG_NLS_CODEPAGE_865 is not set=0A=
# CONFIG_NLS_CODEPAGE_866 is not set=0A=
# CONFIG_NLS_CODEPAGE_869 is not set=0A=
# CONFIG_NLS_CODEPAGE_936 is not set=0A=
# CONFIG_NLS_CODEPAGE_950 is not set=0A=
# CONFIG_NLS_CODEPAGE_932 is not set=0A=
# CONFIG_NLS_CODEPAGE_949 is not set=0A=
# CONFIG_NLS_CODEPAGE_874 is not set=0A=
# CONFIG_NLS_ISO8859_8 is not set=0A=
# CONFIG_NLS_CODEPAGE_1250 is not set=0A=
# CONFIG_NLS_CODEPAGE_1251 is not set=0A=
# CONFIG_NLS_ASCII is not set=0A=
CONFIG_NLS_ISO8859_1=3Dy=0A=
# CONFIG_NLS_ISO8859_2 is not set=0A=
# CONFIG_NLS_ISO8859_3 is not set=0A=
# CONFIG_NLS_ISO8859_4 is not set=0A=
# CONFIG_NLS_ISO8859_5 is not set=0A=
# CONFIG_NLS_ISO8859_6 is not set=0A=
# CONFIG_NLS_ISO8859_7 is not set=0A=
# CONFIG_NLS_ISO8859_9 is not set=0A=
# CONFIG_NLS_ISO8859_13 is not set=0A=
# CONFIG_NLS_ISO8859_14 is not set=0A=
# CONFIG_NLS_ISO8859_15 is not set=0A=
# CONFIG_NLS_KOI8_R is not set=0A=
# CONFIG_NLS_KOI8_U is not set=0A=
# CONFIG_NLS_UTF8 is not set=0A=
=0A=
#=0A=
# Library routines=0A=
#=0A=
# CONFIG_CRC_CCITT is not set=0A=
CONFIG_CRC32=3Dy=0A=
# CONFIG_LIBCRC32C is not set=0A=
CONFIG_GENERIC_HARDIRQS=3Dy=0A=
CONFIG_GENERIC_IRQ_PROBE=3Dy=0A=
=0A=
#=0A=
# HP Simulator drivers=0A=
#=0A=
# CONFIG_HP_SIMETH is not set=0A=
# CONFIG_HP_SIMSERIAL is not set=0A=
# CONFIG_HP_SIMSCSI is not set=0A=
=0A=
#=0A=
# Profiling support=0A=
#=0A=
# CONFIG_PROFILING is not set=0A=
=0A=
#=0A=
# Kernel hacking=0A=
#=0A=
# CONFIG_PRINTK_TIME is not set=0A=
# CONFIG_DEBUG_KERNEL is not set=0A=
CONFIG_LOG_BUF_SHIFT=3D16=0A=
CONFIG_IA64_GRANULE_16MB=3Dy=0A=
# CONFIG_IA64_GRANULE_64MB is not set=0A=
=0A=
#=0A=
# Security options=0A=
#=0A=
# CONFIG_KEYS is not set=0A=
# CONFIG_SECURITY is not set=0A=
=0A=
#=0A=
# Cryptographic options=0A=
#=0A=
# CONFIG_CRYPTO is not set=0A=
=0A=
#=0A=
# Hardware crypto devices=0A=
#=0A=

------=_NextPart_000_0000_01C59D8B.4349C450--


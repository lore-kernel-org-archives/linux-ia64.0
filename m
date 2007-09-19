From: Jes Sorensen <jes@sgi.com>
Date: Wed, 19 Sep 2007 09:54:55 +0000
Subject: [patch] update sn2_defconfig
Message-Id: <46F0F1EF.3050409@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030207050504050400060302"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030207050504050400060302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I have been getting a couple of reports that the sn2_defconfig asks
too many questions now, so here is an update.

Cheers,
Jes


--------------030207050504050400060302
Content-Type: text/plain;
 name="sn-defconfig-180907.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sn-defconfig-180907.diff"

Update defonfig file for sn2 to match recent changes in config options.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/configs/sn2_defconfig |  443 +++++++++++++++++-----------------------
 1 file changed, 189 insertions(+), 254 deletions(-)

Index: linux-2.6/arch/ia64/configs/sn2_defconfig
===================================================================
--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig
+++ linux-2.6/arch/ia64/configs/sn2_defconfig
@@ -1,40 +1,40 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.19-rc1
-# Mon Oct  9 10:53:59 2006
+# Linux kernel version: 2.6.23-rc6
+# Tue Sep 18 11:24:01 2007
 #
 CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
 
 #
-# Code maturity level options
+# General setup
 #
 CONFIG_EXPERIMENTAL=y
 CONFIG_LOCK_KERNEL=y
 CONFIG_INIT_ENV_ARG_LIMIT=32
-
-#
-# General setup
-#
 CONFIG_LOCALVERSION=""
 # CONFIG_LOCALVERSION_AUTO is not set
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
-# CONFIG_IPC_NS is not set
+CONFIG_SYSVIPC_SYSCTL=y
 CONFIG_POSIX_MQUEUE=y
 # CONFIG_BSD_PROCESS_ACCT is not set
 CONFIG_TASKSTATS=y
 # CONFIG_TASK_DELAY_ACCT is not set
-# CONFIG_UTS_NS is not set
+CONFIG_TASK_XACCT=y
+CONFIG_TASK_IO_ACCOUNTING=y
+# CONFIG_USER_NS is not set
 # CONFIG_AUDIT is not set
 # CONFIG_IKCONFIG is not set
+CONFIG_LOG_BUF_SHIFT=20
 CONFIG_CPUSETS=y
+CONFIG_SYSFS_DEPRECATED=y
 CONFIG_RELAY=y
+CONFIG_BLK_DEV_INITRD=y
 CONFIG_INITRAMFS_SOURCE=""
 CONFIG_CC_OPTIMIZE_FOR_SIZE=y
-CONFIG_TASK_XACCT=y
 CONFIG_SYSCTL=y
 # CONFIG_EMBEDDED is not set
-# CONFIG_SYSCTL_SYSCALL is not set
+CONFIG_SYSCTL_SYSCALL=y
 CONFIG_KALLSYMS=y
 CONFIG_KALLSYMS_ALL=y
 # CONFIG_KALLSYMS_EXTRA_PASS is not set
@@ -44,18 +44,20 @@ CONFIG_BUG=y
 CONFIG_ELF_CORE=y
 CONFIG_BASE_FULL=y
 CONFIG_FUTEX=y
+CONFIG_ANON_INODES=y
 CONFIG_EPOLL=y
+CONFIG_SIGNALFD=y
+CONFIG_TIMERFD=y
+CONFIG_EVENTFD=y
 CONFIG_SHMEM=y
-CONFIG_SLUB=y
 CONFIG_VM_EVENT_COUNTERS=y
+CONFIG_SLUB_DEBUG=y
+# CONFIG_SLAB is not set
+CONFIG_SLUB=y
+# CONFIG_SLOB is not set
 CONFIG_RT_MUTEXES=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
-# CONFIG_SLOB is not set
-
-#
-# Loadable module support
-#
 CONFIG_MODULES=y
 CONFIG_MODULE_UNLOAD=y
 # CONFIG_MODULE_FORCE_UNLOAD is not set
@@ -63,12 +65,9 @@ CONFIG_MODULE_UNLOAD=y
 # CONFIG_MODULE_SRCVERSION_ALL is not set
 CONFIG_KMOD=y
 CONFIG_STOP_MACHINE=y
-
-#
-# Block layer
-#
 CONFIG_BLOCK=y
 # CONFIG_BLK_DEV_IO_TRACE is not set
+CONFIG_BLK_DEV_BSG=y
 
 #
 # IO Schedulers
@@ -88,12 +87,15 @@ CONFIG_DEFAULT_IOSCHED="anticipatory"
 #
 CONFIG_IA64=y
 CONFIG_64BIT=y
+CONFIG_QUICKLIST=y
 CONFIG_MMU=y
-CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
+# CONFIG_ARCH_HAS_ILOG2_U32 is not set
+# CONFIG_ARCH_HAS_ILOG2_U64 is not set
 CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_GENERIC_TIME=y
+CONFIG_GENERIC_TIME_VSYSCALL=y
 CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
@@ -116,6 +118,7 @@ CONFIG_IA64_PAGE_SIZE_16KB=y
 CONFIG_PGTABLE_4=y
 # CONFIG_HZ_100 is not set
 CONFIG_HZ_250=y
+# CONFIG_HZ_300 is not set
 # CONFIG_HZ_1000 is not set
 CONFIG_HZ=250
 CONFIG_IA64_L1_CACHE_SHIFT=7
@@ -128,7 +131,10 @@ CONFIG_NR_CPUS=1024
 # CONFIG_HOTPLUG_CPU is not set
 CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
 CONFIG_SCHED_SMT=y
-CONFIG_PREEMPT=y
+CONFIG_PREEMPT_NONE=y
+# CONFIG_PREEMPT_VOLUNTARY is not set
+# CONFIG_PREEMPT is not set
+CONFIG_PREEMPT_BKL=y
 CONFIG_SELECT_MEMORY_MODEL=y
 # CONFIG_FLATMEM_MANUAL is not set
 CONFIG_DISCONTIGMEM_MANUAL=y
@@ -140,6 +146,9 @@ CONFIG_NEED_MULTIPLE_NODES=y
 CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_MIGRATION=y
 CONFIG_RESOURCES_64BIT=y
+CONFIG_ZONE_DMA_FLAG=0
+CONFIG_NR_QUICK=1
+CONFIG_VIRT_TO_BUS=y
 CONFIG_ARCH_SELECT_MEMORY_MODEL=y
 CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_ARCH_FLATMEM_ENABLE=y
@@ -154,16 +163,17 @@ CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
 CONFIG_HAVE_ARCH_NODEDATA_EXTENSION=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
+CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
+CONFIG_IA64_MC_ERR_INJECT=y
 CONFIG_SGI_SN=y
 # CONFIG_IA64_ESI is not set
 
 #
 # SN Devices
 #
-CONFIG_SGI_IOC4=y
 CONFIG_SGI_IOC3=y
 
 #
@@ -171,6 +181,7 @@ CONFIG_SGI_IOC3=y
 #
 CONFIG_EFI_VARS=y
 CONFIG_EFI_PCDP=y
+CONFIG_DMIID=y
 CONFIG_BINFMT_ELF=y
 # CONFIG_BINFMT_MISC is not set
 
@@ -180,12 +191,9 @@ CONFIG_BINFMT_ELF=y
 CONFIG_PM=y
 # CONFIG_PM_LEGACY is not set
 # CONFIG_PM_DEBUG is not set
-# CONFIG_PM_SYSFS_DEPRECATED is not set
-
-#
-# ACPI (Advanced Configuration and Power Interface) Support
-#
 CONFIG_ACPI=y
+# CONFIG_ACPI_PROCFS is not set
+CONFIG_ACPI_PROC_EVENT=y
 # CONFIG_ACPI_BUTTON is not set
 # CONFIG_ACPI_FAN is not set
 # CONFIG_ACPI_DOCK is not set
@@ -208,17 +216,14 @@ CONFIG_ACPI_SYSTEM=y
 #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
+CONFIG_PCI_SYSCALL=y
 CONFIG_PCIEPORTBUS=y
 CONFIG_HOTPLUG_PCI_PCIE=y
 # CONFIG_HOTPLUG_PCI_PCIE_POLL_EVENT_MODE is not set
 CONFIG_PCIEAER=y
+CONFIG_ARCH_SUPPORTS_MSI=y
 # CONFIG_PCI_MSI is not set
-# CONFIG_PCI_MULTITHREAD_PROBE is not set
 # CONFIG_PCI_DEBUG is not set
-
-#
-# PCI Hotplug Support
-#
 CONFIG_HOTPLUG_PCI=y
 # CONFIG_HOTPLUG_PCI_FAKE is not set
 # CONFIG_HOTPLUG_PCI_ACPI is not set
@@ -239,13 +244,13 @@ CONFIG_NET=y
 #
 # Networking options
 #
-# CONFIG_NETDEBUG is not set
 CONFIG_PACKET=y
 CONFIG_PACKET_MMAP=y
 CONFIG_UNIX=y
 CONFIG_XFRM=y
 # CONFIG_XFRM_USER is not set
 # CONFIG_XFRM_SUB_POLICY is not set
+# CONFIG_XFRM_MIGRATE is not set
 # CONFIG_NET_KEY is not set
 CONFIG_INET=y
 CONFIG_IP_MULTICAST=y
@@ -261,7 +266,7 @@ CONFIG_SYN_COOKIES=y
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_XFRM_TUNNEL is not set
-# CONFIG_INET_TUNNEL is not set
+CONFIG_INET_TUNNEL=m
 CONFIG_INET_XFRM_MODE_TRANSPORT=y
 CONFIG_INET_XFRM_MODE_TUNNEL=y
 CONFIG_INET_XFRM_MODE_BEET=y
@@ -270,9 +275,11 @@ CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
 CONFIG_TCP_CONG_CUBIC=y
 CONFIG_DEFAULT_TCP_CONG="cubic"
+# CONFIG_TCP_MD5SIG is not set
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
 # CONFIG_IPV6_ROUTER_PREF is not set
+# CONFIG_IPV6_OPTIMISTIC_DAD is not set
 # CONFIG_INET6_AH is not set
 # CONFIG_INET6_ESP is not set
 # CONFIG_INET6_IPCOMP is not set
@@ -283,25 +290,13 @@ CONFIG_INET6_XFRM_MODE_TRANSPORT=m
 CONFIG_INET6_XFRM_MODE_TUNNEL=m
 CONFIG_INET6_XFRM_MODE_BEET=m
 # CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
+CONFIG_IPV6_SIT=m
 # CONFIG_IPV6_TUNNEL is not set
-# CONFIG_IPV6_SUBTREES is not set
 # CONFIG_IPV6_MULTIPLE_TABLES is not set
 # CONFIG_NETWORK_SECMARK is not set
 # CONFIG_NETFILTER is not set
-
-#
-# DCCP Configuration (EXPERIMENTAL)
-#
 # CONFIG_IP_DCCP is not set
-
-#
-# SCTP Configuration (EXPERIMENTAL)
-#
 # CONFIG_IP_SCTP is not set
-
-#
-# TIPC Configuration (EXPERIMENTAL)
-#
 # CONFIG_TIPC is not set
 # CONFIG_ATM is not set
 # CONFIG_BRIDGE is not set
@@ -327,7 +322,17 @@ CONFIG_INET6_XFRM_MODE_BEET=m
 # CONFIG_HAMRADIO is not set
 # CONFIG_IRDA is not set
 # CONFIG_BT is not set
+# CONFIG_AF_RXRPC is not set
+
+#
+# Wireless
+#
+# CONFIG_CFG80211 is not set
+# CONFIG_WIRELESS_EXT is not set
+# CONFIG_MAC80211 is not set
 # CONFIG_IEEE80211 is not set
+# CONFIG_RFKILL is not set
+# CONFIG_NET_9P is not set
 
 #
 # Device Drivers
@@ -340,31 +345,19 @@ CONFIG_STANDALONE=y
 CONFIG_PREVENT_FIRMWARE_BUILD=y
 CONFIG_FW_LOADER=y
 # CONFIG_DEBUG_DRIVER is not set
+# CONFIG_DEBUG_DEVRES is not set
 # CONFIG_SYS_HYPERVISOR is not set
-
-#
-# Connector - unified userspace <-> kernelspace linker
-#
 # CONFIG_CONNECTOR is not set
-
-#
-# Memory Technology Devices (MTD)
-#
 # CONFIG_MTD is not set
-
-#
-# Parallel port support
-#
 # CONFIG_PARPORT is not set
+CONFIG_PNP=y
+# CONFIG_PNP_DEBUG is not set
 
 #
-# Plug and Play support
-#
-# CONFIG_PNP is not set
-
-#
-# Block devices
+# Protocols
 #
+CONFIG_PNPACPI=y
+CONFIG_BLK_DEV=y
 # CONFIG_BLK_CPQ_DA is not set
 # CONFIG_BLK_CPQ_CISS_DA is not set
 # CONFIG_BLK_DEV_DAC960 is not set
@@ -379,13 +372,13 @@ CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_COUNT=16
 CONFIG_BLK_DEV_RAM_SIZE=4096
 CONFIG_BLK_DEV_RAM_BLOCKSIZE=1024
-CONFIG_BLK_DEV_INITRD=y
 # CONFIG_CDROM_PKTCDVD is not set
 CONFIG_ATA_OVER_ETH=m
-
-#
-# ATA/ATAPI/MFM/RLL support
-#
+CONFIG_MISC_DEVICES=y
+# CONFIG_PHANTOM is not set
+# CONFIG_EEPROM_93CX6 is not set
+CONFIG_SGI_IOC4=y
+# CONFIG_TIFM_CORE is not set
 CONFIG_IDE=y
 CONFIG_IDE_MAX_HWIFS=4
 CONFIG_BLK_DEV_IDE=y
@@ -400,20 +393,23 @@ CONFIG_BLK_DEV_IDECD=y
 # CONFIG_BLK_DEV_IDETAPE is not set
 # CONFIG_BLK_DEV_IDEFLOPPY is not set
 # CONFIG_BLK_DEV_IDESCSI is not set
+# CONFIG_BLK_DEV_IDEACPI is not set
 # CONFIG_IDE_TASK_IOCTL is not set
+CONFIG_IDE_PROC_FS=y
 
 #
 # IDE chipset support/bugfixes
 #
 CONFIG_IDE_GENERIC=y
+# CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
 CONFIG_IDEPCI_SHARE_IRQ=y
+CONFIG_IDEPCI_PCIBUS_ORDER=y
 # CONFIG_BLK_DEV_OFFBOARD is not set
 # CONFIG_BLK_DEV_GENERIC is not set
 # CONFIG_BLK_DEV_OPTI621 is not set
 CONFIG_BLK_DEV_IDEDMA_PCI=y
 # CONFIG_BLK_DEV_IDEDMA_FORCED is not set
-CONFIG_IDEDMA_PCI_AUTO=y
 # CONFIG_IDEDMA_ONLYDISK is not set
 # CONFIG_BLK_DEV_AEC62XX is not set
 # CONFIG_BLK_DEV_ALI15X3 is not set
@@ -428,6 +424,7 @@ CONFIG_IDEDMA_PCI_AUTO=y
 # CONFIG_BLK_DEV_JMICRON is not set
 # CONFIG_BLK_DEV_SC1200 is not set
 # CONFIG_BLK_DEV_PIIX is not set
+# CONFIG_BLK_DEV_IT8213 is not set
 # CONFIG_BLK_DEV_IT821X is not set
 # CONFIG_BLK_DEV_NS87415 is not set
 # CONFIG_BLK_DEV_PDC202XX_OLD is not set
@@ -438,10 +435,10 @@ CONFIG_BLK_DEV_SGIIOC4=y
 # CONFIG_BLK_DEV_SLC90E66 is not set
 # CONFIG_BLK_DEV_TRM290 is not set
 # CONFIG_BLK_DEV_VIA82CXXX is not set
+# CONFIG_BLK_DEV_TC86C001 is not set
 # CONFIG_IDE_ARM is not set
 CONFIG_BLK_DEV_IDEDMA=y
 # CONFIG_IDEDMA_IVB is not set
-CONFIG_IDEDMA_AUTO=y
 # CONFIG_BLK_DEV_HD is not set
 
 #
@@ -449,6 +446,8 @@ CONFIG_IDEDMA_AUTO=y
 #
 # CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
+CONFIG_SCSI_DMA=y
+# CONFIG_SCSI_TGT is not set
 CONFIG_SCSI_NETLINK=y
 CONFIG_SCSI_PROC_FS=y
 
@@ -469,6 +468,8 @@ CONFIG_CHR_DEV_SCH=m
 # CONFIG_SCSI_MULTI_LUN is not set
 CONFIG_SCSI_CONSTANTS=y
 # CONFIG_SCSI_LOGGING is not set
+# CONFIG_SCSI_SCAN_ASYNC is not set
+CONFIG_SCSI_WAIT_SCAN=m
 
 #
 # SCSI Transports
@@ -478,11 +479,9 @@ CONFIG_SCSI_FC_ATTRS=y
 CONFIG_SCSI_ISCSI_ATTRS=m
 CONFIG_SCSI_SAS_ATTRS=y
 CONFIG_SCSI_SAS_LIBSAS=y
+# CONFIG_SCSI_SAS_ATA is not set
 # CONFIG_SCSI_SAS_LIBSAS_DEBUG is not set
-
-#
-# SCSI low-level drivers
-#
+CONFIG_SCSI_LOWLEVEL=y
 CONFIG_ISCSI_TCP=m
 # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
 # CONFIG_SCSI_3W_9XXX is not set
@@ -512,11 +511,10 @@ CONFIG_SCSI_QLA_FC=y
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
 # CONFIG_SCSI_DEBUG is not set
-
-#
-# Serial ATA (prod) and Parallel ATA (experimental) drivers
-#
+# CONFIG_SCSI_SRP is not set
 CONFIG_ATA=y
+CONFIG_ATA_NONSTANDARD=y
+CONFIG_ATA_ACPI=y
 # CONFIG_SATA_AHCI is not set
 # CONFIG_SATA_SVW is not set
 # CONFIG_ATA_PIIX is not set
@@ -532,10 +530,12 @@ CONFIG_ATA=y
 # CONFIG_SATA_ULI is not set
 # CONFIG_SATA_VIA is not set
 CONFIG_SATA_VITESSE=y
+# CONFIG_SATA_INIC162X is not set
 # CONFIG_PATA_ALI is not set
 # CONFIG_PATA_AMD is not set
 # CONFIG_PATA_ARTOP is not set
 # CONFIG_PATA_ATIIXP is not set
+# CONFIG_PATA_CMD640_PCI is not set
 # CONFIG_PATA_CMD64X is not set
 # CONFIG_PATA_CS5520 is not set
 # CONFIG_PATA_CS5530 is not set
@@ -547,8 +547,10 @@ CONFIG_SATA_VITESSE=y
 # CONFIG_PATA_HPT3X2N is not set
 # CONFIG_PATA_HPT3X3 is not set
 # CONFIG_PATA_IT821X is not set
+# CONFIG_PATA_IT8213 is not set
 # CONFIG_PATA_JMICRON is not set
 # CONFIG_PATA_TRIFLEX is not set
+# CONFIG_PATA_MARVELL is not set
 # CONFIG_PATA_MPIIX is not set
 # CONFIG_PATA_OLDPIIX is not set
 # CONFIG_PATA_NETCELL is not set
@@ -565,10 +567,6 @@ CONFIG_SATA_VITESSE=y
 # CONFIG_PATA_SIS is not set
 # CONFIG_PATA_VIA is not set
 # CONFIG_PATA_WINBOND is not set
-
-#
-# Multi-device support (RAID and LVM)
-#
 CONFIG_MD=y
 CONFIG_BLK_DEV_MD=y
 CONFIG_MD_LINEAR=y
@@ -587,6 +585,8 @@ CONFIG_DM_MIRROR=m
 CONFIG_DM_ZERO=m
 CONFIG_DM_MULTIPATH=m
 CONFIG_DM_MULTIPATH_EMC=m
+# CONFIG_DM_MULTIPATH_RDAC is not set
+# CONFIG_DM_DELAY is not set
 
 #
 # Fusion MPT device support
@@ -597,43 +597,25 @@ CONFIG_FUSION_FC=y
 CONFIG_FUSION_SAS=y
 CONFIG_FUSION_MAX_SGE=128
 CONFIG_FUSION_CTL=m
+CONFIG_FUSION_LOGGING=y
 
 #
 # IEEE 1394 (FireWire) support
 #
+# CONFIG_FIREWIRE is not set
 # CONFIG_IEEE1394 is not set
-
-#
-# I2O device support
-#
 # CONFIG_I2O is not set
-
-#
-# Network device support
-#
 CONFIG_NETDEVICES=y
+# CONFIG_NETDEVICES_MULTIQUEUE is not set
 # CONFIG_DUMMY is not set
 # CONFIG_BONDING is not set
+# CONFIG_MACVLAN is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
-
-#
-# ARCnet devices
-#
+# CONFIG_NET_SB1000 is not set
 # CONFIG_ARCNET is not set
-
-#
-# PHY device support
-#
-
-#
-# Ethernet (10 or 100Mbit)
-#
 # CONFIG_NET_ETHERNET is not set
-
-#
-# Ethernet (1000 Mbit)
-#
+CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 # CONFIG_E1000 is not set
@@ -645,32 +627,39 @@ CONFIG_NETDEVICES=y
 # CONFIG_SKGE is not set
 # CONFIG_SKY2 is not set
 # CONFIG_SK98LIN is not set
+# CONFIG_VIA_VELOCITY is not set
 CONFIG_TIGON3=y
 # CONFIG_BNX2 is not set
 # CONFIG_QLA3XXX is not set
-
-#
-# Ethernet (10000 Mbit)
-#
+# CONFIG_ATL1 is not set
+CONFIG_NETDEV_10000=y
 CONFIG_CHELSIO_T1=m
+CONFIG_CHELSIO_T1_1G=y
+# CONFIG_CHELSIO_T1_NAPI is not set
+CONFIG_CHELSIO_T3=m
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
 # CONFIG_S2IO_NAPI is not set
 # CONFIG_MYRI10GE is not set
-
-#
-# Token Ring devices
-#
+# CONFIG_NETXEN_NIC is not set
+# CONFIG_MLX4_CORE is not set
 # CONFIG_TR is not set
 
 #
-# Wireless LAN (non-hamradio)
+# Wireless LAN
 #
-# CONFIG_NET_RADIO is not set
+# CONFIG_WLAN_PRE80211 is not set
+# CONFIG_WLAN_80211 is not set
 
 #
-# Wan interfaces
+# USB Network Adapters
 #
+# CONFIG_USB_CATC is not set
+# CONFIG_USB_KAWETH is not set
+# CONFIG_USB_PEGASUS is not set
+# CONFIG_USB_RTL8150 is not set
+# CONFIG_USB_USBNET_MII is not set
+# CONFIG_USB_USBNET is not set
 # CONFIG_WAN is not set
 # CONFIG_FDDI is not set
 # CONFIG_HIPPI is not set
@@ -680,18 +669,9 @@ CONFIG_S2IO=m
 # CONFIG_SHAPER is not set
 CONFIG_NETCONSOLE=y
 CONFIG_NETPOLL=y
-# CONFIG_NETPOLL_RX is not set
 # CONFIG_NETPOLL_TRAP is not set
 CONFIG_NET_POLL_CONTROLLER=y
-
-#
-# ISDN subsystem
-#
 # CONFIG_ISDN is not set
-
-#
-# Telephony Support
-#
 # CONFIG_PHONE is not set
 
 #
@@ -699,6 +679,7 @@ CONFIG_NET_POLL_CONTROLLER=y
 #
 CONFIG_INPUT=y
 # CONFIG_INPUT_FF_MEMLESS is not set
+# CONFIG_INPUT_POLLDEV is not set
 
 #
 # Userland interfaces
@@ -718,6 +699,7 @@ CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
 # CONFIG_INPUT_KEYBOARD is not set
 # CONFIG_INPUT_MOUSE is not set
 # CONFIG_INPUT_JOYSTICK is not set
+# CONFIG_INPUT_TABLET is not set
 # CONFIG_INPUT_TOUCHSCREEN is not set
 # CONFIG_INPUT_MISC is not set
 
@@ -741,6 +723,7 @@ CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_DIGIEPCA is not set
 # CONFIG_MOXA_INTELLIO is not set
 # CONFIG_MOXA_SMARTIO is not set
+# CONFIG_MOXA_SMARTIO_NEW is not set
 # CONFIG_ISI is not set
 # CONFIG_SYNCLINKMP is not set
 # CONFIG_SYNCLINK_GT is not set
@@ -752,7 +735,6 @@ CONFIG_SERIAL_NONSTANDARD=y
 CONFIG_SGI_SNSC=y
 CONFIG_SGI_TIOCX=y
 CONFIG_SGI_MBCS=m
-CONFIG_MSPEC=y
 
 #
 # Serial drivers
@@ -771,28 +753,13 @@ CONFIG_SERIAL_SGI_IOC3=y
 CONFIG_UNIX98_PTYS=y
 CONFIG_LEGACY_PTYS=y
 CONFIG_LEGACY_PTY_COUNT=256
-
-#
-# IPMI
-#
 # CONFIG_IPMI_HANDLER is not set
-
-#
-# Watchdog Cards
-#
 # CONFIG_WATCHDOG is not set
 # CONFIG_HW_RANDOM is not set
 CONFIG_EFI_RTC=y
-# CONFIG_DTLK is not set
 # CONFIG_R3964 is not set
 # CONFIG_APPLICOM is not set
-
-#
-# Ftape, the floppy tape device driver
-#
 CONFIG_AGP=y
-# CONFIG_AGP_SIS is not set
-# CONFIG_AGP_VIA is not set
 CONFIG_AGP_SGI_TIOCA=y
 # CONFIG_DRM is not set
 CONFIG_RAW_DRIVER=m
@@ -800,16 +767,8 @@ CONFIG_MAX_RAW_DEVS=256
 # CONFIG_HPET is not set
 # CONFIG_HANGCHECK_TIMER is not set
 CONFIG_MMTIMER=y
-
-#
-# TPM devices
-#
 # CONFIG_TCG_TPM is not set
-# CONFIG_TELCLOCK is not set
-
-#
-# I2C support
-#
+CONFIG_DEVPORT=y
 # CONFIG_I2C is not set
 
 #
@@ -817,37 +776,33 @@ CONFIG_MMTIMER=y
 #
 # CONFIG_SPI is not set
 # CONFIG_SPI_MASTER is not set
-
-#
-# Dallas's 1-wire bus
-#
-
-#
-# Hardware Monitoring support
-#
+# CONFIG_W1 is not set
+# CONFIG_POWER_SUPPLY is not set
 # CONFIG_HWMON is not set
-# CONFIG_HWMON_VID is not set
 
 #
-# Misc devices
+# Multifunction device drivers
 #
-# CONFIG_TIFM_CORE is not set
+# CONFIG_MFD_SM501 is not set
 
 #
 # Multimedia devices
 #
 # CONFIG_VIDEO_DEV is not set
+# CONFIG_DVB_CORE is not set
+# CONFIG_DAB is not set
 
 #
-# Digital Video Broadcasting Devices
+# Graphics support
 #
-# CONFIG_DVB is not set
-# CONFIG_USB_DABUSB is not set
+# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
 
 #
-# Graphics support
+# Display device support
 #
-CONFIG_FIRMWARE_EDID=y
+# CONFIG_DISPLAY_SUPPORT is not set
+# CONFIG_VGASTATE is not set
+CONFIG_VIDEO_OUTPUT_CONTROL=m
 # CONFIG_FB is not set
 
 #
@@ -856,16 +811,29 @@ CONFIG_FIRMWARE_EDID=y
 CONFIG_VGA_CONSOLE=y
 # CONFIG_VGACON_SOFT_SCROLLBACK is not set
 CONFIG_DUMMY_CONSOLE=y
-# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
 
 #
 # Sound
 #
 # CONFIG_SOUND is not set
+CONFIG_HID_SUPPORT=y
+CONFIG_HID=y
+CONFIG_HID_DEBUG=y
 
 #
-# USB support
+# USB Input Devices
+#
+CONFIG_USB_HID=m
+# CONFIG_USB_HIDINPUT_POWERBOOK is not set
+# CONFIG_HID_FF is not set
+# CONFIG_USB_HIDDEV is not set
+
+#
+# USB HID Boot Protocol drivers
 #
+# CONFIG_USB_KBD is not set
+# CONFIG_USB_MOUSE is not set
+CONFIG_USB_SUPPORT=y
 CONFIG_USB_ARCH_HAS_HCD=y
 CONFIG_USB_ARCH_HAS_OHCI=y
 CONFIG_USB_ARCH_HAS_EHCI=y
@@ -876,9 +844,10 @@ CONFIG_USB=m
 # Miscellaneous USB options
 #
 # CONFIG_USB_DEVICEFS is not set
-# CONFIG_USB_BANDWIDTH is not set
+CONFIG_USB_DEVICE_CLASS=y
 # CONFIG_USB_DYNAMIC_MINORS is not set
 # CONFIG_USB_SUSPEND is not set
+# CONFIG_USB_PERSIST is not set
 # CONFIG_USB_OTG is not set
 
 #
@@ -890,10 +859,12 @@ CONFIG_USB_EHCI_HCD=m
 # CONFIG_USB_EHCI_TT_NEWSCHED is not set
 # CONFIG_USB_ISP116X_HCD is not set
 CONFIG_USB_OHCI_HCD=m
-# CONFIG_USB_OHCI_BIG_ENDIAN is not set
+# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
+# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
 CONFIG_USB_OHCI_LITTLE_ENDIAN=y
 CONFIG_USB_UHCI_HCD=m
 # CONFIG_USB_SL811_HCD is not set
+# CONFIG_USB_R8A66597_HCD is not set
 
 #
 # USB Device Class drivers
@@ -912,47 +883,10 @@ CONFIG_USB_UHCI_HCD=m
 # CONFIG_USB_LIBUSUAL is not set
 
 #
-# USB Input Devices
-#
-CONFIG_USB_HID=m
-CONFIG_USB_HIDINPUT=y
-# CONFIG_USB_HIDINPUT_POWERBOOK is not set
-# CONFIG_HID_FF is not set
-# CONFIG_USB_HIDDEV is not set
-
-#
-# USB HID Boot Protocol drivers
-#
-# CONFIG_USB_KBD is not set
-# CONFIG_USB_MOUSE is not set
-# CONFIG_USB_AIPTEK is not set
-# CONFIG_USB_WACOM is not set
-# CONFIG_USB_ACECAD is not set
-# CONFIG_USB_KBTAB is not set
-# CONFIG_USB_POWERMATE is not set
-# CONFIG_USB_TOUCHSCREEN is not set
-# CONFIG_USB_YEALINK is not set
-# CONFIG_USB_XPAD is not set
-# CONFIG_USB_ATI_REMOTE is not set
-# CONFIG_USB_ATI_REMOTE2 is not set
-# CONFIG_USB_KEYSPAN_REMOTE is not set
-# CONFIG_USB_APPLETOUCH is not set
-# CONFIG_USB_TRANCEVIBRATOR is not set
-
-#
 # USB Imaging devices
 #
 # CONFIG_USB_MDC800 is not set
 # CONFIG_USB_MICROTEK is not set
-
-#
-# USB Network Adapters
-#
-# CONFIG_USB_CATC is not set
-# CONFIG_USB_KAWETH is not set
-# CONFIG_USB_PEGASUS is not set
-# CONFIG_USB_RTL8150 is not set
-# CONFIG_USB_USBNET is not set
 CONFIG_USB_MON=y
 
 #
@@ -974,6 +908,7 @@ CONFIG_USB_MON=y
 # CONFIG_USB_RIO500 is not set
 # CONFIG_USB_LEGOTOWER is not set
 # CONFIG_USB_LCD is not set
+# CONFIG_USB_BERRY_CHARGE is not set
 # CONFIG_USB_LED is not set
 # CONFIG_USB_CYPRESS_CY7C63 is not set
 # CONFIG_USB_CYTHERM is not set
@@ -983,6 +918,8 @@ CONFIG_USB_MON=y
 # CONFIG_USB_APPLEDISPLAY is not set
 # CONFIG_USB_SISUSBVGA is not set
 # CONFIG_USB_LD is not set
+# CONFIG_USB_TRANCEVIBRATOR is not set
+# CONFIG_USB_IOWARRIOR is not set
 
 #
 # USB DSL modem support
@@ -992,48 +929,24 @@ CONFIG_USB_MON=y
 # USB Gadget Support
 #
 # CONFIG_USB_GADGET is not set
-
-#
-# MMC/SD Card support
-#
 # CONFIG_MMC is not set
-
-#
-# LED devices
-#
 # CONFIG_NEW_LEDS is not set
-
-#
-# LED drivers
-#
-
-#
-# LED Triggers
-#
-
-#
-# InfiniBand support
-#
 CONFIG_INFINIBAND=m
 # CONFIG_INFINIBAND_USER_MAD is not set
 CONFIG_INFINIBAND_USER_ACCESS=m
+CONFIG_INFINIBAND_USER_MEM=y
 CONFIG_INFINIBAND_ADDR_TRANS=y
 CONFIG_INFINIBAND_MTHCA=m
 CONFIG_INFINIBAND_MTHCA_DEBUG=y
 # CONFIG_INFINIBAND_AMSO1100 is not set
+# CONFIG_INFINIBAND_CXGB3 is not set
+# CONFIG_MLX4_INFINIBAND is not set
 CONFIG_INFINIBAND_IPOIB=m
+# CONFIG_INFINIBAND_IPOIB_CM is not set
 CONFIG_INFINIBAND_IPOIB_DEBUG=y
 # CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
 CONFIG_INFINIBAND_SRP=m
 # CONFIG_INFINIBAND_ISER is not set
-
-#
-# EDAC - error detection and reporting (RAS) (EXPERIMENTAL)
-#
-
-#
-# Real Time Clock
-#
 # CONFIG_RTC_CLASS is not set
 
 #
@@ -1050,6 +963,12 @@ CONFIG_INFINIBAND_SRP=m
 #
 
 #
+# Userspace I/O
+#
+# CONFIG_UIO is not set
+CONFIG_MSPEC=y
+
+#
 # File systems
 #
 CONFIG_EXT2_FS=y
@@ -1061,6 +980,7 @@ CONFIG_EXT3_FS=y
 CONFIG_EXT3_FS_XATTR=y
 CONFIG_EXT3_FS_POSIX_ACL=y
 CONFIG_EXT3_FS_SECURITY=y
+# CONFIG_EXT4DEV_FS is not set
 CONFIG_JBD=y
 # CONFIG_JBD_DEBUG is not set
 CONFIG_FS_MBCACHE=y
@@ -1161,6 +1081,7 @@ CONFIG_EXPORTFS=m
 CONFIG_NFS_COMMON=y
 CONFIG_SUNRPC=m
 CONFIG_SUNRPC_GSS=m
+# CONFIG_SUNRPC_BIND34 is not set
 CONFIG_RPCSEC_GSS_KRB5=m
 # CONFIG_RPCSEC_GSS_SPKM3 is not set
 CONFIG_SMB_FS=m
@@ -1174,7 +1095,6 @@ CONFIG_CIFS=m
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
 # CONFIG_AFS_FS is not set
-# CONFIG_9P_FS is not set
 
 #
 # Partition Types
@@ -1196,6 +1116,7 @@ CONFIG_SGI_PARTITION=y
 # CONFIG_SUN_PARTITION is not set
 # CONFIG_KARMA_PARTITION is not set
 CONFIG_EFI_PARTITION=y
+# CONFIG_SYSV68_PARTITION is not set
 
 #
 # Native Language Support
@@ -1244,18 +1165,25 @@ CONFIG_NLS_UTF8=y
 #
 # Distributed Lock Manager
 #
+# CONFIG_DLM is not set
 
 #
 # Library routines
 #
+CONFIG_BITREVERSE=y
 # CONFIG_CRC_CCITT is not set
 CONFIG_CRC16=m
+# CONFIG_CRC_ITU_T is not set
 CONFIG_CRC32=y
+# CONFIG_CRC7 is not set
 CONFIG_LIBCRC32C=m
 CONFIG_ZLIB_INFLATE=m
 CONFIG_ZLIB_DEFLATE=m
 CONFIG_GENERIC_ALLOCATOR=y
 CONFIG_PLIST=y
+CONFIG_HAS_IOMEM=y
+CONFIG_HAS_IOPORT=y
+CONFIG_HAS_DMA=y
 CONFIG_GENERIC_HARDIRQS=y
 CONFIG_GENERIC_IRQ_PROBE=y
 CONFIG_GENERIC_PENDING_IRQ=y
@@ -1274,25 +1202,28 @@ CONFIG_IRQ_PER_CPU=y
 CONFIG_ENABLE_MUST_CHECK=y
 CONFIG_MAGIC_SYSRQ=y
 # CONFIG_UNUSED_SYMBOLS is not set
+# CONFIG_DEBUG_FS is not set
+# CONFIG_HEADERS_CHECK is not set
 CONFIG_DEBUG_KERNEL=y
-CONFIG_LOG_BUF_SHIFT=20
+# CONFIG_DEBUG_SHIRQ is not set
 CONFIG_DETECT_SOFTLOCKUP=y
+CONFIG_SCHED_DEBUG=y
 # CONFIG_SCHEDSTATS is not set
-# CONFIG_DEBUG_SLAB is not set
+# CONFIG_TIMER_STATS is not set
+# CONFIG_SLUB_DEBUG_ON is not set
 # CONFIG_DEBUG_RT_MUTEXES is not set
 # CONFIG_RT_MUTEX_TESTER is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_MUTEXES is not set
-# CONFIG_DEBUG_RWSEMS is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
 # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
 # CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
-# CONFIG_DEBUG_FS is not set
 # CONFIG_DEBUG_VM is not set
 # CONFIG_DEBUG_LIST is not set
 CONFIG_FORCED_INLINING=y
 # CONFIG_RCU_TORTURE_TEST is not set
+# CONFIG_FAULT_INJECTION is not set
 CONFIG_IA64_GRANULE_16MB=y
 # CONFIG_IA64_GRANULE_64MB is not set
 # CONFIG_IA64_PRINT_HAZARDS is not set
@@ -1306,16 +1237,17 @@ CONFIG_SYSVIPC_COMPAT=y
 #
 # CONFIG_KEYS is not set
 # CONFIG_SECURITY is not set
-
-#
-# Cryptographic options
-#
+CONFIG_XOR_BLOCKS=y
+CONFIG_ASYNC_CORE=y
+CONFIG_ASYNC_MEMCPY=y
+CONFIG_ASYNC_XOR=y
 CONFIG_CRYPTO=y
 CONFIG_CRYPTO_ALGAPI=y
 CONFIG_CRYPTO_BLKCIPHER=m
 CONFIG_CRYPTO_HASH=y
-CONFIG_CRYPTO_MANAGER=m
+CONFIG_CRYPTO_MANAGER=y
 CONFIG_CRYPTO_HMAC=y
+# CONFIG_CRYPTO_XCBC is not set
 # CONFIG_CRYPTO_NULL is not set
 # CONFIG_CRYPTO_MD4 is not set
 CONFIG_CRYPTO_MD5=y
@@ -1324,9 +1256,14 @@ CONFIG_CRYPTO_SHA1=m
 # CONFIG_CRYPTO_SHA512 is not set
 # CONFIG_CRYPTO_WP512 is not set
 # CONFIG_CRYPTO_TGR192 is not set
+# CONFIG_CRYPTO_GF128MUL is not set
 CONFIG_CRYPTO_ECB=m
 CONFIG_CRYPTO_CBC=m
+CONFIG_CRYPTO_PCBC=m
+# CONFIG_CRYPTO_LRW is not set
+# CONFIG_CRYPTO_CRYPTD is not set
 CONFIG_CRYPTO_DES=m
+# CONFIG_CRYPTO_FCRYPT is not set
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set
 # CONFIG_CRYPTO_SERPENT is not set
@@ -1340,8 +1277,6 @@ CONFIG_CRYPTO_DES=m
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 CONFIG_CRYPTO_CRC32C=m
+# CONFIG_CRYPTO_CAMELLIA is not set
 # CONFIG_CRYPTO_TEST is not set
-
-#
-# Hardware crypto devices
-#
+# CONFIG_CRYPTO_HW is not set

--------------030207050504050400060302--

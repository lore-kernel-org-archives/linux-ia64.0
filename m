From: Robin Holt <holt@sgi.com>
Date: Tue, 29 Jul 2008 12:25:25 +0000
Subject: Re: [Patch] update generic_defconfig for 2.6.27-rc1 and add sn2
Message-Id: <20080729122525.GD10501@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729122419.GN9663@sgi.com>
In-Reply-To: <20080729122419.GN9663@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ooops I forgot to send one other small patch first.  That one updates
Kconfig to allow NR_CPUS@96.  Please reorder those for me.

Sorry,
Robin

On Tue, Jul 29, 2008 at 07:24:19AM -0500, Robin Holt wrote:
> This is a two-part patch.  I updated generic_defconfig by simply running
> a make oldconfig and holding down the <return> key for a bit.  I then
> modified the generic_defconfig file to  add the one QLA_FC driver sn2
> needs, NR_CPUS got set to 4096, and CPUSETS got turned on.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
> 
> ---
> 
> Look for the small patch at the end of this file that does the
> update for sn2.  With that applied, I would be happy to remove
> arch/ia64/configs/sn2_defconfig.  If that is acceptable to Tony, Jack, and
> Jes, I would suggest Tony does it as a git-rm thing instead of a patch.
> 
> 
> Index: contention_unroll/arch/ia64/configs/generic_defconfig
> =================================> --- contention_unroll.orig/arch/ia64/configs/generic_defconfig	2008-07-28 18:19:56.000000000 -0500
> +++ contention_unroll/arch/ia64/configs/generic_defconfig	2008-07-29 07:11:29.223011621 -0500
> @@ -1,20 +1,16 @@
>  #
>  # Automatically generated make config: don't edit
> -# Linux kernel version: 2.6.22
> -# Thu Jul 19 13:55:32 2007
> +# Linux kernel version: 2.6.27-rc1
> +# Tue Jul 29 07:11:14 2008
>  #
>  CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
>  
>  #
> -# Code maturity level options
> +# General setup
>  #
>  CONFIG_EXPERIMENTAL=y
>  CONFIG_LOCK_KERNEL=y
>  CONFIG_INIT_ENV_ARG_LIMIT2
> -
> -#
> -# General setup
> -#
>  CONFIG_LOCALVERSION=""
>  CONFIG_LOCALVERSION_AUTO=y
>  CONFIG_SWAP=y
> @@ -23,20 +19,27 @@ CONFIG_SYSVIPC_SYSCTL=y
>  CONFIG_POSIX_MQUEUE=y
>  # CONFIG_BSD_PROCESS_ACCT is not set
>  # CONFIG_TASKSTATS is not set
> -# CONFIG_USER_NS is not set
>  # CONFIG_AUDIT is not set
>  CONFIG_IKCONFIG=y
>  CONFIG_IKCONFIG_PROC=y
>  CONFIG_LOG_BUF_SHIFT 
> -# CONFIG_CPUSETS is not set
> +# CONFIG_CGROUPS is not set
> +# CONFIG_GROUP_SCHED is not set
>  CONFIG_SYSFS_DEPRECATED=y
> +CONFIG_SYSFS_DEPRECATED_V2=y
>  # CONFIG_RELAY is not set
> +CONFIG_NAMESPACES=y
> +# CONFIG_UTS_NS is not set
> +# CONFIG_IPC_NS is not set
> +# CONFIG_USER_NS is not set
> +# CONFIG_PID_NS is not set
>  CONFIG_BLK_DEV_INITRD=y
>  CONFIG_INITRAMFS_SOURCE=""
>  CONFIG_CC_OPTIMIZE_FOR_SIZE=y
>  CONFIG_SYSCTL=y
>  # CONFIG_EMBEDDED is not set
>  CONFIG_SYSCTL_SYSCALL=y
> +CONFIG_SYSCTL_SYSCALL_CHECK=y
>  CONFIG_KALLSYMS=y
>  CONFIG_KALLSYMS_ALL=y
>  # CONFIG_KALLSYMS_EXTRA_PASS is not set
> @@ -44,6 +47,7 @@ CONFIG_HOTPLUG=y
>  CONFIG_PRINTK=y
>  CONFIG_BUG=y
>  CONFIG_ELF_CORE=y
> +CONFIG_COMPAT_BRK=y
>  CONFIG_BASE_FULL=y
>  CONFIG_FUTEX=y
>  CONFIG_ANON_INODES=y
> @@ -53,12 +57,30 @@ CONFIG_TIMERFD=y
>  CONFIG_EVENTFD=y
>  CONFIG_SHMEM=y
>  CONFIG_VM_EVENT_COUNTERS=y
> +CONFIG_SLUB_DEBUG=y
> +# CONFIG_SLAB is not set
>  CONFIG_SLUB=y
>  # CONFIG_SLOB is not set
> +# CONFIG_PROFILING is not set
> +# CONFIG_MARKERS is not set
> +CONFIG_HAVE_OPROFILE=y
> +# CONFIG_KPROBES is not set
> +# CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is not set
> +# CONFIG_HAVE_IOREMAP_PROT is not set
> +CONFIG_HAVE_KPROBES=y
> +CONFIG_HAVE_KRETPROBES=y
> +# CONFIG_HAVE_ARCH_TRACEHOOK is not set
> +CONFIG_HAVE_DMA_ATTRS=y
> +CONFIG_USE_GENERIC_SMP_HELPERS=y
> +# CONFIG_HAVE_CLK is not set
> +CONFIG_PROC_PAGE_MONITOR=y
> +# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
> +CONFIG_SLABINFO=y
>  CONFIG_RT_MUTEXES=y
>  # CONFIG_TINY_SHMEM is not set
>  CONFIG_BASE_SMALL=0
>  CONFIG_MODULES=y
> +# CONFIG_MODULE_FORCE_LOAD is not set
>  CONFIG_MODULE_UNLOAD=y
>  # CONFIG_MODULE_FORCE_UNLOAD is not set
>  CONFIG_MODVERSIONS=y
> @@ -68,6 +90,8 @@ CONFIG_STOP_MACHINE=y
>  CONFIG_BLOCK=y
>  # CONFIG_BLK_DEV_IO_TRACE is not set
>  # CONFIG_BLK_DEV_BSG is not set
> +# CONFIG_BLK_DEV_INTEGRITY is not set
> +CONFIG_BLOCK_COMPAT=y
>  
>  #
>  # IO Schedulers
> @@ -81,6 +105,7 @@ CONFIG_DEFAULT_AS=y
>  # CONFIG_DEFAULT_CFQ is not set
>  # CONFIG_DEFAULT_NOOP is not set
>  CONFIG_DEFAULT_IOSCHED="anticipatory"
> +CONFIG_CLASSIC_RCU=y
>  
>  #
>  # Processor type and features
> @@ -91,12 +116,16 @@ CONFIG_ZONE_DMA=y
>  CONFIG_QUICKLIST=y
>  CONFIG_MMU=y
>  CONFIG_SWIOTLB=y
> +CONFIG_IOMMU_HELPER=y
>  CONFIG_RWSEM_XCHGADD_ALGORITHM=y
>  # CONFIG_ARCH_HAS_ILOG2_U32 is not set
>  # CONFIG_ARCH_HAS_ILOG2_U64 is not set
> +CONFIG_HUGETLB_PAGE_SIZE_VARIABLE=y
>  CONFIG_GENERIC_FIND_NEXT_BIT=y
>  CONFIG_GENERIC_CALIBRATE_DELAY=y
>  CONFIG_GENERIC_TIME=y
> +CONFIG_GENERIC_TIME_VSYSCALL=y
> +CONFIG_HAVE_SETUP_PER_CPU_AREA=y
>  CONFIG_DMI=y
>  CONFIG_EFI=y
>  CONFIG_GENERIC_IOMAP=y
> @@ -107,6 +136,7 @@ CONFIG_IA64_GENERIC=y
>  # CONFIG_IA64_HP_ZX1 is not set
>  # CONFIG_IA64_HP_ZX1_SWIOTLB is not set
>  # CONFIG_IA64_SGI_SN2 is not set
> +# CONFIG_IA64_SGI_UV is not set
>  # CONFIG_IA64_HP_SIM is not set
>  # CONFIG_ITANIUM is not set
>  CONFIG_MCKINLEY=y
> @@ -116,22 +146,26 @@ CONFIG_MCKINLEY=y
>  CONFIG_IA64_PAGE_SIZE_64KB=y
>  CONFIG_PGTABLE_3=y
>  # CONFIG_PGTABLE_4 is not set
> +CONFIG_HZ%0
>  # CONFIG_HZ_100 is not set
>  CONFIG_HZ_250=y
>  # CONFIG_HZ_300 is not set
>  # CONFIG_HZ_1000 is not set
> -CONFIG_HZ%0
> +# CONFIG_SCHED_HRTICK is not set
>  CONFIG_IA64_L1_CACHE_SHIFT=7
>  CONFIG_IA64_CYCLONE=y
>  CONFIG_IOSAPIC=y
> -# CONFIG_IA64_SGI_SN_XP is not set
>  CONFIG_FORCE_MAX_ZONEORDER
> +# CONFIG_VIRT_CPU_ACCOUNTING is not set
>  CONFIG_SMP=y
>  CONFIG_NR_CPUSQ2
>  CONFIG_HOTPLUG_CPU=y
>  CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
> +CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
>  # CONFIG_SCHED_SMT is not set
>  # CONFIG_PERMIT_BSP_REMOVE is not set
> +CONFIG_PREEMPT_NONE=y
> +# CONFIG_PREEMPT_VOLUNTARY is not set
>  # CONFIG_PREEMPT is not set
>  CONFIG_SELECT_MEMORY_MODEL=y
>  # CONFIG_FLATMEM_MANUAL is not set
> @@ -141,6 +175,8 @@ CONFIG_DISCONTIGMEM=y
>  CONFIG_FLAT_NODE_MEM_MAP=y
>  CONFIG_NEED_MULTIPLE_NODES=y
>  # CONFIG_SPARSEMEM_STATIC is not set
> +CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
> +CONFIG_PAGEFLAGS_EXTENDED=y
>  CONFIG_SPLIT_PTLOCK_CPUS=4
>  CONFIG_MIGRATION=y
>  CONFIG_RESOURCES_64BIT=y
> @@ -162,12 +198,14 @@ CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
>  CONFIG_HAVE_ARCH_NODEDATA_EXTENSION=y
>  CONFIG_IA32_SUPPORT=y
>  CONFIG_COMPAT=y
> +CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
>  CONFIG_IA64_MCA_RECOVERY=y
>  CONFIG_PERFMON=y
>  CONFIG_IA64_PALINFO=y
>  # CONFIG_IA64_MC_ERR_INJECT is not set
>  CONFIG_SGI_SN=y
>  # CONFIG_IA64_ESI is not set
> +# CONFIG_IA64_HP_AML_NFW is not set
>  
>  #
>  # SN Devices
> @@ -179,6 +217,7 @@ CONFIG_CRASH_DUMP=y
>  #
>  # Firmware Drivers
>  #
> +# CONFIG_FIRMWARE_MEMMAP is not set
>  CONFIG_EFI_VARS=y
>  CONFIG_EFI_PCDP=y
>  CONFIG_DMIID=y
> @@ -189,14 +228,12 @@ CONFIG_BINFMT_MISC=m
>  # Power management and ACPI
>  #
>  CONFIG_PM=y
> -CONFIG_PM_LEGACY=y
>  # CONFIG_PM_DEBUG is not set
> -
> -#
> -# ACPI (Advanced Configuration and Power Interface) Support
> -#
>  CONFIG_ACPI=y
>  CONFIG_ACPI_PROCFS=y
> +CONFIG_ACPI_PROCFS_POWER=y
> +CONFIG_ACPI_SYSFS_POWER=y
> +CONFIG_ACPI_PROC_EVENT=y
>  CONFIG_ACPI_BUTTON=m
>  CONFIG_ACPI_FAN=m
>  # CONFIG_ACPI_DOCK is not set
> @@ -204,9 +241,11 @@ CONFIG_ACPI_PROCESSOR=m
>  CONFIG_ACPI_HOTPLUG_CPU=y
>  CONFIG_ACPI_THERMAL=m
>  CONFIG_ACPI_NUMA=y
> +# CONFIG_ACPI_CUSTOM_DSDT is not set
>  CONFIG_ACPI_BLACKLIST_YEAR=0
>  # CONFIG_ACPI_DEBUG is not set
>  CONFIG_ACPI_EC=y
> +# CONFIG_ACPI_PCI_SLOT is not set
>  CONFIG_ACPI_POWER=y
>  CONFIG_ACPI_SYSTEM=y
>  CONFIG_ACPI_CONTAINER=m
> @@ -225,6 +264,7 @@ CONFIG_PCI_SYSCALL=y
>  # CONFIG_PCIEPORTBUS is not set
>  CONFIG_ARCH_SUPPORTS_MSI=y
>  # CONFIG_PCI_MSI is not set
> +CONFIG_PCI_LEGACY=y
>  # CONFIG_PCI_DEBUG is not set
>  CONFIG_HOTPLUG_PCI=m
>  # CONFIG_HOTPLUG_PCI_FAKE is not set
> @@ -233,10 +273,6 @@ CONFIG_HOTPLUG_PCI_ACPI=m
>  # CONFIG_HOTPLUG_PCI_CPCI is not set
>  # CONFIG_HOTPLUG_PCI_SHPC is not set
>  # CONFIG_HOTPLUG_PCI_SGI is not set
> -
> -#
> -# PCCARD (PCMCIA/CardBus) support
> -#
>  # CONFIG_PCCARD is not set
>  
>  #
> @@ -254,6 +290,7 @@ CONFIG_XFRM=y
>  # CONFIG_XFRM_USER is not set
>  # CONFIG_XFRM_SUB_POLICY is not set
>  # CONFIG_XFRM_MIGRATE is not set
> +# CONFIG_XFRM_STATISTICS is not set
>  # CONFIG_NET_KEY is not set
>  CONFIG_INET=y
>  CONFIG_IP_MULTICAST=y
> @@ -273,6 +310,7 @@ CONFIG_SYN_COOKIES=y
>  CONFIG_INET_XFRM_MODE_TRANSPORT=y
>  CONFIG_INET_XFRM_MODE_TUNNEL=y
>  CONFIG_INET_XFRM_MODE_BEET=y
> +CONFIG_INET_LRO=m
>  CONFIG_INET_DIAG=y
>  CONFIG_INET_TCP_DIAG=y
>  # CONFIG_TCP_CONG_ADVANCED is not set
> @@ -280,8 +318,6 @@ CONFIG_TCP_CONG_CUBIC=y
>  CONFIG_DEFAULT_TCP_CONG="cubic"
>  # CONFIG_TCP_MD5SIG is not set
>  # CONFIG_IPV6 is not set
> -# CONFIG_INET6_XFRM_TUNNEL is not set
> -# CONFIG_INET6_TUNNEL is not set
>  # CONFIG_NETWORK_SECMARK is not set
>  # CONFIG_NETFILTER is not set
>  # CONFIG_IP_DCCP is not set
> @@ -298,10 +334,6 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
>  # CONFIG_LAPB is not set
>  # CONFIG_ECONET is not set
>  # CONFIG_WAN_ROUTER is not set
> -
> -#
> -# QoS and/or fair queueing
> -#
>  # CONFIG_NET_SCHED is not set
>  
>  #
> @@ -309,6 +341,7 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
>  #
>  # CONFIG_NET_PKTGEN is not set
>  # CONFIG_HAMRADIO is not set
> +# CONFIG_CAN is not set
>  # CONFIG_IRDA is not set
>  # CONFIG_BT is not set
>  # CONFIG_AF_RXRPC is not set
> @@ -330,9 +363,12 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
>  #
>  # Generic Driver Options
>  #
> +CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
>  CONFIG_STANDALONE=y
>  CONFIG_PREVENT_FIRMWARE_BUILD=y
> -CONFIG_FW_LOADER=m
> +CONFIG_FW_LOADER=y
> +CONFIG_FIRMWARE_IN_KERNEL=y
> +CONFIG_EXTRA_FIRMWARE=""
>  # CONFIG_DEBUG_DRIVER is not set
>  # CONFIG_DEBUG_DEVRES is not set
>  # CONFIG_SYS_HYPERVISOR is not set
> @@ -360,25 +396,33 @@ CONFIG_BLK_DEV_NBD=m
>  CONFIG_BLK_DEV_RAM=y
>  CONFIG_BLK_DEV_RAM_COUNT
>  CONFIG_BLK_DEV_RAM_SIZE@96
> -CONFIG_BLK_DEV_RAM_BLOCKSIZE24
> +# CONFIG_BLK_DEV_XIP is not set
>  # CONFIG_CDROM_PKTCDVD is not set
>  # CONFIG_ATA_OVER_ETH is not set
> +# CONFIG_BLK_DEV_HD is not set
>  CONFIG_MISC_DEVICES=y
>  # CONFIG_PHANTOM is not set
>  # CONFIG_EEPROM_93CX6 is not set
>  CONFIG_SGI_IOC4=y
>  # CONFIG_TIFM_CORE is not set
> +# CONFIG_ENCLOSURE_SERVICES is not set
> +# CONFIG_SGI_XP is not set
> +# CONFIG_HP_ILO is not set
> +CONFIG_HAVE_IDE=y
>  CONFIG_IDE=y
>  CONFIG_IDE_MAX_HWIFS=4
>  CONFIG_BLK_DEV_IDE=y
>  
>  #
> -# Please see Documentation/ide.txt for help/info on IDE drives
> +# Please see Documentation/ide/ide.txt for help/info on IDE drives
>  #
> +CONFIG_IDE_TIMINGS=y
> +CONFIG_IDE_ATAPI=y
>  # CONFIG_BLK_DEV_IDE_SATA is not set
>  CONFIG_BLK_DEV_IDEDISK=y
>  # CONFIG_IDEDISK_MULTI_MODE is not set
>  CONFIG_BLK_DEV_IDECD=y
> +CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
>  # CONFIG_BLK_DEV_IDETAPE is not set
>  CONFIG_BLK_DEV_IDEFLOPPY=y
>  CONFIG_BLK_DEV_IDESCSI=m
> @@ -390,25 +434,26 @@ CONFIG_IDE_PROC_FS=y
>  # IDE chipset support/bugfixes
>  #
>  # CONFIG_IDE_GENERIC is not set
> +# CONFIG_BLK_DEV_PLATFORM is not set
>  # CONFIG_BLK_DEV_IDEPNP is not set
> +CONFIG_BLK_DEV_IDEDMA_SFF=y
> +
> +#
> +# PCI IDE chipsets support
> +#
>  CONFIG_BLK_DEV_IDEPCI=y
> -CONFIG_IDEPCI_SHARE_IRQ=y
>  CONFIG_IDEPCI_PCIBUS_ORDER=y
>  # CONFIG_BLK_DEV_OFFBOARD is not set
>  CONFIG_BLK_DEV_GENERIC=y
>  # CONFIG_BLK_DEV_OPTI621 is not set
>  CONFIG_BLK_DEV_IDEDMA_PCI=y
> -# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
> -# CONFIG_IDEDMA_ONLYDISK is not set
>  # CONFIG_BLK_DEV_AEC62XX is not set
>  # CONFIG_BLK_DEV_ALI15X3 is not set
>  # CONFIG_BLK_DEV_AMD74XX is not set
>  CONFIG_BLK_DEV_CMD64X=y
>  # CONFIG_BLK_DEV_TRIFLEX is not set
> -# CONFIG_BLK_DEV_CY82C693 is not set
>  # CONFIG_BLK_DEV_CS5520 is not set
>  # CONFIG_BLK_DEV_CS5530 is not set
> -# CONFIG_BLK_DEV_HPT34X is not set
>  # CONFIG_BLK_DEV_HPT366 is not set
>  # CONFIG_BLK_DEV_JMICRON is not set
>  # CONFIG_BLK_DEV_SC1200 is not set
> @@ -425,10 +470,7 @@ CONFIG_BLK_DEV_SGIIOC4=y
>  # CONFIG_BLK_DEV_TRM290 is not set
>  # CONFIG_BLK_DEV_VIA82CXXX is not set
>  # CONFIG_BLK_DEV_TC86C001 is not set
> -# CONFIG_IDE_ARM is not set
>  CONFIG_BLK_DEV_IDEDMA=y
> -# CONFIG_IDEDMA_IVB is not set
> -# CONFIG_BLK_DEV_HD is not set
>  
>  #
>  # SCSI device support
> @@ -468,10 +510,8 @@ CONFIG_SCSI_FC_ATTRS=y
>  # CONFIG_SCSI_ISCSI_ATTRS is not set
>  CONFIG_SCSI_SAS_ATTRS=y
>  # CONFIG_SCSI_SAS_LIBSAS is not set
> -
> -#
> -# SCSI low-level drivers
> -#
> +# CONFIG_SCSI_SRP_ATTRS is not set
> +CONFIG_SCSI_LOWLEVEL=y
>  # CONFIG_ISCSI_TCP is not set
>  # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
>  # CONFIG_SCSI_3W_9XXX is not set
> @@ -481,6 +521,8 @@ CONFIG_SCSI_SAS_ATTRS=y
>  # CONFIG_SCSI_AIC7XXX_OLD is not set
>  # CONFIG_SCSI_AIC79XX is not set
>  # CONFIG_SCSI_AIC94XX is not set
> +# CONFIG_SCSI_DPT_I2O is not set
> +# CONFIG_SCSI_ADVANSYS is not set
>  # CONFIG_SCSI_ARCMSR is not set
>  # CONFIG_MEGARAID_NEWGEN is not set
>  # CONFIG_MEGARAID_LEGACY is not set
> @@ -491,6 +533,7 @@ CONFIG_SCSI_SAS_ATTRS=y
>  # CONFIG_SCSI_IPS is not set
>  # CONFIG_SCSI_INITIO is not set
>  # CONFIG_SCSI_INIA100 is not set
> +# CONFIG_SCSI_MVSAS is not set
>  # CONFIG_SCSI_STEX is not set
>  CONFIG_SCSI_SYM53C8XX_2=y
>  CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
> @@ -505,6 +548,7 @@ CONFIG_SCSI_QLOGIC_1280=y
>  # CONFIG_SCSI_DC390T is not set
>  # CONFIG_SCSI_DEBUG is not set
>  # CONFIG_SCSI_SRP is not set
> +# CONFIG_SCSI_DH is not set
>  # CONFIG_ATA is not set
>  CONFIG_MD=y
>  CONFIG_BLK_DEV_MD=m
> @@ -522,36 +566,52 @@ CONFIG_DM_SNAPSHOT=m
>  CONFIG_DM_MIRROR=m
>  CONFIG_DM_ZERO=m
>  CONFIG_DM_MULTIPATH=m
> -# CONFIG_DM_MULTIPATH_EMC is not set
> -# CONFIG_DM_MULTIPATH_RDAC is not set
>  # CONFIG_DM_DELAY is not set
> -
> -#
> -# Fusion MPT device support
> -#
> +# CONFIG_DM_UEVENT is not set
>  CONFIG_FUSION=y
>  CONFIG_FUSION_SPI=y
>  CONFIG_FUSION_FC=m
>  CONFIG_FUSION_SAS=y
>  CONFIG_FUSION_MAX_SGE8
>  # CONFIG_FUSION_CTL is not set
> +# CONFIG_FUSION_LOGGING is not set
>  
>  #
>  # IEEE 1394 (FireWire) support
>  #
> +
> +#
> +# Enable only one of the two stacks, unless you know what you are doing
> +#
>  # CONFIG_FIREWIRE is not set
>  # CONFIG_IEEE1394 is not set
>  # CONFIG_I2O is not set
>  CONFIG_NETDEVICES=y
> -# CONFIG_NETDEVICES_MULTIQUEUE is not set
>  CONFIG_DUMMY=m
>  # CONFIG_BONDING is not set
>  # CONFIG_MACVLAN is not set
>  # CONFIG_EQUALIZER is not set
>  # CONFIG_TUN is not set
> +# CONFIG_VETH is not set
>  # CONFIG_NET_SB1000 is not set
>  # CONFIG_ARCNET is not set
> -# CONFIG_PHYLIB is not set
> +CONFIG_PHYLIB=y
> +
> +#
> +# MII PHY device drivers
> +#
> +# CONFIG_MARVELL_PHY is not set
> +# CONFIG_DAVICOM_PHY is not set
> +# CONFIG_QSEMI_PHY is not set
> +# CONFIG_LXT_PHY is not set
> +# CONFIG_CICADA_PHY is not set
> +# CONFIG_VITESSE_PHY is not set
> +# CONFIG_SMSC_PHY is not set
> +# CONFIG_BROADCOM_PHY is not set
> +# CONFIG_ICPLUS_PHY is not set
> +# CONFIG_REALTEK_PHY is not set
> +# CONFIG_FIXED_PHY is not set
> +# CONFIG_MDIO_BITBANG is not set
>  CONFIG_NET_ETHERNET=y
>  CONFIG_MII=m
>  # CONFIG_HAPPYMEAL is not set
> @@ -569,13 +629,16 @@ CONFIG_TULIP=m
>  # CONFIG_DM9102 is not set
>  # CONFIG_ULI526X is not set
>  # CONFIG_HP100 is not set
> +# CONFIG_IBM_NEW_EMAC_ZMII is not set
> +# CONFIG_IBM_NEW_EMAC_RGMII is not set
> +# CONFIG_IBM_NEW_EMAC_TAH is not set
> +# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
>  CONFIG_NET_PCI=y
>  # CONFIG_PCNET32 is not set
>  # CONFIG_AMD8111_ETH is not set
>  # CONFIG_ADAPTEC_STARFIRE is not set
>  # CONFIG_B44 is not set
>  # CONFIG_FORCEDETH is not set
> -# CONFIG_DGRS is not set
>  CONFIG_EEPRO100=m
>  CONFIG_E100=m
>  # CONFIG_FEALNX is not set
> @@ -583,17 +646,21 @@ CONFIG_E100=m
>  # CONFIG_NE2K_PCI is not set
>  # CONFIG_8139CP is not set
>  # CONFIG_8139TOO is not set
> +# CONFIG_R6040 is not set
>  # CONFIG_SIS900 is not set
>  # CONFIG_EPIC100 is not set
>  # CONFIG_SUNDANCE is not set
> +# CONFIG_TLAN is not set
>  # CONFIG_VIA_RHINE is not set
>  # CONFIG_SC92031 is not set
>  CONFIG_NETDEV_1000=y
>  # CONFIG_ACENIC is not set
>  # CONFIG_DL2K is not set
>  CONFIG_E1000=y
> -# CONFIG_E1000_NAPI is not set
>  # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
> +# CONFIG_E1000E is not set
> +# CONFIG_IP1000 is not set
> +# CONFIG_IGB is not set
>  # CONFIG_NS83820 is not set
>  # CONFIG_HAMACHI is not set
>  # CONFIG_YELLOWFIN is not set
> @@ -606,14 +673,20 @@ CONFIG_TIGON3=y
>  # CONFIG_BNX2 is not set
>  # CONFIG_QLA3XXX is not set
>  # CONFIG_ATL1 is not set
> +# CONFIG_ATL1E is not set
>  CONFIG_NETDEV_10000=y
>  # CONFIG_CHELSIO_T1 is not set
>  # CONFIG_CHELSIO_T3 is not set
> +# CONFIG_IXGBE is not set
>  # CONFIG_IXGB is not set
>  # CONFIG_S2IO is not set
>  # CONFIG_MYRI10GE is not set
>  # CONFIG_NETXEN_NIC is not set
> +# CONFIG_NIU is not set
>  # CONFIG_MLX4_CORE is not set
> +# CONFIG_TEHUTI is not set
> +# CONFIG_BNX2X is not set
> +# CONFIG_SFC is not set
>  # CONFIG_TR is not set
>  
>  #
> @@ -621,6 +694,7 @@ CONFIG_NETDEV_10000=y
>  #
>  # CONFIG_WLAN_PRE80211 is not set
>  # CONFIG_WLAN_80211 is not set
> +# CONFIG_IWLWIFI_LEDS is not set
>  
>  #
>  # USB Network Adapters
> @@ -629,7 +703,6 @@ CONFIG_NETDEV_10000=y
>  # CONFIG_USB_KAWETH is not set
>  # CONFIG_USB_PEGASUS is not set
>  # CONFIG_USB_RTL8150 is not set
> -# CONFIG_USB_USBNET_MII is not set
>  # CONFIG_USB_USBNET is not set
>  # CONFIG_WAN is not set
>  # CONFIG_FDDI is not set
> @@ -637,8 +710,8 @@ CONFIG_NETDEV_10000=y
>  # CONFIG_PPP is not set
>  # CONFIG_SLIP is not set
>  # CONFIG_NET_FC is not set
> -# CONFIG_SHAPER is not set
>  CONFIG_NETCONSOLE=y
> +# CONFIG_NETCONSOLE_DYNAMIC is not set
>  CONFIG_NETPOLL=y
>  # CONFIG_NETPOLL_TRAP is not set
>  CONFIG_NET_POLL_CONTROLLER=y
> @@ -660,7 +733,6 @@ CONFIG_INPUT_MOUSEDEV_PSAUX=y
>  CONFIG_INPUT_MOUSEDEV_SCREEN_X24
>  CONFIG_INPUT_MOUSEDEV_SCREEN_Yv8
>  # CONFIG_INPUT_JOYDEV is not set
> -# CONFIG_INPUT_TSDEV is not set
>  # CONFIG_INPUT_EVDEV is not set
>  # CONFIG_INPUT_EVBUG is not set
>  
> @@ -709,9 +781,11 @@ CONFIG_GAMEPORT=m
>  # Character devices
>  #
>  CONFIG_VT=y
> +CONFIG_CONSOLE_TRANSLATIONS=y
>  CONFIG_VT_CONSOLE=y
>  CONFIG_HW_CONSOLE=y
>  # CONFIG_VT_HW_CONSOLE_BINDING is not set
> +CONFIG_DEVKMEM=y
>  CONFIG_SERIAL_NONSTANDARD=y
>  # CONFIG_COMPUTONE is not set
>  # CONFIG_ROCKETPORT is not set
> @@ -719,15 +793,16 @@ CONFIG_SERIAL_NONSTANDARD=y
>  # CONFIG_DIGIEPCA is not set
>  # CONFIG_MOXA_INTELLIO is not set
>  # CONFIG_MOXA_SMARTIO is not set
> -# CONFIG_MOXA_SMARTIO_NEW is not set
>  # CONFIG_ISI is not set
>  # CONFIG_SYNCLINKMP is not set
>  # CONFIG_SYNCLINK_GT is not set
>  # CONFIG_N_HDLC is not set
> +# CONFIG_RISCOM8 is not set
>  # CONFIG_SPECIALIX is not set
>  # CONFIG_SX is not set
>  # CONFIG_RIO is not set
>  # CONFIG_STALDRV is not set
> +# CONFIG_NOZOMI is not set
>  CONFIG_SGI_SNSC=y
>  CONFIG_SGI_TIOCX=y
>  CONFIG_SGI_MBCS=m
> @@ -759,76 +834,100 @@ CONFIG_UNIX98_PTYS=y
>  CONFIG_LEGACY_PTYS=y
>  CONFIG_LEGACY_PTY_COUNT%6
>  # CONFIG_IPMI_HANDLER is not set
> -# CONFIG_WATCHDOG is not set
>  # CONFIG_HW_RANDOM is not set
>  CONFIG_EFI_RTC=y
>  # CONFIG_R3964 is not set
>  # CONFIG_APPLICOM is not set
> -CONFIG_AGP=m
> -CONFIG_AGP_I460=m
> -CONFIG_AGP_HP_ZX1=m
> -CONFIG_AGP_SGI_TIOCA=m
> -CONFIG_DRM=m
> -CONFIG_DRM_TDFX=m
> -CONFIG_DRM_R128=m
> -CONFIG_DRM_RADEON=m
> -CONFIG_DRM_MGA=m
> -CONFIG_DRM_SIS=m
> -# CONFIG_DRM_VIA is not set
> -# CONFIG_DRM_SAVAGE is not set
>  CONFIG_RAW_DRIVER=m
>  CONFIG_MAX_RAW_DEVS%6
>  CONFIG_HPET=y
> -# CONFIG_HPET_RTC_IRQ is not set
>  CONFIG_HPET_MMAP=y
>  # CONFIG_HANGCHECK_TIMER is not set
>  CONFIG_MMTIMER=y
>  # CONFIG_TCG_TPM is not set
>  CONFIG_DEVPORT=y
>  # CONFIG_I2C is not set
> -
> -#
> -# SPI support
> -#
>  # CONFIG_SPI is not set
> -# CONFIG_SPI_MASTER is not set
>  # CONFIG_W1 is not set
> -# CONFIG_POWER_SUPPLY is not set
> +CONFIG_POWER_SUPPLY=y
> +# CONFIG_POWER_SUPPLY_DEBUG is not set
> +# CONFIG_PDA_POWER is not set
> +# CONFIG_BATTERY_DS2760 is not set
>  CONFIG_HWMON=y
>  # CONFIG_HWMON_VID is not set
> -# CONFIG_SENSORS_ABITUGURU is not set
> +# CONFIG_SENSORS_I5K_AMB is not set
>  # CONFIG_SENSORS_F71805F is not set
> +# CONFIG_SENSORS_F71882FG is not set
> +# CONFIG_SENSORS_IT87 is not set
> +# CONFIG_SENSORS_PC87360 is not set
>  # CONFIG_SENSORS_PC87427 is not set
> +# CONFIG_SENSORS_SIS5595 is not set
>  # CONFIG_SENSORS_SMSC47M1 is not set
>  # CONFIG_SENSORS_SMSC47B397 is not set
> +# CONFIG_SENSORS_VIA686A is not set
>  # CONFIG_SENSORS_VT1211 is not set
> +# CONFIG_SENSORS_VT8231 is not set
>  # CONFIG_SENSORS_W83627HF is not set
> +# CONFIG_SENSORS_W83627EHF is not set
>  # CONFIG_HWMON_DEBUG_CHIP is not set
> +CONFIG_THERMAL=m
> +# CONFIG_THERMAL_HWMON is not set
> +# CONFIG_WATCHDOG is not set
> +
> +#
> +# Sonics Silicon Backplane
> +#
> +CONFIG_SSB_POSSIBLE=y
> +# CONFIG_SSB is not set
>  
>  #
>  # Multifunction device drivers
>  #
> +# CONFIG_MFD_CORE is not set
>  # CONFIG_MFD_SM501 is not set
> +# CONFIG_HTC_PASIC3 is not set
>  
>  #
>  # Multimedia devices
>  #
> +
> +#
> +# Multimedia core support
> +#
>  # CONFIG_VIDEO_DEV is not set
>  # CONFIG_DVB_CORE is not set
> +# CONFIG_VIDEO_MEDIA is not set
> +
> +#
> +# Multimedia drivers
> +#
>  CONFIG_DAB=y
>  # CONFIG_USB_DABUSB is not set
>  
>  #
>  # Graphics support
>  #
> +CONFIG_AGP=m
> +CONFIG_AGP_I460=m
> +CONFIG_AGP_HP_ZX1=m
> +CONFIG_AGP_SGI_TIOCA=m
> +CONFIG_DRM=m
> +CONFIG_DRM_TDFX=m
> +CONFIG_DRM_R128=m
> +CONFIG_DRM_RADEON=m
> +CONFIG_DRM_MGA=m
> +CONFIG_DRM_SIS=m
> +# CONFIG_DRM_VIA is not set
> +# CONFIG_DRM_SAVAGE is not set
> +# CONFIG_VGASTATE is not set
> +# CONFIG_VIDEO_OUTPUT_CONTROL is not set
> +# CONFIG_FB is not set
>  # CONFIG_BACKLIGHT_LCD_SUPPORT is not set
>  
>  #
>  # Display device support
>  #
>  # CONFIG_DISPLAY_SUPPORT is not set
> -# CONFIG_VGASTATE is not set
> -# CONFIG_FB is not set
>  
>  #
>  # Console display driver support
> @@ -836,15 +935,7 @@ CONFIG_DAB=y
>  CONFIG_VGA_CONSOLE=y
>  # CONFIG_VGACON_SOFT_SCROLLBACK is not set
>  CONFIG_DUMMY_CONSOLE=y
> -
> -#
> -# Sound
> -#
>  CONFIG_SOUND=m
> -
> -#
> -# Advanced Linux Sound Architecture
> -#
>  CONFIG_SND=m
>  CONFIG_SND_TIMER=m
>  CONFIG_SND_PCM=m
> @@ -862,22 +953,18 @@ CONFIG_SND_SUPPORT_OLD_API=y
>  CONFIG_SND_VERBOSE_PROCFS=y
>  CONFIG_SND_VERBOSE_PRINTK=y
>  # CONFIG_SND_DEBUG is not set
> -
> -#
> -# Generic devices
> -#
> +CONFIG_SND_VMASTER=y
>  CONFIG_SND_MPU401_UART=m
>  CONFIG_SND_OPL3_LIB=m
>  CONFIG_SND_AC97_CODEC=m
> +CONFIG_SND_DRIVERS=y
>  CONFIG_SND_DUMMY=m
>  CONFIG_SND_VIRMIDI=m
>  CONFIG_SND_MTPAV=m
>  CONFIG_SND_SERIAL_U16550=m
>  CONFIG_SND_MPU401=m
> -
> -#
> -# PCI devices
> -#
> +# CONFIG_SND_AC97_POWER_SAVE is not set
> +CONFIG_SND_PCI=y
>  # CONFIG_SND_AD1889 is not set
>  # CONFIG_SND_ALS300 is not set
>  # CONFIG_SND_ALI5451 is not set
> @@ -886,10 +973,12 @@ CONFIG_SND_MPU401=m
>  # CONFIG_SND_AU8810 is not set
>  # CONFIG_SND_AU8820 is not set
>  # CONFIG_SND_AU8830 is not set
> +# CONFIG_SND_AW2 is not set
>  # CONFIG_SND_AZT3328 is not set
>  # CONFIG_SND_BT87X is not set
>  # CONFIG_SND_CA0106 is not set
>  # CONFIG_SND_CMIPCI is not set
> +# CONFIG_SND_OXYGEN is not set
>  CONFIG_SND_CS4281=m
>  CONFIG_SND_CS46XX=m
>  CONFIG_SND_CS46XX_NEW_DSP=y
> @@ -912,10 +1001,10 @@ CONFIG_SND_EMU10K1=m
>  # CONFIG_SND_ES1938 is not set
>  # CONFIG_SND_ES1968 is not set
>  CONFIG_SND_FM801=m
> -# CONFIG_SND_FM801_TEA575X_BOOL is not set
>  # CONFIG_SND_HDA_INTEL is not set
>  # CONFIG_SND_HDSP is not set
>  # CONFIG_SND_HDSPM is not set
> +# CONFIG_SND_HIFIER is not set
>  # CONFIG_SND_ICE1712 is not set
>  # CONFIG_SND_ICE1724 is not set
>  # CONFIG_SND_INTEL8X0 is not set
> @@ -933,29 +1022,19 @@ CONFIG_SND_FM801=m
>  # CONFIG_SND_TRIDENT is not set
>  # CONFIG_SND_VIA82XX is not set
>  # CONFIG_SND_VIA82XX_MODEM is not set
> +# CONFIG_SND_VIRTUOSO is not set
>  # CONFIG_SND_VX222 is not set
>  # CONFIG_SND_YMFPCI is not set
> -# CONFIG_SND_AC97_POWER_SAVE is not set
> -
> -#
> -# USB devices
> -#
> +CONFIG_SND_USB=y
>  # CONFIG_SND_USB_AUDIO is not set
>  # CONFIG_SND_USB_CAIAQ is not set
> -
> -#
> -# System on Chip audio support
> -#
>  # CONFIG_SND_SOC is not set
> -
> -#
> -# Open Sound System
> -#
>  # CONFIG_SOUND_PRIME is not set
>  CONFIG_AC97_BUS=m
>  CONFIG_HID_SUPPORT=y
>  CONFIG_HID=y
>  # CONFIG_HID_DEBUG is not set
> +# CONFIG_HIDRAW is not set
>  
>  #
>  # USB Input Devices
> @@ -976,6 +1055,7 @@ CONFIG_USB_ARCH_HAS_OHCI=y
>  CONFIG_USB_ARCH_HAS_EHCI=y
>  CONFIG_USB=m
>  # CONFIG_USB_DEBUG is not set
> +# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set
>  
>  #
>  # Miscellaneous USB options
> @@ -984,17 +1064,17 @@ CONFIG_USB_DEVICEFS=y
>  CONFIG_USB_DEVICE_CLASS=y
>  # CONFIG_USB_DYNAMIC_MINORS is not set
>  # CONFIG_USB_SUSPEND is not set
> -# CONFIG_USB_PERSIST is not set
>  # CONFIG_USB_OTG is not set
>  
>  #
>  # USB Host Controller Drivers
>  #
> +# CONFIG_USB_C67X00_HCD is not set
>  CONFIG_USB_EHCI_HCD=m
> -# CONFIG_USB_EHCI_SPLIT_ISO is not set
>  # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
>  # CONFIG_USB_EHCI_TT_NEWSCHED is not set
>  # CONFIG_USB_ISP116X_HCD is not set
> +# CONFIG_USB_ISP1760_HCD is not set
>  CONFIG_USB_OHCI_HCD=m
>  # CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
>  # CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
> @@ -1008,6 +1088,7 @@ CONFIG_USB_UHCI_HCD=m
>  #
>  # CONFIG_USB_ACM is not set
>  # CONFIG_USB_PRINTER is not set
> +# CONFIG_USB_WDM is not set
>  
>  #
>  # NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
> @@ -1027,7 +1108,9 @@ CONFIG_USB_STORAGE=m
>  # CONFIG_USB_STORAGE_SDDR55 is not set
>  # CONFIG_USB_STORAGE_JUMPSHOT is not set
>  # CONFIG_USB_STORAGE_ALAUDA is not set
> +# CONFIG_USB_STORAGE_ONETOUCH is not set
>  # CONFIG_USB_STORAGE_KARMA is not set
> +# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
>  # CONFIG_USB_LIBUSUAL is not set
>  
>  #
> @@ -1040,10 +1123,6 @@ CONFIG_USB_MON=y
>  #
>  # USB port drivers
>  #
> -
> -#
> -# USB Serial Converter support
> -#
>  # CONFIG_USB_SERIAL is not set
>  
>  #
> @@ -1069,65 +1148,30 @@ CONFIG_USB_MON=y
>  # CONFIG_USB_TRANCEVIBRATOR is not set
>  # CONFIG_USB_IOWARRIOR is not set
>  # CONFIG_USB_TEST is not set
> -
> -#
> -# USB DSL modem support
> -#
> -
> -#
> -# USB Gadget Support
> -#
> +# CONFIG_USB_ISIGHTFW is not set
>  # CONFIG_USB_GADGET is not set
>  # CONFIG_MMC is not set
> -
> -#
> -# LED devices
> -#
> +# CONFIG_MEMSTICK is not set
>  # CONFIG_NEW_LEDS is not set
> -
> -#
> -# LED drivers
> -#
> -
> -#
> -# LED Triggers
> -#
> +# CONFIG_ACCESSIBILITY is not set
>  CONFIG_INFINIBAND=m
>  # CONFIG_INFINIBAND_USER_MAD is not set
>  # CONFIG_INFINIBAND_USER_ACCESS is not set
>  CONFIG_INFINIBAND_ADDR_TRANS=y
>  CONFIG_INFINIBAND_MTHCA=m
>  CONFIG_INFINIBAND_MTHCA_DEBUG=y
> +# CONFIG_INFINIBAND_IPATH is not set
>  # CONFIG_INFINIBAND_AMSO1100 is not set
>  # CONFIG_MLX4_INFINIBAND is not set
> +# CONFIG_INFINIBAND_NES is not set
>  CONFIG_INFINIBAND_IPOIB=m
>  # CONFIG_INFINIBAND_IPOIB_CM is not set
>  CONFIG_INFINIBAND_IPOIB_DEBUG=y
>  # CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
>  # CONFIG_INFINIBAND_SRP is not set
>  # CONFIG_INFINIBAND_ISER is not set
> -
> -#
> -# Real Time Clock
> -#
>  # CONFIG_RTC_CLASS is not set
> -
> -#
> -# DMA Engine support
> -#
> -# CONFIG_DMA_ENGINE is not set
> -
> -#
> -# DMA Clients
> -#
> -
> -#
> -# DMA Devices
> -#
> -
> -#
> -# Userspace I/O
> -#
> +# CONFIG_DMADEVICES is not set
>  # CONFIG_UIO is not set
>  # CONFIG_MSPEC is not set
>  
> @@ -1145,7 +1189,6 @@ CONFIG_EXT3_FS_POSIX_ACL=y
>  CONFIG_EXT3_FS_SECURITY=y
>  # CONFIG_EXT4DEV_FS is not set
>  CONFIG_JBD=y
> -# CONFIG_JBD_DEBUG is not set
>  CONFIG_FS_MBCACHE=y
>  CONFIG_REISERFS_FS=y
>  # CONFIG_REISERFS_CHECK is not set
> @@ -1157,17 +1200,15 @@ CONFIG_REISERFS_FS_SECURITY=y
>  CONFIG_FS_POSIX_ACL=y
>  CONFIG_XFS_FS=y
>  # CONFIG_XFS_QUOTA is not set
> -# CONFIG_XFS_SECURITY is not set
>  # CONFIG_XFS_POSIX_ACL is not set
>  # CONFIG_XFS_RT is not set
> +# CONFIG_XFS_DEBUG is not set
>  # CONFIG_GFS2_FS is not set
>  # CONFIG_OCFS2_FS is not set
> -# CONFIG_MINIX_FS is not set
> -# CONFIG_ROMFS_FS is not set
> +CONFIG_DNOTIFY=y
>  CONFIG_INOTIFY=y
>  CONFIG_INOTIFY_USER=y
>  # CONFIG_QUOTA is not set
> -CONFIG_DNOTIFY=y
>  CONFIG_AUTOFS_FS=y
>  CONFIG_AUTOFS4_FS=y
>  # CONFIG_FUSE_FS is not set
> @@ -1205,7 +1246,6 @@ CONFIG_TMPFS=y
>  # CONFIG_TMPFS_POSIX_ACL is not set
>  CONFIG_HUGETLBFS=y
>  CONFIG_HUGETLB_PAGE=y
> -CONFIG_RAMFS=y
>  # CONFIG_CONFIGFS_FS is not set
>  
>  #
> @@ -1220,32 +1260,30 @@ CONFIG_RAMFS=y
>  # CONFIG_EFS_FS is not set
>  # CONFIG_CRAMFS is not set
>  # CONFIG_VXFS_FS is not set
> +# CONFIG_MINIX_FS is not set
> +# CONFIG_OMFS_FS is not set
>  # CONFIG_HPFS_FS is not set
>  # CONFIG_QNX4FS_FS is not set
> +# CONFIG_ROMFS_FS is not set
>  # CONFIG_SYSV_FS is not set
>  # CONFIG_UFS_FS is not set
> -
> -#
> -# Network File Systems
> -#
> +CONFIG_NETWORK_FILESYSTEMS=y
>  CONFIG_NFS_FS=m
>  CONFIG_NFS_V3=y
>  # CONFIG_NFS_V3_ACL is not set
>  CONFIG_NFS_V4=y
> -CONFIG_NFS_DIRECTIO=y
>  CONFIG_NFSD=m
>  CONFIG_NFSD_V3=y
>  # CONFIG_NFSD_V3_ACL is not set
>  CONFIG_NFSD_V4=y
> -CONFIG_NFSD_TCP=y
>  CONFIG_LOCKD=m
>  CONFIG_LOCKD_V4=y
>  CONFIG_EXPORTFS=m
>  CONFIG_NFS_COMMON=y
>  CONFIG_SUNRPC=m
>  CONFIG_SUNRPC_GSS=m
> -# CONFIG_SUNRPC_BIND34 is not set
> -CONFIG_RPCSEC_GSS_KRB5=y
> +CONFIG_SUNRPC_XPRT_RDMA=m
> +CONFIG_RPCSEC_GSS_KRB5=m
>  # CONFIG_RPCSEC_GSS_SPKM3 is not set
>  CONFIG_SMB_FS=m
>  CONFIG_SMB_NLS_DEFAULT=y
> @@ -1281,10 +1319,6 @@ CONFIG_SGI_PARTITION=y
>  # CONFIG_KARMA_PARTITION is not set
>  CONFIG_EFI_PARTITION=y
>  # CONFIG_SYSV68_PARTITION is not set
> -
> -#
> -# Native Language Support
> -#
>  CONFIG_NLS=y
>  CONFIG_NLS_DEFAULT="iso8859-1"
>  CONFIG_NLS_CODEPAGE_437=y
> @@ -1325,19 +1359,20 @@ CONFIG_NLS_ISO8859_15=m
>  CONFIG_NLS_KOI8_R=m
>  CONFIG_NLS_KOI8_U=m
>  CONFIG_NLS_UTF8=m
> -
> -#
> -# Distributed Lock Manager
> -#
>  # CONFIG_DLM is not set
> +CONFIG_HAVE_KVM=y
> +CONFIG_VIRTUALIZATION=y
> +# CONFIG_KVM is not set
>  
>  #
>  # Library routines
>  #
>  CONFIG_BITREVERSE=y
> +# CONFIG_GENERIC_FIND_FIRST_BIT is not set
>  # CONFIG_CRC_CCITT is not set
>  # CONFIG_CRC16 is not set
> -# CONFIG_CRC_ITU_T is not set
> +CONFIG_CRC_T10DIF=y
> +CONFIG_CRC_ITU_T=m
>  CONFIG_CRC32=y
>  # CONFIG_CRC7 is not set
>  # CONFIG_LIBCRC32C is not set
> @@ -1358,16 +1393,12 @@ CONFIG_IRQ_PER_CPU=y
>  # CONFIG_HP_SIMSCSI is not set
>  
>  #
> -# Instrumentation Support
> -#
> -# CONFIG_PROFILING is not set
> -# CONFIG_KPROBES is not set
> -
> -#
>  # Kernel hacking
>  #
>  # CONFIG_PRINTK_TIME is not set
> +CONFIG_ENABLE_WARN_DEPRECATED=y
>  CONFIG_ENABLE_MUST_CHECK=y
> +CONFIG_FRAME_WARN 48
>  CONFIG_MAGIC_SYSRQ=y
>  # CONFIG_UNUSED_SYMBOLS is not set
>  # CONFIG_DEBUG_FS is not set
> @@ -1375,10 +1406,14 @@ CONFIG_MAGIC_SYSRQ=y
>  CONFIG_DEBUG_KERNEL=y
>  # CONFIG_DEBUG_SHIRQ is not set
>  CONFIG_DETECT_SOFTLOCKUP=y
> +# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
> +CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
>  CONFIG_SCHED_DEBUG=y
>  # CONFIG_SCHEDSTATS is not set
>  # CONFIG_TIMER_STATS is not set
> -# CONFIG_DEBUG_SLAB is not set
> +# CONFIG_DEBUG_OBJECTS is not set
> +# CONFIG_SLUB_DEBUG_ON is not set
> +# CONFIG_SLUB_STATS is not set
>  # CONFIG_DEBUG_RT_MUTEXES is not set
>  # CONFIG_RT_MUTEX_TESTER is not set
>  # CONFIG_DEBUG_SPINLOCK is not set
> @@ -1388,10 +1423,15 @@ CONFIG_DEBUG_MUTEXES=y
>  # CONFIG_DEBUG_KOBJECT is not set
>  # CONFIG_DEBUG_INFO is not set
>  # CONFIG_DEBUG_VM is not set
> +# CONFIG_DEBUG_WRITECOUNT is not set
> +CONFIG_DEBUG_MEMORY_INIT=y
>  # CONFIG_DEBUG_LIST is not set
> -CONFIG_FORCED_INLINING=y
> +# CONFIG_DEBUG_SG is not set
> +# CONFIG_BOOT_PRINTK_DELAY is not set
>  # CONFIG_RCU_TORTURE_TEST is not set
> +# CONFIG_BACKTRACE_SELF_TEST is not set
>  # CONFIG_FAULT_INJECTION is not set
> +# CONFIG_SAMPLES is not set
>  CONFIG_IA64_GRANULE_16MB=y
>  # CONFIG_IA64_GRANULE_64MB is not set
>  # CONFIG_IA64_PRINT_HAZARDS is not set
> @@ -1405,41 +1445,85 @@ CONFIG_SYSVIPC_COMPAT=y
>  #
>  # CONFIG_KEYS is not set
>  # CONFIG_SECURITY is not set
> +# CONFIG_SECURITY_FILE_CAPABILITIES is not set
>  CONFIG_CRYPTO=y
> +
> +#
> +# Crypto core or helper
> +#
>  CONFIG_CRYPTO_ALGAPI=y
>  CONFIG_CRYPTO_BLKCIPHER=m
>  CONFIG_CRYPTO_MANAGER=m
> +# CONFIG_CRYPTO_GF128MUL is not set
> +# CONFIG_CRYPTO_NULL is not set
> +# CONFIG_CRYPTO_CRYPTD is not set
> +# CONFIG_CRYPTO_AUTHENC is not set
> +# CONFIG_CRYPTO_TEST is not set
> +
> +#
> +# Authenticated Encryption with Associated Data
> +#
> +# CONFIG_CRYPTO_CCM is not set
> +# CONFIG_CRYPTO_GCM is not set
> +# CONFIG_CRYPTO_SEQIV is not set
> +
> +#
> +# Block modes
> +#
> +CONFIG_CRYPTO_CBC=m
> +# CONFIG_CRYPTO_CTR is not set
> +# CONFIG_CRYPTO_CTS is not set
> +CONFIG_CRYPTO_ECB=m
> +# CONFIG_CRYPTO_LRW is not set
> +CONFIG_CRYPTO_PCBC=m
> +# CONFIG_CRYPTO_XTS is not set
> +
> +#
> +# Hash modes
> +#
>  # CONFIG_CRYPTO_HMAC is not set
>  # CONFIG_CRYPTO_XCBC is not set
> -# CONFIG_CRYPTO_NULL is not set
> +
> +#
> +# Digest
> +#
> +# CONFIG_CRYPTO_CRC32C is not set
>  # CONFIG_CRYPTO_MD4 is not set
>  CONFIG_CRYPTO_MD5=y
> +# CONFIG_CRYPTO_MICHAEL_MIC is not set
> +# CONFIG_CRYPTO_RMD128 is not set
> +# CONFIG_CRYPTO_RMD160 is not set
> +# CONFIG_CRYPTO_RMD256 is not set
> +# CONFIG_CRYPTO_RMD320 is not set
>  # CONFIG_CRYPTO_SHA1 is not set
>  # CONFIG_CRYPTO_SHA256 is not set
>  # CONFIG_CRYPTO_SHA512 is not set
> -# CONFIG_CRYPTO_WP512 is not set
>  # CONFIG_CRYPTO_TGR192 is not set
> -# CONFIG_CRYPTO_GF128MUL is not set
> -CONFIG_CRYPTO_ECB=m
> -CONFIG_CRYPTO_CBC=m
> -CONFIG_CRYPTO_PCBC=m
> -# CONFIG_CRYPTO_LRW is not set
> -# CONFIG_CRYPTO_CRYPTD is not set
> -CONFIG_CRYPTO_DES=m
> -# CONFIG_CRYPTO_FCRYPT is not set
> -# CONFIG_CRYPTO_BLOWFISH is not set
> -# CONFIG_CRYPTO_TWOFISH is not set
> -# CONFIG_CRYPTO_SERPENT is not set
> +# CONFIG_CRYPTO_WP512 is not set
> +
> +#
> +# Ciphers
> +#
>  # CONFIG_CRYPTO_AES is not set
> +# CONFIG_CRYPTO_ANUBIS is not set
> +# CONFIG_CRYPTO_ARC4 is not set
> +# CONFIG_CRYPTO_BLOWFISH is not set
> +# CONFIG_CRYPTO_CAMELLIA is not set
>  # CONFIG_CRYPTO_CAST5 is not set
>  # CONFIG_CRYPTO_CAST6 is not set
> -# CONFIG_CRYPTO_TEA is not set
> -# CONFIG_CRYPTO_ARC4 is not set
> +CONFIG_CRYPTO_DES=m
> +# CONFIG_CRYPTO_FCRYPT is not set
>  # CONFIG_CRYPTO_KHAZAD is not set
> -# CONFIG_CRYPTO_ANUBIS is not set
> +# CONFIG_CRYPTO_SALSA20 is not set
> +# CONFIG_CRYPTO_SEED is not set
> +# CONFIG_CRYPTO_SERPENT is not set
> +# CONFIG_CRYPTO_TEA is not set
> +# CONFIG_CRYPTO_TWOFISH is not set
> +
> +#
> +# Compression
> +#
>  # CONFIG_CRYPTO_DEFLATE is not set
> -# CONFIG_CRYPTO_MICHAEL_MIC is not set
> -# CONFIG_CRYPTO_CRC32C is not set
> -# CONFIG_CRYPTO_CAMELLIA is not set
> -# CONFIG_CRYPTO_TEST is not set
> +# CONFIG_CRYPTO_LZO is not set
>  CONFIG_CRYPTO_HW=y
> +# CONFIG_CRYPTO_DEV_HIFN_795X is not set
> 
> 
> 
> Index: contention_unroll/arch/ia64/configs/generic_defconfig
> =================================> --- contention_unroll.orig/arch/ia64/configs/generic_defconfig	2008-07-29 07:11:29.000000000 -0500
> +++ contention_unroll/arch/ia64/configs/generic_defconfig	2008-07-29 07:17:07.449034484 -0500
> @@ -1,7 +1,7 @@
>  #
>  # Automatically generated make config: don't edit
>  # Linux kernel version: 2.6.27-rc1
> -# Tue Jul 29 07:11:14 2008
> +# Tue Jul 29 07:17:05 2008
>  #
>  CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
>  
> @@ -23,10 +23,17 @@ CONFIG_POSIX_MQUEUE=y
>  CONFIG_IKCONFIG=y
>  CONFIG_IKCONFIG_PROC=y
>  CONFIG_LOG_BUF_SHIFT 
> -# CONFIG_CGROUPS is not set
> +CONFIG_CGROUPS=y
> +# CONFIG_CGROUP_DEBUG is not set
> +# CONFIG_CGROUP_NS is not set
> +# CONFIG_CGROUP_DEVICE is not set
> +CONFIG_CPUSETS=y
>  # CONFIG_GROUP_SCHED is not set
> +# CONFIG_CGROUP_CPUACCT is not set
> +# CONFIG_RESOURCE_COUNTERS is not set
>  CONFIG_SYSFS_DEPRECATED=y
>  CONFIG_SYSFS_DEPRECATED_V2=y
> +CONFIG_PROC_PID_CPUSET=y
>  # CONFIG_RELAY is not set
>  CONFIG_NAMESPACES=y
>  # CONFIG_UTS_NS is not set
> @@ -158,7 +165,7 @@ CONFIG_IOSAPIC=y
>  CONFIG_FORCE_MAX_ZONEORDER
>  # CONFIG_VIRT_CPU_ACCOUNTING is not set
>  CONFIG_SMP=y
> -CONFIG_NR_CPUSQ2
> +CONFIG_NR_CPUS@96
>  CONFIG_HOTPLUG_CPU=y
>  CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
>  CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
> @@ -507,7 +514,7 @@ CONFIG_SCSI_WAIT_SCAN=m
>  #
>  CONFIG_SCSI_SPI_ATTRS=y
>  CONFIG_SCSI_FC_ATTRS=y
> -# CONFIG_SCSI_ISCSI_ATTRS is not set
> +CONFIG_SCSI_ISCSI_ATTRS=m
>  CONFIG_SCSI_SAS_ATTRS=y
>  # CONFIG_SCSI_SAS_LIBSAS is not set
>  # CONFIG_SCSI_SRP_ATTRS is not set
> @@ -541,7 +548,7 @@ CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS
>  CONFIG_SCSI_SYM53C8XX_MAX_TAGSd
>  CONFIG_SCSI_SYM53C8XX_MMIO=y
>  CONFIG_SCSI_QLOGIC_1280=y
> -# CONFIG_SCSI_QLA_FC is not set
> +CONFIG_SCSI_QLA_FC=m
>  # CONFIG_SCSI_QLA_ISCSI is not set
>  # CONFIG_SCSI_LPFC is not set
>  # CONFIG_SCSI_DC395x is not set
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

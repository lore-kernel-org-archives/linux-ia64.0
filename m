From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 15 Mar 2004 19:02:40 +0000
Subject: [PATCH] Update SN2 defconfig
Message-Id: <20040315190240.GY6699@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ZmUaFz6apKcXQszQ"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--ZmUaFz6apKcXQszQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi,

This patch is against Linus' latest 2.6.4 bk tree.  It updates the SN2
defconfig file.

Jesse asked me to send it in.
thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--ZmUaFz6apKcXQszQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-defconfig-update.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1630  -> 1.1631 
#	arch/ia64/configs/sn2_defconfig	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/15	mort@green.i.bork.org	1.1631
# Update sn2 defconfig
# --------------------------------------------
#
diff -Nru a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
--- a/arch/ia64/configs/sn2_defconfig	Mon Mar 15 13:55:41 2004
+++ b/arch/ia64/configs/sn2_defconfig	Mon Mar 15 13:55:41 2004
@@ -17,6 +17,7 @@
 # CONFIG_BSD_PROCESS_ACCT is not set
 CONFIG_SYSCTL=y
 CONFIG_LOG_BUF_SHIFT=20
+CONFIG_HOTPLUG=y
 # CONFIG_IKCONFIG is not set
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
@@ -30,7 +31,13 @@
 #
 # Loadable module support
 #
-# CONFIG_MODULES is not set
+CONFIG_MODULES=y
+CONFIG_MODULE_UNLOAD=y
+# CONFIG_MODULE_FORCE_UNLOAD is not set
+CONFIG_OBSOLETE_MODPARM=y
+# CONFIG_MODVERSIONS is not set
+CONFIG_KMOD=y
+CONFIG_STOP_MACHINE=y
 
 #
 # Processor type and features
@@ -40,13 +47,14 @@
 CONFIG_MMU=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_TIME_INTERPOLATION=y
+CONFIG_EFI=y
 # CONFIG_ITANIUM is not set
 CONFIG_MCKINLEY=y
 # CONFIG_IA64_GENERIC is not set
 # CONFIG_IA64_DIG is not set
-# CONFIG_IA64_HP_SIM is not set
 # CONFIG_IA64_HP_ZX1 is not set
 CONFIG_IA64_SGI_SN2=y
+# CONFIG_IA64_HP_SIM is not set
 # CONFIG_IA64_PAGE_SIZE_4KB is not set
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
@@ -57,23 +65,23 @@
 CONFIG_IA64_L1_CACHE_SHIFT=7
 # CONFIG_MCKINLEY_ASTEP_SPECIFIC is not set
 CONFIG_NUMA=y
-CONFIG_DISCONTIGMEM=y
 CONFIG_VIRTUAL_MEM_MAP=y
+CONFIG_DISCONTIGMEM=y
 CONFIG_IA64_MCA=y
+# CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
 # CONFIG_IA64_SGI_SN_SIM is not set
 CONFIG_FORCE_MAX_ZONEORDER=18
 # CONFIG_IA64_PAL_IDLE is not set
 CONFIG_SMP=y
+CONFIG_NR_CPUS=512
 # CONFIG_PREEMPT is not set
+CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
-CONFIG_HAVE_DEC_LOCK=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
-CONFIG_EFI=y
-# CONFIG_EFI_VARS is not set
-CONFIG_NR_CPUS=512
+CONFIG_EFI_VARS=y
 CONFIG_BINFMT_ELF=y
 # CONFIG_BINFMT_MISC is not set
 
@@ -90,12 +98,10 @@
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_PCI=y
 CONFIG_ACPI_SYSTEM=y
-# CONFIG_ACPI_RELAXED_AML is not set
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
 CONFIG_PCI_LEGACY_PROC=y
 CONFIG_PCI_NAMES=y
-CONFIG_HOTPLUG=y
 
 #
 # PCI Hotplug Support
@@ -108,14 +114,14 @@
 # CONFIG_PCMCIA is not set
 
 #
-# Parallel port support
+# Device Drivers
 #
-# CONFIG_PARPORT is not set
 
 #
 # Generic Driver Options
 #
 # CONFIG_FW_LOADER is not set
+# CONFIG_DEBUG_DRIVER is not set
 
 #
 # Memory Technology Devices (MTD)
@@ -123,9 +129,13 @@
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
@@ -133,13 +143,15 @@
 # CONFIG_BLK_DEV_FD is not set
 # CONFIG_BLK_CPQ_DA is not set
 # CONFIG_BLK_CPQ_CISS_DA is not set
-# CONFIG_BLK_DEV_DAC960 is not set
-# CONFIG_BLK_DEV_UMEM is not set
+CONFIG_BLK_DEV_DAC960=m
+CONFIG_BLK_DEV_UMEM=m
 CONFIG_BLK_DEV_LOOP=y
 # CONFIG_BLK_DEV_CRYPTOLOOP is not set
-# CONFIG_BLK_DEV_NBD is not set
-# CONFIG_BLK_DEV_RAM is not set
-# CONFIG_BLK_DEV_INITRD is not set
+CONFIG_BLK_DEV_NBD=m
+# CONFIG_BLK_DEV_CARMEL is not set
+CONFIG_BLK_DEV_RAM=y
+CONFIG_BLK_DEV_RAM_SIZE=4096
+CONFIG_BLK_DEV_INITRD=y
 
 #
 # ATA/ATAPI/MFM/RLL support
@@ -150,21 +162,24 @@
 #
 # Please see Documentation/ide.txt for help/info on IDE drives
 #
-# CONFIG_BLK_DEV_IDEDISK is not set
-CONFIG_BLK_DEV_IDECD=y
-# CONFIG_BLK_DEV_IDETAPE is not set
-# CONFIG_BLK_DEV_IDEFLOPPY is not set
-# CONFIG_BLK_DEV_IDESCSI is not set
+CONFIG_BLK_DEV_IDEDISK=y
+# CONFIG_IDEDISK_MULTI_MODE is not set
+# CONFIG_IDEDISK_STROKE is not set
+CONFIG_BLK_DEV_IDECD=m
+CONFIG_BLK_DEV_IDETAPE=m
+CONFIG_BLK_DEV_IDEFLOPPY=y
+CONFIG_BLK_DEV_IDESCSI=m
 # CONFIG_IDE_TASK_IOCTL is not set
 # CONFIG_IDE_TASKFILE_IO is not set
 
 #
 # IDE chipset support/bugfixes
 #
+CONFIG_IDE_GENERIC=y
 CONFIG_BLK_DEV_IDEPCI=y
 CONFIG_IDEPCI_SHARE_IRQ=y
 # CONFIG_BLK_DEV_OFFBOARD is not set
-# CONFIG_BLK_DEV_GENERIC is not set
+CONFIG_BLK_DEV_GENERIC=y
 # CONFIG_BLK_DEV_OPTI621 is not set
 CONFIG_BLK_DEV_IDEDMA_PCI=y
 # CONFIG_BLK_DEV_IDEDMA_FORCED is not set
@@ -174,19 +189,20 @@
 # CONFIG_BLK_DEV_AEC62XX is not set
 # CONFIG_BLK_DEV_ALI15X3 is not set
 # CONFIG_BLK_DEV_AMD74XX is not set
-# CONFIG_BLK_DEV_CMD64X is not set
+CONFIG_BLK_DEV_CMD64X=m
 # CONFIG_BLK_DEV_TRIFLEX is not set
 # CONFIG_BLK_DEV_CY82C693 is not set
 # CONFIG_BLK_DEV_CS5520 is not set
 # CONFIG_BLK_DEV_CS5530 is not set
-# CONFIG_BLK_DEV_HPT34X is not set
-# CONFIG_BLK_DEV_HPT366 is not set
+CONFIG_BLK_DEV_HPT34X=m
+CONFIG_HPT34X_AUTODMA=y
+CONFIG_BLK_DEV_HPT366=m
 # CONFIG_BLK_DEV_SC1200 is not set
 # CONFIG_BLK_DEV_PIIX is not set
 # CONFIG_BLK_DEV_NS87415 is not set
 # CONFIG_BLK_DEV_PDC202XX_OLD is not set
 # CONFIG_BLK_DEV_PDC202XX_NEW is not set
-# CONFIG_BLK_DEV_SVWKS is not set
+CONFIG_BLK_DEV_SVWKS=m
 CONFIG_BLK_DEV_SGIIOC4=y
 # CONFIG_BLK_DEV_SIIMAGE is not set
 # CONFIG_BLK_DEV_SLC90E66 is not set
@@ -199,26 +215,6 @@
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
-# CONFIG_MD is not set
-
-#
-# Fusion MPT device support
-#
-# CONFIG_FUSION is not set
-
-#
 # SCSI device support
 #
 CONFIG_SCSI=y
@@ -228,31 +224,56 @@
 # SCSI support type (disk, tape, CD-ROM)
 #
 CONFIG_BLK_DEV_SD=y
-# CONFIG_CHR_DEV_ST is not set
-# CONFIG_CHR_DEV_OSST is not set
-# CONFIG_BLK_DEV_SR is not set
-# CONFIG_CHR_DEV_SG is not set
+CONFIG_CHR_DEV_ST=m
+CONFIG_CHR_DEV_OSST=m
+CONFIG_BLK_DEV_SR=y
+# CONFIG_BLK_DEV_SR_VENDOR is not set
+CONFIG_CHR_DEV_SG=m
 
 #
 # Some SCSI devices (e.g. CD jukebox) support multiple LUNs
 #
 # CONFIG_SCSI_MULTI_LUN is not set
 CONFIG_SCSI_REPORT_LUNS=y
-# CONFIG_SCSI_CONSTANTS is not set
+CONFIG_SCSI_CONSTANTS=y
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
 # CONFIG_SCSI_ACARD is not set
 # CONFIG_SCSI_AACRAID is not set
-# CONFIG_SCSI_AIC7XXX is not set
-# CONFIG_SCSI_AIC7XXX_OLD is not set
-# CONFIG_SCSI_AIC79XX is not set
+CONFIG_SCSI_AIC7XXX=m
+CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
+CONFIG_AIC7XXX_RESET_DELAY_MS=15000
+# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
+CONFIG_AIC7XXX_DEBUG_ENABLE=y
+CONFIG_AIC7XXX_DEBUG_MASK=0
+CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
+CONFIG_SCSI_AIC7XXX_OLD=m
+CONFIG_SCSI_AIC79XX=m
+CONFIG_AIC79XX_CMDS_PER_DEVICE=32
+CONFIG_AIC79XX_RESET_DELAY_MS=15000
+# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
+# CONFIG_AIC79XX_ENABLE_RD_STRM is not set
+CONFIG_AIC79XX_DEBUG_ENABLE=y
+CONFIG_AIC79XX_DEBUG_MASK=0
+CONFIG_AIC79XX_REG_PRETTY_PRINT=y
 # CONFIG_SCSI_ADVANSYS is not set
-# CONFIG_SCSI_MEGARAID is not set
-# CONFIG_SCSI_SATA is not set
+CONFIG_SCSI_MEGARAID=m
+CONFIG_SCSI_SATA=y
+CONFIG_SCSI_SATA_SVW=m
+CONFIG_SCSI_ATA_PIIX=m
+CONFIG_SCSI_SATA_PROMISE=m
+CONFIG_SCSI_SATA_VIA=m
+CONFIG_SCSI_SATA_VITESSE=y
 # CONFIG_SCSI_BUSLOGIC is not set
 # CONFIG_SCSI_CPQFCTS is not set
 # CONFIG_SCSI_DMX3191D is not set
@@ -262,16 +283,58 @@
 # CONFIG_SCSI_GDTH is not set
 # CONFIG_SCSI_IPS is not set
 # CONFIG_SCSI_INIA100 is not set
-# CONFIG_SCSI_SYM53C8XX_2 is not set
+CONFIG_SCSI_SYM53C8XX_2=m
+CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
+CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
+CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
+# CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set
 # CONFIG_SCSI_QLOGIC_ISP is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
+CONFIG_SCSI_QLA2XXX=y
+# CONFIG_SCSI_QLA21XX is not set
+CONFIG_SCSI_QLA22XX=y
+CONFIG_SCSI_QLA2300=y
+CONFIG_SCSI_QLA2322=y
+CONFIG_SCSI_QLA6312=y
+CONFIG_SCSI_QLA6322=y
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
-# CONFIG_SCSI_NSP32 is not set
 # CONFIG_SCSI_DEBUG is not set
 
 #
+# Multi-device support (RAID and LVM)
+#
+CONFIG_MD=y
+CONFIG_BLK_DEV_MD=y
+CONFIG_MD_LINEAR=y
+CONFIG_MD_RAID0=y
+CONFIG_MD_RAID1=y
+CONFIG_MD_RAID5=y
+# CONFIG_MD_RAID6 is not set
+CONFIG_MD_MULTIPATH=y
+CONFIG_BLK_DEV_DM=y
+# CONFIG_DM_CRYPT is not set
+
+#
+# Fusion MPT device support
+#
+CONFIG_FUSION=m
+CONFIG_FUSION_MAX_SGE=40
+CONFIG_FUSION_ISENSE=m
+CONFIG_FUSION_CTL=m
+# CONFIG_FUSION_LAN is not set
+
+#
+# IEEE 1394 (FireWire) support
+#
+# CONFIG_IEEE1394 is not set
+
+#
+# I2O device support
+#
+
+#
 # Networking support
 #
 CONFIG_NET=y
@@ -280,41 +343,133 @@
 # Networking options
 #
 CONFIG_PACKET=y
-# CONFIG_PACKET_MMAP is not set
+CONFIG_PACKET_MMAP=y
 CONFIG_NETLINK_DEV=y
 CONFIG_UNIX=y
 # CONFIG_NET_KEY is not set
 CONFIG_INET=y
 CONFIG_IP_MULTICAST=y
-# CONFIG_IP_ADVANCED_ROUTER is not set
+CONFIG_IP_ADVANCED_ROUTER=y
+CONFIG_IP_MULTIPLE_TABLES=y
+# CONFIG_IP_ROUTE_FWMARK is not set
+CONFIG_IP_ROUTE_NAT=y
+CONFIG_IP_ROUTE_MULTIPATH=y
+CONFIG_IP_ROUTE_TOS=y
+CONFIG_IP_ROUTE_VERBOSE=y
 # CONFIG_IP_PNP is not set
-# CONFIG_NET_IPIP is not set
-# CONFIG_NET_IPGRE is not set
-# CONFIG_IP_MROUTE is not set
+CONFIG_NET_IPIP=m
+CONFIG_NET_IPGRE=m
+# CONFIG_NET_IPGRE_BROADCAST is not set
+CONFIG_IP_MROUTE=y
+CONFIG_IP_PIMSM_V1=y
+CONFIG_IP_PIMSM_V2=y
 CONFIG_ARPD=y
 # CONFIG_INET_ECN is not set
 CONFIG_SYN_COOKIES=y
-# CONFIG_INET_AH is not set
-# CONFIG_INET_ESP is not set
-# CONFIG_INET_IPCOMP is not set
-# CONFIG_IPV6 is not set
+CONFIG_INET_AH=m
+CONFIG_INET_ESP=m
+CONFIG_INET_IPCOMP=m
+
+#
+# IP: Virtual Server Configuration
+#
+# CONFIG_IP_VS is not set
+CONFIG_IPV6=m
+CONFIG_IPV6_PRIVACY=y
+CONFIG_INET6_AH=m
+CONFIG_INET6_ESP=m
+CONFIG_INET6_IPCOMP=m
+CONFIG_IPV6_TUNNEL=m
 # CONFIG_DECNET is not set
-# CONFIG_BRIDGE is not set
-# CONFIG_NETFILTER is not set
+CONFIG_BRIDGE=m
+CONFIG_NETFILTER=y
+# CONFIG_NETFILTER_DEBUG is not set
+CONFIG_BRIDGE_NETFILTER=y
+
+#
+# IP: Netfilter Configuration
+#
+CONFIG_IP_NF_CONNTRACK=m
+CONFIG_IP_NF_FTP=m
+CONFIG_IP_NF_IRC=m
+CONFIG_IP_NF_TFTP=m
+CONFIG_IP_NF_AMANDA=m
+CONFIG_IP_NF_QUEUE=m
+CONFIG_IP_NF_IPTABLES=m
+CONFIG_IP_NF_MATCH_LIMIT=m
+CONFIG_IP_NF_MATCH_IPRANGE=m
+CONFIG_IP_NF_MATCH_MAC=m
+CONFIG_IP_NF_MATCH_PKTTYPE=m
+CONFIG_IP_NF_MATCH_MARK=m
+CONFIG_IP_NF_MATCH_MULTIPORT=m
+CONFIG_IP_NF_MATCH_TOS=m
+CONFIG_IP_NF_MATCH_RECENT=m
+CONFIG_IP_NF_MATCH_ECN=m
+CONFIG_IP_NF_MATCH_DSCP=m
+CONFIG_IP_NF_MATCH_AH_ESP=m
+CONFIG_IP_NF_MATCH_LENGTH=m
+CONFIG_IP_NF_MATCH_TTL=m
+CONFIG_IP_NF_MATCH_TCPMSS=m
+CONFIG_IP_NF_MATCH_HELPER=m
+CONFIG_IP_NF_MATCH_STATE=m
+CONFIG_IP_NF_MATCH_CONNTRACK=m
+CONFIG_IP_NF_MATCH_OWNER=m
+CONFIG_IP_NF_MATCH_PHYSDEV=m
+CONFIG_IP_NF_FILTER=m
+CONFIG_IP_NF_TARGET_REJECT=m
+CONFIG_IP_NF_NAT=m
+CONFIG_IP_NF_NAT_NEEDED=y
+CONFIG_IP_NF_TARGET_MASQUERADE=m
+CONFIG_IP_NF_TARGET_REDIRECT=m
+CONFIG_IP_NF_TARGET_NETMAP=m
+CONFIG_IP_NF_TARGET_SAME=m
+# CONFIG_IP_NF_NAT_LOCAL is not set
+CONFIG_IP_NF_NAT_SNMP_BASIC=m
+CONFIG_IP_NF_NAT_IRC=m
+CONFIG_IP_NF_NAT_FTP=m
+CONFIG_IP_NF_NAT_TFTP=m
+CONFIG_IP_NF_NAT_AMANDA=m
+CONFIG_IP_NF_MANGLE=m
+CONFIG_IP_NF_TARGET_TOS=m
+CONFIG_IP_NF_TARGET_ECN=m
+CONFIG_IP_NF_TARGET_DSCP=m
+CONFIG_IP_NF_TARGET_MARK=m
+CONFIG_IP_NF_TARGET_CLASSIFY=m
+CONFIG_IP_NF_TARGET_LOG=m
+CONFIG_IP_NF_TARGET_ULOG=m
+CONFIG_IP_NF_TARGET_TCPMSS=m
+CONFIG_IP_NF_ARPTABLES=m
+CONFIG_IP_NF_ARPFILTER=m
+CONFIG_IP_NF_ARP_MANGLE=m
+# CONFIG_IP_NF_COMPAT_IPCHAINS is not set
+# CONFIG_IP_NF_COMPAT_IPFWADM is not set
+
+#
+# IPv6: Netfilter Configuration
+#
+# CONFIG_IP6_NF_QUEUE is not set
+# CONFIG_IP6_NF_IPTABLES is not set
+
+#
+# Bridge: Netfilter Configuration
+#
+# CONFIG_BRIDGE_NF_EBTABLES is not set
+CONFIG_XFRM=y
+CONFIG_XFRM_USER=m
 
 #
 # SCTP Configuration (EXPERIMENTAL)
 #
-CONFIG_IPV6_SCTP__=y
+CONFIG_IPV6_SCTP__=m
 # CONFIG_IP_SCTP is not set
 # CONFIG_ATM is not set
-# CONFIG_VLAN_8021Q is not set
+CONFIG_VLAN_8021Q=m
 # CONFIG_LLC2 is not set
 # CONFIG_IPX is not set
 # CONFIG_ATALK is not set
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
-# CONFIG_NET_DIVERT is not set
+CONFIG_NET_DIVERT=y
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
 # CONFIG_NET_FASTROUTE is not set
@@ -323,7 +478,30 @@
 #
 # QoS and/or fair queueing
 #
-# CONFIG_NET_SCHED is not set
+CONFIG_NET_SCHED=y
+CONFIG_NET_SCH_CBQ=m
+CONFIG_NET_SCH_HTB=m
+CONFIG_NET_SCH_HFSC=m
+CONFIG_NET_SCH_CSZ=m
+CONFIG_NET_SCH_PRIO=m
+CONFIG_NET_SCH_RED=m
+CONFIG_NET_SCH_SFQ=m
+CONFIG_NET_SCH_TEQL=m
+CONFIG_NET_SCH_TBF=m
+CONFIG_NET_SCH_GRED=m
+CONFIG_NET_SCH_DSMARK=m
+# CONFIG_NET_SCH_INGRESS is not set
+CONFIG_NET_QOS=y
+CONFIG_NET_ESTIMATOR=y
+CONFIG_NET_CLS=y
+CONFIG_NET_CLS_TCINDEX=m
+CONFIG_NET_CLS_ROUTE4=m
+CONFIG_NET_CLS_ROUTE=y
+CONFIG_NET_CLS_FW=m
+CONFIG_NET_CLS_U32=m
+CONFIG_NET_CLS_RSVP=m
+CONFIG_NET_CLS_RSVP6=m
+CONFIG_NET_CLS_POLICE=y
 
 #
 # Network testing
@@ -335,29 +513,70 @@
 # ARCnet devices
 #
 # CONFIG_ARCNET is not set
-# CONFIG_DUMMY is not set
-# CONFIG_BONDING is not set
-# CONFIG_EQUALIZER is not set
-# CONFIG_TUN is not set
+CONFIG_DUMMY=m
+CONFIG_BONDING=m
+CONFIG_EQUALIZER=m
+CONFIG_TUN=m
 # CONFIG_ETHERTAP is not set
 
 #
 # Ethernet (10 or 100Mbit)
 #
-# CONFIG_NET_ETHERNET is not set
+CONFIG_NET_ETHERNET=y
+CONFIG_MII=y
+# CONFIG_HAPPYMEAL is not set
+# CONFIG_SUNGEM is not set
+CONFIG_NET_VENDOR_3COM=y
+CONFIG_VORTEX=m
+CONFIG_TYPHOON=m
+
+#
+# Tulip family network device support
+#
+CONFIG_NET_TULIP=y
+# CONFIG_DE2104X is not set
+CONFIG_TULIP=m
+# CONFIG_TULIP_MWI is not set
+# CONFIG_TULIP_MMIO is not set
+# CONFIG_TULIP_NAPI is not set
+# CONFIG_DE4X5 is not set
+# CONFIG_WINBOND_840 is not set
+# CONFIG_DM9102 is not set
+# CONFIG_HP100 is not set
+CONFIG_NET_PCI=y
+# CONFIG_PCNET32 is not set
+# CONFIG_AMD8111_ETH is not set
+# CONFIG_ADAPTEC_STARFIRE is not set
+# CONFIG_B44 is not set
+# CONFIG_FORCEDETH is not set
+# CONFIG_DGRS is not set
+CONFIG_EEPRO100=y
+# CONFIG_EEPRO100_PIO is not set
+# CONFIG_E100 is not set
+# CONFIG_FEALNX is not set
+# CONFIG_NATSEMI is not set
+# CONFIG_NE2K_PCI is not set
+# CONFIG_8139CP is not set
+# CONFIG_8139TOO is not set
+# CONFIG_SIS900 is not set
+# CONFIG_EPIC100 is not set
+# CONFIG_SUNDANCE is not set
+# CONFIG_VIA_RHINE is not set
 
 #
 # Ethernet (1000 Mbit)
 #
-# CONFIG_ACENIC is not set
-# CONFIG_DL2K is not set
-# CONFIG_E1000 is not set
-# CONFIG_NS83820 is not set
-# CONFIG_HAMACHI is not set
-# CONFIG_YELLOWFIN is not set
-# CONFIG_R8169 is not set
-# CONFIG_SIS190 is not set
-# CONFIG_SK98LIN is not set
+CONFIG_ACENIC=m
+# CONFIG_ACENIC_OMIT_TIGON_I is not set
+CONFIG_DL2K=m
+CONFIG_E1000=y
+# CONFIG_E1000_NAPI is not set
+CONFIG_NS83820=m
+CONFIG_HAMACHI=m
+CONFIG_YELLOWFIN=m
+CONFIG_R8169=m
+CONFIG_SIS190=m
+CONFIG_SK98LIN=m
 CONFIG_TIGON3=y
 
 #
@@ -366,7 +585,14 @@
 # CONFIG_IXGB is not set
 # CONFIG_FDDI is not set
 # CONFIG_HIPPI is not set
-# CONFIG_PPP is not set
+CONFIG_PPP=m
+CONFIG_PPP_MULTILINK=y
+CONFIG_PPP_FILTER=y
+CONFIG_PPP_ASYNC=m
+CONFIG_PPP_SYNC_TTY=m
+CONFIG_PPP_DEFLATE=m
+# CONFIG_PPP_BSDCOMP is not set
+# CONFIG_PPPOE is not set
 # CONFIG_SLIP is not set
 
 #
@@ -378,8 +604,9 @@
 # Token Ring devices
 #
 # CONFIG_TR is not set
-# CONFIG_NET_FC is not set
+CONFIG_NET_FC=y
 # CONFIG_SHAPER is not set
+# CONFIG_NETCONSOLE is not set
 
 #
 # Wan interfaces
@@ -400,11 +627,18 @@
 # Bluetooth support
 #
 # CONFIG_BT is not set
+# CONFIG_NETPOLL is not set
+# CONFIG_NET_POLL_CONTROLLER is not set
 
 #
 # ISDN subsystem
 #
-# CONFIG_ISDN_BOOL is not set
+# CONFIG_ISDN is not set
+
+#
+# Telephony Support
+#
+# CONFIG_PHONE is not set
 
 #
 # Input device support
@@ -465,31 +699,21 @@
 #
 # Serial drivers
 #
-# CONFIG_SERIAL_8250 is not set
+CONFIG_SERIAL_8250=y
+CONFIG_SERIAL_8250_CONSOLE=y
+CONFIG_SERIAL_8250_HCDP=y
+CONFIG_SERIAL_8250_ACPI=y
+CONFIG_SERIAL_8250_NR_UARTS=4
+# CONFIG_SERIAL_8250_EXTENDED is not set
 
 #
 # Non-8250 serial port support
 #
+CONFIG_SERIAL_CORE=y
+CONFIG_SERIAL_CORE_CONSOLE=y
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
+CONFIG_LEGACY_PTYS=y
+CONFIG_LEGACY_PTY_COUNT=256
 
 #
 # Mice
@@ -507,7 +731,6 @@
 #
 # CONFIG_WATCHDOG is not set
 # CONFIG_HW_RANDOM is not set
-# CONFIG_NVRAM is not set
 # CONFIG_GEN_RTC is not set
 CONFIG_EFI_RTC=y
 # CONFIG_DTLK is not set
@@ -522,6 +745,15 @@
 # CONFIG_RAW_DRIVER is not set
 
 #
+# I2C support
+#
+# CONFIG_I2C is not set
+
+#
+# Misc devices
+#
+
+#
 # Multimedia devices
 #
 # CONFIG_VIDEO_DEV is not set
@@ -532,20 +764,60 @@
 # CONFIG_DVB is not set
 
 #
+# Graphics support
+#
+# CONFIG_FB is not set
+
+#
+# Console display driver support
+#
+# CONFIG_VGA_CONSOLE is not set
+# CONFIG_MDA_CONSOLE is not set
+CONFIG_DUMMY_CONSOLE=y
+
+#
+# Sound
+#
+# CONFIG_SOUND is not set
+
+#
+# USB support
+#
+# CONFIG_USB is not set
+
+#
+# USB Gadget Support
+#
+# CONFIG_USB_GADGET is not set
+
+#
 # File systems
 #
-# CONFIG_EXT2_FS is not set
-# CONFIG_EXT3_FS is not set
-# CONFIG_JBD is not set
+CONFIG_EXT2_FS=y
+CONFIG_EXT2_FS_XATTR=y
+CONFIG_EXT2_FS_POSIX_ACL=y
+# CONFIG_EXT2_FS_SECURITY is not set
+CONFIG_EXT3_FS=y
+CONFIG_EXT3_FS_XATTR=y
+CONFIG_EXT3_FS_POSIX_ACL=y
+# CONFIG_EXT3_FS_SECURITY is not set
+CONFIG_JBD=y
+# CONFIG_JBD_DEBUG is not set
+CONFIG_FS_MBCACHE=y
 # CONFIG_REISERFS_FS is not set
 # CONFIG_JFS_FS is not set
+CONFIG_FS_POSIX_ACL=y
 CONFIG_XFS_FS=y
-# CONFIG_XFS_RT is not set
-# CONFIG_XFS_QUOTA is not set
-# CONFIG_XFS_POSIX_ACL is not set
+CONFIG_XFS_RT=y
+CONFIG_XFS_QUOTA=y
+# CONFIG_XFS_SECURITY is not set
+CONFIG_XFS_POSIX_ACL=y
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
-# CONFIG_QUOTA is not set
+CONFIG_QUOTA=y
+# CONFIG_QFMT_V1 is not set
+# CONFIG_QFMT_V2 is not set
+CONFIG_QUOTACTL=y
 CONFIG_AUTOFS_FS=y
 CONFIG_AUTOFS4_FS=y
 
@@ -571,11 +843,10 @@
 CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 # CONFIG_DEVFS_FS is not set
-CONFIG_DEVPTS_FS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+CONFIG_HUGETLBFS=y
+CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
 
 #
@@ -584,6 +855,7 @@
 # CONFIG_ADFS_FS is not set
 # CONFIG_AFFS_FS is not set
 # CONFIG_HFS_FS is not set
+# CONFIG_HFSPLUS_FS is not set
 # CONFIG_BEFS_FS is not set
 # CONFIG_BFS_FS is not set
 # CONFIG_EFS_FS is not set
@@ -609,12 +881,12 @@
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y
 CONFIG_SUNRPC=y
-# CONFIG_SUNRPC_GSS is not set
-# CONFIG_SMB_FS is not set
+# CONFIG_RPCSEC_GSS_KRB5 is not set
+CONFIG_SMB_FS=m
+# CONFIG_SMB_NLS_DEFAULT is not set
 # CONFIG_CIFS is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
-# CONFIG_INTERMEZZO_FS is not set
 # CONFIG_AFS_FS is not set
 
 #
@@ -633,7 +905,7 @@
 # CONFIG_UNIXWARE_DISKLABEL is not set
 # CONFIG_LDM_PARTITION is not set
 # CONFIG_NEC98_PARTITION is not set
-# CONFIG_SGI_PARTITION is not set
+CONFIG_SGI_PARTITION=y
 # CONFIG_ULTRIX_PARTITION is not set
 # CONFIG_SUN_PARTITION is not set
 CONFIG_EFI_PARTITION=y
@@ -682,32 +954,11 @@
 # CONFIG_NLS_UTF8 is not set
 
 #
-# Graphics support
-#
-# CONFIG_FB is not set
-
-#
-# Console display driver support
-#
-# CONFIG_VGA_CONSOLE is not set
-# CONFIG_MDA_CONSOLE is not set
-CONFIG_DUMMY_CONSOLE=y
-
-#
-# Sound
-#
-# CONFIG_SOUND is not set
-
-#
-# USB support
-#
-# CONFIG_USB is not set
-# CONFIG_USB_GADGET is not set
-
-#
 # Library routines
 #
 CONFIG_CRC32=y
+CONFIG_ZLIB_INFLATE=m
+CONFIG_ZLIB_DEFLATE=m
 
 #
 # Profiling support
@@ -717,16 +968,12 @@
 #
 # Kernel hacking
 #
-# CONFIG_IA64_GRANULE_16MB is not set
-CONFIG_IA64_GRANULE_64MB=y
+CONFIG_IA64_GRANULE_16MB=y
+# CONFIG_IA64_GRANULE_64MB is not set
 CONFIG_DEBUG_KERNEL=y
 # CONFIG_IA64_PRINT_HAZARDS is not set
 # CONFIG_DISABLE_VHPT is not set
 CONFIG_MAGIC_SYSRQ=y
-CONFIG_IA64_EARLY_PRINTK=y
-# CONFIG_IA64_EARLY_PRINTK_UART is not set
-# CONFIG_IA64_EARLY_PRINTK_VGA is not set
-CONFIG_IA64_EARLY_PRINTK_SGI_SN=y
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
@@ -742,4 +989,21 @@
 #
 # Cryptographic options
 #
-# CONFIG_CRYPTO is not set
+CONFIG_CRYPTO=y
+CONFIG_CRYPTO_HMAC=y
+# CONFIG_CRYPTO_NULL is not set
+# CONFIG_CRYPTO_MD4 is not set
+CONFIG_CRYPTO_MD5=m
+CONFIG_CRYPTO_SHA1=m
+# CONFIG_CRYPTO_SHA256 is not set
+# CONFIG_CRYPTO_SHA512 is not set
+CONFIG_CRYPTO_DES=m
+# CONFIG_CRYPTO_BLOWFISH is not set
+# CONFIG_CRYPTO_TWOFISH is not set
+# CONFIG_CRYPTO_SERPENT is not set
+# CONFIG_CRYPTO_AES is not set
+# CONFIG_CRYPTO_CAST5 is not set
+# CONFIG_CRYPTO_CAST6 is not set
+# CONFIG_CRYPTO_ARC4 is not set
+CONFIG_CRYPTO_DEFLATE=m
+# CONFIG_CRYPTO_TEST is not set

--ZmUaFz6apKcXQszQ--

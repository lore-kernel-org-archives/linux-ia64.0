From: Jes Sorensen <jes@sgi.com>
Date: Thu, 18 Oct 2007 14:59:33 +0000
Subject: [patch] update sn2 defconfig to 64kb pages
Message-Id: <471774D5.7050207@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010007000505030405090408"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010007000505030405090408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Per request of Christoph, here's a patch to update the default page size
to 64KB for sn2's defconfig as well. It's a bit bigger since I also had
it include all the new options that have showed up since the last
update.

Cheers,
Jes


--------------010007000505030405090408
Content-Type: text/plain;
 name="sn-defconfig-64kb.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sn-defconfig-64kb.diff"

Update sn2_defconfig to select 64KB page size, as well as include new
config options.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/configs/sn2_defconfig |  106 ++++++++++++++++++++--------------------
 1 file changed, 54 insertions(+), 52 deletions(-)

Index: linux-2.6/arch/ia64/configs/sn2_defconfig
===================================================================
--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig
+++ linux-2.6/arch/ia64/configs/sn2_defconfig
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.23-rc6
-# Tue Sep 18 11:24:01 2007
+# Linux kernel version: 2.6.23
+# Thu Oct 18 16:03:40 2007
 #
 CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
 
@@ -27,6 +27,8 @@ CONFIG_TASK_IO_ACCOUNTING=y
 # CONFIG_IKCONFIG is not set
 CONFIG_LOG_BUF_SHIFT=20
 CONFIG_CPUSETS=y
+CONFIG_FAIR_GROUP_SCHED=y
+CONFIG_FAIR_USER_SCHED=y
 CONFIG_SYSFS_DEPRECATED=y
 CONFIG_RELAY=y
 CONFIG_BLK_DEV_INITRD=y
@@ -47,7 +49,6 @@ CONFIG_FUTEX=y
 CONFIG_ANON_INODES=y
 CONFIG_EPOLL=y
 CONFIG_SIGNALFD=y
-CONFIG_TIMERFD=y
 CONFIG_EVENTFD=y
 CONFIG_SHMEM=y
 CONFIG_VM_EVENT_COUNTERS=y
@@ -68,6 +69,7 @@ CONFIG_STOP_MACHINE=y
 CONFIG_BLOCK=y
 # CONFIG_BLK_DEV_IO_TRACE is not set
 CONFIG_BLK_DEV_BSG=y
+CONFIG_BLOCK_COMPAT=y
 
 #
 # IO Schedulers
@@ -92,6 +94,7 @@ CONFIG_MMU=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 # CONFIG_ARCH_HAS_ILOG2_U32 is not set
 # CONFIG_ARCH_HAS_ILOG2_U64 is not set
+CONFIG_HUGETLB_PAGE_SIZE_VARIABLE=y
 CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_GENERIC_TIME=y
@@ -112,10 +115,10 @@ CONFIG_IA64_SGI_SN2=y
 CONFIG_MCKINLEY=y
 # CONFIG_IA64_PAGE_SIZE_4KB is not set
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
-CONFIG_IA64_PAGE_SIZE_16KB=y
-# CONFIG_IA64_PAGE_SIZE_64KB is not set
-# CONFIG_PGTABLE_3 is not set
-CONFIG_PGTABLE_4=y
+# CONFIG_IA64_PAGE_SIZE_16KB is not set
+CONFIG_IA64_PAGE_SIZE_64KB=y
+CONFIG_PGTABLE_3=y
+# CONFIG_PGTABLE_4 is not set
 # CONFIG_HZ_100 is not set
 CONFIG_HZ_250=y
 # CONFIG_HZ_300 is not set
@@ -130,6 +133,7 @@ CONFIG_SMP=y
 CONFIG_NR_CPUS=1024
 # CONFIG_HOTPLUG_CPU is not set
 CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
+CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
 CONFIG_SCHED_SMT=y
 CONFIG_PREEMPT_NONE=y
 # CONFIG_PREEMPT_VOLUNTARY is not set
@@ -143,6 +147,7 @@ CONFIG_DISCONTIGMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
 CONFIG_NEED_MULTIPLE_NODES=y
 # CONFIG_SPARSEMEM_STATIC is not set
+CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
 CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_MIGRATION=y
 CONFIG_RESOURCES_64BIT=y
@@ -170,6 +175,7 @@ CONFIG_IA64_PALINFO=y
 CONFIG_IA64_MC_ERR_INJECT=y
 CONFIG_SGI_SN=y
 # CONFIG_IA64_ESI is not set
+# CONFIG_IA64_HP_AML_NFW is not set
 
 #
 # SN Devices
@@ -219,7 +225,6 @@ CONFIG_PCI_DOMAINS=y
 CONFIG_PCI_SYSCALL=y
 CONFIG_PCIEPORTBUS=y
 CONFIG_HOTPLUG_PCI_PCIE=y
-# CONFIG_HOTPLUG_PCI_PCIE_POLL_EVENT_MODE is not set
 CONFIG_PCIEAER=y
 CONFIG_ARCH_SUPPORTS_MSI=y
 # CONFIG_PCI_MSI is not set
@@ -230,10 +235,6 @@ CONFIG_HOTPLUG_PCI=y
 # CONFIG_HOTPLUG_PCI_CPCI is not set
 # CONFIG_HOTPLUG_PCI_SHPC is not set
 CONFIG_HOTPLUG_PCI_SGI=y
-
-#
-# PCCARD (PCMCIA/CardBus) support
-#
 # CONFIG_PCCARD is not set
 
 #
@@ -270,6 +271,7 @@ CONFIG_INET_TUNNEL=m
 CONFIG_INET_XFRM_MODE_TRANSPORT=y
 CONFIG_INET_XFRM_MODE_TUNNEL=y
 CONFIG_INET_XFRM_MODE_BEET=y
+CONFIG_INET_LRO=y
 CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
@@ -341,6 +343,7 @@ CONFIG_IPV6_SIT=m
 #
 # Generic Driver Options
 #
+CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
 CONFIG_STANDALONE=y
 CONFIG_PREVENT_FIRMWARE_BUILD=y
 CONFIG_FW_LOADER=y
@@ -401,7 +404,12 @@ CONFIG_IDE_PROC_FS=y
 # IDE chipset support/bugfixes
 #
 CONFIG_IDE_GENERIC=y
+# CONFIG_BLK_DEV_PLATFORM is not set
 # CONFIG_BLK_DEV_IDEPNP is not set
+
+#
+# PCI IDE chipsets support
+#
 CONFIG_BLK_DEV_IDEPCI=y
 CONFIG_IDEPCI_SHARE_IRQ=y
 CONFIG_IDEPCI_PCIBUS_ORDER=y
@@ -409,8 +417,6 @@ CONFIG_IDEPCI_PCIBUS_ORDER=y
 # CONFIG_BLK_DEV_GENERIC is not set
 # CONFIG_BLK_DEV_OPTI621 is not set
 CONFIG_BLK_DEV_IDEDMA_PCI=y
-# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
-# CONFIG_IDEDMA_ONLYDISK is not set
 # CONFIG_BLK_DEV_AEC62XX is not set
 # CONFIG_BLK_DEV_ALI15X3 is not set
 # CONFIG_BLK_DEV_AMD74XX is not set
@@ -438,7 +444,6 @@ CONFIG_BLK_DEV_SGIIOC4=y
 # CONFIG_BLK_DEV_TC86C001 is not set
 # CONFIG_IDE_ARM is not set
 CONFIG_BLK_DEV_IDEDMA=y
-# CONFIG_IDEDMA_IVB is not set
 # CONFIG_BLK_DEV_HD is not set
 
 #
@@ -481,6 +486,7 @@ CONFIG_SCSI_SAS_ATTRS=y
 CONFIG_SCSI_SAS_LIBSAS=y
 # CONFIG_SCSI_SAS_ATA is not set
 # CONFIG_SCSI_SAS_LIBSAS_DEBUG is not set
+CONFIG_SCSI_SRP_ATTRS=y
 CONFIG_SCSI_LOWLEVEL=y
 CONFIG_ISCSI_TCP=m
 # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
@@ -491,6 +497,7 @@ CONFIG_ISCSI_TCP=m
 # CONFIG_SCSI_AIC7XXX_OLD is not set
 # CONFIG_SCSI_AIC79XX is not set
 # CONFIG_SCSI_AIC94XX is not set
+# CONFIG_SCSI_ADVANSYS is not set
 # CONFIG_SCSI_ARCMSR is not set
 # CONFIG_MEGARAID_NEWGEN is not set
 # CONFIG_MEGARAID_LEGACY is not set
@@ -531,6 +538,7 @@ CONFIG_ATA_ACPI=y
 # CONFIG_SATA_VIA is not set
 CONFIG_SATA_VITESSE=y
 # CONFIG_SATA_INIC162X is not set
+# CONFIG_PATA_ACPI is not set
 # CONFIG_PATA_ALI is not set
 # CONFIG_PATA_AMD is not set
 # CONFIG_PATA_ARTOP is not set
@@ -555,6 +563,7 @@ CONFIG_SATA_VITESSE=y
 # CONFIG_PATA_OLDPIIX is not set
 # CONFIG_PATA_NETCELL is not set
 # CONFIG_PATA_NS87410 is not set
+# CONFIG_PATA_NS87415 is not set
 # CONFIG_PATA_OPTI is not set
 # CONFIG_PATA_OPTIDMA is not set
 # CONFIG_PATA_PDC_OLD is not set
@@ -587,10 +596,6 @@ CONFIG_DM_MULTIPATH=m
 CONFIG_DM_MULTIPATH_EMC=m
 # CONFIG_DM_MULTIPATH_RDAC is not set
 # CONFIG_DM_DELAY is not set
-
-#
-# Fusion MPT device support
-#
 CONFIG_FUSION=y
 CONFIG_FUSION_SPI=y
 CONFIG_FUSION_FC=y
@@ -612,13 +617,16 @@ CONFIG_NETDEVICES=y
 # CONFIG_MACVLAN is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
+# CONFIG_VETH is not set
 # CONFIG_NET_SB1000 is not set
+# CONFIG_IP1000 is not set
 # CONFIG_ARCNET is not set
 # CONFIG_NET_ETHERNET is not set
 CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 # CONFIG_E1000 is not set
+# CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
@@ -637,12 +645,15 @@ CONFIG_CHELSIO_T1=m
 CONFIG_CHELSIO_T1_1G=y
 # CONFIG_CHELSIO_T1_NAPI is not set
 CONFIG_CHELSIO_T3=m
+CONFIG_IXGBE=m
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
 # CONFIG_S2IO_NAPI is not set
 # CONFIG_MYRI10GE is not set
 # CONFIG_NETXEN_NIC is not set
+# CONFIG_NIU is not set
 # CONFIG_MLX4_CORE is not set
+# CONFIG_TEHUTI is not set
 # CONFIG_TR is not set
 
 #
@@ -668,6 +679,7 @@ CONFIG_S2IO=m
 # CONFIG_NET_FC is not set
 # CONFIG_SHAPER is not set
 CONFIG_NETCONSOLE=y
+# CONFIG_NETCONSOLE_DYNAMIC is not set
 CONFIG_NETPOLL=y
 # CONFIG_NETPOLL_TRAP is not set
 CONFIG_NET_POLL_CONTROLLER=y
@@ -689,7 +701,6 @@ CONFIG_INPUT_MOUSEDEV=y
 CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
 CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
 # CONFIG_INPUT_JOYDEV is not set
-# CONFIG_INPUT_TSDEV is not set
 # CONFIG_INPUT_EVDEV is not set
 # CONFIG_INPUT_EVBUG is not set
 
@@ -713,6 +724,7 @@ CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
 # Character devices
 #
 CONFIG_VT=y
+# CONFIG_VT_UNICODE is not set
 CONFIG_VT_CONSOLE=y
 CONFIG_HW_CONSOLE=y
 # CONFIG_VT_HW_CONSOLE_BINDING is not set
@@ -759,9 +771,6 @@ CONFIG_LEGACY_PTY_COUNT=256
 CONFIG_EFI_RTC=y
 # CONFIG_R3964 is not set
 # CONFIG_APPLICOM is not set
-CONFIG_AGP=y
-CONFIG_AGP_SGI_TIOCA=y
-# CONFIG_DRM is not set
 CONFIG_RAW_DRIVER=m
 CONFIG_MAX_RAW_DEVS=256
 # CONFIG_HPET is not set
@@ -781,6 +790,12 @@ CONFIG_DEVPORT=y
 # CONFIG_HWMON is not set
 
 #
+# Sonics Silicon Backplane
+#
+CONFIG_SSB_POSSIBLE=y
+# CONFIG_SSB is not set
+
+#
 # Multifunction device drivers
 #
 # CONFIG_MFD_SM501 is not set
@@ -795,15 +810,18 @@ CONFIG_DEVPORT=y
 #
 # Graphics support
 #
+CONFIG_AGP=y
+CONFIG_AGP_SGI_TIOCA=y
+# CONFIG_DRM is not set
+# CONFIG_VGASTATE is not set
+CONFIG_VIDEO_OUTPUT_CONTROL=m
+# CONFIG_FB is not set
 # CONFIG_BACKLIGHT_LCD_SUPPORT is not set
 
 #
 # Display device support
 #
 # CONFIG_DISPLAY_SUPPORT is not set
-# CONFIG_VGASTATE is not set
-CONFIG_VIDEO_OUTPUT_CONTROL=m
-# CONFIG_FB is not set
 
 #
 # Console display driver support
@@ -819,6 +837,7 @@ CONFIG_DUMMY_CONSOLE=y
 CONFIG_HID_SUPPORT=y
 CONFIG_HID=y
 CONFIG_HID_DEBUG=y
+# CONFIG_HIDRAW is not set
 
 #
 # USB Input Devices
@@ -950,19 +969,6 @@ CONFIG_INFINIBAND_SRP=m
 # CONFIG_RTC_CLASS is not set
 
 #
-# DMA Engine support
-#
-# CONFIG_DMA_ENGINE is not set
-
-#
-# DMA Clients
-#
-
-#
-# DMA Devices
-#
-
-#
 # Userspace I/O
 #
 # CONFIG_UIO is not set
@@ -1004,6 +1010,8 @@ CONFIG_XFS_RT=y
 CONFIG_INOTIFY=y
 CONFIG_INOTIFY_USER=y
 CONFIG_QUOTA=y
+CONFIG_QUOTA_NETLINK_INTERFACE=y
+CONFIG_PRINT_QUOTA_WARNING=y
 # CONFIG_QFMT_V1 is not set
 # CONFIG_QFMT_V2 is not set
 CONFIG_QUOTACTL=y
@@ -1042,7 +1050,6 @@ CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
-CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
@@ -1061,10 +1068,7 @@ CONFIG_RAMFS=y
 # CONFIG_QNX4FS_FS is not set
 # CONFIG_SYSV_FS is not set
 # CONFIG_UFS_FS is not set
-
-#
-# Network File Systems
-#
+CONFIG_NETWORK_FILESYSTEMS=y
 CONFIG_NFS_FS=m
 CONFIG_NFS_V3=y
 # CONFIG_NFS_V3_ACL is not set
@@ -1081,6 +1085,7 @@ CONFIG_EXPORTFS=m
 CONFIG_NFS_COMMON=y
 CONFIG_SUNRPC=m
 CONFIG_SUNRPC_GSS=m
+CONFIG_SUNRPC_XPRT_RDMA=m
 # CONFIG_SUNRPC_BIND34 is not set
 CONFIG_RPCSEC_GSS_KRB5=m
 # CONFIG_RPCSEC_GSS_SPKM3 is not set
@@ -1117,10 +1122,6 @@ CONFIG_SGI_PARTITION=y
 # CONFIG_KARMA_PARTITION is not set
 CONFIG_EFI_PARTITION=y
 # CONFIG_SYSV68_PARTITION is not set
-
-#
-# Native Language Support
-#
 CONFIG_NLS=y
 CONFIG_NLS_DEFAULT="iso8859-1"
 CONFIG_NLS_CODEPAGE_437=y
@@ -1161,10 +1162,6 @@ CONFIG_NLS_ISO8859_1=y
 # CONFIG_NLS_KOI8_R is not set
 # CONFIG_NLS_KOI8_U is not set
 CONFIG_NLS_UTF8=y
-
-#
-# Distributed Lock Manager
-#
 # CONFIG_DLM is not set
 
 #
@@ -1222,6 +1219,7 @@ CONFIG_DEBUG_INFO=y
 # CONFIG_DEBUG_VM is not set
 # CONFIG_DEBUG_LIST is not set
 CONFIG_FORCED_INLINING=y
+# CONFIG_BOOT_PRINTK_DELAY is not set
 # CONFIG_RCU_TORTURE_TEST is not set
 # CONFIG_FAULT_INJECTION is not set
 CONFIG_IA64_GRANULE_16MB=y
@@ -1237,6 +1235,7 @@ CONFIG_SYSVIPC_COMPAT=y
 #
 # CONFIG_KEYS is not set
 # CONFIG_SECURITY is not set
+# CONFIG_SECURITY_FILE_CAPABILITIES is not set
 CONFIG_XOR_BLOCKS=y
 CONFIG_ASYNC_CORE=y
 CONFIG_ASYNC_MEMCPY=y
@@ -1261,6 +1260,7 @@ CONFIG_CRYPTO_ECB=m
 CONFIG_CRYPTO_CBC=m
 CONFIG_CRYPTO_PCBC=m
 # CONFIG_CRYPTO_LRW is not set
+# CONFIG_CRYPTO_XTS is not set
 # CONFIG_CRYPTO_CRYPTD is not set
 CONFIG_CRYPTO_DES=m
 # CONFIG_CRYPTO_FCRYPT is not set
@@ -1274,9 +1274,11 @@ CONFIG_CRYPTO_DES=m
 # CONFIG_CRYPTO_ARC4 is not set
 # CONFIG_CRYPTO_KHAZAD is not set
 # CONFIG_CRYPTO_ANUBIS is not set
+# CONFIG_CRYPTO_SEED is not set
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 CONFIG_CRYPTO_CRC32C=m
 # CONFIG_CRYPTO_CAMELLIA is not set
 # CONFIG_CRYPTO_TEST is not set
+# CONFIG_CRYPTO_AUTHENC is not set
 # CONFIG_CRYPTO_HW is not set

--------------010007000505030405090408--

From: Jes Sorensen <jes@sgi.com>
Date: Thu, 27 Apr 2006 10:10:35 +0000
Subject: [patch] update sn2 defconfig
Message-Id: <yq07j5bs50k.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Would you please apply this one. It's an update to the SN2 defconfig
to match the latest kernel and add the QLA FC drivers.

Thanks,
Jes

Update SN2 defconfig to latest kernel and add QLA FC drivers commonly
found in SN2 boxes.

Signed-off-by: Jes Sorensen <jes@sgi.com> 

---
 arch/ia64/configs/sn2_defconfig |   76 +++++++++++++++++++++++-----------------
 1 file changed, 45 insertions(+), 31 deletions(-)

Index: linux-2.6/arch/ia64/configs/sn2_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig
+++ linux-2.6/arch/ia64/configs/sn2_defconfig
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.16-rc5
-# Mon Feb 27 16:06:38 2006
+# Linux kernel version: 2.6.17-rc3
+# Thu Apr 27 11:48:23 2006
 #
 
 #
@@ -24,6 +24,7 @@
 # CONFIG_AUDIT is not set
 # CONFIG_IKCONFIG is not set
 CONFIG_CPUSETS=y
+CONFIG_RELAY=y
 CONFIG_INITRAMFS_SOURCE=""
 CONFIG_CC_OPTIMIZE_FOR_SIZE=y
 # CONFIG_EMBEDDED is not set
@@ -38,10 +39,6 @@
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
-CONFIG_CC_ALIGN_FUNCTIONS=0
-CONFIG_CC_ALIGN_LABELS=0
-CONFIG_CC_ALIGN_LOOPS=0
-CONFIG_CC_ALIGN_JUMPS=0
 CONFIG_SLAB=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
@@ -53,7 +50,6 @@
 CONFIG_MODULES=y
 CONFIG_MODULE_UNLOAD=y
 # CONFIG_MODULE_FORCE_UNLOAD is not set
-CONFIG_OBSOLETE_MODPARM=y
 # CONFIG_MODVERSIONS is not set
 # CONFIG_MODULE_SRCVERSION_ALL is not set
 CONFIG_KMOD=y
@@ -62,6 +58,7 @@
 #
 # Block layer
 #
+# CONFIG_BLK_DEV_IO_TRACE is not set
 
 #
 # IO Schedulers
@@ -84,8 +81,10 @@
 CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
+CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
 CONFIG_TIME_INTERPOLATION=y
+CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
@@ -116,7 +115,6 @@
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUS24
-CONFIG_IA64_NR_NODES%6
 # CONFIG_HOTPLUG_CPU is not set
 CONFIG_SCHED_SMT=y
 CONFIG_PREEMPT=y
@@ -136,6 +134,7 @@
 CONFIG_ARCH_SPARSEMEM_ENABLE=y
 CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
 CONFIG_NUMA=y
+CONFIG_NODES_SHIFT=8
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_HOLES_IN_ZONE=y
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
@@ -187,7 +186,6 @@
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
 # CONFIG_PCI_MSI is not set
-CONFIG_PCI_LEGACY_PROC=y
 # CONFIG_PCI_DEBUG is not set
 
 #
@@ -231,6 +229,7 @@
 # CONFIG_INET_AH is not set
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
+# CONFIG_INET_XFRM_TUNNEL is not set
 # CONFIG_INET_TUNNEL is not set
 CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
@@ -238,9 +237,11 @@
 CONFIG_TCP_CONG_BIC=y
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
+# CONFIG_IPV6_ROUTER_PREF is not set
 # CONFIG_INET6_AH is not set
 # CONFIG_INET6_ESP is not set
 # CONFIG_INET6_IPCOMP is not set
+# CONFIG_INET6_XFRM_TUNNEL is not set
 # CONFIG_INET6_TUNNEL is not set
 # CONFIG_IPV6_TUNNEL is not set
 # CONFIG_NETFILTER is not set
@@ -468,9 +469,14 @@
 # CONFIG_SCSI_INIA100 is not set
 # CONFIG_SCSI_SYM53C8XX_2 is not set
 # CONFIG_SCSI_IPR is not set
-# CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
-# CONFIG_SCSI_QLA_FC is not set
+CONFIG_SCSI_QLA_FC=y
+CONFIG_SCSI_QLA2XXX_EMBEDDED_FIRMWARE=y
+# CONFIG_SCSI_QLA21XX is not set
+CONFIG_SCSI_QLA22XX=y
+CONFIG_SCSI_QLA2300=y
+CONFIG_SCSI_QLA2322=y
+# CONFIG_SCSI_QLA24XX is not set
 # CONFIG_SCSI_LPFC is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
@@ -486,6 +492,7 @@
 CONFIG_MD_RAID1=y
 # CONFIG_MD_RAID10 is not set
 CONFIG_MD_RAID5=y
+# CONFIG_MD_RAID5_RESHAPE is not set
 # CONFIG_MD_RAID6 is not set
 CONFIG_MD_MULTIPATH=y
 # CONFIG_MD_FAULTY is not set
@@ -694,6 +701,7 @@
 # Ftape, the floppy tape device driver
 #
 CONFIG_AGP=y
+# CONFIG_AGP_VIA is not set
 CONFIG_AGP_SGI_TIOCA=y
 # CONFIG_DRM is not set
 CONFIG_RAW_DRIVER=m
@@ -735,10 +743,6 @@
 #
 
 #
-# Multimedia Capabilities Port drivers
-#
-
-#
 # Multimedia devices
 #
 # CONFIG_VIDEO_DEV is not set
@@ -747,6 +751,7 @@
 # Digital Video Broadcasting Devices
 #
 # CONFIG_DVB is not set
+# CONFIG_USB_DABUSB is not set
 
 #
 # Graphics support
@@ -757,6 +762,7 @@
 # Console display driver support
 #
 CONFIG_VGA_CONSOLE=y
+# CONFIG_VGACON_SOFT_SCROLLBACK is not set
 CONFIG_DUMMY_CONSOLE=y
 
 #
@@ -769,6 +775,7 @@
 #
 CONFIG_USB_ARCH_HAS_HCD=y
 CONFIG_USB_ARCH_HAS_OHCI=y
+CONFIG_USB_ARCH_HAS_EHCI=y
 CONFIG_USB=m
 # CONFIG_USB_DEBUG is not set
 
@@ -829,9 +836,7 @@
 # CONFIG_USB_ACECAD is not set
 # CONFIG_USB_KBTAB is not set
 # CONFIG_USB_POWERMATE is not set
-# CONFIG_USB_MTOUCH is not set
-# CONFIG_USB_ITMTOUCH is not set
-# CONFIG_USB_EGALAX is not set
+# CONFIG_USB_TOUCHSCREEN is not set
 # CONFIG_USB_YEALINK is not set
 # CONFIG_USB_XPAD is not set
 # CONFIG_USB_ATI_REMOTE is not set
@@ -846,15 +851,6 @@
 # CONFIG_USB_MICROTEK is not set
 
 #
-# USB Multimedia devices
-#
-# CONFIG_USB_DABUSB is not set
-
-#
-# Video4Linux support is needed for USB Multimedia device support
-#
-
-#
 # USB Network Adapters
 #
 # CONFIG_USB_CATC is not set
@@ -905,15 +901,29 @@
 # CONFIG_MMC is not set
 
 #
+# LED devices
+#
+# CONFIG_NEW_LEDS is not set
+
+#
+# LED drivers
+#
+
+#
+# LED Triggers
+#
+
+#
 # InfiniBand support
 #
 CONFIG_INFINIBAND=m
 # CONFIG_INFINIBAND_USER_MAD is not set
 CONFIG_INFINIBAND_USER_ACCESS=m
 CONFIG_INFINIBAND_MTHCA=m
-# CONFIG_INFINIBAND_MTHCA_DEBUG is not set
+CONFIG_INFINIBAND_MTHCA_DEBUG=y
 CONFIG_INFINIBAND_IPOIB=m
-# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
+CONFIG_INFINIBAND_IPOIB_DEBUG=y
+# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
 CONFIG_INFINIBAND_SRP=m
 
 #
@@ -923,8 +933,13 @@
 CONFIG_SGI_IOC3=y
 
 #
-# EDAC - error detection and reporting (RAS)
+# EDAC - error detection and reporting (RAS) (EXPERIMENTAL)
+#
+
+#
+# Real Time Clock
 #
+# CONFIG_RTC_CLASS is not set
 
 #
 # File systems
@@ -997,7 +1012,6 @@
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
-CONFIG_RELAYFS_FS=m
 # CONFIG_CONFIGFS_FS is not set
 
 #

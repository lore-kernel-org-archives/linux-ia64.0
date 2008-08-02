From: Robin Holt <holt@sgi.com>
Date: Sat, 02 Aug 2008 18:35:27 +0000
Subject: [Patch 2/2] update generic_defconfig to support sn2.
Message-Id: <20080802183527.GA7290@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch changes the generic_defconfig so it works on all sn2
platforms I have access to.  There is only one support configuration
which was not tested and that configuration is only a combination of two
tested configurations.  With this patchset applied, a generic kernel can
be booted on either a RHEL 5.2, RHEL5.3, or SLES10 SP1 root and operate.
All features needed by SGI's ProPack are also working.  I have not
tested all features of RHEL or SLES, but they do at least boot.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: contention_unroll/arch/ia64/configs/generic_defconfig
=================================--- contention_unroll.orig/arch/ia64/configs/generic_defconfig	2008-08-02 13:16:56.135972118 -0500
+++ contention_unroll/arch/ia64/configs/generic_defconfig	2008-08-02 13:24:13.322305570 -0500
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
 # Linux kernel version: 2.6.27-rc1
-# Fri Aug  1 19:33:14 2008
+# Sat Aug  2 13:24:08 2008
 #
 CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
 
@@ -23,10 +23,17 @@ CONFIG_POSIX_MQUEUE=y
 CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 CONFIG_LOG_BUF_SHIFT 
-# CONFIG_CGROUPS is not set
+CONFIG_CGROUPS=y
+# CONFIG_CGROUP_DEBUG is not set
+# CONFIG_CGROUP_NS is not set
+# CONFIG_CGROUP_DEVICE is not set
+CONFIG_CPUSETS=y
 # CONFIG_GROUP_SCHED is not set
+# CONFIG_CGROUP_CPUACCT is not set
+# CONFIG_RESOURCE_COUNTERS is not set
 CONFIG_SYSFS_DEPRECATED=y
 CONFIG_SYSFS_DEPRECATED_V2=y
+CONFIG_PROC_PID_CPUSET=y
 # CONFIG_RELAY is not set
 CONFIG_NAMESPACES=y
 # CONFIG_UTS_NS is not set
@@ -130,6 +137,7 @@ CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
+CONFIG_IA64_UNCACHED_ALLOCATOR=y
 CONFIG_AUDIT_ARCH=y
 CONFIG_IA64_GENERIC=y
 # CONFIG_IA64_DIG is not set
@@ -158,7 +166,7 @@ CONFIG_IOSAPIC=y
 CONFIG_FORCE_MAX_ZONEORDER
 # CONFIG_VIRT_CPU_ACCOUNTING is not set
 CONFIG_SMP=y
-CONFIG_NR_CPUSQ2
+CONFIG_NR_CPUS@96
 CONFIG_HOTPLUG_CPU=y
 CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
 CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
@@ -369,7 +377,8 @@ CONFIG_EXTRA_FIRMWARE=""
 # CONFIG_DEBUG_DRIVER is not set
 # CONFIG_DEBUG_DEVRES is not set
 # CONFIG_SYS_HYPERVISOR is not set
-# CONFIG_CONNECTOR is not set
+CONFIG_CONNECTOR=y
+CONFIG_PROC_EVENTS=y
 # CONFIG_MTD is not set
 # CONFIG_PARPORT is not set
 CONFIG_PNP=y
@@ -403,7 +412,7 @@ CONFIG_MISC_DEVICES=y
 CONFIG_SGI_IOC4=y
 # CONFIG_TIFM_CORE is not set
 # CONFIG_ENCLOSURE_SERVICES is not set
-# CONFIG_SGI_XP is not set
+CONFIG_SGI_XP=m
 # CONFIG_HP_ILO is not set
 CONFIG_SGI_GRU=m
 # CONFIG_SGI_GRU_DEBUG is not set
@@ -1172,7 +1181,7 @@ CONFIG_INFINIBAND_IPOIB_DEBUG=y
 # CONFIG_RTC_CLASS is not set
 # CONFIG_DMADEVICES is not set
 # CONFIG_UIO is not set
-# CONFIG_MSPEC is not set
+CONFIG_MSPEC=m
 
 #
 # File systems
@@ -1375,6 +1384,7 @@ CONFIG_CRC_ITU_T=m
 CONFIG_CRC32=y
 # CONFIG_CRC7 is not set
 # CONFIG_LIBCRC32C is not set
+CONFIG_GENERIC_ALLOCATOR=y
 CONFIG_PLIST=y
 CONFIG_HAS_IOMEM=y
 CONFIG_HAS_IOPORT=y

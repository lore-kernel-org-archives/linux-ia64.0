From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 06 Jan 2004 01:34:52 +0000
Subject: [PATCH] sn2 defconfig update
Message-Id: <20040106013452.GB21958@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a quick update for the sn2_defconfig file now that some more config
options have been added.

Jesse

=== arch/ia64/configs/sn2_defconfig 1.1 vs edited ==--- 1.1/arch/ia64/configs/sn2_defconfig	Thu Dec 18 03:59:13 2003
+++ edited/arch/ia64/configs/sn2_defconfig	Mon Jan  5 17:31:29 2004
@@ -15,8 +15,6 @@
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 # CONFIG_BSD_PROCESS_ACCT is not set
-CONFIG_PAGG=y
-CONFIG_PAGG_JOB=y
 CONFIG_SYSCTL=y
 CONFIG_LOG_BUF_SHIFT 
 # CONFIG_IKCONFIG is not set
@@ -27,6 +25,7 @@
 CONFIG_IOSCHED_NOOP=y
 CONFIG_IOSCHED_AS=y
 CONFIG_IOSCHED_DEADLINE=y
+# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
 
 #
 # Loadable module support
@@ -53,7 +52,6 @@
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
 CONFIG_ACPI=y
-CONFIG_ACPI_EFI=y
 CONFIG_ACPI_INTERPRETER=y
 CONFIG_ACPI_KERNEL_CONFIG=y
 CONFIG_IA64_L1_CACHE_SHIFT=7
@@ -70,9 +68,10 @@
 # CONFIG_PREEMPT is not set
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
+CONFIG_HAVE_DEC_LOCK=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
-CONFIG_IA64_SALINFO=y
+CONFIG_EFI=y
 # CONFIG_EFI_VARS is not set
 CONFIG_NR_CPUSQ2
 CONFIG_BINFMT_ELF=y
@@ -145,7 +144,60 @@
 #
 # ATA/ATAPI/MFM/RLL support
 #
-# CONFIG_IDE is not set
+CONFIG_IDE=y
+CONFIG_BLK_DEV_IDE=y
+
+#
+# Please see Documentation/ide.txt for help/info on IDE drives
+#
+# CONFIG_BLK_DEV_IDEDISK is not set
+CONFIG_BLK_DEV_IDECD=y
+# CONFIG_BLK_DEV_IDETAPE is not set
+# CONFIG_BLK_DEV_IDEFLOPPY is not set
+# CONFIG_BLK_DEV_IDESCSI is not set
+# CONFIG_IDE_TASK_IOCTL is not set
+# CONFIG_IDE_TASKFILE_IO is not set
+
+#
+# IDE chipset support/bugfixes
+#
+CONFIG_BLK_DEV_IDEPCI=y
+CONFIG_IDEPCI_SHARE_IRQ=y
+# CONFIG_BLK_DEV_OFFBOARD is not set
+# CONFIG_BLK_DEV_GENERIC is not set
+# CONFIG_BLK_DEV_OPTI621 is not set
+CONFIG_BLK_DEV_IDEDMA_PCI=y
+# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
+CONFIG_IDEDMA_PCI_AUTO=y
+# CONFIG_IDEDMA_ONLYDISK is not set
+# CONFIG_IDEDMA_PCI_WIP is not set
+CONFIG_BLK_DEV_ADMA=y
+# CONFIG_BLK_DEV_AEC62XX is not set
+# CONFIG_BLK_DEV_ALI15X3 is not set
+# CONFIG_BLK_DEV_AMD74XX is not set
+# CONFIG_BLK_DEV_CMD64X is not set
+# CONFIG_BLK_DEV_TRIFLEX is not set
+# CONFIG_BLK_DEV_CY82C693 is not set
+# CONFIG_BLK_DEV_CS5520 is not set
+# CONFIG_BLK_DEV_CS5530 is not set
+# CONFIG_BLK_DEV_HPT34X is not set
+# CONFIG_BLK_DEV_HPT366 is not set
+# CONFIG_BLK_DEV_SC1200 is not set
+# CONFIG_BLK_DEV_PIIX is not set
+# CONFIG_BLK_DEV_NS87415 is not set
+# CONFIG_BLK_DEV_PDC202XX_OLD is not set
+# CONFIG_BLK_DEV_PDC202XX_NEW is not set
+# CONFIG_BLK_DEV_SVWKS is not set
+CONFIG_BLK_DEV_SGIIOC4=y
+# CONFIG_BLK_DEV_SIIMAGE is not set
+# CONFIG_BLK_DEV_SLC90E66 is not set
+# CONFIG_BLK_DEV_TRM290 is not set
+# CONFIG_BLK_DEV_VIA82CXXX is not set
+CONFIG_BLK_DEV_IDEDMA=y
+# CONFIG_IDEDMA_IVB is not set
+CONFIG_IDEDMA_AUTO=y
+# CONFIG_DMA_NONPCI is not set
+# CONFIG_BLK_DEV_HD is not set
 
 #
 # IEEE 1394 (FireWire) support (EXPERIMENTAL)
@@ -216,6 +268,7 @@
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
 # CONFIG_SCSI_DC395x is not set
+# CONFIG_SCSI_DC390T is not set
 # CONFIG_SCSI_NSP32 is not set
 # CONFIG_SCSI_DEBUG is not set
 
@@ -585,11 +638,11 @@
 # CONFIG_ULTRIX_PARTITION is not set
 # CONFIG_SUN_PARTITION is not set
 CONFIG_EFI_PARTITION=y
-CONFIG_NLS=y
 
 #
 # Native Language Support
 #
+CONFIG_NLS=y
 CONFIG_NLS_DEFAULT="iso8859-1"
 # CONFIG_NLS_CODEPAGE_437 is not set
 # CONFIG_NLS_CODEPAGE_737 is not set

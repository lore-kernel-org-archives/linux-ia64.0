From: Robin Murphy <robin.murphy@arm.com>
Date: Mon, 13 Sep 2021 12:41:19 +0000
Subject: [PATCH] iommu/dma: Tidy up Kconfig selects
Message-Id: <9ba6f2e8568a3ff6a94fade66668d99705433c44.1631536879.git.robin.murphy@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: joro@8bytes.org, will@kernel.org
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, x86@kernel.org, linux-ia64@vger.kernel.org

Now that the dust has settled on converting all the x86 drivers to
iommu-dma, we can punt the Kconfig selection to arch code where it
was always intended to be.

CC: Christoph Hellwig <hch@lst.de>
CC: Marek Szyprowski <m.szyprowski@samsung.com>
CC: x86@kernel.org
CC: linux-ia64@vger.kernel.org
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 arch/ia64/Kconfig           | 1 +
 arch/x86/Kconfig            | 1 +
 drivers/iommu/Kconfig       | 1 -
 drivers/iommu/amd/Kconfig   | 1 -
 drivers/iommu/intel/Kconfig | 1 -
 5 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 045792cde481..56c00a0851ce 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -51,6 +51,7 @@ config IA64
 	select GENERIC_TIME_VSYSCALL
 	select LEGACY_TIMER_TICK
 	select SWIOTLB
+	select IOMMU_DMA if INTEL_IOMMU
 	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 4e001bbbb425..10ea941e7c80 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -247,6 +247,7 @@ config X86
 	select HAVE_USER_RETURN_NOTIFIER
 	select HAVE_GENERIC_VDSO
 	select HOTPLUG_SMT			if SMP
+	select IOMMU_DMA			if IOMMU_SUPPORT
 	select IRQ_FORCED_THREADING
 	select NEED_SG_DMA_LENGTH
 	select PCI_DOMAINS			if PCI
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 124c41adeca1..3538a2f38b94 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -459,7 +459,6 @@ config VIRTIO_IOMMU
 	depends on VIRTIO
 	depends on (ARM64 || X86)
 	select IOMMU_API
-	select IOMMU_DMA
 	select INTERVAL_TREE
 	select ACPI_VIOT if ACPI
 	help
diff --git a/drivers/iommu/amd/Kconfig b/drivers/iommu/amd/Kconfig
index a3cbafb603f5..9b5fc3356bf2 100644
--- a/drivers/iommu/amd/Kconfig
+++ b/drivers/iommu/amd/Kconfig
@@ -9,7 +9,6 @@ config AMD_IOMMU
 	select PCI_PASID
 	select IOMMU_API
 	select IOMMU_IOVA
-	select IOMMU_DMA
 	select IOMMU_IO_PGTABLE
 	depends on X86_64 && PCI && ACPI && HAVE_CMPXCHG_DOUBLE
 	help
diff --git a/drivers/iommu/intel/Kconfig b/drivers/iommu/intel/Kconfig
index 0ddb77115be7..28c3e922ca27 100644
--- a/drivers/iommu/intel/Kconfig
+++ b/drivers/iommu/intel/Kconfig
@@ -16,7 +16,6 @@ config INTEL_IOMMU
 	select DMAR_TABLE
 	select SWIOTLB
 	select IOASID
-	select IOMMU_DMA
 	select PCI_ATS
 	help
 	  DMA remapping (DMAR) devices support enables independent address
-- 
2.25.1

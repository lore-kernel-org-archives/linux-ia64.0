From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Sun, 07 Apr 2019 12:41:43 +0000
Subject: [PATCH v4 2/6] iommu: keep dma mode build options consistent with cmdline options
Message-Id: <20190407124147.13576-3-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190407124147.13576-1-thunder.leizhen@huawei.com>
In-Reply-To: <20190407124147.13576-1-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

First, add build option IOMMU_DMA_MODE_LAZY, so that we have the
opportunity to set lazy mode as default at build time. Then put the
three config options in an choice, make people can only choose one of the
three at a time, the same to the boot options iommu.dma_mode.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 drivers/iommu/Kconfig | 30 +++++++++++++++++++++++++++---
 drivers/iommu/iommu.c |  4 +++-
 2 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index b67fcabd668f7b6..19118cfdea1c335 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -74,16 +74,40 @@ config IOMMU_DEBUGFS
 	  debug/iommu directory, and then populate a subdirectory with
 	  entries as required.
 
-config IOMMU_DEFAULT_PASSTHROUGH
-	bool "IOMMU passthrough by default"
+choice
+	prompt "IOMMU dma mode"
 	depends on IOMMU_API
+	default IOMMU_DMA_MODE_STRICT
+	help
+	  IOMMU dma mode, such as: passthrough, lazy, strict.
+
+config IOMMU_DMA_MODE_PASSTHROUGH
+	bool "Configure DMA to bypass the IOMMU"
         help
 	  Enable passthrough by default, removing the need to pass in
 	  iommu.dma_mode=passthrough or iommu=pt through command line. If this
 	  is enabled, you can still disable with iommu.dma_mode={lazy|strict}
 	  or iommu=nopt depending on the architecture.
 
-	  If unsure, say N here.
+config IOMMU_DMA_MODE_LAZY
+	bool "IOMMU DMA use lazy mode to flush IOTLB and free IOVA"
+	help
+	  Support lazy mode, where for every IOMMU DMA unmap operation, the
+	  flush operation of IOTLB and the free operation of IOVA are deferred.
+	  They are only guaranteed to be done before the related IOVA will be
+	  reused. Removing the need to pass in kernel parameters through
+	  command line. For example, iommu.dma_mode=lazy on ARM64. If this is
+	  enabled, you can still disable with kernel parameters, such as
+	  iommu.dma_mode=strict depending on the architecture.
+
+config IOMMU_DMA_MODE_STRICT
+	bool "IOMMU DMA use strict mode to flush IOTLB and free IOVA"
+	help
+	  For every IOMMU DMA unmap operation, the flush operation of IOTLB and
+	  the free operation of IOVA are guaranteed to be done in the unmap
+	  function.
+
+endchoice
 
 config OF_IOMMU
        def_bool y
diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index e4d581e6cb8d210..b75e23a2ea08da8 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -39,8 +39,10 @@
 static struct kset *iommu_group_kset;
 static DEFINE_IDA(iommu_group_ida);
 
-#ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
+#if defined(CONFIG_IOMMU_DMA_MODE_PASSTHROUGH)
 #define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_PASSTHROUGH
+#elif defined(CONFIG_IOMMU_DMA_MODE_LAZY)
+#define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_LAZY
 #else
 #define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_STRICT
 #endif
-- 
1.8.3


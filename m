From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Tue, 09 Apr 2019 12:53:04 +0000
Subject: [PATCH v5 2/6] iommu: add build options corresponding to iommu.dma_mode
Message-Id: <20190409125308.18304-3-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190409125308.18304-1-thunder.leizhen@huawei.com>
In-Reply-To: <20190409125308.18304-1-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

First, add build option IOMMU_DEFAULT_{LAZY|STRICT}, so that we have the
opportunity to set {lazy|strict} mode as default at build time. Then put
the three config options in an choice, make people can only choose one of
the three at a time, the same to the boot options iommu.dma_mode.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 Documentation/admin-guide/kernel-parameters.txt |  6 ++--
 drivers/iommu/Kconfig                           | 43 +++++++++++++++++++++----
 drivers/iommu/iommu.c                           |  4 ++-
 3 files changed, 42 insertions(+), 11 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index f7766f8ac8b9084..92d1b3151d003c2 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1811,9 +1811,9 @@
 			1 - Bypass the IOMMU for DMA.
 			unset - Use value of CONFIG_IOMMU_DEFAULT_PASSTHROUGH.
 
-	iommu.dma_mode= Configure default dma mode. if unset, use the value
-			of CONFIG_IOMMU_DEFAULT_PASSTHROUGH to determine
-			passthrough or not.
+	iommu.dma_mode= Configure default dma mode. if unset, use the build
+			options(such as CONFIG_IOMMU_DEFAULT_PASSTHROUGH) to
+			choose which mode to be used.
 			Note: For historical reasons, ARM64/S390/PPC/X86 have
 			their specific options. Currently, only ARM64 support
 			this boot option, and hope other ARCHs to use this as
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 6f07f3b21816c64..1986f9767da488b 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -74,17 +74,46 @@ config IOMMU_DEBUGFS
 	  debug/iommu directory, and then populate a subdirectory with
 	  entries as required.
 
-config IOMMU_DEFAULT_PASSTHROUGH
-	bool "IOMMU passthrough by default"
+choice
+	prompt "IOMMU dma mode"
 	depends on IOMMU_API
-        help
-	  Enable passthrough by default, removing the need to pass in
-	  iommu.passthrough=on or iommu=pt through command line. If this
-	  is enabled, you can still disable with iommu.passthrough=off
-	  or iommu=nopt depending on the architecture.
+	default IOMMU_DEFAULT_STRICT
+	help
+	  This option allows IOMMU dma mode to be chose at build time, to
+	  override the default dma mode of each ARCHs, removing the need to
+	  pass in kernel parameters through command line. You can still use the
+	  generic boot option iommu.dma_mode or ARCHs specific boot options to
+	  override this option again.
+
+config IOMMU_DEFAULT_PASSTHROUGH
+	bool "passthrough"
+	help
+	  In this mode, the dma access through IOMMU without any addresses
+	  transformation. That means, the wrong or illegal dma access can not
+	  be caught, no error information will be reported.
 
 	  If unsure, say N here.
 
+config IOMMU_DEFAULT_LAZY
+	bool "lazy"
+	help
+	  Support lazy mode, where for every IOMMU DMA unmap operation, the
+	  flush operation of IOTLB and the free operation of IOVA are deferred.
+	  They are only guaranteed to be done before the related IOVA will be
+	  reused.
+
+config IOMMU_DEFAULT_STRICT
+	bool "strict"
+	help
+	  For every IOMMU DMA unmap operation, the flush operation of IOTLB and
+	  the free operation of IOVA are guaranteed to be done in the unmap
+	  function.
+
+	  This mode is safer than the two above, but it maybe slow in some high
+	  performace scenarios.
+
+endchoice
+
 config OF_IOMMU
        def_bool y
        depends on OF && IOMMU_API
diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index df1ce8e22385b48..f4171bf4b46eaeb 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -39,8 +39,10 @@
 static struct kset *iommu_group_kset;
 static DEFINE_IDA(iommu_group_ida);
 
-#ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
+#if defined(CONFIG_IOMMU_DEFAULT_PASSTHROUGH)
 #define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_PASSTHROUGH
+#elif defined(CONFIG_IOMMU_DEFAULT_LAZY)
+#define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_LAZY
 #else
 #define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_STRICT
 #endif
-- 
1.8.3


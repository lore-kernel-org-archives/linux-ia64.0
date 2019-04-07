From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Sun, 07 Apr 2019 12:41:42 +0000
Subject: [PATCH v4 1/6] iommu: use iommu.dma_mode to replace iommu.passthrough and iommu.strict
Message-Id: <20190407124147.13576-2-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190407124147.13576-1-thunder.leizhen@huawei.com>
In-Reply-To: <20190407124147.13576-1-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Currently the IOMMU dma contains 3 modes: passthrough, lazy, strict. The
passthrough mode bypass the IOMMU, the lazy mode defer the invalidation
of hardware TLBs, and the strict mode invalidate IOMMU hardware TLBs
synchronously. The three modes are mutually exclusive. So people maybe
confused about iommu.passthrough and iommu.strict, because thay can not
be coexist. Use iommu.dma_mode to replace them will be better.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 33 ++++++++---------
 drivers/iommu/Kconfig                           |  4 +--
 drivers/iommu/iommu.c                           | 48 ++++++++++++++-----------
 include/linux/iommu.h                           |  5 +++
 4 files changed, 50 insertions(+), 40 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 2b8ee90bb64470d..60409ad23b2ac8b 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1792,24 +1792,21 @@
 		nobypass	[PPC/POWERNV]
 			Disable IOMMU bypass, using IOMMU for PCI devices.
 
-	iommu.strict=	[ARM64] Configure TLB invalidation behaviour
-			Format: { "0" | "1" }
-			0 - Lazy mode.
-			  Request that DMA unmap operations use deferred
-			  invalidation of hardware TLBs, for increased
-			  throughput at the cost of reduced device isolation.
-			  Will fall back to strict mode if not supported by
-			  the relevant IOMMU driver.
-			1 - Strict mode (default).
-			  DMA unmap operations invalidate IOMMU hardware TLBs
-			  synchronously.
-
-	iommu.passthrough-			[ARM64] Configure DMA to bypass the IOMMU by default.
-			Format: { "0" | "1" }
-			0 - Use IOMMU translation for DMA.
-			1 - Bypass the IOMMU for DMA.
-			unset - Use value of CONFIG_IOMMU_DEFAULT_PASSTHROUGH.
+
+	iommu.dma_mode= [ARM64] Configure default dma mode. if unset, use the
+			value of CONFIG_IOMMU_DEFAULT_PASSTHROUGH.
+		passthrough
+			Configure DMA to bypass the IOMMU by default.
+		lazy
+			Request that DMA unmap operations use deferred
+			invalidation of hardware TLBs, for increased
+			throughput at the cost of reduced device isolation.
+			Will fall back to strict mode if not supported by
+			the relevant IOMMU driver.
+		strict
+			Default. DMA unmap operations invalidate IOMMU hardware
+			TLBs synchronously.
+
 
 	io7=		[HW] IO7 for Marvel based alpha systems
 			See comment before marvel_specify_io7 in
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 6f07f3b21816c64..b67fcabd668f7b6 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -79,8 +79,8 @@ config IOMMU_DEFAULT_PASSTHROUGH
 	depends on IOMMU_API
         help
 	  Enable passthrough by default, removing the need to pass in
-	  iommu.passthrough=on or iommu=pt through command line. If this
-	  is enabled, you can still disable with iommu.passthrough=off
+	  iommu.dma_mode=passthrough or iommu=pt through command line. If this
+	  is enabled, you can still disable with iommu.dma_mode={lazy|strict}
 	  or iommu=nopt depending on the architecture.
 
 	  If unsure, say N here.
diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index 109de67d5d727c2..e4d581e6cb8d210 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -38,12 +38,13 @@
 
 static struct kset *iommu_group_kset;
 static DEFINE_IDA(iommu_group_ida);
+
 #ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
-static unsigned int iommu_def_domain_type = IOMMU_DOMAIN_IDENTITY;
+#define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_PASSTHROUGH
 #else
-static unsigned int iommu_def_domain_type = IOMMU_DOMAIN_DMA;
+#define IOMMU_DEFAULT_DMA_MODE		IOMMU_DMA_MODE_STRICT
 #endif
-static bool iommu_dma_strict __read_mostly = true;
+static int iommu_default_dma_mode __read_mostly = IOMMU_DEFAULT_DMA_MODE;
 
 struct iommu_callback_data {
 	const struct iommu_ops *ops;
@@ -141,25 +142,29 @@ static int __iommu_attach_group(struct iommu_domain *domain,
 static void __iommu_detach_group(struct iommu_domain *domain,
 				 struct iommu_group *group);
 
-static int __init iommu_set_def_domain_type(char *str)
+static int __init iommu_dma_mode_setup(char *str)
 {
-	bool pt;
-	int ret;
+	if (!str)
+		goto fail;
 
-	ret = kstrtobool(str, &pt);
-	if (ret)
-		return ret;
+	if (!strncmp(str, "passthrough", 11))
+		iommu_default_dma_mode = IOMMU_DMA_MODE_PASSTHROUGH;
+	else if (!strncmp(str, "lazy", 4))
+		iommu_default_dma_mode = IOMMU_DMA_MODE_LAZY;
+	else if (!strncmp(str, "strict", 6))
+		iommu_default_dma_mode = IOMMU_DMA_MODE_STRICT;
+	else
+		goto fail;
+
+	pr_info("Force dma mode to be %d\n", iommu_default_dma_mode);
 
-	iommu_def_domain_type = pt ? IOMMU_DOMAIN_IDENTITY : IOMMU_DOMAIN_DMA;
 	return 0;
-}
-early_param("iommu.passthrough", iommu_set_def_domain_type);
 
-static int __init iommu_dma_setup(char *str)
-{
-	return kstrtobool(str, &iommu_dma_strict);
+fail:
+	pr_debug("Boot option iommu.dma_mode is incorrect, ignored\n");
+	return -EINVAL;
 }
-early_param("iommu.strict", iommu_dma_setup);
+early_param("iommu.dma_mode", iommu_dma_mode_setup);
 
 static ssize_t iommu_group_attr_show(struct kobject *kobj,
 				     struct attribute *__attr, char *buf)
@@ -1102,14 +1107,17 @@ struct iommu_group *iommu_group_get_for_dev(struct device *dev)
 	 */
 	if (!group->default_domain) {
 		struct iommu_domain *dom;
+		int def_domain_type +			(iommu_default_dma_mode = IOMMU_DMA_MODE_PASSTHROUGH)
+			? IOMMU_DOMAIN_IDENTITY : IOMMU_DOMAIN_DMA;
 
-		dom = __iommu_domain_alloc(dev->bus, iommu_def_domain_type);
-		if (!dom && iommu_def_domain_type != IOMMU_DOMAIN_DMA) {
+		dom = __iommu_domain_alloc(dev->bus, def_domain_type);
+		if (!dom && def_domain_type != IOMMU_DOMAIN_DMA) {
 			dom = __iommu_domain_alloc(dev->bus, IOMMU_DOMAIN_DMA);
 			if (dom) {
 				dev_warn(dev,
 					 "failed to allocate default IOMMU domain of type %u; falling back to IOMMU_DOMAIN_DMA",
-					 iommu_def_domain_type);
+					 def_domain_type);
 			}
 		}
 
@@ -1117,7 +1125,7 @@ struct iommu_group *iommu_group_get_for_dev(struct device *dev)
 		if (!group->domain)
 			group->domain = dom;
 
-		if (dom && !iommu_dma_strict) {
+		if (dom && (iommu_default_dma_mode = IOMMU_DMA_MODE_LAZY)) {
 			int attr = 1;
 			iommu_domain_set_attr(dom,
 					      DOMAIN_ATTR_DMA_USE_FLUSH_QUEUE,
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index ffbbc7e39ceeba3..c3f4e3416176496 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -42,6 +42,11 @@
  */
 #define IOMMU_PRIV	(1 << 5)
 
+
+#define IOMMU_DMA_MODE_STRICT		0x0
+#define IOMMU_DMA_MODE_LAZY		0x1
+#define IOMMU_DMA_MODE_PASSTHROUGH	0x2
+
 struct iommu_ops;
 struct iommu_group;
 struct bus_type;
-- 
1.8.3


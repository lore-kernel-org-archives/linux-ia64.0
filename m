From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Thu, 30 May 2019 03:48:29 +0000
Subject: [PATCH v8 5/7] iommu/vt-d: add support for IOMMU default DMA mode build options
Message-Id: <20190530034831.4184-6-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190530034831.4184-1-thunder.leizhen@huawei.com>
In-Reply-To: <20190530034831.4184-1-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

The default DMA mode of INTEL IOMMU is LAZY, this patch make it can be
set to STRICT at build time. It can be overridden by boot option.

There is no functional change.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 drivers/iommu/Kconfig       | 2 +-
 drivers/iommu/intel-iommu.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index b5af859956c4fda..af580274b7c5270 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -79,7 +79,7 @@ choice
 	prompt "IOMMU default DMA mode"
 	depends on IOMMU_API
 	default IOMMU_DEFAULT_PASSTHROUGH if (PPC_POWERNV && PCI)
-	default IOMMU_DEFAULT_LAZY if S390_IOMMU
+	default IOMMU_DEFAULT_LAZY if (INTEL_IOMMU || S390_IOMMU)
 	default IOMMU_DEFAULT_STRICT
 	help
 	  This option allows IOMMU DMA mode to be chose at build time, to
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index a209199f3af6460..50d74ea0acdbdca 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -362,7 +362,7 @@ static int domain_detach_iommu(struct dmar_domain *domain,
 
 static int dmar_map_gfx = 1;
 static int dmar_forcedac;
-static int intel_iommu_strict;
+static int intel_iommu_strict = IS_ENABLED(CONFIG_IOMMU_DEFAULT_STRICT);
 static int intel_iommu_superpage = 1;
 static int intel_iommu_sm;
 static int iommu_identity_mapping;
-- 
1.8.3


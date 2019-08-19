From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 19 Aug 2019 13:22:52 +0000
Subject: [PATCH 07/11] ia64: Get rid of iommu_pass_through
Message-Id: <20190819132256.14436-8-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190819132256.14436-1-joro@8bytes.org>
In-Reply-To: <20190819132256.14436-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

This variable has no users anymore so it can be removed.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/ia64/include/asm/iommu.h | 2 --
 arch/ia64/kernel/pci-dma.c    | 2 --
 2 files changed, 4 deletions(-)

diff --git a/arch/ia64/include/asm/iommu.h b/arch/ia64/include/asm/iommu.h
index 7429a72f3f92..92aceef63710 100644
--- a/arch/ia64/include/asm/iommu.h
+++ b/arch/ia64/include/asm/iommu.h
@@ -8,10 +8,8 @@
 extern void no_iommu_init(void);
 #ifdef	CONFIG_INTEL_IOMMU
 extern int force_iommu, no_iommu;
-extern int iommu_pass_through;
 extern int iommu_detected;
 #else
-#define iommu_pass_through	(0)
 #define no_iommu		(1)
 #define iommu_detected		(0)
 #endif
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index fe988c49f01c..f5d49cd3fbb0 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -22,8 +22,6 @@ int force_iommu __read_mostly = 1;
 int force_iommu __read_mostly;
 #endif
 
-int iommu_pass_through;
-
 static int __init pci_iommu_init(void)
 {
 	if (iommu_detected)
-- 
2.16.4

From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Mon, 18 May 2020 12:08:55 +0000
Subject: [PATCH 2/2] x86: Hide the archdata.iommu field behind generic IOMMU_API
Message-Id: <20200518120855.27822-2-krzk@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200518120855.27822-1-krzk@kernel.org>
In-Reply-To: <20200518120855.27822-1-krzk@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org
Cc: Krzysztof Kozlowski <krzk@kernel.org>

There is a generic, kernel wide configuration symbol for enabling the
IOMMU specific bits: CONFIG_IOMMU_API.  Implementations (including
INTEL_IOMMU and AMD_IOMMU driver) select it so use it here as well.

This makes the conditional archdata.iommu field consistent with other
platforms and also fixes any compile test builds of other IOMMU drivers,
when INTEL_IOMMU or AMD_IOMMU are not selected).

For the case when INTEL_IOMMU/AMD_IOMMU and COMPILE_TEST are not
selected, this should create functionally equivalent code/choice.  With
COMPILE_TEST this field could appear if other IOMMU drivers are chosen
but neither INTEL_IOMMU nor AMD_IOMMU are not.

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>
---
 arch/x86/include/asm/device.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/device.h b/arch/x86/include/asm/device.h
index 7e31f7f1bb06..49bd6cf3eec9 100644
--- a/arch/x86/include/asm/device.h
+++ b/arch/x86/include/asm/device.h
@@ -3,7 +3,7 @@
 #define _ASM_X86_DEVICE_H
 
 struct dev_archdata {
-#if defined(CONFIG_INTEL_IOMMU) || defined(CONFIG_AMD_IOMMU)
+#ifdef CONFIG_IOMMU_API
 	void *iommu; /* hook for IOMMU specific extension */
 #endif
 };
-- 
2.17.1

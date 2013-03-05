From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 05 Mar 2013 13:59:23 +0000
Subject: [PATCH] [RESEND] ia64: change "select DMAR" to "select INTEL_IOMMU"
Message-Id: <1362491963.16460.93.camel@x61.thuisdomein>
List-Id: <linux-ia64.vger.kernel.org>
References: <1321127461.27598.102.camel@x61.thuisdomein>
In-Reply-To: <1321127461.27598.102.camel@x61.thuisdomein>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Suresh Siddha <suresh.b.siddha@intel.com>, Ingo Molnar <mingo@elte.hu>

Commit d3f138106b ("iommu: Rename the DMAR and INTR_REMAP config
options") changed all references to DMAR in Kconfig files to INTEL_IOMMU
(and, likewise, changed the references to CONFIG_DMAR everywhere else
to CONFIG_INTEL_IOMMU). That commit missed one "select DMAR" statement
in ia64's Kconfig file. Change that one too.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) This patch was first send over a year ago. Now I have reapplied it on
top of v3.9-rc1, which only added an offset of two lines.

1) Still tested with "make ARCH=ia64 menuconfig" only (which makes it
rather lightly tested).

2) Everything suggests this was simply an oversight. Otherwise that
select line would have been dropped, wouldn't it?

 arch/ia64/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 33f3fdc..436605b 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -187,7 +187,7 @@ config IA64_DIG
 
 config IA64_DIG_VTD
 	bool "DIG+Intel+IOMMU"
-	select DMAR
+	select INTEL_IOMMU
 	select PCI_MSI
 
 config IA64_HP_ZX1
-- 
1.7.11.7


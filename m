From: Paul Bolle <pebolle@tiscali.nl>
Date: Sat, 12 Nov 2011 19:51:01 +0000
Subject: [PATCH] ia64: change "select DMAR" to "select INTEL_IOMMU"
Message-Id: <1321127461.27598.102.camel@x61.thuisdomein>
List-Id: <linux-ia64.vger.kernel.org>
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
0) Tested with "make ARCH=ia64 menuconfig" only.

1) Everything suggests this was simply an oversight. Otherwise that
select line would have been dropped, wouldn't it?

 arch/ia64/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 552cbe9..c7bf0ea 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -185,7 +185,7 @@ config IA64_DIG
 
 config IA64_DIG_VTD
 	bool "DIG+Intel+IOMMU"
-	select DMAR
+	select INTEL_IOMMU
 	select PCI_MSI
 
 config IA64_HP_ZX1
-- 
1.7.4.4


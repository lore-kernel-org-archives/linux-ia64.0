From: Joe Perches <joe@perches.com>
Date: Wed, 05 Jul 2017 20:02:16 +0000
Subject: [PATCH 07/18] ia64: sn: pci: Move inline before type
Message-Id: <f42b2202bd0d4e7ccf79ce5348bb255a035e67bb.1499284835.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1499284835.git.joe@perches.com>
In-Reply-To: <cover.1499284835.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Make the use of inline like the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/sn/pci/pcibr/pcibr_ate.c | 2 +-
 arch/ia64/sn/pci/tioce_provider.c  | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_ate.c b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
index 5bc34eac9e01..b67bb4cb73ff 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_ate.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
@@ -140,7 +140,7 @@ static inline u64 __iomem *pcibr_ate_addr(struct pcibus_info *pcibus_info,
 /*
  * Update the ate.
  */
-void inline
+inline void
 ate_write(struct pcibus_info *pcibus_info, int ate_index, int count,
 	  volatile u64 ate)
 {
diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index 46d3df4b03a1..3bd9abc35485 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -52,7 +52,7 @@
  * All registers defined in struct tioce will meet that criteria.
  */
 
-static void inline
+static inline void
 tioce_mmr_war_pre(struct tioce_kernel *kern, void __iomem *mmr_addr)
 {
 	u64 mmr_base;
@@ -78,7 +78,7 @@ tioce_mmr_war_pre(struct tioce_kernel *kern, void __iomem *mmr_addr)
 	}
 }
 
-static void inline
+static inline void
 tioce_mmr_war_post(struct tioce_kernel *kern, void __iomem *mmr_addr)
 {
 	u64 mmr_base;
-- 
2.10.0.rc2.1.g053435c


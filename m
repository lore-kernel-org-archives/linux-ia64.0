From: Hanjun Guo <guohanjun@huawei.com>
Date: Mon, 04 Mar 2013 03:46:48 +0000
Subject: [PATCH 1/2] ia64: iosapic: fix a minor typo in comments
Message-Id: <1362368808-28996-1-git-send-email-guohanjun@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>, Jiang Liu <jiang.liu@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

describeinterrupts -> describe interrupts

Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 arch/ia64/kernel/iosapic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index ee33c3a..a6e2f75 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -76,7 +76,7 @@
  *	PCI pin -> global system interrupt (GSI) -> IA-64 vector <-> IRQ
  *
  * Note: The term "IRQ" is loosely used everywhere in Linux kernel to
- * describeinterrupts.  Now we use "IRQ" only for Linux IRQ's.  ISA IRQ
+ * describe interrupts.  Now we use "IRQ" only for Linux IRQ's.  ISA IRQ
  * (isa_irq) is the only exception in this source code.
  */
 
-- 
1.6.0.2



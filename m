From: Hanjun Guo <guohanjun@huawei.com>
Date: Fri, 08 Mar 2013 04:32:52 +0000
Subject: [PATCH V2 1/2] ia64: iosapic: fix a minor typo in comments
Message-Id: <1362717172-36280-1-git-send-email-guohanjun@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>

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



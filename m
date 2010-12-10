From: Joe Perches <joe@perches.com>
Date: Fri, 10 Dec 2010 07:16:55 +0000
Subject: [PATCH 1/2] ia64: Remove unlikely from cpu_is_offline
Message-Id: <c9efab4f338b1c630072c4b8aa5715dfdbb13533.1291965374.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

cpu_is_offline already uses unlikely internally.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/time.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index ed6f22e..9702fa9 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -168,7 +168,7 @@ timer_interrupt (int irq, void *dev_id)
 {
 	unsigned long new_itm;
 
-	if (unlikely(cpu_is_offline(smp_processor_id()))) {
+	if (cpu_is_offline(smp_processor_id())) {
 		return IRQ_HANDLED;
 	}
 
-- 
1.7.3.3.398.g0b0cd.dirty


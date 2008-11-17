From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 17 Nov 2008 01:18:08 +0000
Subject: [PATCH] ia64: use mprintk instead of printk, in ia64_mca_modify_original_stack
Message-Id: <4920C650.4030905@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Using printk from MCA/INIT context is unsafe since it can cause deadlock.
The ia64_mca_modify_original_stack is called from both of mca handler and
init handler, so it should use mprintk instead of printk.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/mca.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 7dd96c1..bab1de2 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1139,7 +1139,7 @@ ia64_mca_modify_original_stack(struct pt_regs *regs,
 	return previous_current;
 
 no_mod:
-	printk(KERN_INFO "cpu %d, %s %s, original stack not modified\n",
+	mprintk(KERN_INFO "cpu %d, %s %s, original stack not modified\n",
 			smp_processor_id(), type, msg);
 	return previous_current;
 }
-- 
1.6.0


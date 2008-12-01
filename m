From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 01 Dec 2008 03:04:18 +0000
Subject: [mmotm][PATCH] fix arch/ia64/kernel/msi_ia64.c warning
Message-Id: <20081201115811.817E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>, Mike Travis <travis@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com

fix following warning.

  arch/ia64/kernel/msi_ia64.c:145: warning: initialization from incompatible pointer type

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Rusty Russell <rusty@rustcorp.com.au>
CC: Mike Travis <travis@sgi.com>
CC: "Luck, Tony" <tony.luck@intel.com>
---
 arch/ia64/kernel/msi_ia64.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: b/arch/ia64/kernel/msi_ia64.c
=================================--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -49,11 +49,12 @@
 static struct irq_chip	ia64_msi_chip;
 
 #ifdef CONFIG_SMP
-static void ia64_set_msi_irq_affinity(unsigned int irq, cpumask_t cpu_mask)
+static void ia64_set_msi_irq_affinity(unsigned int irq,
+				      const cpumask_t *cpu_mask)
 {
 	struct msi_msg msg;
 	u32 addr, data;
-	int cpu = first_cpu(cpu_mask);
+	int cpu = first_cpu(*cpu_mask);
 
 	if (!cpu_online(cpu))
 		return;




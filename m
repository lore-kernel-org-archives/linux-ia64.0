From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 26 Jul 2007 06:30:45 +0000
Subject: [PATCH 1/3] Add sanity check into __bind_irq_vector
Message-Id: <1185431445.3917.67.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add some sanity checks into __bind_irq_vector().

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |    3 +++
 1 files changed, 3 insertions(+)

Index: linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
@@ -145,6 +145,9 @@ static int __bind_irq_vector(int irq, in
 	int cpu;
 	struct irq_cfg *cfg = &irq_cfg[irq];
 
+	BUG_ON((unsigned)irq >= NR_IRQS);
+	BUG_ON((unsigned)vector >= IA64_NUM_VECTORS);
+
 	cpus_and(mask, domain, cpu_online_map);
 	if (cpus_empty(mask))
 		return -EINVAL;



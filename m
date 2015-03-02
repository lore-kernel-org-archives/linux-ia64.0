From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 02 Mar 2015 11:47:44 +0000
Subject: [PATCH 03/16] ia64: Use for_each_cpu_and() and cpumask_any_and() instead of temp var.
Message-Id: <1425296150-4722-3-git-send-email-rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Just a bit of manual neatening, before spatch cleans the rest.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/irq_ia64.c |  4 +---
 arch/ia64/kernel/msi_ia64.c | 10 ++++------
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 698d8fefde6c..3329177c262e 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -161,7 +161,6 @@ int bind_irq_vector(int irq, int vector, cpumask_t domain)
 static void __clear_irq_vector(int irq)
 {
 	int vector, cpu;
-	cpumask_t mask;
 	cpumask_t domain;
 	struct irq_cfg *cfg = &irq_cfg[irq];
 
@@ -169,8 +168,7 @@ static void __clear_irq_vector(int irq)
 	BUG_ON(cfg->vector = IRQ_VECTOR_UNASSIGNED);
 	vector = cfg->vector;
 	domain = cfg->domain;
-	cpumask_and(&mask, &cfg->domain, cpu_online_mask);
-	for_each_cpu_mask(cpu, mask)
+	for_each_cpu_and(cpu, &cfg->domain, cpu_online_mask)
 		per_cpu(vector_irq, cpu)[vector] = -1;
 	cfg->vector = IRQ_VECTOR_UNASSIGNED;
 	cfg->domain = CPU_MASK_NONE;
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 8ae36ea177d3..9dd7464f8c17 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -47,15 +47,14 @@ int ia64_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 	struct msi_msg	msg;
 	unsigned long	dest_phys_id;
 	int	irq, vector;
-	cpumask_t mask;
 
 	irq = create_irq();
 	if (irq < 0)
 		return irq;
 
 	irq_set_msi_desc(irq, desc);
-	cpumask_and(&mask, &(irq_to_domain(irq)), cpu_online_mask);
-	dest_phys_id = cpu_physical_id(first_cpu(mask));
+	dest_phys_id = cpu_physical_id(cpumask_any_and(&(irq_to_domain(irq)),
+						       cpu_online_mask));
 	vector = irq_to_vector(irq);
 
 	msg.address_hi = 0;
@@ -171,10 +170,9 @@ msi_compose_msg(struct pci_dev *pdev, unsigned int irq, struct msi_msg *msg)
 {
 	struct irq_cfg *cfg = irq_cfg + irq;
 	unsigned dest;
-	cpumask_t mask;
 
-	cpumask_and(&mask, &(irq_to_domain(irq)), cpu_online_mask);
-	dest = cpu_physical_id(first_cpu(mask));
+	dest = cpu_physical_id(cpumask_first_and(&(irq_to_domain(irq)),
+						 cpu_online_mask));
 
 	msg->address_hi = 0;
 	msg->address_lo -- 
2.1.0


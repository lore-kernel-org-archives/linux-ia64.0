From: Tony Luck <tony.luck@intel.com>
Date: Tue, 24 Sep 2019 18:45:34 +0000
Subject: [PATCH: Linus, please apply] ia64: Fix some warnings introduced in merge window
Message-Id: <20190924184534.7592-1-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/irq_ia64.c:586:1: warning: no return statement in function returning non-void [-Wr
eturn-type]
arch/ia64/mm/contig.c:111:6: warning: unused variable 'rc' [-Wunused-variable]
arch/ia64/mm/discontig.c:189:39: warning: unused variable 'rc' [-Wunused-variable]

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/kernel/irq_ia64.c | 1 +
 arch/ia64/mm/contig.c       | 1 -
 arch/ia64/mm/discontig.c    | 2 +-
 3 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index f10208478131..8e91c86e8072 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -583,6 +583,7 @@ void ia64_process_pending_intr(void)
 static irqreturn_t dummy_handler (int irq, void *dev_id)
 {
 	BUG();
+	return IRQ_NONE;
 }
 
 static struct irqaction ipi_irqaction = {
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index db09a693f094..5b00dc3898e1 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -108,7 +108,6 @@ setup_per_cpu_areas(void)
 	struct pcpu_group_info *gi;
 	unsigned int cpu;
 	ssize_t static_size, reserved_size, dyn_size;
-	int rc;
 
 	ai = pcpu_alloc_alloc_info(1, num_possible_cpus());
 	if (!ai)
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 219fc640414b..4f33f6e7e206 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -186,7 +186,7 @@ void __init setup_per_cpu_areas(void)
 	unsigned long base_offset;
 	unsigned int cpu;
 	ssize_t static_size, reserved_size, dyn_size;
-	int node, prev_node, unit, nr_units, rc;
+	int node, prev_node, unit, nr_units;
 
 	ai = pcpu_alloc_alloc_info(MAX_NUMNODES, nr_cpu_ids);
 	if (!ai)
-- 
2.20.1

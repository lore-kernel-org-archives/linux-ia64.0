From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 30 Jul 2007 02:54:41 +0000
Subject: [PATCH 1/2] Fix registered interrupt check
Message-Id: <1185764081.3940.55.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix the problem that interrupts are not initialized correctly at PCI
hotplug or driver reloading time.

By vector domain change, the iosapic_rte_info structure was changed to
be on the iosapic_intr_info[irq].rtes list even after the interrupts
are unregistered. So iosapic_intr_info[irq].rtes list must not be
checked to see if there are registered interrupts (RTEs) on the
irq. We must check iosapic_intr_info[irq].count counter instead.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

Index: linux-2.6.23-rc1/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/iosapic.c
@@ -142,7 +142,7 @@ struct iosapic_rte_info {
 static struct iosapic_intr_info {
 	struct list_head rtes;		/* RTEs using this vector (empty =>
 					 * not an IOSAPIC interrupt) */
-	int		count;		/* # of RTEs that shares this vector */
+	int		count;		/* # of registered RTEs */
 	u32		low32;		/* current value of low word of
 					 * Redirection table entry */
 	unsigned int	dest;		/* destination CPU physical ID */
@@ -313,7 +313,7 @@ mask_irq (unsigned int irq)
 	int rte_index;
 	struct iosapic_rte_info *rte;
 
-	if (list_empty(&iosapic_intr_info[irq].rtes))
+	if (!iosapic_intr_info[irq].count)
 		return;			/* not an IOSAPIC interrupt! */
 
 	/* set only the mask bit */
@@ -331,7 +331,7 @@ unmask_irq (unsigned int irq)
 	int rte_index;
 	struct iosapic_rte_info *rte;
 
-	if (list_empty(&iosapic_intr_info[irq].rtes))
+	if (!iosapic_intr_info[irq].count)
 		return;			/* not an IOSAPIC interrupt! */
 
 	low32 = iosapic_intr_info[irq].low32 &= ~IOSAPIC_MASK;
@@ -363,7 +363,7 @@ iosapic_set_affinity (unsigned int irq, 
 
 	dest = cpu_physical_id(first_cpu(mask));
 
-	if (list_empty(&iosapic_intr_info[irq].rtes))
+	if (!iosapic_intr_info[irq].count)
 		return;			/* not an IOSAPIC interrupt */
 
 	set_irq_affinity_info(irq, dest, redir);
@@ -542,7 +542,7 @@ iosapic_reassign_vector (int irq)
 {
 	int new_irq;
 
-	if (!list_empty(&iosapic_intr_info[irq].rtes)) {
+	if (iosapic_intr_info[irq].count) {
 		new_irq = create_irq();
 		if (new_irq < 0)
 			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
@@ -677,7 +677,7 @@ get_target_cpu (unsigned int gsi, int ir
 	 * In case of vector shared by multiple RTEs, all RTEs that
 	 * share the vector need to use the same destination CPU.
 	 */
-	if (!list_empty(&iosapic_intr_info[irq].rtes))
+	if (iosapic_intr_info[irq].count)
 		return iosapic_intr_info[irq].dest;
 
 	/*



From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 30 Jul 2007 02:56:30 +0000
Subject: [PATCH 2/2] Fix possible race in destroy_and_reserve_irq()
Message-Id: <1185764190.3940.58.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently, destroy_and_reserve_irq() sets irq_status[irq] UNUSED using
clear_irq_vector() and sets irq_status[irq] RSVD using reserve_irq().
But there is a race window because vector_lock is once released between
them. This patch fixes this race window.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

Index: linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
@@ -101,15 +101,6 @@ int check_irq_used(int irq)
 	return -1;
 }
 
-static void reserve_irq(unsigned int irq)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&vector_lock, flags);
-	irq_status[irq] = IRQ_RSVD;
-	spin_unlock_irqrestore(&vector_lock, flags);
-}
-
 static inline int find_unassigned_irq(void)
 {
 	int irq;
@@ -302,10 +293,14 @@ static cpumask_t vector_allocation_domai
 
 void destroy_and_reserve_irq(unsigned int irq)
 {
+	unsigned long flags;
+
 	dynamic_irq_cleanup(irq);
 
-	clear_irq_vector(irq);
-	reserve_irq(irq);
+	spin_lock_irqsave(&vector_lock, flags);
+	__clear_irq_vector(irq);
+	irq_status[irq] = IRQ_RSVD;
+	spin_unlock_irqrestore(&vector_lock, flags);
 }
 
 static int __reassign_irq_vector(int irq, int cpu)



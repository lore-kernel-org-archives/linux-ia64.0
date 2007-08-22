From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 22 Aug 2007 10:28:36 +0000
Subject: [PATCH] Remove compiler warinings about uninitialized variable
Message-Id: <1187778516.3798.56.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a patch to remove compiler warinigs about uninitialized
variable.

Thanks,
Kenji Kaneshige

---
This patch removes the following compiler warning messages.

  CC      arch/ia64/kernel/irq_ia64.o
arch/ia64/kernel/irq_ia64.c: In function 'create_irq':
arch/ia64/kernel/irq_ia64.c:343: warning: 'domain.bits[0u]' may be used uninitialized in this function
arch/ia64/kernel/irq_ia64.c: In function 'assign_irq_vector':
arch/ia64/kernel/irq_ia64.c:203: warning: 'domain.bits[0u]' may be used uninitialized in this function

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.23-rc3/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.23-rc3.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.23-rc3/arch/ia64/kernel/irq_ia64.c
@@ -200,7 +200,7 @@ assign_irq_vector (int irq)
 {
 	unsigned long flags;
 	int vector, cpu;
-	cpumask_t domain;
+	cpumask_t domain = CPU_MASK_NONE;
 
 	vector = -ENOSPC;
 
@@ -340,7 +340,7 @@ int create_irq(void)
 {
 	unsigned long flags;
 	int irq, vector, cpu;
-	cpumask_t domain;
+	cpumask_t domain = CPU_MASK_NONE;
 
 	irq = vector = -ENOSPC;
 	spin_lock_irqsave(&vector_lock, flags);



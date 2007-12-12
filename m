From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 12 Dec 2007 07:15:19 +0000
Subject: [PATCH] ia64: Remove compiler warnings on irq_ia64.c
Message-Id: <475F8A87.60802@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This is repost of Kenji's patch at Aug 22.

Thanks,
H.Seto

---
This patch removes the following compiler warning messages.

  CC      arch/ia64/kernel/irq_ia64.o
arch/ia64/kernel/irq_ia64.c: In function 'create_irq':
arch/ia64/kernel/irq_ia64.c:343: warning: 'domain.bits[0u]' may be used uninitialized in this function
arch/ia64/kernel/irq_ia64.c: In function 'assign_irq_vector':
arch/ia64/kernel/irq_ia64.c:203: warning: 'domain.bits[0u]' may be used uninitialized in this function

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.24-rc5/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.24-rc5.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.24-rc5/arch/ia64/kernel/irq_ia64.c
@@ -200,7 +200,7 @@
 {
 	unsigned long flags;
 	int vector, cpu;
-	cpumask_t domain;
+	cpumask_t domain = CPU_MASK_NONE;

 	vector = -ENOSPC;

@@ -340,7 +340,7 @@
 {
 	unsigned long flags;
 	int irq, vector, cpu;
-	cpumask_t domain;
+	cpumask_t domain = CPU_MASK_NONE;

 	irq = vector = -ENOSPC;
 	spin_lock_irqsave(&vector_lock, flags);

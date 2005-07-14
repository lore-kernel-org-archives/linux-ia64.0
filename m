From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:31:05 +0000
Subject: [RFC][patch 6/10] Multiple vector domain support - change irq_to_vector
Message-Id: <42D630D9.8070709@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch changes irq_to_vector() to abolish the identity mapping
between IA-64 vector and Linux IRQ.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN include/asm-ia64/hw_irq.h~vector-domain-ia64-change-irq_to_vector include/asm-ia64/hw_irq.h
--- linux-2.6.13-rc1/include/asm-ia64/hw_irq.h~vector-domain-ia64-change-irq_to_vector	2005-07-13 16:12:49.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h	2005-07-13 16:12:49.000000000 +0900
@@ -207,7 +207,7 @@ irq_descp (int irq)
 static inline ia64_vector
 irq_to_vector (int irq)
 {
-	return (ia64_vector) irq;
+	return (ia64_vector) gsv_to_vector(irq_to_gsv(irq));
 }
 
 /*

_



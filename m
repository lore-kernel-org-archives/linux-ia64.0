From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:28:53 +0000
Subject: [RFC][patch 5/10] Multiple vector domain support - change __ia64_local_vector_to_irq
Message-Id: <42D63055.6070900@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch changes __ia64_local_vector_to_irq() to eliminate identity
mapping between IA-64 vectors and linux IRQs.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq.c    |    3 ++-
 linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff -puN arch/ia64/kernel/irq.c~vector-domain-ia64-change-__ia64_local_vector_to_irq arch/ia64/kernel/irq.c
--- linux-2.6.13-rc1/arch/ia64/kernel/irq.c~vector-domain-ia64-change-__ia64_local_vector_to_irq	2005-07-13 16:12:48.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq.c	2005-07-13 16:12:48.000000000 +0900
@@ -35,7 +35,8 @@ void ack_bad_irq(unsigned int irq)
 #ifdef CONFIG_IA64_GENERIC
 unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return (unsigned int) vec;
+	int domain = ia64_cpu_to_domain(smp_processor_id());
+	return gsv_to_irq(domain_vector_to_gsv(domain, vec));
 }
 #endif
 
diff -puN include/asm-ia64/hw_irq.h~vector-domain-ia64-change-__ia64_local_vector_to_irq include/asm-ia64/hw_irq.h
--- linux-2.6.13-rc1/include/asm-ia64/hw_irq.h~vector-domain-ia64-change-__ia64_local_vector_to_irq	2005-07-13 16:12:48.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h	2005-07-13 16:12:48.000000000 +0900
@@ -181,7 +181,8 @@ extern irq_desc_t irq_desc[NR_IRQS];
 static inline unsigned int
 __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return (unsigned int) vec;
+	int domain = ia64_cpu_to_domain(smp_processor_id());
+	return gsv_to_irq(domain_vector_to_gsv(domain, vec));
 }
 #endif
 

_



From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Sep 2004 11:21:05 +0000
Subject: ia64: kill uniprocessor compilation-warning
Message-Id: <200409081121.i88BL5xZ021231@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kill warning about variables in arch/ia64/kernel/irq.c which are
unused in UP kernels.

Signed-off-by: davidm@hpl.hp.com

=== arch/ia64/kernel/irq.c 1.47 vs edited ==--- 1.47/arch/ia64/kernel/irq.c	2004-08-31 00:57:57 -07:00
+++ edited/arch/ia64/kernel/irq.c	2004-09-08 04:16:13 -07:00
@@ -84,11 +84,13 @@
 	}
 };
 
+#ifdef CONFIG_SMP
 /*
  * This is updated when the user sets irq affinity via /proc
  */
 cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
 static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
+#endif
 
 #ifdef CONFIG_IA64_GENERIC
 irq_desc_t * __ia64_irq_desc (unsigned int irq)

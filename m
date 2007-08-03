From: Russ Anderson <rja@sgi.com>
Date: Fri, 03 Aug 2007 19:32:37 +0000
Subject: [patch] Clean up CPE handler registration
Message-Id: <200708031932.l73JWbcR143006281@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Clean up CPE handler registration

Use local_vector_to_irq() instead of looping through all NR_IRQS.
This avoids registering the CPE handler on multiple irqs.  Only 
register if the irq is valid.  If no valid irq is found, print an
error message and set up polling.

This patch applies on top of Kenji Kaneshige's 
"Implement platform_irq_to_vector() for SN" patch.


Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/kernel/mca.c |   34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2007-08-02 17:53:11.189258072 -0500
+++ test/arch/ia64/kernel/mca.c	2007-08-03 13:55:19.481016222 -0500
@@ -2018,22 +2018,26 @@ ia64_mca_late_init(void)
 
 		if (cpe_vector >= 0) {
 			/* If platform supports CPEI, enable the irq. */
-			cpe_poll_enabled = 0;
-			for (irq = 0; irq < NR_IRQS; ++irq)
-				if (irq_to_vector(irq) = cpe_vector) {
-					desc = irq_desc + irq;
-					desc->status |= IRQ_PER_CPU;
-					setup_irq(irq, &mca_cpe_irqaction);
-					ia64_cpe_irq = irq;
-				}
-			ia64_mca_register_cpev(cpe_vector);
-			IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n", __FUNCTION__);
-		} else {
-			/* If platform doesn't support CPEI, get the timer going. */
-			if (cpe_poll_enabled) {
-				ia64_mca_cpe_poll(0UL);
-				IA64_MCA_DEBUG("%s: CPEP setup and enabled.\n", __FUNCTION__);
+			irq = local_vector_to_irq(cpe_vector);
+			if (irq > 0) {
+				cpe_poll_enabled = 0;
+				desc = irq_desc + irq;
+				desc->status |= IRQ_PER_CPU;
+				setup_irq(irq, &mca_cpe_irqaction);
+				ia64_cpe_irq = irq;
+				ia64_mca_register_cpev(cpe_vector);
+				IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n",
+					__FUNCTION__);
+				return 0;
 			}
+			printk(KERN_ERR "%s: Failed to find irq for CPE "
+					"interrupt handler, vector %d\n",
+					__FUNCTION__, cpe_vector);
+		}
+		/* If platform doesn't support CPEI, get the timer going. */
+		if (cpe_poll_enabled) {
+			ia64_mca_cpe_poll(0UL);
+			IA64_MCA_DEBUG("%s: CPEP setup and enabled.\n", __FUNCTION__);
 		}
 	}
 #endif
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

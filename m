From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 01 Mar 2004 22:45:26 +0000
Subject: [PATCH] don't assume iosapic interrupt controller in mca.c
Message-Id: <20040301224526.GA22182@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Any problems with this patch?  Sn2 doesn't have an iosapic interrupt
controller, so we'd rather not hardcode that type into mca.c for the CPE
interrupt vector.

Thanks,
Jesse

=== arch/ia64/kernel/mca.c 1.59 vs edited ==--- 1.59/arch/ia64/kernel/mca.c	Thu Feb 12 16:14:34 2004
+++ edited/arch/ia64/kernel/mca.c	Mon Mar  1 14:43:35 2004
@@ -103,8 +103,6 @@
 
 static ia64_mc_info_t		ia64_mc_info;
 
-extern struct hw_interrupt_type	irq_type_iosapic_level;
-
 struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
 
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
@@ -1253,7 +1251,6 @@
 				if (irq_to_vector(irq) = cpev) {
 					desc = irq_descp(irq);
 					desc->status |= IRQ_PER_CPU;
-					desc->handler = &irq_type_iosapic_level;
 					setup_irq(irq, &mca_cpe_irqaction);
 				}
 			ia64_mca_register_cpev(cpev);

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 18:03:35 +0000
Subject: [PATCH 2/5] IA64-IRQ: Delete unnecessary braces
Message-Id: <cdcb21f4-c5d8-0d53-6cc4-e819f2e57258@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
In-Reply-To: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Paolo Bonzini <pbonzini@redhat.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 26 Aug 2016 18:40:16 +0200

Do not use curly brackets at a few source code places
where a single statement should be sufficient.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/sn/kernel/irq.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index c7f9eea..9862a97 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -127,9 +127,8 @@ struct sn_irq_info *sn_retarget_vector(struct sn_irq_info *sn_irq_info,
 	struct sn_pcibus_provider *pci_provider;
 
 	bridge = (u64) sn_irq_info->irq_bridge;
-	if (!bridge) {
+	if (!bridge)
 		return NULL; /* irq is not a device interrupt */
-	}
 
 	local_nasid = NASID_GET(bridge);
 
@@ -274,10 +273,9 @@ void sn_irq_init(void)
 	ia64_first_device_vector = IA64_SN2_FIRST_DEVICE_VECTOR;
 	ia64_last_device_vector = IA64_SN2_LAST_DEVICE_VECTOR;
 
-	for (i = 0; i < NR_IRQS; i++) {
+	for (i = 0; i < NR_IRQS; i++)
 		if (irq_get_chip(i) = &no_irq_chip)
 			irq_set_chip(i, &irq_type_sn);
-	}
 }
 
 static void register_intr_pda(struct sn_irq_info *sn_irq_info)
@@ -285,10 +283,8 @@ static void register_intr_pda(struct sn_irq_info *sn_irq_info)
 	int irq = sn_irq_info->irq_irq;
 	int cpu = sn_irq_info->irq_cpuid;
 
-	if (pdacpu(cpu)->sn_last_irq < irq) {
+	if (pdacpu(cpu)->sn_last_irq < irq)
 		pdacpu(cpu)->sn_last_irq = irq;
-	}
-
 	if (pdacpu(cpu)->sn_first_irq = 0 || pdacpu(cpu)->sn_first_irq > irq)
 		pdacpu(cpu)->sn_first_irq = irq;
 }
@@ -304,15 +300,15 @@ static void unregister_intr_pda(struct sn_irq_info *sn_irq_info)
 	if (pdacpu(cpu)->sn_last_irq = irq) {
 		foundmatch = 0;
 		for (i = pdacpu(cpu)->sn_last_irq - 1;
-		     i && !foundmatch; i--) {
+		     i && !foundmatch;
+		     i--)
 			list_for_each_entry_rcu(tmp_irq_info,
 						sn_irq_lh[i],
-						list) {
+						list)
 				if (tmp_irq_info->irq_cpuid = cpu) {
 					foundmatch = 1;
 					break;
 				}
-			}
 		}
 		pdacpu(cpu)->sn_last_irq = i;
 	}
@@ -440,7 +436,7 @@ static void sn_check_intr(int irq, struct sn_irq_info *sn_irq_info)
 	    pdi_pcibus_info;
 	regval = pcireg_intr_status_get(pcibus_info);
 
-	if (!ia64_get_irr(irq_to_vector(irq))) {
+	if (!ia64_get_irr(irq_to_vector(irq)))
 		if (!test_bit(irq, pda->sn_in_service_ivecs)) {
 			regval &= 0xff;
 			if (sn_irq_info->irq_int_bit & regval &
@@ -449,7 +445,6 @@ static void sn_check_intr(int irq, struct sn_irq_info *sn_irq_info)
 				sn_call_force_intr_provider(sn_irq_info);
 			}
 		}
-	}
 	sn_irq_info->irq_last_intr = regval;
 }
 
@@ -462,11 +457,9 @@ void sn_lb_int_war_check(void)
 		return;
 
 	rcu_read_lock();
-	for (i = pda->sn_first_irq; i <= pda->sn_last_irq; i++) {
-		list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[i], list) {
+	for (i = pda->sn_first_irq; i <= pda->sn_last_irq; i++)
+		list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[i], list)
 			sn_check_intr(i, sn_irq_info);
-		}
-	}
 	rcu_read_unlock();
 }
 
-- 
2.9.3


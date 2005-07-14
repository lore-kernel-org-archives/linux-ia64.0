From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:34:47 +0000
Subject: [RFC][patch 8/10] Multiple vector domain support - stop hardware
Message-Id: <42D631B7.6020400@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch is to stop hardware interrupt redirection.

TBD: We might not ought to stop hardware interrupt redirection for
systems that interrupts are redirected on each node. That is, we might
be able to use hardware redirection on each vector domain if it
doesn't redirect interrupts to other domain.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c |   22 +++++++++++++++----
 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/sal.c     |    2 -
 2 files changed, 19 insertions(+), 5 deletions(-)

diff -puN arch/ia64/kernel/iosapic.c~vector-domain-ia64-stop-hw-interrupt-redirection arch/ia64/kernel/iosapic.c
--- linux-2.6.13-rc1/arch/ia64/kernel/iosapic.c~vector-domain-ia64-stop-hw-interrupt-redirection	2005-07-13 16:12:51.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c	2005-07-13 16:12:51.000000000 +0900
@@ -318,7 +318,8 @@ iosapic_set_affinity (unsigned int irq, 
 	u32 high32, low32;
 	int cpu, dest, rte_index, gsv;
 	char __iomem *addr;
-	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
+	int redir = ((smp_int_redirect & SMP_IRQ_REDIRECTION) &&
+		     (irq & IA64_IRQ_REDIRECTED)) ? 1 : 0;
 	struct iosapic_rte_info *rte;
 
 	irq &= (~IA64_IRQ_REDIRECTED);
@@ -792,6 +793,7 @@ iosapic_register_intr (unsigned int gsi,
 	struct iosapic_rte_info *rte;
 	u32 low32;
 	irq_desc_t *idesc;
+	unsigned char dmode;
 again:
 	/*
 	 * If this GSI has already been registered (i.e., it's a
@@ -832,8 +834,12 @@ again:
 		}
 
 		dest = get_target_cpu(gsi, gsv);
-		register_intr(gsi, gsv, IOSAPIC_LOWEST_PRIORITY,
-			      polarity, trigger);
+		if (smp_int_redirect & SMP_IRQ_REDIRECTION)
+			dmode = IOSAPIC_LOWEST_PRIORITY;
+		else
+			dmode = IOSAPIC_FIXED;
+
+		register_intr(gsi, gsv, dmode, polarity, trigger);
 
 		/*
 		 * If the vector is shared and already unmasked for
@@ -971,7 +977,10 @@ iosapic_register_platform_intr (u32 int_
 		break;
 	      case ACPI_INTERRUPT_CPEI:
 		gsv = domain_vector_to_gsv(domain, IA64_CPE_VECTOR);
-		delivery = IOSAPIC_LOWEST_PRIORITY;
+		if (smp_int_redirect & SMP_IRQ_REDIRECTION)
+			delivery = IOSAPIC_LOWEST_PRIORITY;
+		else
+			delivery = IOSAPIC_FIXED;
 		mask = 1;
 		break;
 	      default:
@@ -1005,9 +1014,14 @@ iosapic_override_isa_irq (unsigned int i
 	unsigned int gsv;
 	unsigned int dest = cpu_physical_id(smp_processor_id());
 	unsigned int domain = ia64_cpu_to_domain(smp_processor_id());
+	unsigned char dmode;
 
 	vector = isa_irq_to_vector(isa_irq);
 	gsv = domain_vector_to_gsv(domain, vector);
+	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
+		dmode = IOSAPIC_LOWEST_PRIORITY;
+	else
+		dmode = IOSAPIC_FIXED;
 
 	register_intr(gsi, gsv, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
 
diff -puN arch/ia64/kernel/sal.c~vector-domain-ia64-stop-hw-interrupt-redirection arch/ia64/kernel/sal.c
--- linux-2.6.13-rc1/arch/ia64/kernel/sal.c~vector-domain-ia64-stop-hw-interrupt-redirection	2005-07-13 16:12:51.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/sal.c	2005-07-13 16:12:51.000000000 +0900
@@ -123,7 +123,7 @@ sal_desc_entry_point (void *p)
 static void __init
 set_smp_redirect (int flag)
 {
-#ifndef CONFIG_HOTPLUG_CPU
+#if (!CONFIG_HOTPLUG_CPU && !CONFIG_VECTOR_DOMAIN)
 	if (no_int_routing)
 		smp_int_redirect &= ~flag;
 	else

_



From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 07 Nov 2007 06:38:30 +0000
Subject: Re: [PATCH] ia64: Fix IOSAPIC delivery mode setting
Message-Id: <47315D66.7000606@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <472861AD.5050107@jp.fujitsu.com>
In-Reply-To: <472861AD.5050107@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
> 
> This breaks the build on CONFIG_SMP=n configurations (neither
> smp_int_redirect nor SMP_IRQ_REDIRECTION is defined).
> 

Thank you for pointing out it, and I'm sorry about it.
I'm attaching the fixed one. I noticed that the same fix is also
needed for iosapic_override_isa_irq(). The fixed one also contains
this fix.

BTW, I'm thinking that delivery mode for CPEI also need to be fixed.
I'll send the another patch about this.

Thanks,
Kenji Kaneshige


Fix the problem that redirect hit bit in I/O SAPIC RTE is set even
when it must be disabled (e.g. nointroute boot option is set, CPU
hotplug is enabled or percpu vector is enabled).

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

Index: linux-2.6.24-rc2/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.24-rc2.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6.24-rc2/arch/ia64/kernel/iosapic.c
@@ -748,6 +748,15 @@ skip_numa_setup:
 #endif
 }
 
+static inline unsigned char choose_dmode(void)
+{
+#ifdef CONFIG_SMP
+	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
+		return IOSAPIC_LOWEST_PRIORITY;
+#endif
+	return IOSAPIC_FIXED;
+}
+
 /*
  * ACPI can describe IOSAPIC interrupts via static tables and namespace
  * methods.  This provides an interface to register those interrupts and
@@ -762,6 +771,7 @@ iosapic_register_intr (unsigned int gsi,
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
 	u32 low32;
+	unsigned char dmode;
 
 	/*
 	 * If this GSI has already been registered (i.e., it's a
@@ -791,8 +801,8 @@ iosapic_register_intr (unsigned int gsi,
 
 	spin_lock(&irq_desc[irq].lock);
 	dest = get_target_cpu(gsi, irq);
-	err = register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY,
-			    polarity, trigger);
+	dmode = choose_dmode();
+	err = register_intr(gsi, irq, dmode, polarity, trigger);
 	if (err < 0) {
 		spin_unlock(&irq_desc[irq].lock);
 		irq = err;
@@ -961,10 +971,12 @@ iosapic_override_isa_irq (unsigned int i
 {
 	int vector, irq;
 	unsigned int dest = cpu_physical_id(smp_processor_id());
+	unsigned char dmode;
 
 	irq = vector = isa_irq_to_vector(isa_irq);
 	BUG_ON(bind_irq_vector(irq, vector, CPU_MASK_ALL));
-	register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
+	dmode = choose_dmode();
+	register_intr(gsi, irq, dmode, polarity, trigger);
 
 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
 	    isa_irq, gsi, trigger = IOSAPIC_EDGE ? "edge" : "level",


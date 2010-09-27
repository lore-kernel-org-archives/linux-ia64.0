From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 27 Sep 2010 21:42:58 +0000
Subject: [RFC PATCH] ia64: Stop using the deprecated __do_IRQ() code path
Message-Id: <4ca10fe21492063f83@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thomas Gleixner <tglx@linutronix.de> wrote:
>__do_IRQ() has been deprecated after a two years migration phase in
>commit 0e57aa1. Since then another 18 months have gone by ...

Mostly trivial stuff for this. The only tricky part was realizing
that the new handler_*_irq() paths do not use desc->chip->end(irq).
Not a problem for the edge case as the ia64 iosapic routine for
that was nop(). But the "level" case handled interrupt migration
there.  Just use a slightly modified version of the "end" routine
as "unmask" for the level triggered case.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Tested on Intel Tukwila box and HP2600 (Madison).  I ran some
light stress migrating interrupts between cpus and nothing blew
up immediately.

Not tested: SGI (though it looks like their code already set up
actions to bypass __do_IRQ) or Xen.

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index ba22849..b0f4ae9 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -683,8 +683,10 @@ source "lib/Kconfig"
 # Use the generic interrupt handling code in kernel/irq/:
 #
 config GENERIC_HARDIRQS
-	bool
-	default y
+	def_bool y
+
+config GENERIC_HARDIRQS_NO__DO_IRQ
+	def_bool y
 
 config GENERIC_IRQ_PROBE
 	bool
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 7ded766..dc6913d 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -394,7 +394,7 @@ iosapic_startup_level_irq (unsigned int irq)
 }
 
 static void
-iosapic_end_level_irq (unsigned int irq)
+iosapic_unmask_level_irq (unsigned int irq)
 {
 	ia64_vector vec = irq_to_vector(irq);
 	struct iosapic_rte_info *rte;
@@ -404,7 +404,8 @@ iosapic_end_level_irq (unsigned int irq)
 	if (unlikely(irq_desc[irq].status & IRQ_MOVE_PENDING)) {
 		do_unmask_irq = 1;
 		mask_irq(irq);
-	}
+	} else
+		unmask_irq(irq);
 
 	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list)
 		iosapic_eoi(rte->iosapic->addr, vec);
@@ -427,9 +428,8 @@ static struct irq_chip irq_type_iosapic_level = {
 	.enable =	iosapic_enable_level_irq,
 	.disable =	iosapic_disable_level_irq,
 	.ack =		iosapic_ack_level_irq,
-	.end =		iosapic_end_level_irq,
 	.mask =		mask_irq,
-	.unmask =	unmask_irq,
+	.unmask =	iosapic_unmask_level_irq,
 	.set_affinity =	iosapic_set_affinity
 };
 
@@ -658,6 +658,10 @@ register_intr (unsigned int gsi, int irq, unsigned char delivery,
 			       idesc->chip->name, irq_type->name);
 		idesc->chip = irq_type;
 	}
+	if (trigger = IOSAPIC_EDGE)
+		__set_irq_handler_unlocked(irq, handle_edge_irq);
+	else
+		__set_irq_handler_unlocked(irq, handle_level_irq);
 	return 0;
 }
 
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index f14c35f..5739786 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -635,6 +635,7 @@ ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
 	desc->chip = &irq_type_ia64_lsapic;
 	if (action)
 		setup_irq(irq, action);
+	set_irq_handler(irq, handle_percpu_irq);
 }
 
 void __init

From: akpm@linux-foundation.org
Date: Wed, 10 Jun 2009 19:45:00 +0000
Subject: [patch 3/4] ia64: remove obsolete hw_interrupt_type
Message-Id: <200906101945.n5AJj1W6032309@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

The defines and typedefs (hw_interrupt_type, no_irq_type, irq_desc_t) have
been kept around for migration reasons.  After more than two years it's
time to remove them finally.

This patch cleans up one of the remaining users.  When all such patches
hit mainline we can remove the defines and typedefs finally.

Impact: cleanup

Convert the last remaining users to struct irq_chip and remove the
define.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/hp/sim/hpsim_irq.c   |    2 +-
 arch/ia64/include/asm/hw_irq.h |    2 +-
 arch/ia64/kernel/iosapic.c     |    2 +-
 arch/ia64/kernel/irq_lsapic.c  |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff -puN arch/ia64/hp/sim/hpsim_irq.c~ia64-remove-obsolete-hw_interrupt_type arch/ia64/hp/sim/hpsim_irq.c
--- a/arch/ia64/hp/sim/hpsim_irq.c~ia64-remove-obsolete-hw_interrupt_type
+++ a/arch/ia64/hp/sim/hpsim_irq.c
@@ -27,7 +27,7 @@ hpsim_set_affinity_noop(unsigned int a, 
 	return 0;
 }
 
-static struct hw_interrupt_type irq_type_hp_sim = {
+static struct irq_chip irq_type_hp_sim = {
 	.name =		"hpsim",
 	.startup =	hpsim_irq_startup,
 	.shutdown =	hpsim_irq_noop,
diff -puN arch/ia64/include/asm/hw_irq.h~ia64-remove-obsolete-hw_interrupt_type arch/ia64/include/asm/hw_irq.h
--- a/arch/ia64/include/asm/hw_irq.h~ia64-remove-obsolete-hw_interrupt_type
+++ a/arch/ia64/include/asm/hw_irq.h
@@ -106,7 +106,7 @@ extern struct irq_cfg irq_cfg[NR_IRQS];
 #define irq_to_domain(x)	irq_cfg[(x)].domain
 DECLARE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq);
 
-extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
+extern struct irq_chip irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
 #ifdef CONFIG_PARAVIRT_GUEST
 #include <asm/paravirt.h>
diff -puN arch/ia64/kernel/iosapic.c~ia64-remove-obsolete-hw_interrupt_type arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c~ia64-remove-obsolete-hw_interrupt_type
+++ a/arch/ia64/kernel/iosapic.c
@@ -601,7 +601,7 @@ register_intr (unsigned int gsi, int irq
 	       unsigned long polarity, unsigned long trigger)
 {
 	struct irq_desc *idesc;
-	struct hw_interrupt_type *irq_type;
+	struct irq_chip *irq_type;
 	int index;
 	struct iosapic_rte_info *rte;
 
diff -puN arch/ia64/kernel/irq_lsapic.c~ia64-remove-obsolete-hw_interrupt_type arch/ia64/kernel/irq_lsapic.c
--- a/arch/ia64/kernel/irq_lsapic.c~ia64-remove-obsolete-hw_interrupt_type
+++ a/arch/ia64/kernel/irq_lsapic.c
@@ -33,7 +33,7 @@ static int lsapic_retrigger(unsigned int
 	return 1;
 }
 
-struct hw_interrupt_type irq_type_ia64_lsapic = {
+struct irq_chip irq_type_ia64_lsapic = {
 	.name =		"LSAPIC",
 	.startup =	lsapic_noop_startup,
 	.shutdown =	lsapic_noop,
_

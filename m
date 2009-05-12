From: akpm@linux-foundation.org
Date: Tue, 12 May 2009 20:40:21 +0000
Subject: [patch 1/3] ia64: remove obsolete no_irq_type
Message-Id: <200905122059.n4CKxba5004954@imap1.linux-foundation.org>
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

convert the last remaining users to no_irq_chip

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/hp/sim/hpsim_irq.c |    2 +-
 arch/ia64/kernel/iosapic.c   |    2 +-
 arch/ia64/sn/kernel/irq.c    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff -puN arch/ia64/hp/sim/hpsim_irq.c~ia64-remove-obsolete-no_irq_type arch/ia64/hp/sim/hpsim_irq.c
--- a/arch/ia64/hp/sim/hpsim_irq.c~ia64-remove-obsolete-no_irq_type
+++ a/arch/ia64/hp/sim/hpsim_irq.c
@@ -46,7 +46,7 @@ hpsim_irq_init (void)
 
 	for (i = 0; i < NR_IRQS; ++i) {
 		idesc = irq_desc + i;
-		if (idesc->chip = &no_irq_type)
+		if (idesc->chip = &no_irq_chip)
 			idesc->chip = &irq_type_hp_sim;
 	}
 }
diff -puN arch/ia64/kernel/iosapic.c~ia64-remove-obsolete-no_irq_type arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c~ia64-remove-obsolete-no_irq_type
+++ a/arch/ia64/kernel/iosapic.c
@@ -650,7 +650,7 @@ register_intr (unsigned int gsi, int irq
 
 	idesc = irq_desc + irq;
 	if (irq_type != NULL && idesc->chip != irq_type) {
-		if (idesc->chip != &no_irq_type)
+		if (idesc->chip != &no_irq_chip)
 			printk(KERN_WARNING
 			       "%s: changing vector %d from %s to %s\n",
 			       __func__, irq_to_vector(irq),
diff -puN arch/ia64/sn/kernel/irq.c~ia64-remove-obsolete-no_irq_type arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c~ia64-remove-obsolete-no_irq_type
+++ a/arch/ia64/sn/kernel/irq.c
@@ -301,7 +301,7 @@ void sn_irq_init(void)
 	ia64_last_device_vector = IA64_SN2_LAST_DEVICE_VECTOR;
 
 	for (i = 0; i < NR_IRQS; i++) {
-		if (base_desc[i].chip = &no_irq_type) {
+		if (base_desc[i].chip = &no_irq_chip) {
 			base_desc[i].chip = &irq_type_sn;
 		}
 	}
_

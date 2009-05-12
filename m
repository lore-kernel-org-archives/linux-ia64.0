From: akpm@linux-foundation.org
Date: Tue, 12 May 2009 20:40:21 +0000
Subject: [patch 2/3] ia64: remove obsolete irq_desc_t typedef
Message-Id: <200905122059.n4CKxbQG004957@imap1.linux-foundation.org>
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

Convert the last remaining users and remove the typedef.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/hp/sim/hpsim_irq.c   |    2 +-
 arch/ia64/include/asm/hw_irq.h |    2 +-
 arch/ia64/kernel/iosapic.c     |    6 +++---
 arch/ia64/kernel/irq.c         |    2 +-
 arch/ia64/kernel/irq_ia64.c    |    2 +-
 arch/ia64/kernel/mca.c         |    2 +-
 arch/ia64/kernel/smpboot.c     |    2 +-
 arch/ia64/sn/kernel/irq.c      |    4 ++--
 arch/ia64/xen/irq_xen.c        |    2 +-
 9 files changed, 12 insertions(+), 12 deletions(-)

diff -puN arch/ia64/hp/sim/hpsim_irq.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/hp/sim/hpsim_irq.c
--- a/arch/ia64/hp/sim/hpsim_irq.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/hp/sim/hpsim_irq.c
@@ -41,7 +41,7 @@ static struct hw_interrupt_type irq_type
 void __init
 hpsim_irq_init (void)
 {
-	irq_desc_t *idesc;
+	struct irq_desc *idesc;
 	int i;
 
 	for (i = 0; i < NR_IRQS; ++i) {
diff -puN arch/ia64/include/asm/hw_irq.h~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/include/asm/hw_irq.h
--- a/arch/ia64/include/asm/hw_irq.h~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/include/asm/hw_irq.h
@@ -146,7 +146,7 @@ static inline void ia64_native_resend_ir
  * Default implementations for the irq-descriptor API:
  */
 
-extern irq_desc_t irq_desc[NR_IRQS];
+extern struct irq_desc irq_desc[NR_IRQS];
 
 #ifndef CONFIG_IA64_GENERIC
 static inline ia64_vector __ia64_irq_to_vector(int irq)
diff -puN arch/ia64/kernel/iosapic.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/kernel/iosapic.c
@@ -451,7 +451,7 @@ iosapic_startup_edge_irq (unsigned int i
 static void
 iosapic_ack_edge_irq (unsigned int irq)
 {
-	irq_desc_t *idesc = irq_desc + irq;
+	struct irq_desc *idesc = irq_desc + irq;
 
 	irq_complete_move(irq);
 	move_native_irq(irq);
@@ -600,7 +600,7 @@ static int
 register_intr (unsigned int gsi, int irq, unsigned char delivery,
 	       unsigned long polarity, unsigned long trigger)
 {
-	irq_desc_t *idesc;
+	struct irq_desc *idesc;
 	struct hw_interrupt_type *irq_type;
 	int index;
 	struct iosapic_rte_info *rte;
@@ -828,7 +828,7 @@ iosapic_unregister_intr (unsigned int gs
 {
 	unsigned long flags;
 	int irq, index;
-	irq_desc_t *idesc;
+	struct irq_desc *idesc;
 	u32 low32;
 	unsigned long trigger, polarity;
 	unsigned int dest;
diff -puN arch/ia64/kernel/irq.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/kernel/irq.c
@@ -130,7 +130,7 @@ unsigned int vectors_in_migration[NR_IRQ
  */
 static void migrate_irqs(void)
 {
-	irq_desc_t *desc;
+	struct irq_desc *desc;
 	int 		irq, new_cpu;
 
 	for (irq=0; irq < NR_IRQS; irq++) {
diff -puN arch/ia64/kernel/irq_ia64.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/kernel/irq_ia64.c
--- a/arch/ia64/kernel/irq_ia64.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/kernel/irq_ia64.c
@@ -630,7 +630,7 @@ static struct irqaction tlb_irqaction = 
 void
 ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
 {
-	irq_desc_t *desc;
+	struct irq_desc *desc;
 	unsigned int irq;
 
 	irq = vec;
diff -puN arch/ia64/kernel/mca.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/kernel/mca.c
@@ -2093,7 +2093,7 @@ ia64_mca_late_init(void)
 	cpe_poll_timer.function = ia64_mca_cpe_poll;
 
 	{
-		irq_desc_t *desc;
+		struct irq_desc *desc;
 		unsigned int irq;
 
 		if (cpe_vector >= 0) {
diff -puN arch/ia64/kernel/smpboot.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/kernel/smpboot.c
@@ -678,7 +678,7 @@ extern void fixup_irqs(void);
 int migrate_platform_irqs(unsigned int cpu)
 {
 	int new_cpei_cpu;
-	irq_desc_t *desc = NULL;
+	struct irq_desc *desc = NULL;
 	const struct cpumask *mask;
 	int 		retval = 0;
 
diff -puN arch/ia64/sn/kernel/irq.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/sn/kernel/irq.c
@@ -295,7 +295,7 @@ unsigned int sn_local_vector_to_irq(u8 v
 void sn_irq_init(void)
 {
 	int i;
-	irq_desc_t *base_desc = irq_desc;
+	struct irq_desc *base_desc = irq_desc;
 
 	ia64_first_device_vector = IA64_SN2_FIRST_DEVICE_VECTOR;
 	ia64_last_device_vector = IA64_SN2_LAST_DEVICE_VECTOR;
@@ -377,7 +377,7 @@ void sn_irq_fixup(struct pci_dev *pci_de
 	int cpu = nasid_slice_to_cpuid(nasid, slice);
 #ifdef CONFIG_SMP
 	int cpuphys;
-	irq_desc_t *desc;
+	struct irq_desc *desc;
 #endif
 
 	pci_dev_get(pci_dev);
diff -puN arch/ia64/xen/irq_xen.c~ia64-remove-obsolete-irq_desc_t-typedef arch/ia64/xen/irq_xen.c
--- a/arch/ia64/xen/irq_xen.c~ia64-remove-obsolete-irq_desc_t-typedef
+++ a/arch/ia64/xen/irq_xen.c
@@ -138,7 +138,7 @@ static void
 __xen_register_percpu_irq(unsigned int cpu, unsigned int vec,
 			struct irqaction *action, int save)
 {
-	irq_desc_t *desc;
+	struct irq_desc *desc;
 	int irq = 0;
 
 	if (xen_slab_ready) {
_

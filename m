From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Oct 2010 22:57:43 +0000
Subject: [PATCH] Initialize interrupts later (from init_IRQ())
Message-Id: <4cabad6743478a028@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thomas Gleixner is cleaning up the generic irq code, and ia64 ran
into problems because it calls register_intr() before early_irq_init()
is called.  Move the call to acpi_boot_init() from setup_arch() to
init_IRQ().

As a bonus - moving the call later means we no longer need the
hacks in iosapic.c to switch between the bootmem and regular
allocator - we can just used kzalloc() for allocation.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Perhaps more to come - Thomas says that more changes are coming
in the next few days - but this gets next-20101005 up and
running.

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 7ded766..66ec078 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -108,10 +108,6 @@
 #define DBG(fmt...)
 #endif
 
-#define NR_PREALLOCATE_RTE_ENTRIES \
-	(PAGE_SIZE / sizeof(struct iosapic_rte_info))
-#define RTE_PREALLOCATED	(1)
-
 static DEFINE_SPINLOCK(iosapic_lock);
 
 /*
@@ -136,7 +132,6 @@ struct iosapic_rte_info {
 	struct list_head rte_list;	/* RTEs sharing the same vector */
 	char		rte_index;	/* IOSAPIC RTE index */
 	int		refcnt;		/* reference counter */
-	unsigned int	flags;		/* flags */
 	struct iosapic	*iosapic;
 } ____cacheline_aligned;
 
@@ -155,9 +150,6 @@ static struct iosapic_intr_info {
 
 static unsigned char pcat_compat __devinitdata;	/* 8259 compatibility flag */
 
-static int iosapic_kmalloc_ok;
-static LIST_HEAD(free_rte_list);
-
 static inline void
 iosapic_write(struct iosapic *iosapic, unsigned int reg, u32 val)
 {
@@ -552,37 +544,6 @@ iosapic_reassign_vector (int irq)
 	}
 }
 
-static struct iosapic_rte_info * __init_refok iosapic_alloc_rte (void)
-{
-	int i;
-	struct iosapic_rte_info *rte;
-	int preallocated = 0;
-
-	if (!iosapic_kmalloc_ok && list_empty(&free_rte_list)) {
-		rte = alloc_bootmem(sizeof(struct iosapic_rte_info) *
-				    NR_PREALLOCATE_RTE_ENTRIES);
-		for (i = 0; i < NR_PREALLOCATE_RTE_ENTRIES; i++, rte++)
-			list_add(&rte->rte_list, &free_rte_list);
-	}
-
-	if (!list_empty(&free_rte_list)) {
-		rte = list_entry(free_rte_list.next, struct iosapic_rte_info,
-				 rte_list);
-		list_del(&rte->rte_list);
-		preallocated++;
-	} else {
-		rte = kmalloc(sizeof(struct iosapic_rte_info), GFP_ATOMIC);
-		if (!rte)
-			return NULL;
-	}
-
-	memset(rte, 0, sizeof(struct iosapic_rte_info));
-	if (preallocated)
-		rte->flags |= RTE_PREALLOCATED;
-
-	return rte;
-}
-
 static inline int irq_is_shared (int irq)
 {
 	return (iosapic_intr_info[irq].count > 1);
@@ -615,7 +576,7 @@ register_intr (unsigned int gsi, int irq, unsigned char delivery,
 
 	rte = find_rte(irq, gsi);
 	if (!rte) {
-		rte = iosapic_alloc_rte();
+		rte = kzalloc(sizeof (*rte), GFP_ATOMIC);
 		if (!rte) {
 			printk(KERN_WARNING "%s: cannot allocate memory\n",
 			       __func__);
@@ -1161,10 +1122,3 @@ map_iosapic_to_node(unsigned int gsi_base, int node)
 	return;
 }
 #endif
-
-static int __init iosapic_enable_kmalloc (void)
-{
-	iosapic_kmalloc_ok = 1;
-	return 0;
-}
-core_initcall (iosapic_enable_kmalloc);
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index f14c35f..07d4f94 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -30,6 +30,7 @@
 #include <linux/bitops.h>
 #include <linux/irq.h>
 #include <linux/ratelimit.h>
+#include <linux/acpi.h>
 
 #include <asm/delay.h>
 #include <asm/intrinsics.h>
@@ -650,6 +651,9 @@ ia64_native_register_ipi(void)
 void __init
 init_IRQ (void)
 {
+#ifdef CONFIG_ACPI
+	acpi_boot_init();
+#endif
 	ia64_register_ipi();
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 8fb958a..911cf97 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -594,10 +594,6 @@ setup_arch (char **cmdline_p)
 	cpu_init();	/* initialize the bootstrap CPU */
 	mmu_context_init();	/* initialize context_id bitmap */
 
-#ifdef CONFIG_ACPI
-	acpi_boot_init();
-#endif
-
 	paravirt_banner();
 	paravirt_arch_setup_console(cmdline_p);
 

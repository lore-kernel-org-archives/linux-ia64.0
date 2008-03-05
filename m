From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:21 +0000
Subject: [PATCH 06/50] xen: move arch/x86/xen/events.c undedr drivers/xen and split out arch specific part.
Message-Id: <12047411452264-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64/xen also uses events.c. clean it up so that ia64/xen can use.
make ipi_to_irq globly visible. ia64/xen nees to reference it from other file.
introduce resend_irq_on_evtchn() which ia64 needs.
introduce xen_do_IRQ() to split out arch specific code.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/x86/xen/Makefile              |    2 +-
 arch/x86/xen/xen-ops.h             |    2 +-
 drivers/xen/Makefile               |    2 +-
 {arch/x86 => drivers}/xen/events.c |   33 ++++++++++++++++++++++++---------
 include/asm-x86/xen/hypervisor.h   |    7 +++++++
 include/xen/events.h               |    1 +
 include/xen/xen-ops.h              |    6 ++++++
 7 files changed, 41 insertions(+), 12 deletions(-)
 rename {arch/x86 => drivers}/xen/events.c (95%)
 create mode 100644 include/xen/xen-ops.h

diff --git a/arch/x86/xen/Makefile b/arch/x86/xen/Makefile
index c5e9aa4..95c5926 100644
--- a/arch/x86/xen/Makefile
+++ b/arch/x86/xen/Makefile
@@ -1,4 +1,4 @@
 obj-y		:= enlighten.o setup.o multicalls.o mmu.o \
-			events.o time.o manage.o xen-asm.o
+			time.o manage.o xen-asm.o
 
 obj-$(CONFIG_SMP)	+= smp.o
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index b02a909..caaabf3 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -2,6 +2,7 @@
 #define XEN_OPS_H
 
 #include <linux/init.h>
+#include <xen/xen-ops.h>
 
 /* These are code, but not functions.  Defined in entry.S */
 extern const char xen_hypervisor_callback[];
@@ -9,7 +10,6 @@ extern const char xen_failsafe_callback[];
 
 void xen_copy_trap_info(struct trap_info *traps);
 
-DECLARE_PER_CPU(struct vcpu_info *, xen_vcpu);
 DECLARE_PER_CPU(unsigned long, xen_cr3);
 DECLARE_PER_CPU(unsigned long, xen_current_cr3);
 
diff --git a/drivers/xen/Makefile b/drivers/xen/Makefile
index 609fdda..823ce78 100644
--- a/drivers/xen/Makefile
+++ b/drivers/xen/Makefile
@@ -1,2 +1,2 @@
-obj-y	+= grant-table.o features.o
+obj-y	+= grant-table.o features.o events.o
 obj-y	+= xenbus/
diff --git a/arch/x86/xen/events.c b/drivers/xen/events.c
similarity index 95%
rename from arch/x86/xen/events.c
rename to drivers/xen/events.c
index dcf613e..dce2dfc 100644
--- a/arch/x86/xen/events.c
+++ b/drivers/xen/events.c
@@ -33,12 +33,11 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/hypervisor.h>
 
+#include <xen/xen-ops.h>
 #include <xen/events.h>
 #include <xen/interface/xen.h>
 #include <xen/interface/event_channel.h>
 
-#include "xen-ops.h"
-
 /*
  * This lock protects updates to the following mapping and reference-count
  * arrays. The lock does not need to be acquired to read the mapping tables.
@@ -49,7 +48,7 @@ static DEFINE_SPINLOCK(irq_mapping_update_lock);
 static DEFINE_PER_CPU(int, virq_to_irq[NR_VIRQS]) = {[0 ... NR_VIRQS-1] = -1};
 
 /* IRQ <-> IPI mapping */
-static DEFINE_PER_CPU(int, ipi_to_irq[XEN_NR_IPIS]) = {[0 ... XEN_NR_IPIS-1] = -1};
+DEFINE_PER_CPU(int, ipi_to_irq[XEN_NR_IPIS]) = {[0 ... XEN_NR_IPIS-1] = -1};
 
 /* Packed IRQ information: binding type, sub-type index, and event channel. */
 struct packed_irq
@@ -455,7 +454,6 @@ void xen_send_IPI_one(unsigned int cpu, enum ipi_vector vector)
 	notify_remote_via_irq(irq);
 }
 
-
 /*
  * Search the CPUs pending events bitmasks.  For each one found, map
  * the event number to an irq, and feed it into do_IRQ() for
@@ -474,7 +472,10 @@ void xen_evtchn_do_upcall(struct pt_regs *regs)
 
 	vcpu_info->evtchn_upcall_pending = 0;
 
-	/* NB. No need for a barrier here -- XCHG is a barrier on x86. */
+#ifndef CONFIG_X86 /* No need for a barrier -- XCHG is a barrier on x86. */
+	/* Clear master flag /before/ clearing selector flag. */
+	rmb();
+#endif
 	pending_words = xchg(&vcpu_info->evtchn_pending_sel, 0);
 	while (pending_words != 0) {
 		unsigned long pending_bits;
@@ -486,10 +487,8 @@ void xen_evtchn_do_upcall(struct pt_regs *regs)
 			int port = (word_idx * BITS_PER_LONG) + bit_idx;
 			int irq = evtchn_to_irq[port];
 
-			if (irq != -1) {
-				regs->orig_ax = ~irq;
-				do_IRQ(regs);
-			}
+			if (irq != -1)
+				xen_do_IRQ(irq, regs);
 		}
 	}
 
@@ -525,6 +524,22 @@ static void set_affinity_irq(unsigned irq, cpumask_t dest)
 	rebind_irq_to_cpu(irq, tcpu);
 }
 
+int resend_irq_on_evtchn(unsigned int irq)
+{
+	int masked, evtchn = evtchn_from_irq(irq);
+	struct shared_info *s = HYPERVISOR_shared_info;
+
+	if (!VALID_EVTCHN(evtchn))
+		return 1;
+
+	masked = sync_test_and_set_bit(evtchn, s->evtchn_mask);
+	sync_set_bit(evtchn, s->evtchn_pending);
+	if (!masked)
+		unmask_evtchn(evtchn);
+
+	return 1;
+}
+
 static void enable_dynirq(unsigned int irq)
 {
 	int evtchn = evtchn_from_irq(irq);
diff --git a/include/asm-x86/xen/hypervisor.h b/include/asm-x86/xen/hypervisor.h
index 8e15dd2..138ee8a 100644
--- a/include/asm-x86/xen/hypervisor.h
+++ b/include/asm-x86/xen/hypervisor.h
@@ -61,6 +61,13 @@ extern struct start_info *xen_start_info;
 /* Force a proper event-channel callback from Xen. */
 extern void force_evtchn_callback(void);
 
+/* macro to avoid header inclusion dependncy hell */
+#define xen_do_IRQ(irq, regs)			\
+	do {					\
+		(regs)->orig_ax = ~(irq);	\
+		do_IRQ(regs);			\
+	} while (0)
+
 /* Turn jiffies into Xen system time. */
 u64 jiffies_to_st(unsigned long jiffies);
 
diff --git a/include/xen/events.h b/include/xen/events.h
index 2bde54d..574cfa4 100644
--- a/include/xen/events.h
+++ b/include/xen/events.h
@@ -37,6 +37,7 @@ int bind_ipi_to_irqhandler(enum ipi_vector ipi,
 void unbind_from_irqhandler(unsigned int irq, void *dev_id);
 
 void xen_send_IPI_one(unsigned int cpu, enum ipi_vector vector);
+int resend_irq_on_evtchn(unsigned int irq);
 
 static inline void notify_remote_via_evtchn(int port)
 {
diff --git a/include/xen/xen-ops.h b/include/xen/xen-ops.h
new file mode 100644
index 0000000..003a7c9
--- /dev/null
+++ b/include/xen/xen-ops.h
@@ -0,0 +1,6 @@
+#ifndef INCLUDE_XEN_OPS_H
+#define INCLUDE_XEN_OPS_H
+
+DECLARE_PER_CPU(struct vcpu_info *, xen_vcpu);
+
+#endif /* INCLUDE_XEN_OPS_H */
-- 
1.5.3


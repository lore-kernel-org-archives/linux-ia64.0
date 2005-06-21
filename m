From: Rusty Lynch <rusty.lynch@intel.com>
Date: Tue, 21 Jun 2005 20:53:48 +0000
Subject: [patch 5/5] Return probe redesign: ppc64 specific implementation
Message-Id: <20050621205407.571189000@linux.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050621205343.548977000@linux.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-ia64@vger.kernel.org, Ananth N Mavinakayanahali <ananth@in.ibm.com>, Rusty Lynch <rusty.lynch@intel.com>

The following is a patch provided by Ananth Mavinakayanahalli that implements
the new PPC64 specific parts of the new function return probe design. 

Changes include:
 * Addition of kretprobe_trampoline to act as a dummy function for instrumented
   functions to return to, and for the return probe infrastructure to place
   a kprobe on on, gaining control so that the return probe handler
   can be called, and so that the instruction pointer can be moved back
   to the original return address.
 * Addition of arch_init(), allowing a kprobe to be registered on
   kretprobe_trampoline
 * Addition of trampoline_probe_handler() which is used as the pre_handler
   for the kprobe inserted on kretprobe_implementation.  This is the function
   that handles the details for calling the return probe handler function
   and returning control back at the original return address
 * Addition of arch_prepare_kretprobe() which is setup as the pre_handler
   for a kprobe registered at the beginning of the target function by
   kernel/kprobes.c so that a return probe instance can be setup when
   a caller enters the target function.  (A return probe instance contains
   all the needed information for trampoline_probe_handler to do it's job.)
 * Hooks added to the exit path of a task so that we can cleanup any left-over
   return probe instances (i.e. if a task dies while inside a targeted function
   then the return probe instance was reserved at the beginning of the function
   but the function never returns so we need to mark the instance as unused.)

    --rusty

signed-off-by: Ananth N Mavinakayanahali <ananth@in.ibm.com>
signed-off-by: Rusty Lynch <rusty.lynch@intel.com>

 arch/ppc64/kernel/kprobes.c |   99 ++++++++++++++++++++++++++++++++++++++++++++
 arch/ppc64/kernel/process.c |    4 +
 include/asm-ppc64/kprobes.h |    3 +
 3 files changed, 106 insertions(+)

Index: linux-2.6.12-mm1/arch/ppc64/kernel/kprobes.c
=================================--- linux-2.6.12-mm1.orig/arch/ppc64/kernel/kprobes.c
+++ linux-2.6.12-mm1/arch/ppc64/kernel/kprobes.c
@@ -105,6 +105,23 @@ static inline void restore_previous_kpro
 	kprobe_saved_msr = kprobe_saved_msr_prev;
 }
 
+void arch_prepare_kretprobe(struct kretprobe *rp, struct pt_regs *regs)
+{
+	struct kretprobe_instance *ri;
+
+	if ((ri = get_free_rp_inst(rp)) != NULL) {
+		ri->rp = rp;
+		ri->task = current;
+		ri->ret_addr = (kprobe_opcode_t *)regs->link;
+
+		/* Replace the return addr with trampoline addr */
+		regs->link = (unsigned long)kretprobe_trampoline;
+		add_rp_inst(ri);
+	} else {
+		rp->nmissed++;
+	}
+}
+
 static inline int kprobe_handler(struct pt_regs *regs)
 {
 	struct kprobe *p;
@@ -195,6 +212,78 @@ no_kprobe:
 }
 
 /*
+ * Function return probe trampoline:
+ * 	- init_kprobes() establishes a probepoint here
+ * 	- When the probed function returns, this probe
+ * 		causes the handlers to fire
+ */
+void kretprobe_trampoline_holder(void)
+{
+	asm volatile(".global kretprobe_trampoline\n"
+			"kretprobe_trampoline:\n"
+			"nop\n");
+}
+
+/*
+ * Called when the probe at kretprobe trampoline is hit
+ */
+int trampoline_probe_handler(struct kprobe *p, struct pt_regs *regs)
+{
+        struct kretprobe_instance *ri = NULL;
+        struct hlist_head *head;
+        struct hlist_node *node, *tmp;
+	unsigned long orig_ret_address = 0;
+	unsigned long trampoline_address =(unsigned long)&kretprobe_trampoline;
+
+        head = kretprobe_inst_table_head(current);
+
+	/*
+	 * It is possible to have multiple instances associated with a given
+	 * task either because an multiple functions in the call path
+	 * have a return probe installed on them, and/or more then one return
+	 * return probe was registered for a target function.
+	 *
+	 * We can handle this because:
+	 *     - instances are always inserted at the head of the list
+	 *     - when multiple return probes are registered for the same
+         *       function, the first instance's ret_addr will point to the
+	 *       real return address, and all the rest will point to
+	 *       kretprobe_trampoline
+	 */
+	hlist_for_each_entry_safe(ri, node, tmp, head, hlist) {
+                if (ri->task != current)
+			/* another task is sharing our hash bucket */
+                        continue;
+
+		if (ri->rp && ri->rp->handler)
+			ri->rp->handler(ri, regs);
+
+		orig_ret_address = (unsigned long)ri->ret_addr;
+		recycle_rp_inst(ri);
+
+		if (orig_ret_address != trampoline_address)
+			/*
+			 * This is the real return address. Any other
+			 * instances associated with this task are for
+			 * other calls deeper on the call stack
+			 */
+			break;
+	}
+
+	BUG_ON(!orig_ret_address || (orig_ret_address = trampoline_address));
+	regs->nip = orig_ret_address;
+
+	unlock_kprobes();
+
+        /*
+         * By returning a non-zero value, we are telling
+         * kprobe_handler() that we have handled unlocking
+         * and re-enabling preemption.
+         */
+        return 1;
+}
+
+/*
  * Called after single-stepping.  p->addr is the address of the
  * instruction whose first byte has been replaced by the "breakpoint"
  * instruction.  To avoid the SMP problems that can occur when we
@@ -331,3 +420,13 @@ int longjmp_break_handler(struct kprobe 
 	memcpy(regs, &jprobe_saved_regs, sizeof(struct pt_regs));
 	return 1;
 }
+
+static struct kprobe trampoline_p = {
+	.addr = (kprobe_opcode_t *) &kretprobe_trampoline,
+	.pre_handler = trampoline_probe_handler
+};
+
+int __init arch_init(void)
+{
+	return register_kprobe(&trampoline_p);
+}
Index: linux-2.6.12-mm1/arch/ppc64/kernel/process.c
=================================--- linux-2.6.12-mm1.orig/arch/ppc64/kernel/process.c
+++ linux-2.6.12-mm1/arch/ppc64/kernel/process.c
@@ -37,6 +37,7 @@
 #include <linux/interrupt.h>
 #include <linux/utsname.h>
 #include <linux/perfctr.h>
+#include <linux/kprobes.h>
 
 #include <asm/pgtable.h>
 #include <asm/uaccess.h>
@@ -310,6 +311,8 @@ void show_regs(struct pt_regs * regs)
 
 void exit_thread(void)
 {
+	kprobe_flush_task(current);
+
 #ifndef CONFIG_SMP
 	if (last_task_used_math = current)
 		last_task_used_math = NULL;
@@ -325,6 +328,7 @@ void flush_thread(void)
 {
 	struct thread_info *t = current_thread_info();
 
+	kprobe_flush_task(current);
 	if (t->flags & _TIF_ABI_PENDING)
 		t->flags ^= (_TIF_ABI_PENDING | _TIF_32BIT);
 
Index: linux-2.6.12-mm1/include/asm-ppc64/kprobes.h
=================================--- linux-2.6.12-mm1.orig/include/asm-ppc64/kprobes.h
+++ linux-2.6.12-mm1/include/asm-ppc64/kprobes.h
@@ -42,6 +42,9 @@ typedef unsigned int kprobe_opcode_t;
 
 #define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)((func_descr_t *)pentry)
 
+#define ARCH_SUPPORTS_KRETPROBES
+void kretprobe_trampoline(void);
+
 /* Architecture specific copy of original instruction */
 struct arch_specific_insn {
 	/* copy of original instruction */

--

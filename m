From: Christoph Hellwig <hch@lst.de>
Date: Sat, 12 May 2007 15:57:24 +0000
Subject: [PATCH] ia64: optimize pagefaults a little
Message-Id: <20070512155724.GB8412@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Get rid of the notifier list and call the kprobes code directly
if compiled in.  This mirrors the changes that recently went
into powerpc, s390 and sparc64.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/arch/ia64/kernel/kprobes.c
=================================--- linux-2.6.orig/arch/ia64/kernel/kprobes.c	2007-05-12 15:37:36.000000000 +0200
+++ linux-2.6/arch/ia64/kernel/kprobes.c	2007-05-12 15:38:09.000000000 +0200
@@ -820,7 +820,7 @@ out:
 	return 1;
 }
 
-static int __kprobes kprobes_fault_handler(struct pt_regs *regs, int trapnr)
+int __kprobes kprobes_fault_handler(struct pt_regs *regs, int trapnr)
 {
 	struct kprobe *cur = kprobe_running();
 	struct kprobe_ctlblk *kcb = get_kprobe_ctlblk();
Index: linux-2.6/arch/ia64/mm/fault.c
=================================--- linux-2.6.orig/arch/ia64/mm/fault.c	2007-05-12 15:38:29.000000000 +0200
+++ linux-2.6/arch/ia64/mm/fault.c	2007-05-12 15:49:11.000000000 +0200
@@ -19,36 +19,24 @@
 extern void die (char *, struct pt_regs *, long);
 
 #ifdef CONFIG_KPROBES
-ATOMIC_NOTIFIER_HEAD(notify_page_fault_chain);
-
-/* Hook to register for page fault notifications */
-int register_page_fault_notifier(struct notifier_block *nb)
+static inline int notify_page_fault(struct pt_regs *regs, int trap)
 {
-	return atomic_notifier_chain_register(&notify_page_fault_chain, nb);
-}
+	int ret = 0;
 
-int unregister_page_fault_notifier(struct notifier_block *nb)
-{
-	return atomic_notifier_chain_unregister(&notify_page_fault_chain, nb);
-}
+	if (!user_mode(regs)) {
+		/* kprobe_running() needs smp_processor_id() */
+		preempt_disable();
+		if (kprobe_running() && kprobes_fault_handler(regs, trap))
+			ret = 1
+		preempt_enable();
+	}
 
-static inline int notify_page_fault(enum die_val val, const char *str,
-			struct pt_regs *regs, long err, int trap, int sig)
-{
-	struct die_args args = {
-		.regs = regs,
-		.str = str,
-		.err = err,
-		.trapnr = trap,
-		.signr = sig
-	};
-	return atomic_notifier_call_chain(&notify_page_fault_chain, val, &args);
+	return ret;
 }
 #else
-static inline int notify_page_fault(enum die_val val, const char *str,
-			struct pt_regs *regs, long err, int trap, int sig)
+static inline int notify_page_fault(struct pt_regs *regs, int trap)
 {
-	return NOTIFY_DONE;
+	return 0;
 }
 #endif
 
@@ -117,8 +105,7 @@ ia64_do_page_fault (unsigned long addres
 	/*
 	 * This is to handle the kprobes on user space access instructions
 	 */
-	if (notify_page_fault(DIE_PAGE_FAULT, "page fault", regs, code, TRAP_BRKPT,
-					SIGSEGV) = NOTIFY_STOP)
+	if (notify_page_fault(regs, TRAP_BRKPT))
 		return;
 
 	down_read(&mm->mmap_sem);
Index: linux-2.6/include/asm-ia64/kprobes.h
=================================--- linux-2.6.orig/include/asm-ia64/kprobes.h	2007-05-12 15:37:36.000000000 +0200
+++ linux-2.6/include/asm-ia64/kprobes.h	2007-05-12 15:38:19.000000000 +0200
@@ -120,6 +120,7 @@ struct arch_specific_insn {
 	unsigned short slot;
 };
 
+extern int kprobes_fault_handler(struct pt_regs *regs, int trapnr);
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
 
Index: linux-2.6/include/asm-ia64/kdebug.h
=================================--- linux-2.6.orig/include/asm-ia64/kdebug.h	2007-05-12 15:41:24.000000000 +0200
+++ linux-2.6/include/asm-ia64/kdebug.h	2007-05-12 15:44:14.000000000 +0200
@@ -28,14 +28,24 @@
  */
 #include <linux/notifier.h>
 
-extern int register_page_fault_notifier(struct notifier_block *);
-extern int unregister_page_fault_notifier(struct notifier_block *);
+/*
+ * These are only here because kprobes.c wants them to implement a
+ * blatant layering violation.  Will hopefully go away soon once all
+ * architectures are updated.
+ */
+static inline int register_page_fault_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+static inline int unregister_page_fault_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
 
 enum die_val {
 	DIE_BREAK = 1,
 	DIE_FAULT,
 	DIE_OOPS,
-	DIE_PAGE_FAULT,
 	DIE_MACHINE_HALT,
 	DIE_MACHINE_RESTART,
 	DIE_MCA_MONARCH_ENTER,

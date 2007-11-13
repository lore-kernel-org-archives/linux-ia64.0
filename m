From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 13 Nov 2007 06:55:20 +0000
Subject: [PATCH] kprobe: make kreturn probe handler stack unwind correct
Message-Id: <1194936920.27851.5.camel@sli10-conroe.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Restore regs->ccr_iip before kreturn probe handler runs. In this way, if
probe handler does unwind, unwind can correctly get the stack trace.

http://sourceware.org/bugzilla/show_bug.cgi?idP51

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Index: linux/arch/ia64/kernel/kprobes.c
=================================--- linux.orig/arch/ia64/kernel/kprobes.c	2007-10-17 10:33:45.000000000 +0800
+++ linux/arch/ia64/kernel/kprobes.c	2007-11-13 14:39:50.000000000 +0800
@@ -435,6 +435,23 @@ int __kprobes trampoline_probe_handler(s
 			/* another task is sharing our hash bucket */
 			continue;
 
+		orig_ret_address = (unsigned long)ri->ret_addr;
+		if (orig_ret_address != trampoline_address)
+			/*
+			 * This is the real return address. Any other
+			 * instances associated with this task are for
+			 * other calls deeper on the call stack
+			 */
+			break;
+	}
+
+	regs->cr_iip = orig_ret_address;
+
+	hlist_for_each_entry_safe(ri, node, tmp, head, hlist) {
+		if (ri->task != current)
+			/* another task is sharing our hash bucket */
+			continue;
+
 		if (ri->rp && ri->rp->handler)
 			ri->rp->handler(ri, regs);
 
@@ -452,8 +469,6 @@ int __kprobes trampoline_probe_handler(s
 
 	kretprobe_assert(ri, orig_ret_address, trampoline_address);
 
-	regs->cr_iip = orig_ret_address;
-
 	reset_current_kprobe();
 	spin_unlock_irqrestore(&kretprobe_lock, flags);
 	preempt_enable_no_resched();

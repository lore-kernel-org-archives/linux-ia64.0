From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Thu, 14 Sep 2006 21:34:34 +0000
Subject: [PATCH] Kprobes - fixup the pagefault exception caused by probehandlers
Message-Id: <20060914143433.B30207@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux IA64 <linux-ia64@vger.kernel.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Systemtap <systemtap@sources.redhat.com>

If the user-specified kprobe handler causes the page fault
when accessing user space address, fixup this fault since
do_page_fault() should not continue as the kprobe handler are
run with preemption disabled.

Please apply.


Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
---
 arch/ia64/kernel/kprobes.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: 2.6.18-rc6-git2/arch/ia64/kernel/kprobes.c
=================================--- 2.6.18-rc6-git2.orig/arch/ia64/kernel/kprobes.c
+++ 2.6.18-rc6-git2/arch/ia64/kernel/kprobes.c
@@ -768,6 +768,12 @@ static int __kprobes kprobes_fault_handl
 		 */
 		if (cur->fault_handler && cur->fault_handler(cur, regs, trapnr))
 			return 1;
+		/*
+		 * In case the user-specified fault handler returned
+		 * zero, try to fix up.
+		 */
+		if (ia64_done_with_exception(regs))
+			return 1;
 
 		/*
 		 * In case the user-specified fault handler returned

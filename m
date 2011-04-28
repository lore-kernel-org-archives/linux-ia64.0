From: "Jan Beulich" <JBeulich@novell.com>
Date: Thu, 28 Apr 2011 08:21:44 +0000
Subject: [PATCH] ia64: don't print modules from show_regs()
Message-Id: <4DB93FB8020000780003E97B@vpn.id2.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The function is being used in contexts where listing the modules is
inappropriate and possibly wasteful (one example is
sysrq_handle_showallcpus()), and the name also doesn't imply such
behavior.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 arch/ia64/kernel/process.c |    1 -
 arch/ia64/kernel/traps.c   |    5 +++--
 2 files changed, 3 insertions(+), 3 deletions(-)

--- 2.6.39-rc5/arch/ia64/kernel/process.c
+++ 2.6.39-rc5-ia64-show_regs-no-print_modules/arch/ia64/kernel/process.c
@@ -108,7 +108,6 @@ show_regs (struct pt_regs *regs)
 {
 	unsigned long ip = regs->cr_iip + ia64_psr(regs)->ri;
 
-	print_modules();
 	printk("\nPid: %d, CPU %d, comm: %20s\n", task_pid_nr(current),
 			smp_processor_id(), current->comm);
 	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]    %s (%s)\n",
--- 2.6.39-rc5/arch/ia64/kernel/traps.c
+++ 2.6.39-rc5-ia64-show_regs-no-print_modules/arch/ia64/kernel/traps.c
@@ -62,9 +62,10 @@ die (const char *str, struct pt_regs *re
 		printk("%s[%d]: %s %ld [%d]\n",
 		current->comm, task_pid_nr(current), str, err, ++die_counter);
 		if (notify_die(DIE_OOPS, str, regs, err, 255, SIGSEGV)
-	            != NOTIFY_STOP)
+	            != NOTIFY_STOP) {
+			print_modules();
 			show_regs(regs);
-		else
+		} else
 			regs = NULL;
   	} else
 		printk(KERN_ERR "Recursive die() failure, output suppressed\n");




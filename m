From: John Hawkes <hawkes@babylon.engr.sgi.com>
Date: Thu, 03 Jul 2003 20:36:15 +0000
Subject: [PATCH] improve scalability of 2.4.21 fpassist
Message-Id: <marc-linux-ia64-105726499515305@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This change has already made its way into linux-2.5.72-ia64-031619.diff.
Here is the diff relative to 2.4.21 + linux-2.4.21-ia64-030702.diff.

This patch *significantly* improves the scalability of handle_fpu_swa()
when multiple CPUs are generating concurrent fp-assist traps.
The original algorithm produces cacheline ping-ponging for the cacheline
that contains fpu_swa_count.  This new algorithm only dirties
fpu_sw_count when the printk() is about to occur, rather than on every
fpassist trap, which throttles the ping-ponging to no more than five per
second.

John Hawkes



diff -X /home/hawkes/Patches/ignore.dirs -Naur linux-2.4.21-ia64/arch/ia64/kernel/traps.c linux-2.4.21-ia64-fp/arch/ia64/kernel/traps.c
--- linux-2.4.21-ia64/arch/ia64/kernel/traps.c	Thu Jul  3 13:10:46 2003
+++ linux-2.4.21-ia64-fp/arch/ia64/kernel/traps.c	Thu Jul  3 13:15:42 2003
@@ -335,8 +335,9 @@
 
 	if (jiffies - last_time > 5*HZ)
 		fpu_swa_count = 0;
-	if ((++fpu_swa_count < 5) && !(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT)) {
+	if ((fpu_swa_count < 4) && !(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT)) {
 		last_time = jiffies;
+		++fpu_swa_count;
 		printk(KERN_WARNING "%s(%d): floating-point assist fault at ip %016lx, isr %016lx\n",
 		       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri, isr);
 	}

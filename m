From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 16 Oct 2001 02:46:45 +0000
Subject: [Linux-ia64] [patch] ia64-011010 die() deadlock
Message-Id: <marc-linux-ia64-105590698805346@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Any die() routine that uses die_lock to avoid multiple cpu reentrancy
will deadlock on recursive die() errors.  This patch fixes ia64-011010.
Andrew Morton, who did the original die_lock code, agrees that this is
required.

The code makes best effort at diagnosing the first recursive error then
gives up.  This patch removes the only reference to IA64_KERNEL_DEATH
so I deleted the flag as well.

Index: 11.7/arch/ia64/kernel/traps.c
--- 11.7/arch/ia64/kernel/traps.c Thu, 11 Oct 2001 14:03:29 +1000 kaos (linux-2.4/r/c/43_traps.c 1.1.4.1.3.4 644)
+++ 11.7(w)/arch/ia64/kernel/traps.c Tue, 16 Oct 2001 12:33:57 +1000 kaos (linux-2.4/r/c/43_traps.c 1.1.4.1.3.4 644)
@@ -88,21 +89,26 @@ void
 die (const char *str, struct pt_regs *regs, long err)
 {
 	static spinlock_t die_lock = SPIN_LOCK_UNLOCKED;
+	static int die_lock_owner = -1, die_lock_owner_depth = 0;
 
-	console_verbose();
-	spin_lock_irq(&die_lock);
-	bust_spinlocks(1);
-	printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
-	show_regs(regs);
-	bust_spinlocks(0);
-	spin_unlock_irq(&die_lock);
+	if (die_lock_owner != smp_processor_id()) {
+		console_verbose();
+		spin_lock_irq(&die_lock);
+		die_lock_owner = smp_processor_id();
+		die_lock_owner_depth = 0;
+		bust_spinlocks(1);
+	}
 
-	if (current->thread.flags & IA64_KERNEL_DEATH) {
-		printk("die_if_kernel recursion detected.\n");
-		sti();
-		while (1);
+	if (++die_lock_owner_depth < 3) {
+		printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
+		show_regs(regs);
 	}
-	current->thread.flags |= IA64_KERNEL_DEATH;
+	else
+		printk(KERN_ERR "Recursive die() failure, output suppressed\n");
+
+	bust_spinlocks(0);
+	die_lock_owner = -1;
+	spin_unlock_irq(&die_lock);
 	do_exit(SIGSEGV);
 }
 
Index: 11.7/include/asm-ia64/processor.h
--- 11.7/include/asm-ia64/processor.h Thu, 11 Oct 2001 14:03:29 +1000 kaos (linux-2.4/s/49_processor. 1.1.3.2.2.1.1.4 644)
+++ 11.7(w)/include/asm-ia64/processor.h Tue, 16 Oct 2001 12:28:13 +1000 kaos (linux-2.4/s/49_processor. 1.1.3.2.2.1.1.4 644)
@@ -170,7 +170,6 @@
 #define IA64_THREAD_KRBS_SYNCED	(__IA64_UL(1) << 5)	/* krbs synced with process vm? */
 #define IA64_THREAD_FPEMU_NOPRINT (__IA64_UL(1) << 6)	/* don't log any fpswa faults */
 #define IA64_THREAD_FPEMU_SIGFPE  (__IA64_UL(1) << 7)	/* send a SIGFPE for fpswa faults */
-#define IA64_KERNEL_DEATH	(__IA64_UL(1) << 63)	/* see die_if_kernel()... */
 
 #define IA64_THREAD_UAC_SHIFT	3
 #define IA64_THREAD_UAC_MASK	(IA64_THREAD_UAC_NOPRINT | IA64_THREAD_UAC_SIGBUS)




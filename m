From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 19 May 2004 01:10:00 +0000
Subject: Kill warnings in 2.6.6
Message-Id: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Here're four patches to get rid of warnings in Linux 2.6.6, IA64.

The first is a copy of a fix four lines up; the second declares some
structures (that aren't used anyway), the third hides a function
that's used only for SMP, and the fourth makes cond_syscall use a real
prototype.  It's safe to make the conditional system call have the
same signature as the thing it's aliased to.

=== arch/ia64/ia32/ia32_signal.c 1.27 vs edited ==--- 1.27/arch/ia64/ia32/ia32_signal.c	Fri Apr 23 16:38:17 2004
+++ edited/arch/ia64/ia32/ia32_signal.c	Tue May 18 13:18:25 2004
@@ -173,7 +173,8 @@
 		case __SI_MESGQ >> 16:
 			err |= __put_user(from->si_uid, &to->si_uid);
 			err |= __put_user(from->si_pid, &to->si_pid);
-			err |= __put_user(from->si_ptr, &to->si_ptr);
+			addr = (unsigned long)from->si_ptr;
+			err |= __put_user(addr, &to->si_ptr);
 			break;
 		}
 	}


=== arch/ia64/kernel/machvec.c 1.7 vs edited ==--- 1.7/arch/ia64/kernel/machvec.c	Thu Mar 18 16:57:15 2004
+++ edited/arch/ia64/kernel/machvec.c	Tue May 18 13:00:35 2004
@@ -61,6 +61,9 @@
 }
 EXPORT_SYMBOL(machvec_timer_interrupt);
 
+struct device;
+struct scatterlist;
+
 void
 machvec_dma_sync_single (struct device *hwdev, dma_addr_t dma_handle, size_t size, int dir)
 {


=== arch/ia64/kernel/perfmon.c 1.73 vs edited ==--- 1.73/arch/ia64/kernel/perfmon.c	Fri Apr  9 02:28:59 2004
+++ edited/arch/ia64/kernel/perfmon.c	Tue May 18 13:01:03 2004
@@ -4559,6 +4559,7 @@
 	return 0;
 }
 
+#ifdef CONFIG_SMP
 static void
 pfm_force_cleanup(pfm_context_t *ctx, struct pt_regs *regs)
 {
@@ -4582,7 +4583,7 @@
 
 	DPRINT(("force cleanupf for [%d]\n",  task->pid));
 }
-
+#endif
 
 
 /*


=== include/asm-ia64/unistd.h 1.40 vs edited ==--- 1.40/include/asm-ia64/unistd.h	Thu Apr 15 18:26:53 2004
+++ edited/include/asm-ia64/unistd.h	Tue May 18 12:52:06 2004
@@ -367,12 +367,12 @@
 /*
  * "Conditional" syscalls
  *
- * Note, this macro can only be used in the file which defines sys_ni_syscall, i.e., in
- * kernel/sys.c.  This version causes warnings because the declaration isn't a
- * proper prototype, but we can't use __typeof__ either, because not all cond_syscall()
- * declarations have prototypes at the moment.
+ * Note, this macro can only be used in the file which defines
+ * sys_ni_syscall, i.e., in kernel/sys.c.  It is used to provide
+ * addresses for system call functions for entry.S, where the
+ * functions could be configured out.
  */
-#define cond_syscall(x) asmlinkage long x() __attribute__((weak,alias("sys_ni_syscall")));
+#define cond_syscall(x) asmlinkage long x(void) __attribute__((weak,alias("sys_ni_syscall")));
 
 #endif /* !__ASSEMBLY__ */
 #endif /* __KERNEL__ */

From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 08 Oct 2001 21:57:00 +0000
Subject: [Linux-ia64] prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805301@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think you mentioned awhile ago that a patch like this might be
welcome.  Well, here it is.  It's diff'd against 2.4.10 with the ia64
patch.  Please let me know if you find problems with it.

Thanks,
Jesse

diff -Naur linux-2.4.10-ia64/arch/ia64/kernel/traps.c linux-2.4.10-ia64-fpswa/arch/ia64/kernel/traps.c
--- linux-2.4.10-ia64/arch/ia64/kernel/traps.c	Mon Oct  8 14:45:25 2001
+++ linux-2.4.10-ia64-fpswa/arch/ia64/kernel/traps.c	Mon Oct  8 14:49:47 2001
@@ -300,8 +300,6 @@
 	long exception, bundle[2];
 	unsigned long fault_ip;
 	struct siginfo siginfo;
-	static int fpu_swa_count = 0;
-	static unsigned long last_time;
 
 	fault_ip = regs->cr_iip;
 	if (!fp_fault && (ia64_psr(regs)->ri = 0))
@@ -309,10 +307,7 @@
 	if (copy_from_user(bundle, (void *) fault_ip, sizeof(bundle)))
 		return -1;
 
-	if (jiffies - last_time > 5*HZ)
-		fpu_swa_count = 0;
-	if (++fpu_swa_count < 5) {
-		last_time = jiffies;
+	if (!(current->thread.flags & IA64_THREAD_FPSWA_NOPRINT)) {
 		printk(KERN_WARNING "%s(%d): floating-point assist fault at ip %016lx\n",
 		       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri);
 	}
@@ -512,7 +507,7 @@
 	      case 32: /* fp fault */
 	      case 33: /* fp trap */
 		result = handle_fpu_swa((vector = 32) ? 1 : 0, regs, isr);
-		if (result < 0) {
+		if (result < 0 || (current->thread.flags & IA64_THREAD_FPSWA_SIGFPE)) {
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = FPE_FLTINV;
diff -Naur linux-2.4.10-ia64/include/asm-ia64/processor.h linux-2.4.10-ia64-fpswa/include/asm-ia64/processor.h
--- linux-2.4.10-ia64/include/asm-ia64/processor.h	Mon Oct  8 14:45:26 2001
+++ linux-2.4.10-ia64-fpswa/include/asm-ia64/processor.h	Mon Oct  8 14:46:33 2001
@@ -168,8 +168,12 @@
 #define IA64_THREAD_UAC_NOPRINT	(__IA64_UL(1) << 3)	/* don't log unaligned accesses */
 #define IA64_THREAD_UAC_SIGBUS	(__IA64_UL(1) << 4)	/* generate SIGBUS on unaligned acc. */
 #define IA64_THREAD_KRBS_SYNCED	(__IA64_UL(1) << 5)	/* krbs synced with process vm? */
+#define IA64_THREAD_FPSWA_NOPRINT (__IA64_UL(1) << 6)   /* don't log fpswa faults */
+#define IA64_THREAD_FPSWA_SIGFPE  (__IA64_UL(1) << 7)   /* send a SIGFPE for fpswa faults */
 #define IA64_KERNEL_DEATH	(__IA64_UL(1) << 63)	/* see die_if_kernel()... */
 
+#define IA64_THREAD_FPSWA_SHIFT 6
+#define IA64_THREAD_FPSWA_MASK  (IA64_THREAD_FPSWA_NOPRINT | IA64_THREAD_FPSWA_SIGFPE)
 #define IA64_THREAD_UAC_SHIFT	3
 #define IA64_THREAD_UAC_MASK	(IA64_THREAD_UAC_NOPRINT | IA64_THREAD_UAC_SIGBUS)
 
@@ -322,6 +326,18 @@
 #define GET_UNALIGN_CTL(task,addr)								\
 ({												\
 	put_user(((task)->thread.flags & IA64_THREAD_UAC_MASK) >> IA64_THREAD_UAC_SHIFT,	\
+		 (int *) (addr));								\
+})
+
+#define SET_FPSWA_CTL(task,value)								\
+({												\
+	(task)->thread.flags = (((task)->thread.flags & ~IA64_THREAD_FPSWA_MASK)		\
+				| (((value) << IA64_THREAD_FPSWA_SHIFT) & IA64_THREAD_FPSWA_MASK));	\
+	0;											\
+})
+#define GET_FPSWA_CTL(task,addr)								\
+({												\
+	put_user(((task)->thread.flags & IA64_THREAD_FPSWA_MASK) >> IA64_THREAD_FPSWA_SHIFT,	\
 		 (int *) (addr));								\
 })
 
diff -Naur linux-2.4.10-ia64/include/linux/prctl.h linux-2.4.10-ia64-fpswa/include/linux/prctl.h
--- linux-2.4.10-ia64/include/linux/prctl.h	Thu Jul 19 20:39:57 2001
+++ linux-2.4.10-ia64-fpswa/include/linux/prctl.h	Mon Oct  8 14:47:32 2001
@@ -20,4 +20,8 @@
 #define PR_GET_KEEPCAPS   7
 #define PR_SET_KEEPCAPS   8
 
+/* controls the printing of fpswa fault warnings */
+#define PR_GET_FPSWA  9
+#define PR_SET_FPSWA 10
+
 #endif /* _LINUX_PRCTL_H */
diff -Naur linux-2.4.10-ia64/kernel/sys.c linux-2.4.10-ia64-fpswa/kernel/sys.c
--- linux-2.4.10-ia64/kernel/sys.c	Tue Sep 18 14:10:43 2001
+++ linux-2.4.10-ia64-fpswa/kernel/sys.c	Mon Oct  8 14:46:33 2001
@@ -1245,6 +1245,22 @@
 #endif
 			break;
 
+	        case PR_SET_FPSWA:
+#ifdef SET_FPSWA_CTL
+			error = SET_FPSWA_CTL(current, arg2);
+#else
+			error = -EINVAL;
+#endif
+			break;
+
+	        case PR_GET_FPSWA:
+#ifdef GET_FPSWA_CTL
+			error = GET_FPSWA_CTL(current, arg2);
+#else
+			error = -EINVAL;
+#endif
+			break;
+
 		case PR_GET_KEEPCAPS:
 			if (current->keep_capabilities)
 				error = 1;



From: Brian Sumner <bls@sgi.com>
Date: Thu, 06 Dec 2001 21:44:19 +0000
Subject: [Linux-ia64] fpswa patch(es)
Message-Id: <marc-linux-ia64-105590698805632@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patch is really 3 patches rolled into one.
I've found all 3 useful during application porting and debugging.

1. /proc/fpemu

A proc file that tools can monitor to identify when
applications are running that are requiring lots of
assists.  Configured with CONFIG_PROC_FPEMU

% cat /proc/fpemu
CPU0f4859
CPU135141
Total00000

2.  Log total number of assists to messages

Configured with CONFIG_PRINT_FPEMU, causes messages like

Dec  6 10:04:41 nospam kernel: assist(1151): 1000000 floating-point assist faults

when a process exits having taken a nonzero number of assist faults

3.  signal for successful assist

Allows the process to request a specified signal to be sent
when an assist succeeds.  Currently the process receives
SIGFPE when the assist fails (and nothing when it succeeds).

The application requests this with, e.g.

    prctl(PR_FPEMU_SIGNAL, SIGUSR1);

Configured with CONFIG_SIGNAL_FPEMU.

The following applies cleanly to 2.4.16 + 011128 diff.

Thanks,
Brian Sumner

---------- patch follows ----------------------------------------------------------
diff -urN linux-2.4.16/arch/ia64/config.in linux-2.4.16-fpemu/arch/ia64/config.in
--- linux-2.4.16/arch/ia64/config.in    Tue Nov 27 12:10:18 2001
+++ linux-2.4.16-fpemu/arch/ia64/config.in      Wed Nov 28 06:11:03 2001
@@ -96,6 +96,9 @@
 bool 'SMP support' CONFIG_SMP
 tristate 'Support running of Linux/x86 binaries' CONFIG_IA32_SUPPORT
 bool 'Performance monitor support' CONFIG_PERFMON
+bool '/proc/fpemu support' CONFIG_PROC_FPEMU
+bool 'Log FPEMU activity per process' CONFIG_PRINT_FPEMU
+bool 'Generate signal for successful FPEMU invocation' CONFIG_SIGNAL_FPEMU
 tristate '/proc/pal support' CONFIG_IA64_PALINFO
 tristate '/proc/efi/vars support' CONFIG_EFI_VARS
 
diff -urN linux-2.4.16/arch/ia64/kernel/process.c linux-2.4.16-fpemu/arch/ia64/kernel/process.c
--- linux-2.4.16/arch/ia64/kernel/process.c     Tue Nov 27 12:10:18 2001
+++ linux-2.4.16-fpemu/arch/ia64/kernel/process.c       Wed Nov 28 06:11:03 2001
@@ -517,6 +517,11 @@
                current->thread.flags &= ~IA64_THREAD_PM_VALID;
        }
 #endif
+#ifdef CONFIG_PRINT_FPEMU
+       if (current->thread.fpemu_count)
+               printk(KERN_WARNING "%s(%d): %lu floating-point assist faults\n",
+                      current->comm, current->pid, current->thread.fpemu_count);
+#endif
 }
 
 unsigned long
diff -urN linux-2.4.16/arch/ia64/kernel/traps.c linux-2.4.16-fpemu/arch/ia64/kernel/traps.c
--- linux-2.4.16/arch/ia64/kernel/traps.c       Fri Nov  9 16:26:17 2001
+++ linux-2.4.16-fpemu/arch/ia64/kernel/traps.c Wed Nov 28 06:56:56 2001
@@ -33,6 +33,7 @@
 #include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/vt_kern.h>             /* For unblank_screen() */
+#include <linux/proc_fs.h>
 
 #include <asm/hardirq.h>
 #include <asm/ia32.h>
@@ -45,6 +46,50 @@
 
 static fpswa_interface_t *fpswa_interface;
 
+#ifdef CONFIG_PROC_FPEMU
+static unsigned long fpemu_count[NR_CPUS];
+static struct proc_dir_entry *fpemu_dir;
+
+static int
+fpemu_proc_info(char *page)
+{
+       int i;
+       char *p = page;
+       unsigned long total = 0;
+
+       for (i = 0; i < smp_num_cpus; ++i) {
+               total += fpemu_count[i];
+               p += sprintf(p, "CPU%d=%lu\n", i, fpemu_count[i]);
+       }
+
+       p += sprintf(p, "Total=%lu\n", total);
+
+       return p - page;
+}
+
+static int
+fpemu_read_entry(char *page, char **start, off_t off, int count, int *eof, void *data)
+{
+    int len = fpemu_proc_info(page);
+
+    if (len <= off+count) *eof = 1;
+    *start = page + off;
+    len -= off;
+    if (len > count) len = count;
+    if (len < 0) len = 0;
+
+    return len;
+}
+
+void __init
+trap_proc_init(void)
+{
+       if (ia64_boot_param->fpswa)
+               fpemu_dir = create_proc_read_entry("fpemu", 0, 0, fpemu_read_entry, NULL);
+}
+
+#endif
+
 void __init
 trap_init (void)
 {
@@ -267,6 +312,7 @@
        if (!fpswa_interface)
                return -1;
 
+
        memset(&fp_state, 0, sizeof(fp_state_t));
 
        /*
@@ -311,8 +357,10 @@
        long exception, bundle[2];
        unsigned long fault_ip;
        struct siginfo siginfo;
+#if !defined(CONFIG_PROC_FPEMU) && !defined(CONFIG_PRINT_FPEMU) && !defined(CONFIG_SIGNAL_FPEMU)
        static int fpu_swa_count = 0;
        static unsigned long last_time;
+#endif
 
        fault_ip = regs->cr_iip;
        if (!fp_fault && (ia64_psr(regs)->ri = 0))
@@ -320,6 +368,7 @@
        if (copy_from_user(bundle, (void *) fault_ip, sizeof(bundle)))
                return -1;
 
+#if !defined(CONFIG_PROC_FPEMU) && !defined(CONFIG_PRINT_FPEMU) && !defined(CONFIG_SIGNAL_FPEMU)
        if (jiffies - last_time > 5*HZ)
                fpu_swa_count = 0;
        if ((++fpu_swa_count < 5) && !(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT)) {
@@ -327,9 +376,27 @@
                printk(KERN_WARNING "%s(%d): floating-point assist fault at ip %016lx\n",
                       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri);
        }
+#endif
+#ifdef CONFIG_PROC_FPEMU
+       ++fpemu_count[smp_processor_id()];
+#endif
+#ifdef CONFIG_PRINT_FPEMU
+       ++current->thread.fpemu_count;
+#endif
 
        exception = fp_emulate(fp_fault, bundle, &regs->cr_ipsr, &regs->ar_fpsr, &isr, &regs->pr,
                               &regs->cr_ifs, regs);
+#ifdef CONFIG_SIGNAL_FPEMU
+        if (!exception && current->thread.fpemu_sig) {
+               siginfo.si_signo = current->thread.fpemu_sig;
+               siginfo.si_errno = 0;
+               siginfo.si_code = __SI_FAULT;
+               siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+               siginfo.si_isr = isr;
+               send_sig_info(current->thread.fpemu_sig, &siginfo, current);
+       }
+#endif
+
        if (fp_fault) {
                if (exception = 0) {
                        /* emulation was successful */
@@ -523,7 +590,11 @@
              case 32: /* fp fault */
              case 33: /* fp trap */
                result = handle_fpu_swa((vector = 32) ? 1 : 0, regs, isr);
+#if !defined(CONFIG_SIGNAL_FPEMU)
                if ((result < 0) || (current->thread.flags & IA64_THREAD_FPEMU_SIGFPE)) {
+#else
+               if (result < 0) {
+#endif
                        siginfo.si_signo = SIGFPE;
                        siginfo.si_errno = 0;
                        siginfo.si_code = FPE_FLTINV;
diff -urN linux-2.4.16/include/asm-ia64/processor.h linux-2.4.16-fpemu/include/asm-ia64/processor.h
--- linux-2.4.16/include/asm-ia64/processor.h   Tue Nov 27 12:10:19 2001
+++ linux-2.4.16-fpemu/include/asm-ia64/processor.h     Wed Nov 28 06:11:03 2001
@@ -345,6 +345,15 @@
                 (int *) (addr));                                                               \
 })
 
+#ifdef CONFIG_SIGNAL_FPEMU
+#define SET_FPEMU_SIG(task,value)                                                              \
+({                                                                                             \
+       (task)->thread.fpemu_sig = value; \
+       0;                                \
+})
+#endif
+
+
 struct siginfo;
 
 struct thread_struct {
@@ -378,6 +387,18 @@
 #else
 # define INIT_THREAD_PM
 #endif
+#ifdef CONFIG_PRINT_FPEMU
+       __u64 fpemu_count;
+# define INIT_FPEMU_COUNT      0,
+#else
+# define INIT_FPEMU_COUNT
+#endif
+#ifdef CONFIG_SIGNAL_FPEMU
+       __u64 fpemu_sig;
+# define INIT_FPEMU_SIG 0,
+#else
+# define INIT_FPEMU_SIG
+#endif
        __u64 dbr[IA64_NUM_DBG_REGS];
        __u64 ibr[IA64_NUM_DBG_REGS];
        struct ia64_fpreg fph[96];      /* saved/loaded on demand */
@@ -391,6 +412,8 @@
        0,                              /* siginfo */   \
        INIT_THREAD_IA32                                \
        INIT_THREAD_PM                                  \
+       INIT_FPEMU_COUNT                                \
+       INIT_FPEMU_SIG                                  \
        {0, },                          /* dbr */       \
        {0, },                          /* ibr */       \
        {{{{0}}}, }                     /* fph */       \
diff -urN linux-2.4.16/include/linux/prctl.h linux-2.4.16-fpemu/include/linux/prctl.h
--- linux-2.4.16/include/linux/prctl.h  Tue Nov 27 12:10:20 2001
+++ linux-2.4.16-fpemu/include/linux/prctl.h    Wed Nov 28 06:19:16 2001
@@ -26,4 +26,6 @@
 # define PR_FPEMU_NOPRINT      1       /* silently emulate fp operations accesses */
 # define PR_FPEMU_SIGFPE       2       /* don't emulate fp operations, send SIGFPE instead */
 
+#define PR_FPEMU_SIGNAL        11              /* generate signal on successful FPEMU invocation */
+
 #endif /* _LINUX_PRCTL_H */
diff -urN linux-2.4.16/init/main.c linux-2.4.16-fpemu/init/main.c
--- linux-2.4.16/init/main.c    Tue Nov 27 12:10:20 2001
+++ linux-2.4.16-fpemu/init/main.c      Wed Nov 28 06:11:03 2001
@@ -109,6 +109,9 @@
 #ifdef CONFIG_PERFMON
 extern void perfmon_init(void);
 #endif
+#ifdef CONFIG_PROC_FPEMU
+extern void trap_proc_init(void);
+#endif
 
 /*
  * Boot command-line arguments
@@ -597,6 +600,9 @@
 #ifdef CONFIG_PERFMON
        perfmon_init();
 #endif
+#ifdef CONFIG_PROC_FPEMU
+       trap_proc_init();
+#endif
        mempages = num_physpages;
 
        fork_init(mempages);
diff -urN linux-2.4.16/kernel/sys.c linux-2.4.16-fpemu/kernel/sys.c
--- linux-2.4.16/kernel/sys.c   Tue Nov 27 12:10:20 2001
+++ linux-2.4.16-fpemu/kernel/sys.c     Wed Nov 28 06:11:03 2001
@@ -1272,6 +1272,14 @@
                        }
                        current->keep_capabilities = arg2;
                        break;
+               case PR_FPEMU_SIGNAL:
+#ifdef SET_FPEMU_SIG
+                       error = arg2 < 1 || arg2 >= _NSIG
+                               ? -EINVAL : SET_FPEMU_SIG(current, arg2);
+#else
+                        error = -EINVAL;
+#endif
+                       break;
                default:
                        error = -EINVAL;
                        break;


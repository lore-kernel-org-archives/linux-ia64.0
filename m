From: Joe Perches <joe@perches.com>
Date: Thu, 10 Nov 2011 09:41:44 +0000
Subject: [PATCH 3/5] treewide: Remove useless NORET_TYPE macro and uses
Message-Id: <e69163f6245513b05d5d21c2f57b916931ad5bff.1320917557.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1320917551.git.joe@perches.com>
In-Reply-To: <cover.1320917551.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org

It's a very old and now unused prototype marking
so just delete it.

Neaten panic pointer argument style to keep checkpatch quiet.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/avr32/include/asm/system.h        |    2 +-
 arch/avr32/kernel/traps.c              |    2 +-
 arch/ia64/kernel/machine_kexec.c       |    2 +-
 arch/m68k/amiga/config.c               |    2 +-
 arch/mips/include/asm/ptrace.h         |    2 +-
 arch/mips/kernel/traps.c               |    2 +-
 arch/powerpc/kernel/machine_kexec_32.c |    2 +-
 arch/powerpc/kernel/machine_kexec_64.c |    6 +++---
 arch/s390/kernel/nmi.c                 |    2 +-
 arch/tile/kernel/machine_kexec.c       |    4 ++--
 include/linux/kernel.h                 |    6 +++---
 include/linux/linkage.h                |    1 -
 include/linux/sched.h                  |    2 +-
 kernel/exit.c                          |    6 +++---
 kernel/panic.c                         |    2 +-
 15 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/arch/avr32/include/asm/system.h b/arch/avr32/include/asm/system.h
index 9702c221..62d9ded 100644
--- a/arch/avr32/include/asm/system.h
+++ b/arch/avr32/include/asm/system.h
@@ -169,7 +169,7 @@ static inline unsigned long __cmpxchg_local(volatile void *ptr,
 #define cmpxchg64_local(ptr, o, n) __cmpxchg64_local_generic((ptr), (o), (n))
 
 struct pt_regs;
-void NORET_TYPE die(const char *str, struct pt_regs *regs, long err);
+void die(const char *str, struct pt_regs *regs, long err);
 void _exception(long signr, struct pt_regs *regs, int code,
 		unsigned long addr);
 
diff --git a/arch/avr32/kernel/traps.c b/arch/avr32/kernel/traps.c
index 7aa2575..3d760c0 100644
--- a/arch/avr32/kernel/traps.c
+++ b/arch/avr32/kernel/traps.c
@@ -24,7 +24,7 @@
 
 static DEFINE_SPINLOCK(die_lock);
 
-void NORET_TYPE die(const char *str, struct pt_regs *regs, long err)
+void die(const char *str, struct pt_regs *regs, long err)
 {
 	static int die_counter;
 
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 3d3aeef..581a16d 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -27,7 +27,7 @@
 #include <asm/sal.h>
 #include <asm/mca.h>
 
-typedef NORET_TYPE void (*relocate_new_kernel_t)(
+typedef void (*relocate_new_kernel_t)(
 					unsigned long indirection_page,
 					unsigned long start_address,
 					struct ia64_boot_param *boot_param,
diff --git a/arch/m68k/amiga/config.c b/arch/m68k/amiga/config.c
index 82a4bb5..a3b0558 100644
--- a/arch/m68k/amiga/config.c
+++ b/arch/m68k/amiga/config.c
@@ -511,7 +511,7 @@ static unsigned long amiga_gettimeoffset(void)
 	return ticks + offset;
 }
 
-static NORET_TYPE void amiga_reset(void)
+static void amiga_reset(void)
     ATTRIB_NORET;
 
 static void amiga_reset(void)
diff --git a/arch/mips/include/asm/ptrace.h b/arch/mips/include/asm/ptrace.h
index de39b1f..3d91325 100644
--- a/arch/mips/include/asm/ptrace.h
+++ b/arch/mips/include/asm/ptrace.h
@@ -144,7 +144,7 @@ extern int ptrace_set_watch_regs(struct task_struct *child,
 extern asmlinkage void syscall_trace_enter(struct pt_regs *regs);
 extern asmlinkage void syscall_trace_leave(struct pt_regs *regs);
 
-extern NORET_TYPE void die(const char *, struct pt_regs *) ATTRIB_NORET;
+extern void die(const char *, struct pt_regs *) ATTRIB_NORET;
 
 static inline void die_if_kernel(const char *str, struct pt_regs *regs)
 {
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 261ccbc..fc2cbbc 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -1340,7 +1340,7 @@ void ejtag_exception_handler(struct pt_regs *regs)
 /*
  * NMI exception handler.
  */
-NORET_TYPE void ATTRIB_NORET nmi_exception_handler(struct pt_regs *regs)
+void ATTRIB_NORET nmi_exception_handler(struct pt_regs *regs)
 {
 	bust_spinlocks(1);
 	printk("NMI taken!!!!\n");
diff --git a/arch/powerpc/kernel/machine_kexec_32.c b/arch/powerpc/kernel/machine_kexec_32.c
index e63f2e7..026e7f1 100644
--- a/arch/powerpc/kernel/machine_kexec_32.c
+++ b/arch/powerpc/kernel/machine_kexec_32.c
@@ -16,7 +16,7 @@
 #include <asm/hw_irq.h>
 #include <asm/io.h>
 
-typedef NORET_TYPE void (*relocate_new_kernel_t)(
+typedef void (*relocate_new_kernel_t)(
 				unsigned long indirection_page,
 				unsigned long reboot_code_buffer,
 				unsigned long start_address) ATTRIB_NORET;
diff --git a/arch/powerpc/kernel/machine_kexec_64.c b/arch/powerpc/kernel/machine_kexec_64.c
index 26ccbf7..5fbbf81 100644
--- a/arch/powerpc/kernel/machine_kexec_64.c
+++ b/arch/powerpc/kernel/machine_kexec_64.c
@@ -307,9 +307,9 @@ static union thread_union kexec_stack __init_task_data  struct paca_struct kexec_paca;
 
 /* Our assembly helper, in kexec_stub.S */
-extern NORET_TYPE void kexec_sequence(void *newstack, unsigned long start,
-					void *image, void *control,
-					void (*clear_all)(void)) ATTRIB_NORET;
+extern void kexec_sequence(void *newstack, unsigned long start,
+			   void *image, void *control,
+			   void (*clear_all)(void)) ATTRIB_NORET;
 
 /* too late to fail here */
 void default_machine_kexec(struct kimage *image)
diff --git a/arch/s390/kernel/nmi.c b/arch/s390/kernel/nmi.c
index fab8843..0fd2e86 100644
--- a/arch/s390/kernel/nmi.c
+++ b/arch/s390/kernel/nmi.c
@@ -30,7 +30,7 @@ struct mcck_struct {
 
 static DEFINE_PER_CPU(struct mcck_struct, cpu_mcck);
 
-static NORET_TYPE void s390_handle_damage(char *msg)
+static void s390_handle_damage(char *msg)
 {
 	smp_send_stop();
 	disabled_wait((unsigned long) __builtin_return_address(0));
diff --git a/arch/tile/kernel/machine_kexec.c b/arch/tile/kernel/machine_kexec.c
index e00d717..b0c9070 100644
--- a/arch/tile/kernel/machine_kexec.c
+++ b/arch/tile/kernel/machine_kexec.c
@@ -248,10 +248,10 @@ static void setup_quasi_va_is_pa(void)
 }
 
 
-NORET_TYPE void machine_kexec(struct kimage *image)
+void machine_kexec(struct kimage *image)
 {
 	void *reboot_code_buffer;
-	NORET_TYPE void (*rnk)(unsigned long, void *, unsigned long)
+	void (*rnk)(unsigned long, void *, unsigned long)
 		ATTRIB_NORET;
 
 	/* Mask all interrupts before starting to reboot. */
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 23dae61..c0e0055 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -185,16 +185,16 @@ static inline void might_fault(void)
 
 extern struct atomic_notifier_head panic_notifier_list;
 extern long (*panic_blink)(int state);
-NORET_TYPE __printf(1, 2)
+__printf(1, 2)
 void panic(const char *fmt, ...)
 	ATTRIB_NORET __cold;
 extern void oops_enter(void);
 extern void oops_exit(void);
 void print_oops_end_marker(void);
 extern int oops_may_print(void);
-NORET_TYPE void do_exit(long error_code)
+void do_exit(long error_code)
 	ATTRIB_NORET;
-NORET_TYPE void complete_and_exit(struct completion *, long)
+void complete_and_exit(struct completion *, long)
 	ATTRIB_NORET;
 
 /* Internal, do not use. */
diff --git a/include/linux/linkage.h b/include/linux/linkage.h
index c75074c..6a8f252 100644
--- a/include/linux/linkage.h
+++ b/include/linux/linkage.h
@@ -88,7 +88,6 @@
 
 #endif
 
-#define NORET_TYPE    /**/
 #define ATTRIB_NORET  __attribute__((noreturn))
 
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 68daf4f..5e00e6b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2252,7 +2252,7 @@ extern void __cleanup_sighand(struct sighand_struct *);
 extern void exit_itimers(struct signal_struct *);
 extern void flush_itimer_signals(void);
 
-extern NORET_TYPE void do_group_exit(int);
+extern void do_group_exit(int);
 
 extern void daemonize(const char *, ...);
 extern int allow_signal(int);
diff --git a/kernel/exit.c b/kernel/exit.c
index d0b7d98..d1bdbee 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -888,7 +888,7 @@ static void check_stack_usage(void)
 static inline void check_stack_usage(void) {}
 #endif
 
-NORET_TYPE void do_exit(long code)
+void do_exit(long code)
 {
 	struct task_struct *tsk = current;
 	int group_dead;
@@ -1049,7 +1049,7 @@ NORET_TYPE void do_exit(long code)
 
 EXPORT_SYMBOL_GPL(do_exit);
 
-NORET_TYPE void complete_and_exit(struct completion *comp, long code)
+void complete_and_exit(struct completion *comp, long code)
 {
 	if (comp)
 		complete(comp);
@@ -1068,7 +1068,7 @@ SYSCALL_DEFINE1(exit, int, error_code)
  * Take down every thread in the group.  This is called by fatal signals
  * as well as by sys_exit_group (below).
  */
-NORET_TYPE void
+void
 do_group_exit(int exit_code)
 {
 	struct signal_struct *sig = current->signal;
diff --git a/kernel/panic.c b/kernel/panic.c
index b2659360..9b7df21 100644
--- a/kernel/panic.c
+++ b/kernel/panic.c
@@ -57,7 +57,7 @@ EXPORT_SYMBOL(panic_blink);
  *
  *	This function never returns.
  */
-NORET_TYPE void panic(const char * fmt, ...)
+void panic(const char *fmt, ...)
 {
 	static char buf[1024];
 	va_list args;
-- 
1.7.6.405.gc1be0


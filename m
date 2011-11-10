From: Joe Perches <joe@perches.com>
Date: Thu, 10 Nov 2011 09:41:45 +0000
Subject: [PATCH 4/5] treewide: Convert uses of ATTRIB_NORETURN to __noreturn
Message-Id: <abb1d8b542872ef3bfd695e85d3b8a0fd70645b9.1320917558.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1320917551.git.joe@perches.com>
In-Reply-To: <cover.1320917551.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@google.com>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org

Use the more commonly used __noreturn instead of ATTRIB_NORETURN.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/machine_kexec.c       |    2 +-
 arch/m68k/amiga/config.c               |    2 +-
 arch/mips/include/asm/ptrace.h         |    2 +-
 arch/mips/kernel/traps.c               |    2 +-
 arch/mn10300/include/asm/exceptions.h  |    2 +-
 arch/powerpc/kernel/machine_kexec_32.c |    2 +-
 arch/powerpc/kernel/machine_kexec_64.c |    2 +-
 arch/s390/include/asm/processor.h      |    2 +-
 arch/sh/kernel/process_32.c            |    2 +-
 arch/sh/kernel/process_64.c            |    2 +-
 arch/tile/kernel/machine_kexec.c       |    2 +-
 include/linux/kernel.h                 |    6 +++---
 12 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 581a16d..4eed358 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -31,7 +31,7 @@ typedef void (*relocate_new_kernel_t)(
 					unsigned long indirection_page,
 					unsigned long start_address,
 					struct ia64_boot_param *boot_param,
-					unsigned long pal_addr) ATTRIB_NORET;
+					unsigned long pal_addr) __noreturn;
 
 struct kimage *ia64_kimage;
 
diff --git a/arch/m68k/amiga/config.c b/arch/m68k/amiga/config.c
index a3b0558..7aec938 100644
--- a/arch/m68k/amiga/config.c
+++ b/arch/m68k/amiga/config.c
@@ -512,7 +512,7 @@ static unsigned long amiga_gettimeoffset(void)
 }
 
 static void amiga_reset(void)
-    ATTRIB_NORET;
+    __noreturn;
 
 static void amiga_reset(void)
 {
diff --git a/arch/mips/include/asm/ptrace.h b/arch/mips/include/asm/ptrace.h
index 3d91325..7b99c67 100644
--- a/arch/mips/include/asm/ptrace.h
+++ b/arch/mips/include/asm/ptrace.h
@@ -144,7 +144,7 @@ extern int ptrace_set_watch_regs(struct task_struct *child,
 extern asmlinkage void syscall_trace_enter(struct pt_regs *regs);
 extern asmlinkage void syscall_trace_leave(struct pt_regs *regs);
 
-extern void die(const char *, struct pt_regs *) ATTRIB_NORET;
+extern void die(const char *, struct pt_regs *) __noreturn;
 
 static inline void die_if_kernel(const char *str, struct pt_regs *regs)
 {
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index fc2cbbc..ac740b0 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -1340,7 +1340,7 @@ void ejtag_exception_handler(struct pt_regs *regs)
 /*
  * NMI exception handler.
  */
-void ATTRIB_NORET nmi_exception_handler(struct pt_regs *regs)
+void __noreturn nmi_exception_handler(struct pt_regs *regs)
 {
 	bust_spinlocks(1);
 	printk("NMI taken!!!!\n");
diff --git a/arch/mn10300/include/asm/exceptions.h b/arch/mn10300/include/asm/exceptions.h
index ca3e205..95a4d42 100644
--- a/arch/mn10300/include/asm/exceptions.h
+++ b/arch/mn10300/include/asm/exceptions.h
@@ -110,7 +110,7 @@ extern asmlinkage void nmi_handler(void);
 extern asmlinkage void misalignment(struct pt_regs *, enum exception_code);
 
 extern void die(const char *, struct pt_regs *, enum exception_code)
-	ATTRIB_NORET;
+	__noreturn;
 
 extern int die_if_no_fixup(const char *, struct pt_regs *, enum exception_code);
 
diff --git a/arch/powerpc/kernel/machine_kexec_32.c b/arch/powerpc/kernel/machine_kexec_32.c
index 026e7f1..affe5dc 100644
--- a/arch/powerpc/kernel/machine_kexec_32.c
+++ b/arch/powerpc/kernel/machine_kexec_32.c
@@ -19,7 +19,7 @@
 typedef void (*relocate_new_kernel_t)(
 				unsigned long indirection_page,
 				unsigned long reboot_code_buffer,
-				unsigned long start_address) ATTRIB_NORET;
+				unsigned long start_address) __noreturn;
 
 /*
  * This is a generic machine_kexec function suitable at least for
diff --git a/arch/powerpc/kernel/machine_kexec_64.c b/arch/powerpc/kernel/machine_kexec_64.c
index 5fbbf81..d7f6090 100644
--- a/arch/powerpc/kernel/machine_kexec_64.c
+++ b/arch/powerpc/kernel/machine_kexec_64.c
@@ -309,7 +309,7 @@ struct paca_struct kexec_paca;
 /* Our assembly helper, in kexec_stub.S */
 extern void kexec_sequence(void *newstack, unsigned long start,
 			   void *image, void *control,
-			   void (*clear_all)(void)) ATTRIB_NORET;
+			   void (*clear_all)(void)) __noreturn;
 
 /* too late to fail here */
 void default_machine_kexec(struct kimage *image)
diff --git a/arch/s390/include/asm/processor.h b/arch/s390/include/asm/processor.h
index 5f33d37..c0d6f77 100644
--- a/arch/s390/include/asm/processor.h
+++ b/arch/s390/include/asm/processor.h
@@ -238,7 +238,7 @@ static inline unsigned long __rewind_psw(psw_t psw, unsigned long ilc)
 /*
  * Function to drop a processor into disabled wait state
  */
-static inline void ATTRIB_NORET disabled_wait(unsigned long code)
+static inline void __noreturn disabled_wait(unsigned long code)
 {
         unsigned long ctl_buf;
         psw_t dw_psw;
diff --git a/arch/sh/kernel/process_32.c b/arch/sh/kernel/process_32.c
index aaf6d59..7ec6651 100644
--- a/arch/sh/kernel/process_32.c
+++ b/arch/sh/kernel/process_32.c
@@ -70,7 +70,7 @@ void show_regs(struct pt_regs * regs)
 /*
  * Create a kernel thread
  */
-ATTRIB_NORET void kernel_thread_helper(void *arg, int (*fn)(void *))
+__noreturn void kernel_thread_helper(void *arg, int (*fn)(void *))
 {
 	do_exit(fn(arg));
 }
diff --git a/arch/sh/kernel/process_64.c b/arch/sh/kernel/process_64.c
index 210c1ca..cbd4e4b 100644
--- a/arch/sh/kernel/process_64.c
+++ b/arch/sh/kernel/process_64.c
@@ -285,7 +285,7 @@ void show_regs(struct pt_regs *regs)
 /*
  * Create a kernel thread
  */
-ATTRIB_NORET void kernel_thread_helper(void *arg, int (*fn)(void *))
+__noreturn void kernel_thread_helper(void *arg, int (*fn)(void *))
 {
 	do_exit(fn(arg));
 }
diff --git a/arch/tile/kernel/machine_kexec.c b/arch/tile/kernel/machine_kexec.c
index b0c9070..6255f2e 100644
--- a/arch/tile/kernel/machine_kexec.c
+++ b/arch/tile/kernel/machine_kexec.c
@@ -252,7 +252,7 @@ void machine_kexec(struct kimage *image)
 {
 	void *reboot_code_buffer;
 	void (*rnk)(unsigned long, void *, unsigned long)
-		ATTRIB_NORET;
+		__noreturn;
 
 	/* Mask all interrupts before starting to reboot. */
 	interrupt_mask_set_mask(~0ULL);
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index c0e0055..b93c66e 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -187,15 +187,15 @@ extern struct atomic_notifier_head panic_notifier_list;
 extern long (*panic_blink)(int state);
 __printf(1, 2)
 void panic(const char *fmt, ...)
-	ATTRIB_NORET __cold;
+	__noreturn __cold;
 extern void oops_enter(void);
 extern void oops_exit(void);
 void print_oops_end_marker(void);
 extern int oops_may_print(void);
 void do_exit(long error_code)
-	ATTRIB_NORET;
+	__noreturn;
 void complete_and_exit(struct completion *, long)
-	ATTRIB_NORET;
+	__noreturn;
 
 /* Internal, do not use. */
 int __must_check _kstrtoul(const char *s, unsigned int base, unsigned long *res);
-- 
1.7.6.405.gc1be0


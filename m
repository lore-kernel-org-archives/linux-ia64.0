From: David Howells <dhowells@redhat.com>
Date: Mon, 10 Apr 2017 12:15:58 +0000
Subject: [RFC PATCH 1/5] Construct init thread stack in the linker script rather than by union
Message-Id: <149182655877.9959.2320910557250106080.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <149182655182.9959.4421578108754243877.stgit@warthog.procyon.org.uk>
In-Reply-To: <149182655182.9959.4421578108754243877.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org

Construct the init thread stack in the linker script rather than doing it
by means of a union so that ia64's init_task.c can be got rid of.

The following symbols are then made available from INIT_TASK_DATA() linker
script macro:

	init_thread_union
	init_stack

INIT_TASK_DATA() also expands the region to THREAD_SIZE to accommodate the
size of the init stack.  init_thread_union is given its own section so that
it can be placed into the stack space in the right order.  I'm assuming
that the ia64 ordering is correct and that the task_struct is first and the
thread_info second.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/Kconfig                              |    4 +--
 arch/alpha/include/asm/thread_info.h      |    3 --
 arch/arc/include/asm/thread_info.h        |    3 --
 arch/arm/include/asm/thread_info.h        |    3 --
 arch/arm64/include/asm/thread_info.h      |    2 -
 arch/avr32/include/asm/thread_info.h      |    3 --
 arch/blackfin/include/asm/thread_info.h   |    2 -
 arch/c6x/include/asm/thread_info.h        |    3 --
 arch/cris/include/asm/processor.h         |    2 -
 arch/frv/include/asm/thread_info.h        |    3 --
 arch/h8300/include/asm/thread_info.h      |    3 --
 arch/hexagon/include/asm/thread_info.h    |    3 --
 arch/ia64/Kconfig                         |    2 +
 arch/ia64/Makefile                        |    2 +
 arch/ia64/include/asm/thread_info.h       |    4 +--
 arch/ia64/kernel/Makefile                 |    2 +
 arch/ia64/kernel/init_task.c              |   43 -----------------------------
 arch/ia64/kernel/vmlinux.lds.S            |    1 +
 arch/m32r/include/asm/thread_info.h       |    3 --
 arch/m68k/include/asm/thread_info.h       |    2 -
 arch/metag/include/asm/thread_info.h      |    3 --
 arch/microblaze/include/asm/thread_info.h |    3 --
 arch/mips/include/asm/thread_info.h       |    3 --
 arch/mn10300/include/asm/thread_info.h    |    2 -
 arch/nios2/include/asm/thread_info.h      |    3 --
 arch/openrisc/include/asm/processor.h     |    2 -
 arch/parisc/include/asm/thread_info.h     |    3 --
 arch/powerpc/include/asm/thread_info.h    |    3 --
 arch/s390/include/asm/thread_info.h       |    2 -
 arch/score/include/asm/thread_info.h      |    3 --
 arch/sh/include/asm/thread_info.h         |    3 --
 arch/sparc/include/asm/thread_info_32.h   |    3 --
 arch/sparc/include/asm/thread_info_64.h   |    3 --
 arch/tile/include/asm/thread_info.h       |    3 --
 arch/um/include/asm/processor-generic.h   |    2 -
 arch/um/include/asm/thread_info.h         |    3 --
 arch/unicore32/include/asm/thread_info.h  |    3 --
 arch/x86/include/asm/thread_info.h        |    2 -
 arch/xtensa/include/asm/thread_info.h     |    3 --
 include/asm-generic/vmlinux.lds.h         |    4 +++
 include/linux/init_task.h                 |    3 ++
 include/linux/sched.h                     |    9 ++++++
 init/Makefile                             |    2 -
 init/init_task.c                          |   10 ++++---
 44 files changed, 30 insertions(+), 143 deletions(-)
 delete mode 100644 arch/ia64/kernel/init_task.c

diff --git a/arch/Kconfig b/arch/Kconfig
index cd211a14a88f..0a51e79ac6da 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -226,8 +226,8 @@ config GENERIC_IDLE_POLL_SETUP
 config ARCH_HAS_SET_MEMORY
 	bool
 
-# Select if arch init_task initializer is different to init/init_task.c
-config ARCH_INIT_TASK
+# Select if arch init_task must go in the __init_task_data section
+config ARCH_TASK_STRUCT_ON_STACK
        bool
 
 # Select if arch has its private alloc_task_struct() function
diff --git a/arch/alpha/include/asm/thread_info.h b/arch/alpha/include/asm/thread_info.h
index e9e90bfa2b50..9e336842aa80 100644
--- a/arch/alpha/include/asm/thread_info.h
+++ b/arch/alpha/include/asm/thread_info.h
@@ -38,9 +38,6 @@ struct thread_info {
 	.preempt_count	= INIT_PREEMPT_COUNT,	\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* How to get the thread information struct from C.  */
 register struct thread_info *__current_thread_info __asm__("$8");
 #define current_thread_info()  __current_thread_info
diff --git a/arch/arc/include/asm/thread_info.h b/arch/arc/include/asm/thread_info.h
index 2d79e527fa50..c85947bac5e5 100644
--- a/arch/arc/include/asm/thread_info.h
+++ b/arch/arc/include/asm/thread_info.h
@@ -62,9 +62,6 @@ struct thread_info {
 	.addr_limit = KERNEL_DS,		\
 }
 
-#define init_thread_info    (init_thread_union.thread_info)
-#define init_stack          (init_thread_union.stack)
-
 static inline __attribute_const__ struct thread_info *current_thread_info(void)
 {
 	register unsigned long sp asm("sp");
diff --git a/arch/arm/include/asm/thread_info.h b/arch/arm/include/asm/thread_info.h
index 776757d1604a..e71cc35de163 100644
--- a/arch/arm/include/asm/thread_info.h
+++ b/arch/arm/include/asm/thread_info.h
@@ -75,9 +75,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,					\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /*
  * how to get the current stack pointer in C
  */
diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
index 46c3b93cf865..5dc7dd2fa72c 100644
--- a/arch/arm64/include/asm/thread_info.h
+++ b/arch/arm64/include/asm/thread_info.h
@@ -59,8 +59,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,					\
 }
 
-#define init_stack		(init_thread_union.stack)
-
 #define thread_saved_pc(tsk)	\
 	((unsigned long)(tsk->thread.cpu_context.pc))
 #define thread_saved_sp(tsk)	\
diff --git a/arch/avr32/include/asm/thread_info.h b/arch/avr32/include/asm/thread_info.h
index d4d3079541ea..529dcd7e0edf 100644
--- a/arch/avr32/include/asm/thread_info.h
+++ b/arch/avr32/include/asm/thread_info.h
@@ -39,9 +39,6 @@ struct thread_info {
 	.preempt_count	= INIT_PREEMPT_COUNT,				\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /*
  * Get the thread information struct from C.
  * We do the usual trick and use the lower end of the stack for this
diff --git a/arch/blackfin/include/asm/thread_info.h b/arch/blackfin/include/asm/thread_info.h
index 2966b93850a1..a5aeab4e5f2d 100644
--- a/arch/blackfin/include/asm/thread_info.h
+++ b/arch/blackfin/include/asm/thread_info.h
@@ -56,8 +56,6 @@ struct thread_info {
 	.cpu		= 0,			\
 	.preempt_count	= INIT_PREEMPT_COUNT,	\
 }
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
 
 /* Given a task stack pointer, you can find its corresponding
  * thread_info structure just by masking it to the THREAD_SIZE
diff --git a/arch/c6x/include/asm/thread_info.h b/arch/c6x/include/asm/thread_info.h
index acc70c135ab8..59a5697fe0f3 100644
--- a/arch/c6x/include/asm/thread_info.h
+++ b/arch/c6x/include/asm/thread_info.h
@@ -60,9 +60,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* get the thread information struct of current task */
 static inline __attribute__((const))
 struct thread_info *current_thread_info(void)
diff --git a/arch/cris/include/asm/processor.h b/arch/cris/include/asm/processor.h
index 15b815df29c1..dc16323d83c4 100644
--- a/arch/cris/include/asm/processor.h
+++ b/arch/cris/include/asm/processor.h
@@ -60,8 +60,6 @@ static inline void release_thread(struct task_struct *dead_task)
         /* Nothing needs to be done.  */
 }
 
-#define init_stack      (init_thread_union.stack)
-
 #define cpu_relax()     barrier()
 
 void default_idle(void);
diff --git a/arch/frv/include/asm/thread_info.h b/arch/frv/include/asm/thread_info.h
index ccba3b6ce918..0f950845fad9 100644
--- a/arch/frv/include/asm/thread_info.h
+++ b/arch/frv/include/asm/thread_info.h
@@ -64,9 +64,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 register struct thread_info *__current_thread_info asm("gr15");
 
diff --git a/arch/h8300/include/asm/thread_info.h b/arch/h8300/include/asm/thread_info.h
index 3cef06875f5c..8254f92b359a 100644
--- a/arch/h8300/include/asm/thread_info.h
+++ b/arch/h8300/include/asm/thread_info.h
@@ -45,9 +45,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
 {
diff --git a/arch/hexagon/include/asm/thread_info.h b/arch/hexagon/include/asm/thread_info.h
index b80fe1db7b64..f41f9c6f0e31 100644
--- a/arch/hexagon/include/asm/thread_info.h
+++ b/arch/hexagon/include/asm/thread_info.h
@@ -84,9 +84,6 @@ struct thread_info {
 	.regs = NULL,			\
 }
 
-#define init_thread_info        (init_thread_union.thread_info)
-#define init_stack              (init_thread_union.stack)
-
 /* Tacky preprocessor trickery */
 #define	qqstr(s) qstr(s)
 #define qstr(s) #s
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 18ca6a9ce566..86fa5f197ca8 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -42,7 +42,7 @@ config IA64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
 	select GENERIC_SMP_IDLE_THREAD
-	select ARCH_INIT_TASK
+	select ARCH_TASK_STRUCT_ON_STACK
 	select ARCH_TASK_STRUCT_ALLOCATOR
 	select ARCH_THREAD_STACK_ALLOCATOR
 	select ARCH_CLOCKSOURCE_DATA
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index c100d780f1eb..2dd7f519ad0b 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -42,7 +42,7 @@ $(error Sorry, you need a newer version of the assember, one that is built from
 endif
 
 KBUILD_CFLAGS += $(cflags-y)
-head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
+head-y := arch/ia64/kernel/head.o
 
 libs-y				+= arch/ia64/lib/
 core-y				+= arch/ia64/kernel/ arch/ia64/mm/
diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index 8742d741d19a..caf4f2fefdf3 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -11,6 +11,8 @@
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 
+#define THREAD_SIZE			KERNEL_STACK_SIZE
+
 #ifndef __ASSEMBLY__
 
 /*
@@ -40,8 +42,6 @@ struct thread_info {
 #endif
 };
 
-#define THREAD_SIZE			KERNEL_STACK_SIZE
-
 #define INIT_THREAD_INFO(tsk)			\
 {						\
 	.task		= &tsk,			\
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 3686d6abafde..af29000c5349 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -6,7 +6,7 @@ ifdef CONFIG_DYNAMIC_FTRACE
 CFLAGS_REMOVE_ftrace.o = -pg
 endif
 
-extra-y	:= head.o init_task.o vmlinux.lds
+extra-y	:= head.o vmlinux.lds
 
 obj-y := entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o sal.o		\
diff --git a/arch/ia64/kernel/init_task.c b/arch/ia64/kernel/init_task.c
deleted file mode 100644
index fa8ee64adac2..000000000000
--- a/arch/ia64/kernel/init_task.c
+++ /dev/null
@@ -1,43 +0,0 @@
-/*
- * This is where we statically allocate and initialize the initial
- * task.
- *
- * Copyright (C) 1999, 2002-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#include <linux/init.h>
-#include <linux/mm.h>
-#include <linux/fs.h>
-#include <linux/module.h>
-#include <linux/sched.h>
-#include <linux/init_task.h>
-#include <linux/mqueue.h>
-
-#include <linux/uaccess.h>
-#include <asm/pgtable.h>
-
-static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
-static struct sighand_struct init_sighand = INIT_SIGHAND(init_sighand);
-/*
- * Initial task structure.
- *
- * We need to make sure that this is properly aligned due to the way process stacks are
- * handled. This is done by having a special ".data..init_task" section...
- */
-#define init_thread_info	init_task_mem.s.thread_info
-#define init_stack		init_task_mem.stack
-
-union {
-	struct {
-		struct task_struct task;
-		struct thread_info thread_info;
-	} s;
-	unsigned long stack[KERNEL_STACK_SIZE/sizeof (unsigned long)];
-} init_task_mem asm ("init_task") __init_task_data -	{{
-	.task =		INIT_TASK(init_task_mem.s.task),
-	.thread_info =	INIT_THREAD_INFO(init_task_mem.s.task)
-}};
-
-EXPORT_SYMBOL(init_task);
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index f89d20c97412..28ff81b6ea99 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -2,6 +2,7 @@
 #include <asm/cache.h>
 #include <asm/ptrace.h>
 #include <asm/pgtable.h>
+#include <asm/thread_info.h>
 
 #include <asm-generic/vmlinux.lds.h>
 
diff --git a/arch/m32r/include/asm/thread_info.h b/arch/m32r/include/asm/thread_info.h
index f630d9c30b28..47d0258fd513 100644
--- a/arch/m32r/include/asm/thread_info.h
+++ b/arch/m32r/include/asm/thread_info.h
@@ -55,9 +55,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
 {
diff --git a/arch/m68k/include/asm/thread_info.h b/arch/m68k/include/asm/thread_info.h
index cee13c2e5161..5c5893466cd4 100644
--- a/arch/m68k/include/asm/thread_info.h
+++ b/arch/m68k/include/asm/thread_info.h
@@ -40,8 +40,6 @@ struct thread_info {
 	.preempt_count	= INIT_PREEMPT_COUNT,	\
 }
 
-#define init_stack		(init_thread_union.stack)
-
 #ifndef __ASSEMBLY__
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
diff --git a/arch/metag/include/asm/thread_info.h b/arch/metag/include/asm/thread_info.h
index 32677cc278aa..6e8303ba77cf 100644
--- a/arch/metag/include/asm/thread_info.h
+++ b/arch/metag/include/asm/thread_info.h
@@ -73,9 +73,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the current stack pointer from C */
 register unsigned long current_stack_pointer asm("A0StP") __used;
 
diff --git a/arch/microblaze/include/asm/thread_info.h b/arch/microblaze/include/asm/thread_info.h
index e7e8954e9815..9afe4b5bd6c8 100644
--- a/arch/microblaze/include/asm/thread_info.h
+++ b/arch/microblaze/include/asm/thread_info.h
@@ -86,9 +86,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
 {
diff --git a/arch/mips/include/asm/thread_info.h b/arch/mips/include/asm/thread_info.h
index b439e512792b..3e9da8aeac6a 100644
--- a/arch/mips/include/asm/thread_info.h
+++ b/arch/mips/include/asm/thread_info.h
@@ -48,9 +48,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* How to get the thread information struct from C.  */
 register struct thread_info *__current_thread_info __asm__("$28");
 
diff --git a/arch/mn10300/include/asm/thread_info.h b/arch/mn10300/include/asm/thread_info.h
index f5f90bbf019d..1748a7b25bf8 100644
--- a/arch/mn10300/include/asm/thread_info.h
+++ b/arch/mn10300/include/asm/thread_info.h
@@ -79,8 +79,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
 #define init_uregs							\
 	((struct pt_regs *)						\
 	 ((unsigned long) init_stack + THREAD_SIZE - sizeof(struct pt_regs)))
diff --git a/arch/nios2/include/asm/thread_info.h b/arch/nios2/include/asm/thread_info.h
index d69c338bd19c..7349a4fa635b 100644
--- a/arch/nios2/include/asm/thread_info.h
+++ b/arch/nios2/include/asm/thread_info.h
@@ -63,9 +63,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
 {
diff --git a/arch/openrisc/include/asm/processor.h b/arch/openrisc/include/asm/processor.h
index a908e6c30a00..66f9bd5f56ea 100644
--- a/arch/openrisc/include/asm/processor.h
+++ b/arch/openrisc/include/asm/processor.h
@@ -89,8 +89,6 @@ unsigned long get_wchan(struct task_struct *p);
  */
 extern unsigned long thread_saved_pc(struct task_struct *t);
 
-#define init_stack      (init_thread_union.stack)
-
 #define cpu_relax()     barrier()
 
 #endif /* __ASSEMBLY__ */
diff --git a/arch/parisc/include/asm/thread_info.h b/arch/parisc/include/asm/thread_info.h
index 88fe0aad4390..421b0fb2a6ec 100644
--- a/arch/parisc/include/asm/thread_info.h
+++ b/arch/parisc/include/asm/thread_info.h
@@ -24,9 +24,6 @@ struct thread_info {
 	.preempt_count	= INIT_PREEMPT_COUNT,	\
 }
 
-#define init_thread_info        (init_thread_union.thread_info)
-#define init_stack              (init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 #define current_thread_info()	((struct thread_info *)mfctl(30))
 
diff --git a/arch/powerpc/include/asm/thread_info.h b/arch/powerpc/include/asm/thread_info.h
index 87e4b2d8dcd4..0abb4e9cd198 100644
--- a/arch/powerpc/include/asm/thread_info.h
+++ b/arch/powerpc/include/asm/thread_info.h
@@ -65,9 +65,6 @@ struct thread_info {
 	.flags =	0,			\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 #define THREAD_SIZE_ORDER	(THREAD_SHIFT - PAGE_SHIFT)
 
 /* how to get the thread information struct from C */
diff --git a/arch/s390/include/asm/thread_info.h b/arch/s390/include/asm/thread_info.h
index a5b54a445eb8..d494cca874fb 100644
--- a/arch/s390/include/asm/thread_info.h
+++ b/arch/s390/include/asm/thread_info.h
@@ -41,8 +41,6 @@ struct thread_info {
 	.flags		= 0,			\
 }
 
-#define init_stack		(init_thread_union.stack)
-
 void arch_release_task_struct(struct task_struct *tsk);
 int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src);
 
diff --git a/arch/score/include/asm/thread_info.h b/arch/score/include/asm/thread_info.h
index 7d9ffb15c477..b6136cd4deed 100644
--- a/arch/score/include/asm/thread_info.h
+++ b/arch/score/include/asm/thread_info.h
@@ -57,9 +57,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* How to get the thread information struct from C. */
 register struct thread_info *__current_thread_info __asm__("r28");
 #define current_thread_info()	__current_thread_info
diff --git a/arch/sh/include/asm/thread_info.h b/arch/sh/include/asm/thread_info.h
index 6c65dcd470ab..150f2fc60ffc 100644
--- a/arch/sh/include/asm/thread_info.h
+++ b/arch/sh/include/asm/thread_info.h
@@ -62,9 +62,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the current stack pointer from C */
 register unsigned long current_stack_pointer asm("r15") __used;
 
diff --git a/arch/sparc/include/asm/thread_info_32.h b/arch/sparc/include/asm/thread_info_32.h
index 229475f0d7ce..a119800b9323 100644
--- a/arch/sparc/include/asm/thread_info_32.h
+++ b/arch/sparc/include/asm/thread_info_32.h
@@ -62,9 +62,6 @@ struct thread_info {
 	.preempt_count	=	INIT_PREEMPT_COUNT,	\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 register struct thread_info *current_thread_info_reg asm("g6");
 #define current_thread_info()   (current_thread_info_reg)
diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index 38a24f257b85..3156e104c873 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -119,9 +119,6 @@ struct thread_info {
 	.preempt_count	=	INIT_PREEMPT_COUNT,	\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 register struct thread_info *current_thread_info_reg asm("g6");
 #define current_thread_info()	(current_thread_info_reg)
diff --git a/arch/tile/include/asm/thread_info.h b/arch/tile/include/asm/thread_info.h
index b7659b8f1117..2adcacd85749 100644
--- a/arch/tile/include/asm/thread_info.h
+++ b/arch/tile/include/asm/thread_info.h
@@ -59,9 +59,6 @@ struct thread_info {
 	.align_ctl	= 0,			\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 #endif /* !__ASSEMBLY__ */
 
 #if PAGE_SIZE < 8192
diff --git a/arch/um/include/asm/processor-generic.h b/arch/um/include/asm/processor-generic.h
index 2d1e0dd5bb0b..b24087825483 100644
--- a/arch/um/include/asm/processor-generic.h
+++ b/arch/um/include/asm/processor-generic.h
@@ -65,8 +65,6 @@ static inline void mm_copy_segments(struct mm_struct *from_mm,
 {
 }
 
-#define init_stack	(init_thread_union.stack)
-
 /*
  * User space process size: 3GB (default).
  */
diff --git a/arch/um/include/asm/thread_info.h b/arch/um/include/asm/thread_info.h
index 053baff03674..de24b261e6ac 100644
--- a/arch/um/include/asm/thread_info.h
+++ b/arch/um/include/asm/thread_info.h
@@ -34,9 +34,6 @@ struct thread_info {
 	.real_thread = NULL,			\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 #define THREAD_SIZE ((1 << CONFIG_KERNEL_STACK_ORDER) * PAGE_SIZE)
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
diff --git a/arch/unicore32/include/asm/thread_info.h b/arch/unicore32/include/asm/thread_info.h
index e79ad6d5b5b2..5fb728f3b49a 100644
--- a/arch/unicore32/include/asm/thread_info.h
+++ b/arch/unicore32/include/asm/thread_info.h
@@ -87,9 +87,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,					\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /*
  * how to get the thread information struct from C
  */
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index ad6f5eb07a95..90872c2cf39f 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -61,8 +61,6 @@ struct thread_info {
 	.flags		= 0,			\
 }
 
-#define init_stack		(init_thread_union.stack)
-
 #else /* !__ASSEMBLY__ */
 
 #include <asm/asm-offsets.h>
diff --git a/arch/xtensa/include/asm/thread_info.h b/arch/xtensa/include/asm/thread_info.h
index 7be2400f745a..2ccd37510aaa 100644
--- a/arch/xtensa/include/asm/thread_info.h
+++ b/arch/xtensa/include/asm/thread_info.h
@@ -77,9 +77,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
 {
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 7cdfe167074f..3c6757f67f14 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -252,7 +252,11 @@
 #define INIT_TASK_DATA(align)						\
 	. = ALIGN(align);						\
 	VMLINUX_SYMBOL(__start_init_task) = .;				\
+	VMLINUX_SYMBOL(init_thread_union) = .;				\
+	VMLINUX_SYMBOL(init_stack) = .;					\
 	*(.data..init_task)						\
+	*(.data..init_thread_info)					\
+	. = VMLINUX_SYMBOL(__start_init_task) + THREAD_SIZE;		\
 	VMLINUX_SYMBOL(__end_init_task) = .;
 
 /*
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 91d9049f0039..e889d338cf3e 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -294,5 +294,8 @@ extern struct cred init_cred;
 /* Attach to the init_task data structure for proper alignment */
 #define __init_task_data __attribute__((__section__(".data..init_task")))
 
+/* Attach to the thread_info data structure for proper alignment */
+#define __init_thread_info __attribute__((__section__(".data..init_thread_info")))
+
 
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d67eee84fd43..13ae8170721c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1353,12 +1353,21 @@ extern void ia64_set_curr_task(int cpu, struct task_struct *p);
 void yield(void);
 
 union thread_union {
+#ifndef CONFIG_ARCH_TASK_STRUCT_ON_STACK
+	struct task_struct task;
+#endif
 #ifndef CONFIG_THREAD_INFO_IN_TASK
 	struct thread_info thread_info;
 #endif
 	unsigned long stack[THREAD_SIZE/sizeof(long)];
 };
 
+#ifndef CONFIG_THREAD_INFO_IN_TASK
+extern struct thread_info init_thread_info;
+#endif
+
+extern unsigned long init_stack[THREAD_SIZE / sizeof(unsigned long)];
+
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 static inline struct thread_info *task_thread_info(struct task_struct *task)
 {
diff --git a/init/Makefile b/init/Makefile
index c4fb45525d08..007f5ac02ca5 100644
--- a/init/Makefile
+++ b/init/Makefile
@@ -12,9 +12,7 @@ obj-$(CONFIG_BLK_DEV_INITRD)   += initramfs.o
 endif
 obj-$(CONFIG_GENERIC_CALIBRATE_DELAY) += calibrate.o
 
-ifneq ($(CONFIG_ARCH_INIT_TASK),y)
 obj-y                          += init_task.o
-endif
 
 mounts-y			:= do_mounts.o
 mounts-$(CONFIG_BLK_DEV_RAM)	+= do_mounts_rd.o
diff --git a/init/init_task.c b/init/init_task.c
index 66787e30a419..14770aa71634 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -16,15 +16,17 @@ static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
 static struct sighand_struct init_sighand = INIT_SIGHAND(init_sighand);
 
 /* Initial task structure */
-struct task_struct init_task = INIT_TASK(init_task);
+struct task_struct init_task
+#ifdef CONFIG_ARCH_TASK_STRUCT_ON_STACK
+	__init_task_data
+#endif
+	= INIT_TASK(init_task);
 EXPORT_SYMBOL(init_task);
 
 /*
  * Initial thread structure. Alignment of this is handled by a special
  * linker map entry.
  */
-union thread_union init_thread_union __init_task_data = {
 #ifndef CONFIG_THREAD_INFO_IN_TASK
-	INIT_THREAD_INFO(init_task)
+struct thread_info init_thread_info __init_thread_info = INIT_THREAD_INFO(init_task);
 #endif
-};


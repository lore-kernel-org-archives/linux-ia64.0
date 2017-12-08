From: David Howells <dhowells@redhat.com>
Date: Fri, 08 Dec 2017 15:51:29 +0000
Subject: [PATCH 1/5] Construct init thread stack in the linker script rather than by union
Message-Id: <151274828931.9961.17801232134228415862.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
In-Reply-To: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org

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
 arch/blackfin/include/asm/thread_info.h   |    2 -
 arch/c6x/include/asm/thread_info.h        |    3 --
 arch/cris/include/asm/processor.h         |    2 -
 arch/cris/include/asm/thread_info.h       |    2 -
 arch/frv/include/asm/thread_info.h        |    3 --
 arch/h8300/include/asm/thread_info.h      |    3 --
 arch/hexagon/include/asm/thread_info.h    |    3 --
 arch/ia64/Kconfig                         |    2 +
 arch/ia64/Makefile                        |    2 +
 arch/ia64/include/asm/thread_info.h       |    4 +--
 arch/ia64/kernel/Makefile                 |    2 +
 arch/ia64/kernel/init_task.c              |   44 -----------------------------
 arch/ia64/kernel/vmlinux.lds.S            |    1 +
 arch/m32r/include/asm/thread_info.h       |    3 --
 arch/m68k/include/asm/thread_info.h       |    4 ---
 arch/metag/include/asm/thread_info.h      |    3 --
 arch/microblaze/include/asm/thread_info.h |    3 --
 arch/mips/include/asm/thread_info.h       |    3 --
 arch/mn10300/include/asm/thread_info.h    |    2 -
 arch/nios2/include/asm/thread_info.h      |    3 --
 arch/openrisc/include/asm/processor.h     |    2 -
 arch/openrisc/include/asm/thread_info.h   |    2 -
 arch/parisc/include/asm/thread_info.h     |    3 --
 arch/powerpc/include/asm/thread_info.h    |    3 --
 arch/s390/include/asm/thread_info.h       |    2 -
 arch/score/include/asm/thread_info.h      |    3 --
 arch/sh/include/asm/thread_info.h         |    3 --
 arch/sparc/include/asm/thread_info_32.h   |    3 --
 arch/sparc/include/asm/thread_info_64.h   |    3 --
 arch/tile/include/asm/thread_info.h       |    3 --
 arch/um/include/asm/processor-generic.h   |    5 +++
 arch/um/include/asm/thread_info.h         |    9 ++----
 arch/um/include/asm/vmlinux.lds.h         |    2 +
 arch/um/kernel/dyn.lds.S                  |    3 +-
 arch/um/kernel/um_arch.c                  |    2 +
 arch/um/kernel/uml.lds.S                  |    2 +
 arch/unicore32/include/asm/thread_info.h  |    3 --
 arch/x86/include/asm/thread_info.h        |    2 -
 arch/xtensa/include/asm/thread_info.h     |    3 --
 include/asm-generic/vmlinux.lds.h         |    4 +++
 include/linux/init_task.h                 |    3 ++
 include/linux/sched.h                     |    9 ++++++
 init/Makefile                             |    2 -
 init/init_task.c                          |   10 ++++---
 49 files changed, 42 insertions(+), 153 deletions(-)
 delete mode 100644 arch/ia64/kernel/init_task.c
 create mode 100644 arch/um/include/asm/vmlinux.lds.h

diff --git a/arch/Kconfig b/arch/Kconfig
index 400b9e1b2f27..a26d6f8ab967 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -234,8 +234,8 @@ config ARCH_HAS_FORTIFY_SOURCE
 config ARCH_HAS_SET_MEMORY
 	bool
 
-# Select if arch init_task initializer is different to init/init_task.c
-config ARCH_INIT_TASK
+# Select if arch init_task must go in the __init_task_data section
+config ARCH_TASK_STRUCT_ON_STACK
        bool
 
 # Select if arch has its private alloc_task_struct() function
diff --git a/arch/alpha/include/asm/thread_info.h b/arch/alpha/include/asm/thread_info.h
index 8c20c5e35432..807d7b9a1860 100644
--- a/arch/alpha/include/asm/thread_info.h
+++ b/arch/alpha/include/asm/thread_info.h
@@ -39,9 +39,6 @@ struct thread_info {
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
index eb431286bacd..740aa03c5f0d 100644
--- a/arch/arm64/include/asm/thread_info.h
+++ b/arch/arm64/include/asm/thread_info.h
@@ -51,8 +51,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,					\
 }
 
-#define init_stack		(init_thread_union.stack)
-
 #define thread_saved_pc(tsk)	\
 	((unsigned long)(tsk->thread.cpu_context.pc))
 #define thread_saved_sp(tsk)	\
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
index 124dd5ec7f65..137f6159214d 100644
--- a/arch/cris/include/asm/processor.h
+++ b/arch/cris/include/asm/processor.h
@@ -59,8 +59,6 @@ static inline void release_thread(struct task_struct *dead_task)
         /* Nothing needs to be done.  */
 }
 
-#define init_stack      (init_thread_union.stack)
-
 #define cpu_relax()     barrier()
 
 void default_idle(void);
diff --git a/arch/cris/include/asm/thread_info.h b/arch/cris/include/asm/thread_info.h
index 472830c90997..0f9218397deb 100644
--- a/arch/cris/include/asm/thread_info.h
+++ b/arch/cris/include/asm/thread_info.h
@@ -56,8 +56,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,			\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-
 #endif /* !__ASSEMBLY__ */
 
 /*
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
index 072b92c0d8b5..0cdaa302d3d2 100644
--- a/arch/h8300/include/asm/thread_info.h
+++ b/arch/h8300/include/asm/thread_info.h
@@ -46,9 +46,6 @@ struct thread_info {
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
index 49583c5a5d44..315c51f58811 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -43,7 +43,7 @@ config IA64
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
index 1d172a4119a7..64a1011f6812 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -12,6 +12,8 @@
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 
+#define THREAD_SIZE			KERNEL_STACK_SIZE
+
 #ifndef __ASSEMBLY__
 
 /*
@@ -41,8 +43,6 @@ struct thread_info {
 #endif
 };
 
-#define THREAD_SIZE			KERNEL_STACK_SIZE
-
 #define INIT_THREAD_INFO(tsk)			\
 {						\
 	.task		= &tsk,			\
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 14ad79f394e5..0b4c65a1af25 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -7,7 +7,7 @@ ifdef CONFIG_DYNAMIC_FTRACE
 CFLAGS_REMOVE_ftrace.o = -pg
 endif
 
-extra-y	:= head.o init_task.o vmlinux.lds
+extra-y	:= head.o vmlinux.lds
 
 obj-y := entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o sal.o		\
diff --git a/arch/ia64/kernel/init_task.c b/arch/ia64/kernel/init_task.c
deleted file mode 100644
index 8df9245e29d9..000000000000
--- a/arch/ia64/kernel/init_task.c
+++ /dev/null
@@ -1,44 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
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
index 58db59da0bd8..b0b2070e0591 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -3,6 +3,7 @@
 #include <asm/cache.h>
 #include <asm/ptrace.h>
 #include <asm/pgtable.h>
+#include <asm/thread_info.h>
 
 #include <asm-generic/vmlinux.lds.h>
 
diff --git a/arch/m32r/include/asm/thread_info.h b/arch/m32r/include/asm/thread_info.h
index b3a215b0ce0a..ba00f1032587 100644
--- a/arch/m32r/include/asm/thread_info.h
+++ b/arch/m32r/include/asm/thread_info.h
@@ -56,9 +56,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
 {
diff --git a/arch/m68k/include/asm/thread_info.h b/arch/m68k/include/asm/thread_info.h
index 928035591f2e..015f1ca38305 100644
--- a/arch/m68k/include/asm/thread_info.h
+++ b/arch/m68k/include/asm/thread_info.h
@@ -41,8 +41,6 @@ struct thread_info {
 	.preempt_count	= INIT_PREEMPT_COUNT,	\
 }
 
-#define init_stack		(init_thread_union.stack)
-
 #ifndef __ASSEMBLY__
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
@@ -58,8 +56,6 @@ static inline struct thread_info *current_thread_info(void)
 }
 #endif
 
-#define init_thread_info	(init_thread_union.thread_info)
-
 /* entry.S relies on these definitions!
  * bits 0-7 are tested at every exception exit
  * bits 8-15 are also tested at syscall exit
diff --git a/arch/metag/include/asm/thread_info.h b/arch/metag/include/asm/thread_info.h
index 554f73a77e6e..a1a9c7f5ca8c 100644
--- a/arch/metag/include/asm/thread_info.h
+++ b/arch/metag/include/asm/thread_info.h
@@ -74,9 +74,6 @@ struct thread_info {
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
index 5e8927f99a76..4993db40482c 100644
--- a/arch/mips/include/asm/thread_info.h
+++ b/arch/mips/include/asm/thread_info.h
@@ -49,9 +49,6 @@ struct thread_info {
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
index 396d8f306c21..af31a9fe736a 100644
--- a/arch/openrisc/include/asm/processor.h
+++ b/arch/openrisc/include/asm/processor.h
@@ -84,8 +84,6 @@ void start_thread(struct pt_regs *regs, unsigned long nip, unsigned long sp);
 void release_thread(struct task_struct *);
 unsigned long get_wchan(struct task_struct *p);
 
-#define init_stack      (init_thread_union.stack)
-
 #define cpu_relax()     barrier()
 
 #endif /* __ASSEMBLY__ */
diff --git a/arch/openrisc/include/asm/thread_info.h b/arch/openrisc/include/asm/thread_info.h
index c229aa6bb502..5c15dfa2fd4f 100644
--- a/arch/openrisc/include/asm/thread_info.h
+++ b/arch/openrisc/include/asm/thread_info.h
@@ -79,8 +79,6 @@ struct thread_info {
 	.ksp            = 0,                            \
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-
 /* how to get the thread information struct from C */
 register struct thread_info *current_thread_info_reg asm("r10");
 #define current_thread_info()   (current_thread_info_reg)
diff --git a/arch/parisc/include/asm/thread_info.h b/arch/parisc/include/asm/thread_info.h
index c980a02a52bc..f6e9c56f0e1b 100644
--- a/arch/parisc/include/asm/thread_info.h
+++ b/arch/parisc/include/asm/thread_info.h
@@ -25,9 +25,6 @@ struct thread_info {
 	.preempt_count	= INIT_PREEMPT_COUNT,	\
 }
 
-#define init_thread_info        (init_thread_union.thread_info)
-#define init_stack              (init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 #define current_thread_info()	((struct thread_info *)mfctl(30))
 
diff --git a/arch/powerpc/include/asm/thread_info.h b/arch/powerpc/include/asm/thread_info.h
index a264c3ad366b..4a12c00f8de3 100644
--- a/arch/powerpc/include/asm/thread_info.h
+++ b/arch/powerpc/include/asm/thread_info.h
@@ -58,9 +58,6 @@ struct thread_info {
 	.flags =	0,			\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 #define THREAD_SIZE_ORDER	(THREAD_SHIFT - PAGE_SHIFT)
 
 /* how to get the thread information struct from C */
diff --git a/arch/s390/include/asm/thread_info.h b/arch/s390/include/asm/thread_info.h
index 0880a37b6d3b..25d6ec3aaddd 100644
--- a/arch/s390/include/asm/thread_info.h
+++ b/arch/s390/include/asm/thread_info.h
@@ -42,8 +42,6 @@ struct thread_info {
 	.flags		= 0,			\
 }
 
-#define init_stack		(init_thread_union.stack)
-
 void arch_release_task_struct(struct task_struct *tsk);
 int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src);
 
diff --git a/arch/score/include/asm/thread_info.h b/arch/score/include/asm/thread_info.h
index ad51b56e51bd..bc4c7c90550f 100644
--- a/arch/score/include/asm/thread_info.h
+++ b/arch/score/include/asm/thread_info.h
@@ -58,9 +58,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* How to get the thread information struct from C. */
 register struct thread_info *__current_thread_info __asm__("r28");
 #define current_thread_info()	__current_thread_info
diff --git a/arch/sh/include/asm/thread_info.h b/arch/sh/include/asm/thread_info.h
index becb798f1b04..cf5c792bf70b 100644
--- a/arch/sh/include/asm/thread_info.h
+++ b/arch/sh/include/asm/thread_info.h
@@ -63,9 +63,6 @@ struct thread_info {
 	.addr_limit	= KERNEL_DS,		\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the current stack pointer from C */
 register unsigned long current_stack_pointer asm("r15") __used;
 
diff --git a/arch/sparc/include/asm/thread_info_32.h b/arch/sparc/include/asm/thread_info_32.h
index febaaeb1a0fe..548b366165dd 100644
--- a/arch/sparc/include/asm/thread_info_32.h
+++ b/arch/sparc/include/asm/thread_info_32.h
@@ -63,9 +63,6 @@ struct thread_info {
 	.preempt_count	=	INIT_PREEMPT_COUNT,	\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
 /* how to get the thread information struct from C */
 register struct thread_info *current_thread_info_reg asm("g6");
 #define current_thread_info()   (current_thread_info_reg)
diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index caf915321ba9..f7e7b0baec9f 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -120,9 +120,6 @@ struct thread_info {
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
index 86942a492454..b58b746d3f2c 100644
--- a/arch/um/include/asm/processor-generic.h
+++ b/arch/um/include/asm/processor-generic.h
@@ -58,7 +58,10 @@ static inline void release_thread(struct task_struct *task)
 {
 }
 
-#define init_stack	(init_thread_union.stack)
+static inline void mm_copy_segments(struct mm_struct *from_mm,
+				    struct mm_struct *new_mm)
+{
+}
 
 /*
  * User space process size: 3GB (default).
diff --git a/arch/um/include/asm/thread_info.h b/arch/um/include/asm/thread_info.h
index 9300f7630d2a..4eecd960ee8c 100644
--- a/arch/um/include/asm/thread_info.h
+++ b/arch/um/include/asm/thread_info.h
@@ -6,6 +6,9 @@
 #ifndef __UM_THREAD_INFO_H
 #define __UM_THREAD_INFO_H
 
+#define THREAD_SIZE_ORDER CONFIG_KERNEL_STACK_ORDER
+#define THREAD_SIZE ((1 << CONFIG_KERNEL_STACK_ORDER) * PAGE_SIZE)
+
 #ifndef __ASSEMBLY__
 
 #include <asm/types.h>
@@ -37,10 +40,6 @@ struct thread_info {
 	.real_thread = NULL,			\
 }
 
-#define init_thread_info	(init_thread_union.thread_info)
-#define init_stack		(init_thread_union.stack)
-
-#define THREAD_SIZE ((1 << CONFIG_KERNEL_STACK_ORDER) * PAGE_SIZE)
 /* how to get the thread information struct from C */
 static inline struct thread_info *current_thread_info(void)
 {
@@ -53,8 +52,6 @@ static inline struct thread_info *current_thread_info(void)
 	return ti;
 }
 
-#define THREAD_SIZE_ORDER CONFIG_KERNEL_STACK_ORDER
-
 #endif
 
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
diff --git a/arch/um/include/asm/vmlinux.lds.h b/arch/um/include/asm/vmlinux.lds.h
new file mode 100644
index 000000000000..149494ae78ea
--- /dev/null
+++ b/arch/um/include/asm/vmlinux.lds.h
@@ -0,0 +1,2 @@
+#include <asm/thread_info.h>
+#include <asm-generic/vmlinux.lds.h>
diff --git a/arch/um/kernel/dyn.lds.S b/arch/um/kernel/dyn.lds.S
index d417e3899700..5568cf882371 100644
--- a/arch/um/kernel/dyn.lds.S
+++ b/arch/um/kernel/dyn.lds.S
@@ -1,5 +1,4 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#include <asm-generic/vmlinux.lds.h>
+#include <asm/vmlinux.lds.h>
 #include <asm/page.h>
 
 OUTPUT_FORMAT(ELF_FORMAT)
diff --git a/arch/um/kernel/um_arch.c b/arch/um/kernel/um_arch.c
index f433690b9b37..a818ccef30ca 100644
--- a/arch/um/kernel/um_arch.c
+++ b/arch/um/kernel/um_arch.c
@@ -54,7 +54,7 @@ struct cpuinfo_um boot_cpu_data = {
 
 union thread_union cpu0_irqstack
 	__attribute__((__section__(".data..init_irqstack"))) -		{ INIT_THREAD_INFO(init_task) };
+		{ .thread_info = INIT_THREAD_INFO(init_task) };
 
 /* Changed in setup_arch, which is called in early boot */
 static char host_info[(__NEW_UTS_LEN + 1) * 5];
diff --git a/arch/um/kernel/uml.lds.S b/arch/um/kernel/uml.lds.S
index 3d6ed6ba5b78..36b07ec09742 100644
--- a/arch/um/kernel/uml.lds.S
+++ b/arch/um/kernel/uml.lds.S
@@ -1,5 +1,5 @@
 /* SPDX-License-Identifier: GPL-2.0 */
-#include <asm-generic/vmlinux.lds.h>
+#include <asm/vmlinux.lds.h>
 #include <asm/page.h>
 
 OUTPUT_FORMAT(ELF_FORMAT)
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
index 70f425947dc5..5f4cf6586a50 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -62,8 +62,6 @@ struct thread_info {
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
index ee8b707d9fa9..a564b83bf013 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -268,7 +268,11 @@
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
index 6a532629c983..30a89b99a5af 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -304,5 +304,8 @@ extern struct cred init_cred;
 /* Attach to the init_task data structure for proper alignment */
 #define __init_task_data __attribute__((__section__(".data..init_task")))
 
+/* Attach to the thread_info data structure for proper alignment */
+#define __init_thread_info __attribute__((__section__(".data..init_thread_info")))
+
 
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 21991d668d35..b8b23f5b31a6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1457,12 +1457,21 @@ extern void ia64_set_curr_task(int cpu, struct task_struct *p);
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
index 1dbb23787290..a3e5ce2bcf08 100644
--- a/init/Makefile
+++ b/init/Makefile
@@ -13,9 +13,7 @@ obj-$(CONFIG_BLK_DEV_INITRD)   += initramfs.o
 endif
 obj-$(CONFIG_GENERIC_CALIBRATE_DELAY) += calibrate.o
 
-ifneq ($(CONFIG_ARCH_INIT_TASK),y)
 obj-y                          += init_task.o
-endif
 
 mounts-y			:= do_mounts.o
 mounts-$(CONFIG_BLK_DEV_RAM)	+= do_mounts_rd.o
diff --git a/init/init_task.c b/init/init_task.c
index 9325fee7dc82..2285aa42cbe1 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -17,15 +17,17 @@ static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
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


From: Robin Holt <holt@sgi.com>
Date: Tue, 06 Dec 2005 02:02:31 +0000
Subject: [Patch 1/1] Change SET_PERSONALITY to comply with comment in binfmt_elf.c.
Message-Id: <20051206020231.GA25396@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have a customer application which trips a bug.  The problem arises
when a driver attempts to call do_munmap on an area which is mapped, but
because current->thread.task_size has been set to 0xC0000000, the call
to do_munmap fails thinking it is an unmap beyond the user's address
space.

The comment in fs/binfmt_elf.c in load_elf_library() before the call
to SET_PERSONALITY() indicates that task_size must not be changed for
the running application until flush_thread, but is for ia64 executing
ia32 binaries.

This patch moves the setting of task_size from SET_PERSONALITY() to
flush_thread() as indicated.  The customer application no longer is able
to trip the bug.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: linux-2.6/arch/ia64/ia32/ia32priv.h
=================================--- linux-2.6.orig/arch/ia64/ia32/ia32priv.h	2005-11-09 10:53:59.000000000 -0600
+++ linux-2.6/arch/ia64/ia32/ia32priv.h	2005-12-05 16:08:27.413575723 -0600
@@ -305,7 +305,6 @@ struct old_linux32_dirent {
 #define ELF_DATA	ELFDATA2LSB
 #define ELF_ARCH	EM_386
 
-#define IA32_PAGE_OFFSET	0xc0000000
 #define IA32_STACK_TOP		IA32_PAGE_OFFSET
 #define IA32_GATE_OFFSET	IA32_PAGE_OFFSET
 #define IA32_GATE_END		IA32_PAGE_OFFSET + PAGE_SIZE
Index: linux-2.6/include/asm-ia64/ia32.h
=================================--- linux-2.6.orig/include/asm-ia64/ia32.h	2005-11-09 10:54:11.000000000 -0600
+++ linux-2.6/include/asm-ia64/ia32.h	2005-12-05 16:08:25.701815335 -0600
@@ -13,6 +13,8 @@
 
 # ifdef CONFIG_IA32_SUPPORT
 
+#define IA32_PAGE_OFFSET	0xc0000000
+
 extern void ia32_cpu_init (void);
 extern void ia32_mem_init (void);
 extern void ia32_gdt_init (void);
Index: linux-2.6/arch/ia64/ia32/binfmt_elf32.c
=================================--- linux-2.6.orig/arch/ia64/ia32/binfmt_elf32.c	2005-11-09 10:53:59.000000000 -0600
+++ linux-2.6/arch/ia64/ia32/binfmt_elf32.c	2005-12-05 19:43:09.471600081 -0600
@@ -261,8 +261,6 @@ elf32_set_personality (void)
 {
 	set_personality(PER_LINUX32);
 	current->thread.map_base  = IA32_PAGE_OFFSET/3;
-	current->thread.task_size = IA32_PAGE_OFFSET;	/* use what Linux/x86 uses... */
-	set_fs(USER_DS);				/* set addr limit for new TASK_SIZE */
 }
 
 static unsigned long
Index: linux-2.6/arch/ia64/kernel/process.c
=================================--- linux-2.6.orig/arch/ia64/kernel/process.c	2005-11-23 19:05:46.000000000 -0600
+++ linux-2.6/arch/ia64/kernel/process.c	2005-12-05 19:43:10.834749298 -0600
@@ -721,8 +721,11 @@ flush_thread (void)
 	/* drop floating-point and debug-register state if it exists: */
 	current->thread.flags &= ~(IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID);
 	ia64_drop_fpu(current);
-	if (IS_IA32_PROCESS(ia64_task_regs(current)))
+	if (IS_IA32_PROCESS(ia64_task_regs(current))) {
 		ia32_drop_partial_page_list(current);
+		current->thread.task_size = IA32_PAGE_OFFSET;
+		set_fs(USER_DS);
+	}
 }
 
 /*

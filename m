From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 18:25:19 +0000
Subject: [Linux-ia64] fix for user-level i/o-base corruption
Message-Id: <marc-linux-ia64-105590693005969@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I found that the I/O base in ar.k0 was wrong on my systems.  This
turns out to be due to a bug in the ia32 subsystem: it fails to reset
the original i/o-base address when execve'ing an IA-64 program.  The
patch below fixes this.

I wonder whether this bug may be the root of the crashes that
occasionally occur when switching from XFree86 to a virtual consoles.

	--david

--- lia64/arch/ia64/ia32/sys_ia32.c	Mon Jul 23 14:00:32 2001
+++ lia64-kdb/arch/ia64/ia32/sys_ia32.c	Tue Jul 31 10:59:16 2001
@@ -124,14 +124,16 @@
 	old_map_base  = current->thread.map_base;
 	old_task_size = current->thread.task_size;
 
-	/* we may be exec'ing a 64-bit process: reset map base & task-size: */
+	/* we may be exec'ing a 64-bit process: reset map base, task-size, and io-base: */
 	current->thread.map_base  = DEFAULT_MAP_BASE;
 	current->thread.task_size = DEFAULT_TASK_SIZE;
+	ia64_set_kr(IA64_KR_IO_BASE, current->thread.old_iob);
 
 	set_fs(KERNEL_DS);
 	r = sys_execve(filename, av, ae, regs);
 	if (r < 0) {
-		/* oops, execve failed, switch back to old map base & task-size: */
+		/* oops, execve failed, switch back to old values... */
+		ia64_set_kr(IA64_KR_IO_BASE, IA32_IOBASE);
 		current->thread.map_base  = old_map_base;
 		current->thread.task_size = old_task_size;
 		set_fs(USER_DS);	/* establish new task-size as the address-limit */
@@ -2612,7 +2614,6 @@
 	up_write(&current->mm->mmap_sem);
 
 	if (addr >= 0) {
-		ia64_set_kr(IA64_KR_IO_BASE, addr);
 		old = (old & ~0x3000) | (level << 12);
 		__asm__ __volatile__("mov ar.eflag=%0 ;;" :: "r"(old));
 	}


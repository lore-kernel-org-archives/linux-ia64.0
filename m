From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 13 Sep 2001 18:25:32 +0000
Subject: [Linux-ia64] Re: Issue with using execlp() from a 32 bit binary on IA64
Message-Id: <marc-linux-ia64-105590698805176@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 Sep 2001 14:14:43 -0400, Venkatesh Ramamurthy <Venkateshr@ami.com> said:

  Venkatesh> Hi, The RAID group has a problem with using execlp
  Venkatesh> function from a 32bit binary.  The problem goes like this
  Venkatesh> , a test program "TestCtrl"(A) and "TestServ"(B) are the
  Venkatesh> two binaries. Initially both 'A' and 'B' are 32 bit
  Venkatesh> binaries. 'A' loads 'B' using execlp. 'A' loads during
  Venkatesh> system startup. The system boots to text mode. When i do
  Venkatesh> a 'startx', the X-window system hangs up. The last thing
  Venkatesh> i see is 'RAGE 128 .....' and hangs.

Sounds like you're using an old kernel.  There was a problem with
ar.k0 getting corrupted by the ia32 subsystem.  I fixed that around
2.4.8 or thereabouts.  The original mail reporting the problem and a
fix is attached below.  You might want to upgrade to 2.4.9 though.

	--david

-------------------------------------------------------------------
From: David Mosberger <davidm@hpl.hp.com>
Sender: linux-ia64-admin@linuxia64.org
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] fix for user-level i/o-base corruption
Date: Tue, 31 Jul 2001 11:25:19 -0700
Reply-To: davidm@hpl.hp.com
X-URL: http://www.hpl.hp.com/personal/David_Mosberger/

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

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


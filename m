From: Don Dugger <n0ano@valinux.com>
Date: Tue, 08 May 2001 22:12:30 +0000
Subject: [Linux-ia64] Fix two IA32 bugs.
MIME-Version: 1
Content-Type: multipart/mixed; boundary="7JfCtLOvnd9MIVvH"
Message-Id: <marc-linux-ia64-105590693005550@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii

David-

Here's a patch, against the 2.4.3 kernel + the 0405 IA64 patch + the
LDT patch, that fixes two IA32 buglets:

1)  A typo in `siginfo64to32' caught by Dave Engebretsen.  I can only
assume that this code is never called because otherwise the bug should
have caused the kernel to dereference location 0.

2)  Initialize the IA32 registers on process startup.  This should fix
the problem you were seeing where the JAVA JRE was not terminating
properly.  Since EDX was not being initialized the IA32 exit code could
have been jumping into never-never land.

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_0507.l"

--- linux-2.4.3-ia64/arch/ia64/ia32/binfmt_elf32.c	Mon May  7 08:40:48 2001
+++ kernel-bigsur/arch/ia64/ia32/binfmt_elf32.c	Fri May  4 15:46:04 2001
@@ -157,6 +157,19 @@
 	current->thread.tssd = IA32_SEG_UNSCRAMBLE(ia32_gdt_table[_TSS(nr)]);
 
 	ia32_load_state(current);
+	/*
+	 *  According to the ABI %edx points to an `atexit' handler.
+	 *  Since we don't have one we'll set it to 0 and initialize
+	 *  all the other registers just to make things more deterministic,
+	 *  ala the i386 implementation.
+	 */
+	regs->r8 = 0;	/* %eax */
+	regs->r11 = 0;	/* %ebx */
+	regs->r9 = 0;	/* %ecx */
+	regs->r10 = 0;	/* %edx */
+	regs->r13 = 0;	/* %ebp */
+	regs->r14 = 0;	/* %esi */
+	regs->r15 = 0;	/* %edi */
 }
 
 int
--- linux-2.4.3-ia64/arch/ia64/ia32/sys_ia32.c	2001/04/19 20:43:31
+++ kernel-bigsur/arch/ia64/ia32/sys_ia32.c	2001/05/08 21:58:08
@@ -3230,7 +3230,7 @@
 siginfo_t32 *
 siginfo64to32(siginfo_t32 *d, siginfo_t *s)
 {
-	memset (&d, 0, sizeof(siginfo_t32));
+	memset (d, 0, sizeof(siginfo_t32));
 	d->si_signo = s->si_signo;
 	d->si_errno = s->si_errno;
 	d->si_code = s->si_code;

--7JfCtLOvnd9MIVvH--


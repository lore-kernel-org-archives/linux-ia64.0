From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 17 Jan 2001 21:06:17 +0000
Subject: [Linux-ia64] strace fix for 32-bit exeve()
Message-Id: <marc-linux-ia64-105590693005069@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a quick hack that makes it possible to trace an x86 execve()
on an IA-64 machine without getting completely garbled output.  It
also adds a sanity check to prevent strace from crashing when the
system call number is garbage.  With these hacks in place, I was able
to strace an x86 program as it was execve'ing an IA-64 program.  The
output wasn't completely correct (there is a bogus syscall number
after the execve() and the result values are incorrect for the IA-64
syscalls), but at least this patch illustrates where some of the
problems lie.

Note that the changes to process.c are just a quick hack and should
not be used as is.  The clean solution would be to maintain a
"target_pointer_size" inside strace and use that to determine how many
bytes to read for a pointer stored in memory.  Note that while the
patche fixes the reading of the argv[] and envp[] pointers for
execve(), there are certainly other places where pointers are being
read from memory and those would have to be fixed, too.  Also, the
code below isn't endian clean: it wouldn't work on big-endian
machines.

On a related note, it might also be helpful to prefix the syscall
names with "x86_" when operating in IA-32 mode.  Otherwise, the only
way to tell whether you're dealing with IA-64 or x86 code is by
looking for addresses and checking whether they're above or below 4GB.

I'm unhappy to be sending out such an incomplete (useless?) patch, but
I'm hoping someone else interested in this can find the time needed to
do this right.  strace is just such an incredibly useful debugging
tool that I think it would be well worth to do this properly.

	--david

--- strace-000425/syscall.c	Mon Apr 10 19:00:06 2000
+++ strace/syscall.c	Wed Jan 17 03:12:06 2001
@@ -627,9 +627,10 @@
 		return -1;
 #elif defined(IA64)
 #define IA64_PSR_IS	((long)1 << 34)
-	if (upeek (pid, PT_CR_IPSR, &psr) >= 0)
-		ia32 = (psr & IA64_PSR_IS);
 	if (!(tcp->flags & TCB_INSYSCALL)) {
+		if (upeek (pid, PT_CR_IPSR, &psr) >= 0)
+			ia32 = (psr & IA64_PSR_IS);
+
 		if (ia32) {
 			if (upeek(pid, PT_R8, &scno) < 0)
 				return -1;
@@ -637,6 +638,9 @@
 			if (upeek (pid, PT_R15, &scno) < 0)
 				return -1;
 		}
+
+		if (scno > nsyscalls)
+			scno = 0;
 	} else {
 		/* syscall in progress */
 		if (upeek (pid, PT_R8, &r8) < 0)
--- strace-000425/process.c	Mon Apr 24 19:00:11 2000
+++ strace/process.c	Wed Jan 17 03:08:30 2001
@@ -62,6 +62,7 @@
 #include <linux/ptrace.h>
 #endif
 
+extern long ia32;
 
 #ifdef LINUX
 #include <asm/posix_types.h>
@@ -960,12 +1017,18 @@
 {
 	char *cp;
 	char *sep;
-	int max = max_strlen / 2;
+	int max = max_strlen / 2, addrsize = sizeof(char *);
+
+	if (ia32) {
+		addrsize = 4;
+		addr &= 0xffffffff;
+	}
 
 	for (sep = ""; --max >= 0; sep = ", ") {
 		if (!abbrev(tcp))
 			max++;
-		if (umove(tcp, addr, &cp) < 0) {
+		cp = 0;
+		if (umoven(tcp, addr, addrsize, &cp) < 0) {
 			tprintf("%#lx", addr);
 			return;
 		}
@@ -973,7 +1036,7 @@
 			break;
 		tprintf(sep);
 		printstr(tcp, (long) cp, -1);
-		addr += sizeof(char *);
+		addr += addrsize;
 	}
 	if (cp)
 		tprintf(", ...");
@@ -985,11 +1048,17 @@
 struct tcb *tcp;
 long addr;
 {
-	int count;
+	int count = 0, addrsize = sizeof(char *);
 	char *cp;
 
-	for (count = 0; umove(tcp, addr, &cp) >= 0 && cp != NULL; count++) {
-		addr += sizeof(char *);
+	if (ia32) {
+		addr &= 0xffffffff;
+		addrsize = 4;
+	}
+
+	if (addr) {
+		for (; cp = 0, umoven(tcp, addr, addrsize, &cp) >= 0 && cp != NULL; count++)
+			addr += addrsize;
 	}
 	tprintf(fmt, count, count = 1 ? "" : "s");
 }


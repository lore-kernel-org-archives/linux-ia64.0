From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 31 Dec 2003 20:19:20 +0000
Subject: make inferior calls work on ia64 even when syscall is pending
Message-Id: <16371.12104.503371.251351@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Problem:

 $ cat t.c
 int main () {
   char ch;
   return read(0, &ch, 1);
 }
 $ gcc -g t.c
 $ gdb a.out
 GNU gdb 6.0-debian
 Copyright 2003 Free Software Foundation, Inc.
 GDB is free software, covered by the GNU General Public License, and you are
 welcome to change it and/or distribute copies of it under certain conditions.
 Type "show copying" to see the conditions.
 There is absolutely no warranty for GDB.  Type "show warranty" for details.
 This GDB was configured as "ia64-linux"...
 (gdb) r
 Starting program: /home/davidm/tmp/a.out

 [user hits Ctrl-C]

 Program received signal SIGINT, Interrupt.
 0x20000000001cc401 in read () from /lib/tls/libc.so.6.1
 (gdb) call write(1, "hello\n", 6)

 Program received signal SIGSEGV, Segmentation fault.
 0x2000000000020650 in __libc_memalign () from /lib/ld-linux-ia64.so.2
 The program being debugged was signaled while in a function called from GDB.
 GDB remains in the frame where the signal was received.
 To change this behavior use "set unwindonsignal on"
 Evaluation of the expression containing the function (malloc) will be abandoned.
 (gdb)

The attached patch below fixes this problem.  It took me a while to
understand what's going on, but in retrospect, the situation is
completely analogous to x86 linux: when interrupting execution in a
restartable syscall, gdb needs to cancel restarting of the syscall
before it can run an inferior call.  Otherwise, instead of executing
at the desired IP, we'll end up calling IP-1 (in my test-case, this
ended up calling into the tail of memalign, when the intended target
was malloc() to allocate memory for the string "hello\n"...).

The fix is for gdb to clear r10 when changing the IP.  This will
ensure that the kernel won't treat the value in r8 as an error-code
and effectively cancels the system-call restart.

It turns out that the kernel also needs a small patch, because it
currently checks r10 _before_ waking up the debugger, so that there
was no way for the debugger to cancel system-call restart.  See this
patch:

	http://lia64.bkbits.net:8080/to-linus-2.5/patch@1.1513

(Bjorn, this is also needed for Linux v2.4.)

With both the kernel and gdb fixed, I see four new passes in the
GDB test-suite:

+PASS: gdb.base/interrupt.exp: call function when asleep
+PASS: gdb.base/interrupt.exp: call function a second time
+PASS: gdb.base/interrupt.exp: continue
+PASS: gdb.base/interrupt.exp: send end of file
                == gdb Summary =
-# of expected passes           9928
+# of expected passes           9932
 # of unexpected failures       119
 # of unexpected successes      4
 # of expected failures         58

If the gdb patch looks OK, please check it in.

Thanks!

	--david

2003-12-31  David Mosberger  <davidm@hpl.hp.com>

	* ia64-tdep.c (ia64_write_pc): Clear r10 after writing the
	instruction-pointer (PC) to prevent the kernel from attempting to
	restart an interrupt system call.

Index: ia64-tdep.c
=================================RCS file: /cvs/src/src/gdb/ia64-tdep.c,v
retrieving revision 1.106
diff -u -r1.106 ia64-tdep.c
--- ia64-tdep.c	13 Dec 2003 03:51:56 -0000	1.106
+++ ia64-tdep.c	31 Dec 2003 19:49:49 -0000
@@ -683,6 +683,17 @@
 
   write_register_pid (IA64_PSR_REGNUM, psr_value, ptid);
   write_register_pid (IA64_IP_REGNUM, new_pc, ptid);
+
+  /* We must be careful with modifying the instruction-pointer: if we
+     just interrupt a system call, the kernel would ordinarily try to
+     restart it when we resume the inferior, which typically results
+     in SIGSEGV or SIGILL.  We prevent this by clearing r10, which
+     will tell the kernel that r8 does NOT contain a valid error code
+     and hence it will skip system-call restart.
+
+     The clearing of r10 is safe as long as ia64_write_pc() is only
+     called as part of setting up an inferior call.  */
+  write_register (IA64_GR10_REGNUM, 0);
 }
 
 #define IS_NaT_COLLECTION_ADDR(addr) ((((addr) >> 3) & 0x3f) = 0x3f)

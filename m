From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 29 Apr 2002 21:40:32 +0000
Subject: [Linux-ia64] [patch] small but important change
Message-Id: <marc-linux-ia64-105590701905540@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Attached below is a one-liner that you may need to successfully build
glibc.  Without this change, you may see "make check" in the glibc
build fail with "out of memory" error messages.  The problem is due to
the fact that ld.so, when invoked directly, had only 16MB of virtual
memory available before bumping into the ld.so image.  Eventually,
this would cause brk() to fail.

The fix below is to increase ELF_ET_DYN_BASE to give up to 32GB of
virtual memory.  Of course, you can still come up with test cases
where there would be a conflict, but in practice, 32GB should carry us
for a long time (and the fundamental problem is inherent in the UNIX
process model).  An alternative would be to place a directly-invoked
loader in a different region, but I want to avoid that to minimize the
number of user regions that the kernel requires for proper operation.
Note that this issue comes up only when invoking relocatable ELF
binaries (such as ld.so).  With normal binaries, this issue won't
occur because the break value ends up in region 3.

NOTE TO DISTRIBUTORS: I'd like to encourage all distributions to
include this change in the kernel used for the next distro release.
It should be completely safe and avoids confusing errors during glibc
builds (there may be other cases where this pops up, though I'm not
aware of any).

	--david

--- include/asm-ia64/elf.h~	Mon Apr 22 19:54:07 2002
+++ include/asm-ia64/elf.h	Mon Apr 29 14:03:34 2002
@@ -39,7 +39,7 @@
  * the way of the program that it will "exec", and that there is
  * sufficient room for the brk.
  */
-#define ELF_ET_DYN_BASE		(TASK_UNMAPPED_BASE + 0x1000000)
+#define ELF_ET_DYN_BASE		(TASK_UNMAPPED_BASE + 0x800000000)
 
 
 /*


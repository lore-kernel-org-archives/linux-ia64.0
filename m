From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 08 Feb 2002 03:30:35 +0000
Subject: [Linux-ia64] small but important fix for clone2()
Message-Id: <marc-linux-ia64-105590698806024@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a longstanding and silly bug in clone2() which can lead to
memory corruption.  The problem is that when the user-stack area is
specified explicitly (as is the case during pthread creation),
clone2() failed to allocate the scratch space required by the calling
convention.  The patch below fixes this.

Thanks to Asit Mallick for tracking this down.

	--david

--- arch/ia64/kernel/process.c~	Mon Feb  4 22:38:51 2002
+++ arch/ia64/kernel/process.c	Wed Feb  6 21:05:25 2002
@@ -267,7 +267,7 @@
 
 	if (user_mode(child_ptregs)) {
 		if (user_stack_base) {
-			child_ptregs->r12 = user_stack_base + user_stack_size;
+			child_ptregs->r12 = user_stack_base + user_stack_size - 16;
 			child_ptregs->ar_bspstore = user_stack_base;
 			child_ptregs->ar_rnat = 0;
 			child_ptregs->loadrs = 0;


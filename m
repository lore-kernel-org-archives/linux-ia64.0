From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 09 Feb 2002 18:45:46 +0000
Subject: Re: [Linux-ia64] small but important fix for clone2()
Message-Id: <marc-linux-ia64-105590698806030@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thursday's patch isn't sufficient.  It breaks threaded ia32 apps.  The
patch below should be complete, but more testing needs to be done.  At
least the x86 version of OpenOffice works again.

	--david

--- arch/ia64/kernel/entry.S~	Thu Jan 24 17:16:06 2002
+++ arch/ia64/kernel/entry.S	Sat Feb  9 10:41:59 2002
@@ -115,7 +115,7 @@
 	mov loc1=r16				// save ar.pfs across do_fork
 	.body
 	mov out1=in1
-	mov out3=0
+	mov out3				// stacksize (compensates for 16-byte scratch area)
 	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	mov out0=in0				// out0 = clone_flags
 	br.call.sptk.many rp=do_fork
--- arch/ia64/ia32/ia32_entry.S~	Mon Nov 19 20:04:55 2001
+++ arch/ia64/ia32/ia32_entry.S	Sat Feb  9 10:41:41 2002
@@ -37,7 +37,7 @@
 	mov loc1=r16				// save ar.pfs across do_fork
 	.body
 	zxt4 out1=in1				// newsp
-	mov out3=0				// stacksize
+	mov out3				// stacksize (compensates for 16-byte scratch area)
 	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	zxt4 out0=in0				// out0 = clone_flags
 	br.call.sptk.many rp=do_fork
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



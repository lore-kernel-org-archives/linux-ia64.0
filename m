From: Keith Owens <kaos@sgi.com>
Date: Wed, 05 May 2004 00:04:58 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <19618.1083715498@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 4 May 2004 09:40:58 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Tue, 04 May 2004 12:07:25 +1000, Keith Owens <kaos@sgi.com> said:
>
>  Keith> David, you wanted rp <- r0 to get a clean termination of the
>  Keith> unwind chain.  Without that clean termination, unwind wanders
>  Keith> off into nowhere generating garbage.  This has already
>  Keith> confused at least two people.
>
>Did you not read the changelog entry where I explained why I chose
>this approach?

Which changelog entry?  The only one that comes close is "ia64: Rename
ia64_invoke_kernel_thread_helper() to start_kernel_thread() for
symmetry with start_kernel() and to make it obvious when the end of the
call-chain has been reached".

It is not obvious that the end of the chain has been reached.  The
unwinder keeps going and generates many more useless backtrace entries.

Software Conventions and Runtime Architecture Guide (24535803.pdf)
section 11.1.2 explicitly states "The bottom of the call stack is
identified by a saved return link of 0".

This ugly kludge handles unwinding from a value in r0.  It gets the
kernel unwinder working again, until it can be replaced by libunwind.

Index: linux/arch/ia64/kernel/unwind.c
=================================--- linux.orig/arch/ia64/kernel/unwind.c	Sat May  1 13:15:32 2004
+++ linux/arch/ia64/kernel/unwind.c	Sat May  1 13:15:54 2004
@@ -1417,6 +1417,10 @@
 				need_nat_info = 0;
 			}
 			val = unw.preg_index[UNW_REG_R4 + (rval - 4)];
+		} else if (rval = 0 /*kludge*/) {
+#define KLUDGE_VAL_R0 -1
+			opc = UNW_INSN_MOVE;
+			val = KLUDGE_VAL_R0;
 		} else {
 			/* register got spilled to a scratch register */
 			opc = UNW_INSN_MOVE_SCRATCH;
@@ -1697,6 +1701,7 @@
 	unsigned long opc, dst, val, off;
 	unsigned long *s = (unsigned long *) state;
 	STAT(unsigned long start;)
+	static unsigned long kludge_r0;
 
 	STAT(++unw.stat.script.runs; start = ia64_get_itc());
 	state->flags = script->flags;
@@ -1724,6 +1729,10 @@
 			break;
 
 		      case UNW_INSN_MOVE:
+			if (val = KLUDGE_VAL_R0) {
+				s[dst] = (unsigned long)&kludge_r0;
+				break;
+			}
 			if (!s[val])
 				goto lazy_init;
 			s[dst] = s[val];


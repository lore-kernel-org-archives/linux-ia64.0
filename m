From: Randolph Chung <randolph@tausq.org>
Date: Mon, 08 Apr 2002 00:17:14 +0000
Subject: [Linux-ia64] epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905403@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

While trying to compile mozilla with libffi, the configure phase dies
with a message:

Error: Epilogue count of 4294967296 exceeds number of nested prologues
(0)

I see that this message comes from a patch submitted by David in
February. Is libffi broken? What is needed to fix it?

The offending assembly code is attached. it's the ".restore sp" near
the end that is triggering the error.

thanks
randolph

	.file	"conftest.i"
	.pred.safe_across_calls p1-p5,p16-p63
	.text
	.align 16
	.global main#
	.proc main#
main:
	.prologue 2, 2
	.vframe r2
	mov r2 = r12
	.body
	;;
#APP
	     .data
     .align 8
1:   data8 @fptr(ffi_closure_UNIX)
     data8 1b
     data8 0
     data8 bar
     data8 @fptr(baz)
     data8 quux
     .text
     .global foo
     .proc foo
foo:
     addl r16 = @ltoff(1b), gp;;
     ld8  gp = [r16];;
     ld8  r17 = [gp];;
     ld8  r19 = [r17],8;
	 adds r18 = 16,gp;;
     ld8  r20 = [r17];;
     st8  [r18]=r20;
     mov b6 = r19
     br.cond.sptk.many b6
     .endp

#NO_APP
	;;
	mov r8 = r0
	.restore sp
	mov r12 = r2
	br.ret.sptk.many b0
	.endp main#
	.ident	"GCC: (GNU) 3.0.4"



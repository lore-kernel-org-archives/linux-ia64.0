From: CH Gowri Kumar <gkumar@csa.iisc.ernet.in>
Date: Mon, 19 May 2003 14:33:06 +0000
Subject: Re: [Linux-ia64] [hinkelbein@ti.uni-mannheim.de: Re: Strange problems
Message-Id: <marc-linux-ia64-105590723705943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Comments inline.

>         .file   "waw.c"
>         .pred.safe_across_calls p1-p5,p16-p63
>         .text
>         .align 16
>         .global f#
>         .proc f#
> f:
>         .prologue
>         .body
>         .mii
>         addl r3 = @ltoff(sh#), gp
>         cmp4.eq p8, p9 = 0, r32
>         ;;
>         nop.i 0
>         .mmi
>         ld8 r2 = [r3]
>         ;;
>         ld4 r14 = [r2]
>         nop.i 0
>         ;;
>         .mii
>         (p9) cmp4.eq p6, p7 = 1, r14     ! it is this stuff that triggers the
> asm warning.
>         (p8) cmp4.eq p6, p7 = 2, r14     !
>         ;;                               !
>         (p6) mov r8 = r0                 !
>         .mib                             !
>         (p7) addl r8 = 13, r0            !

It is at this place the assembler is cribbing.
There are two statements which are writing to the same register ofcourse
with appropriate predicate registers.

(p6) mov r8 = r0
(p7) addl r8 = r13,r0

But the predicate register p6 and p7 are set by the just above statements
>         (p9) cmp4.eq p6, p7 = 1, r14     
>         (p8) cmp4.eq p6, p7 = 2, r14     
which are again dependent on the predicates p8 and p9 which are set by the
statment:
>         cmp4.eq p8, p9 = 0, r32

I feel that the assembler is not able to recognize that the two statements 
which are writing to the same register(r8) are mutually exclusive ( only 
one of them can be executed), as it is two levels dependant on predicate 
registers.

Anyway, it's just a warning, not an error.

Regards,
Gowri Kumar




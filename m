From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 19 May 2003 16:27:16 +0000
Subject: Re: [Linux-ia64] [hinkelbein@ti.uni-mannheim.de: Re: Strange problems building bigloo on ia64]
Message-Id: <marc-linux-ia64-105590723705944@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 19 May 2003 14:36:51 +0100, 
Matthew Wilcox <willy@debian.org> wrote:
>
>I don't grok ia64 asm enough to answer his question...
>Yann Dirson schrieb:
>~/src/ia64 > gcc -c -O3 waw.c
>/tmp/cchXUlJF.s: Assembler messages:
>/tmp/cchXUlJF.s:27: Warning: Use of 'addl' may violate WAW dependency 'GR%, % in
>1 - 127' (impliedf), specific resource number is 8
>/tmp/cchXUlJF.s:27: Warning: Only the first path encountering the conflict is
>reported
>/tmp/cchXUlJF.s:25: Warning: This is the location of the conflicting usage
>~/src/ia64 >
>
>This only occurs when using option -O3 to gcc.
>This looks like beeing an assembler problem, not one from gcc.
>Also, when looking into the assembler output, i could not find an error:
>
>        .file   "waw.c"
>        .pred.safe_across_calls p1-p5,p16-p63
>        .text
>        .align 16
>        .global f#
>        .proc f#
>f:
>        .prologue
>        .body
>        .mii
>        addl r3 = @ltoff(sh#), gp
>        cmp4.eq p8, p9 = 0, r32
>        ;;
>        nop.i 0
>        .mmi
>        ld8 r2 = [r3]
>        ;;
>        ld4 r14 = [r2]
>        nop.i 0
>        ;;
>        .mii
>        (p9) cmp4.eq p6, p7 = 1, r14     ! it is this stuff that triggers the
>asm warning.
>        (p8) cmp4.eq p6, p7 = 2, r14     !
>        ;;                               !
>        (p6) mov r8 = r0                 !
>        .mib                             !
>        (p7) addl r8 = 13, r0            !
>        nop.i 0                          !
>        br.ret.sptk.many rp              !
>        .endp f#
>        .common sh#,4,4
>        .ident  "GCC: (GNU) 3.2"

The assembler normally recognises that two predicates are exclusive.
In this case the setting of p6 and p7 is itself predicated (by p8, p9)
so the assembler cannot analyse the logic flow well enough to see that
p6 and p7 are exclusive.  IMHO gcc should issue .pred.rel directives
for complex predicates like this, e.g.

	.pred.rel "mutex", p6, p7
        (p6) mov r8 = r0
        (p7) addl r8 = 13, r0
	.pred.rel "clear", p6, p7

gcc knows that the predicates are exclusive and it is far easier for
gcc to issue the .pred.rel directives than for the assembler to do
complex logic path analysis to deduce what gcc already knows.



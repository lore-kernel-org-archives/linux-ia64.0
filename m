From: Matthew Wilcox <willy@debian.org>
Date: Mon, 19 May 2003 13:36:51 +0000
Subject: [Linux-ia64] [hinkelbein@ti.uni-mannheim.de: Re: Strange problems building bigloo on ia64]
Message-Id: <marc-linux-ia64-105590723705942@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't grok ia64 asm enough to answer his question...

----- Forwarded message from Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de> -----

Date: Mon, 19 May 2003 10:21:04 +0200
From: Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de>
To: Yann Dirson <ydirson@altern.org>
Cc: debian-ia64@lists.debian.org,
	Manuel Serrano <Manuel.Serrano@sophia.inria.fr>
Subject: Re: Strange problems building bigloo on ia64

Hi,

Yann Dirson schrieb:
> 
> Hi ia64 porters,
> 
> #193608 already reports that there are 64bit issues on this package,
> but I see in the logs a lot of messages which make me suspect some gcc
> problem:
> 
> /tmp/ccnfO17g.s: Assembler messages:
> /tmp/ccnfO17g.s:958: Warning: Use of 'mov' may violate WAW dependency 'GR%, % in 1 - 127' (impliedf), specific resource number is 14

i see some similary warnings when compiling following
with gcc3.2 and binutils 2.12

//-----------
// waw.c
int sh;

int f(int s)
{
  int test = sh;

  if(s)
    return (test = 1) ? 0:(13);
  else
    return (test = 2) ? 0:(13);
}
//-----------

~/src/ia64 > gcc -c -O3 waw.c
/tmp/cchXUlJF.s: Assembler messages:
/tmp/cchXUlJF.s:27: Warning: Use of 'addl' may violate WAW dependency 'GR%, % in
1 - 127' (impliedf), specific resource number is 8
/tmp/cchXUlJF.s:27: Warning: Only the first path encountering the conflict is
reported
/tmp/cchXUlJF.s:25: Warning: This is the location of the conflicting usage
~/src/ia64 >

This only occurs when using option -O3 to gcc.
This looks like beeing an assembler problem, not one from gcc.
Also, when looking into the assembler output, i could not find an error:

        .file   "waw.c"
        .pred.safe_across_calls p1-p5,p16-p63
        .text
        .align 16
        .global f#
        .proc f#
f:
        .prologue
        .body
        .mii
        addl r3 = @ltoff(sh#), gp
        cmp4.eq p8, p9 = 0, r32
        ;;
        nop.i 0
        .mmi
        ld8 r2 = [r3]
        ;;
        ld4 r14 = [r2]
        nop.i 0
        ;;
        .mii
        (p9) cmp4.eq p6, p7 = 1, r14     ! it is this stuff that triggers the
asm warning.
        (p8) cmp4.eq p6, p7 = 2, r14     !
        ;;                               !
        (p6) mov r8 = r0                 !
        .mib                             !
        (p7) addl r8 = 13, r0            !
        nop.i 0                          !
        br.ret.sptk.many rp              !
        .endp f#
        .common sh#,4,4
        .ident  "GCC: (GNU) 3.2"

until now i could savely ignore the warning. 
if a ia64 asm guru could please comment ?

i dont see the following anything to do with the asm issue frome above.
 
> 
> And the build terminates in a strange way as well:
> 
> /build/buildd/bigloo-2.5c+really2.5d-alpha-2003-05-16/bin/bigloo -no-hello -O2 -fsharing -unsafe -static-bigloo -c jas/lib.scm -o jas/lib.o
> /build/buildd/bigloo-2.5c+really2.5d-alpha-2003-05-16/bin/bigloo -no-hello -O2 -fsharing -unsafe -static-bigloo -c jas/classfile.scm -o jas/classfile.o
> Assembler messages:
> FATAL: can't create classfile.o: No such file or directory
> make[2]: *** [jas/classfile.o] Error 1
> make[2]: Leaving directory `/build/buildd/bigloo-2.5c+really2.5d-alpha-2003-05-16/bde'
> make[1]: *** [boot] Error 2
> make[1]: Leaving directory `/build/buildd/bigloo-2.5c+really2.5d-alpha-2003-05-16'
> 
> Ideas anyone ?
> --
> Yann Dirson    <ydirson@altern.org> |    Why make M$-Bill richer & richer ?
> Debian-related: <dirson@debian.org> |   Support Debian GNU/Linux:
> Pro:    <yann.dirson@fr.alcove.com> |  Freedom, Power, Stability, Gratuity
>      http://ydirson.free.fr/        | Check <http://www.debian.org/>
> 
> --
> To UNSUBSCRIBE, email to debian-ia64-request@lists.debian.org
> with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian.org


 cheers
  christian


-- 
To UNSUBSCRIBE, email to debian-ia64-request@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian.org


----- End forwarded message -----

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk


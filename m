From: Adrian King <adrian@xidak.com>
Date: Fri, 09 Mar 2001 21:48:24 +0000
Subject: [Linux-ia64] .auto directive appears broken for IA-64 assembler
Message-Id: <marc-linux-ia64-105590693005270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I originally sent this bug report to ia64-list@redhat.com; David wrote:

> Hmmh, you are right.  I thought this had been fixed a long time ago,
> but I can reproduce the problem with the latest assembler.  Can you
> please send your bug report to linux-ia64@linuxia64.org so the right
> people can see it?

==

The GNU assembler version 2.9-ia64-000717 (ia64-redhat-linux) using BFD
version 2.9-ia64-000717 doesn't seem to obey the ".auto" directive
correctly.

For example, consider the following files "foo.s" and "bar.c" (these
files don't do anything useful; they just illustrate where stops should
go):

====================================
foo.s:
====================================
        .auto

        .global     xxx

        .text

        .global     foo
        .proc       foo
foo:    alloc       loc0 = ar.pfs,8,8,0,0

        // There should be stops between the st8 instructions, which
        // modify r14.
        add         r14 = @gprel(xxx),gp
        st8         [r14] = r0,40
        st8         [r14] = r0,-32
        st8         [r14] = r0,16
        st8         [r14] = r0,48

        // There should be a stop between the mov instruction that sets
        // r15 and the dep instruction that uses r15.
        alloc       r14 = ar.pfs,0,0,0,0
        mov         r15 = ar.rsc
        dep         r16 = 0,r15,0,2
        mov         ar.rsc = r16
        invala

        br.ret.sptk b0
        .endp   sPro
====================================

====================================
bar.c:
====================================
long xxx;

main () {
    foo();
}
====================================

The following gdb session illustrates that the stops aren't present
where the comments above say stops are needed:

  $ cc -g -o bar.c foo.s
  $ gdb bar
  GNU gdb 5.0...
  (gdb) disas foo
  Dump of assembler code for function foo:
  0x4000000000000640 <foo>:       [MII]       alloc r40=ar.pfs,16,16,0
  0x4000000000000641 <foo+1>:                 addl r14I6,r1;;
  0x4000000000000642 <foo+2>:                 nop.i 0x0
  0x4000000000000650 <foo+16>:    [MMI]       st8 [r14]=r0,40
  0x4000000000000651 <foo+17>:                st8 [r14]=r0,-32
  0x4000000000000652 <foo+18>:                nop.i 0x0
  0x4000000000000660 <foo+32>:    [MMI]       st8 [r14]=r0,16
  0x4000000000000661 <foo+33>:                st8 [r14]=r0,48
  0x4000000000000662 <foo+34>:                nop.i 0x0;;
  0x4000000000000670 <foo+48>:    [MMI]       alloc r14=ar.pfs,0,0,0
  0x4000000000000671 <foo+49>:                mov.m r15=ar.rsc
  0x4000000000000672 <foo+50>:                dep r16=0,r15,0,2;;
  0x4000000000000680 <foo+64>:    [MMB]       mov.m ar.rsc=r16
  0x4000000000000681 <foo+65>:                invala
  0x4000000000000682 <foo+66>:                br.ret.sptk.few b0;;
  End of assembler dump.

Is there something I should be doing differently, or is this a genuine
assembler bug?

Adrian


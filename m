From: Xavier Leroy <Xavier.Leroy@inria.fr>
Date: Fri, 07 Jul 2000 09:09:17 +0000
Subject: [Linux-ia64] Re: gas dependency checker bug [forwarded message from Xavier Leroy]
Message-Id: <marc-linux-ia64-105590678205190@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Attached below is a bug report for gas.  I did verify that gas indeed
> fails to detect the RAW hazard on r2 in the sample code.

While we're at it, I found a third case of missed RAW dependency.
The IA64 has a special bypass allowing predicates set by e.g. a "cmp"
instruction to be used to predicate a branch in the same instruction
group:

        cmp.eq p6, p7 = r32, r33
        (p6) br ...

However, non-branch instructions predicated on the result of the "cmp"
cannot be executed in the same instruction group.  gas doesn't realize
this.  Consider:

[xleroy@tl2 essais]$ more preds.s
        .global f#
        .proc   f#
f:
        cmp.eq p6, p7 = r32, r33
        (p6) mov r8 = 1
        (p7) mov r8 = 0
        br.ret.sptk b0

        .endp f#

[xleroy@tl2 essais]$ as -xauto -xdebug preds.s
Checking cmp.eq for violations (line 4, 18/12)
Registering 'cmp.eq' resource usage
  Adding RAW 'PR%, % in 1 - 62' (7)
  Adding RAW 'PR%, % in 1 - 62' (6)
  Adding WAW 'PR%, % in 1 - 62' (7)
  Adding WAW 'PR%, % in 1 - 62' (6)
  Adding WAW 'PR%, % in 1 - 62' (7)
  Adding WAW 'PR%, % in 1 - 62' (6)
  Registering mutex on p6, p7
Checking mov for violations (line 5, 8/2)
Registering 'mov' resource usage
  Adding RAW 'GR%, % in 1 - 127' (8)
  Adding WAW 'GR%, % in 1 - 127' (8)
Checking mov for violations (line 6, 8/2)
Registering 'mov' resource usage
  Adding RAW 'GR%, % in 1 - 127' (8)
  Adding WAW 'GR%, % in 1 - 127' (8)
Checking br.ret.sptk for violations (line 7, 27/13)
Registering 'br.ret.sptk' resource usage
  Clearing register values
  Clearing mutex relation p6, p7
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)

[xleroy@tl2 essais]$ objdump -d a.out  

a.out:     file format elf64-ia64-little

Disassembly of section .text:

0000000000000000 <f>:
   0:   00 30 80 42 07 b8       [MII]       cmp.eq p6,p7=r32,r33
   6:   81 08 00 00 c2 03             (p06) mov r8=1
   c:   01 00 00 84                   (p07) mov r8=r0
  10:   11 00 00 00 01 00       [MIB]       nop.m 0x0
  16:   00 00 00 02 00 80                   nop.i 0x0
  1c:   00 00 84 00                         br.ret.sptk.few b0;;

This is incorrect: there should be a stop after the cmp.eq.

Best regards,

- Xavier Leroy



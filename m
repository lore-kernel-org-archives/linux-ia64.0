From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 06 Jul 2000 17:57:32 +0000
Subject: [Linux-ia64] gas dependency checker bug [forwarded message from Xavier Leroy]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="EMCFQTS0Vn"
Message-Id: <marc-linux-ia64-105590678205189@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--EMCFQTS0Vn
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit

Attached below is a bug report for gas.  I did verify that gas indeed
fails to detect the RAW hazard on r2 in the sample code.

	--david


--EMCFQTS0Vn
Content-Type: message/rfc822
Content-Description: forwarded message
Content-Transfer-Encoding: 7bit

Return-Path: <Xavier.Leroy@inria.fr>
Received: from hplms2.hpl.hp.com (root@hplms2.hpl.hp.com [15.0.152.33])
	by napali.hpl.hp.com (8.9.3/8.9.3) with ESMTP id GAA17088
	for <davidm@napali.hpl.hp.com>; Mon, 3 Jul 2000 06:08:53 -0700
Received: from hplms26.hpl.hp.com (hplms26.hpl.hp.com [15.255.168.31])
	by hplms2.hpl.hp.com (8.9.3 (PHNE_18979)/8.9.3 HPL-PA Hub) with ESMTP id GAA02138
	for <davidm@hpl.hp.com>; Mon, 3 Jul 2000 06:08:52 -0700 (PDT)
Received: from concorde.inria.fr (concorde.inria.fr [192.93.2.39])
	by hplms26.hpl.hp.com (8.9.3 (PHNE_18979)/HPL-PA Relay) with ESMTP id GAA27579
	for <davidm@hpl.hp.com>; Mon, 3 Jul 2000 06:08:50 -0700 (PDT)
Received: from pauillac.inria.fr (pauillac.inria.fr [128.93.11.35])
	by concorde.inria.fr (8.10.0/8.10.0) with ESMTP id e63D23T12184
	for <davidm@hpl.hp.com>; Mon, 3 Jul 2000 15:02:03 +0200 (MET DST)
Received: (from xleroy@localhost) by pauillac.inria.fr (8.7.6/8.7.3) id PAA19702; Mon, 3 Jul 2000 15:02:02 +0200 (MET DST)
Message-ID: <20000703150202.63145@pauillac.inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
X-Mailer: Mutt 0.89.1
From: Xavier Leroy <Xavier.Leroy@inria.fr>
To: davidm@hpl.hp.com
Subject: possible dependency bug in gas for IA64
Date: Mon, 3 Jul 2000 15:02:02 +0200

Hello,

I'm taking the liberty to contact you directly, as you seem to be the
main author of the IA64 port of the GNU assembler.  If I should have
used some mailing list instead, please accept my apologies.

While retargeting the Objective Caml compiler for the IA64, I've found
what looks like two bugs in the way "as" record dependencies between
instructions.

The problems were observed with version 2.9-ia64-000216-final of the
GNU assembler, but seem to be still there in the working sources
available from Cygnus' CVS repository.

1- "addl" vs. "adds"

Consider:

        .global f#
        .proc   f#
f:
        mov     r2 = r32
        addl    r3 = 12345, r2
        br.ret.sptk b0

        .endp f#

Once assembled in -xauto -xdebug mode, we get:

[xleroy@tl2 xleroy]$ as -xauto -xdebug deps.s
Checking mov for violations (line 4, 8/2)
Registering 'mov' resource usage
  Adding RAW 'GR%, % in 1 - 127' (2)
  Adding WAW 'GR%, % in 1 - 127' (2)
Checking addl for violations (line 5, 8/2)
Registering 'addl' resource usage
  Adding RAW 'GR%, % in 1 - 127' (3)
  Adding WAW 'GR%, % in 1 - 127' (3)
Checking br.ret.sptk for violations (line 7, 27/13)
Registering 'br.ret.sptk' resource usage
  Clearing register values
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)
[xleroy@tl2 xleroy]$ objdump -d a.out

a.out:     file format elf64-ia64-little

Disassembly of section .text:

0000000000000000 <f>:
   0:   11 10 00 40 00 21       [MIB]       mov r2=r32
   6:   30 c8 09 c0 48 80                   addl r3=12345,r2
   c:   00 00 84 00                         br.ret.sptk.few b0;;

This is incorrect, because the "addl" depends on the previous "mov",
so both instructions cannot be executed in parallel.

However, if the "addl" is replaced by an "adds", everything works as
expected:

        .global f#
        .proc   f#
f:
        mov     r2 = r32
        adds    r3 = 123, r2
        br.ret.sptk b0

        .endp f#

[xleroy@tl2 xleroy]$ as -xauto -xdebug deps.s
Checking mov for violations (line 4, 8/2)
Registering 'mov' resource usage
  Adding RAW 'GR%, % in 1 - 127' (2)
  Adding WAW 'GR%, % in 1 - 127' (2)
Checking adds for violations (line 6, 8/2)
Use of 'adds' violates RAW dependency 'GR%, % in 1 - 127' (impliedf), specific resource number is 2 @ deps.s:4
Inserting stop
  Insn group break (w/stop)
  Removing RAW 'GR%, % in 1 - 127' (2)
  Removing WAW 'GR%, % in 1 - 127' (2)
Registering 'adds' resource usage
  Adding RAW 'GR%, % in 1 - 127' (3)
  Adding WAW 'GR%, % in 1 - 127' (3)
Checking br.ret.sptk for violations (line 7, 27/13)
Registering 'br.ret.sptk' resource usage
  Clearing register values
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)
[xleroy@tl2 xleroy]$ objdump -d a.out

a.out:     file format elf64-ia64-little

Disassembly of section .text:

0000000000000000 <f>:
   0:   0a 10 00 40 00 21       [MMI]       mov r2=r32;;
   6:   30 d8 0b 00 42 00                   adds r3=123,r2
   c:   00 00 04 00                         nop.i 0x0
  10:   11 00 00 00 01 00       [MIB]       nop.m 0x0
  16:   00 00 00 02 00 80                   nop.i 0x0
  1c:   00 00 84 00                         br.ret.sptk.few b0;;


2- Loads and stores with postincrement.

A similar issue (missing dependencies) occur with the post-increment
forms of loads and stores.  Consider:

        .global f#
        .proc   f#
f:
        ld8     r2 = [r32], 8
        mov     r8 = r32
        br.ret.sptk b0

        .endp f#

[xleroy@tl2 xleroy]$ as -xdebug -xauto postinc.s
Checking ld8 for violations (line 4, 32/4)
Registering 'ld8' resource usage
  Adding RAW 'GR%, % in 1 - 127' (2)
  Adding WAW 'GR%, % in 1 - 127' (2)
Checking mov for violations (line 5, 8/2)
Registering 'mov' resource usage
  Adding RAW 'GR%, % in 1 - 127' (8)
  Adding WAW 'GR%, % in 1 - 127' (8)
Checking br.ret.sptk for violations (line 6, 27/13)
Registering 'br.ret.sptk' resource usage
  Clearing register values
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)
  Insn group break (w/stop)

[xleroy@tl2 xleroy]$ objdump -d a.out

a.out:     file format elf64-ia64-little

Disassembly of section .text:

0000000000000000 <f>:
   0:   11 10 20 40 18 14       [MIB]       ld8 r2=[r32],8
   6:   80 00 80 00 42 80                   mov r8=r32
   c:   00 00 84 00                         br.ret.sptk.few b0;;

Again, I believe it's incorrect to execute the ld8 and the mov in
parallel, because the mov should get the updated value of r32 (after
the post-increment was performed).

The problem with postincrement isn't too serious for my application
(I can avoid generating postincremented loads and stores), but
the first problem with addl is a real show-stopper, due to code of the form

        <restore gp after a call>
        addl <tempreg> = @ltoff(some_symbol#), gp

which gets incorrectly scheduled with -xauto.  So, any help you could
provide will be most appreciated!

Best regards,

- Xavier Leroy

--EMCFQTS0Vn--



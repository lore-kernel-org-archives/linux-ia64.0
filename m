From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 10 Jul 2007 18:12:33 +0000
Subject: RE: [RFC][PATCH take2 0/13] Support vector domain on ia64
Message-Id: <617E1C2C70743745A92448908E030B2A01E2D4B2@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46779036.5050602@jp.fujitsu.com>
In-Reply-To: <46779036.5050602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> I have never seen these messages. I will check them.

This seems to be an intermittent problem.  I just got my serial console
working again to get you a full stack trace, and the first time I booted the
kernel with your vector domain patch it didn't crash.

Second boot did crash.  Here's the stack trace part of the console log:


CPU 9: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 159 cycles)
CPU 10: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 40 cycles)
CPU 11: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 161 cycles)
Unable to handle kernel paging request at virtual address a000008100974780
swapper[0]: Oops 8813272891392 [1]
Modules linked in:

Pid: 0, CPU 12, comm:              swapper
psr : 0000101008022018 ifs : 8000000000000389 ip  : [<a000000100011c50>]   =
 Not tainted
ip is at ia64_handle_irq+0x190/0x2a0
unat: 0000000000000000 pfs : 03e0000000000389 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 00000000000095a5
ldrs: 0000000000000000 ccv : 0000000000000fff fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100011b10 b6  : a000000100003320 b7  : e00000007fb1bde0
f6  : 000000000000000000000 f7  : 1003e0000000155557000
f8  : 000000000000000000000 f9  : 000000000000000000000
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a000000100c2db30 r2  : 0000000000010000 r3  : 0000000000000000
r8  : 00000000000000fd r9  : 00000000000000fc r10 : 0000000000000000
r11 : 0009804c0270033f r12 : e000000180eafc60 r13 : e000000180ea0000
r14 : ffffffffffff4b00 r15 : ffffffffffff0428 r16 : 00000000ffffffff
r17 : a000000100a45c58 r18 : e00000007fe131b0 r19 : e00000007fb1bde0
r20 : a000000100a4b6a0 r21 : a000000100970000 r22 : a000008100974780
r23 : 0000007fffffff80 r24 : a000000100974800 r25 : a000000100a2ef30
r26 : e0000001800c004c r27 : 000000000000004c r28 : e0000001800c0000
r29 : ffffffffffff0000 r30 : e0000001800d0000 r31 : a000000100a44ea0

Call Trace:
 [<a000000100012bb0>] show_stack+0x50/0xa0
                                sp=E000000180eaf830 bsp=E000000180ea0d28
 [<a000000100013480>] show_regs+0x820/0x840
                                sp=E000000180eafa00 bsp=E000000180ea0ce0
 [<a0000001000370c0>] die+0x1a0/0x280
                                sp=E000000180eafa00 bsp=E000000180ea0c98
 [<a000000100061230>] ia64_do_page_fault+0x810/0x900
                                sp=E000000180eafa00 bsp=E000000180ea0c38
 [<a00000010000bcc0>] ia64_leave_kernel+0x0/0x270
                                sp=E000000180eafa90 bsp=E000000180ea0c38
 [<a000000100011c50>] ia64_handle_irq+0x190/0x2a0
                                sp=E000000180eafc60 bsp=E000000180ea0be8
 [<a00000010000bcc0>] ia64_leave_kernel+0x0/0x270
                                sp=E000000180eafc60 bsp=E000000180ea0be8
 [<a0000001000541d0>] unlock_ipi_calllock+0x30/0x60
                                sp=E000000180eafe30 bsp=E000000180ea0bd0
 [<a000000100055fb0>] start_secondary+0x2d0/0x580
                                sp=E000000180eafe30 bsp=E000000180ea0b80
 [<a0000001000089e0>] __end_ivt_text+0x6c0/0x6f0
                                sp=E000000180eafe30 bsp=E000000180ea0b80
Kernel panic - not syncing: Aiee, killing interrupt handler!

The bit of ia64_handle_irq where we crashed looks like this:

a000000100011c30:       02 80 00 34 10 10       [MII]       ld4 r16=3D[r26]
a000000100011c36:       00 00 00 02 00 e0                   nop.i 0x0;;
a000000100011c3c:       02 c1 7d 53                         dep.z r23=3Dr16=
,7,32
a000000100011c40:       03 00 00 00 01 00       [MII]       nop.m 0x0
a000000100011c46:       70 02 40 00 42 c0                   mov r39=3Dr16;;
a000000100011c4c:       72 c1 00 80                         add r22=3Dr23,r=
24;;
a000000100011c50:       0d 70 00 2c 18 10       [MFI]       ld8 r14=3D[r22]

r22 has the very bad value of 0xa000008100974780 ... so we die.

-Tony

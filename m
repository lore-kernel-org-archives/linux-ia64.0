From: Matthew Wilcox <willy@debian.org>
Date: Fri, 04 Jul 2003 15:03:03 +0000
Subject: Re: Using Linus's tree for IA64.
Message-Id: <marc-linux-ia64-105733106329649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


The idea of using Linus' tree for ia64 appeals to me, so I tried it ...

POSIX conformance testing by UNIFIX
Boot processor id 0x0/0x2
task migration cache decay timeo<4>kernel BUG at kernel/timer.c:376!
swapper[1]: bugcheck! 0 [1]

Pid: 1, CPU 0, comm:              swapper
psr : 0000101008022018 ifs : 800000000000048c ip  : [<a0000001000980d0>]   =
 Not tainted
ip is at cascade+0xf0/0x100
unat: 0000000000000000 pfs : 000000000000048c rsc : 0000000000000003
rnat: 8000000000000004 bsps: 000000000001003e pr  : 80000000ff719aa5
ldrs: 0000000000000000 ccv : 00000000ffffffff fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000980d0 b6  : a000000100003320 b7  : a0000001002b3980
f6  : 0fffbccccccccc8c00000 f7  : 0ffdaf300000000000000
f8  : 10000c000000000000000 f9  : 10002a000000000000000
f10 : 0fffd9999999996900000 f11 : 1003e0000000000000000
r1  : a0000001009a0000 r2  : 0000000000000308 r3  : a0000001007bac94
r8  : 0000000000000022 r9  : a000000100906720 r10 : 00000000ffffffff
r11 : 0000000000000000 r12 : e0000040fef87bd0 r13 : e0000040fef80000
r14 : 0000000000020000 r15 : 0000000000004000 r16 : 00000000000018d9
r17 : 0000000100000000 r18 : 0000000000000000 r19 : 0000000000000001
r20 : 0000000000000000 r21 : 0000000000004000 r22 : 00000000000018fe
r23 : fffffffffffe18fe r24 : a000000100906810 r25 : a000000100906818
r26 : a000000100906828 r27 : a0000001007bac80 r28 : a000000100035630
r29 : 0000000000000000 r30 : 0000000000000000 r31 : a0000001007bac98

Call Trace:
 [<a000000100018c80>] show_stack+0x0/0xa0
                                sp=E0000040fef877a0 bsp=E0000040fef81518
 [<a00000010003b730>] die+0x170/0x200
                                sp=E0000040fef87970 bsp=E0000040fef814e0
 [<a00000010003ba40>] ia64_bad_break+0x220/0x340
                                sp=E0000040fef87970 bsp=E0000040fef814b8
 [<a000000100011fe0>] ia64_leave_kernel+0x0/0x260
                                sp=E0000040fef87a00 bsp=E0000040fef814b8
 [<a0000001000980d0>] cascade+0xf0/0x100
                                sp=E0000040fef87bd0 bsp=E0000040fef81458
 [<a000000100099300>] run_timer_softirq+0x3a0/0x440
                                sp=E0000040fef87bd0 bsp=E0000040fef813e8
 [<a00000010008e680>] do_softirq+0x2c0/0x2e0
                                sp=E0000040fef87bf0 bsp=E0000040fef81360
 [<a000000100015da0>] do_IRQ+0x220/0x480
                                sp=E0000040fef87bf0 bsp=E0000040fef81308
 [<a000000100017cb0>] ia64_handle_irq+0x70/0x140
                                sp=E0000040fef87bf0 bsp=E0000040fef812d8
 [<a000000100011fe0>] ia64_leave_kernel+0x0/0x260
                                sp=E0000040fef87bf0 bsp=E0000040fef812d8
 [<a0000001003685c0>] serial8250_console_write+0x140/0x6c0
                                sp=E0000040fef87dc0 bsp=E0000040fef81230
 [<a000000100085990>] __call_console_drivers+0x110/0x120
                                sp=E0000040fef87dc0 bsp=E0000040fef811e8
 [<a000000100085c10>] call_console_drivers+0x170/0x280
                                sp=E0000040fef87dc0 bsp=E0000040fef81190
 [<a000000100086500>] release_console_sem+0x100/0x260
                                sp=E0000040fef87dc0 bsp=E0000040fef81140
 [<a0000001000861c0>] printk+0x3e0/0x540
                                sp=E0000040fef87dc0 bsp=E0000040fef810a0
 [<a000000100737aa0>] smp_prepare_cpus+0x180/0x200
                                sp=E0000040fef87e20 bsp=E0000040fef81078
 [<a000000100009200>] init+0xa0/0x320
                                sp=E0000040fef87e20 bsp=E0000040fef81050
 [<a00000010001a890>] kernel_thread+0x150/0x280
                                sp=E0000040fef87e20 bsp=E0000040fef81018
 [<a000000100009050>] rest_init+0x30/0xe0
                                sp=E0000040fef87e20 bsp=E0000040fef81000
 [<a00000010072ce10>] start_kernel+0x450/0x4a0
                                sp=E0000040fef87e20 bsp=E0000040fef80f98
 [<a0000001000085a0>] _start+0x280/0x2a0
                                sp=E0000040fef87e30 bsp=E0000040fef80f30
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing

It's reproducable, FWIW.  Were you trying on a serial console or a
graphical console?

--=20
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodi=
es.
Do you think I want to have an academic debate on this subject?" -- Robert =
Fisk

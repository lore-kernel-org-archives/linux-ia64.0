From: Aron Griffis <aron@hp.com>
Date: Wed, 10 Mar 2004 22:53:07 +0000
Subject: oops in sysrq: showTasks
Message-Id: <20040310225307.GA27287@kaf.zk3.dec.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This is again rx2600, zx1, running davidm's 2.6.4-rc1 built with gcc-3.3.3

telnet> send brk
SysRq : HELP : loglevel0-8 reBoot tErm kIll saK showMem powerOff showPc unR=
aw Sync showTasks Unmount

telnet> send brk
SysRq : Show State
events/0[6]: Oops 8813272891392 [1]

Pid: 6, CPU 0, comm:             events/0
psr : 0000101008026018 ifs : 800000000000038b ip  : [<a000000100585bc0>]   =
 Tainted: GF
ip is at sba_unmap_sg+0x20/0xc0
unat: 0000000000000000 pfs : 0000000000000610 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 442140444445aa65
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a74433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100502dd0 b6  : a000000100002d70 b7  : a0000001005095a0
f6  : 1003e0000000000000010 f7  : 0ffe8cae9f14400000000
f8  : 1003e0000000000000600 f9  : 1003e0000000000000060
f10 : 1003e000000000013d620 f11 : 1003e0000000000000514
r1  : a000000100afd5c0 r2  : 0000000000000018 r3  : 0000000000000600
r8  : 0000000000000000 r9  : e00000407efa8000 r10 : 0000000000000600
r11 : 0000000000000600 r12 : e00000407efb7da0 r13 : e00000407efb0000
r14 : e00000407ff69000 r15 : e00000407fc500c0 r16 : e00000407fc50000
r17 : e00000407efa8000 r18 : 0000000000000600 r19 : 0000000000000060
r20 : e00000407fc500a8 r21 : e00000407ee179f2 r22 : e00000407fc52000
r23 : e00000407ee17978 r24 : e00000407ee179d8 r25 : e00000407fc500f0
r26 : a00000010096cc38 r27 : e00000407fc50800 r28 : a0000001005095a0
r29 : a0000001007b6618 r30 : 0000000000000000 r31 : e00000407fc51440

Call Trace:
 [<a000000100018420>] show_stack+0x80/0xa0
                                sp=E00000407efb7970 bsp=E00000407efb1338
 [<a00000010003ca70>] die+0x170/0x200
                                sp=E00000407efb7b40 bsp=E00000407efb1300
 [<a00000010005a850>] ia64_do_page_fault+0x350/0x980
                                sp=E00000407efb7b40 bsp=E00000407efb1298
 [<a000000100011540>] ia64_leave_kernel+0x0/0x260
                                sp=E00000407efb7bd0 bsp=E00000407efb1298
 [<a000000100585bc0>] sba_unmap_sg+0x20/0xc0
                                sp=E00000407efb7da0 bsp=E00000407efb1240
 [<a000000100502dd0>] mptscsih_flush_running_cmds+0x190/0x2e0
                                sp=E00000407efb7da0 bsp=E00000407efb11d8
 [<a0000001005098d0>] mptscsih_ioc_reset+0x330/0x440
                                sp=E00000407efb7da0 bsp=E00000407efb11a0
 [<a0000001004fada0>] mpt_diag_reset+0x1bc0/0x1c80
                                sp=E00000407efb7da0 bsp=E00000407efb1118
 [<a0000001004f8ec0>] KickStart+0x60/0x380
                                sp=E00000407efb7da0 bsp=E00000407efb10c0
 [<a0000001004f5ed0>] MakeIocReady+0x150/0x5c0
                                sp=E00000407efb7da0 bsp=E00000407efb1040
 [<a0000001004f47e0>] mpt_do_ioc_recovery+0x280/0xb00
                                sp=E00000407efb7db0 bsp=E00000407efb0fd0
 [<a000000100500a20>] mpt_HardResetHandler+0x1a0/0x2c0
                                sp=E00000407efb7db0 bsp=E00000407efb0f90
 [<a00000010050b470>] mptscsih_schedule_reset+0x30/0x80
                                sp=E00000407efb7db0 bsp=E00000407efb0f70
 [<a000000100095bc0>] worker_thread+0x420/0x580
                                sp=E00000407efb7db0 bsp=E00000407efb0ef0
 [<a00000010009e450>] kthread+0x150/0x160
                                sp=E00000407efb7e20 bsp=E00000407efb0eb8
 [<a000000100019fd0>] kernel_thread_helper+0x30/0x60
                                sp=E00000407efb7e30 bsp=E00000407efb0e90
 [<a000000100008c40>] start_kernel_thread+0x20/0x40
                                sp=E00000407efb7e30 bsp=E00000407efb0e90
 [<a000000100002d70>] break_fault+0x170/0x400
                                sp=E00000407efb7e30 bsp=E00000407efb0e90
 [<a000000100502dd0>] mptscsih_flush_running_cmds+0x190/0x2e0
                                sp=E00000407efb7e30 bsp=E00000407efb0e90

--=20
Aron Griffis
hp Linux and Open Source Lab
Key fingerprint =3D 4601 AE87 379D A917 BA62  5263 C284 0366 5E6A 3C6B


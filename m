From: Aron Griffis <aron@hp.com>
Date: Tue, 09 Mar 2004 16:09:04 +0000
Subject: crash on SysRq : Show Memory
Message-Id: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="K8nIJk4ghYZn606h"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--K8nIJk4ghYZn606h
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I'm running davidm's bk kernel, version 2.6.4-rc1, built with gcc-3.3.
I've been poking around with SysRq and hit a crash last evening with the
following footprint.  After this the machine was wedged so badly that
the Ethernet MP stopped responding completely, so I was unable to power
cycle the machine until I arrived at the office.

telnet> send brk
SysRq : Show Memory
swapper[0]: Oops 8813272891392 [1]

Pid: 0, CPU 0, comm:              swapper
psr : 0000101008026018 ifs : 8000000000000389 ip  : [<a00000010005b9e0>]   =
 Tainted: GF
ip is at show_mem+0x100/0x260
unat: 0000000000000000 pfs : 0000000000000389 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 80000000ff556565
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010005b970 b6  : a00000010006dc70 b7  : a0000001002eda00
f6  : 0fffbccccccccc8c00000 f7  : 0ffdaa200000000000000
f8  : 100008000000000000000 f9  : 10002a000000000000000
f10 : 0fffcccccccccc8c00000 f11 : 1003e0000000000000000
r1  : a000000100afd5c0 r2  : ffffffffffffff05 r3  : 000000000103ffef
r8  : a0000001009174f0 r9  : a0000001009174f0 r10 : 0000000000000000
r11 : a0000001009172a0 r12 : e0000000047ffb90 r13 : e0000000047f8000
r14 : a000000100848510 r15 : a00000010084dcf8 r16 : a0007fffff0fffb0
r17 : 000000000100ffff r18 : a0007fffff0fffd0 r19 : a0007fffaec00000
r20 : a000000100917508 r21 : 0000000000000000 r22 : 000000000504fffb
r23 : 000000000100ffff r24 : 0000000000000000 r25 : 0000000000000001
r26 : 00000000000008eb r27 : 0000000000000001 r28 : a000000100931c12
r29 : 0000000000004b3a r30 : 0000000000000000 r31 : a000000100917258

Call Trace:
 [<a000000100018420>] show_stack+0x80/0xa0
                                sp=3De0000000047ff760 bsp=3De0000000047f96b8
 [<a00000010003ca70>] die+0x170/0x200
                                sp=3De0000000047ff930 bsp=3De0000000047f9680
 [<a00000010005a850>] ia64_do_page_fault+0x350/0x980
                                sp=3De0000000047ff930 bsp=3De0000000047f9618
 [<a000000100011540>] ia64_leave_kernel+0x0/0x260
                                sp=3De0000000047ff9c0 bsp=3De0000000047f9618
 [<a00000010005b9e0>] show_mem+0x100/0x260
                                sp=3De0000000047ffb90 bsp=3De0000000047f95c8
 [<a0000001003928a0>] sysrq_handle_showmem+0x20/0x40
                                sp=3De0000000047ffb90 bsp=3De0000000047f95b0
 [<a000000100392dd0>] __handle_sysrq_nolock+0x110/0x260
                                sp=3De0000000047ffb90 bsp=3De0000000047f9568
 [<a000000100392c90>] handle_sysrq+0x70/0xa0
                                sp=3De0000000047ffb90 bsp=3De0000000047f9538
 [<a00000010040e110>] receive_chars+0x330/0x680
                                sp=3De0000000047ffb90 bsp=3De0000000047f9448
 [<a00000010040ebf0>] serial8250_interrupt+0x1b0/0x200
                                sp=3De0000000047ffba0 bsp=3De0000000047f93d8
 [<a000000100014d40>] handle_IRQ_event+0xa0/0x120
                                sp=3De0000000047ffbb0 bsp=3De0000000047f9390
 [<a000000100015780>] do_IRQ+0x280/0x380
                                sp=3De0000000047ffbb0 bsp=3De0000000047f9340
 [<a000000100017400>] ia64_handle_irq+0xa0/0x1a0
                                sp=3De0000000047ffbb0 bsp=3De0000000047f9308
 [<a000000100011540>] ia64_leave_kernel+0x0/0x260
                                sp=3De0000000047ffbb0 bsp=3De0000000047f9308
 [<a0000001000177c0>] ia64_pal_call_static+0x80/0xa0
                                sp=3De0000000047ffd80 bsp=3De0000000047f9000
 [<a000000100018e30>] default_idle+0x90/0x140
                                sp=3De0000000047ffd80 bsp=3De0000000047f8fd8
 [<a000000100019000>] cpu_idle+0x120/0x1e0
                                sp=3De0000000047ffe20 bsp=3De0000000047f8f78
 [<a000000100008d30>] rest_init+0x90/0xe0
                                sp=3De0000000047ffe20 bsp=3De0000000047f8f60
 [<a0000001007c4e10>] start_kernel+0x490/0x520
                                sp=3De0000000047ffe20 bsp=3De0000000047f8f00
 [<a0000001000081a0>] _start+0x280/0x2a0
                                sp=3De0000000047ffe30 bsp=3De0000000047f8e90
 <<00>>KIenr nienlt eprarnuipct:  hAainedel,e rk i-l lniontg  siynntceirnru=
gp
 h a                                                                       =
  t

--=20
Aron Griffis
hp Linux and Open Source Lab
Key fingerprint =3D 4601 AE87 379D A917 BA62  5263 C284 0366 5E6A 3C6B


--K8nIJk4ghYZn606h
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFATewgwoQDZl5qPGsRAl0dAJ97sN6fGL/Buhmip0Msoh31TebkAACbBaIM
RmIX213oQwcma9Cdk9J4DFE=
=HLgp
-----END PGP SIGNATURE-----

--K8nIJk4ghYZn606h--

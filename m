From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 27 Apr 2021 07:18:38 +0000
Subject: Re: New working ia64 installer images available
Message-Id: <53183eb3-62ad-6b17-9659-e31704e755ed@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Sergei!

Below is a backtrace of a crash on an RX-2660 that one user is reporting.

Not sure what the problem is as the same kernel boots fine on my RX-2660,
but maybe you have an idea?

Adrian

On 4/19/21 10:30 PM, Pedro Miguel Justo wrote:
> When I try to boot the new install image on my rx2660 this is what I get:
>=20
> [    0.592000] usercopy: Kernel memory overwrite attempt detected to line=
ar kernel text (offset 7733248, size 1)!
> [    0.592000] cryptomgr_test[65]: bugcheck! 0 [1]
> [    0.592000] Modules linked in:
> [    0.592000]
> [    0.592000] CPU: 6 PID: 65 Comm: cryptomgr_test Not tainted 5.10.0-6-i=
tanium #1 Debian 5.10.28-1
> [    0.596000] Hardware name: hp server rx2660                   , BIOS 0=
4.30                                                            03/05/2012
> [    0.596000] psr : 00001010084a6010 ifs : 8000000000000410 ip  : [<a000=
0001011e06b0>]    Not tainted (5.10.0-6-itanium Debian 5.10.28-1)
> [    0.596000] ip is at usercopy_abort+0x120/0x130
> [    0.596000] unat: 0000000000000000 pfs : 0000000000000410 rsc : 000000=
0000000003
> [    0.596000] rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000=
21559aaa55
> [    0.596000] ldrs: 0000000000000000 ccv : 00000000fffff08d fpsr: 000980=
4c8a70433f
> [    0.596000] csd : 0000000000000000 ssd : 0000000000000000
> [    0.596000] b0  : a0000001011e06b0 b6  : a0000001009e9a80 b7  : a00000=
01007aef00
> [    0.596000] f6  : 1003e0000000000000000 f7  : 1003e0044b82fa09b5a53
> [    0.596000] f8  : 1003e00000000000004bc f9  : 1003e0000000004692680
> [    0.596000] f10 : 1003e20c49ba5e353f7cf f11 : 1003e0000000000908800
> [    0.596000] r1  : a000000101a4b5d0 r2  : a0000001017e4b18 r3  : a00000=
01017e4b20
> [    0.596000] r8  : 000000000000001f r9  : 0000000000000001 r10 : 000000=
0000000000
> [    0.596000] r11 : 00000000ffffefff r12 : e000000100757c70 r13 : e00000=
0100750000
> [    0.596000] r14 : ffffffffffd99548 r15 : a0000001017e4b20 r16 : e00000=
00012c0000
> [    0.596000] r17 : 0000000000004000 r18 : 000000000000008e r19 : 000000=
000000051a
> [    0.596000] r20 : 000000000000051a r21 : 000000000000051a r22 : 000000=
000000051c
> [    0.596000] r23 : 000000000000051c r24 : 000000000000051c r25 : 000000=
0000004000
> [    0.596000] r26 : 000000000000000c r27 : a0000001017ccb18 r28 : 000000=
0000001000
> [    0.596000] r29 : ffffffffffd18c61 r30 : a000000101764231 r31 : 000000=
0000000001
> [    0.596000]
> [    0.596000] Call Trace:
> [    0.596000]  [<a000000100014c50>] show_stack+0x90/0xc0
> [    0.596000]                                 sp=E0000001007578b0 bsp=E0=
00000100751560
> [    0.596000]  [<a000000100015360>] show_regs+0x6e0/0xa40
> [    0.596000]                                 sp=E000000100757a80 bsp=E0=
000001007514f0
> [    0.596000]  [<a0000001000275d0>] die+0x1b0/0x4a0
> [    0.596000]                                 sp=E000000100757aa0 bsp=E0=
000001007514b0
> [    0.596000]  [<a0000001011fb460>] ia64_bad_break+0x740/0x760
> [    0.596000]                                 sp=E000000100757aa0 bsp=E0=
00000100751480
> [    0.596000]  [<a00000010000ca20>] ia64_leave_kernel+0x0/0x270
> [    0.596000]                                 sp=E000000100757aa0 bsp=E0=
00000100751480
> [    0.596000]  [<a0000001011e06b0>] usercopy_abort+0x120/0x130
> [    0.596000]                                 sp=E000000100757c70 bsp=E0=
00000100751400
> [    0.596000]  [<a00000010047c6b0>] __check_object_size+0x330/0x3a0
> [    0.596000]                                 sp=E000000100757c80 bsp=E0=
000001007513c0
> [    0.596000]  [<a0000001007bc580>] build_test_sglist+0x500/0x8c0
> [    0.596000]                                 sp=E000000100757c80 bsp=E0=
00000100751300
> [    0.596000]  [<a0000001007be240>] test_shash_vec_cfg+0x1e0/0xcc0
> [    0.596000]                                 sp=E000000100757d00 bsp=E0=
00000100751250
> [    0.596000]  [<a0000001007c35f0>] __alg_test_hash.constprop.0+0x2d0/0x=
740
> [    0.596000]                                 sp=E000000100757da0 bsp=E0=
00000100751198
> [    0.596000]  [<a0000001007c3b70>] alg_test_hash+0x110/0x2e0
> [    0.596000]                                 sp=E000000100757db0 bsp=E0=
00000100751140
> [    0.596000]  [<a0000001007bf930>] alg_test+0xc10/0xe80
> [    0.596000]                                 sp=E000000100757db0 bsp=E0=
000001007510c0
> [    0.596000]  [<a0000001007b8e40>] cryptomgr_test+0x80/0xc0
> [    0.596000]                                 sp=E000000100757e30 bsp=E0=
000001007510a0
> [    0.596000]  [<a0000001000ba870>] kthread+0x270/0x2a0
> [    0.596000]                                 sp=E000000100757e30 bsp=E0=
00000100751058
> [    0.596000]  [<a00000010000c810>] call_payload+0x50/0x80
> [    0.596000]                                 sp=E000000100757e30 bsp=E0=
00000100751040
> [    0.596000] Disabling lock debugging due to kernel taint
> [    6.796000] random: crng init done

--=20
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

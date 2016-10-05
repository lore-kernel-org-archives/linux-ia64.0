From: Meelis Roos <mroos@linux.ee>
Date: Wed, 05 Oct 2016 20:34:56 +0000
Subject: 4.8 ia64: usercopy: kernel memory exposure attempt detected
Message-Id: <alpine.LRH.2.20.1610060046330.29486@math.ut.ee>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

This is 4.8 on HP rx2620, with usercopy checks. How do I find out the=20
culprit?

[    9.013642] VFS: Mounted root (ext4 filesystem) readonly on device 8:3.
[    9.033645] devtmpfs: mounted
[    9.033645] Freeing unused kernel memory: 800K (e000000004b38000 - e0000=
00004c00000)
[    9.033645] This architecture does not have kernel memory protection.
[    9.149645] usercopy: kernel memory exposure attempt detected from e0000=
00100888000 (<linear kernel text>) (832 bytes)
[    9.149645] kernel BUG at mm/usercopy.c:75!
[    9.149645] init[1]: bugcheck! 0 [1]
[    9.149645] Modules linked in:
[    9.149645]=20
[    9.149645] CPU: 0 PID: 1 Comm: init Not tainted 4.8.0 #45
[    9.149645] Hardware name: hp server rx2620                   , BIOS 04.=
29                                                            11/30/2007   =
      =20
[    9.149645] task: e000004083208000 task.stack: e000004083208000
[    9.149645] psr : 0000101008026010 ifs : 800000000000038d ip  : [<a00000=
0100233760>]    Not tainted (4.8.0)
[    9.149645] ip is at __check_object_size+0xe0/0x520
[    9.149645] unat: 0000000000000000 pfs : 000000000000038d rsc : 00000000=
00000003
[    9.149645] rnat: 0000000000000000 bsps: 0000000000000000 pr  : 00000000=
0005ca99
[    9.149645] ldrs: 0000000000000000 ccv : 00000002215c8332 fpsr: 0009804c=
8a70033f
[    9.149645] csd : 0000000000000000 ssd : 0000000000000000
[    9.149645] b0  : a000000100233760 b6  : a0000001006e6ba0 b7  : a0000001=
0065b580
[    9.149645] f6  : 000000000000000000000 f7  : 1003e0044b82fa09b5a53
[    9.149645] f8  : 1003e0000000000004932 f9  : 1003e00000000011d6d26
[    9.149645] f10 : 1003e20c49ba5e353f7cf f11 : 1003e00000000002488d9
[    9.149645] r1  : a000000100ef5af0 r2  : a000000100cbda00 r3  : a0000001=
00cbda08
[    9.149645] r8  : 000000000000001f r9  : 0000000000000dc4 r10 : a0000001=
00cd3958
[    9.149645] r11 : ffffffffffffffff r12 : e00000408320fd70 r13 : e0000040=
83208000
[    9.149645] r14 : a000000100cf6438 r15 : a000000100cbda08 r16 : a0000001=
00cbda30
[    9.149645] r17 : 0000000000007fff r18 : 000000000dc206e1 r19 : 00000000=
0000013c
[    9.149645] r20 : 0000000000000003 r21 : 0000000000000000 r22 : 00000000=
00000000
[    9.149645] r23 : 0000000000000dc0 r24 : 0000000000000021 r25 : 00000000=
00006c80
[    9.149645] r26 : 0000000000000dc0 r27 : 0000000000000dc0 r28 : a0000001=
00d1c7c8
[    9.149645] r29 : a00000010052b400 r30 : 0000000000000001 r31 : 00000000=
00000894
[    9.149645]=20
[    9.149645] Call Trace:
[    9.149645]  [<a0000001000131d0>] show_stack+0x90/0xc0
[    9.149645]                                 sp=E00000408320f920 bsp=E000=
004083209340
[    9.149645] Disabling lock debugging due to kernel taint
[    9.293651] Kernel panic - not syncing: Attempted to kill init! exitcode=
=3D0x0000000b
[    9.293651]=20
[    9.293651] ---[ end Kernel panic - not syncing: Attempted to kill init!=
 exitcode=3D0x0000000b


--=20
Meelis Roos (mroos@linux.ee)

From: Andrew Morton <akpm@osdl.org>
Date: Sun, 05 Oct 2003 07:24:57 +0000
Subject: current bk goes BUG on ia64 when dumping core
Message-Id: <marc-linux-ia64-106533868423168@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


When running the latest LTP code, it dies in the new coredump code.

I'm afraid I won't have time to work on this for a week or so.

The ia64 oops code should report current->comm btw.  It is often useful.



kernel BUG at fs/binfmt_elf.c:1366!
abort01[9605]: bugcheck! 0 [1]

Pid: 9605, CPU 2, comm:              abort01
psr : 0000101008026018 ifs : 8000000000001028 ip  : [<a000000100183640>]   =
 Not tainted
ip is at elf_core_dump+0xf20/0x14c0
unat: 0000000000000000 pfs : 0000000000001028 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a65a5a6aae69a957
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100183640 b6  : a00000010001a5c0 b7  : a000000100086cc0
f6  : 1003e0fc0fc0fc0fc0fc1 f7  : 0ffd9a200000000000000
f8  : 1003e0000000000000240 f9  : 1003e0000000000002490
f10 : 1003e000000000ea00000 f11 : 1003e00000000367b7ad0
r1  : a000000100980000 r2  : 0000000000004000 r3  : 0000000000004000
r8  : 0000000000000024 r9  : 0000000000000000 r10 : 00000000000c0180
r11 : 000000000000c018 r12 : e00000000c55fcb0 r13 : e00000000c558000
r14 : e00000000c55fc50 r15 : a00000010079baa8 r16 : 00000000000000fd
r17 : 0000000000000000 r18 : 00000000000000fd r19 : 0000000000000003
r20 : a0000001008fea50 r21 : a0000001008e5a10 r22 : a0000001008fea50
r23 : e000000004974dd0 r24 : e00000003d180038 r25 : e00000003c7e0f00
r26 : 0000000000000000 r27 : 0000000000000000 r28 : 0000000000000000
r29 : 0000000000000000 r30 : 0000000000000000 r31 : 0000000000000000

Call Trace:
 [<a000000100018f00>] show_stack+0x80/0xa0
                                sp=E00000000c55f880 bsp=E00000000c559320
 [<a00000010003ba20>] die+0x180/0x220
                                sp=E00000000c55fa50 bsp=E00000000c5592e8
 [<a00000010003bd40>] ia64_bad_break+0x220/0x340
                                sp=E00000000c55fa50 bsp=E00000000c5592c0
 [<a0000001000120c0>] ia64_leave_kernel+0x0/0x260
                                sp=E00000000c55fae0 bsp=E00000000c5592c0
 [<a000000100183640>] elf_core_dump+0xf20/0x14c0
                                sp=E00000000c55fcb0 bsp=E00000000c559178
 [<a000000100139860>] do_coredump+0x4e0/0x560
                                sp=E00000000c55fd50 bsp=E00000000c559118
 [<a0000001000afdd0>] get_signal_to_deliver+0x6b0/0x900
                                sp=E00000000c55fda0 bsp=E00000000c5590b8
 [<a000000100039820>] ia64_do_signal+0x120/0x460
                                sp=E00000000c55fda0 bsp=E00000000c559038
 [<a000000100019830>] do_notify_resume_user+0xb0/0x100
                                sp=E00000000c55fe20 bsp=E00000000c559008
 [<a000000100012560>] notify_resume_user+0x40/0x60
                                sp=E00000000c55fe20 bsp=E00000000c558fb0
 [<a000000100012490>] skip_rbs_switch+0xb0/0xc0
                                sp=E00000000c55fe30 bsp=E00000000c558fb0
=20

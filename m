From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 08 Dec 2003 22:46:18 +0000
Subject: q-tools OOPS
Message-Id: <marc-linux-ia64-107092374429612@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Hi David,
   Dunno what's going on here.  I've built q-tools against libpfm3.0
and libc 2.3.2.ds1-10.0.1 from Debian using gcc 3.2.3.

When run on a vanilla 2.6.0-test11 kernel, I either get no output, or
an OOPS.  stracing q-syscollect always shows a SEGV in the child
processes, but I think that may be an strace bug.
I guess that this *could* be a preemption problem; have you run
q-syscollect on a machine with CONFIG_PREEMPT on?



Test1:
	sudo q-syscollect -k -t 10
pauses for 10 seconds, creates a ./.q directory, but there's nothing
in it.

Test2:
	q-syscollect sleep 1
causes a kernel panic:

Unable to handle kernel paging request at virtual address 2000000000040000
sleep[2308]: Oops 11012296146944 [1]

Pid: 2308, CPU 0, comm:                sleep
psr : 00001213087a6010 ifs : 8000000000015428 ip  :
[<2000000000023991>]    Not tainted
ip is at 0x2000000000023991
unat: 0000000000000000 pfs : c000000000000a99 rsc : 000000000000000f
rnat: 0000000000000000 bsps: 60000fff7fffc5d0 pr  : ffffffffffd6a6a9
ldrs: 0000000003100000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : 20000000000104f0 b6  : 2000000000015da0 b7  : 0000000000000000
...

I've also caught other panics:  For example q-syscollect -v sleep 1

bad: scheduling while atomic!

Call Trace:
 [<a000000100014980>] show_stack+0x80/0xa0
                                sp=E00000003861fb80 bsp=E0000000386194b0
 [<a000000100082910>] schedule+0x12b0/0x12c0
                                sp=E00000003861fd50 bsp=E0000000386193d0
 [<a0000001001b8d30>] do_get_write_access+0x9f0/0xe80
                                sp=E00000003861fd60 bsp=E000000038619360
 [<a0000001001b9200>] journal_get_write_access+0x40/0x80
                                sp=E00000003861fd90 bsp=E000000038619328
 [<a0000001001a2f70>] ext3_reserve_inode_write+0xd0/0x160
                                sp=E00000003861fd90 bsp=E0000000386192e0
 [<a0000001001a3030>] ext3_mark_inode_dirty+0x30/0x80
                                sp=E00000003861fd90 bsp=E0000000386192c0
 [<a0000001001a31b0>] ext3_dirty_inode+0x130/0x1a0
                                sp=E00000003861fdb0 bsp=E000000038619298
 [<a00000010015f970>] __mark_inode_dirty+0x290/0x2a0
                                sp=E00000003861fdb0 bsp=E000000038619268
 [<a000000100151f80>] update_atime+0x220/0x240
                                sp=E00000003861fdb0 bsp=E000000038619240
 [<a000000100135540>] link_path_walk+0xf00/0x1840
                                sp=E00000003861fdd0 bsp=E0000000386191c8
 [<a0000001001376d0>] open_namei+0xf0/0xa80
                                sp=E00000003861fdf0 bsp=E000000038619160
 [<a000000100110ae0>] filp_open+0x60/0xe0
                                sp=E00000003861fe00 bsp=E000000038619138
 [<a000000100111810>] sys_open+0xb0/0x140
                                sp=E00000003861fe30 bsp=E0000000386190c0
 [<a00000010000db60>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000003861fe30 bsp=E0000000386190c0
bad: scheduling while atomic!

Call Trace:
 [<a000000100014980>] show_stack+0x80/0xa0
                                sp=E000000037fafc50 bsp=E000000037fa9170
 [<a000000100082910>] schedule+0x12b0/0x12c0
                                sp=E000000037fafe20 bsp=E000000037fa9098
 [<a00000010000e0d0>] skip_rbs_switch+0x90/0xe0
                                sp=E000000037fafe30 bsp=E000000037fa9098
Unable to handle kernel paging request at virtual address 20000000000e23dc
sleep[651]: Oops 8804682956800 [1]

Pid: 651, CPU 0, comm:                sleep
psr : 00001013087a6010 ifs : 8000000000000183 ip  : [<2000000000024020>]   =
 Not tainted
ip is at 0x2000000000024020
unat: 0000000000000000 pfs : c000000000001736 rsc : 000000000000000f
rnat: 0000000000000000 bsps: 60000fff7fffc6f0 pr  : 0000000000193729
ldrs: 0000000001900000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : 200000000000c2c0 b6  : 2000000000024b00 b7  : 0000000000000000
f6  : 000000000000000000000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 000000000000000000000
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : 200000000003e750 r2  : 0000000000000000 r3  : 0000000000000001
r8  : 20000000000e23dc r9  : 60000fffffffb660 r10 : 0000000000000000
r11 : 0000000000003a3a r12 : 60000fffffffafa0 r13 : 200000000002d580
r14 : 0000000000000002 r15 : 0000000000004000 r16 : ffffffffffffc000
r17 : 0000000000000000 r18 : 0000000000000000 r19 : 0000000000000000
r20 : 0009804c0270033f r21 : 0000000000000004 r22 : 2000000000024b00
r23 : 60000fff7fffc6f0 r24 : 0000000000000000 r25 : 0000000000000000
r26 : c000000000001736 r27 : 20000000000e23dc r28 : 20000000000e23e0

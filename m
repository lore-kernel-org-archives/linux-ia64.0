From: Bob Montgomery <bob.montgomery@hp.com>
Date: Sat, 26 Mar 2005 01:49:51 +0000
Subject: Can't unwind through dispatch_illegal_op_fault
Message-Id: <1111801791.498.151.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I accidentally discovered that another good way for my buncho crash test
module to oops the system is to mov from ar.bspstore without zeroing the
mode bits on ar.rsc.  The resulting illegal op doesn't unwind past=20
dispatch_illegal_op_fault.

I'm testing on a 2.6.10 based system (with other patches), and get the
following oops message, stopping at dispatch_illegal_op_fault.  Is this
a quick question for the ivt.S folks, or should I prepare a test module
for a stock kernel?

Thanks,
Bob Montgomery, HP

--
buncho about to read ar.bspstore with wrong rsc on CPU 0
bunchotest[1710]: IA-64 Illegal operation fault 0 [1]
Modules linked in: buncho buncho1 buncho2 buncho3 buncho4 buncho5
buncho6 buncho7 buncho8 buncho_utils ipv6 dump_blockdev dump_gzip
zlib_deflate dump

Pid: 1710, CPU 0, comm:           bunchotest
psr : 0000101008026018 ifs : 8000000000000185 ip  : [<a0000002000f8a40>]
Not tainted
ip is at buncho_going_to_illegal_op+0x40/0xa0 [buncho]
unat: 0000000000000000 pfs : 0000000000000185 rsc : 0000000000000003
rnat: 0009804c0270033f bsps: 00000000000003e8 pr  : 0a40000000166965
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000002000f8a30 b6  : a000000100002d70 b7  : a0000001000cad20
f6  : 1003e8080808080808081 f7  : 1003e0000000000000080
f8  : 1003e0000000000001200 f9  : 1003e00000000000023dc
f10 : 1003e000000000e580000 f11 : 1003e00000000356f424c
r1  : a0000002002f8000 r2  : 0000000000004000 r3  : 0000000000004000
r8  : 000000000000003b r9  : a000000100687bb0 r10 : a000000100687bb0
r11 : 0000000000000100 r12 : e0000040fdd1fe20 r13 : e0000040fdd18000
r14 : 00000000000000fd r15 : a000000100687bb0 r16 : 0000000000000000
r17 : e0000040fe1cfde8 r18 : 00000000000000fd r19 : 0000000000000001
r20 : a00000010079fdc0 r21 : a0000001007841c8 r22 : a00000010079fdc0
r23 : 0000000000000004 r24 : 0000000000000000 r25 : 0000000000000000
r26 : 0000000000000000 r27 : 0000000000000000 r28 : 0000000000000000
r29 : 0000000000000004 r30 : e0000040ffe08d50 r31 : 0000000000000000

Call Trace:
 [<a000000100012940>] show_stack+0x80/0xa0
                                sp=E0000040fdd1f8d0 bsp=E0000040fdd18fb8
 [<a0000001000131c0>] show_regs+0x800/0x820
                                sp=E0000040fdd1faa0 bsp=E0000040fdd18f60
    r32 : e0000040fdd1fc60 r33 : 0000000000000000 r34 : e0000040fdd1fd18
    r35 : e0000040fdd1fcd8 r36 : e0000040fdd1fcf0 r37 : e0000040fdd1fcb0
    r38 : e0000040fdd1fca0 r39 : 00000fffffffbfff r40 : a000000100036b50
    r41 : 000000000000040e r42 : e00000417dd1fbde
 [<a000000100036b50>] die+0x150/0x2c0
                                sp=E0000040fdd1fab0 bsp=E0000040fdd18f20
    r32 : e0000040fdd1fbe0 r33 : e0000040fdd1fc60 r34 : 0000000000000000
    r35 : a00000010067a1b8 r36 : a00000010067a1bc r37 : a000000100036d00
    r38 : 0000000000000309 r39 : a000000100570bc0
 [<a000000100036d00>] die_if_kernel+0x40/0x60
                                sp=E0000040fdd1fb30 bsp=E0000040fdd18ef0
    r32 : e0000040fdd1fbe0 r33 : e0000040fdd1fc60 r34 : 0000000000000000
    r35 : a0000001000376c0 r36 : 000000000000048c r37 : e0000040fdd1fde0
 [<a0000001000376c0>] ia64_illegal_op_fault+0x60/0x160
                                sp=E0000040fdd1fb30 bsp=E0000040fdd18ea8
    r32 : e0000040fdd1fb60 r33 : 0000000000000000 r34 : e0000040fdd1fbe0
    r35 : a000000100974450 r36 : e0000040fdd18000 r37 : 0000000000000015
    r38 : a000000100003f20 r39 : 0000000000000001 r40 : e0000040fdd1fde0
 [<a000000100003f20>] dispatch_illegal_op_fault+0x300/0x800
                                sp=E0000040fdd1fc50 bsp=E0000040fdd18ea8



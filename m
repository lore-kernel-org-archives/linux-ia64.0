From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 17 Jul 2003 00:21:13 +0000
Subject: NaT consumption faults in current 2.5 BK kernel
Message-Id: <marc-linux-ia64-105840128613012@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


OK, thanks to the latest mod from David, I have the system running on
the simulator.  Hurrah.=20

I can see a NaT consumption fault every time I cat /proc/net/dev

Is there any easy way to track down what's causing this?
The offending code section is:

   dev_seq_pr*+02a0       ld8              r3=3D[r15],8
     MII
                          mov              r34=3Dgp
                          mov              r38=3Dr33;;
			  ld8		   r1=3D[r15]
			  mov		   b7=3Dr3
			  br.call.sptk.many b0=B7
			  ;;


in the middle of dev_seq_printf_stats().

I suspect a compiler or assembler bug.  I can't see anything obviously
wrong with the generated code.

The branch to dev_seq_printf+0x2a0 is here:

        alloc r37 =3D ar.pfs,3,3,8,0
        adds r12 =3D -96, r12
        mov r11 =3D r0
        adds r2 =3D 88, r33
        mov r36 =3D b0
        .body
	;;
	nop.i 0
	ld8 r15 =3D [r2]
        nop.f 0
        nop.b 0
        ;;
        cmp.eq p8, p9 =3D 0, r15
        nop.i 0
        (p9) br.cond.dpnt.few dev_seq_pr*+02a0
	.mii
	adds r15=80,r11
	adds r16=88,r11
	adds r17=96,r11
	...


cat[174]: NaT consumption 17179869216 [4]

Pid: 174, CPU 0, comm:                  cat
psr : 0000101008026018 ifs : 800000000000030e ip  :
[<a000000100266f60>]    Not tainted

ip is at dev_seq_printf_stats+0x2a0/0x2e0
unat: 0000000000000000 pfs : 0000000000000309 rsc : 0000000000000003
rnat: 0000000000000000 bsps: a00000010065b830 pr  : 000000000006aa19
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100266fe0 b6  : a000000100002d70 b7  : a000000100266fa0
f6  : 1003e0000000000004000 f7  : 1003e0000000000000040
f8  : 1003e0000000000000000 f9  : 1003e0000000000000000
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a00000010065b830 r2  : e000000007f42858 r3  : 0000000000000002
r8  : e000000007f42800 r9  : 0000000000004000 r10 : 0000000000000143
r11 : 0000000000000000 r12 : e0000000075bfdb0 r13 : e0000000075b8000

Call Trace:
 [<a000000100013a20>] show_stack+0x80/0xa0
                                sp=E0000000075bf910
bsp=E0000000075b9028
 [<a000000100020190>] die+0x130/0x1c0
                                sp=E0000000075bfae0
bsp=E0000000075b9000
 [<a000000100020f70>] ia64_fault+0x150/0xec0
                                sp=E0000000075bfae0
bsp=E0000000075b8fb8
 [<a00000010000d840>] ia64_leave_kernel+0x0/0x260
                                sp=E0000000075bfbe0
bsp=E0000000075b8fb8
 [<a000000100266f60>] dev_seq_printf_stats+0x2a0/0x2e0
                                sp=E0000000075bfdb0
bsp=E0000000075b8f48
 [<a000000100266fe0>] dev_seq_show+0x40/0x100
                                sp=E0000000075bfe10
bsp=E0000000075b8f18
 [<a0000001001041e0>] seq_read+0x4c0/0x760
                                sp=E0000000075bfe10
bsp=E0000000075b8e88
 [<a0000001000c6100>] vfs_read+0x200/0x2a0
                                sp=E0000000075bfe20
bsp=E0000000075b8e40
 [<a0000001000c65e0>] sys_read+0x60/0xc0
                                sp=E0000000075bfe20
bsp=E0000000075b8dc8
 [<a00000010000d6c0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000000075bfe30
bsp=E0000000075b8dc8
 Segmentation fault

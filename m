From: Andreas Schwab <schwab@suse.de>
Date: Fri, 27 Feb 2004 10:16:03 +0000
Subject: Re: Oops in pdflush
Message-Id: <je4qtcu8t8.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

> In any case, it's not good that the stack-trace is truncated.
> gcc-3.3.3 should be good enough, so I'm not sure off hand what's going
> wrong.  If you could enable unwind-debugging (set UNW_DEBUG to 5 in
> arch/ia64/kernel/unwind.c) and capture the resulting output during a
> crash, it might get us further.

Here's what I get:

pdflush[18140]: Oops 11012296146944 [1]

Pid: 18140, CPU 1, comm:              pdflush
psr : 0000121008026018 ifs : 8000000000000590 ip  : [<a00000010046e0d1>]   =
 Not tainted
ip is at nf_iterate+0x111/0x240
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: e00000003ccc4800 bsps: 0000000000000000 pr  : 82aa6aa6a555a59b
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010046e0f0 b6  : a0000001002968e0 b7  : a000000100260540
f6  : 000000000000000000000 f7  : 1003e000000000011d541
f8  : 1003e0000000000680264 f9  : 1003e00000000032c92ae
f10 : 1003e000000000023aa82 f11 : 1003e0000000000000001
r1  : a000000100a17200 r2  : ffffffffffefffff r3  : 0000000000100000
r8  : 0000000000000001 r9  : 0000000000000000 r10 : a000000100a17228
r11 : 0000000000000000 r12 : e0000000110e6790 r13 : e0000000110e0000
r14 : 0000000000000001 r15 : a000000100a17200 r16 : a000000100a17210
r17 : e00000003feb5400 r18 : a000000100a17200 r19 : 0000000000000000
r20 : a000000100a17200 r21 : 0000000000100000 r22 : 0000000000100000
r23 : a000000100885220 r24 : e0000000110e6750 r25 : e00000003feb541c
r26 : 00000000ffffffff r27 : e00000003feb5418 r28 : 0000000000000000
r29 : e00000003feb5414 r30 : 0000000000100000 r31 : e00000003feb5410
unwind.init_frame_info:
  task   0xe0000000110e0000
  rbs =3D [0xe0000000110e0ef0-0xe0000000110e6ac8)
  stk =3D [0xe0000000110e6ac8-0xe0000000110e8000)
  pr     0x82aa6aa6a55596a7
  sw     0xe0000000110e6160
  sp     0xe0000000110e6ac8
unwind.unw_init_frame_info:
  bsp    0xe0000000110e6aa8
  sol    0x4
  ip     0xa000000100016ac0
unwind.build_script: ip 0xa000000100016ac0
unwind.build_script: state record for func 0xa000000100016a40, t$:
  ar.pfs <- r34		0
  psp <- psp+0x1d0		1
  rp <- r33		4

Call Trace:
 [<a000000100016ac0>] show_stack+0x80/0xa0
                                sp=E0000000110e6ac8 bsp=E0000000110e6aa8
unwind.build_script: ip 0xa000000100039350
unwind.build_script: state record for func 0xa0000001000391e0, ti:
  ar.pfs <- r37		0
  rp <- r36		4
 [<a000000100039350>] die+0x170/0x220
                                sp=E0000000110e6c98 bsp=E0000000110e6a70
unwind.build_script: ip 0xa000000100058e60
unwind.build_script: state record for func 0xa000000100058740, t42:
  ar.pfs <- r43		0
  psp <- psp+0x90		1
  rp <- r42		10
 [<a000000100058e60>] ia64_do_page_fault+0x720/0xa60
                                sp=E0000000110e6c98 bsp=E0000000110e6a08
unwind.build_script: ip 0xa00000010000d640
unwind.desc_abi: interrupt frame
unwind.build_script: state record for func 0xa00000010000d640, t=3D0:
  ar.pfs <- [sp+0x60]		-1
  psp <- psp+0x1d0		-1
  rp <- [sp+0x58]		-1
  ar.unat <- [sp+0x68]		-1
  pr <- [sp+0x90]		-1
  ar.fpsr <- [sp+0xc0]		-1
 [<a00000010000d640>] ia64_leave_kernel+0x0/0x260
                                sp=E0000000110e6d28 bsp=E0000000110e6a08
unwind.unw_unwind: reached user-space (ip=3D0x148e)
 unwind.init_frame_info:
  task   0xe0000000110e0000
  rbs =3D [0xe0000000110e0ef0-0xe0000000110e6b88)
  stk =3D [0xe0000000110e6b88-0xe0000000110e8000)
  pr     0x82aa6955a69aa99b
  sw     0xe0000000110e6300
  sp     0xe0000000110e6b88
unwind.init_frame_info:
  task   0xe0000000026f8000
  rbs =3D [0xe0000000026f8ef0-0xe0000000026f93d8)
  stk =3D [0xe0000000026ffbf0-0xe000000002700000)
  pr     0x90000050a655955b
  sw     0xe0000000026ff9f0
  sp     0xe0000000026ffbf0
unwind.init_frame_info:
  task   0xe000000021e10000
  rbs =3D [0xe000000021e10ef0-0xe000000021e11a10)
  stk =3D [0xe000000021e173a0-0xe000000021e18000)
  pr     0x900155566655955b
  sw     0xe000000021e171a0
  sp     0xe000000021e173a0
unwind.init_frame_info:
  task   0xe000000003b70000
  rbs =3D [0xe000000003b70ef0-0xe000000003b71948)
  stk =3D [0xe000000003b77810-0xe000000003b78000)
  pr     0x90000050a655959b
  sw     0xe000000003b77610
  sp     0xe000000003b77810
unwind.unw_init_frame_info:
  bsp    0xe0000000026f9370
  sol    0xd
  ip     0xa0000001003ff290
unwind.unw_init_frame_info:
  bsp    0xe000000003b718e0
  sol    0xd
  ip     0xa0000001003ff290
unwind.unw_init_frame_info:
  bsp    0xe000000021e119a0
  sol    0xd
  ip     0xa0000001003ff290
unwind.build_script: ip 0xa0000001003ff290
unwind.build_script: ip 0xa0000001003ff290
unwind.build_script: ip 0xa0000001003ff290
unwind.build_script: state record for func 0xa0000001003ff140, tc:
  ar.pfs <- r43		0
  psp <- psp+0x20		1
  rp <- r42		7
unwind.build_script: state record for func 0xa0000001003ff140, tc:
  ar.pfs <- r43		0
  psp <- psp+0x20		1
  rp <- r42		7
unwind.build_script: state record for func 0xa0000001003ff140, tc:
  ar.pfs <- r43		0
  psp <- psp+0x20		1
  rp <- r42		7
unwind.unw_init_frame_info:
  bsp    0xe0000000110e6b20
  sol    0xd
  ip     0xa0000001003ff290
unwind.build_script: ip 0xa0000001003ff290
unwind.build_script: state record for func 0xa0000001003ff140, tc:
  ar.pfs <- r43		0
  psp <- psp+0x20		1
  rp <- r42		7

Entering kdb (current=3D0xe0000000110e0000, pid 18140) on processor 1 Oops:=
 <NULL>
due to oops @ 0xa00000010046e0d1
 psr: 0x0000121008026018   ifs: 0x8000000000000590    ip: 0xa00000010046e0d=
0 =20
unat: 0x0000000000000000   pfs: 0x0000000000000590   rsc: 0x000000000000000=
3 =20
rnat: 0xe00000003ccc4800  bsps: 0x0000000000000000    pr: 0x82aa6aa6a555a59=
b =20
ldrs: 0x0000000000000000   ccv: 0x0000000000000000  fpsr: 0x0009804c0270033=
f =20
  b0: 0xa00000010046e0f0    b6: 0xa0000001002968e0    b7: 0xa00000010026054=
0 =20
  r1: 0xa000000100a17200    r2: 0xffffffffffefffff    r3: 0x000000000010000=
0 =20
  r8: 0x0000000000000001    r9: 0x0000000000000000   r10: 0xa000000100a1722=
8 =20
 r11: 0x0000000000000000   r12: 0xe0000000110e6790   r13: 0xe0000000110e000=
0 =20
 r14: 0x0000000000000001   r15: 0xa000000100a17200   r16: 0xa000000100a1721=
0 =20
 r17: 0xe00000003feb5400   r18: 0xa000000100a17200   r19: 0x000000000000000=
0 =20
 r20: 0xa000000100a17200   r21: 0x0000000000100000   r22: 0x000000000010000=
0 =20
 r23: 0xa000000100885220   r24: 0xe0000000110e6750   r25: 0xe00000003feb541=
c =20
 r26: 0x00000000ffffffff   r27: 0xe00000003feb5418   r28: 0x000000000000000=
0 =20
 r29: 0xe00000003feb5414   r30: 0x0000000000100000   r31: 0xe00000003feb541=
0 =20
&regs =3D e0000000110e65d0

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

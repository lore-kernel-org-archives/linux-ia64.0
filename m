From: Roel Teuwen <roel.teuwen@gmail.com>
Date: Fri, 30 Jul 2004 14:24:51 +0000
Subject: 2.6.7-ia64-040629 : kernel BUG at mm/slab.c:1392!
Message-Id: <1b137cb704073007247c14be96@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I consistently get the kernel BUG pasted below, running
linux-2.6.7-ia64-040629 on a HP rx4640, Debian unstable

This machine is running from lvm2 root

Please CC: me as I am not subscribed to the list.

Best regards,

Roel Teuwen

=3D
kmem_cache_create: duplicate cache dm_io
kernel BUG at mm/slab.c:1392!
modprobe[852]: bugcheck! 0 [1]
Modules linked in: dm_mod acpiphp

Pid: 852, CPU 0, comm:             modprobe
psr : 0000101008026038 ifs : 8000000000000999 ip  :
[<a0000001000f4d90>]    Not tainted
ip is at kmem_cache_create+0xb0/0xc20
unat: 0000000000000000 pfs : 0000000000000999 rsc : 0000000000000003
rnat: 0000000000000000 bsps: c0000000000bb3c2 pr  : 1945915551559655
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000f4d90 b6  : a000000100009120 b7  : a00000010024fa00
f6  : 1003e00000000000000a0 f7  : 0ffd9a200000000000000
f8  : 1003e00000000000000a0 f9  : 1003e0000000000000001
f10 : 0fffbccccccccc8c00000 f11 : 1003e0000000000000000
r1  : a0000001009a6ea0 r2  : ffffffffffffd1fa r3  : 0000000000000000
r8  : 000000000000001e r9  : 0000000000000000 r10 : a0000001007457f0
r11 : 00000000000fffff r12 : e000000001fefe20 r13 : e000000001fe8000
r14 : 0000000000000001 r15 : 0000000000000001 r16 : 0000000000000000
r17 : a0000001007b9d20 r18 : 00000000000000ff r19 : 0000000003ffffff
r20 : a0000001007b9d50 r21 : a0000001007b9d28 r22 : a0000001007a9430
r23 : 0000000000000000 r24 : e000000001fe8ea0 r25 : e000000001fe8eb0
r26 : 0000000000000000 r27 : 0000000000000001 r28 : 0000000000004000
r29 : 0000000000004000 r30 : 0000000000000000 r31 : a0000001007b9d1c

Call Trace:
 [<a00000010001a1a0>] show_stack+0x80/0xa0
                                sp=E000000001fef9f0 bsp=E000000001fe9118
 [<a0000001000407a0>] die+0x1e0/0x2c0
                                sp=E000000001fefbc0 bsp=E000000001fe90e0
 [<a000000100040b00>] ia64_bad_break+0x220/0x340
                                sp=E000000001fefbc0 bsp=E000000001fe90b8
 [<a0000001000122e0>] ia64_leave_kernel+0x0/0x280
                                sp=E000000001fefc50 bsp=E000000001fe90b8
 [<a0000001000f4d90>] kmem_cache_create+0xb0/0xc20
                                sp=E000000001fefe20 bsp=E000000001fe8fe8
 [<a0000002000001c0>] local_init+0x40/0x1a0 [dm_mod]
                                sp=E000000001fefe30 bsp=E000000001fe8fb0
 [<a000000200000370>] dm_init+0x50/0x140 [dm_mod]
                                sp=E000000001fefe30 bsp=E000000001fe8f80
 [<a0000001000d5c10>] sys_init_module+0x410/0x7e0
                                sp=E000000001fefe30 bsp=E000000001fe8f08
 [<a000000100012140>] ia64_ret_from_syscall+0x0/0x20
                                sp=E000000001fefe30 bsp=E000000001fe8f08

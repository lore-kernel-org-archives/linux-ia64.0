From: Jay Lan <jlan@sgi.com>
Date: Thu, 10 Aug 2006 19:28:42 +0000
Subject: Re: [Fastboot] Ia64 kdump patch
Message-Id: <44DB88EA.3010508@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Nanhai and horms,

Zou, Nanhai wrote:
>=20
[snip]
>  Forget to mention,
>  If you are using same kernel as first and crash kernel, you'd better pas=
s an additional=20
>  "maxcpus=3D1" kernel parameter to the second kernel.

The "maxpus=3D1' did help. Without it, the kernel went into double panic.
However, with "maxcpus=3D1" i saw crash dump and Call Trace...

holism.engr.sgi.com login: SysRq : Trigger a crashdump=20
         kernel BUG at kernel/irq/migration.c:39!=20
                  bash[3213]: bugcheck! 0 [1]=20
                           Modules linked in: radeon drm agpgart nfs=20
lockd sunrpc binfmt_misc dm_mirror dmi=20
                                               Pid: 3213, CPU 1, comm:=20
                bash                                    psr :=20
00001010085a2010 ifs : 800000000000038b ip  : [<a0000001000e1c00>]=20
Notdip is at move_native_irq+0x1a0/0x360=20
             unat: 0000000000000000 pfs : 000000000000038b rsc :=20
0000000000000000            rnat: d6304e388f73eebc bsps:=20
9d40fde11cbbf11b pr  : 0000000000596599            ldrs:=20
0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f=20
   csd : 0000000000000000 ssd : 0000000000000000=20
            b0  : a0000001000e1c00 b6  : a000000100036060 b7  :=20
a000000100010150            f6  : 1003e0000006c1c8a11a7 f7  :=20
1003e0000000000000514                         f8  :=20
1003e0000006c1c8a0c93 f9  : 1003e0000000000000001=20
   f10 : 0fffd9999999996900000 f11 : 1003e0000000000000000=20
            r1  : a000000100b66020 r2  : 000000000000048d r3  :=20
a0000001009665b8            r8  : 000000000000002c r9  :=20
0000000000003446 r10 : a00000010097d1f8            r11 :=20
0000000000000000 r12 : e00000001a62f7e0 r13 : e00000001a628000=20
   r14 : 0000000000004000 r15 : a00000010097d200 r16 : 0000000000000000=20
            r17 : 0000000000004000 r18 : 0000000000000060 r19 :=20
0000000000004000            r20 : a00000010097c430 r21 :=20
0000000000000000 r22 : a00000010096a4b8            r23 :=20
a00000010097d210 r24 : a00000010097d1f0 r25 : a000000100910c88=20
   r26 : a000000100910c88 r27 : a000000100966270 r28 : 0000000000000034=20
            r29 : 0000000000000034 r30 : 0000000000000000 r31 :=20
a00000010097d1cc=20
                                     Call Trace:=20
                                               [<a000000100013880>]=20
show_stack+0x40/0xa0=20
                   sp=E00000001a62f370 bsp=E00000001a6294b8=20
[<a0000001000144e0>] show_regs+0x840/0x880=20
                                        sp=E00000001a62f540=20
bsp=E00000001a629460         [<a0000001000363a0>] die+0x1c0/0x2e0=20
=20
sp=E00000001a62f540 bsp=E00000001a629418         [<a000000100036510>]=20
die_if_kernel+0x50/0x80=20
                   sp=E00000001a62f560 bsp=E00000001a6293e0=20
[<a000000100037c10>] ia64_bad_break+0x270/0x4a0=20
                                        sp=E00000001a62f560=20
bsp=E00000001a6293b8         [<a00000010000c320>]=20
ia64_leave_kernel+0x0/0x280=20
                   sp=E00000001a62f610 bsp=E00000001a6293b8=20
[<a0000001000e1c00>] move_native_irq+0x1a0/0x360=20
                                        sp=E00000001a62f7e0=20
bsp=E00000001a629360         [<a00000010004ecb0>]=20
iosapic_end_level_irq+0x30/0xe0=20
                   sp=E00000001a62f7e0 bsp=E00000001a629340=20
[<a00000010005d620>] machine_crash_shutdown+0x5c0/0x680=20
                                        sp=E00000001a62f7e0=20
bsp=E00000001a629300         [<a0000001000d4fd0>] crash_kexec+0x70/0xc0=20
=20
sp=E00000001a62fc60 bsp=E00000001a6292e0         [<a00000010045dfc0>]=20
sysrq_handle_crashdump+0x20/0x40=20
                   sp=E00000001a62fe20 bsp=E00000001a6292b8=20
[<a00000010045e1a0>] __handle_sysrq+0x160/0x300=20
                                        sp=E00000001a62fe20=20
bsp=E00000001a629268         [<a0000001001b9770>]=20
write_sysrq_trigger+0xb0/0xe0=20
                   sp=E00000001a62fe20 bsp=E00000001a629238=20
[<a00000010012f1d0>] vfs_write+0x1b0/0x340=20
                                        sp=E00000001a62fe20=20
bsp=E00000001a6291e0         [<a00000010012fe50>] sys_write+0x70/0xe0=20
=20
sp=E00000001a62fe20 bsp=E00000001a629168         [<a00000010000c180>]=20
ia64_ret_from_syscall+0x0/0x20=20
                   sp=E00000001a62fe30 bsp=E00000001a629168=20
[<a000000000010620>] __kernel_syscall_via_break+0x0/0x20=20
                                        sp=E00000001a630000=20
bsp=E00000001a629168=20
                                     Fedora Core release 5 (Bordeaux)=20
                                              Kernel 2.6.18-rc2 on an=20
ia64=20
=20
holism.engr.sgi.com login:

However, the second kernel was not booted and system remained
alive.

The /proc/{sysrq-trigger,iomem} after the trigger were as below:
(holism,9) ls -l /proc/{sysrq-trigger,iomem}
-r--r--r-- 1 root root 0 Aug  9 08:10 /proc/iomem
--w------- 1 root root 0 Aug  9 08:10 /proc/sysrq-trigger
(holism,10)

I built the kernel based on 2.6.18-rc2 with Nanhai's
kexec-kdump-ia64-2.6.16.patch and my fixes to
   - replace  irq_descp(dev->irq) with irq_desc + dev->irq
   - replace  desc->handle with desc-chip
for compilation.

As to kexec-tools, i use kdump9 with Nanhai's
kexec-tools-kdump9-ia64-zou.patch.

What did i miss here? Do i miss any patch(es)?
My machine is a HP zx6000 loaded with FC5.

Thanks!
  - jay

>=20
> Thanks
> Zou Nan hai

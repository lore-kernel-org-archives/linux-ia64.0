From: Jay Lan <jlan@sgi.com>
Date: Tue, 15 Aug 2006 01:56:27 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <44E129CB.5060709@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bob Montgomery wrote:
> On Mon, 2006-08-14 at 14:47 +0800, Zou Nan hai wrote:
>=20
>>This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.
>=20
>=20
> Contrary to expectations, my experience with this patch on a 2.6.18-rc4
> kernel is that kexec -l, kexec -e is now working without my adding any
> delays to mptscsih, and the kexec -p, echo c >/proc/sysrq-trigger case
> hangs.
>=20
> My "got here" printk's on the console indicate:
>=20
> SysRq : Trigger a crashdump
> machine_crash_shutdown
> device_shootdown
> machine_kexec type: 1
>=20
> And then it hangs.

Hi,

I got it further down.

>=20
> My test system: hp A6870A server rx2600
>>From /proc/iomem:
> 04a1f000-3f5e3fff : System RAM
>   10000000-17ffffff : Crash kernel
>=20

My test system is a zx6000.
Here is from /proc/iomem:
04aaf000-3e417fff : System RAM
   10000000-17ffffff : Crash kernel

I used 'make tiger_defconfig', then set on CONFIG_KEXEC,
CONFIG_CRASH_DUMP, and CONFIG_PROC_VMCOR.


Here are shown on console:
SysRq : Trigger a crashdump
kernel BUG at kernel/irq/migration.c:39!
bash[4846]: bugcheck! 0 [1]
Modules linked in: radeon drm agpgart nfs lockd sunrpc binfmt_misc=20
dm_mirror dmi
Pid: 4846, CPU 0, comm:                 bash
psr : 00001010085a2010 ifs : 800000000000038b ip  : [<a0000001000e2520>]=20
    Notdip is at move_native_irq+0x1a0/0x360
unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000000059a999
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000e2520 b6  : a0000001000bc7c0 b7  : a00000010004ec60
f6  : 1003e00000000000000a0 f7  : 1003e20c49ba5e353f7cf
f8  : 1003e00000000000004e2 f9  : 1003e000000000fa00000
f10 : 1003e000000003b9aca00 f11 : 1003e431bde82d7b634db
r1  : a000000100b663c0 r2  : 0000000000001000 r3  : a000000100910e88
r8  : 000000000000002c r9  : 00000000000000fd r10 : a00000010097c750
r11 : 0000000000000000 r12 : e00000001c157c60 r13 : e00000001c150000
r14 : 0000000000004000 r15 : a000000100910e88 r16 : a000000100910e90
r17 : 0000000000004000 r18 : 0000000000000000 r19 : 0000000000000001
r20 : a000000100985f98 r21 : a000000100985f98 r22 : 0000000000000004
r23 : 0000000000000000 r24 : e00000003f3e0f64 r25 : 0000000000000000
r26 : e00000003f3e0f6c r27 : e00000003f3e0f50 r28 : e00000003f3e0008
r29 : 0000000000000000 r30 : 0000000000000000 r31 : 0000000000000000

Call Trace:
  [<a0000001000138e0>] show_stack+0x40/0xa0
                                 sp=E00000001c1577f0 bsp=E00000001c1514a8
  [<a000000100014540>] show_regs+0x840/0x880
                                 sp=E00000001c1579c0 bsp=E00000001c151450
  [<a000000100036400>] die+0x1c0/0x2c0
                                 sp=E00000001c1579c0 bsp=E00000001c151408
  [<a000000100036550>] die_if_kernel+0x50/0x80
                                 sp=E00000001c1579e0 bsp=E00000001c1513d0
  [<a000000100037c50>] ia64_bad_break+0x270/0x4a0
                                 sp=E00000001c1579e0 bsp=E00000001c1513a8
  [<a00000010000c320>] ia64_leave_kernel+0x0/0x280
                                 sp=E00000001c157a90 bsp=E00000001c1513a8
  [<a0000001000e2520>] move_native_irq+0x1a0/0x360
                                 sp=E00000001c157c60=20
bsp=E00000001c151350
  [<a00000010004ec90>] iosapic_end_level_irq+0x30/0xe0
                                 sp=E00000001c157c60=20
bsp=E00000001c151330
  [<a00000010005d4e0>] machine_crash_shutdown+0x120/0x220
                                 sp=E00000001c157c60=20
bsp=E00000001c151300
  [<a0000001000d5890>] crash_kexec+0x70/0xc0
                                 sp=E00000001c157c60=20
bsp=E00000001c1512e0
  [<a00000010045ee00>] sysrq_handle_crashdump+0x20/0x40
                                 sp=E00000001c157e20=20
bsp=E00000001c1512b8
  [<a00000010045efe0>] __handle_sysrq+0x160/0x300
                                 sp=E00000001c157e20=20
bsp=E00000001c151268
  [<a0000001001ba0b0>] write_sysrq_trigger+0xb0/0xe0
                                 sp=E00000001c157e20=20
bsp=E00000001c151238
  [<a00000010012fad0>] vfs_write+0x1b0/0x340
                                 sp=E00000001c157e20=20
bsp=E00000001c1511e0
  [<a000000100130750>] sys_write+0x70/0xe0
                                 sp=E00000001c157e20=20
bsp=E00000001c151168
  [<a00000010000c180>] ia64_ret_from_syscall+0x0/0x20
                                 sp=E00000001c157e30=20
bsp=E00000001c151168
  [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
                                 sp=E00000001c158000=20
bsp=E00000001c151168
  <4>hda: lost interrupt
mptscsih: ioc0: attempting task abort! (sc=E00000003e42ba00)
sd 0:0:0:0:
         command: cdb[0]=3D0x4d: 4d 00 6f 00 00 00 00 00 04 00
mptbase: Initiating ioc0 recovery
mptscsih: ioc0: task abort: SUCCESS (sc=E00000003e42ba00)
mptscsih: ioc0: attempting task abort! (sc=E00000003e42ba00)
sd 0:0:0:0:
         command: cdb[0]=3D0x0: 00 00 00 00 00 00
mptbase: Initiating ioc0 recovery
mptscsih: ioc0: task abort: SUCCESS (sc=E00000003e42ba00)
mptscsih: ioc0: attempting task abort! (sc=E00000003e429c00)
sd 0:0:0:0:
         command: cdb[0]=3D0x0: 00 00 00 00 00 00
mptbase: Initiating ioc0 recovery
mptscsih: ioc0: task abort: SUCCESS (sc=E00000003e429c00)
mptscsih: ioc0: attempting task abort! (sc=E00000003e42bd00)
sd 0:0:0:0:
         command: cdb[0]=3D0x0: 00 00 00 00 00 00
ide-cd: cmd 0x3 timed out
hda: lost interrupt
...


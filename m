From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Sun, 25 Oct 2020 18:27:59 +0000
Subject: Random failures while loading modules with kernel 5.x
Message-Id: <CAA9xbM53e89L0bwZim1c_UacbNaxvr8w=wOnYumvBWP90O6aLg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I'm getting random failures at boot time while loading modules with
kernel 5.x. I'm dual-booting LTS 4.x kernel (4.19.152 at the moment)
and never had any issue with the latter.

Are you experiencing similar problems? I can provide complete dmesg
outputs if helpful but here are excerpts showing the kind of bugs I'm
currently facing (various kernels or kernel configurations):


Kernel 5.6.5:

[   18.599225] systemd-udevd[1690]: NaT consumption 2216203124768 [1]
[   18.599225] Modules linked in: snd_hwdep snd_rawmidi drm
snd_seq_device snd_pcm tg3(+) drm_panel_orientation_quirks backlight
i2c_core snd_timer e100 libphy fm801_gp snd gameport soundcore mii
hwmon efivarfs configfs fuse nfs lockd grace sunrpc

[   18.599225] CPU: 0 PID: 1690 Comm: systemd-udevd Not tainted
5.6.5-gentoo-ia64 #1
[   18.599225] Hardware name: hp workstation zx6000              ,
BIOS 02.31
03/11/2004
[   18.599225] psr : 00001210085a6010 ifs : 800000000000152e ip  :
[<a000000100051281>]    Not tainted (5.6.5-gentoo-ia64)
[   18.599225] ip is at apply_relocate_add+0x2c1/0x13a0
[   18.599225] unat: 0000000000000000 pfs : 0000000000001a3c rsc :
0000000000000003
[   18.599225] rnat: 0000000000000000 bsps: 0000000000000000 pr  :
00000001a666a659
[   18.599225] ldrs: 0000000000000000 ccv : e000004080fe8000 fpsr:
0009804c8a70433f
[   18.599225] csd : 0000000000000000 ssd : 0000000000000000
[   18.599225] b0  : a000000100196e90 b6  : a000000100190380 b7  :
a00000010000c7a0
[   18.599225] f6  : 1003e0000000000000b10 f7  : 1003eaaaaaaaaaaaaaaab
[   18.599225] f8  : 1003e0000000000000760 f9  : 1003e0000000000000000
[   18.599225] f10 : 1003e0000000000000000 f11 : 1003ecccccccccccccccd
[   18.599225] r1  : a0000001014029a0 r2  : 0000000000000100 r3  :
0000000000000000
[   18.599225] r8  : 0000000000000009 r9  : a0000002000c8000 r10 :
0000000000000005
[   18.599225] r11 : 0000000000000810 r12 : e000004080fefd00 r13 :
e000004080fe8000
[   18.599225] r14 : 0000000000000810 r15 : 00000000000000ac r16 :
0000000000000056
[   18.599225] r17 : 0000000000000102 r18 : 0000000000000005 r19 :
0000000000000818
[   18.599225] r20 : 0000000000000076 r21 : 0000000000000028 r22 :
a000000100e5a830
[   18.599225] r23 : ffffffffff1f7040 r24 : 0000000000002b5b r25 :
0000000000400000
[   18.599225] r26 : 0000000000002b62 r27 : a0000002000cd158 r28 :
a0000002000c8000
[   18.599225] r29 : 0000000000002b60 r30 : a0000002000cab60 r31 :
0000000000000075
[   18.599225]
               Call Trace:
[   18.599225]  [<a000000100015070>] show_stack+0x90/0xc0
                                               sp=3De000004080fef8c0
bsp=3De000004080fe9410
[   18.599225]  [<a000000100015760>] show_regs+0x6c0/0xa20
                                               sp=3De000004080fefa90
bsp=3De000004080fe9398
[   18.599225]  [<a000000100029030>] die+0x1b0/0x4a0
                                               sp=3De000004080fefab0
bsp=3De000004080fe9358
[   18.599225]  [<a00000010002a490>] ia64_fault+0x770/0xd80
                                               sp=3De000004080fefab0
bsp=3De000004080fe9308
[   18.599225]  [<a00000010000cf80>] ia64_leave_kernel+0x0/0x270
                                               sp=3De000004080fefb30
bsp=3De000004080fe9308
[   18.599225]  [<a000000100051280>] apply_relocate_add+0x2c0/0x13a0
                                               sp=3De000004080fefd00
bsp=3De000004080fe9190
[   18.599225]  [<a000000100196e90>] load_module+0x34f0/0x5fc0
                                               sp=3De000004080fefd10
bsp=3De000004080fe8fe8
[   18.599225]  [<a000000100199d30>] __do_sys_finit_module+0x110/0x180
                                               sp=3De000004080fefd90
bsp=3De000004080fe8fb8
[   18.599225]  [<a000000100199e30>] sys_finit_module+0x30/0x80
                                               sp=3De000004080fefe30
bsp=3De000004080fe8f60
[   18.599225]  [<a00000010000ce00>] ia64_ret_from_syscall+0x0/0x20
                                               sp=3De000004080fefe30
bsp=3De000004080fe8f58
[   18.599225] Disabling lock debugging due to kernel taint
[   18.601537] systemd-udevd[1573]: Worker [1690] terminated by signal 11 (=
SEGV)
[   18.601537] systemd-udevd[1573]: 0000:c0:01.0: Worker [1690] failed


Kernel 5.9.1:

[   18.881449] kernel BUG at arch/ia64/kernel/module.c:609!
[   18.881449] systemd-udevd[1705]: bugcheck! 0 [1]
[   18.881449] Modules linked in: cfbimgblt snd_opl3_lib sysfillrect
sysimgblt snd_hwdep fb_sys_fops snd_rawmidi cfbcopyarea fb font
snd_seq_device ttm snd_pcm drm snd_timer snd i2c_core
drm_panel_orientation_quirks backlight tg3(+) agpgart libphy e100
fm801_gp soundcore gameport mii hwmon efivarfs configfs fuse nfs lockd
grace sunrpc

[   18.881449] CPU: 0 PID: 1705 Comm: systemd-udevd Not tainted
5.9.1-gentoo-ia64 #1
[   18.881449] Hardware name: hp workstation zx6000              ,
BIOS 02.31
03/11/2004
[   18.881449] psr : 0000101008026010 ifs : 8000000000000309 ip  :
[<a00000010004c6b0>]    Not tainted (5.9.1-gentoo-ia64)
[   18.881449] ip is at get_fdesc.isra.0+0x110/0x240
[   18.881449] unat: 0000000000000000 pfs : 0000000000000309 rsc :
0000000000000003
[   18.881449] rnat: 0000000000000000 bsps: 0000000000000000 pr  :
0000000069665159
[   18.881449] ldrs: 0000000000000000 ccv : 00000004656c0cc1 fpsr:
0009804c0270033f
[   18.881449] csd : 0000000000000000 ssd : 0000000000000000
[   18.881449] b0  : a00000010004c6b0 b6  : a000000100740e60 b7  :
a0000001004a4740
[   18.881449] f6  : 000000000000000000000 f7  : 1003eaaaaaaaaaaaaaaab
[   18.881449] f8  : 1003e0000000000000020 f9  : 1003e0000000000000000
[   18.881449] f10 : 1003e0000000000000000 f11 : 1003ecccccccccccccccd
[   18.881449] r1  : a0000001014c65e0 r2  : a00000010126da10 r3  :
a00000010126da18
[   18.881449] r8  : 000000000000002c r9  : 0000000000000001 r10 :
0000000000000000
[   18.881449] r11 : 0000000000000000 r12 : e00000408556fd00 r13 :
e000004085568000
[   18.881449] r14 : ffffffffffda7430 r15 : a00000010126da18 r16 :
e0000040fff80000
[   18.881449] r17 : 0000000000004000 r18 : a000000101259a38 r19 :
0000000000000003
[   18.881449] r20 : 0000000000000003 r21 : 0000000000000003 r22 :
0000000000004000
[   18.881449] r23 : 0000000000004000 r24 : 0000000000000001 r25 :
a0000001012f074e
[   18.881449] r26 : a0000001012f077f r27 : 0000000000009140 r28 :
a0000001012e7648
[   18.881449] r29 : 0000000000000001 r30 : 000000000000148e r31 :
000000000000148e
[   18.881449]
               Call Trace:
[   18.881449]  [<a000000100014df0>] show_stack+0x90/0xc0
                                               sp=3De00000408556f940
bsp=3De000004085569420
[   18.881449]  [<a0000001000154f0>] show_regs+0x6d0/0xa40
                                               sp=3De00000408556fb10
bsp=3De0000040855693a8
[   18.881449]  [<a000000100027610>] die+0x1b0/0x4a0
                                               sp=3De00000408556fb30
bsp=3De000004085569368
[   18.881449]  [<a000000100e2aa60>] ia64_bad_break+0x740/0x760
                                               sp=3De00000408556fb30
bsp=3De000004085569338
[   18.881449]  [<a00000010000cc00>] ia64_leave_kernel+0x0/0x270
                                               sp=3De00000408556fb30
bsp=3De000004085569338
[   18.881449]  [<a00000010004c6b0>] get_fdesc.isra.0+0x110/0x240
                                               sp=3De00000408556fd00
bsp=3De0000040855692f0
[   18.881449]  [<a00000010004e250>] apply_relocate_add+0x310/0x13e0
                                               sp=3De00000408556fd00
bsp=3De000004085569198
[   18.881449]  [<a0000001001a1110>] load_module+0x3c30/0x69e0
                                               sp=3De00000408556fd10
bsp=3De000004085568fe0
[   18.881449]  [<a0000001001a4270>] __do_sys_finit_module+0x110/0x180
                                               sp=3De00000408556fd90
bsp=3De000004085568fb0
[   18.881449]  [<a0000001001a4370>] sys_finit_module+0x30/0x80
                                               sp=3De00000408556fe30
bsp=3De000004085568f58
[   18.881449]  [<a00000010000ca80>] ia64_ret_from_syscall+0x0/0x20
                                               sp=3De00000408556fe30
bsp=3De000004085568f50


Kernel 5.9.1:
[   17.836872] ------------[ cut here ]------------
[   17.836872] WARNING: CPU: 0 PID: 1926 at mm/vmalloc.c:2247
__vunmap+0x4a0/0x5c0
[   17.836872] Trying to vfree() bad address (00000000d54cc3f8)
[   17.836872] Modules linked in: usb_common fm801_gp gameport mii
hwmon pata_cmd64x efivarfs crc32c_generic msdos fat configfs squashfs
fuse nfs lockd grace sunrpc ext4 mbcache jbd2 sd_mod mptspi
scsi_transport_spi mptscsih mptbase libata scsi_mod
[   17.836872] CPU: 0 PID: 1926 Comm: systemd-udevd Tainted: G
W         5.9.1-gentoo-ia64 #1
[   17.836872] Hardware name: hp workstation zx6000              ,
BIOS 02.31
03/11/2004
[   17.836872]
               Call Trace:
[   17.836872]  [<a000000100014df0>] show_stack+0x90/0xc0
                                               sp=3De000004081717b10
bsp=3De000004081711250
[   17.836872]  [<a0000001005c5440>] dump_stack+0x120/0x160
                                               sp=3De000004081717ce0
bsp=3De0000040817111d0
[   17.836872]  [<a000000100064360>] __warn+0x190/0x230
                                               sp=3De000004081717ce0
bsp=3De000004081711180
[   17.836872]  [<a0000001000644c0>] warn_slowpath_fmt+0xc0/0xe0
                                               sp=3De000004081717ce0
bsp=3De000004081711120
[   17.836872]  [<a0000001002a7660>] __vunmap+0x4a0/0x5c0
                                               sp=3De000004081717d10
bsp=3De0000040817110d0
[   17.836872]  [<a0000001002a7af0>] vfree+0xd0/0x1e0
                                               sp=3De000004081717d10
bsp=3De0000040817110a8
[   17.836872]  [<a00000010019c210>] module_memfree+0x70/0xa0
                                               sp=3De000004081717d10
bsp=3De000004081711088
[   17.836872]  [<a0000001001a13d0>] load_module+0x3ef0/0x69e0
                                               sp=3De000004081717d10
bsp=3De000004081710ed0
[   17.836872]  [<a0000001001a4270>] __do_sys_finit_module+0x110/0x180
                                               sp=3De000004081717d90
bsp=3De000004081710ea0
[   17.836872]  [<a0000001001a4370>] sys_finit_module+0x30/0x80
                                               sp=3De000004081717e30
bsp=3De000004081710e48
[   17.836872]  [<a00000010000ca80>] ia64_ret_from_syscall+0x0/0x20
                                               sp=3De000004081717e30
bsp=3De000004081710e40
[   17.836872] ---[ end trace d067dd4ef2f6ea79 ]---


Kernel 5.9.1:

[   18.110401] Unable to handle kernel NULL pointer dereference
(address 0000000000000ef0)
[   18.110401] systemd-udevd[1915]: Oops 8804682956800 [1]
[   18.110401] Modules linked in: usb_common mii pata_cmd64x(+)
thermal efivarfs crc32c_generic msdos fat configfs squashfs loop fuse
nfs lockd grace sunrpc ext4 crc16 mbcache jbd2 sd_mod mptspi
scsi_transport_spi mptscsih mptbase libata scsi_mod

[   18.110401] CPU: 0 PID: 1915 Comm: systemd-udevd Not tainted
5.9.1-gentoo-ia64 #1
[   18.110401] Hardware name: hp workstation zx6000              ,
BIOS 02.31
03/11/2004
[   18.110401] psr : 0000101008026010 ifs : 8000000000001b3e ip  :
[<a00000010019f940>]    Not tainted (5.9.1-gentoo-ia64)
[   18.110401] ip is at load_module+0x4c80/0x69e0
[   18.110401] unat: 0000000000000000 pfs : 0000000000001b3e rsc :
0000000000000003
[   18.110401] rnat: 0000000000000000 bsps: 0000000000000000 pr  :
0000000069666959
[   18.110401] ldrs: 0000000000000000 ccv : e000004080e08000 fpsr:
0009804c0270033f
[   18.110401] csd : 0000000000000000 ssd : 0000000000000000
[   18.110401] b0  : a00000010019e860 b6  : a000000100196680 b7  :
a0000002003782a0
[   18.110401] f6  : 000000000000000000000 f7  : 1003e0000000000000008
[   18.110401] f8  : 1003e0000000000000520 f9  : 1003e00000000000007b0
[   18.110401] f10 : 1003eaaaaaaaaaaaaaaab f11 : 1003e0000000000000520
[   18.110401] r1  : a00000010106c4f0 r2  : a000000200160c90 r3  :
a000000200160ca8
[   18.110401] r8  : a000000200160ca0 r9  : 0000000000000000 r10 :
0000000000000000
[   18.110401] r11 : 0000000000000000 r12 : e000004080e0fd10 r13 :
e000004080e08000
[   18.110401] r14 : 0000000000000000 r15 : a000000200160c90 r16 :
e000004080e0fdf0
[   18.110401] r17 : 00000000000007b0 r18 : a000000200160c90 r19 :
a000000200150ece
[   18.110401] r20 : a000000200152e28 r21 : a000000200152e38 r22 :
a000000200150d60
[   18.110401] r23 : a000000200152e48 r24 : a000000200150ec8 r25 :
0000000000000055
[   18.110401] r26 : aaaaaaaaaaaaaaab r27 : a000000200150ece r28 :
a000000200160c98
[   18.110401] r29 : 0000000000000052 r30 : 0000000000000023 r31 :
a0000002001525a8
[   18.110401]
               Call Trace:
[   18.110401]  [<a000000100014df0>] show_stack+0x90/0xc0
                                               sp=3De000004080e0f940
bsp=3De000004080e09218
[   18.110401]  [<a0000001000154f0>] show_regs+0x6d0/0xa40
                                               sp=3De000004080e0fb10
bsp=3De000004080e091a0
[   18.110401]  [<a000000100027610>] die+0x1b0/0x4a0
                                               sp=3De000004080e0fb30
bsp=3De000004080e09160
[   18.110401]  [<a000000100aa7be0>] ia64_do_page_fault+0x6c0/0xc80
                                               sp=3De000004080e0fb30
bsp=3De000004080e090c8
[   18.110401]  [<a00000010000cc00>] ia64_leave_kernel+0x0/0x270
                                               sp=3De000004080e0fb40
bsp=3De000004080e090c8
[   18.110401]  [<a00000010019f940>] load_module+0x4c80/0x69e0
                                               sp=3De000004080e0fd10
bsp=3De000004080e08ed0
[   18.110401]  [<a0000001001a1a50>] __do_sys_finit_module+0x110/0x180
                                               sp=3De000004080e0fd90
bsp=3De000004080e08ea0
[   18.110401]  [<a0000001001a1b50>] sys_finit_module+0x30/0x80
                                               sp=3De000004080e0fe30
bsp=3De000004080e08e48
[   18.110401]  [<a00000010000ca80>] ia64_ret_from_syscall+0x0/0x20
                                               sp=3De000004080e0fe30
bsp=3De000004080e08e40


Do these remind any code change w.r.t. module loading to someone?

Thanks,

     =C3=89meric

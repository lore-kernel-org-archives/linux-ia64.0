From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Mon, 04 Jan 2010 22:40:46 +0000
Subject: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello and Happy New Year,

Some months ago, I filed bug #546655 on the Debian IA-64 list about
the impossibility to enable hardware graphics acceleration on my hp
zx6000 workstation running daily-updated Debian "Squeeze" Testing (see
http://bugs.debian.org/cgi-bin/bugreport.cgi?bugT6655 if
interested). There, I was advised to contact the dri-devel list,
although the problem might as well reside on the kernel part. Hence
this post.

Indeed, it seems that something is going wrong with AGP GART. Here are
the relevant lines of the dmesg output:

[=A0=A0 12.652322] Linux agpgart interface v0.103
[=A0=A0 12.715735] Unable to handle kernel NULL pointer dereference
(address 0000000000000003)
[=A0=A0 12.715784] modprobe[895]: Oops 8804682956800 [1]
[=A0=A0 12.715819] Modules linked in: hp_agp(+) agpgart snd_fm801
snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm
snd_page_alloc snd_tea575x_tuner videodev v4l1_compat
v4l2_compat_ioctl32 i2c_core snd_opl3_lib snd_hwdep snd_mpu401_uart
snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer
snd_seq_device snd fm801_gp soundcore gameport evdev ext4 mbcache jbd2
crc16 sd_mod crc_t10dif usbhid hid ide_cd_mod cdrom ide_pci_generic
ata_generic libata tg3 mptspi mptscsih e100 ohci_hcd cmd64x libphy
mptbase scsi_transport_spi scsi_mod mii ide_core ehci_hcd usbcore
nls_base [last unloaded: scsi_wait_scan]
[=A0=A0 12.716925]
[=A0=A0 12.716926] Pid: 895, CPU 0, comm:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 modprobe
[=A0=A0 12.716988] psr : 00001010085a6010 ifs : 8000000000000712 ip=A0 :
[<a000000202b10200>]=A0=A0=A0 Not tainted (2.6.32-trunk-mckinley)
[=A0=A0 12.717044] ip is at zx1_gart_probe+0xd0/0xcc0 [hp_agp]
[=A0=A0 12.717078] unat: 0000000000000000 pfs : 0000000000000712 rsc :
0000000000000003
[=A0=A0 12.717124] rnat: e000004084f68d14 bsps: a0007fffff90ae30 pr=A0 :
000000559a9a5665
[=A0=A0 12.717171] ldrs: 0000000000000000 ccv : 0000000000000002 fpsr:
0009804c8a70033f
[=A0=A0 12.717216] csd : 0000000000000000 ssd : 0000000000000000
[=A0=A0 12.717250] b0=A0 : a000000202b101a0 b6=A0 : a000000100425a70 b7=A0 :
a000000100408420
[=A0=A0 12.717297] f6=A0 : 1003e0000000000000000 f7=A0 : 1003e0000000000000=
020
[=A0=A0 12.717332] f8=A0 : 1003e0000000000000000 f9=A0 : 1003efffffffffffff=
ff6
[=A0=A0 12.717367] f10 : 1001eff45f776f00ba089 f11 : 1003e0000000000000000
[=A0=A0 12.717403] r1=A0 : a000000202b05430 r2=A0 : 0000000000000003 r3=A0 :
0000000000000000
[=A0=A0 12.717449] r8=A0 : e000004080d27c90 r9=A0 : e000004080d27c60 r10 :
a000000100a36548
[=A0=A0 12.717496] r11 : e000004084f6fd20 r12 : e000004084f6fdc0 r13 :
e000004084f68000
[=A0=A0 12.717542] r14 : e000004080d27c90 r15 : e000004080d27c64 r16 :
e000004080d27c6c
[=A0=A0 12.717588] r17 : e000004080d27c6d r18 : e000004084f6fd10 r19 :
a0007fffff90ca58
[=A0=A0 12.717634] r20 : a0000001009355d8 r21 : a00000010098da10 r22 :
000000000000011e
[=A0=A0 12.717680] r23 : 0000000000000000 r24 : 0000000000000000 r25 :
e000004084f6fdc0
[=A0=A0 12.717726] r26 : a0007fffff90ca68 r27 : 0000000000000000 r28 :
a0000001009355e0
[=A0=A0 12.717773] r29 : e000004080e77740 r30 : e000004080e772c0 r31 :
e000004084f6fdb0
[=A0=A0 12.717832]
[=A0=A0 12.717833] Call Trace:
[=A0=A0 12.717898]=A0 [<a000000100016370>] show_stack+0x50/0xa0
[=A0=A0 12.717900]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6f990
bsp=E000004084f69160
[=A0=A0 12.717983]=A0 [<a000000100016be0>] show_regs+0x820/0x860
[=A0=A0 12.717984]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fb60
bsp=E000004084f69108
[=A0=A0 12.718069]=A0 [<a00000010003bcc0>] die+0x1a0/0x300
[=A0=A0 12.718070]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fb60
bsp=E000004084f690c8
[=A0=A0 12.718155]=A0 [<a000000100063c30>] ia64_do_page_fault+0x8b0/0x9e0
[=A0=A0 12.718157]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fb60
bsp=E000004084f69078
[=A0=A0 12.718242]=A0 [<a00000010000c860>] ia64_native_leave_kernel+0x0/0x2=
70
[=A0=A0 12.718244]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fbf0
bsp=E000004084f69078
[=A0=A0 12.718329]=A0 [<a000000202b10200>] zx1_gart_probe+0xd0/0xcc0 [hp_ag=
p]
[=A0=A0 12.718331]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fdc0
bsp=E000004084f68fe0
[=A0=A0 12.718403]=A0 [<a00000010042bc40>] acpi_ns_get_device_callback+0x2a=
0/0x2e0
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fdf0
bsp=E000004084f68f78
[=A0=A0 12.718403]=A0 [<a000000100431370>] acpi_ns_walk_namespace+0x1b0/0x3=
00
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fe10
bsp=E000004084f68ef8
[=A0=A0 12.718403]=A0 [<a00000010042b970>] acpi_get_devices+0xb0/0xe0
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fe10
bsp=E000004084f68ec0
[=A0=A0 12.718403]=A0 [<a000000202b10090>] agp_hp_init+0x90/0x130 [hp_agp]
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fe30
bsp=E000004084f68ea0
[=A0=A0 12.718403]=A0 [<a00000010000a960>] do_one_initcall+0xe0/0x360
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fe30
bsp=E000004084f68e60
[=A0=A0 12.718403]=A0 [<a000000100108a20>] sys_init_module+0x1e0/0x4c0
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fe30
bsp=E000004084f68de0
[=A0=A0 12.718403]=A0 [<a00000010000c6c0>] ia64_ret_from_syscall+0x0/0x20
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f6fe30
bsp=E000004084f68de0
[=A0=A0 12.718403]=A0 [<a000000000010720>] ia64_ivt+0xffffffff00010720/0x400
[=A0=A0 12.718403]=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sp=E000004084f70000
bsp=E000004084f68de0

I don't know if this is the reason "why the sarea map would be busted"
(in Julien Cristau/Dave Airlie words):

[   25.243857] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   25.243876] [drm:drm_mmap_locked], start =3D 0x200000000d500000, end
=3D 0x200000000d510000, page offset =3D 0x3d80
[   25.243881] [drm:drm_mmap_locked] *ERROR* Could not find map

Is this a kernel-related problem or should I post on the dri-devel list?

Thank you,

     =C9meric

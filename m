From: James Bottomley <James.Bottomley@SteelEye.com>
Date: Tue, 14 Sep 2004 15:42:45 +0000
Subject: Oops in free_page_and_swap_cache on 2.6.9-rc2
Message-Id: <1095176571.1762.14.camel@mulgrave>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I get this on a HP zx2000:

Unable to handle kernel paging request at virtual address
a0007fffc7900000
gcc[14948]: Oops 11012296146944 [4]
Modules linked in: af_packet forte ac97_codec ehci_hcd aic79xx e1000
tulip cmd64x ide_core usbhid ohci_hcd usbcore snd_fm801 snd_pcm
snd_page_alloc snd_tea575x_tuner videodev snd_ac97_codec snd_opl3_lib
snd_timer snd_hwdep snd_mpu401_uart snd_rawmidi snd_seq_device snd
soundcore ext2 ext3 jbd mbcache sd_mod qla1280 mptscsih mptbase aic7xxx
sym53c8xx scsi_transport_spi scsi_mod

Pid: 14948, CPU 0, comm:                  gcc
psr : 0000121008026038 ifs : 8000000000000205 ip  :
[<a0000001000f5f61>]    Not tainted
ip is at free_page_and_swap_cache+0x1/0xe0
unat: 0000000000000000 pfs : 0000000000000ea1 rsc : 0000000000000003
rnat: e000004043400408 bsps: e000004043400000 pr  : 0000000000165559
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000e1ff0 b6  : a000000100002d70 b7  : a000000100002cd0
f6  : 1003e6db6db6db6db6db7 f7  : 1003e0000000001011bdf
f8  : 1003e000000000707c319 f9  : 1003e0000000000069ca2
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a00000010088a400 r2  : e000000001a111bc r3  : 0000000000008000
r8  : 0000000000000004 r9  : 0000000000008000 r10 : 0000000001011bde
r11 : 0000000000000000 r12 : e000000006c57ca0 r13 : e000000006c50000
r14 : 0000001008026038 r15 : 7ffc000000000000 r16 : 0000000000000000
r17 : 0000000000004000 r18 : 0000000000000000 r19 : 0000000000000000
r20 : 0000000000000000 r21 : e000000000000001 r22 : 00000000000000b0
r23 : 00000000000000b1 r24 : a0007fffc7900000 r25 : 0000000000000217
r26 : 0000000000000216 r27 : e000004067504000 r28 : 000000000000eb3f
r29 : 0000000000000000 r30 : 000000000707c319 r31 : 000000000808def8

Call Trace:
 [<a000000100017e40>] show_stack+0x80/0xa0
                                sp=E000000006c57830 bsp=E000000006c51340
 [<a00000010003a670>] die+0x130/0x1a0
                                sp=E000000006c57a00 bsp=E000000006c51308
 [<a0000001000546f0>] ia64_do_page_fault+0x350/0x940
                                sp=E000000006c57a00 bsp=E000000006c512a0
 [<a000000100011d20>] ia64_leave_kernel+0x0/0x260
                                sp=E000000006c57ad0 bsp=E000000006c512a0
 [<a0000001000f5f60>] free_page_and_swap_cache+0x0/0xe0
                                sp=E000000006c57ca0 bsp=E000000006c51278
 [<a0000001000e1ff0>] clear_page_tables+0x1f0/0x2e0
                                sp=E000000006c57ca0 bsp=E000000006c51188
 [<a0000001000eda20>] exit_mmap+0x160/0x620
                                sp=E000000006c57d60 bsp=E000000006c510f0
 [<a00000010007fcd0>] mmput+0xf0/0x180
                                sp=E000000006c57e30 bsp=E000000006c510c8
 [<a000000100089550>] do_exit+0x3f0/0x900
                                sp=E000000006c57e30 bsp=E000000006c51048
 [<a000000100089c20>] do_group_exit+0x120/0x160
                                sp=E000000006c57e30 bsp=E000000006c51028
 [<a000000100011ba0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E000000006c57e30 bsp=E000000006c51018

It occurs fairly frequently under load (about once during a full kernel
compile).  It's also been doing this on 2.6.9-rc1.

James



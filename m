From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Date: Tue, 09 Dec 2008 07:19:30 +0000
Subject: next-20081104 - kernel panic on ia64 box, at
Message-Id: <20081209070730.GA12102@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081204200745.eff0ac87.sfr@canb.auug.org.au>
In-Reply-To: <20081204200745.eff0ac87.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: tony.luck@intel.com
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Hi Tony,

	next-20081204 kernel panic's, while booting up on ia64 box. This panic=20
was not reproducible with the latest next-20081208 kernel.

VFS: Mounted root (cramfs filesystem) readonly.
Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[1266]: Oops 8804682956800 [1]
Modules linked in:

Pid: 1266, CPU 4, comm:              swapper
psr : 00001010085a6010 ifs : 800000000000060d ip  : [<a0000001007f73d0>]   =
 Not tainted (2.6.28-rc7-next-20081204-autokern1)
ip is at __mutex_lock_interruptible_slowpath+0x70/0x220
unat: 0000000000000000 pfs : 000000000000060d rsc : 0000000000000000
rnat: e303ca0717d84d54 bsps: 52f9f686bedfb255 pr  : 101026600565a559
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001007f7390 b6  : a0000001004a2880 b7  : a0000001004d55c0
f6  : 1003e0000000000000000 f7  : 1003e0000000000000020
f8  : 1003e0000000000000800 f9  : 1003e0000000000010000
f10 : 1003e0000000000000800 f11 : 1003e0000000000000020
r1  : a000000100e88990 r2  : e000001303f97d30 r3  : e0000006443d0100
r8  : 0000000000000000 r9  : e000001304432aa0 r10 : e0000006443d0000
r11 : 0000000000000000 r12 : e000001303f97d10 r13 : e000001303f90000
r14 : 0000000000000000 r15 : 0000000000000000 r16 : ffffffffffffffff
r17 : e000001303f97d20 r18 : a000000100c5ef20 r19 : 0000000000000000
usb 2-1: new low speed USB device using uhci_hcd and address 2
r20 : a000000100c5ef50 r21 : e000001303f800c0 r22 : ffffffdfffffffff
r23 : e000001303f801de r24 : 0000000000000001 r25 : 000000000000001a
r26 : e00000130318401b r27 : 0000000000000000 r28 : 0000000010ee2419
r29 : 0000000010ee2419 r30 : 0000000000000000 r31 : e0000006443d00f4

Call Trace:
 [<a0000001000155a0>] show_stack+0x80/0xa0
                                sp=E000001303f978e0 bsp=E000001303f91178
 [<a000000100015ea0>] show_regs+0x880/0x8c0
                                sp=E000001303f97ab0 bsp=E000001303f91120
 [<a00000010003dca0>] die+0x1a0/0x300
                                sp=E000001303f97ab0 bsp=E000001303f910d8
 [<a0000001007fff20>] ia64_do_page_fault+0x8a0/0xba0
                                sp=E000001303f97ab0 bsp=E000001303f91078
 [<a00000010000bfa0>] ia64_native_leave_kernel+0x0/0x270
                                sp=E000001303f97b40 bsp=E000001303f91078
 [<a0000001007f73d0>] __mutex_lock_interruptible_slowpath+0x70/0x220
                                sp=E000001303f97d10 bsp=E000001303f91010
 [<a0000001007f7630>] mutex_lock_interruptible+0x30/0x60
                                sp=E000001303f97d30 bsp=E000001303f90fe8
 [<a0000001004d56b0>] uart_open+0xf0/0xa60
                                sp=E000001303f97d30 bsp=E000001303f90f58
 [<a00000010049ace0>] tty_open+0x4a0/0xc20
                                sp=E000001303f97d60 bsp=E000001303f90ec0
 [<a00000010018f2e0>] chrdev_open+0x1c0/0x380
                                sp=E000001303f97d70 bsp=E000001303f90e78
 [<a000000100183b20>] __dentry_open+0x5c0/0x6a0
                                sp=E000001303f97d80 bsp=E000001303f90e00
 [<a000000100183ca0>] nameidata_to_filp+0xa0/0xc0
                                sp=E000001303f97d80 bsp=E000001303f90dd0
 [<a0000001001a3050>] do_filp_open+0x310/0x12e0
                                sp=E000001303f97d80 bsp=E000001303f90d10
usb 2-1: configuration #1 chosen from 1 choice
 [<a000000100183290>] do_sys_open+0x90/0x200
                                sp=E000001303f97e30 bsp=E000001303f90cc0
 [<a0000001001834d0>] sys_open+0x50/0x80
                                sp=E000001303f97e30 bsp=E000001303f90c68
input: LITE-ON Technology USB NetVista Full Width Keyboard. as /class/input=
/input1
 [<a0000001009c82b0>] do_linuxrc+0xb0/0x120
                                sp=E000001303f97e30 bsp=E000001303f90c48
 [<a000000100013710>] kernel_thread_helper+0xd0/0x100
                                sp=E000001303f97e30 bsp=E000001303f90c20
 [<a00000010000a4c0>] start_kernel_thread+0x20/0x40
                                sp=E000001303f97e30 bsp=E000001303f90c20
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Trying to move old root to /initrd ... <6>generic-usb 0003:04B3:3025.0001: =
input: USB HID v1.10 Keyboard [LITE-ON Technology USB NetVista Full Width K=
eyboard.] on usb-0000:00:05.3-1/input0
okay
Freeing unused kernel memory: 1760kB freed
BUG: soft lockup - CPU#0 stuck for 61s! [swapper:1]
Modules linked in:
Modules linked in:

Pid: 1, CPU 0, comm:              swapper
psr : 00001010085a6010 ifs : 8000000000000000 ip  : [<a00000010000a500>]   =
 Tainted: G      D    (2.6.28-rc7-next-20081204-autokern1)
ip is at ia64_spinlock_contention+0x20/0x60
unat: 0000000000000000 pfs : 0000000000000081 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 1810264469655559
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0930ffff000f0000 ssd : 0930ffff00000000
b0  : a0000001007f7390 b6  : a0000001007fa020 b7  : a0000001004d55c0
f6  : 1003e0000000000400000 f7  : 1003e0000000000000000
f8  : 1003e0000000028000000 f9  : 1003e0000000c5d145160
f10 : 1003eee8b2cb700000000 f11 : 1003e0000000000000001
r1  : a000000100e88990 r2  : 000000000000060d r3  : e00000064309001c
r8  : 0000000000000000 r9  : e000001304432aa0 r10 : e0000006443d0000
r11 : 0000000000000000 r12 : e000000643097d00 r13 : e000000643090000
r14 : 0000000000000000 r15 : e000001304432a00 r16 : 0000000000000000
r17 : 0000000000000000 r18 : a000000100c5ef20 r19 : 0000000000000000
r20 : a000000100c5ef50 r21 : e000001303f800c0 r22 : e000001304432aa0
r23 : 0000000000500002 r24 : e000000600005398 r25 : fffffffffffff000
r26 : a00000010049a840 r27 : 0000000000000000 r28 : e000000644516020
r29 : 0000000000000200 r30 : 0000000000000001 r31 : e0000006443d00f4

Call Trace:
 [<a0000001000155a0>] show_stack+0x80/0xa0
                                sp=E000000643097960 bsp=E000000643091340
 [<a000000100015ea0>] show_regs+0x880/0x8c0
                                sp=E000000643097b30 bsp=E0000006430912e8
 [<a0000001000f8770>] softlockup_tick+0x2b0/0x3a0
                                sp=E000000643097b30 bsp=E000000643091290
 [<a0000001000af920>] run_local_timers+0x40/0x60
                                sp=E000000643097b30 bsp=E000000643091278
 [<a0000001000af980>] update_process_times+0x40/0xc0
                                sp=E000000643097b30 bsp=E000000643091248
 [<a00000010003d800>] timer_interrupt+0x1c0/0x4c0
                                sp=E000000643097b30 bsp=E0000006430911e0
 [<a0000001000f8a90>] handle_IRQ_event+0x90/0x120
                                sp=E000000643097b30 bsp=E0000006430911a8
 [<a0000001000f8c70>] __do_IRQ+0x150/0x440
                                sp=E000000643097b30 bsp=E000000643091148
 [<a0000001000129b0>] ia64_handle_irq+0x410/0x440
                                sp=E000000643097b30 bsp=E0000006430910c8
 [<a00000010000bfa0>] ia64_native_leave_kernel+0x0/0x270
                                sp=E000000643097b30 bsp=E0000006430910c8
 [<a00000010000a500>] ia64_spinlock_contention+0x20/0x60
                                sp=E000000643097d00 bsp=E0000006430910c8
 [<a0000001007fa020>] _spin_lock+0x40/0x60
                                sp=E000000643097d00 bsp=E0000006430910c0
 [<a0000001007f7390>] __mutex_lock_interruptible_slowpath+0x30/0x220
                                sp=E000000643097d00 bsp=E000000643091060
 [<a0000001007f7630>] mutex_lock_interruptible+0x30/0x60
                                sp=E000000643097d20 bsp=E000000643091040
 [<a0000001004d56b0>] uart_open+0xf0/0xa60
                                sp=E000000643097d20 bsp=E000000643090fa8
 [<a00000010049ace0>] tty_open+0x4a0/0xc20
                                sp=E000000643097d50 bsp=E000000643090f10
 [<a00000010018f2e0>] chrdev_open+0x1c0/0x380
                                sp=E000000643097d60 bsp=E000000643090ec8
 [<a000000100183b20>] __dentry_open+0x5c0/0x6a0
                                sp=E000000643097d70 bsp=E000000643090e50
 [<a000000100183ca0>] nameidata_to_filp+0xa0/0xc0
                                sp=E000000643097d70 bsp=E000000643090e28
 [<a0000001001a3050>] do_filp_open+0x310/0x12e0
                                sp=E000000643097d70 bsp=E000000643090d60
 [<a000000100183290>] do_sys_open+0x90/0x200
                                sp=E000000643097e20 bsp=E000000643090d10
 [<a0000001001834d0>] sys_open+0x50/0x80
                                sp=E000000643097e20 bsp=E000000643090cb8
 [<a00000010000a980>] init_post+0x80/0x220
                                sp=E000000643097e20 bsp=E000000643090c98
 [<a0000001009c0640>] kernel_init+0x420/0x440
                                sp=E000000643097e20 bsp=E000000643090c48
 [<a000000100013710>] kernel_thread_helper+0xd0/0x100
                                sp=E000000643097e30 bsp=E000000643090c20
 [<a00000010000a4c0>] start_kernel_thread+0x20/0x40
                                sp=E000000643097e30 bsp=E000000643090c20
--=20
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

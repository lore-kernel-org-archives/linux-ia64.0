From: Andreas Schwab <schwab@suse.de>
Date: Wed, 12 Nov 2003 15:37:24 +0000
Subject: drivers/usb/core/config.c: invalid configuration descriptor
Message-Id: <marc-linux-ia64-106865176701709@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When I try to run 2.6.0-test9 on an HP Everest I can't get USB working.
All I get is this:

drivers/usb/core/usb.c: registered new driver hub
PCI: Found IRQ 52 for device 0000:01:04.0
IOSAPIC: vector 52 -> CPU 0x0200, enabled
ohci_hcd 0000:01:04.0: OHCI Host Controller
ohci_hcd 0000:01:04.0: irq 52, pci mem c000000088032000
ohci_hcd 0000:01:04.0: new USB bus registered, assigned bus number 1
drivers/usb/core/config.c: invalid configuration descriptor
usb usb1: can't read configurations, error -22
ohci_hcd 0000:01:04.0: can't register root hub for usb1, -22
ohci_hcd 0000:01:04.0: can't start
ohci_hcd 0000:01:04.0: remove, state 0
ohci_hcd 0000:01:04.0: USB bus 1 deregistered
ohci_hcd: probe of 0000:01:04.0 failed with error -16
PCI: Found IRQ 53 for device 0000:01:04.1
IOSAPIC: vector 53 -> CPU 0x0300, enabled
ohci_hcd 0000:01:04.1: OHCI Host Controller
ohci_hcd 0000:01:04.1: irq 53, pci mem c000000088031000
ohci_hcd 0000:01:04.1: new USB bus registered, assigned bus number 1
drivers/usb/core/config.c: invalid configuration descriptor
usb usb1: can't read configurations, error -22
ohci_hcd 0000:01:04.1: can't register root hub for usb1, -22
ohci_hcd 0000:01:04.1: can't start
ohci_hcd 0000:01:04.1: remove, state 0
ohci_hcd 0000:01:04.1: USB bus 1 deregistered
ohci_hcd: probe of 0000:01:04.1 failed with error -16
PCI: Found IRQ 54 for device 0000:01:04.2
IOSAPIC: vector 54 -> CPU 0x0000, enabled
ehci_hcd 0000:01:04.2: EHCI Host Controller
ehci_hcd 0000:01:04.2: irq 54, pci mem c000000088030000
ehci_hcd 0000:01:04.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:01:04.2: USB 2.0 enabled, EHCI 0.95, driver 2003-Jun-13
drivers/usb/core/config.c: invalid configuration descriptor
usb usb1: can't read configurations, error -22
ehci_hcd 0000:01:04.2: can't register root hub for usb1, -22
ehci_hcd 0000:01:04.2: remove, state 0
modprobe[987]: NaT consumption 17179869216 [1]
=20
Pid: 987, CPU 1, comm:             modprobe
psr : 0000101008022018 ifs : 8000000000000690 ip  : [<a000000200178440>]   =
 Not tainted
ip is at scan_async+0xa0/0x340 [ehci_hcd]
unat: 0000000000000000 pfs : 0000000000000308 rsc : 0000000000000003
rnat: fffffffff5955559 bsps: a000000100306e70 pr  : fffffffff5952659
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000020017dbe0 b6  : a000000100002d70 b7  : a000000100174fe0
f6  : 000000000000000000000 f7  : 0ffdca200000000000000
f8  : 100028000000000000000 f9  : 10002a000000000000000
f10 : 0fffeccccccccc8c00000 f11 : 1003e0000000000000000
r1  : a000000200370000 r2  : 0000000000000000 r3  : 0000000000000000
r8  : 0000000000000000 r9  : 0000000000000000 r10 : 0000000000000000
r11 : 0000000000000050 r12 : e00000087d147da0 r13 : e00000087d140000
r14 : 0000000000000001 r15 : 0000000000000000 r16 : a0000001007000c8
r17 : 0000000000002d35 r18 : 0000000000000001 r19 : 0000000000000000
r20 : e0000008721a5780 r21 : e0000040fa7305a8 r22 : a0000001007000c8
r23 : e0000040fa7306a8 r24 : e0000040fa7306a0 r25 : 0000000000000008
r26 : 0000000000000000 r27 : a0000001007000d8 r28 : a00000020017d170
r29 : a0000001007a7d20 r30 : 0000000000000000 r31 : e00000087dcca800
=20
Call Trace:
 [<a00000010001afc0>] show_stack+0x80/0xa0
                                sp=E00000087d147900 bsp=E00000087d1413c8
 [<a00000010003f040>] die+0x180/0x220
                                sp=E00000087d147ad0 bsp=E00000087d141390
 [<a00000010003fd30>] ia64_fault+0x110/0xa40
                                sp=E00000087d147ad0 bsp=E00000087d141348
 [<a000000100013040>] ia64_leave_kernel+0x0/0x260
                                sp=E00000087d147bd0 bsp=E00000087d141348
 [<a000000200178440>] scan_async+0xa0/0x340 [ehci_hcd]
                                sp=E00000087d147da0 bsp=E00000087d1412c8
 [<a00000020017dbe0>] ehci_work+0x80/0x240 [ehci_hcd]
                                sp=E00000087d147da0 bsp=E00000087d141298
 [<a00000020017d1b0>] ehci_stop+0x250/0x460 [ehci_hcd]
                                sp=E00000087d147da0 bsp=E00000087d141268
 [<a000000200469e30>] usb_hcd_pci_remove+0x170/0x3c0 [usbcore]
                                sp=E00000087d147df0 bsp=E00000087d141228
 [<a000000200469c20>] usb_hcd_pci_probe+0x8a0/0x940 [usbcore]
                                sp=E00000087d147e00 bsp=E00000087d141198
 [<a00000010026c9c0>] pci_device_probe_static+0xc0/0x120
                                sp=E00000087d147e10 bsp=E00000087d141168
 [<a00000010026cac0>] __pci_device_probe+0xa0/0xe0
                                sp=E00000087d147e10 bsp=E00000087d141140
 [<a00000010026cb50>] pci_device_probe+0x50/0xa0
                                sp=E00000087d147e10 bsp=E00000087d141118
 [<a00000010030d7a0>] bus_match+0xc0/0x120
                                sp=E00000087d147e10 bsp=E00000087d1410e0
 [<a00000010030db00>] driver_attach+0x120/0x1e0
                                sp=E00000087d147e10 bsp=E00000087d1410a8
 [<a00000010030e200>] bus_add_driver+0x100/0x1a0
                                sp=E00000087d147e10 bsp=E00000087d141070
 [<a00000010030ea80>] driver_register+0xc0/0xe0
                                sp=E00000087d147e10 bsp=E00000087d141050
 [<a00000010026d0a0>] pci_register_driver+0xe0/0x120
                                sp=E00000087d147e30 bsp=E00000087d141028
 [<a0000002000a8120>] init+0xa0/0x120 [ehci_hcd]
                                sp=E00000087d147e30 bsp=E00000087d141000
 [<a0000001000d5970>] sys_init_module+0x390/0x680
                                sp=E00000087d147e30 bsp=E00000087d140f80
 [<a000000100012ec0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000087d147e30 bsp=E00000087d140f80

And then the machine is dead.

Any ideas?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

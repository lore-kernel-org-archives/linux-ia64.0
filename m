From: Horms <horms@verge.net.au>
Date: Fri, 29 Sep 2006 03:48:19 +0000
Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <20060929034818.GR29346@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Sep 27, 2006 at 11:52:12AM +0200, Tristan Gingold wrote:
> Linux and xen call efi in real mode if set_virtual_address_map fails.
> You may add an option in both xen and linux to force calling efi in real =
mode.
> This should be really simple and you will be able to make progress.

I took a stab at forcing the call to stay in real mode,=20
by simply replacing the call to set_virtual_address_map with
a return. This should both prevent the mapping from occuring,
and force the kernel to use the real mode variants of the calls.

Unfortunately, the boot fails with the following log.
A bit of investigation has found that is it dying in

   SAL_CALL()
   called by: ia64_sal_cache_flush()
   called by: ia64_sal_cache_flush()
   called by: ia64_sal_init()

Well, when I say dying in, its probably more accurate to say,
never returning from.

The trace below is with 2.6.18. I had identical results with a recent
checkout of ia64-test. I can post my config if needed.

I'm a bit of a loss to know why this is occuring. Though
I do wonder if SAL (and in this case indrectly PAL) calls are
are running into trouble by runing in real mode without
set_virtual_address_map() having being called.

I tried poking around a bit, but to no avail.
Any ideas on where to poke around?

--=20
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

Linux version 2.6.18-kexec-dirty (horms@tabatha.lab.ultramonkey.org)
(gcc version 3.4.5) #2 SMP Fri Sep 29 12:38:35 JST 2006 EFI v1.10 by INTEL:=
 SALsystab=3D0x7fe54980 ACPI=3D0x7ff99000 ACPI
2.0=3D0x7ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
Forcing EFI calls to stay in physical mode
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200')
Initial ramdisk at: 0xe00000007aecd000 (10463216 bytes)
SAL 3.20: Intel Corp                       SR870BH2                        =
 version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
swapper[0]: General Exception: IA-64 Reserved Register/Field fault (data ac=
cess) 2199023255600 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001210084a2010 ifs : 8000000000000183 ip  : [<000000007fe21dc1>]
Not tainted
ip is at 0x7fe21dc1
unat: 0000000000000000 pfs : 0000000000000818 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 80000000aff55d2b
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0930ffff00090000 ssd : 0930ffff00090000
b0  : 000000007fe21ca0 b6  : 000000007fe08010 b7  : a000000100205420
f6  : 0fffafffffffff0000000 f7  : 0ffdef000000000000000
f8  : 10002f000000000000000 f9  : 100038000000000000000
f10 : 0fffeeffffffff1000000 f11 : 1003e0000000000000000
r1  : e000000080095280 r2  : 0000000000000000 r3  : e00000007fe59340
r8  : fffffffffffffffe r9  : 000000000000000f r10 : 0000000000000000
r11 : 0000000000000000 r12 : a00000010057fc30 r13 : a000000100578000
r14 : 000000007fe20300 r15 : 00000000000004d5 r16 : 0000000000000000
r17 : 00001010084a2010 r18 : 000000000007e000 r19 : 80000000aff54cab
r20 : 00000000000006c2 r21 : 0000000000000000 r22 : 0000000000000000
r23 : 0000000000000609 r24 : 00000000003ffc00 r25 : 0000000000000008
r26 : 0000000000000000 r27 : 00000010084a2010 r28 : 000000000000003f
r29 : 0000000000000000 r30 : 0000000000000001 r31 : 0000000000000000

Call Trace:
 [<a0000001000124f0>] show_stack+0x50/0xa0
                                sp=A00000010057f640 bsp=A000000100579368
 <4>kernel unaligned access to 0xffffffffffff45c3, ip=3D0xa0000001000d9451
kernel unaligned access to 0xffffffffffff45c3, ip=3D0xa0000001000d9470
irq 239, desc: a0000001005b1c80, depth: 1, count: 0, unhandled: 0
->handle_irq():  a00000010050dcd0, __stop___param+0x3550/0x15880
->chip(): a000000100612f88, no_irq_chip+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0xef on CPU 0!



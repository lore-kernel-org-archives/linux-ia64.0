From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Aug 2018 23:34:16 +0000
Subject: Re: [PATCH 1/2] ia64: use asm-generic/io.h
Message-Id: <20180815233416.GA28832@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180711120824.3882108-1-arnd@arndb.de>
In-Reply-To: <20180711120824.3882108-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Arnd Bergmann <arnd@arndb.de>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Boris Brezillon <boris.brezillon@bootlin.com>, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 11, 2018 at 02:08:05PM +0200, Arnd Bergmann wrote:
> asm-generic/io.h provides a generic implementation of all I/O accessors,
> which the architectures can override.
>=20
> Since ia64 does not provide readsl/writesl etc, any driver using those
> fails to build, and including asm-generic/io.h will provide the
> missing interfaces, as well as any other future interfaces that get
> added there. We need to #define a couple of symbols to themselves
> in the ia64 to ensure that we use the ia64 specific version of those
> rather than the generic one.
>=20
> There should be no other effect than adding {read,write}s{b,w,l}()
> as well as {in,out}s{b,w,l}_p(), which were also not provided
> by ia64 but are provided by the generic header for historic reasons.

Sorry. I should have tried this when you sent it to me a month ago.

There must be something subtle in there somewhere because ia64 panics
early in boot with this patch present.  Revert the patch and it boots
OK.

Snip from console log:


NET: Registered protocol family 16
ACPI: bus type PCI registered
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
HugeTLB registered 256 MiB page size, pre-allocated 0 pages
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: Added _OSI(Linux-Dell-Video)
ACPI: 1 ACPI AML tables successfully acquired and loaded
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOSAPIC for interrupt routing
ACPI: Enabled 11 GPEs in block 00 to 3F
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-7f])
acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig Segments MSI]
acpi PNP0A08:00: PCIe port services disabled; not requesting _OSC control
kernel BUG at lib/ioremap.c:72!
swapper/0[1]: bugcheck! 0 [1]
Modules linked in:

CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.18.0-rc3-bisect-00137-g0bbf47e =
#15
Hardware name: Supermicro I8QBH/I8QBH, BIOS I8QBH 15.006.004RAS 2010/05/10
psr : 00001010084a6010 ifs : 800000000000050d ip  : [<a000000100e6d830>]   =
 Not tainted (4.18.0-rc3-bisect-00137-g0bbf47e)
ip is at ioremap_pte_range+0x190/0x1a0
unat: 0000000000000000 pfs : 000000000000050d rsc : 0000000000000003
rnat: fffffffffffc3358 bsps: 0000000000000000 pr  : 0000000000014745
ldrs: 0000000000000000 ccv : 00000000017c00be fpsr: 0009804c8a70433f
csd : 0930ffff00063000 ssd : 0930ffff00063000
b0  : a000000100e6d830 b6  : a000000100e91fa0 b7  : a000000100e91fa0
f6  : 1003e00000000000000a0 f7  : 1003e0000000000000000
f8  : 1003e0000000000000001 f9  : 1003efffffffffffffffc
f10 : 1001b80140227f7febfde f11 : 1003e20c49ba5e353f7cf
r1  : a000000101b3b7e0 r2  : a0000001018ca770 r3  : a00000010193c5d8
r8  : 000000000000001f r9  : 0000000000004000 r10 : fffffffffffc0408
r11 : 000000000000047e r12 : e000000301bdfca0 r13 : e000000301bd0000
r14 : a0000001018ca778 r15 : a0000001018ca778 r16 : 0000000000000000
r17 : 00000010084a2010 r18 : e000000301bdfc60 r19 : 0000000000000000
r20 : 000000000000047c r21 : 0000000000000000 r22 : 00000000000000ea
r23 : 000000000000017c r24 : 000000000000017c r25 : a0000001011d87b8
r26 : a000000100e91fa0 r27 : ffffffffffffffff r28 : a000000100e91fa0
r29 : a0000001011d87b8 r30 : a000000100e91fa0 r31 : a00000010198a300

Call Trace:
 [<a0000001000155e0>] show_stack+0x80/0xa0
                                sp=E000000301bdf880 bsp=E000000301bd17b8
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Attempted to kill init! exitcode=3D0x0000000b

---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=3D0x0=
000000b

Here's the surrounding code to the "BUG at lib/ioremap.c"

 61 static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 62                 unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 63 {
 64         pte_t *pte;
 65         u64 pfn;
 66
 67         pfn =3D phys_addr >> PAGE_SHIFT;
 68         pte =3D pte_alloc_kernel(pmd, addr);
 69         if (!pte)
 70                 return -ENOMEM;
 71         do {
 72                 BUG_ON(!pte_none(*pte));
 73                 set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
 74                 pfn++;
 75         } while (pte++, addr +=3D PAGE_SIZE, addr !=3D end);
 76         return 0;
 77 }

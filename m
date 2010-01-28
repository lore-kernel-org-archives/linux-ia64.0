From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 28 Jan 2010 21:52:48 +0000
Subject: Re: "new" dependencies on ACPI/BIOS
Message-Id: <4b620730109841f68a@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
In-Reply-To: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> I'd start with a patch like this (just the rsutils.c piece):
>   http://bugzilla.kernel.org/attachment.cgi?id=16776
>=20
> If you can post the output with that patch, we can manually decode the
> _CRS buffer straight from ACPI, so we can at least figure out whether
> to look at Linux or the BIOS.

Here's the dmesg output with that patch applied (rsutils.c has been
moved since that patch was written - I applied the hunk to the new
location: drivers/acpi/acpica/rsutils.c)

-Tony

Initializing cgroup subsys cpuset
Linux version 2.6.33-rc5-generic-smp-284-gf925714 (aegl@linux-bxb2) (gcc ve=
rsion 4.4.2 (GCC) ) #1 SMP Thu Jan 28 13:29:03 PST 2010
EFI v2.10 by Intel: SALsystab=3D0x3e9b0518 ACPI 2.0=3D0x3e804014 SMBIOS=3D0=
x3aafa000
booting generic kernel on platform dig
Early serial console at I/O port 0x3f8 (options '115200')
bootconsole [uart0] enabled
ACPI: RSDP 000000003e804014 00024 (v02 INTEL )
ACPI: XSDT 000000003e804120 0004C (v01 INTEL  BXBIOH   00000002      010000=
13)
ACPI: FACP 000000003aaf8000 000F4 (v04 INTEL  BXBIOH   00000002      000000=
00)
ACPI: DSDT 000000003aad6000 18DA4 (v01 INTEL  BXBIOH   00000002 INTL 200807=
29)
ACPI: FACS 000000003adfa000 00040
ACPI: APIC 000000003aaf6000 002D0 (v01 INTEL  BXBIOH   00000002      000000=
00)
ACPI: SLIT 000000003aaf4000 0003C (v01 INTEL  BXBIOH   00000002      000000=
00)
ACPI: SPCR 000000003aaf2000 00050 (v01 INTEL  BXBIOH   00000002      000000=
00)
ACPI: SRAT 000000003aaf0000 00550 (v01 INTEL  BXBIOH   00000002      000000=
00)
ia64_native_iosapic_pcat_compat_init: Disabling PC-AT compatible 8259 inter=
rupts
ACPI: Local APIC address c0000000fee00000
32 CPUs available, 32 CPUs total
Number of logical nodes in system =3D 1
Number of memory chunks in system =3D 3
SMP: Allowing 32 CPUs, 0 hotplug CPUs
Initial ramdisk at: 0xe0000004fb071000 (3786488 bytes)
SAL 3.20:  version 0.0
SAL: AP wakeup using external interrupt vector 0xf0
ia64_native_iosapic_pcat_compat_init: Disabling PC-AT compatible 8259 inter=
rupts
ACPI: Local APIC address c0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0000) vector 30
PLATFORM int PMI (0x1): GSI 23 (edge, low) -> CPU 0 (0x0000) vector 0
register_intr: changing vector 47 from IO-SAPIC-edge to IO-SAPIC-level
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
MCA related initialization done
Virtual mem_map starts at 0xa07ffffffee80000
Zone PFN ranges:
  DMA      0x00000100 -> 0x00010000
  Normal   0x00010000 -> 0x0004fc00
Movable zone start PFN for each node
early_node_map[26] active PFN ranges
    0: 0x00000100 -> 0x00003aad
    0: 0x00003ab0 -> 0x00003adf
    0: 0x00003ae0 -> 0x00003ae2
    0: 0x00003aea -> 0x00003b0a
    0: 0x00003b0b -> 0x00003b0d
    0: 0x00003b0e -> 0x00003b71
    0: 0x00003b75 -> 0x00003b7f
    0: 0x00003b82 -> 0x00003b83
    0: 0x00003b85 -> 0x00003b87
    0: 0x00003b91 -> 0x00003b94
    0: 0x00003b95 -> 0x00003b96
    0: 0x00003bd8 -> 0x00003bda
    0: 0x00003c54 -> 0x00003c65
    0: 0x00003c66 -> 0x00003cc2
    0: 0x00003cc3 -> 0x00003cc7
    0: 0x00003cc9 -> 0x00003da9
    0: 0x00003daa -> 0x00003db1
    0: 0x00003db2 -> 0x00003dde
    0: 0x00003ddf -> 0x00003e80
    0: 0x00003e81 -> 0x00003e9a
    0: 0x00003e9c -> 0x00003f8e
    0: 0x00003fdd -> 0x00003fdf
    0: 0x00010000 -> 0x00040000
    0: 0x00044000 -> 0x0004fb40
    0: 0x0004fb48 -> 0x0004fb55
    0: 0x0004fb56 -> 0x0004fc00
On node 0 totalpages: 260511
free_area_init_node: node 0, pgdat e000000001300000, node_mem_map a07ffffff=
ee83800
  DMA zone: 56 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 15728 pages, LIFO batch:1
  Normal zone: 224 pages used for memmap
  Normal zone: 244503 pages, LIFO batch:1
pcpu-alloc: s46232 r8192 d11112 u65536 alloc=3D1*65536
pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07=20
pcpu-alloc: [0] 08 [0] 09 [0] 10 [0] 11 [0] 12 [0] 13 [0] 14 [0] 15=20
pcpu-alloc: [0] 16 [0] 17 [0] 18 [0] 19 [0] 20 [0] 21 [0] 22 [0] 23=20
pcpu-alloc: [0] 24 [0] 25 [0] 26 [0] 27 [0] 28 [0] 29 [0] 30 [0] 31=20
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 260231
Policy zone: Normal
Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\l-generic-smp.gz  conso=
le=3Dtty1 console=3Duart,io,0x3f8 intel_iommu=3Doff root=3DLABEL=3D/ ro
Intel-IOMMU: disabled
PID hash table entries: 4096 (order: -1, 32768 bytes)
Placing 64MB software IO TLB between e000000006c90000 - e00000000ac90000
software IO TLB at phys 0x6c90000 - 0xac90000
Memory: 16539008k/16623296k available (9120k code, 133696k reserved, 11497k=
 data, 1984k init)
SLUB: Genslabs=18, HWalign=128, Order=3D0-3, MinObjects=3D0, CPUs2, Nodes=
=1024
Hierarchical RCU implementation.
NR_IRQS:1024
CPU 0: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
Console: colour VGA+ 80x25
console [tty1] enabled
Calibrating delay loop... 3383.29 BogoMIPS (lpjg66592)
Dentry cache hash table entries: 2097152 (order: 8, 16777216 bytes)
Inode-cache hash table entries: 1048576 (order: 7, 8388608 bytes)
Mount-cache hash table entries: 4096
ACPI: Core revision 20091214
Boot processor id 0x0/0x0
Fixed BSP b0 value from CPU 1
CPU 1: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 100 cycles)
CPU 1: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 2: synchronized ITC with CPU 0 (last diff -3 cycles, maxerr 725 cycles)
CPU 2: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 3: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 712 cycles)
CPU 3: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 4: synchronized ITC with CPU 0 (last diff -2 cycles, maxerr 717 cycles)
CPU 4: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 5: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 712 cycles)
CPU 5: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 6: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 719 cycles)
CPU 6: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 7: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 713 cycles)
CPU 7: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 8: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 842 cycles)
CPU 8: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 9: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 836 cycles)
CPU 9: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 10: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 841 cycles)
CPU 10: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 11: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 836 cycles)
CPU 11: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 12: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 842 cycles)
CPU 12: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 13: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 836 cycles)
CPU 13: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 14: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 842 cycles)
CPU 14: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 15: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 836 cycles)
CPU 15: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 16: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 816 cycles)
CPU 16: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 17: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 816 cycles)
CPU 17: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 18: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 818 cycles)
CPU 18: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 19: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 818 cycles)
CPU 19: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 20: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 816 cycles)
CPU 20: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 21: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 816 cycles)
CPU 21: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 22: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 816 cycles)
CPU 22: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 23: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 817 cycles)
CPU 23: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 24: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 845 cycles)
CPU 24: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 25: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 841 cycles)
CPU 25: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 26: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 845 cycles)
CPU 26: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 27: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 841 cycles)
CPU 27: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 28: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 845 cycles)
CPU 28: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 29: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 840 cycles)
CPU 29: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 30: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 845 cycles)
CPU 30: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
CPU 31: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 842 cycles)
CPU 31: base freq=133.333MHz, ITC ratio=3D6/1, ITC freqy9.999MHz
Brought up 32 CPUs
Total of 32 processors activated (108265.47 BogoMIPS).
DMI 2.4 present.
NET: Registered protocol family 16
ACPI: bus type pci registered
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOSAPIC for interrupt routing
ACPI: No dock devices found.
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 00 00 7f 00 00 00 80 00
  47 01 f8 0c f8 0c 01 08 88 0d 00 01 0c 03 00 00
  00 00 f7 0c 00 00 f8 0c 88 0d 00 01 0c 03 00 00
  00 10 ff 8f 00 00 00 80 87 17 00 00 0d 03 00 00
  00 00 00 00 0a 00 ff ff 0b 00 00 00 00 00 00 00
  02 00 87 17 00 00 0d 03 00 00 00 00 00 00 0c 00
  ff ff 0f 00 00 00 00 00 00 00 04 00 87 17 00 00
  0d 01 00 00 00 00 00 00 c0 fe ff ff c3 fe 00 00
  00 00 00 00 04 00 87 17 00 00 0d 01 00 00 00 00
  00 c0 d1 fe ff c0 d1 fe 00 00 00 00 00 01 00 00
  87 17 00 00 0d 01 00 00 00 00 00 00 d4 fe ff ff
  df fe 00 00 00 00 00 00 0c 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 50 ff ff ff 9f 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 00 01 00 00 fe ff ff ff 00 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 01 01 00 00 fe ff ff ff 01 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 02 01 00 00 fe ff ff ff 02 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  03 01 00 00 fe ff ff ff 03 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
ACPI: PCI Root Bridge [PCI0] (0000:00)
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 00 00 7f 00 00 00 80 00
  47 01 f8 0c f8 0c 01 08 88 0d 00 01 0c 03 00 00
  00 00 f7 0c 00 00 f8 0c 88 0d 00 01 0c 03 00 00
  00 10 ff 8f 00 00 00 80 87 17 00 00 0d 03 00 00
  00 00 00 00 0a 00 ff ff 0b 00 00 00 00 00 00 00
  02 00 87 17 00 00 0d 03 00 00 00 00 00 00 0c 00
  ff ff 0f 00 00 00 00 00 00 00 04 00 87 17 00 00
  0d 01 00 00 00 00 00 00 c0 fe ff ff c3 fe 00 00
  00 00 00 00 04 00 87 17 00 00 0d 01 00 00 00 00
  00 c0 d1 fe ff c0 d1 fe 00 00 00 00 00 01 00 00
  87 17 00 00 0d 01 00 00 00 00 00 00 d4 fe ff ff
  df fe 00 00 00 00 00 00 0c 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 50 ff ff ff 9f 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 00 01 00 00 fe ff ff ff 00 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 01 01 00 00 fe ff ff ff 01 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 02 01 00 00 fe ff ff ff 02 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  03 01 00 00 fe ff ff ff 03 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 00 00 7f 00 00 00 80 00
  47 01 f8 0c f8 0c 01 08 88 0d 00 01 0c 03 00 00
  00 00 f7 0c 00 00 f8 0c 88 0d 00 01 0c 03 00 00
  00 10 ff 8f 00 00 00 80 87 17 00 00 0d 03 00 00
  00 00 00 00 0a 00 ff ff 0b 00 00 00 00 00 00 00
  02 00 87 17 00 00 0d 03 00 00 00 00 00 00 0c 00
  ff ff 0f 00 00 00 00 00 00 00 04 00 87 17 00 00
  0d 01 00 00 00 00 00 00 c0 fe ff ff c3 fe 00 00
  00 00 00 00 04 00 87 17 00 00 0d 01 00 00 00 00
  00 c0 d1 fe ff c0 d1 fe 00 00 00 00 00 01 00 00
  87 17 00 00 0d 01 00 00 00 00 00 00 d4 fe ff ff
  df fe 00 00 00 00 00 00 0c 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 50 ff ff ff 9f 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 00 01 00 00 fe ff ff ff 00 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 01 01 00 00 fe ff ff ff 01 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 02 01 00 00 fe ff ff ff 02 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  03 01 00 00 fe ff ff ff 03 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
pci_root PNP0A08:00: host bridge window [io  0x1000-0x8fff]
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
pci 0000:00:05.0: PME# disabled
pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
pci 0000:00:07.0: PME# disabled
pci 0000:00:13.0: reg 10: [mem 0x5832c000-0x5832cfff]
pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
pci 0000:00:13.0: PME# disabled
pci 0000:00:16.0: reg 10: [mem 0x58300000-0x58303fff 64bit]
pci 0000:00:16.1: reg 10: [mem 0x58304000-0x58307fff 64bit]
pci 0000:00:16.2: reg 10: [mem 0x58308000-0x5830bfff 64bit]
pci 0000:00:16.3: reg 10: [mem 0x5830c000-0x5830ffff 64bit]
pci 0000:00:16.4: reg 10: [mem 0x58310000-0x58313fff 64bit]
pci 0000:00:16.5: reg 10: [mem 0x58314000-0x58317fff 64bit]
pci 0000:00:16.6: reg 10: [mem 0x58318000-0x5831bfff 64bit]
pci 0000:00:16.7: reg 10: [mem 0x5831c000-0x5831ffff 64bit]
pci 0000:00:1a.0: reg 20: [io  0x40c0-0x40df]
pci 0000:00:1a.1: reg 20: [io  0x40a0-0x40bf]
pci 0000:00:1a.2: reg 20: [io  0x4080-0x409f]
pci 0000:00:1a.7: reg 10: [mem 0x58328000-0x583283ff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.1: PME# disabled
pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.2: PME# disabled
pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.3: PME# disabled
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: PME# disabled
pci 0000:00:1d.0: reg 20: [io  0x4060-0x407f]
pci 0000:00:1d.1: reg 20: [io  0x4040-0x405f]
pci 0000:00:1d.2: reg 20: [io  0x4020-0x403f]
pci 0000:00:1d.7: reg 10: [mem 0x58324000-0x583243ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.2: reg 10: [io  0x4138-0x413f]
pci 0000:00:1f.2: reg 14: [io  0x414c-0x414f]
pci 0000:00:1f.2: reg 18: [io  0x4130-0x4137]
pci 0000:00:1f.2: reg 1c: [io  0x4148-0x414b]
pci 0000:00:1f.2: reg 20: [io  0x4110-0x411f]
pci 0000:00:1f.2: reg 24: [io  0x4100-0x410f]
pci 0000:00:1f.3: reg 10: [mem 0x58320000-0x583200ff 64bit]
pci 0000:00:1f.3: reg 20: [io  0x4000-0x401f]
pci 0000:00:1f.5: reg 10: [io  0x4128-0x412f]
pci 0000:00:1f.5: reg 14: [io  0x4144-0x4147]
pci 0000:00:1f.5: reg 18: [io  0x4120-0x4127]
pci 0000:00:1f.5: reg 1c: [io  0x4140-0x4143]
pci 0000:00:1f.5: reg 20: [io  0x40f0-0x40ff]
pci 0000:00:1f.5: reg 24: [io  0x40e0-0x40ef]
pci 0000:01:00.0: reg 10: [mem 0x58260000-0x5827ffff]
pci 0000:01:00.0: reg 14: [mem 0x58240000-0x5825ffff]
pci 0000:01:00.0: reg 18: [io  0x3020-0x303f]
pci 0000:01:00.0: reg 1c: [mem 0x58284000-0x58287fff]
pci 0000:01:00.0: reg 30: [mem 0xfffe0000-0xffffffff pref]
pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
pci 0000:01:00.0: PME# disabled
pci 0000:01:00.1: reg 10: [mem 0x58220000-0x5823ffff]
pci 0000:01:00.1: reg 14: [mem 0x58200000-0x5821ffff]
pci 0000:01:00.1: reg 18: [io  0x3000-0x301f]
pci 0000:01:00.1: reg 1c: [mem 0x58280000-0x58283fff]
pci 0000:01:00.1: reg 30: [mem 0xfffe0000-0xffffffff pref]
pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
pci 0000:01:00.1: PME# disabled
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
pci 0000:00:01.0:   bridge window [mem 0x58200000-0x582fffff]
pci 0000:00:03.0: PCI bridge to [bus 02-02]
pci 0000:03:00.0: reg 10: [io  0x2000-0x20ff]
pci 0000:03:00.0: reg 14: [mem 0x58110000-0x58113fff 64bit]
pci 0000:03:00.0: reg 1c: [mem 0x58100000-0x5810ffff 64bit]
pci 0000:03:00.0: reg 30: [mem 0xffe00000-0xffffffff pref]
pci 0000:03:00.0: supports D1 D2
pci 0000:00:05.0: PCI bridge to [bus 03-03]
pci 0000:00:05.0:   bridge window [io  0x2000-0x2fff]
pci 0000:00:05.0:   bridge window [mem 0x58100000-0x581fffff]
pci 0000:00:07.0: PCI bridge to [bus 04-04]
pci 0000:00:1c.0: PCI bridge to [bus 05-05]
pci 0000:00:1c.1: PCI bridge to [bus 06-06]
pci 0000:00:1c.2: PCI bridge to [bus 07-07]
pci 0000:00:1c.3: PCI bridge to [bus 08-08]
pci 0000:00:1c.4: PCI bridge to [bus 09-09]
pci 0000:00:1c.5: PCI bridge to [bus 0a-0a]
pci 0000:0b:04.0: reg 10: [mem 0x50000000-0x57ffffff pref]
pci 0000:0b:04.0: reg 14: [io  0x1000-0x10ff]
pci 0000:0b:04.0: reg 18: [mem 0x58000000-0x5800ffff]
pci 0000:0b:04.0: reg 30: [mem 0xfffe0000-0xffffffff pref]
pci 0000:0b:04.0: Boot video device
pci 0000:0b:04.0: supports D1 D2
pci 0000:00:1e.0: PCI bridge to [bus 0b-0b] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x1000-0x1fff]
pci 0000:00:1e.0:   bridge window [mem 0x50000000-0x580fffff]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP7._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IP2P._PRT]
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 80 00 ff 00 00 00 80 00
  88 0d 00 01 0c 03 00 00 00 90 ff ff 00 00 ff 6f
  87 17 00 00 0d 01 00 00 00 00 00 00 c4 fe ff ff
  c7 fe 00 00 00 00 00 00 04 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 a0 ff ff ff ef 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 04 01 00 00 fe ff ff ff 04 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 05 01 00 00 fe ff ff ff 05 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 06 01 00 00 fe ff ff ff 06 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  07 01 00 00 fe ff ff ff 07 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
ACPI: PCI Root Bridge [PCI1] (0000:80)
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 80 00 ff 00 00 00 80 00
  88 0d 00 01 0c 03 00 00 00 90 ff ff 00 00 ff 6f
  87 17 00 00 0d 01 00 00 00 00 00 00 c4 fe ff ff
  c7 fe 00 00 00 00 00 00 04 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 a0 ff ff ff ef 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 04 01 00 00 fe ff ff ff 04 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 05 01 00 00 fe ff ff ff 05 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 06 01 00 00 fe ff ff ff 06 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  07 01 00 00 fe ff ff ff 07 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 80 00 ff 00 00 00 80 00
  88 0d 00 01 0c 03 00 00 00 90 ff ff 00 00 ff 6f
  87 17 00 00 0d 01 00 00 00 00 00 00 c4 fe ff ff
  c7 fe 00 00 00 00 00 00 04 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 a0 ff ff ff ef 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 04 01 00 00 fe ff ff ff 04 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 05 01 00 00 fe ff ff ff 05 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 06 01 00 00 fe ff ff ff 06 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  07 01 00 00 fe ff ff ff 07 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
pci_root PNP0A08:01: host bridge window [io  0x9000-0xfffe]
pci 0000:80:01.0: PME# supported from D0 D3hot D3cold
pci 0000:80:01.0: PME# disabled
pci 0000:80:03.0: PME# supported from D0 D3hot D3cold
pci 0000:80:03.0: PME# disabled
pci 0000:80:05.0: PME# supported from D0 D3hot D3cold
pci 0000:80:05.0: PME# disabled
pci 0000:80:07.0: PME# supported from D0 D3hot D3cold
pci 0000:80:07.0: PME# disabled
pci 0000:80:13.0: reg 10: [mem 0xa0220000-0xa0220fff]
pci 0000:80:13.0: PME# supported from D0 D3hot D3cold
pci 0000:80:13.0: PME# disabled
pci 0000:80:16.0: reg 10: [mem 0xa0200000-0xa0203fff 64bit]
pci 0000:80:16.1: reg 10: [mem 0xa0204000-0xa0207fff 64bit]
pci 0000:80:16.2: reg 10: [mem 0xa0208000-0xa020bfff 64bit]
pci 0000:80:16.3: reg 10: [mem 0xa020c000-0xa020ffff 64bit]
pci 0000:80:16.4: reg 10: [mem 0xa0210000-0xa0213fff 64bit]
pci 0000:80:16.5: reg 10: [mem 0xa0214000-0xa0217fff 64bit]
pci 0000:80:16.6: reg 10: [mem 0xa0218000-0xa021bfff 64bit]
pci 0000:80:16.7: reg 10: [mem 0xa021c000-0xa021ffff 64bit]
pci 0000:81:00.0: reg 10: [mem 0xa0160000-0xa017ffff]
pci 0000:81:00.0: reg 14: [mem 0xa0140000-0xa015ffff]
pci 0000:81:00.0: reg 18: [io  0xa020-0xa03f]
pci 0000:81:00.0: reg 1c: [mem 0xa0184000-0xa0187fff]
pci 0000:81:00.0: reg 30: [mem 0xfffe0000-0xffffffff pref]
pci 0000:81:00.0: PME# supported from D0 D3hot D3cold
pci 0000:81:00.0: PME# disabled
pci 0000:81:00.1: reg 10: [mem 0xa0120000-0xa013ffff]
pci 0000:81:00.1: reg 14: [mem 0xa0100000-0xa011ffff]
pci 0000:81:00.1: reg 18: [io  0xa000-0xa01f]
pci 0000:81:00.1: reg 1c: [mem 0xa0180000-0xa0183fff]
pci 0000:81:00.1: reg 30: [mem 0xfffe0000-0xffffffff pref]
pci 0000:81:00.1: PME# supported from D0 D3hot D3cold
pci 0000:81:00.1: PME# disabled
pci 0000:80:01.0: PCI bridge to [bus 81-81]
pci 0000:80:01.0:   bridge window [io  0xa000-0xafff]
pci 0000:80:01.0:   bridge window [mem 0xa0100000-0xa01fffff]
pci 0000:80:03.0: PCI bridge to [bus 82-82]
pci 0000:83:00.0: reg 10: [io  0x9000-0x90ff]
pci 0000:83:00.0: reg 14: [mem 0xa0010000-0xa0013fff 64bit]
pci 0000:83:00.0: reg 1c: [mem 0xa0000000-0xa000ffff 64bit]
pci 0000:83:00.0: reg 30: [mem 0xffe00000-0xffffffff pref]
pci 0000:83:00.0: supports D1 D2
pci 0000:80:05.0: PCI bridge to [bus 83-83]
pci 0000:80:05.0:   bridge window [io  0x9000-0x9fff]
pci 0000:80:05.0:   bridge window [mem 0xa0000000-0xa00fffff]
pci 0000:80:07.0: PCI bridge to [bus 84-84]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.MRP1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.MRP3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.MRP5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.MRP7._PRT]
_PRS AML buffer:
  23 f8 de 18 79 00=20
_CRS AML buffer:
  23 40 00 18 79 00=20
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 *6 7 9 10 11 12 14 15)
_PRS AML buffer:
  23 f8 de 18 79 00=20
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
_PRS AML buffer:
  23 f8 de 18 79 00=20
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
_PRS AML buffer:
  23 f8 de 18 79 00=20
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
_PRS AML buffer:
  23 f8 de 18 79 00=20
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
_PRS AML buffer:
  23 f8 de 18 79 00=20
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
_PRS AML buffer:
  23 f8 de 18 79 00=20
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
_PRS AML buffer:
  23 f8 de 18 79 00=20
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
vgaarb: device added: PCI:0000:0b:04.0,decodes=3Dio+mem,owns=3Dio+mem,locks=
=3Dnone
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
Switching to clocksource itc
pnp: PnP ACPI init
ACPI: bus type pnp registered
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 00 00 7f 00 00 00 80 00
  47 01 f8 0c f8 0c 01 08 88 0d 00 01 0c 03 00 00
  00 00 f7 0c 00 00 f8 0c 88 0d 00 01 0c 03 00 00
  00 10 ff 8f 00 00 00 80 87 17 00 00 0d 03 00 00
  00 00 00 00 0a 00 ff ff 0b 00 00 00 00 00 00 00
  02 00 87 17 00 00 0d 03 00 00 00 00 00 00 0c 00
  ff ff 0f 00 00 00 00 00 00 00 04 00 87 17 00 00
  0d 01 00 00 00 00 00 00 c0 fe ff ff c3 fe 00 00
  00 00 00 00 04 00 87 17 00 00 0d 01 00 00 00 00
  00 c0 d1 fe ff c0 d1 fe 00 00 00 00 00 01 00 00
  87 17 00 00 0d 01 00 00 00 00 00 00 d4 fe ff ff
  df fe 00 00 00 00 00 00 0c 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 50 ff ff ff 9f 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 00 01 00 00 fe ff ff ff 00 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 01 01 00 00 fe ff ff ff 01 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 02 01 00 00 fe ff ff ff 02 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  03 01 00 00 fe ff ff ff 03 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
_CRS AML buffer:
  86 09 00 00 00 00 c0 fe 00 00 10 00 79 00=20
_CRS AML buffer:
  47 01 00 00 00 00 00 10 47 01 81 00 81 00 00 03
  47 01 87 00 87 00 00 01 47 01 89 00 89 00 00 03
  47 01 8f 00 8f 00 00 01 47 01 c0 00 c0 00 00 20
  2a 10 00 79 00=20
_CRS AML buffer:
  47 01 70 00 70 00 01 02 47 01 74 00 74 00 01 04
  22 00 01 79 00=20
_CRS AML buffer:
  47 01 f0 00 f0 00 01 01 22 00 20 79 00=20
_CRS AML buffer:
  47 01 61 00 61 00 01 01 79 00=20
_CRS AML buffer:
  47 01 00 05 00 05 01 40 47 01 00 04 00 04 01 80
  47 01 92 00 92 00 01 01 47 01 10 00 10 00 01 10
  47 01 72 00 72 00 01 02 47 01 80 00 80 00 01 01
  47 01 84 00 84 00 01 03 47 01 88 00 88 00 01 01
  47 01 8c 00 8c 00 01 03 47 01 90 00 90 00 01 10
  47 01 00 08 00 08 01 20 47 01 f8 02 f8 02 01 08
  86 09 00 00 00 c0 d1 fe ff ff 06 00 86 09 00 00
  00 00 00 ff 00 00 00 01 86 09 00 00 00 00 e0 fe
  00 00 10 00 86 09 00 01 00 00 a0 fe 20 00 00 00
  86 09 00 00 00 b0 d1 fe 00 10 00 00 79 00=20
_CRS AML buffer:
  47 01 f8 03 f8 03 08 08 22 10 00 79 00=20
_PRS AML buffer:
  31 08 47 01 f8 03 f8 03 01 08 22 10 00 31 08 47
  01 f8 03 f8 03 01 08 22 08 00 31 08 47 01 e8 03
  e8 03 01 08 22 10 00 31 08 47 01 e8 03 e8 03 01
  08 22 08 00 31 08 47 01 f8 02 f8 02 01 08 22 10
  00 31 08 47 01 f8 02 f8 02 01 08 22 08 00 31 08
  47 01 e8 02 e8 02 01 08 22 10 00 31 08 47 01 e8
  02 e8 02 01 08 22 08 00 31 08 47 01 00 01 f8 03
  08 08 22 fa fd 38 79 00=20
_CRS AML buffer:
  47 01 f8 02 f8 02 08 08 22 08 00 79 00=20
_PRS AML buffer:
  31 08 47 01 f8 02 f8 02 01 08 22 08 00 31 08 47
  01 f8 03 f8 03 01 08 22 08 00 31 08 47 01 f8 03
  f8 03 01 08 22 10 00 31 08 47 01 e8 03 e8 03 01
  08 22 10 00 31 08 47 01 e8 03 e8 03 01 08 22 08
  00 31 08 47 01 f8 02 f8 02 01 08 22 10 00 31 08
  47 01 e8 02 e8 02 01 08 22 10 00 31 08 47 01 e8
  02 e8 02 01 08 22 08 00 31 08 47 01 00 01 f8 02
  08 08 22 fa fd 38 79 00=20
_CRS AML buffer:
  88 0d 00 02 0d 00 00 00 80 00 ff 00 00 00 80 00
  88 0d 00 01 0c 03 00 00 00 90 ff ff 00 00 ff 6f
  87 17 00 00 0d 01 00 00 00 00 00 00 c4 fe ff ff
  c7 fe 00 00 00 00 00 00 04 00 87 17 00 00 0d 01
  00 00 00 00 00 00 00 a0 ff ff ff ef 00 00 00 00
  00 00 00 50 8a 2b 00 00 0d 01 ff ff ff 03 00 00
  00 00 00 00 00 00 04 01 00 00 fe ff ff ff 04 01
  00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00
  00 00 8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00
  00 00 00 00 05 01 00 00 fe ff ff ff 05 01 00 00
  00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00
  8a 2b 00 00 0d 01 ff ff ff 03 00 00 00 00 00 00
  00 00 06 01 00 00 fe ff ff ff 06 01 00 00 00 00
  00 00 00 00 00 00 ff ff ff ff 00 00 00 00 8a 2b
  00 00 0d 01 ff ff ff 03 00 00 00 00 00 00 00 00
  07 01 00 00 fe ff ff ff 07 01 00 00 00 00 00 00
  00 00 00 00 ff ff ff ff 00 00 00 00 79 00=20
_CRS AML buffer:
  86 09 00 00 00 00 c4 fe 00 00 04 00 79 00=20
pnp: PnP ACPI: found 11 devices
ACPI: ACPI bus type pnp unregistered
system 00:06: [io  0x0500-0x053f] has been reserved
system 00:06: [io  0x0400-0x047f] has been reserved
system 00:06: [io  0x0800-0x081f] has been reserved
system 00:06: [io  0x02f8-0x02ff] has been reserved
system 00:06: [mem 0xfed1c000-0xfed8bffe] has been reserved
system 00:06: [mem 0xff000000-0xffffffff] has been reserved
system 00:06: [mem 0xfee00000-0xfeefffff] has been reserved
system 00:06: [mem 0xfea00000-0xfea0001f] has been reserved
system 00:06: [mem 0xfed1b000-0xfed1bfff] has been reserved
NET: Registered protocol family 2
IP route cache hash table entries: 524288 (order: 6, 4194304 bytes)
TCP established hash table entries: 524288 (order: 7, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
UDP hash table entries: 8192 (order: 2, 262144 bytes)
UDP-Lite hash table entries: 8192 (order: 2, 262144 bytes)
NET: Registered protocol family 1
PCI: CLS 64 bytes, default 128
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 3584kB freed
perfmon: version 2.0 IRQ 238
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Please use IA-32 EL for executing IA-32 binaries
HugeTLB registered 256 MB page size, pre-allocated 0 pages
SGI XFS with security attributes, large block/inode numbers, no debug enabl=
ed
msgmni has been set to 32308
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
EFI Time Services Driver v0.4
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
00:07: ttyS0 at I/O 0x3f8 (irq =3D 44) is a 16550A
console [ttyS0] enabled, bootconsole disabled
brd: module loaded
Uniform Multi-Platform E-IDE driver
ide-gd driver 1.18
ide-cd driver 5.00
ata_piix 0000:00:1f.2: version 2.13
GSI 17 (level, low) -> CPU 0 (0x0000) vector 49
ata_piix 0000:00:1f.2: PCI INT B -> GSI 17 (level, low) -> IRQ 49
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
scsi0 : ata_piix
scsi1 : ata_piix
ata1: SATA max UDMA/133 cmd 0x4138 ctl 0x414c bmdma 0x4110 irq 49
ata2: SATA max UDMA/133 cmd 0x4130 ctl 0x4148 bmdma 0x4118 irq 49
ata_piix 0000:00:1f.5: PCI INT B -> GSI 17 (level, low) -> IRQ 49
ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0x4128 ctl 0x4144 bmdma 0x40f0 irq 49
ata4: SATA max UDMA/133 cmd 0x4120 ctl 0x4140 bmdma 0x40f8 irq 49
Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAPI
Copyright (c) 1999-2006 Intel Corporation.
Intel(R) Gigabit Ethernet Network Driver - version 2.1.0-k2
Copyright (c) 2007-2009 Intel Corporation.
GSI 28 (level, low) -> CPU 1 (0x0100) vector 50
igb 0000:01:00.0: PCI INT A -> GSI 28 (level, low) -> IRQ 50
igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:30:48:d7:d3:26
igb 0000:01:00.0: eth0: PBA No: ffffff-0ff
igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
GSI 40 (level, low) -> CPU 2 (0x0200) vector 60
igb 0000:01:00.1: PCI INT B -> GSI 40 (level, low) -> IRQ 60
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
ata1.00: SATA link down (SStatus 0 SControl 300)
ata1.01: SATA link down (SStatus 0 SControl 300)
igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:30:48:d7:d3:27
ata2.00: SATA link down (SStatus 0 SControl 300)
ata2.01: SATA link down (SStatus 0 SControl 300)
igb 0000:01:00.1: eth1: PBA No: ffffff-0ff
igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
GSI 52 (level, low) -> CPU 3 (0x0300) vector 70
igb 0000:81:00.0: PCI INT A -> GSI 52 (level, low) -> IRQ 70
igb 0000:81:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:81:00.0: eth2: (PCIe:2.5Gb/s:Width x4) 00:30:48:d7:d3:4e
igb 0000:81:00.0: eth2: PBA No: ffffff-0ff
igb 0000:81:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
GSI 64 (level, low) -> CPU 4 (0x0400) vector 80
igb 0000:81:00.1: PCI INT B -> GSI 64 (level, low) -> IRQ 80
igb 0000:81:00.1: Intel(R) Gigabit Ethernet Network Connection
igb 0000:81:00.1: eth3: (PCIe:2.5Gb/s:Width x4) 00:30:48:d7:d3:4f
igb 0000:81:00.1: eth3: PBA No: ffffff-0ff
igb 0000:81:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
console [netcon0] enabled
netconsole: network logging started
Fusion MPT base driver 3.04.13
Copyright (c) 1999-2008 LSI Corporation
Fusion MPT SPI Host driver 3.04.13
Fusion MPT SAS Host driver 3.04.13
GSI 26 (level, low) -> CPU 5 (0x0500) vector 90
mptsas 0000:03:00.0: PCI INT A -> GSI 26 (level, low) -> IRQ 90
mptbase: ioc0: Initiating bringup
ioc0: LSISAS1068E B3: Capabilities=3D{Initiator}
scsi4 : ioc0: LSISAS1068E B3, FwRev=011a0000h, Ports=3D1, MaxQG8, IRQ=90
mptsas: ioc0: attaching ssp device: fw_channel 0, fw_id 6, phy 6, sas_addr =
0x5000c5000ecad991
scsi 4:0:0:0: Direct-Access     SEAGATE  ST9146802SS      0003 PQ: 0 ANSI: 5
GSI 50 (level, low) -> CPU 6 (0x0600) vector 91
mptsas 0000:83:00.0: PCI INT A -> GSI 50 (level, low) -> IRQ 91
sd 4:0:0:0: [sda] 286749488 512-byte logical blocks: (146 GB/136 GiB)
mptbase: ioc1: Initiating bringup
sd 4:0:0:0: [sda] Write Protect is off
sd 4:0:0:0: [sda] Mode Sense: b3 00 10 08
sd 4:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO a=
nd FUA
 sda: sda1 sda2 sda3
sd 4:0:0:0: [sda] Attached SCSI disk
ioc1: LSISAS1068E B3: Capabilities=3D{Initiator}
scsi5 : ioc1: LSISAS1068E B3, FwRev=011a0000h, Ports=3D1, MaxQG8, IRQ=91
mptsas: ioc1: attaching ssp device: fw_channel 0, fw_id 6, phy 6, sas_addr =
0x5000c5000b180115
scsi 5:0:0:0: Direct-Access     SEAGATE  ST9146802SS      0003 PQ: 0 ANSI: 5
mice: PS/2 mouse device common for all mice
sd 5:0:0:0: [sdb] 286749488 512-byte logical blocks: (146 GB/136 GiB)
EFI Variables Facility v0.08 2004-May-17
sd 5:0:0:0: [sdb] Write Protect is off
sd 5:0:0:0: [sdb] Mode Sense: b3 00 10 08
sd 5:0:0:0: [sdb] Write cache: enabled, read cache: enabled, supports DPO a=
nd FUA
 sdb:
sd 5:0:0:0: [sdb] Attached SCSI disk
TCP cubic registered
NET: Registered protocol family 17
Freeing unused kernel memory: 1984kB freed
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
device-mapper: ioctl: 4.16.0-ioctl (2009-11-05) initialised: dm-devel@redha=
t.com
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sda2): mounted filesystem with writeback data mode
uhci_hcd: USB Universal Host Controller Interface driver
GSI 16 (level, low) -> CPU 7 (0x0700) vector 92
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 92
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:1a.0: irq 92, io base 0x000040c0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 17 (level, low) -> IRQ 49
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1a.1: irq 49, io base 0x000040a0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
GSI 18 (level, low) -> CPU 8 (0x1000) vector 93
uhci_hcd 0000:00:1a.2: PCI INT C -> GSI 18 (level, low) -> IRQ 93
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.2: irq 93, io base 0x00004080
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 92
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.0: irq 92, io base 0x00004060
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 49
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.1: irq 49, io base 0x00004040
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 93
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.2: irq 93, io base 0x00004020
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not=
 after
ehci_hcd 0000:00:1a.7: device not available (can't reserve [mem 0x58328000-=
0x583283ff])
ehci_hcd 0000:00:1d.7: device not available (can't reserve [mem 0x58324000-=
0x583243ff])

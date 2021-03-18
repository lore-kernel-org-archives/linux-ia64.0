From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 18 Mar 2021 10:28:34 +0000
Subject: Re: [PATCH 0/1] sched/topology: NUMA distance deduplication
Message-Id: <f096ecf6-e18a-d824-2db8-91f021db2132@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de>
 <8735wtr2ro.mognet@arm.com>
 <cf4d7277-54a0-8bc7-60fb-9b2f6befb511@physik.fu-berlin.de>
 <87zgz1pmx4.mognet@arm.com> <87wnu5pkib.mognet@arm.com>
 <132937a8-0514-5a62-2897-569187e355a7@physik.fu-berlin.de>
In-Reply-To: <132937a8-0514-5a62-2897-569187e355a7@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Valentin Schneider <valentin.schneider@arm.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Sergei Trofimovich <slyfox@gentoo.org>, debian-ia64 <debian-ia64@lists.debian.org>

Hello!

On 3/18/21 12:26 AM, John Paul Adrian Glaubitz wrote:
>> b) do anything?
>=20
> It fixes the problem for me.

Here are the kernel messages with your patch applied:

[    0.000000] Linux version 5.12.0-rc3+ (glaubitz@epyc) (ia64-linux-gcc (G=
CC) 10.1.0, GNU ld (GNU Binutils) 2.34) #207 SMP Thu Mar 18 09:50:43 CET 20=
21
[    0.000000] efi: EFI v2.00 by HP
[    0.000000] efi: SALsystab=3D0x3ee7a000 ACPI 2.0=3D0x3fde4000 ESI=3D0x3e=
e7b000 SMBIOS=3D0x3ee7c000 HCDP=3D0x3fde2000=20
[    0.000000] PCDP: v3 at 0x3fde2000
[    0.000000] earlycon: uart8250 at MMIO 0x0000000088033000 (options '1152=
00n8')
[    0.000000] printk: bootconsole [uart8250] enabled
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000003FDE4000 000028 (v02 HP    )
[    0.000000] ACPI: XSDT 0x000000003FDE402C 0000A4 (v01 HP     rx2660   00=
000000 HP   00000000)
[    0.000000] ACPI: FACP 0x000000003FDF6A08 0000F4 (v03 HP     rx2660   00=
000000 HP   00000000)
[    0.000000] ACPI: DSDT 0x000000003FDE41C8 00E566 (v01 HP     rx2660   00=
000007 INTL 20050309)
[    0.000000] ACPI: FACS 0x000000003FDF6B00 000040
[    0.000000] ACPI: SPCR 0x000000003FDF6B40 000050 (v01 HP              00=
000000 HP   00000000)
[    0.000000] ACPI: DBGP 0x000000003FDF6B90 000034 (v01 HP     rx2660   00=
000000 HP   00000000)
[    0.000000] ACPI: APIC 0x000000003FDF6FB0 0000C8 (v01 HP     rx2660   00=
000000 HP   00000000)
[    0.000000] ACPI: SPMI 0x000000003FDF6BC8 000050 (v04 HP     rx2660   00=
000000 HP   00000000)
[    0.000000] ACPI: CPEP 0x000000003FDF6E80 000034 (v01 HP     rx2660   00=
000000 HP   00000000)
[    0.000000] ACPI: SSDT 0x000000003FDF2738 0004B3 (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF2BF8 000456 (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF3058 000EB8 (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF3F18 000EB8 (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF4DD8 000866 (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF5648 000EB8 (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF6508 000138 (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF6648 00013C (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF6788 00013C (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF68C8 00013C (v01 HP     rx2660   00=
000006 INTL 20050309)
[    0.000000] ACPI: Local APIC address (____ptrval____)
[    0.000000] 4 CPUs available, 4 CPUs total
[    0.000000] SMP: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] Initial ramdisk at: 0xe00000002d52b000 (24744716 bytes)
[    0.000000] SAL 3.20: HP version 4.4
[    0.000000] SAL Platform features:
[    0.000000]  None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] MCA related initialization done
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000001007fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000001000000-0x000000003e67ffff]
[    0.000000]   node   0: [mem 0x000000003eaec000-0x000000003ee77fff]
[    0.000000]   node   0: [mem 0x000000003fc00000-0x000000003fd77fff]
[    0.000000]   node   0: [mem 0x000000003fddc000-0x000000003fddffff]
[    0.000000]   node   0: [mem 0x0000010040000000-0x000001007f1fbfff]
[    0.000000]   node   0: [mem 0x000001007f200000-0x000001007fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000001000000-0x000001007ffff=
fff]
[    0.000000] On node 0 totalpages: 128737
[    0.000000]   DMA32 zone: 247 pages used for memmap
[    0.000000]   DMA32 zone: 0 pages reserved
[    0.000000]   DMA32 zone: 63202 pages, LIFO batch:15
[    0.000000]   DMA32 zone: 2334 pages in unavailable ranges
[    0.000000]   Normal zone: 256 pages used for memmap
[    0.000000]   Normal zone: 65535 pages, LIFO batch:15
[    0.000000]   Normal zone: 1 pages in unavailable ranges
[    0.000000] pcpu-alloc: s33176 r8192 d220776 u262144 alloc=16*16384
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3=20
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 128234
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-5.12.0-rc3+ =
root=3DUUID=0C24a3da-2673-4901-b95b-d5adf2643b67 ro
[    0.000000] Dentry cache hash table entries: 262144 (order: 7, 2097152 b=
ytes, linear)
[    0.000000] Inode-cache hash table entries: 131072 (order: 6, 1048576 by=
tes, linear)
[    0.000000] Sorting __ex_table...
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0x000000003a680000-0x000000003e=
680000] (64MB)
[    0.000000] Memory: 1924752K/2059792K available (17153K kernel code, 142=
0K rwdata, 1992K rodata, 992K init, 702K bss, 135040K reserved, 0K cma-rese=
rved)
[    0.000000] random: get_random_u64 called from __kmem_cache_create+0x50/=
0x10a0 with crng_init=3D0
[    0.000000] SLUB: HWalign=128, Order=3D0-3, MinObjects=3D0, CPUs=3D4, No=
des=3D1
[    0.000000] rcu: Hierarchical RCU implementation.
[    0.000000] rcu: 	RCU restricting CPUs from NR_CPUSd to nr_cpu_ids=3D4.
[    0.000000] 	Tracing variant of Tasks RCU enabled.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 2=
5 jiffies.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=
=3D4
[    0.000000] NR_IRQS: 1024
[    0.000000] ACPI: Local APIC address (____ptrval____)
[    0.000000] GSI 25 (level, low) -> CPU 0 (0x0000) vector 49
[    0.000000] CPU 0: base freq&6.110MHz, ITC ratio=3D6/4, ITC freq99.165MHz
[    0.000000] +/-150ppm
[    0.000000] clocksource: itc: mask: 0xffffffffffffffff max_cycles: 0x5c0=
f4c551d, max_idle_ns: 440795215289 ns
[    0.004000] Console: colour VGA+ 80x25
[    0.004000] ACPI: Core revision 20210105
[    0.004000] Calibrating delay loop... 3182.59 BogoMIPS (lpjc65184)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] LSM: Security Framework initializing
[    0.020000] Yama: becoming mindful.
[    0.020000] AppArmor: AppArmor initialized
[    0.020000] TOMOYO Linux initialized
[    0.020000] Mount-cache hash table entries: 4096 (order: 1, 32768 bytes,=
 linear)
[    0.020000] Mountpoint-cache hash table entries: 4096 (order: 1, 32768 b=
ytes, linear)
[    0.024000] Boot processor id 0x0/0x0
[    0.024000] rcu: Hierarchical SRCU implementation.
[    0.024000] smp: Bringing up secondary CPUs ...
[    0.004000] Fixed BSP b0 value from CPU 1
[    0.004000] CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxe=
rr 39 cycles)
[    0.004000] CPU 1: base freq&6.110MHz, ITC ratio=3D6/4, ITC freq99.165MHz
[    0.004000] +/-150ppm
[    0.004000] CPU 2: synchronized ITC with CPU 0 (last diff -5 cycles, max=
err 167 cycles)
[    0.004000] CPU 2: base freq&6.110MHz, ITC ratio=3D6/4, ITC freq99.165MHz
[    0.004000] +/-150ppm
[    0.004000] CPU 3: synchronized ITC with CPU 0 (last diff -5 cycles, max=
err 167 cycles)
[    0.004000] CPU 3: base freq&6.110MHz, ITC ratio=3D6/4, ITC freq99.165MHz
[    0.004000] +/-150ppm
[    0.028000] smp: Brought up 1 node, 4 CPUs
[    0.032000] Total of 4 processors activated (12730.36 BogoMIPS).
[    0.032000] devtmpfs: initialized
[    0.032000] SMBIOS 2.4 present.
[    0.032000] DMI: hp server rx2660                   , BIOS 04.04        =
                                                    07/15/2008
[    0.036000] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfffffff=
f, max_idle_ns: 7645041785100000 ns
[    0.036000] futex hash table entries: 1024 (order: 3, 131072 bytes, line=
ar)
[    0.036000] NET: Registered protocol family 16
[    0.036000] audit: initializing netlink subsys (disabled)
[    0.040000] audit: type 00 audit(1616057988.040:1): state=3Dinitialized =
audit_enabled=3D0 res=3D1
[    0.040000] thermal_sys: Registered thermal governor 'fair_share'
[    0.040000] thermal_sys: Registered thermal governor 'step_wise'
[    0.040000] ACPI: bus type PCI registered
[    0.044000] HugeTLB registered 256 MiB page size, pre-allocated 0 pages
[    0.276000] random: fast init done
[    1.500000] ACPI: Added _OSI(Module Device)
[    1.500000] ACPI: Added _OSI(Processor Device)
[    1.500000] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.500000] ACPI: Added _OSI(Processor Aggregator Device)
[    1.500000] ACPI: Added _OSI(Linux-Dell-Video)
[    1.504000] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
[    1.504000] ACPI: Added _OSI(Linux-HPI-Hybrid-Graphics)
[    1.508000] ACPI: 11 ACPI AML tables successfully acquired and loaded
[    1.564000] ACPI: Interpreter enabled
[    1.564000] ACPI: (supports S0 S5)
[    1.564000] ACPI: Using IOSAPIC for interrupt routing
[    1.592000] ACPI: Enabled 2 GPEs in block 10 to 1F
[    1.908000] ACPI: PCI Root Bridge [L000] (domain 0000 [bus 00])
[    1.908000] acpi HWP0002:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI HPX-Type3]
[    1.940000] PCI host bridge to bus 0000:00
[    1.940000] pci_bus 0000:00: root bus resource [io  0x1000000-0x100ffff =
window] (bus address [0x0000-0xffff])
[    1.940000] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000ffff=
f window]
[    1.940000] pci_bus 0000:00: root bus resource [mem 0x80000000-0x8ffffff=
f window]
[    1.944000] pci_bus 0000:00: root bus resource [mem 0x80004000000-0x800f=
fffffff window]
[    1.944000] pci_bus 0000:00: root bus resource [bus 00]
[    1.948000] pci 0000:00:01.0: [103c:1303] type 00 class 0xff0000
[    1.952000] pci 0000:00:01.1: [103c:1302] type 00 class 0x078000
[    1.952000] pci 0000:00:01.1: reg 0x14: [mem 0x88034000-0x88034fff 64bit]
[    1.952000] pci 0000:00:01.1: reg 0x1c: [mem 0x80080000000-0x8008001ffff=
 64bit pref]
[    1.956000] pci 0000:00:01.2: [103c:1048] type 00 class 0x070002
[    1.956000] pci 0000:00:01.2: reg 0x14: [mem 0x88033000-0x88033fff 64bit]
[    1.960000] pci 0000:00:02.0: [1033:0035] type 00 class 0x0c0310
[    1.960000] pci 0000:00:02.0: reg 0x10: [mem 0x88032000-0x88032fff]
[    1.964000] pci 0000:00:02.0: supports D1 D2
[    1.964000] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot
[    1.964000] pci 0000:00:02.1: [1033:0035] type 00 class 0x0c0310
[    1.964000] pci 0000:00:02.1: reg 0x10: [mem 0x88031000-0x88031fff]
[    1.968000] pci 0000:00:02.1: supports D1 D2
[    1.968000] pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot
[    1.972000] pci 0000:00:02.2: [1033:00e0] type 00 class 0x0c0320
[    1.972000] pci 0000:00:02.2: reg 0x10: [mem 0x88030000-0x880300ff]
[    1.972000] pci 0000:00:02.2: supports D1 D2
[    1.972000] pci 0000:00:02.2: PME# supported from D0 D1 D2 D3hot
[    1.976000] pci 0000:00:03.0: [1002:515e] type 00 class 0x030000
[    1.976000] pci 0000:00:03.0: reg 0x10: [mem 0x80000000-0x87ffffff pref]
[    1.976000] pci 0000:00:03.0: reg 0x14: [io  0x1001000-0x10010ff]
[    1.976000] pci 0000:00:03.0: reg 0x18: [mem 0x88020000-0x8802ffff]
[    1.976000] pci 0000:00:03.0: reg 0x30: [mem 0x88000000-0x8801ffff pref]
[    1.980000] pci 0000:00:03.0: supports D1 D2
[    2.008000] ACPI: PCI Root Bridge [L002] (domain 0000 [bus 01])
[    2.008000] acpi HWP0002:01: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI HPX-Type3]
[    2.032000] PCI host bridge to bus 0000:01
[    2.032000] pci_bus 0000:01: root bus resource [io  0x2000000-0x200ffff =
window] (bus address [0x0000-0xffff])
[    2.032000] pci_bus 0000:01: root bus resource [mem 0xa0000000-0xaffffff=
f window]
[    2.032000] pci_bus 0000:01: root bus resource [mem 0x80204000000-0x802f=
fffffff window]
[    2.036000] pci_bus 0000:01: root bus resource [bus 01]
[    2.040000] pci 0000:01:01.0: [1000:0054] type 00 class 0x010000
[    2.040000] pci 0000:01:01.0: reg 0x10: [io  0x2001000-0x20010ff]
[    2.044000] pci 0000:01:01.0: reg 0x14: [mem 0xa0470000-0xa0473fff 64bit]
[    2.044000] pci 0000:01:01.0: reg 0x1c: [mem 0xa0460000-0xa046ffff 64bit]
[    2.044000] pci 0000:01:01.0: reg 0x30: [mem 0xa0000000-0xa03fffff pref]
[    2.044000] pci 0000:01:01.0: supports D1 D2
[    2.048000] pci 0000:01:02.0: [14e4:1648] type 00 class 0x020000
[    2.048000] pci 0000:01:02.0: reg 0x10: [mem 0xa0450000-0xa045ffff 64bit]
[    2.052000] pci 0000:01:02.0: reg 0x30: [mem 0xa0420000-0xa043ffff pref]
[    2.052000] pci 0000:01:02.0: PME# supported from D3hot D3cold
[    2.052000] pci 0000:01:02.1: [14e4:1648] type 00 class 0x020000
[    2.056000] pci 0000:01:02.1: reg 0x10: [mem 0xa0440000-0xa044ffff 64bit]
[    2.056000] pci 0000:01:02.1: reg 0x30: [mem 0xa0400000-0xa041ffff pref]
[    2.060000] pci 0000:01:02.1: PME# supported from D3hot D3cold
[    2.084000] ACPI: PCI Root Bridge [L003] (domain 0000 [bus 02-03])
[    2.084000] acpi HPQ0002:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI HPX-Type3]
[    2.092000] acpi HPQ0002:00: _OSC: OS now controls [PCIeHotplug PME AER =
PCIeCapability LTR]
[    2.116000] PCI host bridge to bus 0000:02
[    2.116000] pci_bus 0000:02: root bus resource [io  0x3000000-0x300ffff =
window] (bus address [0x0000-0xffff])
[    2.116000] pci_bus 0000:02: root bus resource [mem 0xb0000000-0xbffffff=
f window]
[    2.116000] pci_bus 0000:02: root bus resource [mem 0x80304000000-0x803f=
fffffff window]
[    2.116000] pci_bus 0000:02: root bus resource [bus 02-03]
[    2.120000] pci 0000:02:00.0: [103c:403b] type 01 class 0x060400
[    2.128000] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    2.152000] pci 0000:02:00.0: PCI bridge to [bus 03]
[    2.152000] pci 0000:02:00.0:   bridge window [io  0x3001000-0x300ffff]
[    2.152000] pci 0000:02:00.0:   bridge window [mem 0xb0000000-0xbfffffff]
[    2.152000] pci 0000:02:00.0:   bridge window [mem 0x80380000000-0x803ff=
ffffff 64bit pref]
[    2.192000] ACPI: PCI Root Bridge [L004] (domain 0000 [bus 04-05])
[    2.192000] acpi HPQ0002:01: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI HPX-Type3]
[    2.200000] acpi HPQ0002:01: _OSC: OS now controls [PCIeHotplug PME AER =
PCIeCapability LTR]
[    2.224000] PCI host bridge to bus 0000:04
[    2.224000] pci_bus 0000:04: root bus resource [io  0x4000000-0x400ffff =
window] (bus address [0x0000-0xffff])
[    2.224000] pci_bus 0000:04: root bus resource [mem 0xc0000000-0xdffffff=
f window]
[    2.224000] pci_bus 0000:04: root bus resource [mem 0x80404000000-0x804f=
fffffff window]
[    2.224000] pci_bus 0000:04: root bus resource [bus 04-05]
[    2.228000] pci 0000:04:00.0: [103c:403b] type 01 class 0x060400
[    2.236000] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
[    2.264000] pci 0000:05:00.0: [103c:3230] type 00 class 0x010400
[    2.272000] pci 0000:05:00.0: reg 0x10: [mem 0xc0000000-0xc00fffff 64bit]
[    2.276000] pci 0000:05:00.0: reg 0x18: [io  0x4001000-0x40010ff]
[    2.284000] pci 0000:05:00.0: reg 0x1c: [mem 0xc0140000-0xc0140fff 64bit]
[    2.292000] pci 0000:05:00.0: reg 0x30: [mem 0xc0100000-0xc013ffff pref]
[    2.312000] pci 0000:05:00.0: supports D1
[    2.336000] pci 0000:04:00.0: PCI bridge to [bus 05]
[    2.336000] pci 0000:04:00.0:   bridge window [io  0x4001000-0x400ffff]
[    2.336000] pci 0000:04:00.0:   bridge window [mem 0xc0000000-0xdfffffff]
[    2.336000] pci 0000:04:00.0:   bridge window [mem 0x80480000000-0x804ff=
ffffff 64bit pref]
[    2.376000] ACPI: PCI Root Bridge [L006] (domain 0000 [bus 06])
[    2.380000] acpi HWP0002:02: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI HPX-Type3]
[    2.420000] PCI host bridge to bus 0000:06
[    2.420000] pci_bus 0000:06: root bus resource [io  0x5000000-0x500ffff =
window] (bus address [0x0000-0xffff])
[    2.420000] pci_bus 0000:06: root bus resource [mem 0xe0000000-0xeffffff=
f window]
[    2.420000] pci_bus 0000:06: root bus resource [mem 0x80604000000-0x806f=
fffffff window]
[    2.420000] pci_bus 0000:06: root bus resource [bus 06]
[    2.468000] ACPI: PCI Root Bridge [L007] (domain 0000 [bus 07-08])
[    2.468000] acpi HPQ0002:02: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI HPX-Type3]
[    2.476000] acpi HPQ0002:02: _OSC: OS now controls [PCIeHotplug PME AER =
PCIeCapability LTR]
[    2.496000] PCI host bridge to bus 0000:07
[    2.496000] pci_bus 0000:07: root bus resource [io  0x6000000-0x600ffff =
window] (bus address [0x0000-0xffff])
[    2.496000] pci_bus 0000:07: root bus resource [mem 0xf0000000-0xfdfffff=
f window]
[    2.496000] pci_bus 0000:07: root bus resource [mem 0x80704000000-0x807f=
fffffff window]
[    2.500000] pci_bus 0000:07: root bus resource [bus 07-08]
[    2.504000] pci 0000:07:00.0: [103c:403b] type 01 class 0x060400
[    2.512000] pci 0000:07:00.0: PME# supported from D0 D3hot D3cold
[    2.540000] pci 0000:07:00.0: PCI bridge to [bus 08]
[    2.540000] pci 0000:07:00.0:   bridge window [io  0x6001000-0x600ffff]
[    2.540000] pci 0000:07:00.0:   bridge window [mem 0xf0000000-0xfdffffff]
[    2.540000] pci 0000:07:00.0:   bridge window [mem 0x80780000000-0x807ff=
ffffff 64bit pref]
[    2.556000] pci 0000:00:03.0: vgaarb: setting as boot VGA device
[    2.556000] pci 0000:00:03.0: vgaarb: VGA device added: decodes=3Dio+mem=
,owns=3Dio+mem,locks=3Dnone
[    2.556000] pci 0000:00:03.0: vgaarb: bridge control possible
[    2.556000] vgaarb: loaded
[    2.560000] pps_core: LinuxPPS API ver. 1 registered
[    2.560000] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    2.560000] PTP clock support registered
[    2.560000] Registered efivars operations
[    2.576000] IOC: zx2 2.0 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[    2.652000] clocksource: Switched to clocksource itc
[    2.652000] VFS: Disk quotas dquot_6.6.0
[    2.652000] VFS: Dquot-cache hash table entries: 2048 (order 0, 16384 by=
tes)
[    2.652000] AppArmor: AppArmor Filesystem Enabled
[    2.652000] pnp: PnP ACPI init
[    2.655658] GSI 24 (level, low) -> CPU 1 (0x0100) vector 50
[    2.655658] pnp 00:00: Plug and Play ACPI device, IDs PNP0501 (active)
[    2.727659] pnp: PnP ACPI: found 1 devices
[    2.734895] NET: Registered protocol family 2
[    2.734895] tcp_listen_portaddr_hash hash table entries: 1024 (order: 0,=
 16384 bytes, linear)
[    2.734895] TCP established hash table entries: 16384 (order: 3, 131072 =
bytes, linear)
[    2.734895] TCP bind hash table entries: 16384 (order: 4, 262144 bytes, =
linear)
[    2.735697] TCP: Hash tables configured (established 16384 bind 16384)
[    2.739611] UDP hash table entries: 1024 (order: 1, 32768 bytes, linear)
[    2.739611] UDP-Lite hash table entries: 1024 (order: 1, 32768 bytes, li=
near)
[    2.739611] NET: Registered protocol family 1
[    2.739611] NET: Registered protocol family 44
[    2.742884] GSI 17 (level, low) -> CPU 2 (0x0200) vector 51
[    2.743659] GSI 17 (level, low) -> CPU 2 (0x0200) vector 51 unregistered
[    2.747659] GSI 18 (level, low) -> CPU 3 (0x0300) vector 51
[    2.751659] GSI 18 (level, low) -> CPU 3 (0x0300) vector 51 unregistered
[    2.755659] GSI 19 (level, low) -> CPU 0 (0x0000) vector 51
[    2.759659] GSI 19 (level, low) -> CPU 0 (0x0000) vector 51 unregistered
[    2.759659] pci 0000:00:03.0: Video device with shadowed ROM at [mem 0x0=
00c0000-0x000dffff]
[    2.759659] PCI: CLS 128 bytes, default 128
[    2.759659] Unpacking initramfs...
[    3.479659] Freeing initrd memory: 24160kB freed
[    3.483611] Initialise system trusted keyrings
[    3.483611] Key type blacklist registered
[    3.483661] workingset: timestamp_bits8 max_order=17 bucket_order=3D0
[    3.483661] zbud: loaded
[    3.483661] Key type asymmetric registered
[    3.483661] Asymmetric key parser 'x509' registered
[    3.483661] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 249)
[    3.487613] io scheduler mq-deadline registered
[    3.491611] GSI 38 (level, low) -> CPU 1 (0x0100) vector 51
[    3.491706] pcieport 0000:02:00.0: PME: Signaling with IRQ 55
[    3.495671] pcieport 0000:02:00.0: AER: enabled with IRQ 55
[    3.499710] GSI 45 (level, low) -> CPU 2 (0x0200) vector 53
[    3.503697] pcieport 0000:04:00.0: PME: Signaling with IRQ 57
[    3.507713] pcieport 0000:04:00.0: AER: enabled with IRQ 57
[    3.511741] GSI 63 (level, low) -> CPU 3 (0x0300) vector 55
[    3.515691] pcieport 0000:07:00.0: PME: Signaling with IRQ 59
[    3.519726] pcieport 0000:07:00.0: AER: enabled with IRQ 59
[    3.523763] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    3.523763] ACPI: button: Power Button [PWRF]
[    3.523763] input: Sleep Button as /devices/LNXSYSTM:00/LNXSLPBN:00/inpu=
t/input1
[    3.523763] ACPI: button: Sleep Button [SLPF]
[    3.530380] thermal LNXTHERM:00: registered as thermal_zone0
[    3.530380] ACPI: thermal: Thermal Zone [THM0] (27 C)
[    3.530885] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    3.530885] 00:00: ttyS0 at MMIO 0xff5e2000 (irq =3D 50, base_baud =3D 1=
15200) is a 16550A
[    3.575658] GSI 16 (level, low) -> CPU 0 (0x0000) vector 57
[    3.582885] 0000:00:01.2: ttyS1 at MMIO 0x88033000 (irq =3D 60, base_bau=
d =3D 115200) is a 16550A
[    3.582885] printk: console [ttyS1] enabled
[    3.582885] printk: bootconsole [uart8250] disabled
[    3.582885] Linux agpgart interface v0.103
[    3.638883] mousedev: PS/2 mouse device common for all mice
[    3.638883] rtc-efi rtc-efi.0: registered as rtc0
[    3.638883] rtc-efi rtc-efi.0: setting system clock to 2021-03-18T08:59:=
52 UTC (1616057992)
[    3.639610] ledtrig-cpu: registered to indicate activity on CPUs
[    3.639610] EFI Variables Facility v0.08 2004-May-17
[    3.639659] NET: Registered protocol family 10
[    3.650380] Segment Routing with IPv6
[    3.651659] mip6: Mobile IPv6
[    3.651659] NET: Registered protocol family 17
[    3.654375] mpls_gso: MPLS GSO support
[    3.654375] registered taskstats version 1
[    3.654375] Loading compiled-in X.509 certificates
[    3.654375] zswap: loaded using pool lzo/zbud
[    3.654883] AppArmor: AppArmor sha1 policy hashing enabled
[    3.655659] Freeing unused kernel memory: 992K
[    3.655659] This architecture does not have kernel memory protection.
[    3.655659] Run /init as init process
[    3.655659]   with arguments:
[    3.655659]     /init
[    3.655659]   with environment:
[    3.655659]     HOME=3D/
[    3.655659]     TERM=3Dlinux
[    3.655659]     BOOT_IMAGE=3D/boot/vmlinuz-5.12.0-rc3+
[    3.811607] SCSI subsystem initialized
[    3.843681] GSI 29 (level, low) -> CPU 1 (0x0100) vector 58
[    3.854878] ACPI: bus type USB registered
[    3.854878] usbcore: registered new interface driver usbfs
[    3.855610] usbcore: registered new interface driver hub
[    3.855610] usbcore: registered new device driver usb
[    3.855610] HP HPSA Driver (v 3.4.20-200)
[    3.855610] hpsa 0000:05:00.0: legacy board ID: 0x3234103c
[    3.856757] hpsa 0000:05:00.0: legacy board ID: 0x3234103c
[    3.856757] hpsa 0000:05:00.0: can't disable ASPM; OS doesn't have ASPM =
control
[    3.862879] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.863624] Fusion MPT base driver 3.04.20
[    3.863624] Copyright (c) 1999-2008 LSI Corporation
[    3.863624] ehci-pci: EHCI PCI platform driver
[    3.863624] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.874375] GSI 19 (level, low) -> CPU 2 (0x0200) vector 59
[    3.874375] ehci-pci 0000:00:02.2: EHCI Host Controller
[    3.874375] ehci-pci 0000:00:02.2: new USB bus registered, assigned bus =
number 1
[    3.871888] Fusion MPT SAS Host driver 3.04.20
[    3.874456] ehci-pci 0000:00:02.2: irq 53, io mem 0x88030000
[    3.878887] hpsa 0000:05:00.0: Logical aborts not supported
[    3.878887] hpsa 0000:05:00.0: HP SSD Smart Path aborts not supported
[    3.879662] GSI 27 (level, low) -> CPU 3 (0x0300) vector 64
[    3.883614] mptbase: ioc0: Initiating bringup
[    3.890380] ehci-pci 0000:00:02.2: USB 2.0 started, EHCI 1.00
[    3.890380] usb usb1: New USB device found, idVendor=1D6b, idProduct=000=
2, bcdDevice=3D 5.12
[    3.890380] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    3.894380] usb usb1: Product: EHCI Host Controller
[    3.894380] usb usb1: Manufacturer: Linux 5.12.0-rc3+ ehci_hcd
[    3.894380] usb usb1: SerialNumber: 0000:00:02.2
[    3.895615] hub 1-0:1.0: USB hub found
[    3.895615] hub 1-0:1.0: 5 ports detected
[    3.899072] ohci-pci: OHCI PCI platform driver
[    3.902879] GSI 17 (level, low) -> CPU 0 (0x0000) vector 65
[    3.902879] ohci-pci 0000:00:02.0: OHCI PCI host controller
[    3.902879] ohci-pci 0000:00:02.0: new USB bus registered, assigned bus =
number 2
[    3.902879] ohci-pci 0000:00:02.0: irq 51, io mem 0x88032000
[    3.994877] usb usb2: New USB device found, idVendor=1D6b, idProduct=000=
1, bcdDevice=3D 5.12
[    3.994877] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    3.994877] usb usb2: Product: OHCI PCI host controller
[    3.995093] usb usb2: Manufacturer: Linux 5.12.0-rc3+ ohci_hcd
[    3.995093] usb usb2: SerialNumber: 0000:00:02.0
[    3.995669] scsi host0: hpsa
[    3.999613] hub 2-0:1.0: USB hub found
[    3.999613] hub 2-0:1.0: 3 ports detected
[    3.999613] hpsa can't handle SMP requests
[    4.002878] GSI 18 (level, low) -> CPU 1 (0x0100) vector 66
[    4.002878] ohci-pci 0000:00:02.1: OHCI PCI host controller
[    4.002878] ohci-pci 0000:00:02.1: new USB bus registered, assigned bus =
number 3
[    4.003520] ohci-pci 0000:00:02.1: irq 52, io mem 0x88031000
[    4.007616] hpsa 0000:05:00.0: scsi 0:0:0:0: masked Direct-Access     HP=
       DG036A8B53       PHYS DRV SSDSmartPathCap- En- Exp=3D0
[    4.007616] hpsa 0000:05:00.0: scsi 0:1:0:0: added Direct-Access     HP =
      LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1
[    4.007616] hpsa 0000:05:00.0: scsi 0:3:0:0: added RAID              HP =
      P400             controller SSDSmartPathCap- En- Exp=3D1
[    4.009107] scsi 0:1:0:0: Direct-Access     HP       LOGICAL VOLUME   7.=
22 PQ: 0 ANSI: 5
[    4.010383] scsi 0:3:0:0: RAID              HP       P400             7.=
22 PQ: 0 ANSI: 0
[    4.019609] sd 0:1:0:0: [sda] 71065440 512-byte logical blocks: (36.4 GB=
/33.9 GiB)
[    4.019609] sd 0:1:0:0: [sda] Write Protect is off
[    4.019609] sd 0:1:0:0: [sda] Mode Sense: 6b 00 00 08
[    4.019609] sd 0:1:0:0: [sda] Write cache: disabled, read cache: disable=
d, doesn't support DPO or FUA
[    4.063610]  sda: sda1 sda2 sda3
[    4.067613] sd 0:1:0:0: [sda] Attached SCSI disk
[    4.098878] usb usb3: New USB device found, idVendor=1D6b, idProduct=000=
1, bcdDevice=3D 5.12
[    4.098878] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    4.098878] usb usb3: Product: OHCI PCI host controller
[    4.099351] usb usb3: Manufacturer: Linux 5.12.0-rc3+ ohci_hcd
[    4.099351] usb usb3: SerialNumber: 0000:00:02.1
[    4.103351] hub 3-0:1.0: USB hub found
[    4.103351] hub 3-0:1.0: 2 ports detected
[    4.194383] tg3 0000:01:02.0 eth0: Tigon3 [partno(BCM95700A6) rev 2100] =
(PCIX:66MHz:64-bit) MAC address 00:17:a4:99:2d:09
[    4.194383] tg3 0000:01:02.0 eth0: attached PHY is 5704 (10/100/1000Base=
-T Ethernet) (WireSpeed[1], EEE[0])
[    4.198381] tg3 0000:01:02.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF=
[0] TSOcap[1]
[    4.198381] tg3 0000:01:02.0 eth0: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.202374] GSI 30 (level, low) -> CPU 2 (0x0200) vector 67
[    4.559666] usb 2-1: new full-speed USB device number 2 using ohci-pci
[    4.562383] tg3 0000:01:02.1 eth1: Tigon3 [partno(BCM95700A6) rev 2100] =
(PCIX:66MHz:64-bit) MAC address 00:17:a4:99:2d:08
[    4.562383] tg3 0000:01:02.1 eth1: attached PHY is 5704 (10/100/1000Base=
-T Ethernet) (WireSpeed[1], EEE[0])
[    4.566382] tg3 0000:01:02.1 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF=
[0] TSOcap[1]
[    4.566382] tg3 0000:01:02.1 eth1: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.571604] tg3 0000:01:02.1 enp1s2f1: renamed from eth1
[    4.587610] tg3 0000:01:02.0 enp1s2f0: renamed from eth0
[    4.719667] ioc0: LSISAS1068 B0: Capabilities=3D{Initiator}
[    4.791666] usb 2-1: New USB device found, idVendor=03f0, idProduct=1126=
, bcdDevice=3D 0.01
[    4.791666] usb 2-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumberc
[    4.791666] usb 2-1: Product: Virtual Management Device
[    4.796567] usb 2-1: Manufacturer: HP
[    4.796567] usb 2-1: SerialNumber: 0017a499dd1c
[    4.811605] hid: raw HID events driver (C) Jiri Kosina
[    4.831610] usbcore: registered new interface driver usbhid
[    4.831610] usbhid: USB HID core driver
[    4.831610] input: HP Virtual Management Device as /devices/pci0000:00/0=
000:00:02.0/usb2/2-1/2-1:1.0/0003:03F0:1126.0001/input/input2
[    4.895610] hid-generic 0003:03F0:1126.0001: input,hidraw0: USB HID v1.1=
1 Keyboard [HP Virtual Management Device] on usb-0000:00:02.0-1/input0
[    4.895610] input: HP Virtual Management Device as /devices/pci0000:00/0=
000:00:02.0/usb2/2-1/2-1:1.1/0003:03F0:1126.0002/input/input3
[    4.895610] hid-generic 0003:03F0:1126.0002: input,hidraw1: USB HID v1.0=
1 Mouse [HP Virtual Management Device] on usb-0000:00:02.0-1/input1
[    5.134379] usb 1-2: new high-speed USB device number 3 using ehci-pci
[    5.298379] usb 1-2: New USB device found, idVendor=03f0, idProduct=0126=
, bcdDevice=3D 0.a1
[    5.298379] usb 1-2: New USB device strings: MfrQ, Product=80, SerialNum=
berg
[    5.298379] usb 1-2: Product: INTEGRITY SERVER
[    5.298379] usb 1-2: Manufacturer: HEWLETT PACKARD
[    5.298445] usb 1-2: SerialNumber: A60020000001
[    5.303604] usb-storage 1-2:1.0: USB Mass Storage device detected
[    5.306883] scsi host1: usb-storage 1-2:1.0
[    5.306883] usbcore: registered new interface driver usb-storage
[    5.306883] usbcore: registered new interface driver uas
[    5.430883] scsi host2: ioc0: LSISAS1068 B0, FwRev=010f0000h, Ports=3D1,=
 MaxQQ1, IRQf
[    5.831610] EXT4-fs (sda2): mounted filesystem with ordered data mode. O=
pts: (null). Quota mode: none.
[    5.979658] Not activating Mandatory Access Control as /sbin/tomoyo-init=
 does not exist.
[    6.343609] scsi 1:0:0:0: CD-ROM            TEAC     DV-W28EAW        H.=
0C PQ: 0 ANSI: 0
[    6.607663] random: crng init done
[    7.478882] systemd[1]: Inserted module 'autofs4'
[    7.678379] systemd[1]: systemd 246.6-5 running in system mode. (+PAM +A=
UDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT =
+GNUTLS +ACL +XZ +LZ4 +ZSTD -SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCR=
E2 default-hierarchy=3Dhybrid)
[    7.682373] systemd[1]: Detected architecture ia64.
[    7.722379] systemd[1]: Set hostname to <glendronach>.
[    9.258379] systemd[1]: Queued start job for default target Graphical In=
terface.
[    9.266373] systemd[1]: Created slice system-getty.slice.
[    9.266373] systemd[1]: Created slice system-modprobe.slice.
[    9.266373] systemd[1]: Created slice system-serial\x2dgetty.slice.
[    9.270373] systemd[1]: Created slice User and Session Slice.
[    9.270373] systemd[1]: Started Dispatch Password Requests to Console Di=
rectory Watch.
[    9.274493] systemd[1]: Started Forward Password Requests to Wall Direct=
ory Watch.
[    9.274493] systemd[1]: Condition check resulted in Arbitrary Executable=
 File Formats File System Automount Point being skipped.
[    9.274810] systemd[1]: Reached target Local Encrypted Volumes.
[    9.278810] systemd[1]: Reached target Paths.
[    9.290379] systemd[1]: Reached target Remote File Systems.
[    9.290379] systemd[1]: Reached target Slices.
[    9.302378] systemd[1]: Listening on Syslog Socket.
[    9.314379] systemd[1]: Listening on fsck to fsckd communication Socket.
[    9.314379] systemd[1]: Listening on initctl Compatibility Named Pipe.
[    9.318379] systemd[1]: Listening on Journal Audit Socket.
[    9.318379] systemd[1]: Listening on Journal Socket (/dev/log).
[    9.330379] systemd[1]: Listening on Journal Socket.
[    9.342378] systemd[1]: Listening on udev Control Socket.
[    9.342378] systemd[1]: Listening on udev Kernel Socket.
[    9.346378] systemd[1]: Mounting Huge Pages File System...
[    9.362378] systemd[1]: Mounting POSIX Message Queue File System...
[    9.363609] systemd[1]: Mounting Kernel Debug File System...
[    9.363609] systemd[1]: Condition check resulted in Kernel Trace File Sy=
stem being skipped.
[    9.378379] systemd[1]: Starting Set the console keyboard layout...
[    9.382882] systemd[1]: Starting Create list of static device nodes for =
the current kernel...
[    9.386373] systemd[1]: Starting Load Kernel Module drm...
[    9.426378] systemd[1]: Condition check resulted in Set Up Additional Bi=
nary Formats being skipped.
[    9.426378] systemd[1]: Condition check resulted in File System Check on=
 Root Device being skipped.
[    9.427609] systemd[1]: Starting Journal Service...
[    9.462379] systemd[1]: Starting Load Kernel Modules...
[    9.478378] systemd[1]: Starting Remount Root and Kernel File Systems...
[    9.479609] systemd[1]: Starting Coldplug All udev Devices...
[    9.482379] systemd[1]: Finished Create list of static device nodes for =
the current kernel.
[    9.494378] systemd[1]: Finished Load Kernel Modules.
[    9.506379] systemd[1]: Condition check resulted in FUSE Control File Sy=
stem being skipped.
[    9.506379] systemd[1]: Condition check resulted in Kernel Configuration=
 File System being skipped.
[    9.510378] systemd[1]: Starting Apply Kernel Variables...
[    9.595609] systemd[1]: Started Journal Service.
[   10.399663] EXT4-fs (sda2): re-mounted. Opts: errors=3Dremount-ro. Quota=
 mode: none.
[   12.478877] IPMI message handler: version 39.2
[   12.526378] ipmi device interface
[   12.618881] ipmi_si: IPMI System Interface driver
[   12.618881] ipmi_si IPI0001:00: ipmi_platform: probing via ACPI
[   12.618881] ipmi_si IPI0001:00: ipmi_platform: [mem 0xff5bc000-0xff5bc00=
3] regsize 1 spacing 1 irq 0
[   12.622877] ipmi_si: Adding ACPI-specified kcs state machine
[   12.623608] ipmi_si: Trying ACPI-specified kcs state machine at mem addr=
ess 0xff5bc000, slave address 0x0, irq 0
[   12.671602] sd 0:1:0:0: Attached scsi generic sg0 type 0
[   12.671602] scsi 0:3:0:0: Attached scsi generic sg1 type 12
[   12.671602] scsi 1:0:0:0: Attached scsi generic sg2 type 5
[   12.850881] sr 1:0:0:0: Power-on or device reset occurred
[   12.950881] sr 1:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer cd/rw xa/f=
orm2 cdda tray
[   12.950881] cdrom: Uniform CD-ROM driver Revision: 3.20
[   13.043662] ipmi_si IPI0001:00: IPMI message handler: Found new BMC (man=
_id: 0x00000b, prod_id: 0x8201, dev_id: 0x32)
[   13.047608] ipmi_si IPI0001:00: IPMI kcs interface initialized
[   13.059608] sr 1:0:0:0: Attached scsi CD-ROM sr0
[   13.223608] ipmi_ssif: IPMI SSIF Interface driver
[   15.959607] FAT-fs (sda1): Volume was not properly unmounted. Some data =
may be corrupt. Please run fsck.
[   16.034878] [drm] radeon kernel modesetting enabled.
[   16.034878] radeon 0000:00:03.0: vgaarb: deactivate vga console
[   16.035611] Console: switching to colour dummy device 80x25
[   16.035662] Adding 1974256k swap on /dev/sda3.  Priority:-2 extents:1 ac=
ross:1974256k FS
[   16.042878] GSI 20 (level, low) -> CPU 3 (0x0300) vector 68
[   16.043607] [drm] initializing kernel modesetting (RV100 0x1002:0x515E 0=
x103C:0x1304 0x02).
[   16.050875] radeon 0000:00:03.0: VRAM: 128M 0x0000000080000000 - 0x00000=
00087FFFFFF (32M used)
[   16.050875] radeon 0000:00:03.0: GTT: 512M 0x0000000060000000 - 0x000000=
007FFFFFFF
[   16.050875] [drm] Detected VRAM RAM=128M, BAR=128M
[   16.054875] [drm] RAM width 16bits DDR
[   16.055608] [TTM] Zone  kernel: Available graphics memory: 1008040 KiB
[   16.055608] [drm] radeon: 32M of VRAM memory ready
[   16.055819] [drm] radeon: 512M of GTT memory ready.
[   16.055819] [drm] GART: num cpu pages 32768, num gpu pages 131072
[   16.076927] [drm] PCI GART of 512M enabled (table at 0x000000004A300000).
[   16.076927] radeon 0000:00:03.0: WB disabled
[   16.076927] radeon 0000:00:03.0: fence driver on ring 0 use gpu addr 0x0=
000000060000000
[   16.078377] [drm] radeon: irq initialized.
[   16.080121] [drm] Loading R100 Microcode
[   16.226880] [drm] radeon: ring at 0x0000000060004000
[   16.226880] [drm] ring test succeeded in 0 usecs
[   16.226880] [drm] ib test succeeded in 0 usecs
[   16.226880] [drm] No TV DAC info found in BIOS
[   16.227607] [drm] Radeon Display Connectors
[   16.230917] [drm] Connector 0:
[   16.230917] [drm]   VGA-1
[   16.230917] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[   16.230917] [drm]   Encoders:
[   16.230917] [drm]     CRT1: INTERNAL_DAC1
[   16.230917] [drm] Connector 1:
[   16.230917] [drm]   VGA-2
[   16.230917] [drm]   DDC: 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c
[   16.231935] [drm]   Encoders:
[   16.231935] [drm]     CRT2: INTERNAL_DAC2
[   16.602877] [drm] fb mappable at 0x80040000
[   16.602877] [drm] vram apper at 0x80000000
[   16.602877] [drm] size 1572864
[   16.602877] [drm] fb depth is 16
[   16.602877] [drm]    pitch is 2048
[   16.752002] Console: switching to colour frame buffer device 128x48
[   16.838879] radeon 0000:00:03.0: [drm] fb0: radeondrmfb frame buffer dev=
ice
[   16.923601] [drm] Initialized radeon 2.50.0 20080528 for 0000:00:03.0 on=
 minor 0
[   17.227661] kernel unaligned access to 0xe000010047c64046, ip=3D0xa00000=
0100720841
[   17.227661] kernel unaligned access to 0xe000010047c64066, ip=3D0xa00000=
0100720ae1
[   17.231784] kernel unaligned access to 0xe000010047c6406e, ip=3D0xa00000=
0100720ae1
[   17.231784] kernel unaligned access to 0xe000010047c64076, ip=3D0xa00000=
0100720ae1
[   17.234377] kernel unaligned access to 0xe000010047c6407e, ip=3D0xa00000=
0100720ae1
[   17.242880] audit: type=1400 audit(1616058006.099:2): apparmor=3D"STATUS=
" operation=3D"profile_load" profile=3D"unconfined" name=3D"nvidia_modprobe=
" pid00 comm=3D"apparmor_parser"
[   17.242880] audit: type=1400 audit(1616058006.099:3): apparmor=3D"STATUS=
" operation=3D"profile_load" profile=3D"unconfined" name=3D"nvidia_modprobe=
//kmod" pid00 comm=3D"apparmor_parser"
[   17.250880] audit: type=1400 audit(1616058006.107:4): apparmor=3D"STATUS=
" operation=3D"profile_load" profile=3D"unconfined" name=3D"/usr/bin/man" p=
id01 comm=3D"apparmor_parser"
[   17.250880] audit: type=1400 audit(1616058006.107:5): apparmor=3D"STATUS=
" operation=3D"profile_load" profile=3D"unconfined" name=3D"man_filter" pid=
01 comm=3D"apparmor_parser"
[   17.252592] audit: type=1400 audit(1616058006.107:6): apparmor=3D"STATUS=
" operation=3D"profile_load" profile=3D"unconfined" name=3D"man_groff" pid0=
1 comm=3D"apparmor_parser"
[   17.274880] audit: type=1400 audit(1616058006.131:7): apparmor=3D"STATUS=
" operation=3D"profile_load" profile=3D"unconfined" name=3D"lsb_release" pi=
d)9 comm=3D"apparmor_parser"
[   22.967654] tg3 0000:01:02.0 enp1s2f0: Link is up at 1000 Mbps, full dup=
lex
[   22.967654] tg3 0000:01:02.0 enp1s2f0: Flow control is on for TX and on =
for RX
[   22.967654] IPv6: ADDRCONF(NETDEV_CHANGE): enp1s2f0: link becomes ready


--=20
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

From: Meelis Roos <mroos@linux.ee>
Date: Tue, 25 Jun 2019 20:44:22 +0000
Subject: 5.2-rc6 oops on ia64
Message-Id: <e7f5f9ef-dbf5-3796-7b8e-31fb86045cb5@linux.ee>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I found an oops (NaT consumption 2216203124768) killing udevd worker on HP =
RX2620.
5.1 worked fine, 5.2-rc1 did not show the problem on 2 boots, 5.2.0-rc1-003=
85-g128f2bfafcf2
has shown it on one out of 2 boots, as has 5.2-rc6.

Full dmesg:
[    0.000000] Linux version 5.2.0-rc6-00015-g249155c20f9b (mroos@rx2620) (=
gcc version 8.2.0 (Gentoo 8.2.0-r6 p1.7)) #47 SMP Tue Jun 25 23:32:04 EEST =
2019
[    0.000000] EFI v1.10 by HP:
[    0.000000] efi:  SALsystab=3D0x3ee7a000  ACPI 2.0=3D0x3fe2c000  SMBIOS=
=3D0x3ee7c000  HCDP=3D0x3fe2a000
[    0.000000] PCDP: v3 at 0x3fe2a000
[    0.000000] earlycon: uart8250 at MMIO 0x00000000f4050000 (options '9600=
n8')
[    0.000000] printk: bootconsole [uart8250] enabled
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000003FE2C000 000028 (v02 HP    )
[    0.000000] ACPI: XSDT 0x000000003FE2C02C 00009C (v01 HP     rx2620   00=
000000 HP   00000000)
[    0.000000] ACPI: FACP 0x000000003FE374B8 0000F4 (v03 HP     rx2620   00=
000000 HP   00000000)
[    0.000000] ACPI: DSDT 0x000000003FE2C1C8 008390 (v01 HP     rx2620   00=
000007 INTL 20050309)
[    0.000000] ACPI: FACS 0x000000003FE375B0 000040
[    0.000000] ACPI: SPCR 0x000000003FE375F0 000050 (v01 HP     rx2620   00=
000000 HP   00000000)
[    0.000000] ACPI: DBGP 0x000000003FE37640 000034 (v01 HP     rx2620   00=
000000 HP   00000000)
[    0.000000] ACPI: APIC 0x000000003FE37860 0000C0 (v01 HP     rx2620   00=
000000 HP   00000000)
[    0.000000] ACPI: SPMI 0x000000003FE37678 000050 (v04 HP     rx2620   00=
000000 HP   00000000)
[    0.000000] ACPI: CPEP 0x000000003FE37730 000034 (v01 HP     rx2620   00=
000000 HP   00000000)
[    0.000000] ACPI: SSDT 0x000000003FE34568 0001A7 (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE34718 0007DB (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE34EF8 000887 (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE35788 000887 (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE36018 000887 (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE368A8 000887 (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE37138 0001A9 (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE372E8 0000DC (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FE373C8 0000E0 (v01 HP     rx2620   00=
000006 INTL 20050309)
[    0.000000] ACPI: Local APIC address (____ptrval____)
[    0.000000] 2 CPUs available, 2 CPUs total
[    0.000000] SAL 3.1: HP version 4.29
[    0.000000] SAL Platform features:
[    0.000000]  None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] MCA related initialization done
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000040ffffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000001000000-0x000000003e873fff]
[    0.000000]   node   0: [mem 0x000000003eb90000-0x000000003ee77fff]
[    0.000000]   node   0: [mem 0x000000003fc00000-0x000000003fe27fff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x00000005ffffbfff]
[    0.000000]   node   0: [mem 0x0000004040000000-0x00000040feffbfff]
[    0.000000]   node   0: [mem 0x00000040ff000000-0x00000040ffc2ffff]
[    0.000000]   node   0: [mem 0x00000040ffc9c000-0x00000040ffe03fff]
[    0.000000]   node   0: [mem 0x00000040ffe80000-0x00000040fffe3fff]
[    0.000000] Zeroed struct page in unavailable ranges: 2274 pages
[    0.000000] Initmem setup node 0 [mem 0x0000000001000000-0x00000040fffe3=
fff]
[    0.000000] On node 0 totalpages: 1570590
[    0.000000]   DMA32 zone: 217 pages used for memmap
[    0.000000]   DMA32 zone: 0 pages reserved
[    0.000000]   DMA32 zone: 63329 pages, LIFO batch:15
[    0.000000]   Normal zone: 5152 pages used for memmap
[    0.000000]   Normal zone: 1507261 pages, LIFO batch:15
[    0.000000] pcpu-alloc: s32408 r8192 d221544 u262144 alloc=16*16384
[    0.000000] pcpu-alloc: [0] 0 [0] 1
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 15652=
21
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3Dscsi0:/EFI/gentoo/boot/vml=
inuz root=3D/dev/sda3  ro
[    0.000000] Sorting __ex_table...
[    0.000000] Memory: 25024576K/25129440K available (12365K kernel code, 6=
05K rwdata, 1196K rodata, 752K init, 302K bss, 104864K reserved, 0K cma-res=
erved)
[    0.000000] SLUB: HWalign=128, Order=3D0-3, MinObjects=3D0, CPUs=3D2, No=
des=16
[    0.000000] rcu: Hierarchical RCU implementation.
[    0.000000] rcu: 	RCU restricting CPUs from NR_CPUS=3D4 to nr_cpu_ids=3D=
2.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 2=
5 jiffies.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS: 384
[    0.000000] ACPI: Local APIC address (____ptrval____)
[    0.000000] GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
[    0.000000] CPU 0: base freq=199.999MHz, ITC ratio=16/2, ITC freq=1599.9=
92MHz
[    0.000000] +/-800ppm
[    0.000000] clocksource: itc: mask: 0xffffffffffffffff max_cycles: 0x171=
01df767f, max_idle_ns: 440795286379 ns
[    0.008000] Console: colour VGA+ 80x25
[    0.008000] ACPI: Core revision 20190509
[    0.012000] Calibrating delay loop... 2390.01 BogoMIPS (lpjG80032)
[    0.028000] pid_max: default: 32768 minimum: 301
[    0.040000] Dentry cache hash table entries: 4194304 (order: 11, 3355443=
2 bytes)
[    0.048000] Inode-cache hash table entries: 2097152 (order: 10, 16777216=
 bytes)
[    0.048000] Mount-cache hash table entries: 65536 (order: 5, 524288 byte=
s)
[    0.052000] Mountpoint-cache hash table entries: 65536 (order: 5, 524288=
 bytes)
[    0.052000] Boot processor id 0x0/0x0
[    0.064000] rcu: Hierarchical SRCU implementation.
[    0.064000] smp: Bringing up secondary CPUs ...
[    0.004000] CPU 1: synchronized ITC with CPU 0 (last diff -43 cycles, ma=
xerr 721 cycles)
[    0.004000] CPU 1: base freq=199.999MHz, ITC ratio=16/2, ITC freq=1599.9=
92MHz
[    0.004000] +/-800ppm
[    0.084000] smp: Brought up 1 node, 2 CPUs
[    0.084000] Total of 2 processors activated (4780.03 BogoMIPS).
[    0.084000] devtmpfs: initialized
[    0.092000] random: get_random_u32 called from bucket_table_alloc.isra.2=
8+0xd0/0x3e0 with crng_init=3D0
[    0.096000] SMBIOS 2.3 present.
[    0.096000] DMI: hp server rx2620                   , BIOS 04.29        =
                                                    11/30/2007
[    0.104000] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfffffff=
f, max_idle_ns: 7645041785100000 ns
[    0.112000] futex hash table entries: 512 (order: 2, 65536 bytes)
[    0.112000] NET: Registered protocol family 16
[    0.120000] ACPI: bus type PCI registered
[    0.120000] HugeTLB registered 256 MiB page size, pre-allocated 0 pages
[    0.128000] ACPI: Added _OSI(Module Device)
[    0.128000] ACPI: Added _OSI(Processor Device)
[    0.136000] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.136000] ACPI: Added _OSI(Processor Aggregator Device)
[    0.136000] ACPI: Added _OSI(Linux-Dell-Video)
[    0.144000] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
[    0.144000] ACPI: Added _OSI(Linux-HPI-Hybrid-Graphics)
[    0.152000] ACPI: 10 ACPI AML tables successfully acquired and loaded
[    0.184000] ACPI: Interpreter enabled
[    0.184000] ACPI: (supports S0 S5)
[    0.184000] ACPI: Using IOSAPIC for interrupt routing
[    0.200000] ACPI: Enabled 1 GPEs in block 10 to 1F
[    0.416000] ACPI: PCI Root Bridge [L000] (domain 0000 [bus 00-1f])
[    0.416000] acpi HWP0002:00: _OSC: OS supports [ExtendedConfig Segments =
MSI HPX-Type3]
[    0.432000] PCI host bridge to bus 0000:00
[    0.432000] pci_bus 0000:00: root bus resource [io  0x0000-0x03af window]
[    0.432000] pci_bus 0000:00: root bus resource [io  0x03e0-0x1fff window]
[    0.432000] pci_bus 0000:00: root bus resource [mem 0x80000000-0x8ffffff=
f window]
[    0.440000] pci_bus 0000:00: root bus resource [mem 0x80004000000-0x8010=
3fffffe window]
[    0.440000] pci_bus 0000:00: root bus resource [bus 00-1f]
[    0.448000] pci 0000:00:01.0: [1033:0035] type 00 class 0x0c0310
[    0.456000] pci 0000:00:01.0: reg 0x10: [mem 0x80002000-0x80002fff]
[    0.460000] pci 0000:00:01.0: supports D1 D2
[    0.460000] pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
[    0.464000] pci 0000:00:01.1: [1033:0035] type 00 class 0x0c0310
[    0.472000] pci 0000:00:01.1: reg 0x10: [mem 0x80001000-0x80001fff]
[    0.476000] pci 0000:00:01.1: supports D1 D2
[    0.476000] pci 0000:00:01.1: PME# supported from D0 D1 D2 D3hot
[    0.480000] pci 0000:00:01.2: [1033:00e0] type 00 class 0x0c0320
[    0.488000] pci 0000:00:01.2: reg 0x10: [mem 0x80000000-0x800000ff]
[    0.492000] pci 0000:00:01.2: supports D1 D2
[    0.492000] pci 0000:00:01.2: PME# supported from D0 D1 D2 D3hot
[    0.496000] pci 0000:00:02.0: [1095:0649] type 00 class 0x01018f
[    0.500000] pci 0000:00:02.0: reg 0x10: [io  0x0d18-0x0d1f]
[    0.500000] pci 0000:00:02.0: reg 0x14: [io  0x0d24-0x0d27]
[    0.508000] pci 0000:00:02.0: reg 0x18: [io  0x0d10-0x0d17]
[    0.508000] pci 0000:00:02.0: reg 0x1c: [io  0x0d20-0x0d23]
[    0.516000] pci 0000:00:02.0: reg 0x20: [io  0x0d00-0x0d0f]
[    0.524000] pci 0000:00:02.0: supports D1 D2
[    0.544000] ACPI: PCI Root Bridge [L001] (domain 0000 [bus 20-3f])
[    0.544000] acpi HWP0002:01: _OSC: OS supports [ExtendedConfig Segments =
MSI HPX-Type3]
[    0.560000] PCI host bridge to bus 0000:20
[    0.560000] pci_bus 0000:20: root bus resource [io  0x2000-0x2fff window]
[    0.560000] pci_bus 0000:20: root bus resource [mem 0x90000000-0x97fffff=
f window]
[    0.560000] pci_bus 0000:20: root bus resource [mem 0x90004000000-0x9010=
3fffffe window]
[    0.568000] pci_bus 0000:20: root bus resource [bus 20-3f]
[    0.568000] pci 0000:20:01.0: [1000:0030] type 00 class 0x010000
[    0.576000] pci 0000:20:01.0: reg 0x10: [io  0x2100-0x21ff]
[    0.576000] pci 0000:20:01.0: reg 0x14: [mem 0x903a0000-0x903bffff 64bit]
[    0.584000] pci 0000:20:01.0: reg 0x1c: [mem 0x90380000-0x9039ffff 64bit]
[    0.592000] pci 0000:20:01.0: reg 0x30: [mem 0x90100000-0x901fffff pref]
[    0.596000] pci 0000:20:01.0: supports D1 D2
[    0.600000] pci 0000:20:01.1: [1000:0030] type 00 class 0x010000
[    0.600000] pci 0000:20:01.1: reg 0x10: [io  0x2000-0x20ff]
[    0.608000] pci 0000:20:01.1: reg 0x14: [mem 0x90360000-0x9037ffff 64bit]
[    0.608000] pci 0000:20:01.1: reg 0x1c: [mem 0x90340000-0x9035ffff 64bit]
[    0.616000] random: fast init done
[    0.616000] pci 0000:20:01.1: reg 0x30: [mem 0x90000000-0x900fffff pref]
[    0.628000] pci 0000:20:01.1: supports D1 D2
[    0.628000] pci 0000:20:02.0: [8086:1079] type 00 class 0x020000
[    0.632000] pci 0000:20:02.0: reg 0x10: [mem 0x90320000-0x9033ffff 64bit]
[    0.632000] pci 0000:20:02.0: reg 0x18: [mem 0x90280000-0x902fffff 64bit]
[    0.640000] pci 0000:20:02.0: reg 0x20: [io  0x2240-0x227f]
[    0.640000] pci 0000:20:02.0: reg 0x30: [mem 0x90200000-0x9027ffff pref]
[    0.652000] pci 0000:20:02.0: PME# supported from D0 D3hot D3cold
[    0.656000] pci 0000:20:02.1: [8086:1079] type 00 class 0x020000
[    0.656000] pci 0000:20:02.1: reg 0x10: [mem 0x90300000-0x9031ffff 64bit]
[    0.664000] pci 0000:20:02.1: reg 0x20: [io  0x2200-0x223f]
[    0.668000] pci 0000:20:02.1: PME# supported from D0 D3hot D3cold
[    0.688000] ACPI: PCI Root Bridge [L002] (domain 0000 [bus 40-5f])
[    0.688000] acpi HWP0002:02: _OSC: OS supports [ExtendedConfig Segments =
MSI HPX-Type3]
[    0.716000] PCI host bridge to bus 0000:40
[    0.716000] pci_bus 0000:40: root bus resource [io  0x3000-0x5fff window]
[    0.716000] pci_bus 0000:40: root bus resource [mem 0x98000000-0xaffffff=
f window]
[    0.716000] pci_bus 0000:40: root bus resource [mem 0xa0004000000-0xa010=
3fffffe window]
[    0.720000] pci_bus 0000:40: root bus resource [bus 40-5f]
[    0.748000] ACPI: PCI Root Bridge [L003] (domain 0000 [bus 60-7f])
[    0.748000] acpi HWP0002:03: _OSC: OS supports [ExtendedConfig Segments =
MSI HPX-Type3]
[    0.776000] PCI host bridge to bus 0000:60
[    0.776000] pci_bus 0000:60: root bus resource [io  0x6000-0x7fff window]
[    0.776000] pci_bus 0000:60: root bus resource [mem 0xb0000000-0xc7fffff=
f window]
[    0.776000] pci_bus 0000:60: root bus resource [mem 0xb0004000000-0xb010=
3fffffe window]
[    0.780000] pci_bus 0000:60: root bus resource [bus 60-7f]
[    0.780000] pci 0000:60:01.0: [103c:1029] type 00 class 0x0c0400
[    0.788000] pci 0000:60:01.0: reg 0x14: [io  0x6100-0x61ff]
[    0.788000] pci 0000:60:01.0: reg 0x18: [io  0x6000-0x60ff]
[    0.796000] pci 0000:60:01.0: reg 0x1c: [mem 0xb0040000-0xb00401ff]
[    0.796000] pci 0000:60:01.0: reg 0x24: [mem 0xb0020000-0xb003ffff]
[    0.804000] pci 0000:60:01.0: reg 0x30: [mem 0xb0000000-0xb001ffff pref]
[    0.820000] pci 0000:60:01.0: supports D1
[    0.852000] ACPI: PCI Root Bridge [L004] (domain 0000 [bus 80-bf])
[    0.852000] acpi HWP0002:04: _OSC: OS supports [ExtendedConfig Segments =
MSI HPX-Type3]
[    0.876000] PCI host bridge to bus 0000:80
[    0.876000] pci_bus 0000:80: root bus resource [io  0x8000-0xbfff window]
[    0.880000] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xdffffff=
f window]
[    0.880000] pci_bus 0000:80: root bus resource [mem 0xc0004000000-0xc010=
3fffffe window]
[    0.884000] pci_bus 0000:80: root bus resource [bus 80-bf]
[    0.884000] pci 0000:80:01.0: [103c:1029] type 00 class 0x0c0400
[    0.892000] pci 0000:80:01.0: reg 0x14: [io  0x8100-0x81ff]
[    0.892000] pci 0000:80:01.0: reg 0x18: [io  0x8000-0x80ff]
[    0.900000] pci 0000:80:01.0: reg 0x1c: [mem 0xc8040000-0xc80401ff]
[    0.900000] pci 0000:80:01.0: reg 0x24: [mem 0xc8020000-0xc803ffff]
[    0.908000] pci 0000:80:01.0: reg 0x30: [mem 0xc8000000-0xc801ffff pref]
[    0.920000] pci 0000:80:01.0: supports D1
[    0.956000] ACPI: PCI Root Bridge [L006] (domain 0000 [bus c0-df])
[    0.956000] acpi HWP0002:05: _OSC: OS supports [ExtendedConfig Segments =
MSI HPX-Type3]
[    0.980000] PCI host bridge to bus 0000:c0
[    0.980000] pci_bus 0000:c0: root bus resource [io  0xc000-0xdfff window]
[    0.980000] pci_bus 0000:c0: root bus resource [mem 0xe0000000-0xeffffff=
f window]
[    0.984000] pci_bus 0000:c0: root bus resource [mem 0xe0004000000-0xe010=
3fffffe window]
[    0.988000] pci_bus 0000:c0: root bus resource [bus c0-df]
[    1.020000] ACPI: PCI Root Bridge [L007] (domain 0000 [bus e0-ff])
[    1.020000] acpi HWP0002:06: _OSC: OS supports [ExtendedConfig Segments =
MSI HPX-Type3]
[    1.036000] PCI host bridge to bus 0000:e0
[    1.036000] pci_bus 0000:e0: root bus resource [io  0x03b0-0x03df window]
[    1.036000] pci_bus 0000:e0: root bus resource [io  0xe000-0xffff window]
[    1.036000] pci_bus 0000:e0: root bus resource [mem 0x000a0000-0x000ffff=
f window]
[    1.044000] pci_bus 0000:e0: root bus resource [mem 0xf0000000-0xfdfffff=
f window]
[    1.044000] pci_bus 0000:e0: root bus resource [mem 0xf0004000000-0xf010=
3fffffe window]
[    1.052000] pci_bus 0000:e0: root bus resource [bus e0-ff]
[    1.060000] pci 0000:e0:01.0: [103c:1290] type 00 class 0x078000
[    1.064000] pci 0000:e0:01.0: reg 0x18: [mem 0xf4051000-0xf405100f]
[    1.076000] pci 0000:e0:01.1: [103c:1048] type 00 class 0x070002
[    1.076000] pci 0000:e0:01.1: reg 0x10: [mem 0xf4050000-0xf4050fff]
[    1.080000] pci 0000:e0:01.1: reg 0x18: [mem 0xf4020000-0xf403ffff pref]
[    1.092000] pci 0000:e0:02.0: [1002:5159] type 00 class 0x030000
[    1.092000] pci 0000:e0:02.0: reg 0x10: [mem 0xf0000000-0xf3ffffff pref]
[    1.096000] pci 0000:e0:02.0: reg 0x14: [io  0xe000-0xe0ff]
[    1.096000] pci 0000:e0:02.0: reg 0x18: [mem 0xf4040000-0xf404ffff]
[    1.104000] pci 0000:e0:02.0: reg 0x30: [mem 0xf4000000-0xf401ffff pref]
[    1.112000] pci 0000:e0:02.0: supports D1 D2
[    1.116000] pci 0000:e0:02.0: vgaarb: setting as boot VGA device
[    1.116000] pci 0000:e0:02.0: vgaarb: VGA device added: decodes=3Dio+mem=
,owns=3Dio+mem,locks=3Dnone
[    1.120000] pci 0000:e0:02.0: vgaarb: bridge control possible
[    1.128000] vgaarb: loaded
[    1.128000] SCSI subsystem initialized
[    1.128000] Registered efivars operations
[    1.140000] IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[    1.200000] clocksource: Switched to clocksource itc
[    1.200000] pnp: PnP ACPI init
[    1.207600] GSI 34 (level, low) -> CPU 1 (0x0100) vector 49
[    1.207600] pnp 00:00: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.207600] GSI 35 (level, low) -> CPU 0 (0x0000) vector 50
[    1.214026] pnp 00:01: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.263600] pnp: PnP ACPI: found 2 devices
[    1.267600] NET: Registered protocol family 2
[    1.267600] tcp_listen_portaddr_hash hash table entries: 16384 (order: 4=
, 262144 bytes)
[    1.267600] TCP established hash table entries: 262144 (order: 7, 209715=
2 bytes)
[    1.276411] TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
[    1.276411] TCP: Hash tables configured (established 262144 bind 65536)
[    1.284836] UDP hash table entries: 16384 (order: 5, 524288 bytes)
[    1.284836] UDP-Lite hash table entries: 16384 (order: 5, 524288 bytes)
[    1.292619] NET: Registered protocol family 1
[    1.292619] NET: Registered protocol family 44
[    1.300497] GSI 16 (level, low) -> CPU 1 (0x0100) vector 51
[    1.303630] GSI 16 (level, low) -> CPU 1 (0x0100) vector 51 unregistered
[    1.308298] GSI 17 (level, low) -> CPU 0 (0x0000) vector 51
[    1.311600] GSI 17 (level, low) -> CPU 0 (0x0000) vector 51 unregistered
[    1.316236] GSI 18 (level, low) -> CPU 1 (0x0100) vector 51
[    1.319600] GSI 18 (level, low) -> CPU 1 (0x0100) vector 51 unregistered
[    1.324043] pci 0000:e0:02.0: Video device with shadowed ROM at [mem 0x0=
00c0000-0x000dffff]
[    1.331848] PCI: CLS 128 bytes, default 128
[    1.331848] workingset: timestamp_bitsX max_order! bucket_order=3D0
[    1.339575] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[    1.339575] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    1.347604] ACPI: Power Button [PWRF]
[    1.347604] input: Sleep Button as /devices/LNXSYSTM:00/LNXSLPBN:00/inpu=
t/input1
[    1.355301] ACPI: Sleep Button [SLPF]
[    1.355301] thermal LNXTHERM:00: registered as thermal_zone0
[    1.363395] ACPI: Thermal Zone [THM0] (27 C)
[    1.363395] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.391389] 00:00: ttyS0 at MMIO 0xff5e0000 (irq =3D 49, base_baud =3D 1=
15200) is a 16550A
[    1.411944] 00:01: ttyS1 at MMIO 0xff5e2000 (irq =3D 50, base_baud =3D 1=
15200) is a 16550A
[    1.411944] GSI 82 (level, low) -> CPU 0 (0x0000) vector 51
[    1.436938] 0000:e0:01.0: ttyS2 at MMIO 0xf4051000 (irq =3D 54, base_bau=
d =3D 115200) is a 16550A
[    1.461460] 0000:e0:01.1: ttyS3 at MMIO 0xf4050000 (irq =3D 54, base_bau=
d =3D 115200) is a 16550A
[    1.461460] printk: console [ttyS3] enabled
[    1.461460] printk: bootconsole [uart8250] disabled
[    1.468778] serial 0000:e0:01.1: Couldn't register serial port 0, irq 54=
, type 2, error -28
[    1.476130] Fusion MPT base driver 3.04.20
[    1.476130] Copyright (c) 1999-2008 LSI Corporation
[    1.483672] Fusion MPT SPI Host driver 3.04.20
[    1.483672] GSI 27 (level, low) -> CPU 1 (0x0100) vector 52
[    1.495606] mptbase: ioc0: Initiating bringup
[    2.455602] ioc0: LSI53C1030 C0: Capabilities=3D{Initiator,Target}
[    3.799602] scsi host0: ioc0: LSI53C1030 C0, FwRev=01032346h, Ports=3D1,=
 MaxQ%5, IRQU
[    3.803600] GSI 28 (level, low) -> CPU 0 (0x0000) vector 53
[    3.803600] mptbase: ioc1: Initiating bringup
[    4.759602] ioc1: LSI53C1030 C0: Capabilities=3D{Initiator,Target}
[    6.085690] scsi 0:0:0:0: Direct-Access     COMPAQ   BF07285A36       HP=
B7 PQ: 0 ANSI: 3
[    6.085690] scsi target0:0:0: Beginning Domain Validation
[    6.103602] scsi host1: ioc1: LSI53C1030 C0, FwRev=01032346h, Ports=3D1,=
 MaxQ%5, IRQV
[    6.107600] rtc-efi rtc-efi: registered as rtc0
[    6.107600] hidraw: raw HID events driver (C) Jiri Kosina
[    6.118523] NET: Registered protocol family 10
[    6.118523] Segment Routing with IPv6
[    6.118523] NET: Registered protocol family 17
[    6.127611] printk: console [netcon0] enabled
[    6.127611] netconsole: network logging started
[    6.138157] rtc-efi rtc-efi: setting system clock to 2019-06-25T20:37:51=
 UTC (1561495071)
[    6.151603] scsi target0:0:0: Ending Domain Validation
[    6.151603] scsi target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RT=
I WRFLOW PCOMP (6.25 ns, offset 63)
[    9.659602] sd 0:0:0:0: [sda] 142264000 512-byte logical blocks: (72.8 G=
B/67.8 GiB)
[    9.659602] sd 0:0:0:0: [sda] Write Protect is off
[    9.659602] sd 0:0:0:0: [sda] Mode Sense: d3 00 10 08
[    9.661690] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled=
, supports DPO and FUA
[    9.693690]  sda: sda1 sda2 sda3 sda4
[    9.697690] sd 0:0:0:0: [sda] Attached SCSI disk
[    9.891600] EXT4-fs (sda3): mounted filesystem with ordered data mode. O=
pts: (null)
[    9.891600] VFS: Mounted root (ext4 filesystem) readonly on device 8:3.
[    9.903602] devtmpfs: mounted
[    9.903602] Freeing unused kernel memory: 752K
[    9.903602] This architecture does not have kernel memory protection.
[    9.909843] Run /sbin/init as init process
[   11.219602] random: crng init done
[   12.871604] udevd[421]: starting version 3.2.5
[   13.043602] udevd[421]: starting eudev-3.2.5
[   13.223603] EFI Variables Facility v0.08 2004-May-17
[   13.267601] libata version 3.00 loaded.
[   13.303602] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[   13.303602] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   13.347602] ACPI: bus type USB registered
[   13.347602] usbcore: registered new interface driver usbfs
[   13.347602] usbcore: registered new interface driver hub
[   13.347602] usbcore: registered new device driver usb
[   13.359602] GSI 29 (level, low) -> CPU 1 (0x0100) vector 54
[   13.379602] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   13.387601] GSI 21 (level, low) -> CPU 0 (0x0000) vector 55
[   13.387601] pata_cmd64x 0000:00:02.0: Secondary port is disabled
[   13.387601] scsi host2: pata_cmd64x
[   13.387601] scsi host3: pata_cmd64x
[   13.387601] ata1: PATA max UDMA/100 cmd 0xd18 ctl 0xd24 bmdma 0xd00 irq =
58
[   13.387601] ata2: DUMMY
[   13.387601] pata_cmd64x: active 10 recovery 10 setup 3.
[   13.387601] pata_cmd64x: active 10 recovery 10 setup 3.
[   13.391603] ehci-pci: EHCI PCI platform driver
[   13.423600] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   13.447600] GSI 18 (level, low) -> CPU 1 (0x0100) vector 56
[   13.447600] ehci-pci 0000:00:01.2: EHCI Host Controller
[   13.447600] ehci-pci 0000:00:01.2: new USB bus registered, assigned bus =
number 1
[   13.447600] ehci-pci 0000:00:01.2: irq 53, io mem 0x80000000
[   13.467599] ehci-pci 0000:00:01.2: USB 2.0 started, EHCI 0.95
[   13.467599] usb usb1: New USB device found, idVendor=1D6b, idProduct=000=
2, bcdDevice=3D 5.02
[   13.467599] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.467599] usb usb1: Product: EHCI Host Controller
[   13.467599] usb usb1: Manufacturer: Linux 5.2.0-rc6-00015-g249155c20f9b =
ehci_hcd
[   13.467599] usb usb1: SerialNumber: 0000:00:01.2
[   13.471600] hub 1-0:1.0: USB hub found
[   13.471600] hub 1-0:1.0: 5 ports detected
[   13.471600] udevd[498]: NaT consumption 2216203124768 [1]
[   13.471600] Modules linked in: L=01() ohci_hcd ehci_pci ehci_hcd usbcore=
 pata_cmd64x e1000(+) usb_common libata efivars

[   13.471600] CPU: 0 PID: 498 Comm: udevd Not tainted 5.2.0-rc6-00015-g249=
155c20f9b #47
[   13.473692] Hardware name: hp server rx2620                   , BIOS 04.=
29                                                            11/30/2007
[   13.477692] psr : 0000121008526030 ifs : 800000000000050d ip  : [<a00000=
010004a201>]    Not tainted (5.2.0-rc6-00015-g249155c20f9b)
[   13.477692] ip is at get_plt.part.4+0x81/0x2e0
[   13.477692] unat: 0000000000000000 pfs : 00000000000013ab rsc : 00000000=
00000003
[   13.477692] rnat: 0000000000000008 bsps: 000000000001003e pr  : 00000000=
69665959
[   13.477692] ldrs: 0000000000000000 ccv : e000004085380000 fpsr: 0009804c=
0270033f
[   13.477692] csd : 0000000000000000 ssd : 0000000000000000
[   13.477692] b0  : a00000010004c4f0 b6  : a00000010004bef0 b7  : a0000001=
0000bf20
[   13.477692] f6  : 1003e0000000000000528 f7  : 1003eaaaaaaaaaaaaaaab
[   13.477692] f8  : 1003e0000000000000370 f9  : 1003e00000000000004f0
[   13.477692] f10 : 1003e0000000000000000 f11 : 1003e0000000000000000
[   13.477692] r1  : a000000101210a10 r2  : a0000002035e6088 r3  : 00000000=
00000ed0
[   13.477692] r8  : 0000000000000000 r9  : 0000000000000010 r10 : 00000000=
00000020
[   13.477692] r11 : 0000000000000005 r12 : e000004085387d00 r13 : e0000040=
85380000
[   13.477692] r14 : a0000002035e6070 r15 : a0000002035e6078 r16 : 00000000=
000000a2
[   13.477692] r17 : 0000000000000005 r18 : 0000000000000510 r19 : 00000000=
00000001
[   13.477692] r20 : 0000000000009e80 r21 : 00000000000fffff r22 : 08000000=
00000000
[   13.477692] r23 : 0000000000000000 r24 : 07fffff000000000 r25 : 00000000=
00000010
[   13.477692] r26 : 00000000000008e0 r27 : a000000203a10fa0 r28 : a0000002=
035ec950
[   13.477692] r29 : 0000000000000000 r30 : 0000000000000036 r31 : a0000002=
035b2b88
[   13.477692]
                Call Trace:
[   13.477692]  [<a000000100013530>] show_stack+0x90/0xc0
                                                sp=E0000040853878c0 bsp=E00=
0004085381428
[   13.477692]  [<a000000100013c20>] show_regs+0x6c0/0xa00
                                                sp=E000004085387a90 bsp=E00=
00040853813b0
[   13.477692]  [<a000000100027150>] die+0x1b0/0x4a0
                                                sp=E000004085387ab0 bsp=E00=
0004085381370
[   13.477692]  [<a0000001000283a0>] ia64_fault+0x540/0xd60
                                                sp=E000004085387ab0 bsp=E00=
0004085381328
[   13.477692]  [<a00000010000c700>] ia64_leave_kernel+0x0/0x270
                                                sp=E000004085387b30 bsp=E00=
0004085381328
[   13.477692]  [<a00000010004a200>] get_plt.part.4+0x80/0x2e0
                                                sp=E000004085387d00 bsp=E00=
00040853812c0
[   13.477692]  [<a00000010004c4f0>] apply_relocate_add+0xf30/0x13e0
                                                sp=E000004085387d00 bsp=E00=
0004085381180
[   13.477692]  [<a00000010016ba80>] load_module+0x32a0/0x5d40
                                                sp=E000004085387d10 bsp=E00=
0004085380fe8
[   13.477692]  [<a00000010016e8f0>] __do_sys_finit_module+0x110/0x180
                                                sp=E000004085387d90 bsp=E00=
0004085380fb8
[   13.477692]  [<a00000010016e9f0>] sys_finit_module+0x30/0x80
                                                sp=E000004085387e30 bsp=E00=
0004085380f60
[   13.477692]  [<a00000010000c580>] ia64_ret_from_syscall+0x0/0x20
                                                sp=E000004085387e30 bsp=E00=
0004085380f58
[   13.477692] Disabling lock debugging due to kernel taint
[   13.723618] ata1.00: ATAPI: DV-28E-N, E.6A, max UDMA/33
[   13.723618] pata_cmd64x: active 3 recovery 1 setup 1.
[   13.739600] scsi 2:0:0:0: CD-ROM            TEAC     DV-28E-N         E.=
6A PQ: 0 ANSI: 5
[   13.743600] udevd[421]: worker [498] terminated by signal 11 (Segmentati=
on fault)
[   13.743600] udevd[421]: worker [498] failed while handling '/devices/pci=
0000:00/0000:00:01.0'
[   13.779605] ohci-pci: OHCI PCI platform driver
[   13.791603] GSI 16 (level, low) -> CPU 0 (0x0000) vector 57
[   13.791603] ohci-pci 0000:00:01.0: OHCI PCI host controller
[   13.795683] ohci-pci 0000:00:01.0: new USB bus registered, assigned bus =
number 2
[   13.795683] ohci-pci 0000:00:01.0: irq 51, io mem 0x80002000
[   13.945707] e1000 0000:20:02.0 eth0: (PCI-X:66MHz:64-bit) 00:17:08:7c:2a=
:8a
[   13.945707] e1000 0000:20:02.0 eth0: Intel(R) PRO/1000 Network Connection
[   14.371600] usb usb2: New USB device found, idVendor=1D6b, idProduct=000=
1, bcdDevice=3D 5.02
[   14.371600] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   14.373690] usb usb2: Product: OHCI PCI host controller
[   14.377891] usb usb2: Manufacturer: Linux 5.2.0-rc6-00015-g249155c20f9b =
ohci_hcd
[   14.377891] usb usb2: SerialNumber: 0000:00:01.0
[   14.389346] hub 2-0:1.0: USB hub found
[   14.389346] GSI 30 (level, low) -> CPU 1 (0x0100) vector 58
[   14.391601] hub 2-0:1.0: 3 ports detected
[   14.399600] GSI 17 (level, low) -> CPU 0 (0x0000) vector 59
[   14.404243] ohci-pci 0000:00:01.1: OHCI PCI host controller
[   14.404243] ohci-pci 0000:00:01.1: new USB bus registered, assigned bus =
number 3
[   14.411888] ohci-pci 0000:00:01.1: irq 52, io mem 0x80001000
[   14.733688] e1000 0000:20:02.1 eth1: (PCI-X:66MHz:64-bit) 00:17:08:7c:2a=
:8b
[   14.733688] e1000 0000:20:02.1 eth1: Intel(R) PRO/1000 Network Connection
[   14.789690] e1000 0000:20:02.0 enp32s2f0: renamed from eth0
[   14.969695] EXT4-fs (sda3): re-mounted. Opts: errors=3Dremount-ro
[   14.987599] usb usb3: New USB device found, idVendor=1D6b, idProduct=000=
1, bcdDevice=3D 5.02
[   14.987599] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   14.987599] usb usb3: Product: OHCI PCI host controller
[   14.992461] usb usb3: Manufacturer: Linux 5.2.0-rc6-00015-g249155c20f9b =
ohci_hcd
[   15.003601] usb usb3: SerialNumber: 0000:00:01.1
[   15.003601] hub 3-0:1.0: USB hub found
[   15.011270] e1000 0000:20:02.1 enp32s2f1: renamed from eth1
[   15.011270] hub 3-0:1.0: 2 ports detected
[   15.173690] Adding 3906544k swap on /dev/sda2.  Priority:-2 extents:1 ac=
ross:3906544k
[   17.471603] e1000: enp32s2f0 NIC Link is Up 100 Mbps Full Duplex, Flow C=
ontrol: RX
[   17.471603] IPv6: ADDRCONF(NETDEV_CHANGE): enp32s2f0: link becomes ready

Config:
#
# Automatically generated file; DO NOT EDIT.
# Linux/ia64 5.2.0-rc6 Kernel Configuration
#

#
# Compiler: gcc (Gentoo 8.2.0-r6 p1.7) 8.2.0
#
CONFIG_CC_IS_GCC=3Dy
CONFIG_GCC_VERSION=80200
CONFIG_CLANG_VERSION=3D0
CONFIG_CC_HAS_ASM_GOTO=3Dy
CONFIG_CC_HAS_WARN_MAYBE_UNINITIALIZED=3Dy
CONFIG_IRQ_WORK=3Dy

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT2
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=3D""
CONFIG_LOCALVERSION_AUTO=3Dy
CONFIG_BUILD_SALT=3D""
CONFIG_DEFAULT_HOSTNAME=3D"(none)"
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
CONFIG_SYSVIPC_SYSCTL=3Dy
CONFIG_POSIX_MQUEUE=3Dy
CONFIG_POSIX_MQUEUE_SYSCTL=3Dy
CONFIG_CROSS_MEMORY_ATTACH=3Dy
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=3Dy

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_LEGACY=3Dy
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_GENERIC_IRQ_SHOW=3Dy
CONFIG_GENERIC_PENDING_IRQ=3Dy
CONFIG_GENERIC_MSI_IRQ=3Dy
# end of IRQ subsystem

CONFIG_ARCH_CLOCKSOURCE_DATA=3Dy
CONFIG_GENERIC_TIME_VSYSCALL=3Dy
CONFIG_PREEMPT_NONE=3Dy
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=3Dy
# CONFIG_VIRT_CPU_ACCOUNTING_NATIVE is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
# CONFIG_PSI is not set
# end of CPU/Task time and stats accounting

# CONFIG_CPU_ISOLATION is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=3Dy
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=3Dy
CONFIG_TREE_SRCU=3Dy
CONFIG_RCU_STALL_COMMON=3Dy
CONFIG_RCU_NEED_SEGCBLIST=3Dy
# end of RCU Subsystem

# CONFIG_IKCONFIG is not set
# CONFIG_IKHEADERS is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
CONFIG_CGROUPS=3Dy
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_BPF=3Dy
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=3Dy
CONFIG_NAMESPACES=3Dy
CONFIG_UTS_NS=3Dy
CONFIG_IPC_NS=3Dy
CONFIG_USER_NS=3Dy
CONFIG_PID_NS=3Dy
CONFIG_NET_NS=3Dy
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
# CONFIG_BLK_DEV_INITRD is not set
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=3Dy
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=3Dy
CONFIG_SYSCTL_ARCH_UNALIGN_NO_WARN=3Dy
CONFIG_BPF=3Dy
# CONFIG_EXPERT is not set
CONFIG_MULTIUSER=3Dy
CONFIG_SYSFS_SYSCALL=3Dy
CONFIG_FHANDLE=3Dy
CONFIG_POSIX_TIMERS=3Dy
CONFIG_PRINTK=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_FUTEX_PI=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SIGNALFD=3Dy
CONFIG_TIMERFD=3Dy
CONFIG_EVENTFD=3Dy
CONFIG_SHMEM=3Dy
CONFIG_AIO=3Dy
CONFIG_IO_URING=3Dy
CONFIG_ADVISE_SYSCALLS=3Dy
CONFIG_MEMBARRIER=3Dy
CONFIG_KALLSYMS=3Dy
# CONFIG_KALLSYMS_ALL is not set
CONFIG_BPF_SYSCALL=3Dy
CONFIG_USERFAULTFD=3Dy
# CONFIG_EMBEDDED is not set

#
# Kernel Performance Events And Counters
#
# end of Kernel Performance Events And Counters

CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_SLUB_DEBUG=3Dy
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=3Dy
CONFIG_SLAB_MERGE_DEFAULT=3Dy
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
# CONFIG_SHUFFLE_PAGE_ALLOCATOR is not set
CONFIG_SLUB_CPU_PARTIAL=3Dy
# CONFIG_PROFILING is not set
# end of General setup

CONFIG_PGTABLE_LEVELS=3D3

#
# Processor type and features
#
CONFIG_IA64=3Dy
CONFIG_64BIT=3Dy
CONFIG_ZONE_DMA32=3Dy
CONFIG_QUICKLIST=3Dy
CONFIG_MMU=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_HUGETLB_PAGE_SIZE_VARIABLE=3Dy
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
CONFIG_DMI=3Dy
CONFIG_EFI=3Dy
CONFIG_SCHED_OMIT_FRAME_POINTER=3Dy
CONFIG_IA64_UNCACHED_ALLOCATOR=3Dy
CONFIG_ARCH_USES_PG_UNCACHED=3Dy
CONFIG_AUDIT_ARCH=3Dy
# CONFIG_IA64_GENERIC is not set
# CONFIG_IA64_DIG is not set
# CONFIG_IA64_DIG_VTD is not set
CONFIG_IA64_HP_ZX1=3Dy
# CONFIG_IA64_HP_ZX1_SWIOTLB is not set
# CONFIG_IA64_SGI_SN2 is not set
# CONFIG_IA64_SGI_UV is not set
# CONFIG_ITANIUM is not set
CONFIG_MCKINLEY=3Dy
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
CONFIG_IA64_PAGE_SIZE_16KB=3Dy
# CONFIG_IA64_PAGE_SIZE_64KB is not set
CONFIG_HZ%0
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=3Dy
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_IA64_L1_CACHE_SHIFT=3D7
# CONFIG_IA64_CYCLONE is not set
CONFIG_IOSAPIC=3Dy
CONFIG_FORCE_MAX_ZONEORDER=17
CONFIG_SMP=3Dy
CONFIG_NR_CPUS=3D4
# CONFIG_HOTPLUG_CPU is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=3Dy
# CONFIG_SCHED_SMT is not set
CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
CONFIG_ARCH_DISCONTIGMEM_ENABLE=3Dy
CONFIG_ARCH_FLATMEM_ENABLE=3Dy
CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
CONFIG_ARCH_DISCONTIGMEM_DEFAULT=3Dy
CONFIG_NUMA=3Dy
CONFIG_NODES_SHIFT=3D4
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=3Dy
CONFIG_HAVE_ARCH_NODEDATA_EXTENSION=3Dy
CONFIG_USE_PERCPU_NUMA_NODE_ID=3Dy
CONFIG_HAVE_MEMORYLESS_NODES=3Dy
CONFIG_ARCH_PROC_KCORE_TEXT=3Dy
CONFIG_IA64_MCA_RECOVERY=3Dm
CONFIG_IA64_PALINFO=3Dm
# CONFIG_IA64_MC_ERR_INJECT is not set
CONFIG_IA64_ESI=3Dy
CONFIG_IA64_HP_AML_NFW=3Dy

#
# Firmware Drivers
#
CONFIG_EFI_PCDP=3Dy
CONFIG_DMIID=3Dy
CONFIG_DMI_SYSFS=3Dm
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=3Dy
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=3Dm
CONFIG_EFI_BOOTLOADER_CONTROL=3Dm
CONFIG_EFI_CAPSULE_LOADER=3Dm
# CONFIG_EFI_TEST is not set
# end of EFI (Extensible Firmware Interface) Support

#
# Tegra firmware driver
#
# end of Tegra firmware driver
# end of Firmware Drivers
# end of Processor type and features

#
# Power management and ACPI options
#
CONFIG_PM=3Dy
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
# CONFIG_ENERGY_MODEL is not set
CONFIG_ARCH_SUPPORTS_ACPI=3Dy
CONFIG_ACPI=3Dy
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=3Dy
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=3Dy
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=3Dy
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_BUTTON=3Dy
CONFIG_ACPI_FAN=3Dy
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=3Dy
CONFIG_ACPI_PROCESSOR_CSTATE=3Dy
CONFIG_ACPI_PROCESSOR_IDLE=3Dy
CONFIG_ACPI_PROCESSOR=3Dy
CONFIG_ACPI_THERMAL=3Dy
CONFIG_ACPI_NUMA=3Dy
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=3Dy
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_HMAT is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set

#
# CPU Frequency scaling
#

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=3Dy
CONFIG_CPU_FREQ_GOV_ATTR_SET=3Dy
CONFIG_CPU_FREQ_GOV_COMMON=3Dy
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=3Dy
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=3Dm
CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dy
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_SCHEDUTIL=3Dy

#
# CPU frequency scaling drivers
#
CONFIG_IA64_ACPI_CPUFREQ=3Dm
# end of CPU Frequency scaling
# end of CPU Frequency scaling
# end of Power management and ACPI options

CONFIG_MSPEC=3Dm

#
# General architecture-dependent options
#
CONFIG_CRASH_CORE=3Dy
CONFIG_HAVE_OPROFILE=3Dy
# CONFIG_KPROBES is not set
CONFIG_HAVE_64BIT_ALIGNED_ACCESS=3Dy
CONFIG_HAVE_KPROBES=3Dy
CONFIG_HAVE_KRETPROBES=3Dy
CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
CONFIG_GENERIC_SMP_IDLE_THREAD=3Dy
CONFIG_ARCH_TASK_STRUCT_ON_STACK=3Dy
CONFIG_ARCH_TASK_STRUCT_ALLOCATOR=3Dy
CONFIG_ARCH_THREAD_STACK_ALLOCATOR=3Dy
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=3Dy
CONFIG_CC_HAS_STACKPROTECTOR_NONE=3Dy
CONFIG_HAVE_VIRT_CPU_ACCOUNTING=3Dy
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=3Dy
CONFIG_HAVE_MOD_ARCH_SPECIFIC=3Dy
CONFIG_MODULES_USE_ELF_RELA=3Dy
CONFIG_HAVE_EXIT_THREAD=3Dy
CONFIG_64BIT_TIME=3Dy
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
# end of GCOV-based kernel profiling

CONFIG_PLUGIN_HOSTCC=3D""
# end of General architecture-dependent options

CONFIG_RT_MUTEXES=3Dy
CONFIG_BASE_SMALL=3D0
CONFIG_MODULES=3Dy
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=3Dy
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_BLOCK=3Dy
CONFIG_BLK_SCSI_REQUEST=3Dy
CONFIG_BLK_DEV_BSG=3Dy
# CONFIG_BLK_DEV_BSGLIB is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_DEV_ZONED is not set
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=3Dy
CONFIG_EFI_PARTITION=3Dy
# end of Partition Types

CONFIG_BLK_MQ_PCI=3Dy
CONFIG_BLK_PM=3Dy

#
# IO Schedulers
#
# CONFIG_MQ_IOSCHED_DEADLINE is not set
# CONFIG_MQ_IOSCHED_KYBER is not set
# CONFIG_IOSCHED_BFQ is not set
# end of IO Schedulers

CONFIG_INLINE_SPIN_UNLOCK_IRQ=3Dy
CONFIG_INLINE_READ_UNLOCK=3Dy
CONFIG_INLINE_READ_UNLOCK_IRQ=3Dy
CONFIG_INLINE_WRITE_UNLOCK=3Dy
CONFIG_INLINE_WRITE_UNLOCK_IRQ=3Dy

#
# Executable file formats
#
CONFIG_BINFMT_ELF=3Dy
CONFIG_ELFCORE=3Dy
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=3Dy
CONFIG_BINFMT_SCRIPT=3Dy
CONFIG_BINFMT_MISC=3Dy
CONFIG_COREDUMP=3Dy
# end of Executable file formats

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=3Dy
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=3Dy
CONFIG_SPARSEMEM=3Dy
CONFIG_NEED_MULTIPLE_NODES=3Dy
CONFIG_HAVE_MEMORY_PRESENT=3Dy
CONFIG_SPARSEMEM_EXTREME=3Dy
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=3Dy
CONFIG_SPARSEMEM_VMEMMAP=3Dy
CONFIG_HAVE_MEMBLOCK_NODE_MAP=3Dy
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=3D4
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=3Dy
CONFIG_PHYS_ADDR_T_64BIT=3Dy
CONFIG_NR_QUICK=3D1
CONFIG_VIRT_TO_BUS=3Dy
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR@96
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZPOOL is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
# CONFIG_IDLE_PAGE_TRACKING is not set
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
# end of Memory Management options

CONFIG_NET=3Dy
CONFIG_SKB_EXTENSIONS=3Dy

#
# Networking options
#
CONFIG_PACKET=3Dy
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=3Dy
CONFIG_UNIX_SCM=3Dy
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=3Dy
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_INTERFACE is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_XDP_SOCKETS=3Dy
# CONFIG_XDP_SOCKETS_DIAG is not set
CONFIG_INET=3Dy
CONFIG_IP_MULTICAST=3Dy
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=3Dm
# CONFIG_IP_MROUTE is not set
CONFIG_SYN_COOKIES=3Dy
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=3Dm
CONFIG_INET_DIAG=3Dy
CONFIG_INET_TCP_DIAG=3Dy
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_DEFAULT_TCP_CONG=3D"cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=3Dy
CONFIG_IPV6_ROUTER_PREF=3Dy
CONFIG_IPV6_ROUTE_INFO=3Dy
CONFIG_IPV6_OPTIMISTIC_DAD=3Dy
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
CONFIG_IPV6_MIP6=3Dm
CONFIG_INET6_TUNNEL=3Dm
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=3Dm
CONFIG_IPV6_SIT_6RD=3Dy
CONFIG_IPV6_NDISC_NODETYPE=3Dy
CONFIG_IPV6_TUNNEL=3Dm
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_BPFILTER=3Dy
CONFIG_BPFILTER_UMH=3Dm
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=3Dy
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_NET_NSH is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
CONFIG_RPS=3Dy
CONFIG_RFS_ACCEL=3Dy
CONFIG_XPS=3Dy
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=3Dy
CONFIG_BQL=3Dy
# CONFIG_BPF_STREAM_PARSER is not set
CONFIG_NET_FLOW_LIMIT=3Dy

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# end of Network testing
# end of Networking options

# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=3Dy
CONFIG_GRO_CELLS=3Dy
# CONFIG_FAILOVER is not set

#
# Device Drivers
#
CONFIG_HAVE_PCI=3Dy
CONFIG_FORCE_PCI=3Dy
CONFIG_PCI=3Dy
CONFIG_PCI_DOMAINS=3Dy
CONFIG_PCI_SYSCALL=3Dy
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_MSI=3Dy
CONFIG_PCI_QUIRKS=3Dy
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=3Dy
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
# end of Cadence PCIe controllers support

#
# DesignWare PCI Core Support
#
# end of DesignWare PCI Core Support
# end of PCI controller drivers

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set
# end of PCI Endpoint

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
# end of PCI switch controller drivers

# CONFIG_PCCARD is not set
# CONFIG_RAPIDIO is not set

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=3Dy
CONFIG_UEVENT_HELPER_PATH=3D""
CONFIG_DEVTMPFS=3Dy
CONFIG_DEVTMPFS_MOUNT=3Dy
CONFIG_STANDALONE=3Dy
CONFIG_PREVENT_FIRMWARE_BUILD=3Dy

#
# Firmware loader
#
CONFIG_FW_LOADER=3Dy
CONFIG_EXTRA_FIRMWARE=3D""
# CONFIG_FW_LOADER_USER_HELPER is not set
# end of Firmware loader

CONFIG_ALLOW_DEV_COREDUMP=3Dy
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
# end of Generic Driver Options

#
# Bus devices
#
# end of Bus devices

# CONFIG_CONNECTOR is not set
# CONFIG_GNSS is not set
# CONFIG_MTD is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=3Dy
# CONFIG_PARPORT is not set
CONFIG_PNP=3Dy
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=3Dy
# CONFIG_BLK_DEV is not set

#
# NVME Support
#
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_NVME_FC is not set
# end of NVME Support

#
# Misc devices
#
# CONFIG_DUMMY_IRQ is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
# CONFIG_PVPANIC is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_93CX6 is not set
# end of EEPROM support

# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# end of Texas Instruments shared transport line discipline

#
# Altera FPGA firmware download module (requires I2C)
#

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# end of Intel MIC & related support

# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_MISC_ALCOR_PCI is not set
# CONFIG_MISC_RTSX_PCI is not set
# CONFIG_MISC_RTSX_USB is not set
# CONFIG_HABANA_AI is not set
# end of Misc devices

CONFIG_HAVE_IDE=3Dy
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=3Dy
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=3Dy
CONFIG_SCSI_DMA=3Dy
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dy
CONFIG_CHR_DEV_ST=3Dm
# CONFIG_CHR_DEV_OSST is not set
CONFIG_CHR_DEV_SG=3Dm
CONFIG_CHR_DEV_SCH=3Dm
CONFIG_SCSI_CONSTANTS=3Dy
CONFIG_SCSI_LOGGING=3Dy
CONFIG_SCSI_SCAN_ASYNC=3Dy

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=3Dy
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
# end of SCSI Transports

# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_DH is not set
# end of SCSI device support

CONFIG_ATA=3Dm
CONFIG_ATA_NONSTANDARD=3Dy
CONFIG_ATA_VERBOSE_ERROR=3Dy
CONFIG_ATA_ACPI=3Dy
CONFIG_SATA_ZPODD=3Dy
CONFIG_SATA_PMP=3Dy

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=3Dy

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=3Dy

#
# SATA SFF controllers with BMDMA
#
# CONFIG_ATA_PIIX is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
CONFIG_PATA_CMD64X=3Dm
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=3Dy
CONFIG_FUSION_SPI=3Dy
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=3Dm
CONFIG_FUSION_LOGGING=3Dy

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# end of IEEE 1394 (FireWire) support

CONFIG_NETDEVICES=3Dy
CONFIG_NET_CORE=3Dy
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_IPVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
CONFIG_NETCONSOLE=3Dy
CONFIG_NETPOLL=3Dy
CONFIG_NET_POLL_CONTROLLER=3Dy
CONFIG_TUN=3Dm
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
# end of Distributed Switch Architecture drivers

CONFIG_ETHERNET=3Dy
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_AGERE is not set
# CONFIG_NET_VENDOR_ALACRITECH is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_ALTERA_TSE is not set
# CONFIG_NET_VENDOR_AMAZON is not set
# CONFIG_NET_VENDOR_AMD is not set
# CONFIG_NET_VENDOR_AQUANTIA is not set
# CONFIG_NET_VENDOR_ARC is not set
# CONFIG_NET_VENDOR_ATHEROS is not set
# CONFIG_NET_VENDOR_AURORA is not set
# CONFIG_NET_VENDOR_BROADCOM is not set
# CONFIG_NET_VENDOR_BROCADE is not set
# CONFIG_NET_VENDOR_CADENCE is not set
# CONFIG_NET_VENDOR_CAVIUM is not set
# CONFIG_NET_VENDOR_CHELSIO is not set
# CONFIG_NET_VENDOR_CISCO is not set
# CONFIG_NET_VENDOR_CORTINA is not set
# CONFIG_DNET is not set
# CONFIG_NET_VENDOR_DEC is not set
# CONFIG_NET_VENDOR_DLINK is not set
# CONFIG_NET_VENDOR_EMULEX is not set
# CONFIG_NET_VENDOR_EZCHIP is not set
# CONFIG_NET_VENDOR_HP is not set
# CONFIG_NET_VENDOR_HUAWEI is not set
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_NET_VENDOR_INTEL=3Dy
# CONFIG_E100 is not set
CONFIG_E1000=3Dm
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
# CONFIG_I40EVF is not set
# CONFIG_ICE is not set
# CONFIG_FM10K is not set
# CONFIG_IGC is not set
# CONFIG_JME is not set
# CONFIG_NET_VENDOR_MARVELL is not set
# CONFIG_NET_VENDOR_MELLANOX is not set
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_MICROCHIP is not set
# CONFIG_NET_VENDOR_MICROSEMI is not set
# CONFIG_NET_VENDOR_MYRI is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NETERION is not set
# CONFIG_NET_VENDOR_NETRONOME is not set
# CONFIG_NET_VENDOR_NI is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
# CONFIG_NET_VENDOR_OKI is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_VENDOR_PACKET_ENGINES is not set
# CONFIG_NET_VENDOR_QLOGIC is not set
# CONFIG_NET_VENDOR_QUALCOMM is not set
# CONFIG_NET_VENDOR_RDC is not set
# CONFIG_NET_VENDOR_REALTEK is not set
# CONFIG_NET_VENDOR_RENESAS is not set
# CONFIG_NET_VENDOR_ROCKER is not set
# CONFIG_NET_VENDOR_SAMSUNG is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SOLARFLARE is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_SOCIONEXT is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_SYNOPSYS is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Host-side USB support is needed for USB Network Adapter support
#
# CONFIG_USB_NET_DRIVERS is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=3Dy
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=3Dy
CONFIG_KEYBOARD_ATKBD=3Dy
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=3Dy
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=3Dy
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set
# end of Hardware I/O ports
# end of Input device support

#
# Character devices
#
CONFIG_TTY=3Dy
CONFIG_VT=3Dy
CONFIG_CONSOLE_TRANSLATIONS=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_HW_CONSOLE=3Dy
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_UNIX98_PTYS=3Dy
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_NULL_TTY is not set
CONFIG_LDISC_AUTOLOAD=3Dy
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=3Dy
CONFIG_SERIAL_8250=3Dy
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=3Dy
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=3Dy
CONFIG_SERIAL_8250_PCI=3Dy
# CONFIG_SERIAL_8250_EXAR is not set
CONFIG_SERIAL_8250_NR_UARTS=3D4
CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=3Dy
CONFIG_SERIAL_CORE_CONSOLE=3Dy
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# end of Serial drivers

# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=3Dm
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=3Dm
# CONFIG_APPLICOM is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=3Dm
# CONFIG_TCG_TPM is not set
CONFIG_DEVPORT=3Dy
# CONFIG_XILLYBUS is not set
# end of Character devices

#
# I2C support
#
# CONFIG_I2C is not set
# end of I2C support

# CONFIG_I3C is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set
# CONFIG_PPS is not set

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# end of PTP clock support

# CONFIG_PINCTRL is not set
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=3Dy
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_HWMON is not set
CONFIG_THERMAL=3Dy
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=3D0
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=3Dy
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=3Dy
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_WATCHDOG=3Dy
CONFIG_WATCHDOG_CORE=3Dy
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=3Dy
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=3Dm
# CONFIG_WDAT_WDT is not set
# CONFIG_XILINX_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_ITCO_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
CONFIG_SSB_POSSIBLE=3Dy
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=3Dy
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_MADERA is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_TQMX86 is not set
# CONFIG_MFD_VX855 is not set
# end of Multifunction device drivers

# CONFIG_REGULATOR is not set
# CONFIG_RC_CORE is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=3Dm
CONFIG_AGP_HP_ZX1=3Dm
CONFIG_VGA_ARB=3Dy
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_DRM is not set
# CONFIG_DRM_DP_CEC is not set

#
# ARM devices
#
# end of ARM devices

#
# ACP (Audio CoProcessor) Configuration
#
# end of ACP (Audio CoProcessor) Configuration

#
# Frame buffer Devices
#
# CONFIG_FB is not set
# end of Frame buffer Devices

#
# Backlight & LCD device support
#
# CONFIG_LCD_CLASS_DEVICE is not set
# CONFIG_BACKLIGHT_CLASS_DEVICE is not set
# end of Backlight & LCD device support

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK_SIZEd
CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT=3Dy
CONFIG_DUMMY_CONSOLE=3Dy
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS%
# end of Console display driver support
# end of Graphics support

# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=3Dy
CONFIG_HID_BATTERY_STRENGTH=3Dy
CONFIG_HIDRAW=3Dy
CONFIG_UHID=3Dm
CONFIG_HID_GENERIC=3Dy

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACCUTOUCH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_BETOP_FF is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_COUGAR is not set
# CONFIG_HID_MACALLY is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_VIEWSONIC is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_ITE is not set
# CONFIG_HID_JABRA is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MALTRON is not set
# CONFIG_HID_MAYFLASH is not set
# CONFIG_HID_REDRAGON is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PENMOUNT is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_RETRODE is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEAM is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_UDRAW_PS3 is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set
# end of Special HID drivers

#
# USB HID support
#
CONFIG_USB_HID=3Dm
CONFIG_HID_PID=3Dy
CONFIG_USB_HIDDEV=3Dy
# end of USB HID support
# end of HID support

CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
CONFIG_USB_SUPPORT=3Dy
CONFIG_USB_COMMON=3Dm
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB=3Dm
CONFIG_USB_PCI=3Dy
CONFIG_USB_ANNOUNCE_NEW_DEVICES=3Dy

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=3Dy
CONFIG_USB_DYNAMIC_MINORS=3Dy
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_AUTOSUSPEND_DELAY=3D2
CONFIG_USB_MON=3Dm
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=3Dm
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
CONFIG_USB_EHCI_TT_NEWSCHED=3Dy
CONFIG_USB_EHCI_PCI=3Dm
# CONFIG_USB_EHCI_FSL is not set
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=3Dm
CONFIG_USB_OHCI_HCD_PCI=3Dm
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=3Dm
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=3Dm
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=3Dm
CONFIG_REALTEK_AUTOPM=3Dy
CONFIG_USB_STORAGE_DATAFAB=3Dm
CONFIG_USB_STORAGE_FREECOM=3Dm
CONFIG_USB_STORAGE_ISD200=3Dm
CONFIG_USB_STORAGE_USBAT=3Dm
CONFIG_USB_STORAGE_SDDR09=3Dm
CONFIG_USB_STORAGE_SDDR55=3Dm
CONFIG_USB_STORAGE_JUMPSHOT=3Dm
CONFIG_USB_STORAGE_ALAUDA=3Dm
CONFIG_USB_STORAGE_ONETOUCH=3Dm
CONFIG_USB_STORAGE_KARMA=3Dm
CONFIG_USB_STORAGE_CYPRESS_ATACB=3Dm
CONFIG_USB_STORAGE_ENE_UB6250=3Dm
CONFIG_USB_UAS=3Dm

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# end of USB Physical Layer drivers

# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_ROLE_SWITCH is not set
# CONFIG_USB_ULPI_BUS is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_RTC_LIB=3Dy
CONFIG_RTC_CLASS=3Dy
CONFIG_RTC_HCTOSYS=3Dy
CONFIG_RTC_HCTOSYS_DEVICE=3D"rtc0"
CONFIG_RTC_SYSTOHC=3Dy
CONFIG_RTC_SYSTOHC_DEVICE=3D"rtc0"
# CONFIG_RTC_DEBUG is not set
CONFIG_RTC_NVMEM=3Dy

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=3Dy
CONFIG_RTC_INTF_PROC=3Dy
CONFIG_RTC_INTF_DEV=3Dy
CONFIG_RTC_INTF_DEV_UIE_EMUL=3Dy
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#

#
# SPI RTC drivers
#

#
# SPI and I2C RTC drivers
#

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_EFI=3Dy
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_FTRTC010 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
# end of DMABUF options

# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# end of Microsoft Hyper-V guest support

# CONFIG_STAGING is not set
# CONFIG_HWSPINLOCK is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set
# end of Remoteproc drivers

#
# Rpmsg drivers
#
# CONFIG_RPMSG_VIRTIO is not set
# end of Rpmsg drivers

# CONFIG_SOUNDWIRE is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#
# end of Amlogic SoC drivers

#
# Aspeed SoC drivers
#
# end of Aspeed SoC drivers

#
# Broadcom SoC drivers
#
# end of Broadcom SoC drivers

#
# NXP/Freescale QorIQ SoC drivers
#
# end of NXP/Freescale QorIQ SoC drivers

#
# i.MX SoC drivers
#
# end of i.MX SoC drivers

#
# IXP4xx SoC drivers
#
# CONFIG_IXP4XX_QMGR is not set
# CONFIG_IXP4XX_NPE is not set
# end of IXP4xx SoC drivers

#
# Qualcomm SoC drivers
#
# end of Qualcomm SoC drivers

# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
# CONFIG_XILINX_VCU is not set
# end of Xilinx SoC drivers
# end of SOC (System On Chip) specific Drivers

# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=3D1
# end of IRQ chip support

# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
# CONFIG_GENERIC_PHY is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
# end of PHY Subsystem

# CONFIG_POWERCAP is not set
# CONFIG_MCB is not set
# CONFIG_RAS is not set

#
# Android
#
# CONFIG_ANDROID is not set
# end of Android

# CONFIG_DAX is not set
CONFIG_NVMEM=3Dy
CONFIG_NVMEM_SYSFS=3Dy

#
# HW tracing support
#
# CONFIG_STM is not set
# CONFIG_INTEL_TH is not set
# end of HW tracing support

# CONFIG_FPGA is not set
# CONFIG_SIOX is not set
# CONFIG_SLIMBUS is not set
# CONFIG_INTERCONNECT is not set
# CONFIG_COUNTER is not set
# end of Device Drivers

#
# File systems
#
# CONFIG_VALIDATE_FS_PARSER is not set
CONFIG_FS_IOMAP=3Dy
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=3Dy
CONFIG_EXT4_USE_FOR_EXT2=3Dy
CONFIG_EXT4_FS_POSIX_ACL=3Dy
CONFIG_EXT4_FS_SECURITY=3Dy
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=3Dy
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=3Dy
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
# CONFIG_F2FS_FS is not set
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=3Dy
CONFIG_EXPORTFS=3Dy
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=3Dy
CONFIG_MANDATORY_FILE_LOCKING=3Dy
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=3Dy
CONFIG_DNOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_AUTOFS_FS=3Dm
# CONFIG_FUSE_FS is not set
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set
# end of Caches

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=3Dy
CONFIG_JOLIET=3Dy
CONFIG_ZISOFS=3Dy
CONFIG_UDF_FS=3Dm
# end of CD-ROM/DVD Filesystems

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=3Dy
CONFIG_MSDOS_FS=3Dy
CONFIG_VFAT_FS=3Dy
CONFIG_FAT_DEFAULT_CODEPAGEC7
CONFIG_FAT_DEFAULT_IOCHARSET=3D"utf8"
CONFIG_FAT_DEFAULT_UTF8=3Dy
CONFIG_NTFS_FS=3Dm
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set
# end of DOS/FAT/NT Filesystems

#
# Pseudo filesystems
#
CONFIG_PROC_FS=3Dy
CONFIG_PROC_KCORE=3Dy
CONFIG_PROC_SYSCTL=3Dy
CONFIG_PROC_PAGE_MONITOR=3Dy
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=3Dy
CONFIG_SYSFS=3Dy
CONFIG_TMPFS=3Dy
CONFIG_TMPFS_POSIX_ACL=3Dy
CONFIG_TMPFS_XATTR=3Dy
CONFIG_HUGETLBFS=3Dy
CONFIG_HUGETLB_PAGE=3Dy
CONFIG_MEMFD_CREATE=3Dy
# CONFIG_CONFIGFS_FS is not set
CONFIG_EFIVAR_FS=3Dy
# end of Pseudo filesystems

# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=3Dy
CONFIG_NLS_DEFAULT=3D"utf8"
CONFIG_NLS_CODEPAGE_437=3Dy
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=3Dy
CONFIG_NLS_ISO8859_1=3Dy
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=3Dy
# CONFIG_UNICODE is not set
# end of File systems

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=3Dy
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_DEFAULT_SECURITY_DAC=3Dy
CONFIG_LSM=3D"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmo=
r"

#
# Kernel hardening options
#

#
# Memory initialization
#
CONFIG_INIT_STACK_NONE=3Dy
# end of Memory initialization
# end of Kernel hardening options
# end of Security options

CONFIG_CRYPTO=3Dy

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=3Dy
CONFIG_CRYPTO_ALGAPI2=3Dy
CONFIG_CRYPTO_HASH=3Dy
CONFIG_CRYPTO_HASH2=3Dy
# CONFIG_CRYPTO_MANAGER is not set
# CONFIG_CRYPTO_USER is not set
# CONFIG_CRYPTO_MANAGER_EXTRA_TESTS is not set
# CONFIG_CRYPTO_GF128MUL is not set
# CONFIG_CRYPTO_NULL is not set
# CONFIG_CRYPTO_PCRYPT is not set
# CONFIG_CRYPTO_CRYPTD is not set
# CONFIG_CRYPTO_AUTHENC is not set
# CONFIG_CRYPTO_TEST is not set

#
# Public-key cryptography
#
# CONFIG_CRYPTO_RSA is not set
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
# CONFIG_CRYPTO_ECRDSA is not set

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
# CONFIG_CRYPTO_AEGIS128 is not set
# CONFIG_CRYPTO_AEGIS128L is not set
# CONFIG_CRYPTO_AEGIS256 is not set
# CONFIG_CRYPTO_MORUS640 is not set
# CONFIG_CRYPTO_MORUS1280 is not set
# CONFIG_CRYPTO_SEQIV is not set
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
# CONFIG_CRYPTO_CBC is not set
# CONFIG_CRYPTO_CFB is not set
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
# CONFIG_CRYPTO_ECB is not set
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_OFB is not set
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_XTS is not set
# CONFIG_CRYPTO_KEYWRAP is not set
# CONFIG_CRYPTO_ADIANTUM is not set

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
# CONFIG_CRYPTO_HMAC is not set
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=3Dy
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRCT10DIF is not set
# CONFIG_CRYPTO_GHASH is not set
# CONFIG_CRYPTO_POLY1305 is not set
# CONFIG_CRYPTO_MD4 is not set
# CONFIG_CRYPTO_MD5 is not set
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
# CONFIG_CRYPTO_SHA1 is not set
# CONFIG_CRYPTO_SHA256 is not set
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_SM3 is not set
# CONFIG_CRYPTO_STREEBOG is not set
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=3Dy
# CONFIG_CRYPTO_AES_TI is not set
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_DES is not set
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_SM4 is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
# CONFIG_CRYPTO_LZO is not set
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set
# CONFIG_CRYPTO_ZSTD is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
# CONFIG_CRYPTO_DRBG_MENU is not set
# CONFIG_CRYPTO_JITTERENTROPY is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
# CONFIG_CRYPTO_HW is not set

#
# Certificates for signature checking
#
# end of Certificates for signature checking

#
# Library routines
#
# CONFIG_PACKING is not set
CONFIG_BITREVERSE=3Dy
CONFIG_GENERIC_NET_UTILS=3Dy
# CONFIG_CORDIC is not set
CONFIG_GENERIC_PCI_IOMAP=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=3Dy
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=3Dy
# CONFIG_CRC_T10DIF is not set
CONFIG_CRC_ITU_T=3Dm
CONFIG_CRC32=3Dy
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=3Dy
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC64 is not set
# CONFIG_CRC4 is not set
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
# CONFIG_CRC8 is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=3Dy
# CONFIG_XZ_DEC is not set
CONFIG_GENERIC_ALLOCATOR=3Dy
CONFIG_HAS_IOMEM=3Dy
CONFIG_HAS_IOPORT_MAP=3Dy
CONFIG_HAS_DMA=3Dy
CONFIG_NEED_SG_DMA_LENGTH=3Dy
CONFIG_NEED_DMA_MAP_STATE=3Dy
CONFIG_ARCH_DMA_ADDR_T_64BIT=3Dy
# CONFIG_DMA_API_DEBUG is not set
CONFIG_CPU_RMAP=3Dy
CONFIG_DQL=3Dy
CONFIG_GLOB=3Dy
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=3Dy
# CONFIG_DDR is not set
# CONFIG_IRQ_POLL is not set
CONFIG_UCS2_STRING=3Dy
CONFIG_SG_POOL=3Dy
CONFIG_SBITMAP=3Dy
# CONFIG_STRING_SELFTEST is not set
# end of Library routines

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=3Dy
# CONFIG_PRINTK_CALLER is not set
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=3D7
CONFIG_CONSOLE_LOGLEVEL_QUIET=3D4
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=3D4
# CONFIG_BOOT_PRINTK_DELAY is not set
# end of printk and dmesg options

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN 48
CONFIG_STRIP_ASM_SYMS=3Dy
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
CONFIG_OPTIMIZE_INLINING=3Dy
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=3Dy
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# end of Compile-time checks and compiler options

CONFIG_MAGIC_SYSRQ=3Dy
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=3D0x1
CONFIG_MAGIC_SYSRQ_SERIAL=3Dy
CONFIG_DEBUG_KERNEL=3Dy
CONFIG_DEBUG_MISC=3Dy

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_OWNER is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_MEMORY_INIT=3Dy
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_KASAN_STACK=3D1
# end of Memory Debugging

CONFIG_CC_HAS_SANCOV_TRACE_PC=3Dy
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=3Dy
CONFIG_SOFTLOCKUP_DETECTOR=3Dy
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=3D0
CONFIG_DETECT_HUNG_TASK=3Dy
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=3D0
CONFIG_WQ_WATCHDOG=3Dy
# end of Debug Lockups and Hangs

# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=3D0
CONFIG_PANIC_TIMEOUT=3D0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_ATOMIC_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
# CONFIG_WW_MUTEX_SELFTEST is not set
# end of Lock Debugging (spinlocks, mutexes, etc...)

# CONFIG_STACKTRACE is not set
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PLIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_RCU_PERF_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT!
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# end of RCU Debugging

# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_HAVE_FUNCTION_TRACER=3Dy
CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
# CONFIG_RUNTIME_TESTING_MENU is not set
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_UBSAN=3Dy
# CONFIG_UBSAN_NO_ALIGNMENT is not set
CONFIG_UBSAN_ALIGNMENT=3Dy
# CONFIG_TEST_UBSAN is not set
CONFIG_IA64_GRANULE_16MB=3Dy
# CONFIG_IA64_PRINT_HAZARDS is not set
# CONFIG_DISABLE_VHPT is not set
# CONFIG_IA64_DEBUG_CMPXCHG is not set
# CONFIG_IA64_DEBUG_IRQ is not set
# end of Kernel hacking


--=20
Meelis Roos <mroos@linux.ee>

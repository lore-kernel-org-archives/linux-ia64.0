From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Mon, 11 Jan 2010 21:18:11 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001111318x59c6be5bke5e71791eeb8855c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2010/1/11 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> On Monday 11 January 2010 11:23:30 am Luck, Tony wrote:
>> > =A0 =A0 =A0 =A0printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset "
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"(ioc=3D%llx, lba=3D%llx)\n", (char *)c=
ontext,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
>> >
>> >If hp_zx1_setup returned 0, we should see the "Detected HP ZX1
>> >HWP0003 AGP chipset" message next, but we don't

Sorry guys, my mistake: I had the return AE_OK line; duplicated!

> =C9meric, can you grab the dmesg log instead, please?

OK, please find below the contents of /var/log/dmesg:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.33-rc3 (root@longspeak) (gcc version
4.3.4 (Debian 4.3.4-6) ) #2 SMP Fri Jan 8 20:36:36 CET 2010
[    0.000000] EFI v1.10 by HP: SALsystab=3D0x3fb38000 ACPI
2.0=3D0x3fb2e000 SMBIOS=3D0x3fb3a000 HCDP=3D0x3fb2c000
[    0.000000] booting generic kernel on platform hpzx1
[    0.000000] PCDP: v0 at 0x3fb2c000
[    0.000000] ACPI: RSDP 000000003fb2e000 00028 (v02     HP)
[    0.000000] ACPI: XSDT 000000003fb2e02c 00094 (v01     HP   zx6000
00000000   HP 00000000)
[    0.000000] ACPI: FACP 000000003fb36800 000F4 (v03     HP   zx6000
00000000   HP 00000000)
[    0.000000] ACPI Warning: 32/64X length mismatch in Gpe0Block:
32/16 (20091214/tbfadt-526)
[    0.000000] ACPI Warning: 32/64X length mismatch in Gpe1Block:
32/16 (20091214/tbfadt-526)
[    0.000000] ACPI: DSDT 000000003fb2e0e0 05781 (v01     HP   zx6000
00000007 INTL 02012044)
[    0.000000] ACPI: FACS 000000003fb368f8 00040
[    0.000000] ACPI: SPCR 000000003fb36938 00050 (v01     HP   zx6000
00000000   HP 00000000)
[    0.000000] ACPI: DBGP 000000003fb36988 00034 (v01     HP   zx6000
00000000   HP 00000000)
[    0.000000] ACPI: APIC 000000003fb36a48 000B0 (v01     HP   zx6000
00000000   HP 00000000)
[    0.000000] ACPI: SPMI 000000003fb369c0 00050 (v04     HP   zx6000
00000000   HP 00000000)
[    0.000000] ACPI: CPEP 000000003fb36a10 00034 (v01     HP   zx6000
00000000   HP 00000000)
[    0.000000] ACPI: SSDT 000000003fb33870 001D6 (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb33a50 00342 (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb33da0 00A16 (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb347c0 00A16 (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb351e0 00A16 (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb35c00 00A16 (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb36620 000EB (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb36710 000EF (v01     HP   zx6000
00000006 INTL 02012044)
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] 2 CPUs available, 2 CPUs total
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] Initial ramdisk at: 0xe0000040fe247000 (13944150 bytes)
[    0.000000] SAL 3.1: HP version 2.31
[    0.000000] SAL Platform features: None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] GSI 36 (level, low) -> CPU 0 (0x0000) vector 49
[    0.000000] MCA related initialization done
[    0.000000] Virtual mem_map starts at 0xa0007fffc7200000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000400 -> 0x00040000
[    0.000000]   Normal   0x00040000 -> 0x01040000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0: 0x00000400 -> 0x0000fd79
[    0.000000]     0: 0x0000fec0 -> 0x0000fecb
[    0.000000]     0: 0x00040000 -> 0x00060000
[    0.000000]     0: 0x01010000 -> 0x0103ff5a
[    0.000000]     0: 0x0103ff69 -> 0x0103ff84
[    0.000000]     0: 0x0103ffa0 -> 0x0103fff0
[    0.000000] On node 0 totalpages: 391497
[    0.000000] free_area_init_node: node 0, pgdat e000000001300000,
node_mem_map a0007fffc720e000
[    0.000000]   DMA zone: 893 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 62983 pages, LIFO batch:7
[    0.000000]   Normal zone: 57344 pages used for memmap
[    0.000000]   Normal zone: 270277 pages, LIFO batch:7
[    0.000000] pcpu-alloc: s30104 r8192 d27240 u65536 alloc=3D4*16384
[    0.000000] pcpu-alloc: [0] 0 [0] 1
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 333260
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line:
BOOT_IMAGE=3Dscsi1:/EFI/debian/vmlinuz root=3D/dev/sdb2  drm.debug=3D1 ro
[    0.000000] PID hash table entries: 4096 (order: 1, 32768 bytes)
[    0.000000] Memory: 6213952k/6238512k available (7026k code, 50000k
reserved, 3489k data, 848k init)
[    0.000000] SLUB: Genslabs=16, HWalign=128, Order=3D0-3,
MinObjects=3D0, CPUs=3D2, Nodes%6
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:1024
[    0.000000] CPU 0: base freq 0.000MHz, ITC ratio=15/2, ITC
freq=1500.000MHz+/-750ppm
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.004000] Calibrating delay loop... 2244.60 BogoMIPS (lpjD89216)
[    0.100064] Security Framework initialized
[    0.100102] SELinux:  Disabled at boot.
[    0.100430] Dentry cache hash table entries: 1048576 (order: 9,
8388608 bytes)
[    0.107583] Inode-cache hash table entries: 524288 (order: 8, 4194304 by=
tes)
[    0.111506] Mount-cache hash table entries: 1024
[    0.111829] Initializing cgroup subsys ns
[    0.111866] Initializing cgroup subsys cpuacct
[    0.111902] Initializing cgroup subsys devices
[    0.111936] Initializing cgroup subsys freezer
[    0.111969] Initializing cgroup subsys net_cls
[    0.112038] ACPI: Core revision 20091214
[    0.114975] Boot processor id 0x0/0x0
[    0.000000] Fixed BSP b0 value from CPU 1
[    0.000000] CPU 1: synchronized ITC with CPU 0 (last diff -31
cycles, maxerr 669 cycles)
[    0.000000] CPU 1: base freq 0.000MHz, ITC ratio=15/2, ITC
freq=1500.000MHz+/-750ppm
[    0.117273] Brought up 2 CPUs
[    0.117307] Total of 2 processors activated (4489.21 BogoMIPS).
[    0.118318] DMI 2.3 present.
[    0.118494] regulator: core version 0.5
[    0.118581] NET: Registered protocol family 16
[    0.118734] ACPI: bus type pci registered
[    0.119357] bio: create slab <bio-0> at 0
[    0.120238] ACPI: EC: Look up EC in DSDT
[    0.129188] ACPI: Interpreter enabled
[    0.129220] ACPI: (supports S0 S5)
[    0.129292] ACPI: Using IOSAPIC for interrupt routing
[    0.268370] ACPI: No dock devices found.
[    0.281593] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.307987] pci_root HWP0002:00: host bridge window [io  0x0000-0x03af]
[    0.308006] pci_root HWP0002:00: host bridge window [io  0x03e0-0x1fff]
[    0.308042] pci_root HWP0002:00: host bridge window [mem
0x80000000-0x8fffffff]
[    0.308089] pci_root HWP0002:00: host bridge window [mem
0x80004000000-0x80103fffffe]
[    0.308730] pci 0000:00:01.0: reg 10: [mem 0x80023000-0x80023fff]
[    0.309898] pci 0000:00:01.0: supports D1 D2
[    0.309901] pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
[    0.309966] pci 0000:00:01.0: PME# disabled
[    0.310612] pci 0000:00:01.1: reg 10: [mem 0x80022000-0x80022fff]
[    0.311770] pci 0000:00:01.1: supports D1 D2
[    0.311773] pci 0000:00:01.1: PME# supported from D0 D1 D2 D3hot
[    0.311837] pci 0000:00:01.1: PME# disabled
[    0.312493] pci 0000:00:01.2: reg 10: [mem 0x80021000-0x800210ff]
[    0.313652] pci 0000:00:01.2: supports D1 D2
[    0.313655] pci 0000:00:01.2: PME# supported from D0 D1 D2 D3hot
[    0.313719] pci 0000:00:01.2: PME# disabled
[    0.314515] pci 0000:00:02.0: reg 10: [io  0x0d58-0x0d5f]
[    0.314640] pci 0000:00:02.0: reg 14: [io  0x0d64-0x0d67]
[    0.314766] pci 0000:00:02.0: reg 18: [io  0x0d50-0x0d57]
[    0.314891] pci 0000:00:02.0: reg 1c: [io  0x0d60-0x0d63]
[    0.315017] pci 0000:00:02.0: reg 20: [io  0x0d40-0x0d4f]
[    0.315718] pci 0000:00:02.0: supports D1 D2
[    0.316372] pci 0000:00:03.0: reg 10: [mem 0x80020000-0x80020fff]
[    0.316497] pci 0000:00:03.0: reg 14: [io  0x0d00-0x0d3f]
[    0.316626] pci 0000:00:03.0: reg 18: [mem 0x80000000-0x8001ffff]
[    0.317541] pci 0000:00:03.0: supports D1 D2
[    0.317544] pci 0000:00:03.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.317608] pci 0000:00:03.0: PME# disabled
[    0.318595] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI0._PRT]
[    0.335756] ACPI: PCI Root Bridge [PCI1] (0000:20)
[    0.366412] pci_root HWP0002:01: host bridge window [mem
0xff5e0000-0xff5e0007]
[    0.366459] pci_root HWP0002:01: host bridge window [mem
0xff5e2000-0xff5e2007]
[    0.366507] pci_root HWP0002:01: host bridge window [io  0x2000-0x2fff]
[    0.366544] pci_root HWP0002:01: host bridge window [mem
0x90000000-0x97ffffff]
[    0.366591] pci_root HWP0002:01: host bridge window [mem
0x90004000000-0x90103fffffe]
[    0.367456] pci 0000:20:01.0: reg 10: [io  0x2100-0x21ff]
[    0.367749] pci 0000:20:01.0: reg 14: [mem 0x90840000-0x9084ffff 64bit]
[    0.368041] pci 0000:20:01.0: reg 1c: [mem 0x90830000-0x9083ffff 64bit]
[    0.368334] pci 0000:20:01.0: reg 30: [mem 0x90400000-0x907fffff pref]
[    0.368986] pci 0000:20:01.0: supports D1 D2
[    0.369965] pci 0000:20:01.1: reg 10: [io  0x2000-0x20ff]
[    0.370257] pci 0000:20:01.1: reg 14: [mem 0x90820000-0x9082ffff 64bit]
[    0.370550] pci 0000:20:01.1: reg 1c: [mem 0x90810000-0x9081ffff 64bit]
[    0.370843] pci 0000:20:01.1: reg 30: [mem 0x90000000-0x903fffff pref]
[    0.371495] pci 0000:20:01.1: supports D1 D2
[    0.372907] pci 0000:20:02.0: reg 10: [mem 0x90800000-0x9080ffff 64bit]
[    0.374393] pci 0000:20:02.0: PME# supported from D3hot D3cold
[    0.374469] pci 0000:20:02.0: PME# disabled
[    0.375776] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI1._PRT]
[    0.397173] ACPI: PCI Root Bridge [PCI2] (0000:40)
[    0.421300] pci_root HWP0002:02: host bridge window [io  0x3000-0x5fff]
[    0.421337] pci_root HWP0002:02: host bridge window [mem
0x98000000-0xafffffff]
[    0.421384] pci_root HWP0002:02: host bridge window [mem
0xa0004000000-0xa0103fffffe]
[    0.422243] pci 0000:40:01.0: reg 10: [io  0x3000-0x307f]
[    0.423891] pci 0000:40:01.0: supports D2
[    0.424742] pci 0000:40:01.1: reg 10: [io  0x3080-0x308f]
[    0.426389] pci 0000:40:01.1: supports D1
[    0.426393] pci 0000:40:01.1: PME# supported from D1 D3hot
[    0.426482] pci 0000:40:01.1: PME# disabled
[    0.428222] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI2._PRT]
[    0.483306] ACPI: PCI Root Bridge [PCI3] (0000:60)
[    0.507389] pci_root HWP0002:03: host bridge window [io  0x6000-0x7fff]
[    0.507426] pci_root HWP0002:03: host bridge window [mem
0xb0000000-0xc7ffffff]
[    0.507473] pci_root HWP0002:03: host bridge window [mem
0xb0004000000-0xb0103fffffe]
[    0.509080] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI3._PRT]
[    0.531256] ACPI: PCI Root Bridge [PCI4] (0000:80)
[    0.560665] pci_root HWP0003:00: host bridge window [io  0x03b0-0x03df]
[    0.560703] pci_root HWP0003:00: host bridge window [io  0x8000-0xbfff]
[    0.560739] pci_root HWP0003:00: host bridge window [mem
0x000a0000-0x000fffff]
[    0.560786] pci_root HWP0003:00: host bridge window [mem
0xc8000000-0xdfffffff]
[    0.560833] pci_root HWP0003:00: host bridge window [mem
0xc0004000000-0xc0103fffffe]
[    0.562070] pci 0000:80:00.0: reg 10: [mem 0xd0000000-0xd7ffffff pref]
[    0.562295] pci 0000:80:00.0: reg 14: [io  0x8000-0x80ff]
[    0.562520] pci 0000:80:00.0: reg 18: [mem 0xd8030000-0xd803ffff]
[    0.563407] pci 0000:80:00.0: reg 30: [mem 0xd8000000-0xd801ffff pref]
[    0.563577] pci 0000:80:00.0: Boot video device
[    0.564555] pci 0000:80:00.0: supports D1 D2
[    0.565779] pci 0000:80:00.1: reg 10: [mem 0xc8000000-0xcfffffff pref]
[    0.566005] pci 0000:80:00.1: reg 14: [mem 0xd8020000-0xd802ffff]
[    0.567884] pci 0000:80:00.1: supports D1 D2
[    0.570162] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI4._PRT]
[    0.624610] ACPI: PCI Root Bridge [PCI6] (0000:c0)
[    0.648710] pci_root HWP0002:04: host bridge window [io  0xc000-0xdfff]
[    0.648747] pci_root HWP0002:04: host bridge window [mem
0xe0000000-0xefffffff]
[    0.648794] pci_root HWP0002:04: host bridge window [mem
0xe0004000000-0xe0103fffffe]
[    0.650891] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI6._PRT]
[    0.658449] vgaarb: device added:
PCI:0000:80:00.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
[    0.658497] vgaarb: loaded
[    0.704871] ioc_init: PAGE_SIZE 16K, iovp_size 16K
[    0.704907] ioc_iova_init() hpa c0000000fed01000 IOV base
0x40000000 mask 0xffffffffc0000000 (1024MB)
[    0.705183] ioc_iova_init() IOV page size 16K pdir e000004080e80000
size 80000
[    0.707369] IOC: reserving 512Mb of IOVA space at 0x60000000 for agpgart
[    0.707405] put cookie at 0xe000004080ec0000: 0xbadbadc0ffee
[    0.707440] ioc_resource_init() res_size 0x1000
[    0.707476] ioc_resource_init() res_map 1000 e000004080e2c000
[    0.707512] IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[    0.757826] Switching to clocksource itc
[    0.759043] pnp: PnP ACPI init
[    0.759099] ACPI: bus type pnp registered
[    0.839792] GSI 34 (edge, high) -> CPU 1 (0x0100) vector 50
[    0.840842] GSI 35 (edge, high) -> CPU 0 (0x0000) vector 51
[    0.941058] pnp: PnP ACPI: found 10 devices
[    0.941090] ACPI: ACPI bus type pnp unregistered
[    0.941321] NET: Registered protocol family 2
[    0.941505] IP route cache hash table entries: 262144 (order: 7,
2097152 bytes)
[    0.942609] TCP established hash table entries: 524288 (order: 9,
8388608 bytes)
[    0.949804] TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
[    0.951430] TCP: Hash tables configured (established 524288 bind 65536)
[    0.951468] TCP reno registered
[    0.951510] UDP hash table entries: 4096 (order: 3, 131072 bytes)
[    0.951720] UDP-Lite hash table entries: 4096 (order: 3, 131072 bytes)
[    0.952086] NET: Registered protocol family 1
[    0.952534] pci 0000:00:03.0: Firmware left e100 interrupts
enabled; disabling
[    0.952929] PCI: CLS 128 bytes, default 128
[    0.953019] Unpacking initramfs...
[    1.430372] Freeing initrd memory: 13600kB freed
[    1.430688] perfmon: version 2.0 IRQ 238
[    1.430729] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4
counters (47 bits)
[    1.431445] perfmon: added sampling format default_format
[    1.431480] perfmon_default_smpl: default_format v2.0 registered
[    1.431657] audit: initializing netlink socket (disabled)
[    1.431709] type 00 audit(1263243355.430:1): initialized
[    1.432254] HugeTLB registered 256 MB page size, pre-allocated 0 pages
[    1.434043] VFS: Disk quotas dquot_6.5.2
[    1.434145] Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
[    1.434325] msgmni has been set to 12163
[    1.434681] alg: No test for stdrng (krng)
[    1.434779] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
[    1.434827] io scheduler noop registered
[    1.434859] io scheduler deadline registered
[    1.434962] io scheduler cfq registered (default)
[    1.435220] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.435267] ACPI: Power Button [PWRF]
[    1.435365] input: Sleep Button as
/devices/LNXSYSTM:00/LNXSLPBN:00/input/input1
[    1.435411] ACPI: Sleep Button [SLPF]
[    1.525453] thermal LNXTHERM:01: registered as thermal_zone0
[    1.525493] ACPI: Thermal Zone [THM0] (27 C)
[    1.526776] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.527052] 00:04: ttyS0 at MMIO 0xff5e0000 (irq =3D 50) is a 16550A
[    1.527184] 00:05: ttyS1 at MMIO 0xff5e2000 (irq =3D 51) is a 16550A
[    1.527418] mice: PS/2 mouse device common for all mice
[    1.527512] rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0
[    1.527926] TCP cubic registered
[    1.527959] NET: Registered protocol family 17
[    1.528062] registered taskstats version 1
[    1.533062] rtc-efi rtc-efi: setting system clock to 2010-01-11
20:55:55 UTC (1263243355)
[    1.533136] Freeing unused kernel memory: 848kB freed
[    1.752397] usbcore: registered new interface driver usbfs
[    1.752523] usbcore: registered new interface driver hub
[    1.752836] usbcore: registered new device driver usb
[    1.755324] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.757308] GSI 18 (level, low) -> CPU 1 (0x0100) vector 52
[    1.757345] ehci_hcd 0000:00:01.2: PCI INT C -> GSI 18 (level, low) -> I=
RQ 52
[    1.757420] ehci_hcd 0000:00:01.2: EHCI Host Controller
[    1.757478] ehci_hcd 0000:00:01.2: new USB bus registered, assigned
bus number 1
[    1.759149] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    1.759187] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.786466] ehci_hcd 0000:00:01.2: irq 52, io mem 0x80021000
[    1.787701] SCSI subsystem initialized
[    1.806901] ehci_hcd 0000:00:01.2: USB 2.0 started, EHCI 0.95
[    1.806976] usb usb1: New USB device found, idVendor=1D6b, idProduct=0002
[    1.807012] usb usb1: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    1.807058] usb usb1: Product: EHCI Host Controller
[    1.807092] usb usb1: Manufacturer: Linux 2.6.33-rc3 ehci_hcd
[    1.807126] usb usb1: SerialNumber: 0000:00:01.2
[    1.807262] hub 1-0:1.0: USB hub found
[    1.807298] hub 1-0:1.0: 5 ports detected
[    1.807626] GSI 20 (level, low) -> CPU 0 (0x0000) vector 53
[    1.807663] e100 0000:00:03.0: PCI INT A -> GSI 20 (level, low) -> IRQ 53
[    1.807722] Uniform Multi-Platform E-IDE driver
[    1.821772] tg3.c:v3.105 (December 2, 2009)
[    1.821975] GSI 29 (level, low) -> CPU 1 (0x0100) vector 54
[    1.822011] tg3 0000:20:02.0: PCI INT A -> GSI 29 (level, low) -> IRQ 54
[    1.823232] Fusion MPT base driver 3.04.13
[    1.823264] Copyright (c) 1999-2008 LSI Corporation
[    1.831985] Fusion MPT SPI Host driver 3.04.13
[    1.840008] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.904896] e100 0000:00:03.0: PME# disabled
[    1.905258] e100: eth0: e100_probe: addr 0x80020000, irq 53, MAC
addr 00:30:6e:4a:d3:ab
[    1.905333] cmd64x 0000:00:02.0: IDE controller (0x1095:0x0649 rev 0x02)
[    1.905517] GSI 21 (level, low) -> CPU 0 (0x0000) vector 55
[    1.905553] CMD64x_IDE 0000:00:02.0: PCI INT A -> GSI 21 (level,
low) -> IRQ 55
[    1.905696] cmd64x 0000:00:02.0: IDE port disabled
[    1.905834] cmd64x 0000:00:02.0: 100% native mode on irq 55
[    1.905905]     ide0: BM-DMA at 0x0d40-0x0d47
[    1.905975] Probing IDE interface ide0...
[    2.309559] hda: DV-28E-B, ATAPI CD/DVD-ROM drive
[    2.981312] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    2.986886] hda: UDMA/33 mode selected
[    2.987175] ide0 at 0xd58-0xd5f,0xd66 on irq 55
[    2.987456] GSI 16 (level, low) -> CPU 1 (0x0100) vector 56
[    2.987492] ohci_hcd 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> I=
RQ 56
[    2.987562] ohci_hcd 0000:00:01.0: OHCI Host Controller
[    2.987606] ohci_hcd 0000:00:01.0: new USB bus registered, assigned
bus number 2
[    2.987670] ohci_hcd 0000:00:01.0: irq 56, io mem 0x80023000
[    3.203986] eth1: Tigon3 [partno(BCM95700A6) rev 0105]
(PCI:66MHz:64-bit) MAC address 00:30:6e:4a:d2:bd
[    3.204037] eth1: attached PHY is 5701 (10/100/1000Base-T Ethernet)
(WireSpeed[1])
[    3.204085] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[0]
[    3.204120] eth1: dma_rwctrl[76ff2d0f] dma_mask[64-bit]
[    3.204938] GSI 27 (level, low) -> CPU 0 (0x0000) vector 57
[    3.204974] mptspi 0000:20:01.0: PCI INT A -> GSI 27 (level, low) -> IRQ=
 57
[    3.205224] mptbase: ioc0: Initiating bringup
[    3.555307] usb usb2: New USB device found, idVendor=1D6b, idProduct=0001
[    3.555344] usb usb2: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    3.555390] usb usb2: Product: OHCI Host Controller
[    3.555423] usb usb2: Manufacturer: Linux 2.6.33-rc3 ohci_hcd
[    3.555457] usb usb2: SerialNumber: 0000:00:01.0
[    3.555652] hub 2-0:1.0: USB hub found
[    3.555691] hub 2-0:1.0: 3 ports detected
[    3.562321] GSI 17 (level, low) -> CPU 1 (0x0100) vector 58
[    3.562358] ohci_hcd 0000:00:01.1: PCI INT B -> GSI 17 (level, low) -> I=
RQ 58
[    3.562428] ohci_hcd 0000:00:01.1: OHCI Host Controller
[    3.562477] ohci_hcd 0000:00:01.1: new USB bus registered, assigned
bus number 3
[    3.562552] ohci_hcd 0000:00:01.1: irq 58, io mem 0x80022000
[    3.587876] libata version 3.00 loaded.
[    3.813250] ioc0: LSI53C1030 B2: Capabilities=3D{Initiator,Target}
[    4.128151] usb usb3: New USB device found, idVendor=1D6b, idProduct=0001
[    4.128188] usb usb3: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    4.128234] usb usb3: Product: OHCI Host Controller
[    4.128267] usb usb3: Manufacturer: Linux 2.6.33-rc3 ohci_hcd
[    4.128301] usb usb3: SerialNumber: 0000:00:01.1
[    4.128496] hub 3-0:1.0: USB hub found
[    4.128533] hub 3-0:1.0: 2 ports detected
[    4.136839] ide-cd driver 5.00
[    4.142826] ide-cd: hda: ATAPI 24X DVD-ROM drive, 256kB Cache
[    4.142926] Uniform CD-ROM driver Revision: 3.20
[    4.297256] usb 2-1: new low speed USB device using ohci_hcd and address=
 2
[    4.473279] usb 2-1: New USB device found, idVendor=045e, idProduct=0040
[    4.473316] usb 2-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[    4.473353] usb 2-1: Product: Microsoft Wheel Mouse Optical=AE
[    4.473387] usb 2-1: Manufacturer: Microsoft
[    4.488769] usbcore: registered new interface driver hiddev
[    4.495905] scsi0 : ioc0: LSI53C1030 B2, FwRev=01032300h, Ports=3D1,
MaxQ%5, IRQW
[    4.497398] input: Microsoft Microsoft Wheel Mouse Optical=AE as
/devices/pci0000:00/0000:00:01.0/usb2/2-1/2-1:1.0/input/input2
[    4.497500] generic-usb 0003:045E:0040.0001: input,hidraw0: USB HID
v1.00 Mouse [Microsoft Microsoft Wheel Mouse Optical=AE] on
usb-0000:00:01.0-1/input0
[    4.497586] usbcore: registered new interface driver usbhid
[    4.497620] usbhid: USB HID core driver
[    4.866083] usb 3-1: new low speed USB device using ohci_hcd and address=
 2
[    5.035108] usb 3-1: New USB device found, idVendor=03f0, idProduct=0024
[    5.035145] usb 3-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[    5.035181] usb 3-1: Product: HP Basic USB Keyboard
[    5.035214] usb 3-1: Manufacturer: CHICONY
[    5.047299] input: CHICONY HP Basic USB Keyboard as
/devices/pci0000:00/0000:00:01.1/usb3/3-1/3-1:1.0/input/input3
[    5.047384] generic-usb 0003:03F0:0024.0002: input,hidraw1: USB HID
v1.10 Keyboard [CHICONY HP Basic USB Keyboard] on
usb-0000:00:01.1-1/input0
[    5.131526] GSI 28 (level, low) -> CPU 0 (0x0000) vector 59
[    5.131562] mptspi 0000:20:01.1: PCI INT B -> GSI 28 (level, low) -> IRQ=
 59
[    5.131830] mptbase: ioc1: Initiating bringup
[    5.610086] ioc1: LSI53C1030 B2: Capabilities=3D{Initiator,Target}
[    6.292603] scsi1 : ioc1: LSI53C1030 B2, FwRev=01032300h, Ports=3D1,
MaxQ%5, IRQY
[    6.293267] scsi 0:0:0:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    6.293325] scsi target0:0:0: Beginning Domain Validation
[    6.952930] scsi target0:0:0: Ending Domain Validation
[    6.953034] scsi target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[    6.955828] scsi 0:0:1:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    6.955879] scsi target0:0:1: Beginning Domain Validation
[    6.970884] scsi target0:0:1: Ending Domain Validation
[    6.970985] scsi target0:0:1: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[    7.436537] scsi 1:0:2:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    7.436589] scsi target1:0:2: Beginning Domain Validation
[    7.451587] scsi target1:0:2: Ending Domain Validation
[    7.452295] scsi target1:0:2: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[   10.232934] sd 0:0:0:0: [sda] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[   10.233101] sd 0:0:1:0: [sdb] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[   10.234256] sd 0:0:0:0: [sda] Write Protect is off
[   10.234290] sd 0:0:0:0: [sda] Mode Sense: d3 00 10 08
[   10.234413] sd 0:0:1:0: [sdb] Write Protect is off
[   10.234447] sd 0:0:1:0: [sdb] Mode Sense: d3 00 10 08
[   10.235862] sd 0:0:0:0: [sda] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[   10.236018] sd 0:0:1:0: [sdb] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[   10.239322]  sda:
[   10.239450]  sdb: sda1 sda2 sda3
[   10.263652]  sdb1 sdb2 sdb3
[   10.264570] sd 0:0:0:0: [sda] Attached SCSI disk
[   10.268270] sd 0:0:1:0: [sdb] Attached SCSI disk
[   10.455713] sd 1:0:2:0: [sdc] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[   10.457160] sd 1:0:2:0: [sdc] Write Protect is off
[   10.457194] sd 1:0:2:0: [sdc] Mode Sense: d3 00 10 08
[   10.458770] sd 1:0:2:0: [sdc] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[   10.462219]  sdc: sdc1 sdc2 sdc3
[   10.490504] sd 1:0:2:0: [sdc] Attached SCSI disk
[   10.635614] EXT4-fs (sdb2): mounted filesystem with ordered data mode
[   11.943029] udev: starting version 149
[   12.366136] gameport: FM801 is pci0000:40:01.1/gameport0, io
0x3080, speed 875kHz
[   13.015603] Linux video capture interface: v2.00
[   13.222727] GSI 38 (level, low) -> CPU 1 (0x0100) vector 60
[   13.222767] FM801 0000:40:01.0: PCI INT A -> GSI 38 (level, low) -> IRQ =
60
[   13.781229] Adding 2000768k swap on /dev/sdb3.  Priority:-1
extents:1 across:2000768k
[   13.986234] Linux agpgart interface v0.103
[   13.992347] agp_hp_init
[   14.091509] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   14.091546] GART at 0xe000004080ec0000
[   14.091577] read cookie at 0xe000004080ec0000: 0xbadbadc0ffee
[   14.091618] hp_zx1_create_gatt_table
[   14.092261]  (null): AGP aperture is 512M @ 0x60000000
[   14.092295] agp_add_bridge: returning 0 (success)
[   14.092328] hp_zx1_setup: agp_add_bridge returned 0
[   14.092361] zx1_gart_probe: hp_zx1_setup returned 0
[   14.092394] agpgart: Detected HP ZX1 HWP0003 AGP chipset
(ioc=FEd01000, lba=FEd28000)
[   15.170624] fuse init (API version 7.13)
[   17.241305] NET: Registered protocol family 10
[   17.242003] lo: Disabled Privacy Extensions
[   17.242896] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   17.687542] tg3: eth1: Link is up at 10 Mbps, half duplex.
[   17.687594] tg3: eth1: Flow control is off for TX and off for RX.
[   17.691303] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   18.173271] lp: driver loaded but no devices found
[   18.179094] ppdev: user-space parallel port driver

Looks as expected this time :-)

I've initially posted the dmesg command output because drm-related
messages don't seem to be logged in /var/log/dmesg. We thus could have
the impression that everything is fine, but the dmesg command output
reveals that the drm_mmap_locked error is still there:

[   26.337042] [drm] Initialized drm 1.1.0 20060810
[   26.654034] [drm] radeon defaulting to userspace modesetting.
[   26.654042] [drm:drm_init],
[   26.654119] [drm:drm_get_dev],
[   26.654674] [drm:drm_get_minor],
[   26.656293] [drm:drm_get_minor], new minor assigned 0
[   26.656468] [drm:drm_addmap_core], offset =3D 0xd8030000, size 0x0001000=
0, type =3D 1
[   26.656478] [drm:radeon_driver_load], AGP card detected
[   26.656483] [drm] Initialized radeon 1.31.0 20080528 for
0000:80:00.0 on minor 0
[   26.657092] [drm:drm_stub_open],
[   26.657097] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
[   26.657102] [drm:radeon_driver_open],
[   26.657107] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.657140] [drm:drm_addmap_core], 65536 16 a000000203600000
[   26.657147] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.657154] [drm:drm_setup],
[   26.657215] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.657230] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.657240] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.657284] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.657291] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.657383] [drm:drm_release], open_count =3D 1
[   26.657387] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_cou=
nt =3D 1
[   26.657398] [drm:drm_lastclose],
[   26.657404] [drm:radeon_do_cleanup_cp],
[   26.657407] [drm:drm_lastclose], driver lastclose completed
[   26.657413] [drm:drm_lastclose], lastclose completed
[   26.963807] [drm:drm_stub_open],
[   26.963811] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
[   26.963816] [drm:radeon_driver_open],
[   26.963820] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.963855] [drm:drm_addmap_core], 65536 16 a000000203700000
[   26.963860] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.963866] [drm:drm_setup],
[   26.963885] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.963892] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.963903] [drm:drm_release], open_count =3D 1
[   26.963906] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_cou=
nt =3D 1
[   26.963915] [drm:drm_lastclose],
[   26.963919] [drm:radeon_do_cleanup_cp],
[   26.963923] [drm:drm_lastclose], driver lastclose completed
[   26.963927] [drm:drm_lastclose], lastclose completed
[   26.963963] [drm:drm_stub_open],
[   26.963966] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
[   26.963970] [drm:radeon_driver_open],
[   26.963974] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.964005] [drm:drm_addmap_core], 65536 16 a000000203800000
[   26.964010] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.964016] [drm:drm_setup],
[   26.964029] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.964036] [drm:drm_ioctl], pid=1576, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.964044] [drm:drm_release], open_count =3D 1
[   26.964048] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_cou=
nt =3D 1
[   26.964056] [drm:drm_lastclose],
[   26.964060] [drm:radeon_do_cleanup_cp],
[   26.964063] [drm:drm_lastclose], driver lastclose completed
[   26.964067] [drm:drm_lastclose], lastclose completed
[   26.964095] [drm:drm_stub_open],
[   26.964098] [drm:drm_open_helper], pid =3D 1576, minor =3D 0
[   26.964102] [drm:radeon_driver_open],
[   26.964106] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.964136] [drm:drm_addmap_core], 65536 16 a000000203900000
[   26.964141] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.964147] [drm:drm_setup],
[   26.964167] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.964175] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.964181] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.964199] [drm:drm_ioctl], pid=1576, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.964217] [drm:drm_ioctl], pid=1576, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   26.964223] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.964241] [drm:drm_mmap_locked], start =3D 0x200000000d500000, end
=3D 0x200000000d510000, page offset =3D 0x3dc0
[   26.964247] [drm:drm_mmap_locked] *ERROR* Could not find map
[   26.964271] [drm:drm_ioctl], pid=1576, cmd=3D0x4028641b, nr=3D0x1b, dev
0xe200, auth=3D1
[   26.964277] [drm:drm_ioctl], ret =3D ffffffea
[   26.964291] [drm:drm_release], open_count =3D 1
[   26.964294] [drm:drm_release], pid =3D 1576, device =3D 0xe200, open_cou=
nt =3D 1
[   26.964302] [drm:drm_lastclose],
[   26.964307] [drm:radeon_do_cleanup_cp],
[   26.964310] [drm:drm_lastclose], driver lastclose completed
[   26.964314] [drm:drm_lastclose], lastclose completed

=C9meric

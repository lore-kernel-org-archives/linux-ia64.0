From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Fri, 08 Jan 2010 20:06:07 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001081206g2c4d113dv70bc1daf54c77682@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> Thanks a lot for testing these patches!

You did the hard part of the work. So thanks a lot to you!

> Can you try the debug patch below, and respond with the entire dmesg
> log and the output of "lspci -vv"?

Sure. Please find below the entire dmesg log with drm.debug=3D1 (BTW, is
this the right way to post such a huge output to the list?):

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
[    0.000000] Initial ramdisk at: 0xe0000040fe247000 (13942829 bytes)
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
[    0.100431] Dentry cache hash table entries: 1048576 (order: 9,
8388608 bytes)
[    0.107592] Inode-cache hash table entries: 524288 (order: 8, 4194304 by=
tes)
[    0.111522] Mount-cache hash table entries: 1024
[    0.111846] Initializing cgroup subsys ns
[    0.111882] Initializing cgroup subsys cpuacct
[    0.111918] Initializing cgroup subsys devices
[    0.111952] Initializing cgroup subsys freezer
[    0.111985] Initializing cgroup subsys net_cls
[    0.112038] ACPI: Core revision 20091214
[    0.114976] Boot processor id 0x0/0x0
[    0.000000] Fixed BSP b0 value from CPU 1
[    0.000000] CPU 1: synchronized ITC with CPU 0 (last diff -31
cycles, maxerr 669 cycles)
[    0.000000] CPU 1: base freq 0.000MHz, ITC ratio=15/2, ITC
freq=1500.000MHz+/-750ppm
[    0.117290] Brought up 2 CPUs
[    0.117323] Total of 2 processors activated (4489.21 BogoMIPS).
[    0.118333] DMI 2.3 present.
[    0.118508] regulator: core version 0.5
[    0.118596] NET: Registered protocol family 16
[    0.118747] ACPI: bus type pci registered
[    0.119369] bio: create slab <bio-0> at 0
[    0.120244] ACPI: EC: Look up EC in DSDT
[    0.129192] ACPI: Interpreter enabled
[    0.129225] ACPI: (supports S0 S5)
[    0.129297] ACPI: Using IOSAPIC for interrupt routing
[    0.268376] ACPI: No dock devices found.
[    0.281600] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.307993] pci_root HWP0002:00: host bridge window [io  0x0000-0x03af]
[    0.308006] pci_root HWP0002:00: host bridge window [io  0x03e0-0x1fff]
[    0.308042] pci_root HWP0002:00: host bridge window [mem
0x80000000-0x8fffffff]
[    0.308089] pci_root HWP0002:00: host bridge window [mem
0x80004000000-0x80103fffffe]
[    0.308730] pci 0000:00:01.0: reg 10: [mem 0x80023000-0x80023fff]
[    0.309898] pci 0000:00:01.0: supports D1 D2
[    0.309902] pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
[    0.309966] pci 0000:00:01.0: PME# disabled
[    0.310612] pci 0000:00:01.1: reg 10: [mem 0x80022000-0x80022fff]
[    0.311771] pci 0000:00:01.1: supports D1 D2
[    0.311774] pci 0000:00:01.1: PME# supported from D0 D1 D2 D3hot
[    0.311838] pci 0000:00:01.1: PME# disabled
[    0.312493] pci 0000:00:01.2: reg 10: [mem 0x80021000-0x800210ff]
[    0.313652] pci 0000:00:01.2: supports D1 D2
[    0.313655] pci 0000:00:01.2: PME# supported from D0 D1 D2 D3hot
[    0.313719] pci 0000:00:01.2: PME# disabled
[    0.314515] pci 0000:00:02.0: reg 10: [io  0x0d58-0x0d5f]
[    0.314641] pci 0000:00:02.0: reg 14: [io  0x0d64-0x0d67]
[    0.314766] pci 0000:00:02.0: reg 18: [io  0x0d50-0x0d57]
[    0.314892] pci 0000:00:02.0: reg 1c: [io  0x0d60-0x0d63]
[    0.315017] pci 0000:00:02.0: reg 20: [io  0x0d40-0x0d4f]
[    0.315718] pci 0000:00:02.0: supports D1 D2
[    0.316372] pci 0000:00:03.0: reg 10: [mem 0x80020000-0x80020fff]
[    0.316497] pci 0000:00:03.0: reg 14: [io  0x0d00-0x0d3f]
[    0.316626] pci 0000:00:03.0: reg 18: [mem 0x80000000-0x8001ffff]
[    0.317541] pci 0000:00:03.0: supports D1 D2
[    0.317544] pci 0000:00:03.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.317609] pci 0000:00:03.0: PME# disabled
[    0.318595] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI0._PRT]
[    0.335764] ACPI: PCI Root Bridge [PCI1] (0000:20)
[    0.366420] pci_root HWP0002:01: host bridge window [mem
0xff5e0000-0xff5e0007]
[    0.366467] pci_root HWP0002:01: host bridge window [mem
0xff5e2000-0xff5e2007]
[    0.366516] pci_root HWP0002:01: host bridge window [io  0x2000-0x2fff]
[    0.366552] pci_root HWP0002:01: host bridge window [mem
0x90000000-0x97ffffff]
[    0.366599] pci_root HWP0002:01: host bridge window [mem
0x90004000000-0x90103fffffe]
[    0.367464] pci 0000:20:01.0: reg 10: [io  0x2100-0x21ff]
[    0.367757] pci 0000:20:01.0: reg 14: [mem 0x90840000-0x9084ffff 64bit]
[    0.368041] pci 0000:20:01.0: reg 1c: [mem 0x90830000-0x9083ffff 64bit]
[    0.368334] pci 0000:20:01.0: reg 30: [mem 0x90400000-0x907fffff pref]
[    0.368986] pci 0000:20:01.0: supports D1 D2
[    0.369965] pci 0000:20:01.1: reg 10: [io  0x2000-0x20ff]
[    0.370258] pci 0000:20:01.1: reg 14: [mem 0x90820000-0x9082ffff 64bit]
[    0.370551] pci 0000:20:01.1: reg 1c: [mem 0x90810000-0x9081ffff 64bit]
[    0.370844] pci 0000:20:01.1: reg 30: [mem 0x90000000-0x903fffff pref]
[    0.371496] pci 0000:20:01.1: supports D1 D2
[    0.372907] pci 0000:20:02.0: reg 10: [mem 0x90800000-0x9080ffff 64bit]
[    0.374390] pci 0000:20:02.0: PME# supported from D3hot D3cold
[    0.374466] pci 0000:20:02.0: PME# disabled
[    0.375777] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI1._PRT]
[    0.397181] ACPI: PCI Root Bridge [PCI2] (0000:40)
[    0.421308] pci_root HWP0002:02: host bridge window [io  0x3000-0x5fff]
[    0.421345] pci_root HWP0002:02: host bridge window [mem
0x98000000-0xafffffff]
[    0.421392] pci_root HWP0002:02: host bridge window [mem
0xa0004000000-0xa0103fffffe]
[    0.422251] pci 0000:40:01.0: reg 10: [io  0x3000-0x307f]
[    0.423899] pci 0000:40:01.0: supports D2
[    0.424743] pci 0000:40:01.1: reg 10: [io  0x3080-0x308f]
[    0.426390] pci 0000:40:01.1: supports D1
[    0.426393] pci 0000:40:01.1: PME# supported from D1 D3hot
[    0.426483] pci 0000:40:01.1: PME# disabled
[    0.428222] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI2._PRT]
[    0.483315] ACPI: PCI Root Bridge [PCI3] (0000:60)
[    0.507399] pci_root HWP0002:03: host bridge window [io  0x6000-0x7fff]
[    0.507436] pci_root HWP0002:03: host bridge window [mem
0xb0000000-0xc7ffffff]
[    0.507482] pci_root HWP0002:03: host bridge window [mem
0xb0004000000-0xb0103fffffe]
[    0.509080] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI3._PRT]
[    0.531267] ACPI: PCI Root Bridge [PCI4] (0000:80)
[    0.560675] pci_root HWP0003:00: host bridge window [io  0x03b0-0x03df]
[    0.560713] pci_root HWP0003:00: host bridge window [io  0x8000-0xbfff]
[    0.560750] pci_root HWP0003:00: host bridge window [mem
0x000a0000-0x000fffff]
[    0.560796] pci_root HWP0003:00: host bridge window [mem
0xc8000000-0xdfffffff]
[    0.560843] pci_root HWP0003:00: host bridge window [mem
0xc0004000000-0xc0103fffffe]
[    0.562081] pci 0000:80:00.0: reg 10: [mem 0xd0000000-0xd7ffffff pref]
[    0.562306] pci 0000:80:00.0: reg 14: [io  0x8000-0x80ff]
[    0.562531] pci 0000:80:00.0: reg 18: [mem 0xd8030000-0xd803ffff]
[    0.563418] pci 0000:80:00.0: reg 30: [mem 0xd8000000-0xd801ffff pref]
[    0.563588] pci 0000:80:00.0: Boot video device
[    0.564556] pci 0000:80:00.0: supports D1 D2
[    0.565780] pci 0000:80:00.1: reg 10: [mem 0xc8000000-0xcfffffff pref]
[    0.566005] pci 0000:80:00.1: reg 14: [mem 0xd8020000-0xd802ffff]
[    0.567885] pci 0000:80:00.1: supports D1 D2
[    0.570162] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI4._PRT]
[    0.624622] ACPI: PCI Root Bridge [PCI6] (0000:c0)
[    0.648723] pci_root HWP0002:04: host bridge window [io  0xc000-0xdfff]
[    0.648760] pci_root HWP0002:04: host bridge window [mem
0xe0000000-0xefffffff]
[    0.648807] pci_root HWP0002:04: host bridge window [mem
0xe0004000000-0xe0103fffffe]
[    0.650904] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI6._PRT]
[    0.658462] vgaarb: device added:
PCI:0000:80:00.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
[    0.658511] vgaarb: loaded
[    0.704884] ioc_init: PAGE_SIZE 16K, iovp_size 16K
[    0.704919] ioc_iova_init() hpa c0000000fed01000 IOV base
0x40000000 mask 0xffffffffc0000000 (1024MB)
[    0.705195] ioc_iova_init() IOV page size 16K pdir e000004080e80000
size 80000
[    0.707381] IOC: reserving 512Mb of IOVA space at 0x60000000 for agpgart
[    0.707417] put cookie at 0xe000004080ec0000: 0xbadbadc0ffee
[    0.707453] ioc_resource_init() res_size 0x1000
[    0.707488] ioc_resource_init() res_map 1000 e000004080e2c000
[    0.707525] IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[    0.757838] Switching to clocksource itc
[    0.759030] pnp: PnP ACPI init
[    0.759085] ACPI: bus type pnp registered
[    0.839788] GSI 34 (edge, high) -> CPU 1 (0x0100) vector 50
[    0.840839] GSI 35 (edge, high) -> CPU 0 (0x0000) vector 51
[    0.941055] pnp: PnP ACPI: found 10 devices
[    0.941087] ACPI: ACPI bus type pnp unregistered
[    0.941319] NET: Registered protocol family 2
[    0.941503] IP route cache hash table entries: 262144 (order: 7,
2097152 bytes)
[    0.942607] TCP established hash table entries: 524288 (order: 9,
8388608 bytes)
[    0.949802] TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
[    0.951429] TCP: Hash tables configured (established 524288 bind 65536)
[    0.951467] TCP reno registered
[    0.951509] UDP hash table entries: 4096 (order: 3, 131072 bytes)
[    0.951717] UDP-Lite hash table entries: 4096 (order: 3, 131072 bytes)
[    0.952083] NET: Registered protocol family 1
[    0.952531] pci 0000:00:03.0: Firmware left e100 interrupts
enabled; disabling
[    0.952926] PCI: CLS 128 bytes, default 128
[    0.953016] Unpacking initramfs...
[    1.430879] Freeing initrd memory: 13600kB freed
[    1.431195] perfmon: version 2.0 IRQ 238
[    1.431235] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4
counters (47 bits)
[    1.431951] perfmon: added sampling format default_format
[    1.431986] perfmon_default_smpl: default_format v2.0 registered
[    1.432161] audit: initializing netlink socket (disabled)
[    1.432214] type 00 audit(1262979966.430:1): initialized
[    1.432758] HugeTLB registered 256 MB page size, pre-allocated 0 pages
[    1.434543] VFS: Disk quotas dquot_6.5.2
[    1.434644] Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
[    1.434823] msgmni has been set to 12163
[    1.435189] alg: No test for stdrng (krng)
[    1.435296] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
[    1.435345] io scheduler noop registered
[    1.435377] io scheduler deadline registered
[    1.435480] io scheduler cfq registered (default)
[    1.435739] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.435786] ACPI: Power Button [PWRF]
[    1.435884] input: Sleep Button as
/devices/LNXSYSTM:00/LNXSLPBN:00/input/input1
[    1.435930] ACPI: Sleep Button [SLPF]
[    1.525958] thermal LNXTHERM:01: registered as thermal_zone0
[    1.525999] ACPI: Thermal Zone [THM0] (27 C)
[    1.527282] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.527558] 00:04: ttyS0 at MMIO 0xff5e0000 (irq =3D 50) is a 16550A
[    1.527690] 00:05: ttyS1 at MMIO 0xff5e2000 (irq =3D 51) is a 16550A
[    1.527924] mice: PS/2 mouse device common for all mice
[    1.528017] rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0
[    1.528430] TCP cubic registered
[    1.528464] NET: Registered protocol family 17
[    1.528566] registered taskstats version 1
[    1.533567] rtc-efi rtc-efi: setting system clock to 2010-01-08
19:46:06 UTC (1262979966)
[    1.533641] Freeing unused kernel memory: 848kB freed
[    1.751965] usbcore: registered new interface driver usbfs
[    1.752054] usbcore: registered new interface driver hub
[    1.752136] usbcore: registered new device driver usb
[    1.754190] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.759422] GSI 18 (level, low) -> CPU 1 (0x0100) vector 52
[    1.759467] ehci_hcd 0000:00:01.2: PCI INT C -> GSI 18 (level, low) -> I=
RQ 52
[    1.759543] ehci_hcd 0000:00:01.2: EHCI Host Controller
[    1.759612] ehci_hcd 0000:00:01.2: new USB bus registered, assigned
bus number 1
[    1.781636] SCSI subsystem initialized
[    1.782372] ehci_hcd 0000:00:01.2: irq 52, io mem 0x80021000
[    1.785208] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    1.785245] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.805005] ehci_hcd 0000:00:01.2: USB 2.0 started, EHCI 0.95
[    1.805081] usb usb1: New USB device found, idVendor=1D6b, idProduct=0002
[    1.805117] usb usb1: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    1.805163] usb usb1: Product: EHCI Host Controller
[    1.805196] usb usb1: Manufacturer: Linux 2.6.33-rc3 ehci_hcd
[    1.805231] usb usb1: SerialNumber: 0000:00:01.2
[    1.805386] hub 1-0:1.0: USB hub found
[    1.805428] hub 1-0:1.0: 5 ports detected
[    1.805646] Uniform Multi-Platform E-IDE driver
[    1.805692] GSI 20 (level, low) -> CPU 0 (0x0000) vector 53
[    1.805729] e100 0000:00:03.0: PCI INT A -> GSI 20 (level, low) -> IRQ 53
[    1.811584] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.824434] tg3.c:v3.105 (December 2, 2009)
[    1.824671] GSI 29 (level, low) -> CPU 1 (0x0100) vector 54
[    1.824707] tg3 0000:20:02.0: PCI INT A -> GSI 29 (level, low) -> IRQ 54
[    1.825939] Fusion MPT base driver 3.04.13
[    1.825971] Copyright (c) 1999-2008 LSI Corporation
[    1.837992] Fusion MPT SPI Host driver 3.04.13
[    1.902968] e100 0000:00:03.0: PME# disabled
[    1.903318] e100: eth0: e100_probe: addr 0x80020000, irq 53, MAC
addr 00:30:6e:4a:d3:ab
[    1.903393] cmd64x 0000:00:02.0: IDE controller (0x1095:0x0649 rev 0x02)
[    1.903568] GSI 21 (level, low) -> CPU 0 (0x0000) vector 55
[    1.903604] CMD64x_IDE 0000:00:02.0: PCI INT A -> GSI 21 (level,
low) -> IRQ 55
[    1.903747] cmd64x 0000:00:02.0: IDE port disabled
[    1.903884] cmd64x 0000:00:02.0: 100% native mode on irq 55
[    1.903957]     ide0: BM-DMA at 0x0d40-0x0d47
[    1.904027] Probing IDE interface ide0...
[    2.305571] hda: DV-28E-B, ATAPI CD/DVD-ROM drive
[    2.977324] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    2.982899] hda: UDMA/33 mode selected
[    2.983189] ide0 at 0xd58-0xd5f,0xd66 on irq 55
[    2.983475] GSI 16 (level, low) -> CPU 1 (0x0100) vector 56
[    2.983511] ohci_hcd 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> I=
RQ 56
[    2.983581] ohci_hcd 0000:00:01.0: OHCI Host Controller
[    2.983632] ohci_hcd 0000:00:01.0: new USB bus registered, assigned
bus number 2
[    2.983695] ohci_hcd 0000:00:01.0: irq 56, io mem 0x80023000
[    3.203987] eth1: Tigon3 [partno(BCM95700A6) rev 0105]
(PCI:66MHz:64-bit) MAC address 00:30:6e:4a:d2:bd
[    3.204038] eth1: attached PHY is 5701 (10/100/1000Base-T Ethernet)
(WireSpeed[1])
[    3.204086] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[0]
[    3.204121] eth1: dma_rwctrl[76ff2d0f] dma_mask[64-bit]
[    3.204929] GSI 27 (level, low) -> CPU 0 (0x0000) vector 57
[    3.204965] mptspi 0000:20:01.0: PCI INT A -> GSI 27 (level, low) -> IRQ=
 57
[    3.205205] mptbase: ioc0: Initiating bringup
[    3.551349] usb usb2: New USB device found, idVendor=1D6b, idProduct=0001
[    3.551386] usb usb2: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    3.551432] usb usb2: Product: OHCI Host Controller
[    3.551466] usb usb2: Manufacturer: Linux 2.6.33-rc3 ohci_hcd
[    3.551500] usb usb2: SerialNumber: 0000:00:01.0
[    3.551700] hub 2-0:1.0: USB hub found
[    3.551738] hub 2-0:1.0: 3 ports detected
[    3.554316] GSI 17 (level, low) -> CPU 1 (0x0100) vector 58
[    3.554352] ohci_hcd 0000:00:01.1: PCI INT B -> GSI 17 (level, low) -> I=
RQ 58
[    3.554422] ohci_hcd 0000:00:01.1: OHCI Host Controller
[    3.554466] ohci_hcd 0000:00:01.1: new USB bus registered, assigned
bus number 3
[    3.554540] ohci_hcd 0000:00:01.1: irq 58, io mem 0x80022000
[    3.583979] libata version 3.00 loaded.
[    3.689304] ioc0: LSI53C1030 B2: Capabilities=3D{Initiator,Target}
[    4.120147] usb usb3: New USB device found, idVendor=1D6b, idProduct=0001
[    4.120183] usb usb3: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    4.120229] usb usb3: Product: OHCI Host Controller
[    4.120263] usb usb3: Manufacturer: Linux 2.6.33-rc3 ohci_hcd
[    4.120297] usb usb3: SerialNumber: 0000:00:01.1
[    4.120483] hub 3-0:1.0: USB hub found
[    4.120520] hub 3-0:1.0: 2 ports detected
[    4.128848] ide-cd driver 5.00
[    4.134843] ide-cd: hda: ATAPI 24X DVD-ROM drive, 256kB Cache
[    4.134943] Uniform CD-ROM driver Revision: 3.20
[    4.293269] usb 2-1: new low speed USB device using ohci_hcd and address=
 2
[    4.371725] scsi0 : ioc0: LSI53C1030 B2, FwRev=01032300h, Ports=3D1,
MaxQ%5, IRQW
[    4.468320] usb 2-1: New USB device found, idVendor=045e, idProduct=0040
[    4.468357] usb 2-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[    4.468393] usb 2-1: Product: Microsoft Wheel Mouse Optical=AE
[    4.468428] usb 2-1: Manufacturer: Microsoft
[    4.483770] usbcore: registered new interface driver hiddev
[    4.492436] input: Microsoft Microsoft Wheel Mouse Optical=AE as
/devices/pci0000:00/0000:00:01.0/usb2/2-1/2-1:1.0/input/input2
[    4.492539] generic-usb 0003:045E:0040.0001: input,hidraw0: USB HID
v1.00 Mouse [Microsoft Microsoft Wheel Mouse Optical=AE] on
usb-0000:00:01.0-1/input0
[    4.492611] usbcore: registered new interface driver usbhid
[    4.492645] usbhid: USB HID core driver
[    4.858077] usb 3-1: new low speed USB device using ohci_hcd and address=
 2
[    5.008988] GSI 28 (level, low) -> CPU 0 (0x0000) vector 59
[    5.009024] mptspi 0000:20:01.1: PCI INT B -> GSI 28 (level, low) -> IRQ=
 59
[    5.009301] mptbase: ioc1: Initiating bringup
[    5.027103] usb 3-1: New USB device found, idVendor=03f0, idProduct=0024
[    5.027140] usb 3-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[    5.027176] usb 3-1: Product: HP Basic USB Keyboard
[    5.027209] usb 3-1: Manufacturer: CHICONY
[    5.039294] input: CHICONY HP Basic USB Keyboard as
/devices/pci0000:00/0000:00:01.1/usb3/3-1/3-1:1.0/input/input3
[    5.039379] generic-usb 0003:03F0:0024.0002: input,hidraw1: USB HID
v1.10 Keyboard [CHICONY HP Basic USB Keyboard] on
usb-0000:00:01.1-1/input0
[    5.486081] ioc1: LSI53C1030 B2: Capabilities=3D{Initiator,Target}
[    6.168599] scsi1 : ioc1: LSI53C1030 B2, FwRev=01032300h, Ports=3D1,
MaxQ%5, IRQY
[    6.169263] scsi 0:0:0:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    6.169321] scsi target0:0:0: Beginning Domain Validation
[    6.828927] scsi target0:0:0: Ending Domain Validation
[    6.829033] scsi target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[    6.831838] scsi 0:0:1:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    6.831889] scsi target0:0:1: Beginning Domain Validation
[    6.846907] scsi target0:0:1: Ending Domain Validation
[    6.847010] scsi target0:0:1: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[    7.316677] scsi 1:0:2:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    7.316729] scsi target1:0:2: Beginning Domain Validation
[    7.331717] scsi target1:0:2: Ending Domain Validation
[    7.332426] scsi target1:0:2: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[   10.108993] sd 0:0:0:0: [sda] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[   10.109067] sd 0:0:1:0: [sdb] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[   10.110322] sd 0:0:0:0: [sda] Write Protect is off
[   10.110356] sd 0:0:0:0: [sda] Mode Sense: d3 00 10 08
[   10.110374] sd 0:0:1:0: [sdb] Write Protect is off
[   10.110408] sd 0:0:1:0: [sdb] Mode Sense: d3 00 10 08
[   10.111931] sd 0:0:0:0: [sda] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[   10.112040] sd 0:0:1:0: [sdb] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[   10.115421]  sda:
[   10.115523]  sdb: sda1 sda2 sda3
[   10.139924]  sdb1 sdb2 sdb3
[   10.143754] sd 0:0:1:0: [sdb] Attached SCSI disk
[   10.144146] sd 0:0:0:0: [sda] Attached SCSI disk
[   10.335779] sd 1:0:2:0: [sdc] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[   10.337286] sd 1:0:2:0: [sdc] Write Protect is off
[   10.337321] sd 1:0:2:0: [sdc] Mode Sense: d3 00 10 08
[   10.338905] sd 1:0:2:0: [sdc] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[   10.342342]  sdc: sdc1 sdc2 sdc3
[   10.370285] sd 1:0:2:0: [sdc] Attached SCSI disk
[   10.555814] EXT4-fs (sdb2): mounted filesystem with ordered data mode
[   11.891231] udev: starting version 149
[   12.306131] gameport: FM801 is pci0000:40:01.1/gameport0, io
0x3080, speed 876kHz
[   12.838590] Linux video capture interface: v2.00
[   13.371189] GSI 38 (level, low) -> CPU 1 (0x0100) vector 60
[   13.371246] FM801 0000:40:01.0: PCI INT A -> GSI 38 (level, low) -> IRQ =
60
[   13.737422] Adding 2000768k swap on /dev/sdb3.  Priority:-1
extents:1 across:2000768k
[   13.930385] Linux agpgart interface v0.103
[   14.036636] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   14.036674] GART at 0xe000004080ec0000
[   14.036706] read cookie at 0xe000004080ec0000: 0xbadbadc0ffee
[   14.037359]  (null): AGP aperture is 512M @ 0x60000000
[   14.037394] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   14.037429] GART at 0xe000004080ec0000
[   14.037460] read cookie at 0xe000004080ec0000: 0x0
[   14.037492] agpgart: No reserved IO PDIR entry found; GART disabled
[   15.240421] fuse init (API version 7.13)
[   17.233719] NET: Registered protocol family 10
[   17.234377] lo: Disabled Privacy Extensions
[   17.235267] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   17.727728] tg3: eth1: Link is up at 10 Mbps, half duplex.
[   17.727780] tg3: eth1: Flow control is off for TX and off for RX.
[   17.731467] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   18.171995] lp: driver loaded but no devices found
[   18.178499] ppdev: user-space parallel port driver
[   20.167832] GSI 60 (level, low) -> CPU 0 (0x0000) vector 61
[   20.167840] pci 0000:80:00.0: PCI INT A -> GSI 60 (level, low) -> IRQ 61
[   26.289194] [drm] Initialized drm 1.1.0 20060810
[   26.605406] [drm] radeon defaulting to userspace modesetting.
[   26.605413] [drm:drm_init],
[   26.605616] [drm:drm_get_dev],
[   26.605885] [drm:drm_get_minor],
[   26.606047] [drm:drm_get_minor], new minor assigned 0
[   26.606222] [drm:drm_addmap_core], offset =3D 0xd8030000, size 0x0001000=
0, type =3D 1
[   26.606233] [drm:radeon_driver_load], AGP card detected
[   26.606238] [drm] Initialized radeon 1.31.0 20080528 for
0000:80:00.0 on minor 0
[   26.606905] [drm:drm_stub_open],
[   26.606910] [drm:drm_open_helper], pid =3D 1592, minor =3D 0
[   26.606915] [drm:radeon_driver_open],
[   26.606921] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.606952] [drm:drm_addmap_core], 65536 16 a000000203600000
[   26.606959] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.606966] [drm:drm_setup],
[   26.607027] [drm:drm_ioctl], pid=1592, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.607041] [drm:drm_ioctl], pid=1592, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.607052] [drm:drm_ioctl], pid=1592, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.607095] [drm:drm_ioctl], pid=1592, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.607102] [drm:drm_ioctl], pid=1592, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.607195] [drm:drm_release], open_count =3D 1
[   26.607198] [drm:drm_release], pid =3D 1592, device =3D 0xe200, open_cou=
nt =3D 1
[   26.607210] [drm:drm_lastclose],
[   26.607215] [drm:radeon_do_cleanup_cp],
[   26.607218] [drm:drm_lastclose], driver lastclose completed
[   26.607224] [drm:drm_lastclose], lastclose completed
[   26.912021] [drm:drm_stub_open],
[   26.912024] [drm:drm_open_helper], pid =3D 1592, minor =3D 0
[   26.912029] [drm:radeon_driver_open],
[   26.912033] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.912066] [drm:drm_addmap_core], 65536 16 a000000203700000
[   26.912072] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.912078] [drm:drm_setup],
[   26.912096] [drm:drm_ioctl], pid=1592, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.912104] [drm:drm_ioctl], pid=1592, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.912115] [drm:drm_release], open_count =3D 1
[   26.912118] [drm:drm_release], pid =3D 1592, device =3D 0xe200, open_cou=
nt =3D 1
[   26.912127] [drm:drm_lastclose],
[   26.912132] [drm:radeon_do_cleanup_cp],
[   26.912134] [drm:drm_lastclose], driver lastclose completed
[   26.912139] [drm:drm_lastclose], lastclose completed
[   26.912174] [drm:drm_stub_open],
[   26.912177] [drm:drm_open_helper], pid =3D 1592, minor =3D 0
[   26.912182] [drm:radeon_driver_open],
[   26.912185] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.912216] [drm:drm_addmap_core], 65536 16 a000000203800000
[   26.912221] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.912227] [drm:drm_setup],
[   26.912241] [drm:drm_ioctl], pid=1592, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.912247] [drm:drm_ioctl], pid=1592, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   26.912256] [drm:drm_release], open_count =3D 1
[   26.912259] [drm:drm_release], pid =3D 1592, device =3D 0xe200, open_cou=
nt =3D 1
[   26.912267] [drm:drm_lastclose],
[   26.912271] [drm:radeon_do_cleanup_cp],
[   26.912274] [drm:drm_lastclose], driver lastclose completed
[   26.912278] [drm:drm_lastclose], lastclose completed
[   26.912306] [drm:drm_stub_open],
[   26.912309] [drm:drm_open_helper], pid =3D 1592, minor =3D 0
[   26.912313] [drm:radeon_driver_open],
[   26.912317] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.912347] [drm:drm_addmap_core], 65536 16 a000000203900000
[   26.912352] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   26.912358] [drm:drm_setup],
[   26.912378] [drm:drm_ioctl], pid=1592, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.912386] [drm:drm_ioctl], pid=1592, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.912392] [drm:drm_ioctl], pid=1592, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   26.912410] [drm:drm_ioctl], pid=1592, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   26.912428] [drm:drm_ioctl], pid=1592, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   26.912434] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   26.912452] [drm:drm_mmap_locked], start =3D 0x200000000d500000, end
=3D 0x200000000d510000, page offset =3D 0x3dc0
[   26.912458] [drm:drm_mmap_locked] *ERROR* Could not find map
[   26.912482] [drm:drm_ioctl], pid=1592, cmd=3D0x4028641b, nr=3D0x1b, dev
0xe200, auth=3D1
[   26.912488] [drm:drm_ioctl], ret =3D ffffffea
[   26.912503] [drm:drm_release], open_count =3D 1
[   26.912506] [drm:drm_release], pid =3D 1592, device =3D 0xe200, open_cou=
nt =3D 1
[   26.912515] [drm:drm_lastclose],
[   26.912519] [drm:radeon_do_cleanup_cp],
[   26.912522] [drm:drm_lastclose], driver lastclose completed
[   26.912526] [drm:drm_lastclose], lastclose completed
[   28.106133] eth1: no IPv6 routers present

And please find below the output of lspci -vv:

00:01.0 USB Controller: NEC Corporation USB (rev 41) (prog-if 10 [OHCI])
	Subsystem: NEC Corporation Hama USB 2.0 CardBus
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 128 (250ns min, 10500ns max), Cache Line Size: 128 bytes
	Interrupt: pin A routed to IRQ 56
	Region 0: Memory at 80023000 (32-bit, non-prefetchable) [size=3D4K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: ohci_hcd

00:01.1 USB Controller: NEC Corporation USB (rev 41) (prog-if 10 [OHCI])
	Subsystem: NEC Corporation Hama USB 2.0 CardBus
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 128 (250ns min, 10500ns max), Cache Line Size: 128 bytes
	Interrupt: pin B routed to IRQ 58
	Region 0: Memory at 80022000 (32-bit, non-prefetchable) [size=3D4K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: ohci_hcd

00:01.2 USB Controller: NEC Corporation USB 2.0 (rev 02) (prog-if 20 [EHCI])
	Subsystem: NEC Corporation USB 2.0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 128 (4000ns min, 8500ns max), Cache Line Size: 128 bytes
	Interrupt: pin C routed to IRQ 52
	Region 0: Memory at 80021000 (32-bit, non-prefetchable) [size%6]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: ehci_hcd

00:02.0 IDE interface: Silicon Image, Inc. SiI 0649 Ultra ATA/100 PCI
to ATA Host Controller (rev 02) (prog-if 8f [Master SecP SecO PriP
PriO])
	Subsystem: Silicon Image, Inc. SiI 0649 Ultra ATA/100 PCI to ATA Host
Controller
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (500ns min, 1000ns max)
	Interrupt: pin A routed to IRQ 55
	Region 0: I/O ports at 0d58 [size=3D8]
	Region 1: I/O ports at 0d64 [size=3D4]
	Region 2: I/O ports at 0d50 [size=3D8]
	Region 3: I/O ports at 0d60 [size=3D4]
	Region 4: I/O ports at 0d40 [size=16]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D3 PME-
	Kernel driver in use: CMD64x_IDE

00:03.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet
Pro 100 (rev 0d)
	Subsystem: Hewlett-Packard Company Device 1274
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 128 (2000ns min, 14000ns max)
	Interrupt: pin A routed to IRQ 53
	Region 0: Memory at 80020000 (32-bit, non-prefetchable) [size=3D4K]
	Region 1: I/O ports at 0d00 [sized]
	Region 2: Memory at 80000000 (32-bit, non-prefetchable) [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D2 PME-
	Kernel driver in use: e100

20:01.0 SCSI storage controller: LSI Logic / Symbios Logic 53c1030
PCI-X Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: LSI Logic / Symbios Logic Device 1000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 192 (4250ns min, 4500ns max), Cache Line Size: 128 bytes
	Interrupt: pin A routed to IRQ 57
	Region 0: I/O ports at 2100 [size%6]
	Region 1: Memory at 90840000 (64-bit, non-prefetchable) [sizedK]
	Region 3: Memory at 90830000 (64-bit, non-prefetchable) [sizedK]
	Expansion ROM at 90400000 [disabled] [size=3D4M]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] MSI: Enable- Count=3D1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: mptspi

20:01.1 SCSI storage controller: LSI Logic / Symbios Logic 53c1030
PCI-X Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: LSI Logic / Symbios Logic Device 1000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 192 (4250ns min, 4500ns max), Cache Line Size: 128 bytes
	Interrupt: pin B routed to IRQ 59
	Region 0: I/O ports at 2000 [size%6]
	Region 1: Memory at 90820000 (64-bit, non-prefetchable) [sizedK]
	Region 3: Memory at 90810000 (64-bit, non-prefetchable) [sizedK]
	Expansion ROM at 90000000 [disabled] [size=3D4M]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] MSI: Enable- Count=3D1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: mptspi

20:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701
Gigabit Ethernet (rev 15)
	Subsystem: Hewlett-Packard Company Core Lan 1000Base-T
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 192 (16000ns min), Cache Line Size: 128 bytes
	Interrupt: pin A routed to IRQ 54
	Region 0: Memory at 90800000 (64-bit, non-prefetchable) [sizedK]
	Capabilities: [40] PCI-X non-bridge device
		Command: DPERE- ERO+ RBCQ2 OST=3D1
		Status: Dev=FF:1f.1 64bit+ 133MHz+ SCD- USC- DC=3Dsimple DMMRBCQ2
DMOST=3D1 DMCRS=3D8 RSCEM- 266MHz- 533MHz-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [50] Vital Product Data
		Product Name: Broadcom NetXtreme Gigabit Ethernet Controller
		Read-only fields:
			[PN] Part number: BCM95700A6
			[EC] Engineering changes: 106679-15
			[SN] Serial number: 0123456789
			[MN] Manufacture ID: 31 34 65 34
			[RV] Reserved: checksum bad, 26 byte(s) reserved
		Read/write fields:
			[YA] Asset tag: XYZ01234567
			[RW] Read-write area: 107 byte(s) free
		End
	Capabilities: [58] MSI: Enable- Count=3D1/8 Maskable- 64bit+
		Address: 189721380f6b5204  Data: 1ba0
	Kernel driver in use: tg3

40:01.0 Multimedia audio controller: Fortemedia, Inc Xwave QS3000A
[FM801] (rev b2)
	Subsystem: Fortemedia, Inc FM801 PCI Audio
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 128 (1000ns min, 10000ns max)
	Interrupt: pin A routed to IRQ 60
	Region 0: I/O ports at 3000 [size=128]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI+ D1- D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: FM801

40:01.1 Input device controller: Fortemedia, Inc Xwave QS3000A [FM801
game port] (rev b2)
	Subsystem: Fortemedia, Inc FM801 PCI Joystick
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 128 (1000ns min, 10000ns max)
	Region 0: I/O ports at 3080 [size=16]
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI+ D1+ D2- AuxCurrent=3D0mA PME(D0-,D1+,D2-,D3hot+,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
	Kernel driver in use: FM801_gameport

80:00.0 VGA compatible controller: ATI Technologies Inc Radeon R300 NG
[FireGL X1] (rev 80) (prog-if 00 [VGA controller])
	Subsystem: ATI Technologies Inc Device 0152
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping+ SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 192 (2000ns min), Cache Line Size: 128 bytes
	Interrupt: pin A routed to IRQ 61
	Region 0: Memory at d0000000 (32-bit, prefetchable) [size=128M]
	Region 1: I/O ports at 8000 [size%6]
	Region 2: Memory at d8030000 (32-bit, non-prefetchable) [sizedK]
	Expansion ROM at d8000000 [disabled] [size=128K]
	Capabilities: [58] AGP version 2.0
		Status: RQ=80 Iso- ArqSz=3D0 Cal=3D0 SBA+ ITACoh- GART64- HTrans- 64bit-
FW+ AGP3- Rate=3Dx1,x2,x4
		Command: RQ=3D1 ArqSz=3D0 Cal=3D0 SBA+ AGP- GART64- 64bit- FW- Rate=3D<no=
ne>
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-

80:00.1 Display controller: ATI Technologies Inc Radeon R300 [FireGL
X1] (Secondary) (rev 80)
	Subsystem: ATI Technologies Inc Device 0153
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping+ SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 192 (2000ns min), Cache Line Size: 128 bytes
	Region 0: Memory at c8000000 (32-bit, prefetchable) [size=128M]
	Region 1: Memory at d8020000 (32-bit, non-prefetchable) [sizedK]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-

Thank you for your time.

=C9meric

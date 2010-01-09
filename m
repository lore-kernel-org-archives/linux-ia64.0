From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Sat, 09 Jan 2010 11:46:55 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001090346p1ed0a55td260a76fdcc899d5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> 2010/1/9 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> Then for some reason we must be calling hp_zx1_setup() again, and this
> time it failed because the cookie is gone. =A0This could happen if
> agp_add_bridge() failed, but I don't see a way it could fail after
> printing the "AGP aperture is 512M" message.
>
> Can you try the attached patch, please?

Please find below the dmesg output with the patches attached in your
previous message. I don't have the impression that hp_zx1_setup() is
called twice:

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
[    0.000000] Initial ramdisk at: 0xe0000040fe247000 (13945232 bytes)
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
[    0.100063] Security Framework initialized
[    0.100101] SELinux:  Disabled at boot.
[    0.100429] Dentry cache hash table entries: 1048576 (order: 9,
8388608 bytes)
[    0.107579] Inode-cache hash table entries: 524288 (order: 8, 4194304 by=
tes)
[    0.111507] Mount-cache hash table entries: 1024
[    0.111832] Initializing cgroup subsys ns
[    0.111868] Initializing cgroup subsys cpuacct
[    0.111905] Initializing cgroup subsys devices
[    0.111938] Initializing cgroup subsys freezer
[    0.111971] Initializing cgroup subsys net_cls
[    0.112038] ACPI: Core revision 20091214
[    0.114973] Boot processor id 0x0/0x0
[    0.000000] Fixed BSP b0 value from CPU 1
[    0.000000] CPU 1: synchronized ITC with CPU 0 (last diff -40
cycles, maxerr 680 cycles)
[    0.000000] CPU 1: base freq 0.000MHz, ITC ratio=15/2, ITC
freq=1500.000MHz+/-750ppm
[    0.117275] Brought up 2 CPUs
[    0.117309] Total of 2 processors activated (4489.21 BogoMIPS).
[    0.118319] DMI 2.3 present.
[    0.118494] regulator: core version 0.5
[    0.118582] NET: Registered protocol family 16
[    0.118734] ACPI: bus type pci registered
[    0.119355] bio: create slab <bio-0> at 0
[    0.120235] ACPI: EC: Look up EC in DSDT
[    0.129186] ACPI: Interpreter enabled
[    0.129218] ACPI: (supports S0 S5)
[    0.129290] ACPI: Using IOSAPIC for interrupt routing
[    0.268369] ACPI: No dock devices found.
[    0.281593] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.307985] pci_root HWP0002:00: host bridge window [io  0x0000-0x03af]
[    0.308006] pci_root HWP0002:00: host bridge window [io  0x03e0-0x1fff]
[    0.308042] pci_root HWP0002:00: host bridge window [mem
0x80000000-0x8fffffff]
[    0.308089] pci_root HWP0002:00: host bridge window [mem
0x80004000000-0x80103fffffe]
[    0.308730] pci 0000:00:01.0: reg 10: [mem 0x80023000-0x80023fff]
[    0.309898] pci 0000:00:01.0: supports D1 D2
[    0.309901] pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
[    0.309966] pci 0000:00:01.0: PME# disabled
[    0.310611] pci 0000:00:01.1: reg 10: [mem 0x80022000-0x80022fff]
[    0.311770] pci 0000:00:01.1: supports D1 D2
[    0.311773] pci 0000:00:01.1: PME# supported from D0 D1 D2 D3hot
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
[    0.317608] pci 0000:00:03.0: PME# disabled
[    0.318595] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI0._PRT]
[    0.335756] ACPI: PCI Root Bridge [PCI1] (0000:20)
[    0.366411] pci_root HWP0002:01: host bridge window [mem
0xff5e0000-0xff5e0007]
[    0.366458] pci_root HWP0002:01: host bridge window [mem
0xff5e2000-0xff5e2007]
[    0.366506] pci_root HWP0002:01: host bridge window [io  0x2000-0x2fff]
[    0.366543] pci_root HWP0002:01: host bridge window [mem
0x90000000-0x97ffffff]
[    0.366590] pci_root HWP0002:01: host bridge window [mem
0x90004000000-0x90103fffffe]
[    0.367455] pci 0000:20:01.0: reg 10: [io  0x2100-0x21ff]
[    0.367748] pci 0000:20:01.0: reg 14: [mem 0x90840000-0x9084ffff 64bit]
[    0.368041] pci 0000:20:01.0: reg 1c: [mem 0x90830000-0x9083ffff 64bit]
[    0.368334] pci 0000:20:01.0: reg 30: [mem 0x90400000-0x907fffff pref]
[    0.368986] pci 0000:20:01.0: supports D1 D2
[    0.369965] pci 0000:20:01.1: reg 10: [io  0x2000-0x20ff]
[    0.370258] pci 0000:20:01.1: reg 14: [mem 0x90820000-0x9082ffff 64bit]
[    0.370551] pci 0000:20:01.1: reg 1c: [mem 0x90810000-0x9081ffff 64bit]
[    0.370843] pci 0000:20:01.1: reg 30: [mem 0x90000000-0x903fffff pref]
[    0.371495] pci 0000:20:01.1: supports D1 D2
[    0.372907] pci 0000:20:02.0: reg 10: [mem 0x90800000-0x9080ffff 64bit]
[    0.374390] pci 0000:20:02.0: PME# supported from D3hot D3cold
[    0.374466] pci 0000:20:02.0: PME# disabled
[    0.375777] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI1._PRT]
[    0.397173] ACPI: PCI Root Bridge [PCI2] (0000:40)
[    0.421301] pci_root HWP0002:02: host bridge window [io  0x3000-0x5fff]
[    0.421338] pci_root HWP0002:02: host bridge window [mem
0x98000000-0xafffffff]
[    0.421384] pci_root HWP0002:02: host bridge window [mem
0xa0004000000-0xa0103fffffe]
[    0.422244] pci 0000:40:01.0: reg 10: [io  0x3000-0x307f]
[    0.423892] pci 0000:40:01.0: supports D2
[    0.424742] pci 0000:40:01.1: reg 10: [io  0x3080-0x308f]
[    0.426390] pci 0000:40:01.1: supports D1
[    0.426393] pci 0000:40:01.1: PME# supported from D1 D3hot
[    0.426482] pci 0000:40:01.1: PME# disabled
[    0.428222] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI2._PRT]
[    0.483307] ACPI: PCI Root Bridge [PCI3] (0000:60)
[    0.507391] pci_root HWP0002:03: host bridge window [io  0x6000-0x7fff]
[    0.507427] pci_root HWP0002:03: host bridge window [mem
0xb0000000-0xc7ffffff]
[    0.507474] pci_root HWP0002:03: host bridge window [mem
0xb0004000000-0xb0103fffffe]
[    0.509080] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI3._PRT]
[    0.531258] ACPI: PCI Root Bridge [PCI4] (0000:80)
[    0.560668] pci_root HWP0003:00: host bridge window [io  0x03b0-0x03df]
[    0.560706] pci_root HWP0003:00: host bridge window [io  0x8000-0xbfff]
[    0.560742] pci_root HWP0003:00: host bridge window [mem
0x000a0000-0x000fffff]
[    0.560789] pci_root HWP0003:00: host bridge window [mem
0xc8000000-0xdfffffff]
[    0.560836] pci_root HWP0003:00: host bridge window [mem
0xc0004000000-0xc0103fffffe]
[    0.562074] pci 0000:80:00.0: reg 10: [mem 0xd0000000-0xd7ffffff pref]
[    0.562299] pci 0000:80:00.0: reg 14: [io  0x8000-0x80ff]
[    0.562523] pci 0000:80:00.0: reg 18: [mem 0xd8030000-0xd803ffff]
[    0.563411] pci 0000:80:00.0: reg 30: [mem 0xd8000000-0xd801ffff pref]
[    0.563580] pci 0000:80:00.0: Boot video device
[    0.564555] pci 0000:80:00.0: supports D1 D2
[    0.565780] pci 0000:80:00.1: reg 10: [mem 0xc8000000-0xcfffffff pref]
[    0.566005] pci 0000:80:00.1: reg 14: [mem 0xd8020000-0xd802ffff]
[    0.567885] pci 0000:80:00.1: supports D1 D2
[    0.570162] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI4._PRT]
[    0.624616] ACPI: PCI Root Bridge [PCI6] (0000:c0)
[    0.648717] pci_root HWP0002:04: host bridge window [io  0xc000-0xdfff]
[    0.648753] pci_root HWP0002:04: host bridge window [mem
0xe0000000-0xefffffff]
[    0.648800] pci_root HWP0002:04: host bridge window [mem
0xe0004000000-0xe0103fffffe]
[    0.650897] ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI6._PRT]
[    0.658456] vgaarb: device added:
PCI:0000:80:00.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
[    0.658504] vgaarb: loaded
[    0.704879] ioc_init: PAGE_SIZE 16K, iovp_size 16K
[    0.704915] ioc_iova_init() hpa c0000000fed01000 IOV base
0x40000000 mask 0xffffffffc0000000 (1024MB)
[    0.705190] ioc_iova_init() IOV page size 16K pdir e000004080e80000
size 80000
[    0.707376] IOC: reserving 512Mb of IOVA space at 0x60000000 for agpgart
[    0.707412] put cookie at 0xe000004080ec0000: 0xbadbadc0ffee
[    0.707447] ioc_resource_init() res_size 0x1000
[    0.707483] ioc_resource_init() res_map 1000 e000004080e2c000
[    0.707520] IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[    0.757834] Switching to clocksource itc
[    0.759042] pnp: PnP ACPI init
[    0.759098] ACPI: bus type pnp registered
[    0.839790] GSI 34 (edge, high) -> CPU 1 (0x0100) vector 50
[    0.840841] GSI 35 (edge, high) -> CPU 0 (0x0000) vector 51
[    0.941055] pnp: PnP ACPI: found 10 devices
[    0.941088] ACPI: ACPI bus type pnp unregistered
[    0.941319] NET: Registered protocol family 2
[    0.941502] IP route cache hash table entries: 262144 (order: 7,
2097152 bytes)
[    0.942606] TCP established hash table entries: 524288 (order: 9,
8388608 bytes)
[    0.949820] TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
[    0.951445] TCP: Hash tables configured (established 524288 bind 65536)
[    0.951483] TCP reno registered
[    0.951525] UDP hash table entries: 4096 (order: 3, 131072 bytes)
[    0.951736] UDP-Lite hash table entries: 4096 (order: 3, 131072 bytes)
[    0.952099] NET: Registered protocol family 1
[    0.952547] pci 0000:00:03.0: Firmware left e100 interrupts
enabled; disabling
[    0.952942] PCI: CLS 128 bytes, default 128
[    0.953031] Unpacking initramfs...
[    1.430886] Freeing initrd memory: 13600kB freed
[    1.431202] perfmon: version 2.0 IRQ 238
[    1.431242] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4
counters (47 bits)
[    1.431961] perfmon: added sampling format default_format
[    1.431996] perfmon_default_smpl: default_format v2.0 registered
[    1.432172] audit: initializing netlink socket (disabled)
[    1.432224] type 00 audit(1263036540.430:1): initialized
[    1.432770] HugeTLB registered 256 MB page size, pre-allocated 0 pages
[    1.434556] VFS: Disk quotas dquot_6.5.2
[    1.434656] Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
[    1.434837] msgmni has been set to 12163
[    1.435192] alg: No test for stdrng (krng)
[    1.435289] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
[    1.435337] io scheduler noop registered
[    1.435370] io scheduler deadline registered
[    1.435473] io scheduler cfq registered (default)
[    1.435732] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.435779] ACPI: Power Button [PWRF]
[    1.435877] input: Sleep Button as
/devices/LNXSYSTM:00/LNXSLPBN:00/input/input1
[    1.435923] ACPI: Sleep Button [SLPF]
[    1.525966] thermal LNXTHERM:01: registered as thermal_zone0
[    1.526007] ACPI: Thermal Zone [THM0] (27 C)
[    1.527291] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.527566] 00:04: ttyS0 at MMIO 0xff5e0000 (irq =3D 50) is a 16550A
[    1.527698] 00:05: ttyS1 at MMIO 0xff5e2000 (irq =3D 51) is a 16550A
[    1.527932] mice: PS/2 mouse device common for all mice
[    1.528026] rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0
[    1.528440] TCP cubic registered
[    1.528473] NET: Registered protocol family 17
[    1.528576] registered taskstats version 1
[    1.533576] rtc-efi rtc-efi: setting system clock to 2010-01-09
11:29:01 UTC (1263036541)
[    1.533650] Freeing unused kernel memory: 848kB freed
[    1.751380] usbcore: registered new interface driver usbfs
[    1.751587] usbcore: registered new interface driver hub
[    1.751661] usbcore: registered new device driver usb
[    1.774483] SCSI subsystem initialized
[    1.782395] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    1.782457] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.782736] GSI 20 (level, low) -> CPU 1 (0x0100) vector 52
[    1.782772] e100 0000:00:03.0: PCI INT A -> GSI 20 (level, low) -> IRQ 52
[    1.798620] Uniform Multi-Platform E-IDE driver
[    1.809171] Fusion MPT base driver 3.04.13
[    1.809203] Copyright (c) 1999-2008 LSI Corporation
[    1.821022] Fusion MPT SPI Host driver 3.04.13
[    1.824000] GSI 27 (level, low) -> CPU 0 (0x0000) vector 53
[    1.824036] mptspi 0000:20:01.0: PCI INT A -> GSI 27 (level, low) -> IRQ=
 53
[    1.824164] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.824350] mptbase: ioc0: Initiating bringup
[    1.879955] e100 0000:00:03.0: PME# disabled
[    1.880317] e100: eth0: e100_probe: addr 0x80020000, irq 52, MAC
addr 00:30:6e:4a:d3:ab
[    1.880393] cmd64x 0000:00:02.0: IDE controller (0x1095:0x0649 rev 0x02)
[    1.880571] GSI 21 (level, low) -> CPU 1 (0x0100) vector 54
[    1.880608] CMD64x_IDE 0000:00:02.0: PCI INT A -> GSI 21 (level,
low) -> IRQ 54
[    1.880750] cmd64x 0000:00:02.0: IDE port disabled
[    1.880891] cmd64x 0000:00:02.0: 100% native mode on irq 54
[    1.880964]     ide0: BM-DMA at 0x0d40-0x0d47
[    1.881034] Probing IDE interface ide0...
[    2.282378] hda: DV-28E-B, ATAPI CD/DVD-ROM drive
[    2.305238] ioc0: LSI53C1030 B2: Capabilities=3D{Initiator,Target}
[    2.954146] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    2.959720] hda: UDMA/33 mode selected
[    2.960014] ide0 at 0xd58-0xd5f,0xd66 on irq 54
[    2.960301] GSI 18 (level, low) -> CPU 0 (0x0000) vector 55
[    2.960336] ehci_hcd 0000:00:01.2: PCI INT C -> GSI 18 (level, low) -> I=
RQ 55
[    2.960407] ehci_hcd 0000:00:01.2: EHCI Host Controller
[    2.960465] ehci_hcd 0000:00:01.2: new USB bus registered, assigned
bus number 1
[    2.982162] ehci_hcd 0000:00:01.2: irq 55, io mem 0x80021000
[    2.987680] scsi0 : ioc0: LSI53C1030 B2, FwRev=01032300h, Ports=3D1,
MaxQ%5, IRQS
[    2.994254] ehci_hcd 0000:00:01.2: USB 2.0 started, EHCI 0.95
[    2.994323] usb usb1: New USB device found, idVendor=1D6b, idProduct=0002
[    2.994360] usb usb1: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    2.994406] usb usb1: Product: EHCI Host Controller
[    2.994439] usb usb1: Manufacturer: Linux 2.6.33-rc3 ehci_hcd
[    2.994473] usb usb1: SerialNumber: 0000:00:01.2
[    2.994613] hub 1-0:1.0: USB hub found
[    2.994648] hub 1-0:1.0: 5 ports detected
[    3.027220] libata version 3.00 loaded.
[    3.029134] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.029334] GSI 16 (level, low) -> CPU 1 (0x0100) vector 56
[    3.029370] ohci_hcd 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> I=
RQ 56
[    3.029443] ohci_hcd 0000:00:01.0: OHCI Host Controller
[    3.029491] ohci_hcd 0000:00:01.0: new USB bus registered, assigned
bus number 2
[    3.029561] ohci_hcd 0000:00:01.0: irq 56, io mem 0x80023000
[    3.595325] usb usb2: New USB device found, idVendor=1D6b, idProduct=0001
[    3.595362] usb usb2: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    3.595408] usb usb2: Product: OHCI Host Controller
[    3.595441] usb usb2: Manufacturer: Linux 2.6.33-rc3 ohci_hcd
[    3.595475] usb usb2: SerialNumber: 0000:00:01.0
[    3.595704] hub 2-0:1.0: USB hub found
[    3.595742] hub 2-0:1.0: 3 ports detected
[    3.595990] GSI 17 (level, low) -> CPU 0 (0x0000) vector 57
[    3.596026] ohci_hcd 0000:00:01.1: PCI INT B -> GSI 17 (level, low) -> I=
RQ 57
[    3.596095] ohci_hcd 0000:00:01.1: OHCI Host Controller
[    3.596273] ohci_hcd 0000:00:01.1: new USB bus registered, assigned
bus number 3
[    3.596340] ohci_hcd 0000:00:01.1: irq 57, io mem 0x80022000
[    3.604083] ide-cd driver 5.00
[    3.610250] ide-cd: hda: ATAPI 24X DVD-ROM drive, 256kB Cache
[    3.610351] Uniform CD-ROM driver Revision: 3.20
[    3.635313] tg3.c:v3.105 (December 2, 2009)
[    3.635545] GSI 29 (level, low) -> CPU 1 (0x0100) vector 58
[    3.635582] tg3 0000:20:02.0: PCI INT A -> GSI 29 (level, low) -> IRQ 58
[    4.147303] scsi 0:0:0:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    4.147363] scsi target0:0:0: Beginning Domain Validation
[    4.162350] scsi target0:0:0: Ending Domain Validation
[    4.162455] scsi target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[    4.163328] usb usb3: New USB device found, idVendor=1D6b, idProduct=0001
[    4.163364] usb usb3: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
[    4.163410] usb usb3: Product: OHCI Host Controller
[    4.163443] usb usb3: Manufacturer: Linux 2.6.33-rc3 ohci_hcd
[    4.163477] usb usb3: SerialNumber: 0000:00:01.1
[    4.163831] hub 3-0:1.0: USB hub found
[    4.163871] hub 3-0:1.0: 2 ports detected
[    4.165273] scsi 0:0:1:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    4.165325] scsi target0:0:1: Beginning Domain Validation
[    4.180334] scsi target0:0:1: Ending Domain Validation
[    4.180438] scsi target0:0:1: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[    4.390075] usb 2-1: new low speed USB device using ohci_hcd and address=
 2
[    4.565278] usb 2-1: New USB device found, idVendor=045e, idProduct=0040
[    4.565315] usb 2-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[    4.565351] usb 2-1: Product: Microsoft Wheel Mouse Optical=AE
[    4.565385] usb 2-1: Manufacturer: Microsoft
[    4.580881] usbcore: registered new interface driver hiddev
[    4.589431] input: Microsoft Microsoft Wheel Mouse Optical=AE as
/devices/pci0000:00/0000:00:01.0/usb2/2-1/2-1:1.0/input/input2
[    4.589594] generic-usb 0003:045E:0040.0001: input,hidraw0: USB HID
v1.00 Mouse [Microsoft Microsoft Wheel Mouse Optical=AE] on
usb-0000:00:01.0-1/input0
[    4.589747] usbcore: registered new interface driver usbhid
[    4.589781] usbhid: USB HID core driver
[    4.902081] usb 3-1: new low speed USB device using ohci_hcd and address=
 2
[    5.012003] eth1: Tigon3 [partno(BCM95700A6) rev 0105]
(PCI:66MHz:64-bit) MAC address 00:30:6e:4a:d2:bd
[    5.012054] eth1: attached PHY is 5701 (10/100/1000Base-T Ethernet)
(WireSpeed[1])
[    5.012101] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[0]
[    5.012136] eth1: dma_rwctrl[76ff2d0f] dma_mask[64-bit]
[    5.012364] GSI 28 (level, low) -> CPU 0 (0x0000) vector 59
[    5.012399] mptspi 0000:20:01.1: PCI INT B -> GSI 28 (level, low) -> IRQ=
 59
[    5.012765] mptbase: ioc1: Initiating bringup
[    5.073281] usb 3-1: New USB device found, idVendor=03f0, idProduct=0024
[    5.073318] usb 3-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[    5.073354] usb 3-1: Product: HP Basic USB Keyboard
[    5.073387] usb 3-1: Manufacturer: CHICONY
[    5.085466] input: CHICONY HP Basic USB Keyboard as
/devices/pci0000:00/0000:00:01.1/usb3/3-1/3-1:1.0/input/input3
[    5.085551] generic-usb 0003:03F0:0024.0002: input,hidraw1: USB HID
v1.10 Keyboard [CHICONY HP Basic USB Keyboard] on
usb-0000:00:01.1-1/input0
[    5.490083] ioc1: LSI53C1030 B2: Capabilities=3D{Initiator,Target}
[    6.172539] scsi1 : ioc1: LSI53C1030 B2, FwRev=01032300h, Ports=3D1,
MaxQ%5, IRQY
[    7.318529] scsi 1:0:2:0: Direct-Access     HP 73.4G ST373453LC
  HPC5 PQ: 0 ANSI: 3
[    7.318584] scsi target1:0:2: Beginning Domain Validation
[    7.333576] scsi target1:0:2: Ending Domain Validation
[    7.334291] scsi target1:0:2: FAST-160 WIDE SCSI 320.0 MB/s DT IU
QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
[    8.818796] sd 0:0:0:0: [sda] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[    8.818864] sd 0:0:1:0: [sdb] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[    8.820119] sd 0:0:0:0: [sda] Write Protect is off
[    8.820153] sd 0:0:0:0: [sda] Mode Sense: d3 00 10 08
[    8.820172] sd 0:0:1:0: [sdb] Write Protect is off
[    8.820206] sd 0:0:1:0: [sdb] Mode Sense: d3 00 10 08
[    8.821729] sd 0:0:0:0: [sda] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[    8.821837] sd 0:0:1:0: [sdb] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[    8.825206]  sda:
[    8.825311]  sdb: sda1 sda2 sda3
[    8.847910]  sdb1 sdb2 sdb3
[    8.851789] sd 0:0:1:0: [sdb] Attached SCSI disk
[    8.851837] sd 0:0:0:0: [sda] Attached SCSI disk
[    9.251795] EXT4-fs (sdb2): mounted filesystem with ordered data mode
[   10.337911] sd 1:0:2:0: [sdc] 143374738 512-byte logical blocks:
(73.4 GB/68.3 GiB)
[   10.339235] sd 1:0:2:0: [sdc] Write Protect is off
[   10.339269] sd 1:0:2:0: [sdc] Mode Sense: d3 00 10 08
[   10.340843] sd 1:0:2:0: [sdc] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[   10.344283]  sdc: sdc1 sdc2 sdc3
[   10.371658] sd 1:0:2:0: [sdc] Attached SCSI disk
[   10.611198] udev: starting version 149
[   11.142119] gameport: FM801 is pci0000:40:01.1/gameport0, io
0x3080, speed 875kHz
[   11.830450] Linux video capture interface: v2.00
[   12.099487] GSI 38 (level, low) -> CPU 1 (0x0100) vector 60
[   12.099532] FM801 0000:40:01.0: PCI INT A -> GSI 38 (level, low) -> IRQ =
60
[   12.569300] Adding 2000768k swap on /dev/sdb3.  Priority:-1
extents:1 across:2000768k
[   12.778181] Linux agpgart interface v0.103
[   12.786149] agp_hp_init
[   12.885078] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   12.885115] GART at 0xe000004080ec0000
[   12.885147] read cookie at 0xe000004080ec0000: 0xbadbadc0ffee
[   12.885187] hp_zx1_create_gatt_table
[   12.885833]  (null): AGP aperture is 512M @ 0x60000000
[   12.885866] agp_add_bridge: returning 0 (success)
[   12.885899] hp_zx1_setup: agp_add_bridge returned 0
[   12.885932] zx1_gart_probe: hp_zx1_setup returned 0
[   12.885966] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
[   12.886001] GART at 0xe000004080ec0000
[   12.886032] read cookie at 0xe000004080ec0000: 0x0
[   12.886065] agpgart: No reserved IO PDIR entry found; GART disabled
[   12.886099] hp_zx1_cleanup
[   14.424347] fuse init (API version 7.13)
[   16.119589] NET: Registered protocol family 10
[   16.120235] lo: Disabled Privacy Extensions
[   16.121127] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   16.311791] tg3: eth1: Link is up at 10 Mbps, half duplex.
[   16.311836] tg3: eth1: Flow control is off for TX and off for RX.
[   16.315552] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   17.025669] lp: driver loaded but no devices found
[   17.031747] ppdev: user-space parallel port driver
[   18.999705] GSI 60 (level, low) -> CPU 0 (0x0000) vector 61
[   18.999711] pci 0000:80:00.0: PCI INT A -> GSI 60 (level, low) -> IRQ 61
[   25.324840] [drm] Initialized drm 1.1.0 20060810
[   25.641972] [drm] radeon defaulting to userspace modesetting.
[   25.641979] [drm:drm_init],
[   25.642056] [drm:drm_get_dev],
[   25.642401] [drm:drm_get_minor],
[   25.643105] [drm:drm_get_minor], new minor assigned 0
[   25.643279] [drm:drm_addmap_core], offset =3D 0xd8030000, size 0x0001000=
0, type =3D 1
[   25.643290] [drm:radeon_driver_load], AGP card detected
[   25.643295] [drm] Initialized radeon 1.31.0 20080528 for
0000:80:00.0 on minor 0
[   25.644026] [drm:drm_stub_open],
[   25.644031] [drm:drm_open_helper], pid =3D 1614, minor =3D 0
[   25.644036] [drm:radeon_driver_open],
[   25.644042] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   25.644074] [drm:drm_addmap_core], 65536 16 a000000203600000
[   25.644081] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   25.644087] [drm:drm_setup],
[   25.644149] [drm:drm_ioctl], pid=1614, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   25.644164] [drm:drm_ioctl], pid=1614, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   25.644174] [drm:drm_ioctl], pid=1614, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   25.644217] [drm:drm_ioctl], pid=1614, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.644224] [drm:drm_ioctl], pid=1614, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.644314] [drm:drm_release], open_count =3D 1
[   25.644318] [drm:drm_release], pid =3D 1614, device =3D 0xe200, open_cou=
nt =3D 1
[   25.644330] [drm:drm_lastclose],
[   25.644336] [drm:radeon_do_cleanup_cp],
[   25.644339] [drm:drm_lastclose], driver lastclose completed
[   25.644345] [drm:drm_lastclose], lastclose completed
[   25.939746] [drm:drm_stub_open],
[   25.939750] [drm:drm_open_helper], pid =3D 1614, minor =3D 0
[   25.939754] [drm:radeon_driver_open],
[   25.939759] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   25.939793] [drm:drm_addmap_core], 65536 16 a000000203700000
[   25.939799] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   25.939805] [drm:drm_setup],
[   25.939823] [drm:drm_ioctl], pid=1614, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.939830] [drm:drm_ioctl], pid=1614, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.939841] [drm:drm_release], open_count =3D 1
[   25.939845] [drm:drm_release], pid =3D 1614, device =3D 0xe200, open_cou=
nt =3D 1
[   25.939853] [drm:drm_lastclose],
[   25.939858] [drm:radeon_do_cleanup_cp],
[   25.939861] [drm:drm_lastclose], driver lastclose completed
[   25.939865] [drm:drm_lastclose], lastclose completed
[   25.939901] [drm:drm_stub_open],
[   25.939904] [drm:drm_open_helper], pid =3D 1614, minor =3D 0
[   25.939908] [drm:radeon_driver_open],
[   25.939912] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   25.939942] [drm:drm_addmap_core], 65536 16 a000000203800000
[   25.939947] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   25.939953] [drm:drm_setup],
[   25.939967] [drm:drm_ioctl], pid=1614, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.939973] [drm:drm_ioctl], pid=1614, cmd=3D0xc0406400, nr=3D0x00, dev
0xe200, auth=3D1
[   25.939982] [drm:drm_release], open_count =3D 1
[   25.939985] [drm:drm_release], pid =3D 1614, device =3D 0xe200, open_cou=
nt =3D 1
[   25.939993] [drm:drm_lastclose],
[   25.939998] [drm:radeon_do_cleanup_cp],
[   25.940000] [drm:drm_lastclose], driver lastclose completed
[   25.940004] [drm:drm_lastclose], lastclose completed
[   25.940032] [drm:drm_stub_open],
[   25.940035] [drm:drm_open_helper], pid =3D 1614, minor =3D 0
[   25.940039] [drm:radeon_driver_open],
[   25.940043] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   25.940073] [drm:drm_addmap_core], 65536 16 a000000203900000
[   25.940078] [drm:drm_addmap_core], offset =3D 0xd0000000, size 0x0800000=
0, type =3D 0
[   25.940084] [drm:drm_setup],
[   25.940104] [drm:drm_ioctl], pid=1614, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   25.940112] [drm:drm_ioctl], pid=1614, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   25.940118] [drm:drm_ioctl], pid=1614, cmd=3D0xc0106401, nr=3D0x01, dev
0xe200, auth=3D1
[   25.940136] [drm:drm_ioctl], pid=1614, cmd=3D0xc0106407, nr=3D0x07, dev
0xe200, auth=3D1
[   25.940154] [drm:drm_ioctl], pid=1614, cmd=3D0xc0286415, nr=3D0x15, dev
0xe200, auth=3D1
[   25.940160] [drm:drm_addmap_core], offset =3D 0x00000000, size 0x0001000=
0, type =3D 2
[   25.940177] [drm:drm_mmap_locked], start =3D 0x200000000d500000, end
=3D 0x200000000d510000, page offset =3D 0x3dc0
[   25.940183] [drm:drm_mmap_locked] *ERROR* Could not find map
[   25.940208] [drm:drm_ioctl], pid=1614, cmd=3D0x4028641b, nr=3D0x1b, dev
0xe200, auth=3D1
[   25.940213] [drm:drm_ioctl], ret =3D ffffffea
[   25.940227] [drm:drm_release], open_count =3D 1
[   25.940230] [drm:drm_release], pid =3D 1614, device =3D 0xe200, open_cou=
nt =3D 1
[   25.940239] [drm:drm_lastclose],
[   25.940243] [drm:radeon_do_cleanup_cp],
[   25.940246] [drm:drm_lastclose], driver lastclose completed
[   25.940250] [drm:drm_lastclose], lastclose completed
[   27.298167] eth1: no IPv6 routers present

=C9meric

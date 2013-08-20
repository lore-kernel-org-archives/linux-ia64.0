From: =?ISO-8859-1?Q?=C9meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Tue, 20 Aug 2013 22:30:43 +0000
Subject: Re: SGI Atix 4700 Help
Message-Id: <CAA9xbM5YGRcf-D+gnmbbRnqLzcKZsP8upLpnXs_7wvv9koieMQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMzumdZ6Yf+tonQMxEa-vWueHJtkwpVZeO7HCx1xs3kAUkY3rw@mail.gmail.com>
In-Reply-To: <CAMzumdZ6Yf+tonQMxEa-vWueHJtkwpVZeO7HCx1xs3kAUkY3rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Do you get this kind of error with all Linux kernels, or only >=3D 3.2?
It seems to me that you're experiencing memory problem, so I'm
wondering whether this could be a hardware issue (bad memory DIMM)
rather than a problem with Linux.
Maybe Linux kernels >=3D 3.2 test or stress memory in a way that trigger
this hardware fault?

     Emeric

2013/8/21 Barclay Jameson <almightybeeij@gmail.com>:
> I had another go at compiling the ia64 Kernel again on the SGI Altix
> 4700 this time with passing the  O1 flag.
> It at least gave me some output that might be helpful. Anyone have any id=
eas?
>
> ELILO v3.14 for EFI/IA-64
> ..
> Loading \EFI\debian\vmlinuz-3.4.49...Loading Linux... Attempting to
> relocate kernel...done
> Loading file \EFI\debian\initrd.img-3.4.49...done
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.4.49 (beeij@debian) (gcc version 4.6.3
> (Debian 4.6.3-14) ) #10 SMP Tue Aug 20 16:15:16 CDT 2013
> [    0.000000] EFI v1.10 by INTEL: SALsystab=3D0x1802c26190 ACPI 2.0=3D0x=
1802c26280
> [    0.000000] booting generic kernel on platform sn2
> [    0.000000] console [sn_sal0] enabled
> [    0.000000] ACPI: RSDP 0000001802c26280 00024 (v02    SGI)
> [    0.000000] ACPI: XSDT 0000001802c2a740 00044 (v01    SGI  XSDTSN2
> 00010001    ? 0000007C)
> [    0.000000] ACPI: APIC 0000001802c26af0 0032C (v01    SGI  APICSN2
> 00010001    ? 00000001)
> [    0.000000] ACPI: SRAT 0000001802c26e30 006B0 (v01    SGI  SRATSN2
> 00010001    ? 00000001)
> [    0.000000] ACPI: SLIT 0000001802c274f0 0012C (v01    SGI  SLITSN2
> 00010001    ? 00000001)
> [    0.000000] ACPI: FACP 0000001802c27680 000F4 (v03    SGI  FACPSN2
> 00030001    ? 00000001)
> [    0.000000] ACPI Warning: 32/64X length mismatch in Pm1aEventBlock:
> 32/0 (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: 32/64X length mismatch in
> Pm1aControlBlock: 16/0 (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: 32/64X length mismatch in PmTimerBlock:
> 32/0 (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: 32/64X length mismatch in Gpe0Block: 64/0
> (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: Invalid length for Pm1aEventBlock: 0,
> using default 32 (20120320/tbfadt-629)
> [    0.000000] ACPI Warning: Invalid length for Pm1aControlBlock: 0,
> using default 16 (20120320/tbfadt-629)
> [    0.000000] ACPI Warning: Invalid length for PmTimerBlock: 0, using
> default 32 (20120320/tbfadt-629)
> [    0.000000] ACPI: DSDT 0000001802c29750 00024 (v02    SGI  DSDTSN2
> 00020001    ? 0000088B)
> [    0.000000] ACPI: FACS 0000001802c27630 00040
> [    0.000000] ACPI: Local APIC address c0000000fee00000
> [    0.000000] 64 CPUs available, 64 CPUs total
> [    0.000000] Number of logical nodes in system =3D 16
> [    0.000000] Number of memory chunks in system =3D 16
> [    0.000000] SMP: Allowing 64 CPUs, 0 hotplug CPUs
> [    0.000000] Initial ramdisk at: 0xe00003daf517e000 (19257232 bytes)
> [    0.000000] SAL 3.2: SGI SN2 version 1.54
> [    0.000000] SAL Platform features: ITC_Drift
> [    0.000000] SAL: AP wakeup using external interrupt vector 0x12
> [    0.000000] MCA related initialization done
> [    0.000000] ACPI: RSDP 0000001802c26280 00024 (v02    SGI)
> [    0.000000] ACPI: XSDT 0000001802c2a740 0007C (v01    SGI  XSDTSN2
> 00010001    ? 0000007C)
> [    0.000000] ACPI: APIC 0000001802c26af0 0032C (v01    SGI  APICSN2
> 00010001    ? 00000001)
> [    0.000000] ACPI: SRAT 0000001802c26e30 006B0 (v01    SGI  SRATSN2
> 00010001    ? 00000001)
> [    0.000000] ACPI: SLIT 0000001802c274f0 0012C (v01    SGI  SLITSN2
> 00010001    ? 00000001)
> [    0.000000] ACPI: FACP 0000001802c27680 000F4 (v03    SGI  FACPSN2
> 00030001    ? 00000001)
> [    0.000000] ACPI Warning: 32/64X length mismatch in Pm1aEventBlock:
> 32/0 (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: 32/64X length mismatch in
> Pm1aControlBlock: 16/0 (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: 32/64X length mismatch in PmTimerBlock:
> 32/0 (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: 32/64X length mismatch in Gpe0Block: 64/0
> (20120320/tbfadt-548)
> [    0.000000] ACPI Warning: Invalid length for Pm1aEventBlock: 0,
> using default 32 (20120320/tbfadt-629)
> [    0.000000] ACPI Warning: Invalid length for Pm1aControlBlock: 0,
> using default 16 (20120320/tbfadt-629)
> [    0.000000] ACPI Warning: Invalid length for PmTimerBlock: 0, using
> default 32 (20120320/tbfadt-629)
> [    0.000000] ACPI: DSDT 0000001802c29750 0088B (v02    SGI  DSDTSN2
> 00020101    ? 0000088B)
> [    0.000000] ACPI: FACS 0000001802c27630 00040
> [    0.000000] ACPI: SSDT 0000001802c2a1e0 00095 (v02    SGI  SSDTSN2
> 00020101    ? 00000095)
> [    0.000000] ACPI: SSDT 0000001802c2a2f0 000F5 (v02    SGI  SSDTSN2
> 00020101    ? 000000F5)
> [    0.000000] ACPI: SSDT 0000001802c2a400 001F2 (v02    SGI  SSDTSN2
> 00020101    ? 000001F2)
> [    0.000000] ACPI: SSDT 0000001802c29ff0 00095 (v02    SGI  SSDTSN2
> 00020101    ? 00000095)
> [    0.000000] ACPI: SSDT 0000001802c2a610 0007E (v02    SGI  SSDTSN2
> 00020101    ? 0000007E)
> [    0.000000] ACPI: SSDT 0000001802c2a7d0 00139 (v02    SGI  SSDTSN2
> 00020101    ? 00000139)
> [    0.000000] ACPI: SSDT 0000001802c2a6a0 00090 (v02    SGI  SSDTSN2
> 00020101    ? 00000090)
> [    0.000000] SGI SAL version 1.54
> [    0.000000] Virtual mem_map starts at 0xa0007ffca0600000
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00600c00 -> 0x1000000000
> [    0.000000]   Normal   empty
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] Early memory PFN ranges
> [    0.000000]     0: 0x00600c00 -> 0x0063e000
> [    0.000000]     0: 0x00680000 -> 0x006bdfff
> [    0.000000]     1: 0x01600c00 -> 0x0163e000
> [    0.000000]     1: 0x01680000 -> 0x016be000
> [    0.000000]     2: 0x02600c00 -> 0x0263e000
> [    0.000000]     2: 0x02680000 -> 0x026be000
> [    0.000000]     3: 0x03600c00 -> 0x0363e000
> [    0.000000]     3: 0x03680000 -> 0x036be000
> [    0.000000]     4: 0x04600c00 -> 0x0463e000
> [    0.000000]     4: 0x04680000 -> 0x046be000
> [    0.000000]     5: 0x05600c00 -> 0x0563e000
> [    0.000000]     5: 0x05680000 -> 0x056be000
> [    0.000000]     6: 0x06600c00 -> 0x0663e000
> [    0.000000]     6: 0x06680000 -> 0x066bdfff
> [    0.000000]     7: 0x07600c00 -> 0x0763e000
> [    0.000000]     7: 0x07680000 -> 0x076be000
> [    0.000000]     8: 0x08600c00 -> 0x0863e000
> [    0.000000]     8: 0x08680000 -> 0x086be000
> [    0.000000]     9: 0x09600c00 -> 0x0963e000
> [    0.000000]     9: 0x09680000 -> 0x096be000
> [    0.000000]    10: 0x0a600c00 -> 0x0a63e000
> [    0.000000]    10: 0x0a680000 -> 0x0a6be000
> [    0.000000]    11: 0x0b600c00 -> 0x0b63e000
> [    0.000000]    11: 0x0b680000 -> 0x0b6be000
> [    0.000000]    12: 0x0c600c00 -> 0x0c63e000
> [    0.000000]    12: 0x0c680000 -> 0x0c6be000
> [    0.000000]    13: 0x0d600c00 -> 0x0d63e000
> [    0.000000]    13: 0x0d680000 -> 0x0d6be000
> [    0.000000]    14: 0x0e600c00 -> 0x0e63e000
> [    0.000000]    14: 0x0e680000 -> 0x0e6bdfff
> [    0.000000]    15: 0x0f600c00 -> 0x0f63e000
> [    0.000000]    15: 0x0f680000 -> 0x0f6bd9ff
> [    0.000000]    15: 0x0f6bde00 -> 0x0f6bdf56
> [    0.000000]    15: 0x0f6bdf65 -> 0x0f6bdf84
> [    0.000000]    15: 0x0f6bdfa0 -> 0x0f6bdfb9
> [    0.000000] Built 16 zonelists in Node order, mobility grouping on.
>  Total pages: 8033770
> [    0.000000] Policy zone: DMA
> [    0.000000] Kernel command line:
> BOOT_IMAGE=3Dscsi1:/EFI/debian/vmlinuz-3.4.49 root=3D/dev/md0  ro
> [    0.000000] PID hash table entries: 4096 (order: 1, 32768 bytes)
> [    0.000000] Memory: 128722256k/129185072k available (7956k code,
> 496464k reserved, 4790k data, 816k init)
> [    0.000000] SLUB: Genslabs=17, HWalign=128, Order=3D0-3,
> MinObjects=3D0, CPUsd, Nodes%6
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]     CONFIG_RCU_FANOUT set to non-default value of 32
> [    0.000000] NR_IRQS:1024
> [    0.000000] ACPI: Local APIC address c0000000fee00000
> [    0.000000] register_intr: No IOSAPIC for GSI 52
> [    0.000000] WARNING: Persistent clock returned invalid value!
> [    0.000000]          Check your CMOS/BIOS settings.
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [ttySG0] enabled
> [    0.000000] console [ttySG0] enabled
> [    0.044000] Calibrating delay loop... 3182.59 BogoMIPS (lpjc65184)
> [    0.065688] pid_max: default: 65536 minimum: 512
> [    0.073194] Security Framework initialized
> [    0.084011] SELinux:  Disabled at boot.
> [    0.112172] Dentry cache hash table entries: 16777216 (order: 13,
> 134217728 bytes)
> [    0.387579] Inode-cache hash table entries: 8388608 (order: 12,
> 67108864 bytes)
> [    0.523179] Mount-cache hash table entries: 1024
> [    0.528217] Initializing cgroup subsys cpuacct
> [    0.532005] Initializing cgroup subsys devices
> [    0.544004] Initializing cgroup subsys freezer
> [    0.560004] Initializing cgroup subsys net_cls
> [    0.568224] ACPI: Core revision 20120320
> [    0.581597] Boot processor id 0x0/0x0
> [    0.040000] Fixed BSP b0 value from CPU 1
> [    0.659422] Brought up 64 CPUs
> [    0.660031] Total of 64 processors activated (203685.88 BogoMIPS).
> [    0.706196] devtmpfs: initialized
> [    0.724306] DMI not present or invalid.
> [    0.726680] dummy:
> [    0.732470] NET: Registered protocol family 16
> [    0.740147] ACPI: bus type pci registered
> [    0.752148] ACPI  DSDT OEM Rev 0x20101
> [    0.782373] bio: create slab <bio-0> at 0
> [    0.785459] ACPI: Added _OSI(Module Device)
> [    0.792003] ACPI: Added _OSI(Processor Device)
> [    0.804004] ACPI: Added _OSI(3.0 _SCP Extensions)
> [    0.820003] ACPI: Added _OSI(Processor Aggregator Device)
> [    0.828294] ACPI: SCI (ACPI GSI 52) not registered
> [    0.845126] ACPI: Interpreter enabled
> [    0.860003] ACPI: (supports S0)
> [    0.872000] ACPI: Using platform specific model for interrupt routing
> [    0.881647] ACPI: No dock devices found.
> [    0.892058] [Firmware Bug]: ACPI: no secondary bus range in _CRS
> [    0.904010] ACPI: PCI Root Bridge [P000] (domain 0002 [bus 00-ff])
> [    0.916043] pci_root PNP0A03:00: host bridge window [mem
> 0x2010200000-0x20103fffff] (PCI address [0x200000-0x3fffff])
> [    0.928008] pci_root PNP0A03:00: host bridge window [mem
> 0x2010400000-0x20105fffff] (PCI address [0x400000-0x5fffff])
> [    0.944005] pci_root PNP0A03:00: host bridge window [mem
> 0x2010600000-0x20106fffff] (PCI address [0x600000-0x6fffff])
> [    0.956005] pci_root PNP0A03:00: host bridge window [mem
> 0x2180700000-0x21bffeffff] (PCI address [0x700000-0x3ffeffff])
> [    0.980007] pci_root PNP0A03:00: host bridge window [mem
> 0x2180000000-0x21800fffff] (PCI address [0x0-0xfffff])
> [    0.992041] PCI host bridge to bus 0002:00
> [    1.000008] pci_bus 0002:00: root bus resource [mem
> 0x2010200000-0x20103fffff] (bus address [0x00200000-0x003fffff])
> [    1.016005] pci_bus 0002:00: root bus resource [mem
> 0x2010400000-0x20105fffff] (bus address [0x00400000-0x005fffff])
> [    1.036006] pci_bus 0002:00: root bus resource [mem
> 0x2010600000-0x20106fffff] (bus address [0x00600000-0x006fffff])
> [    1.048006] pci_bus 0002:00: root bus resource [mem
> 0x2180700000-0x21bffeffff] (bus address [0x00700000-0x3ffeffff])
> [    1.064005] pci_bus 0002:00: root bus resource [mem
> 0x2180000000-0x21800fffff] (bus address [0x00000000-0x000fffff])
> [    1.081959]  pci0002:00: Requesting ACPI _OSC control (0x1d)
> [    1.092007]  pci0002:00: ACPI _OSC request failed (AE_NOT_FOUND),
> returned control mask: 0x1d
> [    1.108002] ACPI _OSC control for PCIe not granted, disabling ASPM
> [    1.120074] [Firmware Bug]: ACPI: no secondary bus range in _CRS
> [    1.128007] ACPI: PCI Root Bridge [P001] (domain 0001 [bus 00-ff])
> [    1.140036] pci_root PNP0A03:01: host bridge window [mem
> 0x2000200000-0x20003fffff] (PCI address [0x200000-0x3fffff])
> [    1.156005] pci_root PNP0A03:01: host bridge window [mem
> 0x2000400000-0x20005fffff] (PCI address [0x400000-0x5fffff])
> [    1.172005] pci_root PNP0A03:01: host bridge window [mem
> 0x2000600000-0x20006fffff] (PCI address [0x600000-0x6fffff])
> [    1.184007] pci_root PNP0A03:01: host bridge window [io
> 0x1000000-0x10fffff] (PCI address [0x0-0xfffff])
> [    1.196008] pci_root PNP0A03:01: host bridge window [mem
> 0x21c0700000-0x21fffeffff] (PCI address [0x700000-0x3ffeffff])
> [    1.208010] pci_root PNP0A03:01: host bridge window [mem
> 0x21c0000000-0x21c00fffff] (PCI address [0x0-0xfffff])
> [    1.220046] PCI host bridge to bus 0001:00
> [    1.236005] pci_bus 0001:00: root bus resource [mem
> 0x2000200000-0x20003fffff] (bus address [0x00200000-0x003fffff])
> [    1.248005] pci_bus 0001:00: root bus resource [mem
> 0x2000400000-0x20005fffff] (bus address [0x00400000-0x005fffff])
> [    1.260006] pci_bus 0001:00: root bus resource [mem
> 0x2000600000-0x20006fffff] (bus address [0x00600000-0x006fffff])
> [    1.272005] pci_bus 0001:00: root bus resource [io
> 0x1000000-0x10fffff] (bus address [0x0000-0xfffff])
> [    1.288005] pci_bus 0001:00: root bus resource [mem
> 0x21c0700000-0x21fffeffff] (bus address [0x00700000-0x3ffeffff])
> [    1.304005] pci_bus 0001:00: root bus resource [mem
> 0x21c0000000-0x21c00fffff] (bus address [0x00000000-0x000fffff])
> [    1.334427] pci 0001:00:03.0: PCI bridge to [bus 01-01]
> [    1.336601]  pci0001:00: Requesting ACPI _OSC control (0x1d)
> [    1.348005]  pci0001:00: ACPI _OSC request failed (AE_NOT_FOUND),
> returned control mask: 0x1d
> [    1.364002] ACPI _OSC control for PCIe not granted, disabling ASPM
> [    1.376640] [Firmware Bug]: ACPI: no secondary bus range in _CRS
> [    1.388008] ACPI: PCI Root Bridge [P000] (domain 0011 [bus 00-ff])
> [    1.400031] pci_root PNP0A03:02: host bridge window [mem
> 0x6200000000-0x67ffffffff] (PCI address [0x0-0x5ffffffff])
> [    1.412009] pci_root PNP0A03:02: host bridge window [io
> 0x2000000-0x2ffffff] (PCI address [0x0-0xffffff])
> [    1.428045] PCI host bridge to bus 0011:00
> [    1.444005] pci_bus 0011:00: root bus resource [mem
> 0x6200000000-0x67ffffffff] (bus address [0x00000000-0x5ffffffff])
> [    1.456007] pci_bus 0011:00: root bus resource [io
> 0x2000000-0x2ffffff] (bus address [0x0000-0xffffff])
> [    1.473755] pci 0011:00:01.0: PCI bridge to [bus 01-01]
> [    1.480452] pci 0011:00:02.0: PCI bridge to [bus 02-02]
> [    1.492243]  pci0011:00: Requesting ACPI _OSC control (0x1d)
> [    1.500004]  pci0011:00: ACPI _OSC request failed (AE_NOT_FOUND),
> returned control mask: 0x1d
> [    1.516002] ACPI _OSC control for PCIe not granted, disabling ASPM
> [    1.536571] vgaarb: loaded
> [    1.544413] Switching to clocksource sn2_rtc
> [    1.560324] pnp: PnP ACPI init
> [    1.569151] ACPI: bus type pnp registered
> [    1.578709] pnp: PnP ACPI: found 3 devices
> [    1.594314] ACPI: ACPI bus type pnp unregistered
> [    1.610913] NET: Registered protocol family 2
> [    1.616848] IP route cache hash table entries: 524288 (order: 8,
> 4194304 bytes)
> [    1.631962] TCP established hash table entries: 524288 (order: 9,
> 8388608 bytes)
> [    1.656604] TCP bind hash table entries: 65536 (order: 6, 1048576 byte=
s)
> [    1.662448] TCP: Hash tables configured (established 524288 bind 65536)
> [    1.669308] TCP: reno registered
> [    1.685228] UDP hash table entries: 65536 (order: 7, 2097152 bytes)
> [    1.704860] UDP-Lite hash table entries: 65536 (order: 7, 2097152 byte=
s)
> [    1.718780] NET: Registered protocol family 1
> [    1.831029] Unpacking initramfs...
> [    2.559641] Freeing initrd memory: 18784kB freed
> [    2.562393] perfmon: version 2.0 IRQ 238
> [    2.569242] perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12
> counters (47 bits)
> [    2.609465] perfmon: added sampling format default_format
> [    2.612017] perfmon_default_smpl: default_format v2.0 registered
> [    2.941690] audit: initializing netlink socket (disabled)
> [    2.944540] type 00 audit(2.940:1): initialized
> [    3.053549] HugeTLB registered 256 MB page size, pre-allocated 0 pages
> [    3.060106] VFS: Disk quotas dquot_6.5.2
> [    3.063376] Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
> [    3.077548] msgmni has been set to 32768
> [    3.085721] Block layer SCSI generic (bsg) driver version 0.4
> loaded (major 253)
> [    3.101259] io scheduler noop registered
> [    3.114227] io scheduler deadline registered
> [    3.124480] io scheduler cfq registered (default)
> [    3.138410] input: Power Button as
> /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
> [    3.151399] ACPI: Power Button [PWRF]
> [    3.164463] input: Sleep Button as
> /devices/LNXSYSTM:00/LNXSLPBN:00/input/input1
> [    3.175828] ACPI: Sleep Button [SLPF]
> [    3.190913] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [    3.206082] sn_console: Console driver init
> [    3.219494] ttySG0 at I/O 0x0 (irq =3D 0) is a SGI SN L1
> [    3.300195] Linux agpgart interface v0.103
> [    3.303450] mousedev: PS/2 mouse device common for all mice
> [    3.311532] rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0
> [    3.324627] TCP: cubic registered
> [    3.334577] NET: Registered protocol family 17
> [    3.344580] Registering the dns_resolver key type
> [    3.358790] registered taskstats version 1
> [    3.371272] rtc-efi rtc-efi: setting system clock to 2013-08-20
> 21:27:57 UTC (1377034077)
> [    3.381022] Freeing unused kernel memory: 816kB freedLoading, please w=
ait...
> [    3.420446] kernel unaligned access to 0xe000005a80008014,
> ip=3D0xa00000010020df90
> [    3.423708] Unable to handle kernel paging request at virtual
> address 8000800000000018
> [    3.427693] udevd[247]: Oops 8813272891392 [1]
> [    3.427693] Modules linked in:
> [    3.427693]
> [    3.427693] Pid: 247, CPU 17, comm:                udevd
> [    3.427693] psr : 0000101008522030 ifs : 8000000000000001 ip  :
> [<a000000100236f40>]    Not tainted (3.4.49)
> [    3.427693] ip is at mntget+0x20/0xa0
> [    3.427693] unat: 0000000000000000 pfs : 0000000000000286 rsc :
> 0000000000000003
> [    3.427693] rnat: 000000000000003c bsps: 0000000000000038 pr  :
> 000000000001c299
> [    3.427693] ldrs: 0000000000000000 ccv : 0000000000000000 fpsr:
> 0009804c0270033f
> [    3.427693] csd : 0000000000000000 ssd : 0000000000000000
> [    3.427693] b0  : a00000010020dfb0 b6  : a000000100309c40 b7  :
> a0000001000102d0
> [    3.427693] f6  : 000000000000000000000 f7  : 000000000000000000000
> [    3.427693] f8  : 000000000000000000000 f9  : 000000000000000000000
> [    3.427693] f10 : 000000000000000000000 f11 : 000000000000000000000
> [    3.427693] r1  : a000000100e58960 r2  : 0000000000c80000 r3  :
> 0000000000000064
> [    3.427693] r8  : 8000800000000000 r9  : a000000100c05370 r10 :
> e000009805e4fd98
> [    3.427693] r11 : e000005a80008000 r12 : e000009805e4fd40 r13 :
> e000009805e48000
> [    3.427693] r14 : 0000000000c80064 r15 : 0000001008526030 r16 :
> 0000000000c80064
> [    3.427693] r17 : 0000000000000000 r18 : 8000800000000018 r19 :
> e000009805e4fd98
> [    3.427693] r20 : 0000000000000000 r21 : e000009805e4fd50 r22 :
> e000009805e4fdcc
> [    3.427693] r23 : 0000000000000001 r24 : 0000000000000044 r25 :
> e0000118031462f8
> [    3.427693] r26 : fffffffffffc62f8 r27 : fffffffffffc62f8 r28 :
> e000011803180000
> [    3.427693] r29 : fffffffffffc62f0 r30 : 0000000000000063 r31 :
> 0000000000000063
> [    3.427693]
> [    3.427693] Call Trace:
> [    3.427693]  [<a000000100014b00>] show_stack+0x40/0x90
> [    3.427693]                                 sp=E000009805e4f910
> bsp=E000009805e49108
> [    3.427693]  [<a000000100015370>] show_regs+0x7d0/0x900
> [    3.427693]                                 sp=E000009805e4fae0
> bsp=E000009805e49098
> [    3.427693]  [<a00000010003b8c0>] die+0x1c0/0x320
> [    3.427693]                                 sp=E000009805e4fae0
> bsp=E000009805e49058
> [    3.427693]  [<a0000001007c0060>] ia64_do_page_fault+0xa00/0xae0
> [    3.427693]                                 sp=E000009805e4fae0
> bsp=E000009805e49008
> [    3.427693]  [<a00000010000bdc0>] ia64_native_leave_kernel+0x0/0x270
> [    3.427693]                                 sp=E000009805e4fb70
> bsp=E000009805e49008
> [    3.427693]  [<a000000100236f40>] mntget+0x20/0xa0
> [    3.427693]                                 sp=E000009805e4fd40
> bsp=E000009805e49000
> [    3.427693]  [<a00000010020dfb0>] path_get+0x30/0xe0
> [    3.427693]                                 sp=E000009805e4fd40
> bsp=E000009805e48fd0
> [    3.427693]  [<a000000100214860>] path_init+0x7c0/0x880
> [    3.427693]                                 sp=E000009805e4fd40
> bsp=E000009805e48f88
> [    3.427693]  [<a000000100214970>] path_lookupat+0x50/0x1180
> [    3.427693]                                 sp=E000009805e4fd50
> bsp=E000009805e48e88
> [    3.427693]  [<a000000100215ad0>] do_path_lookup+0x30/0x180
> [    3.427693]                                 sp=E000009805e4fd80
> bsp=E000009805e48e48
> [    3.427693]  [<a000000100215c50>] kern_path_create+0x30/0x280
> [    3.427693]                                 sp=E000009805e4fd80
> bsp=E000009805e48e08
> [    3.427693]  [<a000000100219200>] user_path_create+0x60/0xc0
> [    3.427693]                                 sp=E000009805e4fe20
> bsp=E000009805e48dc0
> [    3.427693]  [<a00000010021a9d0>] sys_symlinkat+0x70/0x1e0
> [    3.427693]                                 sp=E000009805e4fe20
> bsp=E000009805e48d50
> [    3.427693]  [<a00000010000bc40>] ia64_ret_from_syscall+0x0/0x20
> [    3.427693]                                 sp=E000009805e4fe30
> bsp=E000009805e48d50
> [    3.427693]  [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
> [    3.427693]                                 sp=E000009805e50000
> bsp=E000009805e48d50
> [    3.427693] Disabling lock debugging due to kernel taint
> [   63.422259] INFO: rcu_sched self-detected stall on CPU { 17}
> [   63.427883] INFO: rcu_sched detected stalls on CPUs/tasks: { 17}
> (detected by 51, t=15002 jiffies)
> [   63.427883] INFO: Stall ended before state dump start
> [   63.422259]  (t=15010 jiffies)
> [   63.422259]
> [   63.422259] Call Trace:
> [   63.422259]  [<a000000100014b00>] show_stack+0x40/0x90
> [   63.422259]                                 sp=E000009805e4f690
> bsp=E000009805e49560
> [   63.422259]  [<a000000100014b80>] dump_stack+0x30/0x50
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e49548
> [   63.422259]  [<a000000100146e90>] __rcu_pending+0x1b0/0x9c0
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e494d8
> [   63.422259]  [<a000000100148520>] rcu_check_callbacks+0x100/0x1a0
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e494b0
> [   63.422259]  [<a000000100086a40>] update_process_times+0x60/0xc0
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e49480
> [   63.422259]  [<a00000010003a940>] timer_interrupt+0x1c0/0x300
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e49420
> [   63.422259]  [<a000000100138460>] handle_irq_event_percpu+0xc0/0x3c0
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e49390
> [   63.422259]  [<a00000010013fcb0>] handle_percpu_irq+0x110/0x1a0
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e49360
> [   63.422259]  [<a000000100137590>] generic_handle_irq+0x90/0xc0
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e49340
> [   63.422259]  [<a000000100013200>] ia64_handle_irq+0x2a0/0x340
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e492b0
> [   63.422259]  [<a00000010000bdc0>] ia64_native_leave_kernel+0x0/0x270
> [   63.422259]                                 sp=E000009805e4f860
> bsp=E000009805e492b0
> [   63.422259]  [<a0000001002366f0>] vfsmount_lock_local_lock+0xb0/0xe0
> [   63.422259]                                 sp=E000009805e4fa30
> bsp=E000009805e492a0
> [   63.422259]  [<a000000100239720>] mntput_no_expire+0x40/0x380
> [   63.422259]                                 sp=E000009805e4fa30
> bsp=E000009805e49250
> [   63.422259]  [<a000000100239ac0>] mntput+0x60/0x80
> [   63.422259]                                 sp=E000009805e4fa30
> bsp=E000009805e49230
> [   63.422259]  [<a0000001001fb910>] fput+0x510/0x540
> [   63.422259]                                 sp=E000009805e4fa30
> bsp=E000009805e491d8
> [   63.422259]  [<a0000001001a6710>] remove_vma+0xd0/0x160
> [   63.422259]                                 sp=E000009805e4fa30
> bsp=E000009805e491b0
> [   63.422259]  [<a0000001001a9a90>] exit_mmap+0x470/0x500
> [   63.422259]                                 sp=E000009805e4fa30
> bsp=E000009805e49170
> [   63.422259]  [<a000000100065230>] mmput+0x90/0x240
> [   63.422259]                                 sp=E000009805e4fab0
> bsp=E000009805e49150
> [   63.422259]  [<a000000100070490>] exit_mm+0x270/0x2a0
> [   63.422259]                                 sp=E000009805e4fab0
> bsp=E000009805e49118
> [   63.422259]  [<a000000100073f10>] do_exit+0x510/0x1400
> [   63.422259]                                 sp=E000009805e4fac0
> bsp=E000009805e49098
> [   63.422259]  [<a00000010003ba00>] die+0x300/0x320
> [   63.422259]                                 sp=E000009805e4fae0
> bsp=E000009805e49058
> [   63.422259]  [<a0000001007c0060>] ia64_do_page_fault+0xa00/0xae0
> [   63.422259]                                 sp=E000009805e4fae0
> bsp=E000009805e49008
> [   63.422259]  [<a00000010000bdc0>] ia64_native_leave_kernel+0x0/0x270
> [   63.422259]                                 sp=E000009805e4fb70
> bsp=E000009805e49008
> [   63.422259]  [<a000000100236f40>] mntget+0x20/0xa0
> [   63.422259]                                 sp=E000009805e4fd40
> bsp=E000009805e49000
> [   63.422259]  [<a00000010020dfb0>] path_get+0x30/0xe0
> [   63.422259]                                 sp=E000009805e4fd40
> bsp=E000009805e48fd0
> [   63.422259]  [<a000000100214860>] path_init+0x7c0/0x880
> [   63.422259]                                 sp=E000009805e4fd40
> bsp=E000009805e48f88
> [   63.422259]  [<a000000100214970>] path_lookupat+0x50/0x1180
> [   63.422259]                                 sp=E000009805e4fd50
> bsp=E000009805e48e88
> [   63.422259]  [<a000000100215ad0>] do_path_lookup+0x30/0x180
> [   63.422259]                                 sp=E000009805e4fd80
> bsp=E000009805e48e48
> [   63.422259]  [<a000000100215c50>] kern_path_create+0x30/0x280051c21
> [   63.422259]                                 sp=E000009805e4fd80
> bsp=E000009805e48e08
> [   63.422259]  [<a000000100219200>] user_path_create+0x60/0xc0
> [   63.422259]                                 sp=E000009805e4fe20
> bsp=E000009805e48dc0
> [   63.422259]  [<a00000010021a9d0>] sys_symlinkat+0x70/0x1e0
> [   63.422259]                                 sp=E000009805e4fe20
> bsp=E000009805e48d50
> [   63.422259]  [<a00000010000bc40>] ia64_ret_from_syscall+0x0/0x20
> [   63.422259]                                 sp=E000009805e4fe30
> bsp=E000009805e48d50
> [   63.422259]  [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
> [   63.422259]                                 sp=E000009805e50000
> bsp=E000009805e48d50
>
> On Mon, Aug 19, 2013 at 7:05 PM, Barclay Jameson
> <almightybeeij@gmail.com> wrote:
>> I have posted on Nekochan
>> (http://forums.nekochan.net/viewtopic.php?f=3D3&t=16727918) asking help
>> for an error when trying to boot a Kernel compiled >=3D 3.2 (using
>> Debian Wheezy).
>> Here is the error:
>>
>> 000 051.21^1#0a: index time stamp         type      component    subcomp=
onent
>> 000 051.21^1#0a: ----- ------------------ --------- ------------ -------=
-----
>> 000 051.21^1#0a:     0 0x000000c92deef702 MD_HW     051.21^1#0
>> Non-existent Memory Address Error
>> 000 051.21^1#0a:     1 0x000000ce43920f08 PI_HW     051.21^1#0   RRB
>> Time-out Error
>> 000 051.21^1#0a:     2 0x000000ce43b16400 PROC_MCA  051.21^1#0a  Bus Che=
ck
>>
>> A more detailed error is listed below:
>>
>> 000 051.21^1#0a:   SH2_EVENT_OCCURRED                      : 0x000000818=
0000003
>> 000 051.21^1#0a:    MD Hardware Interrupt Pending
>> 000 051.21^1#0a:   SH2_FIRST_ERROR                         : 0x000000000=
0000002
>> 000 051.21^1#0a:    MD Hardware Interrupt Pending
>> 000 051.21^1#0a:   SH2_MEM_ERROR_SUMMARY                   : 0x000000780=
0000002
>> 000 051.21^1#0a:    Non-existent Memory Address Error
>> 000 051.21^1#0a:   SH2_MEM_FIRST_ERROR                     : 0x000000000=
0000002
>> 000 051.21^1#0a:    MD_HW_INT: Non-existent Memory Address Error
>> 000 051.21^1#0a:   SH2_MISC_ERR_HDR_UPPER                  : 0x000000000=
1f00004
>> 000 051.21^1#0a:     Non-Existant Memory Address Error Header Captured
>> 000 051.21^1#0a:     Echo: 0x1f
>> 000 051.21^1#0a:   SH2_MISC_ERR_HDR_LOWER                  : 0x880001000=
0000000
>> 000 051.21^1#0a:     Source  : pi chiplet, nasid 0x0
>> 000 051.21^1#0a:     Command : NCRD, Non-coherent read
>> 000 051.21^1#0a:     Read Operation
>> 000 051.21^1#0a:   SH2_MISC_ADRS_ERR_HDR_LOWER_A           : 0x800000010=
14cf070
>> 000 051.21^1#0a:     Address <37:0>: 0x1014cf070
>> 000 051.21^1#0a:     Read Operation
>> 000 051.21^1#0a:   SH2_MD_HW_TIME_STAMP                    : 0x800000fa2=
2fade06
>> 000 051.21^1#0a:
>> 000 051.21^1#0a: PI_HW :051.21^1#0 :RRB Time-out Error
>> 000 051.21^1#0a:
>> 000 051.21^1#0a:   SH2_EVENT_OCCURRED                      : 0x000000818=
0000003
>> 000 051.21^1#0a:    PI Hardware Interrupt Pending
>> 000 051.21^1#0a:   SH2_FIRST_ERROR                         : 0x000000000=
0000002
>> 000 051.21^1#0a:   SH2_PI_ERROR_SUMMARY                    : 0x000000000=
0000010
>> 000 051.21^1#0a:    RRB Time-out Error
>> 000 051.21^1#0a:   SH2_PI_FIRST_ERROR                     : 0x0000000000=
000010
>> 000 051.21^1#0a:    RRB Time-out Error
>> 000 051.21^1#0a:   SH2_PI_ERROR_DETAIL_1                      :
>> 0xfe200001014cf071
>> 000 051.21^1#0a:   SH2_PI_ERROR_DETAIL_2                      :
>> 0x000000001f0801f1
>> 000 051.21^1#0a:     Address      : 0x1014cf070
>> 000 051.21^1#0a:     Table Select : 0x4
>> 000 051.21^1#0a:     Command      : RESERVED_FE
>> 000 051.21^1#0a:     IsReal       : 0x1
>> 000 051.21^1#0a:     RRB Idx      : 0x1f
>> 000 051.21^1#0a:     WRB Idx      : 0x0
>> 000 051.21^1#0a:     IRB Idx      : 0x0
>> 000 051.21^1#0a:     Error Code   : 0x4
>> 000 051.21^1#0a:     Echo         : 0x1f
>> 000 051.21^1#0a:     Source       : not available
>> 000 051.21^1#0a:     Supplemental : 0x0
>> 000 051.21^1#0a:     AXB Queue    : 0x0
>> 000 051.21^1#0a:   SH2_PI_HW_TIME_STAMP                    : 0x800000feb=
a7afc05
>> 000 051.21^1#0a:
>> 000 051.21^1#0a: PROC_MCA :051.21^1#0a :Bus Check
>> 000 051.21^1#0a:
>> 000 051.21^1#0a:   processor lid                     : 0x0000000000000000
>> 000 051.21^1#0a:     cpu: A nasid: 0x0
>> 000 051.21^1#0a:   processor state parameter         : 0x20010000fff21120
>> 000 051.21^1#0a:     rendevous was not attempted
>> 000 051.21^1#0a:     min state is valid
>> 000 051.21^1#0a:     not continuable
>> 000 051.21^1#0a:     machine check is isolated
>> 000 051.21^1#0a:     more info available
>> 000 051.21^1#0a:     ip logged is not precise
>> 000 051.21^1#0a:     min state is not precise
>> 000 051.21^1#0a:     shared MCA
>> 000 051.21^1#0a:     bus check
>> 000 051.21^1#0a:     PAL recovery status:
>> 000 051.21^1#0a:       error was isolated and contained, continuable
>> if sw can recover
>> 000 051.21^1#0a:   processor error map               : 0x0000000001000000
>> 000 051.21^1#0a:     processor code id: 0
>> 000 051.21^1#0a:     logical thread id: 0
>> 000 051.21^1#0a:     processor bus level 1 error
>> 000 051.21^1#0a:   processor structure: bus
>> 000 051.21^1#0a:     bus check                         : 0x1880000000800=
141
>> 000 051.21^1#0a:       bus transaction size: 1
>> 000 051.21^1#0a:       external bus error
>> 000 051.21^1#0a:       transaction type: partial read
>> 000 051.21^1#0a:       bus error severity: 0
>> 000 051.21^1#0a:       bus hierarchy: 0
>> 000 051.21^1#0a:       UCE detected on incoming
>> 000 051.21^1#0a:       ia64 instruction set
>> 000 051.21^1#0a:       machine check corrected
>> 000 051.21^1#0a:       target address valid
>> 000 051.21^1#0a:     target identifier                 : 0x00000001014cf=
071
>>
>> Anybody have any any pointers to help me solve this problem?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

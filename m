From: Dennis Schridde <devurandom@gmx.net>
Date: Fri, 24 Jan 2014 22:32:17 +0000
Subject: Re: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <1733893.KHLnUZ27kp@ernie>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart1744716.kM5xPohOc1"
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--nextPart1744716.kM5xPohOc1
Content-Type: multipart/mixed; boundary="nextPart1760099.fd1tlJyCuR"
Content-Transfer-Encoding: quoted-printable

This is a multi-part message in MIME format.

=2D-nextPart1760099.fd1tlJyCuR
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

Hello everyone!

Am Donnerstag, 23. Januar 2014, 10:31:59 schrieb =C9meric MASCHINO:
> Did you compile kernel with -O2 or -O1 optimization?
Thanks for that hint!

=2DO1 boots with output (the default is -O2 and does not work, and -Os or=
=20
CONFIG_CC_OPTIMIZE_FOR_SIZE does not work either).

I get an oops, though:
[   56.305585] Unable to handle kernel NULL pointer dereference (addres=
s=20
000000000000003c)
[   56.305842] modprobe[896]: Oops 8821862825984 [1]

Logs attached. The same config worked with gcc-4.5.4.

I assume it is best to first make -O1 work and then progress to -O2 lat=
er?

=2D-Dennis
=2D-nextPart1760099.fd1tlJyCuR
Content-Disposition: attachment; filename="boot-3.12.7-gentoo.gcc47.log"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-log; charset="UTF-8"; name="boot-3.12.7-gentoo.gcc47.log"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.12.7-gentoo (root@maroon) (gcc version 4.7.3 (Gentoo Hardened 4.7.3-r1 p1.4, pie-0.5.5) ) #4 SMP Fri Jan 24 22:55:01 CET 2014
[    0.000000] EFI v1.10 by HP: SALsystab=0x3fb38000 ACPI 2.0=0x3fb2e000 SMBIOS=0x3fb3a000 HCDP=0x3fb2c000
[    0.000000] Early serial console at MMIO 0xf8050000 (options '9600')
[    0.000000] bootconsole [uart0] enabled
[    0.000000] PCDP: v0 at 0x3fb2c000
[    0.000000] Explicit "console="; ignoring PCDP
[    0.000000] ACPI: RSDP 000000003fb2e000 00028 (v02     HP)
[    0.000000] ACPI: XSDT 000000003fb2e02c 0009C (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: FACP 000000003fb369e0 000F4 (v03     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe0Block: 32/16 (20130725/tbfadt-572)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe1Block: 32/16 (20130725/tbfadt-572)
[    0.000000] ACPI: DSDT 000000003fb2e0e0 05781 (v01     HP   rx2600 00000007 INTL 02012044)
[    0.000000] ACPI: FACS 000000003fb36ad8 00040
[    0.000000] ACPI: SPCR 000000003fb36b18 00050 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: DBGP 000000003fb36b68 00034 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: APIC 000000003fb36c28 000C0 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: SPMI 000000003fb36ba0 00050 (v04     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: CPEP 000000003fb36bf0 00034 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: SSDT 000000003fb33870 001D6 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb33a50 00342 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb33da0 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb347c0 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb351e0 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb35c00 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb36620 001D8 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb36800 000EB (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb368f0 000EF (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] 2 CPUs available, 2 CPUs total
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] Initial ramdisk at: 0xe0000040be750000 (8641392 bytes)
[    0.000000] SAL 3.1: HP version 2.31
[    0.000000] SAL Platform features: None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] MCA related initialization done
[    0.000000] Virtual mem_map starts at 0xa0007fffc7580000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x40bfffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x01000000-0x3f5e3fff]
[    0.000000]   node   0: [mem 0x3fb00000-0x3fb2bfff]
[    0.000000]   node   0: [mem 0x4040000000-0x40667f3fff]
[    0.000000]   node   0: [mem 0x40667f8000-0x40bfd67fff]
[    0.000000]   node   0: [mem 0x40bfda4000-0x40bfe0ffff]
[    0.000000]   node   0: [mem 0x40bfe80000-0x40bffb3fff]
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 136872
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=scsi0:/EFI/gentoo/root/kernel/vmlinuz-3.12.7-gentoo root=/dev/sda2  rd.lvm.lv=maroon/usr console=uart,mmio,0xf8050000 ro
[    0.000000] PID hash table entries: 4096 (order: 1, 32768 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] allocated 271564496 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Memory: 2810976K/3118160K available (6822K kernel code, 929K rwdata, 788K rodata, 880K init, 2710K bss, 307184K reserved)
[    0.000000] Leaving McKinley Errata 9 workaround enabled
[    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=2, Nodes=1024
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU restricting CPUs from NR_CPUS=32 to nr_cpu_ids=2.
[    0.000000] NR_IRQS:1024
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
[    0.000000] Console: colour VGA+ 80x25
[    0.010000] Calibrating delay loop... 1345.12 BogoMIPS (lpj=6725632)
[    0.080112] pid_max: default: 32768 minimum: 301
[    0.080486] Security Framework initialized
[    0.081342] Dentry cache hash table entries: 524288 (order: 8, 4194304 bytes)
[    0.086793] Inode-cache hash table entries: 262144 (order: 7, 2097152 bytes)
[    0.091395] Mount-cache hash table entries: 1024
[    0.093655] Initializing cgroup subsys memory
[    0.098093] Initializing cgroup subsys devices
[    0.098250] Initializing cgroup subsys freezer
[    0.098394] Initializing cgroup subsys blkio
[    0.100117] ACPI: Core revision 20130725
[    0.105669] ACPI: All ACPI Tables successfully acquired
[    0.110515] Boot processor id 0x0/0x0
[    0.000000] Fixed BSP b0 value from CPU 1
[    0.000000] CPU 1: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 429 cycles)
[    0.120028] Brought up 2 CPUs
[    0.120129] Total of 2 processors activated (2690.25 BogoMIPS).
[    0.129333] devtmpfs: initialized
[    0.130369] SMBIOS 2.3 present.
[    0.131305] NET: Registered protocol family 16
[    0.141508] ACPI: bus type PCI registered
[    0.149016] bio: create slab <bio-0> at 0
[    0.149831] ACPI: Added _OSI(Module Device)
[    0.149831] ACPI: Added _OSI(Processor Device)
[    0.149918] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.150011] ACPI: Added _OSI(Processor Aggregator Device)
[    1.650162] ACPI: Interpreter enabled
[    1.650292] ACPI: (supports S0 S5)
[    1.650399] ACPI: Using IOSAPIC for interrupt routing
[    1.656006] ACPI: No dock devices found.
[   18.590345] IOC: zx1 2.2 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[   19.354104] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-1f])
[   19.354306] acpi HWP0002:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[   19.354785] acpi HWP0002:00: Unable to request _OSC control (_OSC support mask: 0x08)
[   20.714114] acpi HWP0002:00: host bridge window [io  0x0000-0x03af]
[   20.714314] acpi HWP0002:00: host bridge window [io  0x03e0-0x1fff]
[   20.714724] acpi HWP0002:00: host bridge window [mem 0x80000000-0x8fffffff]
[   20.714949] acpi HWP0002:00: host bridge window [mem 0x80004000000-0x80103fffffe]
[   20.727777] PCI host bridge to bus 0000:00
[   20.727777] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[   20.730012] pci_bus 0000:00: root bus resource [io  0x03e0-0x1fff]
[   20.730213] pci_bus 0000:00: root bus resource [mem 0x80000000-0x8fffffff]
[   20.738267] pci_bus 0000:00: root bus resource [mem 0x80004000000-0x80103fffffe]
[   20.740012] pci_bus 0000:00: root bus resource [bus 00-1f]
[   21.464106] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 20-3f])
[   21.464304] acpi HWP0002:01: ACPI _OSC support notification failed, disabling PCIe ASPM
[   21.464772] acpi HWP0002:01: Unable to request _OSC control (_OSC support mask: 0x08)
[   22.824108] acpi HWP0002:01: host bridge window [mem 0xff5e0000-0xff5e0007]
[   22.824325] acpi HWP0002:01: host bridge window [mem 0xff5e2000-0xff5e2007]
[   22.824769] acpi HWP0002:01: host bridge window [io  0x2000-0x2fff]
[   22.824972] acpi HWP0002:01: host bridge window [mem 0x90000000-0x97ffffff]
[   22.830012] acpi HWP0002:01: host bridge window [mem 0x90004000000-0x90103fffffe]
[   22.845360] PCI host bridge to bus 0000:20
[   22.845360] pci_bus 0000:20: root bus resource [io  0x2000-0x2fff]
[   22.847609] pci_bus 0000:20: root bus resource [mem 0x90000000-0x97ffffff]
[   22.847827] pci_bus 0000:20: root bus resource [mem 0x90004000000-0x90103fffffe]
[   22.850012] pci_bus 0000:20: root bus resource [bus 20-3f]
[   23.594102] ACPI: PCI Root Bridge [PCI2] (domain 0000 [bus 40-5f])
[   23.594301] acpi HWP0002:02: ACPI _OSC support notification failed, disabling PCIe ASPM
[   23.594766] acpi HWP0002:02: Unable to request _OSC control (_OSC support mask: 0x08)
[   24.874094] acpi HWP0002:02: host bridge window [io  0x3000-0x5fff]
[   24.874292] acpi HWP0002:02: host bridge window [mem 0x98000000-0xafffffff]
[   24.874723] acpi HWP0002:02: host bridge window [mem 0xa0004000000-0xa0103fffffe]
[   25.500087] PCI host bridge to bus 0000:40
[   25.500219] pci_bus 0000:40: root bus resource [io  0x3000-0x5fff]
[   25.500413] pci_bus 0000:40: root bus resource [mem 0x98000000-0xafffffff]
[   25.500851] pci_bus 0000:40: root bus resource [mem 0xa0004000000-0xa0103fffffe]
[   25.508242] pci_bus 0000:40: root bus resource [bus 40-5f]
[   27.094100] ACPI: PCI Root Bridge [PCI3] (domain 0000 [bus 60-7f])
[   27.094299] acpi HWP0002:03: ACPI _OSC support notification failed, disabling PCIe ASPM
[   27.094767] acpi HWP0002:03: Unable to request _OSC control (_OSC support mask: 0x08)
[   28.294108] acpi HWP0002:03: host bridge window [io  0x6000-0x7fff]
[   28.294305] acpi HWP0002:03: host bridge window [mem 0xb0000000-0xc7ffffff]
[   28.294742] acpi HWP0002:03: host bridge window [mem 0xb0004000000-0xb0103fffffe]
[   28.920087] PCI host bridge to bus 0000:60
[   28.920219] pci_bus 0000:60: root bus resource [io  0x6000-0x7fff]
[   28.920411] pci_bus 0000:60: root bus resource [mem 0xb0000000-0xc7ffffff]
[   28.920854] pci_bus 0000:60: root bus resource [mem 0xb0004000000-0xb0103fffffe]
[   28.928292] pci_bus 0000:60: root bus resource [bus 60-7f]
[   30.214113] ACPI: PCI Root Bridge [PCI4] (domain 0000 [bus 80-bf])
[   30.214312] acpi HWP0002:04: ACPI _OSC support notification failed, disabling PCIe ASPM
[   30.214782] acpi HWP0002:04: Unable to request _OSC control (_OSC support mask: 0x08)
[   31.414111] acpi HWP0002:04: host bridge window [io  0x8000-0xbfff]
[   31.414308] acpi HWP0002:04: host bridge window [mem 0xc8000000-0xdfffffff]
[   31.414740] acpi HWP0002:04: host bridge window [mem 0xc0004000000-0xc0103fffffe]
[   32.040087] PCI host bridge to bus 0000:80
[   32.040219] pci_bus 0000:80: root bus resource [io  0x8000-0xbfff]
[   32.040412] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xdfffffff]
[   32.040851] pci_bus 0000:80: root bus resource [mem 0xc0004000000-0xc0103fffffe]
[   32.045670] pci_bus 0000:80: root bus resource [bus 80-bf]
[   33.324107] ACPI: PCI Root Bridge [PCI6] (domain 0000 [bus c0-df])
[   33.324303] acpi HWP0002:05: ACPI _OSC support notification failed, disabling PCIe ASPM
[   33.324768] acpi HWP0002:05: Unable to request _OSC control (_OSC support mask: 0x08)
[   34.524105] acpi HWP0002:05: host bridge window [io  0xc000-0xdfff]
[   34.524300] acpi HWP0002:05: host bridge window [mem 0xe0000000-0xefffffff]
[   34.524763] acpi HWP0002:05: host bridge window [mem 0xe0004000000-0xe0103fffffe]
[   35.150087] PCI host bridge to bus 0000:c0
[   35.150219] pci_bus 0000:c0: root bus resource [io  0xc000-0xdfff]
[   35.150411] pci_bus 0000:c0: root bus resource [mem 0xe0000000-0xefffffff]
[   35.150853] pci_bus 0000:c0: root bus resource [mem 0xe0004000000-0xe0103fffffe]
[   35.158324] pci_bus 0000:c0: root bus resource [bus c0-df]
[   36.684097] ACPI: PCI Root Bridge [PCI7] (domain 0000 [bus e0-ff])
[   36.684295] acpi HWP0002:06: ACPI _OSC support notification failed, disabling PCIe ASPM
[   36.685697] acpi HWP0002:06: Unable to request _OSC control (_OSC support mask: 0x08)
[   38.364096] acpi HWP0002:06: host bridge window [io  0x03b0-0x03df]
[   38.364296] acpi HWP0002:06: host bridge window [io  0xe000-0xffff]
[   38.364743] acpi HWP0002:06: host bridge window [mem 0x000a0000-0x000fffff]
[   38.364969] acpi HWP0002:06: host bridge window [mem 0xf0000000-0xfdffffff]
[   38.370012] acpi HWP0002:06: host bridge window [mem 0xf0004000000-0xf0103fffffe]
[   38.385086] PCI host bridge to bus 0000:e0
[   38.385086] pci_bus 0000:e0: root bus resource [io  0x03b0-0x03df]
[   38.385086] pci_bus 0000:e0: root bus resource [io  0xe000-0xffff]
[   38.387803] pci_bus 0000:e0: root bus resource [mem 0x000a0000-0x000fffff]
[   38.390011] pci_bus 0000:e0: root bus resource [mem 0xf0000000-0xfdffffff]
[   38.390233] pci_bus 0000:e0: root bus resource [mem 0xf0004000000-0xf0103fffffe]
[   38.397892] pci_bus 0000:e0: root bus resource [bus e0-ff]
[   38.485581] ACPI: Enabled 1 GPEs in block 10 to 1F
[   38.486431] vgaarb: device added: PCI:0000:e0:02.0,decodes=io+mem,owns=io+mem,locks=none
[   38.486900] vgaarb: loaded
[   38.486989] vgaarb: bridge control possible 0000:e0:02.0
[   41.430279] Switched to clocksource itc
[   41.472144] pnp: PnP ACPI init
[   41.472264] ACPI: bus type PNP registered
[   45.149939] GSI 34 (edge, high) -> CPU 1 (0x0100) vector 49
[   45.219907] GSI 35 (edge, high) -> CPU 0 (0x0000) vector 50
[   47.969973] pnp: PnP ACPI: found 4 devices
[   47.970102] ACPI: bus type PNP unregistered
[   47.970411] NET: Registered protocol family 2
[   47.971310] TCP established hash table entries: 32768 (order: 5, 524288 bytes)
[   47.972114] TCP bind hash table entries: 32768 (order: 5, 524288 bytes)
[   47.979042] TCP: Hash tables configured (established 32768 bind 32768)
[   47.979325] TCP: reno registered
[   47.986254] UDP hash table entries: 2048 (order: 2, 65536 bytes)
[   47.986557] UDP-Lite hash table entries: 2048 (order: 2, 65536 bytes)
[   48.409885] GSI 16 (level, low) -> CPU 1 (0x0100) vector 51
[   48.849832] GSI 16 (level, low) -> CPU 1 (0x0100) vector 51 unregistered
[   49.289845] GSI 17 (level, low) -> CPU 0 (0x0000) vector 51
[   49.729831] GSI 17 (level, low) -> CPU 0 (0x0000) vector 51 unregistered
[   50.169845] GSI 18 (level, low) -> CPU 1 (0x0100) vector 51
[   50.609831] GSI 18 (level, low) -> CPU 1 (0x0100) vector 51 unregistered
[   50.610179] pci 0000:00:03.0: Firmware left e100 interrupts enabled; disabling
[   50.611217] Unpacking initramfs...
[   55.704647] Freeing initrd memory: 8432kB freed
[   55.705254] perfmon: version 2.0 IRQ 238
[   55.705386] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
[   55.707210] perfmon: added sampling format default_format
[   55.707381] perfmon_default_smpl: default_format v2.0 registered
[   55.724264] bounce pool size: 64 pages
[   55.736038] VFS: Disk quotas dquot_6.5.2
[   55.736612] Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
[   55.737238] msgmni has been set to 5506
[   55.738985] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[   55.739217] io scheduler noop registered
[   55.745299] io scheduler deadline registered
[   55.745941] io scheduler cfq registered (default)
[   55.834914] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   55.855491] 00:02: ttyS0 at MMIO 0xff5e0000 (irq = 49, base_baud = 115200) is a 16550A
[   55.876240] 00:03: ttyS1 at MMIO 0xff5e2000 (irq = 50, base_baud = 115200) is a 16550A
[   56.054999] GSI 82 (level, low) -> CPU 0 (0x0000) vector 51
[   56.077356] 0000:e0:01.0: ttyS2 at MMIO 0xf8051000 (irq = 54, base_baud = 115200) is a 16550A
[   56.277802] 0000:e0:01.1: ttyS3 at MMIO 0xf8050000 (irq = 54, base_baud = 115200) is a 16550A
[   56.278362] console [ttyS3] enabled, bootconsole disabled
[   56.278362] console [ttyS3] enabled, bootconsole disabled
[   56.279132] Couldn't register serial port 0000:e0:01.1: -28
[   56.290308] mousedev: PS/2 mouse device common for all mice
[   56.290889] TCP: cubic registered
[   56.291014] Key type dns_resolver registered
[   56.292281] registered taskstats version 1
[   56.296241] /usr/src/linux-3.12.7-gentoo/drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[   56.299381] Freeing unused kernel memory: 880K (e000000004824000 - e000000004900000)
[   56.305585] Unable to handle kernel NULL pointer dereference (address 000000000000003c)
[   56.305842] modprobe[896]: Oops 8821862825984 [1]
[   56.309367] Modules linked in:
[   56.309474]
[   56.309533] CPU: 0 PID: 896 Comm: modprobe Not tainted 3.12.7-gentoo #4
[   56.314060] Hardware name: hp server rx2600                   , BIOS 02.31                                                            03/11/2004
[   56.314816] task: e0000040b8410000 ti: e0000040b8410d20 task.ti: e0000040b8410d20
[   56.314816] psr : 0000101008526038 ifs : 8000000000000289 ip  : [<a000000100210ed0>]    Not tainted (3.12.7-gentoo)
[   56.314816] ip is at fput+0x10/0x160
[   56.314816] unat: 0000000000000000 pfs : 000000000000058d rsc : 0000000000000003
[   56.314816] rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000016999
[   56.314816] ldrs: 0000000000000000 ccv : 000000040016000b fpsr: 0009804c0270033f
[   56.314816] csd : 0000000000000000 ssd : 0000000000000000
[   56.314816] b0  : a0000001002289f0 b6  : a000000100010480 b7  : a000000100010450
[   56.314816] f6  : 1003e0800000000666e6f f7  : 000000000000000000000
[   56.314816] f8  : 000000000000000000000 f9  : 000000000000000000000
[   56.314816] f10 : 000000000000000000000 f11 : 000000000000000000000
[   56.314816] r1  : a000000100c53490 r2  : 0000000400160000 r3  : 0000000000000000
[   56.314816] r8  : 000000050016000b r9  : 0000000000000005 r10 : 000000040016000b
[   56.314816] r11 : 00000000000006c0 r12 : e0000040b8417ce0 r13 : e0000040b8410000
[   56.314816] r14 : 000000000000003c r15 : 000000000000000b r16 : 000000040016000b
[   56.314816] r17 : 0000000000000004 r18 : 0000000000007fff r19 : e0000040bc07b840
[   56.314816] r20 : 0000000000000075 r21 : 0000000000000075 r22 : e0000040bc07b870
[   56.314816] r23 : e0000040bc084fc2 r24 : 0000000000000007 r25 : 0000000000000002
[   56.314816] r26 : 0000000000000002 r27 : e0000040b8534010 r28 : 0000000000000040
[   56.314816] r29 : e0000040b8534018 r30 : 0000000000000000 r31 : e0000040b8534098
[   56.314816]
[   56.314816] Call Trace:
[   56.314816]  [<a0000001000133a0>] show_stack+0x40/0xa0
[   56.314816]                                 sp=e0000040b8417880 bsp=e0000040b8411358
[   56.314816]  [<a000000100013c00>] show_regs+0x800/0x960
[   56.314816]                                 sp=e0000040b8417a50 bsp=e0000040b84112e8
[   56.314816]  [<a00000010003c080>] die+0x1c0/0x320
[   56.314816]                                 sp=e0000040b8417a80 bsp=e0000040b84112a8
[   56.314816]  [<a000000100067d60>] ia64_do_page_fault+0xa60/0xb80
[   56.314816]                                 sp=e0000040b8417a80 bsp=e0000040b8411208
[   56.314816]  [<a00000010000c260>] ia64_native_leave_kernel+0x0/0x270
[   56.314816]                                 sp=e0000040b8417b10 bsp=e0000040b8411208
[   56.314816]  [<a000000100210ed0>] fput+0x10/0x160
[   56.314816]                                 sp=e0000040b8417ce0 bsp=e0000040b84111b8
[   56.314816]  [<a0000001002289f0>] path_init+0x910/0x9c0
[   56.314816]                                 sp=e0000040b8417ce0 bsp=e0000040b8411160
[   56.314816]  [<a000000100228af0>] path_lookupat+0x50/0x1460
[   56.314816]                                 sp=e0000040b8417cf0 bsp=e0000040b8411040
[   56.314816]  [<a000000100229f30>] filename_lookup+0x30/0xc0
[   56.314816]                                 sp=e0000040b8417d20 bsp=e0000040b8411008
[   56.314816]  [<a00000010022fb50>] user_path_at_empty+0xb0/0x120
[   56.314816]                                 sp=e0000040b8417d20 bsp=e0000040b8410fb0
[   56.314816]  [<a00000010022fc00>] user_path_at+0x40/0x60
[   56.314816]                                 sp=e0000040b8417db0 bsp=e0000040b8410f78
[   56.314816]  [<a000000100217e20>] vfs_fstatat+0x80/0x140
[   56.314816]                                 sp=e0000040b8417db0 bsp=e0000040b8410f30
[   56.314816]  [<a0000001002181b0>] SyS_newfstatat+0x30/0x80
[   56.314816]                                 sp=e0000040b8417dc0 bsp=e0000040b8410ed0
[   56.314816]  [<a00000010000c0e0>] ia64_ret_from_syscall+0x0/0x20
[   56.314816]                                 sp=e0000040b8417e30 bsp=e0000040b8410ed0
[   56.314816]  [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
[   56.314816]                                 sp=e0000040b8418000 bsp=e0000040b8410ed0
[   56.314816] Disabling lock debugging due to kernel taint
[  116.604813] INFO: rcu_sched self-detected stall on CPU { 0}  (t=6000 jiffies g=2631 c=2630 q=13)
[  116.604813] CPU: 0 PID: 896 Comm: modprobe Tainted: G      D      3.12.7-gentoo #4
[  116.604813] Hardware name: hp server rx2600                   , BIOS 02.31                                                            03/11/2004
[  116.604813]
[  116.604813] Call Trace:
[  116.604813]  [<a0000001000133a0>] show_stack+0x40/0xa0
[  116.604813]                                 sp=e0000040b84176c0 bsp=e0000040b84117e8
[  116.604813]  [<a000000100388d50>] dump_stack+0xc0/0xf0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411788
[  116.604813]  [<a00000010014cf80>] rcu_check_callbacks+0x420/0xe80
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411678
[  116.604813]  [<a00000010008b340>] update_process_times+0x60/0x100
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411648
[  116.604813]  [<a00000010003a8e0>] timer_interrupt+0x160/0x2a0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b84115e0
[  116.604813]  [<a0000001000f62b0>] handle_irq_event_percpu+0xd0/0x3e0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411550
[  116.604813]  [<a0000001000fe090>] handle_percpu_irq+0x110/0x1a0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411520
[  116.604813]  [<a0000001000f53c0>] generic_handle_irq+0x80/0xc0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411500
[  116.604813]  [<a000000100012000>] ia64_handle_irq+0x260/0x300
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411468
[  116.604813]  [<a00000010000c260>] ia64_native_leave_kernel+0x0/0x270
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411468
[  116.604813]  [<a0000001000c3a30>] lg_local_lock+0xb0/0xe0
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411458
[  116.604813]  [<a000000100250280>] mntput_no_expire+0x40/0x380
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411400
[  116.604813]  [<a000000100250620>] mntput+0x60/0x80
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b84113d8
[  116.604813]  [<a000000100222950>] path_put+0x30/0x60
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b84113b8
[  116.604813]  [<a00000010026dba0>] free_fs_struct+0x20/0x80
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411398
[  116.604813]  [<a00000010026dd00>] exit_fs+0x100/0x120
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411370
[  116.604813]  [<a0000001000776f0>] do_exit+0x810/0x16e0
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b84112e8
[  116.604813]  [<a00000010003c1c0>] die+0x300/0x320
[  116.604813]                                 sp=e0000040b8417a80 bsp=e0000040b84112a8
[  116.604813]  [<a000000100067d60>] ia64_do_page_fault+0xa60/0xb80
[  116.604813]                                 sp=e0000040b8417a80 bsp=e0000040b8411208
[  116.604813]  [<a00000010000c260>] ia64_native_leave_kernel+0x0/0x270
[  116.604813]                                 sp=e0000040b8417b10 bsp=e0000040b8411208
[  116.604813]  [<a000000100210ed0>] fput+0x10/0x160
[  116.604813]                                 sp=e0000040b8417ce0 bsp=e0000040b84111b8
[  116.604813]  [<a0000001002289f0>] path_init+0x910/0x9c0
[  116.604813]                                 sp=e0000040b8417ce0 bsp=e0000040b8411160
[  116.604813]  [<a000000100228af0>] path_lookupat+0x50/0x1460
[  116.604813]                                 sp=e0000040b8417cf0 bsp=e0000040b8411040
[  116.604813]  [<a000000100229f30>] filename_lookup+0x30/0xc0
[  116.604813]                                 sp=e0000040b8417d20 bsp=e0000040b8411008
[  116.604813]  [<a00000010022fb50>] user_path_at_empty+0xb0/0x120
[  116.604813]                                 sp=e0000040b8417d20 bsp=e0000040b8410fb0
[  116.604813]  [<a00000010022fc00>] user_path_at+0x40/0x60
[  116.604813]                                 sp=e0000040b8417db0 bsp=e0000040b8410f78
[  116.604813]  [<a000000100217e20>] vfs_fstatat+0x80/0x140
[  116.604813]                                 sp=e0000040b8417db0 bsp=e0000040b8410f30
[  116.604813]  [<a0000001002181b0>] SyS_newfstatat+0x30/0x80
[  116.604813]                                 sp=e0000040b8417dc0 bsp=e0000040b8410ed0
[  116.604813]  [<a00000010000c0e0>] ia64_ret_from_syscall+0x0/0x20
[  116.604813]                                 sp=e0000040b8417e30 bsp=e0000040b8410ed0
[  116.604813]  [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
[  116.604813]                                 sp=e0000040b8418000 bsp=e0000040b8410ed0


=2D-nextPart1760099.fd1tlJyCuR--
This is a multi-part message in MIME format.

--nextPart1760099.fd1tlJyCuR
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

Hello everyone!

Am Donnerstag, 23. Januar 2014, 10:31:59 schrieb =C9meric MASCHINO:
> Did you compile kernel with -O2 or -O1 optimization?
Thanks for that hint!

-O1 boots with output (the default is -O2 and does not work, and -Os or=
=20
CONFIG_CC_OPTIMIZE_FOR_SIZE does not work either).

I get an oops, though:
[   56.305585] Unable to handle kernel NULL pointer dereference (addres=
s=20
000000000000003c)
[   56.305842] modprobe[896]: Oops 8821862825984 [1]

Logs attached. The same config worked with gcc-4.5.4.

I assume it is best to first make -O1 work and then progress to -O2 lat=
er?

--Dennis
--nextPart1760099.fd1tlJyCuR
Content-Disposition: attachment; filename="boot-3.12.7-gentoo.gcc47.log"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-log; charset="UTF-8"; name="boot-3.12.7-gentoo.gcc47.log"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.12.7-gentoo (root@maroon) (gcc version 4.7.3 (Gentoo Hardened 4.7.3-r1 p1.4, pie-0.5.5) ) #4 SMP Fri Jan 24 22:55:01 CET 2014
[    0.000000] EFI v1.10 by HP: SALsystab=0x3fb38000 ACPI 2.0=0x3fb2e000 SMBIOS=0x3fb3a000 HCDP=0x3fb2c000
[    0.000000] Early serial console at MMIO 0xf8050000 (options '9600')
[    0.000000] bootconsole [uart0] enabled
[    0.000000] PCDP: v0 at 0x3fb2c000
[    0.000000] Explicit "console="; ignoring PCDP
[    0.000000] ACPI: RSDP 000000003fb2e000 00028 (v02     HP)
[    0.000000] ACPI: XSDT 000000003fb2e02c 0009C (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: FACP 000000003fb369e0 000F4 (v03     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe0Block: 32/16 (20130725/tbfadt-572)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe1Block: 32/16 (20130725/tbfadt-572)
[    0.000000] ACPI: DSDT 000000003fb2e0e0 05781 (v01     HP   rx2600 00000007 INTL 02012044)
[    0.000000] ACPI: FACS 000000003fb36ad8 00040
[    0.000000] ACPI: SPCR 000000003fb36b18 00050 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: DBGP 000000003fb36b68 00034 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: APIC 000000003fb36c28 000C0 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: SPMI 000000003fb36ba0 00050 (v04     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: CPEP 000000003fb36bf0 00034 (v01     HP   rx2600 00000000   HP 00000000)
[    0.000000] ACPI: SSDT 000000003fb33870 001D6 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb33a50 00342 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb33da0 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb347c0 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb351e0 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb35c00 00A16 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb36620 001D8 (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb36800 000EB (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: SSDT 000000003fb368f0 000EF (v01     HP   rx2600 00000006 INTL 02012044)
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] 2 CPUs available, 2 CPUs total
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] Initial ramdisk at: 0xe0000040be750000 (8641392 bytes)
[    0.000000] SAL 3.1: HP version 2.31
[    0.000000] SAL Platform features: None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] MCA related initialization done
[    0.000000] Virtual mem_map starts at 0xa0007fffc7580000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x40bfffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x01000000-0x3f5e3fff]
[    0.000000]   node   0: [mem 0x3fb00000-0x3fb2bfff]
[    0.000000]   node   0: [mem 0x4040000000-0x40667f3fff]
[    0.000000]   node   0: [mem 0x40667f8000-0x40bfd67fff]
[    0.000000]   node   0: [mem 0x40bfda4000-0x40bfe0ffff]
[    0.000000]   node   0: [mem 0x40bfe80000-0x40bffb3fff]
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 136872
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=scsi0:/EFI/gentoo/root/kernel/vmlinuz-3.12.7-gentoo root=/dev/sda2  rd.lvm.lv=maroon/usr console=uart,mmio,0xf8050000 ro
[    0.000000] PID hash table entries: 4096 (order: 1, 32768 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] allocated 271564496 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Memory: 2810976K/3118160K available (6822K kernel code, 929K rwdata, 788K rodata, 880K init, 2710K bss, 307184K reserved)
[    0.000000] Leaving McKinley Errata 9 workaround enabled
[    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=2, Nodes=1024
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU restricting CPUs from NR_CPUS=32 to nr_cpu_ids=2.
[    0.000000] NR_IRQS:1024
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
[    0.000000] Console: colour VGA+ 80x25
[    0.010000] Calibrating delay loop... 1345.12 BogoMIPS (lpj=6725632)
[    0.080112] pid_max: default: 32768 minimum: 301
[    0.080486] Security Framework initialized
[    0.081342] Dentry cache hash table entries: 524288 (order: 8, 4194304 bytes)
[    0.086793] Inode-cache hash table entries: 262144 (order: 7, 2097152 bytes)
[    0.091395] Mount-cache hash table entries: 1024
[    0.093655] Initializing cgroup subsys memory
[    0.098093] Initializing cgroup subsys devices
[    0.098250] Initializing cgroup subsys freezer
[    0.098394] Initializing cgroup subsys blkio
[    0.100117] ACPI: Core revision 20130725
[    0.105669] ACPI: All ACPI Tables successfully acquired
[    0.110515] Boot processor id 0x0/0x0
[    0.000000] Fixed BSP b0 value from CPU 1
[    0.000000] CPU 1: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 429 cycles)
[    0.120028] Brought up 2 CPUs
[    0.120129] Total of 2 processors activated (2690.25 BogoMIPS).
[    0.129333] devtmpfs: initialized
[    0.130369] SMBIOS 2.3 present.
[    0.131305] NET: Registered protocol family 16
[    0.141508] ACPI: bus type PCI registered
[    0.149016] bio: create slab <bio-0> at 0
[    0.149831] ACPI: Added _OSI(Module Device)
[    0.149831] ACPI: Added _OSI(Processor Device)
[    0.149918] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.150011] ACPI: Added _OSI(Processor Aggregator Device)
[    1.650162] ACPI: Interpreter enabled
[    1.650292] ACPI: (supports S0 S5)
[    1.650399] ACPI: Using IOSAPIC for interrupt routing
[    1.656006] ACPI: No dock devices found.
[   18.590345] IOC: zx1 2.2 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[   19.354104] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-1f])
[   19.354306] acpi HWP0002:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[   19.354785] acpi HWP0002:00: Unable to request _OSC control (_OSC support mask: 0x08)
[   20.714114] acpi HWP0002:00: host bridge window [io  0x0000-0x03af]
[   20.714314] acpi HWP0002:00: host bridge window [io  0x03e0-0x1fff]
[   20.714724] acpi HWP0002:00: host bridge window [mem 0x80000000-0x8fffffff]
[   20.714949] acpi HWP0002:00: host bridge window [mem 0x80004000000-0x80103fffffe]
[   20.727777] PCI host bridge to bus 0000:00
[   20.727777] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[   20.730012] pci_bus 0000:00: root bus resource [io  0x03e0-0x1fff]
[   20.730213] pci_bus 0000:00: root bus resource [mem 0x80000000-0x8fffffff]
[   20.738267] pci_bus 0000:00: root bus resource [mem 0x80004000000-0x80103fffffe]
[   20.740012] pci_bus 0000:00: root bus resource [bus 00-1f]
[   21.464106] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 20-3f])
[   21.464304] acpi HWP0002:01: ACPI _OSC support notification failed, disabling PCIe ASPM
[   21.464772] acpi HWP0002:01: Unable to request _OSC control (_OSC support mask: 0x08)
[   22.824108] acpi HWP0002:01: host bridge window [mem 0xff5e0000-0xff5e0007]
[   22.824325] acpi HWP0002:01: host bridge window [mem 0xff5e2000-0xff5e2007]
[   22.824769] acpi HWP0002:01: host bridge window [io  0x2000-0x2fff]
[   22.824972] acpi HWP0002:01: host bridge window [mem 0x90000000-0x97ffffff]
[   22.830012] acpi HWP0002:01: host bridge window [mem 0x90004000000-0x90103fffffe]
[   22.845360] PCI host bridge to bus 0000:20
[   22.845360] pci_bus 0000:20: root bus resource [io  0x2000-0x2fff]
[   22.847609] pci_bus 0000:20: root bus resource [mem 0x90000000-0x97ffffff]
[   22.847827] pci_bus 0000:20: root bus resource [mem 0x90004000000-0x90103fffffe]
[   22.850012] pci_bus 0000:20: root bus resource [bus 20-3f]
[   23.594102] ACPI: PCI Root Bridge [PCI2] (domain 0000 [bus 40-5f])
[   23.594301] acpi HWP0002:02: ACPI _OSC support notification failed, disabling PCIe ASPM
[   23.594766] acpi HWP0002:02: Unable to request _OSC control (_OSC support mask: 0x08)
[   24.874094] acpi HWP0002:02: host bridge window [io  0x3000-0x5fff]
[   24.874292] acpi HWP0002:02: host bridge window [mem 0x98000000-0xafffffff]
[   24.874723] acpi HWP0002:02: host bridge window [mem 0xa0004000000-0xa0103fffffe]
[   25.500087] PCI host bridge to bus 0000:40
[   25.500219] pci_bus 0000:40: root bus resource [io  0x3000-0x5fff]
[   25.500413] pci_bus 0000:40: root bus resource [mem 0x98000000-0xafffffff]
[   25.500851] pci_bus 0000:40: root bus resource [mem 0xa0004000000-0xa0103fffffe]
[   25.508242] pci_bus 0000:40: root bus resource [bus 40-5f]
[   27.094100] ACPI: PCI Root Bridge [PCI3] (domain 0000 [bus 60-7f])
[   27.094299] acpi HWP0002:03: ACPI _OSC support notification failed, disabling PCIe ASPM
[   27.094767] acpi HWP0002:03: Unable to request _OSC control (_OSC support mask: 0x08)
[   28.294108] acpi HWP0002:03: host bridge window [io  0x6000-0x7fff]
[   28.294305] acpi HWP0002:03: host bridge window [mem 0xb0000000-0xc7ffffff]
[   28.294742] acpi HWP0002:03: host bridge window [mem 0xb0004000000-0xb0103fffffe]
[   28.920087] PCI host bridge to bus 0000:60
[   28.920219] pci_bus 0000:60: root bus resource [io  0x6000-0x7fff]
[   28.920411] pci_bus 0000:60: root bus resource [mem 0xb0000000-0xc7ffffff]
[   28.920854] pci_bus 0000:60: root bus resource [mem 0xb0004000000-0xb0103fffffe]
[   28.928292] pci_bus 0000:60: root bus resource [bus 60-7f]
[   30.214113] ACPI: PCI Root Bridge [PCI4] (domain 0000 [bus 80-bf])
[   30.214312] acpi HWP0002:04: ACPI _OSC support notification failed, disabling PCIe ASPM
[   30.214782] acpi HWP0002:04: Unable to request _OSC control (_OSC support mask: 0x08)
[   31.414111] acpi HWP0002:04: host bridge window [io  0x8000-0xbfff]
[   31.414308] acpi HWP0002:04: host bridge window [mem 0xc8000000-0xdfffffff]
[   31.414740] acpi HWP0002:04: host bridge window [mem 0xc0004000000-0xc0103fffffe]
[   32.040087] PCI host bridge to bus 0000:80
[   32.040219] pci_bus 0000:80: root bus resource [io  0x8000-0xbfff]
[   32.040412] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xdfffffff]
[   32.040851] pci_bus 0000:80: root bus resource [mem 0xc0004000000-0xc0103fffffe]
[   32.045670] pci_bus 0000:80: root bus resource [bus 80-bf]
[   33.324107] ACPI: PCI Root Bridge [PCI6] (domain 0000 [bus c0-df])
[   33.324303] acpi HWP0002:05: ACPI _OSC support notification failed, disabling PCIe ASPM
[   33.324768] acpi HWP0002:05: Unable to request _OSC control (_OSC support mask: 0x08)
[   34.524105] acpi HWP0002:05: host bridge window [io  0xc000-0xdfff]
[   34.524300] acpi HWP0002:05: host bridge window [mem 0xe0000000-0xefffffff]
[   34.524763] acpi HWP0002:05: host bridge window [mem 0xe0004000000-0xe0103fffffe]
[   35.150087] PCI host bridge to bus 0000:c0
[   35.150219] pci_bus 0000:c0: root bus resource [io  0xc000-0xdfff]
[   35.150411] pci_bus 0000:c0: root bus resource [mem 0xe0000000-0xefffffff]
[   35.150853] pci_bus 0000:c0: root bus resource [mem 0xe0004000000-0xe0103fffffe]
[   35.158324] pci_bus 0000:c0: root bus resource [bus c0-df]
[   36.684097] ACPI: PCI Root Bridge [PCI7] (domain 0000 [bus e0-ff])
[   36.684295] acpi HWP0002:06: ACPI _OSC support notification failed, disabling PCIe ASPM
[   36.685697] acpi HWP0002:06: Unable to request _OSC control (_OSC support mask: 0x08)
[   38.364096] acpi HWP0002:06: host bridge window [io  0x03b0-0x03df]
[   38.364296] acpi HWP0002:06: host bridge window [io  0xe000-0xffff]
[   38.364743] acpi HWP0002:06: host bridge window [mem 0x000a0000-0x000fffff]
[   38.364969] acpi HWP0002:06: host bridge window [mem 0xf0000000-0xfdffffff]
[   38.370012] acpi HWP0002:06: host bridge window [mem 0xf0004000000-0xf0103fffffe]
[   38.385086] PCI host bridge to bus 0000:e0
[   38.385086] pci_bus 0000:e0: root bus resource [io  0x03b0-0x03df]
[   38.385086] pci_bus 0000:e0: root bus resource [io  0xe000-0xffff]
[   38.387803] pci_bus 0000:e0: root bus resource [mem 0x000a0000-0x000fffff]
[   38.390011] pci_bus 0000:e0: root bus resource [mem 0xf0000000-0xfdffffff]
[   38.390233] pci_bus 0000:e0: root bus resource [mem 0xf0004000000-0xf0103fffffe]
[   38.397892] pci_bus 0000:e0: root bus resource [bus e0-ff]
[   38.485581] ACPI: Enabled 1 GPEs in block 10 to 1F
[   38.486431] vgaarb: device added: PCI:0000:e0:02.0,decodes=io+mem,owns=io+mem,locks=none
[   38.486900] vgaarb: loaded
[   38.486989] vgaarb: bridge control possible 0000:e0:02.0
[   41.430279] Switched to clocksource itc
[   41.472144] pnp: PnP ACPI init
[   41.472264] ACPI: bus type PNP registered
[   45.149939] GSI 34 (edge, high) -> CPU 1 (0x0100) vector 49
[   45.219907] GSI 35 (edge, high) -> CPU 0 (0x0000) vector 50
[   47.969973] pnp: PnP ACPI: found 4 devices
[   47.970102] ACPI: bus type PNP unregistered
[   47.970411] NET: Registered protocol family 2
[   47.971310] TCP established hash table entries: 32768 (order: 5, 524288 bytes)
[   47.972114] TCP bind hash table entries: 32768 (order: 5, 524288 bytes)
[   47.979042] TCP: Hash tables configured (established 32768 bind 32768)
[   47.979325] TCP: reno registered
[   47.986254] UDP hash table entries: 2048 (order: 2, 65536 bytes)
[   47.986557] UDP-Lite hash table entries: 2048 (order: 2, 65536 bytes)
[   48.409885] GSI 16 (level, low) -> CPU 1 (0x0100) vector 51
[   48.849832] GSI 16 (level, low) -> CPU 1 (0x0100) vector 51 unregistered
[   49.289845] GSI 17 (level, low) -> CPU 0 (0x0000) vector 51
[   49.729831] GSI 17 (level, low) -> CPU 0 (0x0000) vector 51 unregistered
[   50.169845] GSI 18 (level, low) -> CPU 1 (0x0100) vector 51
[   50.609831] GSI 18 (level, low) -> CPU 1 (0x0100) vector 51 unregistered
[   50.610179] pci 0000:00:03.0: Firmware left e100 interrupts enabled; disabling
[   50.611217] Unpacking initramfs...
[   55.704647] Freeing initrd memory: 8432kB freed
[   55.705254] perfmon: version 2.0 IRQ 238
[   55.705386] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
[   55.707210] perfmon: added sampling format default_format
[   55.707381] perfmon_default_smpl: default_format v2.0 registered
[   55.724264] bounce pool size: 64 pages
[   55.736038] VFS: Disk quotas dquot_6.5.2
[   55.736612] Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
[   55.737238] msgmni has been set to 5506
[   55.738985] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[   55.739217] io scheduler noop registered
[   55.745299] io scheduler deadline registered
[   55.745941] io scheduler cfq registered (default)
[   55.834914] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   55.855491] 00:02: ttyS0 at MMIO 0xff5e0000 (irq = 49, base_baud = 115200) is a 16550A
[   55.876240] 00:03: ttyS1 at MMIO 0xff5e2000 (irq = 50, base_baud = 115200) is a 16550A
[   56.054999] GSI 82 (level, low) -> CPU 0 (0x0000) vector 51
[   56.077356] 0000:e0:01.0: ttyS2 at MMIO 0xf8051000 (irq = 54, base_baud = 115200) is a 16550A
[   56.277802] 0000:e0:01.1: ttyS3 at MMIO 0xf8050000 (irq = 54, base_baud = 115200) is a 16550A
[   56.278362] console [ttyS3] enabled, bootconsole disabled
[   56.278362] console [ttyS3] enabled, bootconsole disabled
[   56.279132] Couldn't register serial port 0000:e0:01.1: -28
[   56.290308] mousedev: PS/2 mouse device common for all mice
[   56.290889] TCP: cubic registered
[   56.291014] Key type dns_resolver registered
[   56.292281] registered taskstats version 1
[   56.296241] /usr/src/linux-3.12.7-gentoo/drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[   56.299381] Freeing unused kernel memory: 880K (e000000004824000 - e000000004900000)
[   56.305585] Unable to handle kernel NULL pointer dereference (address 000000000000003c)
[   56.305842] modprobe[896]: Oops 8821862825984 [1]
[   56.309367] Modules linked in:
[   56.309474]
[   56.309533] CPU: 0 PID: 896 Comm: modprobe Not tainted 3.12.7-gentoo #4
[   56.314060] Hardware name: hp server rx2600                   , BIOS 02.31                                                            03/11/2004
[   56.314816] task: e0000040b8410000 ti: e0000040b8410d20 task.ti: e0000040b8410d20
[   56.314816] psr : 0000101008526038 ifs : 8000000000000289 ip  : [<a000000100210ed0>]    Not tainted (3.12.7-gentoo)
[   56.314816] ip is at fput+0x10/0x160
[   56.314816] unat: 0000000000000000 pfs : 000000000000058d rsc : 0000000000000003
[   56.314816] rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000016999
[   56.314816] ldrs: 0000000000000000 ccv : 000000040016000b fpsr: 0009804c0270033f
[   56.314816] csd : 0000000000000000 ssd : 0000000000000000
[   56.314816] b0  : a0000001002289f0 b6  : a000000100010480 b7  : a000000100010450
[   56.314816] f6  : 1003e0800000000666e6f f7  : 000000000000000000000
[   56.314816] f8  : 000000000000000000000 f9  : 000000000000000000000
[   56.314816] f10 : 000000000000000000000 f11 : 000000000000000000000
[   56.314816] r1  : a000000100c53490 r2  : 0000000400160000 r3  : 0000000000000000
[   56.314816] r8  : 000000050016000b r9  : 0000000000000005 r10 : 000000040016000b
[   56.314816] r11 : 00000000000006c0 r12 : e0000040b8417ce0 r13 : e0000040b8410000
[   56.314816] r14 : 000000000000003c r15 : 000000000000000b r16 : 000000040016000b
[   56.314816] r17 : 0000000000000004 r18 : 0000000000007fff r19 : e0000040bc07b840
[   56.314816] r20 : 0000000000000075 r21 : 0000000000000075 r22 : e0000040bc07b870
[   56.314816] r23 : e0000040bc084fc2 r24 : 0000000000000007 r25 : 0000000000000002
[   56.314816] r26 : 0000000000000002 r27 : e0000040b8534010 r28 : 0000000000000040
[   56.314816] r29 : e0000040b8534018 r30 : 0000000000000000 r31 : e0000040b8534098
[   56.314816]
[   56.314816] Call Trace:
[   56.314816]  [<a0000001000133a0>] show_stack+0x40/0xa0
[   56.314816]                                 sp=e0000040b8417880 bsp=e0000040b8411358
[   56.314816]  [<a000000100013c00>] show_regs+0x800/0x960
[   56.314816]                                 sp=e0000040b8417a50 bsp=e0000040b84112e8
[   56.314816]  [<a00000010003c080>] die+0x1c0/0x320
[   56.314816]                                 sp=e0000040b8417a80 bsp=e0000040b84112a8
[   56.314816]  [<a000000100067d60>] ia64_do_page_fault+0xa60/0xb80
[   56.314816]                                 sp=e0000040b8417a80 bsp=e0000040b8411208
[   56.314816]  [<a00000010000c260>] ia64_native_leave_kernel+0x0/0x270
[   56.314816]                                 sp=e0000040b8417b10 bsp=e0000040b8411208
[   56.314816]  [<a000000100210ed0>] fput+0x10/0x160
[   56.314816]                                 sp=e0000040b8417ce0 bsp=e0000040b84111b8
[   56.314816]  [<a0000001002289f0>] path_init+0x910/0x9c0
[   56.314816]                                 sp=e0000040b8417ce0 bsp=e0000040b8411160
[   56.314816]  [<a000000100228af0>] path_lookupat+0x50/0x1460
[   56.314816]                                 sp=e0000040b8417cf0 bsp=e0000040b8411040
[   56.314816]  [<a000000100229f30>] filename_lookup+0x30/0xc0
[   56.314816]                                 sp=e0000040b8417d20 bsp=e0000040b8411008
[   56.314816]  [<a00000010022fb50>] user_path_at_empty+0xb0/0x120
[   56.314816]                                 sp=e0000040b8417d20 bsp=e0000040b8410fb0
[   56.314816]  [<a00000010022fc00>] user_path_at+0x40/0x60
[   56.314816]                                 sp=e0000040b8417db0 bsp=e0000040b8410f78
[   56.314816]  [<a000000100217e20>] vfs_fstatat+0x80/0x140
[   56.314816]                                 sp=e0000040b8417db0 bsp=e0000040b8410f30
[   56.314816]  [<a0000001002181b0>] SyS_newfstatat+0x30/0x80
[   56.314816]                                 sp=e0000040b8417dc0 bsp=e0000040b8410ed0
[   56.314816]  [<a00000010000c0e0>] ia64_ret_from_syscall+0x0/0x20
[   56.314816]                                 sp=e0000040b8417e30 bsp=e0000040b8410ed0
[   56.314816]  [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
[   56.314816]                                 sp=e0000040b8418000 bsp=e0000040b8410ed0
[   56.314816] Disabling lock debugging due to kernel taint
[  116.604813] INFO: rcu_sched self-detected stall on CPU { 0}  (t=6000 jiffies g=2631 c=2630 q=13)
[  116.604813] CPU: 0 PID: 896 Comm: modprobe Tainted: G      D      3.12.7-gentoo #4
[  116.604813] Hardware name: hp server rx2600                   , BIOS 02.31                                                            03/11/2004
[  116.604813]
[  116.604813] Call Trace:
[  116.604813]  [<a0000001000133a0>] show_stack+0x40/0xa0
[  116.604813]                                 sp=e0000040b84176c0 bsp=e0000040b84117e8
[  116.604813]  [<a000000100388d50>] dump_stack+0xc0/0xf0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411788
[  116.604813]  [<a00000010014cf80>] rcu_check_callbacks+0x420/0xe80
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411678
[  116.604813]  [<a00000010008b340>] update_process_times+0x60/0x100
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411648
[  116.604813]  [<a00000010003a8e0>] timer_interrupt+0x160/0x2a0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b84115e0
[  116.604813]  [<a0000001000f62b0>] handle_irq_event_percpu+0xd0/0x3e0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411550
[  116.604813]  [<a0000001000fe090>] handle_percpu_irq+0x110/0x1a0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411520
[  116.604813]  [<a0000001000f53c0>] generic_handle_irq+0x80/0xc0
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411500
[  116.604813]  [<a000000100012000>] ia64_handle_irq+0x260/0x300
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411468
[  116.604813]  [<a00000010000c260>] ia64_native_leave_kernel+0x0/0x270
[  116.604813]                                 sp=e0000040b8417890 bsp=e0000040b8411468
[  116.604813]  [<a0000001000c3a30>] lg_local_lock+0xb0/0xe0
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411458
[  116.604813]  [<a000000100250280>] mntput_no_expire+0x40/0x380
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411400
[  116.604813]  [<a000000100250620>] mntput+0x60/0x80
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b84113d8
[  116.604813]  [<a000000100222950>] path_put+0x30/0x60
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b84113b8
[  116.604813]  [<a00000010026dba0>] free_fs_struct+0x20/0x80
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411398
[  116.604813]  [<a00000010026dd00>] exit_fs+0x100/0x120
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b8411370
[  116.604813]  [<a0000001000776f0>] do_exit+0x810/0x16e0
[  116.604813]                                 sp=e0000040b8417a60 bsp=e0000040b84112e8
[  116.604813]  [<a00000010003c1c0>] die+0x300/0x320
[  116.604813]                                 sp=e0000040b8417a80 bsp=e0000040b84112a8
[  116.604813]  [<a000000100067d60>] ia64_do_page_fault+0xa60/0xb80
[  116.604813]                                 sp=e0000040b8417a80 bsp=e0000040b8411208
[  116.604813]  [<a00000010000c260>] ia64_native_leave_kernel+0x0/0x270
[  116.604813]                                 sp=e0000040b8417b10 bsp=e0000040b8411208
[  116.604813]  [<a000000100210ed0>] fput+0x10/0x160
[  116.604813]                                 sp=e0000040b8417ce0 bsp=e0000040b84111b8
[  116.604813]  [<a0000001002289f0>] path_init+0x910/0x9c0
[  116.604813]                                 sp=e0000040b8417ce0 bsp=e0000040b8411160
[  116.604813]  [<a000000100228af0>] path_lookupat+0x50/0x1460
[  116.604813]                                 sp=e0000040b8417cf0 bsp=e0000040b8411040
[  116.604813]  [<a000000100229f30>] filename_lookup+0x30/0xc0
[  116.604813]                                 sp=e0000040b8417d20 bsp=e0000040b8411008
[  116.604813]  [<a00000010022fb50>] user_path_at_empty+0xb0/0x120
[  116.604813]                                 sp=e0000040b8417d20 bsp=e0000040b8410fb0
[  116.604813]  [<a00000010022fc00>] user_path_at+0x40/0x60
[  116.604813]                                 sp=e0000040b8417db0 bsp=e0000040b8410f78
[  116.604813]  [<a000000100217e20>] vfs_fstatat+0x80/0x140
[  116.604813]                                 sp=e0000040b8417db0 bsp=e0000040b8410f30
[  116.604813]  [<a0000001002181b0>] SyS_newfstatat+0x30/0x80
[  116.604813]                                 sp=e0000040b8417dc0 bsp=e0000040b8410ed0
[  116.604813]  [<a00000010000c0e0>] ia64_ret_from_syscall+0x0/0x20
[  116.604813]                                 sp=e0000040b8417e30 bsp=e0000040b8410ed0
[  116.604813]  [<a000000000040720>] ia64_ivt+0xffffffff00040720/0x400
[  116.604813]                                 sp=e0000040b8418000 bsp=e0000040b8410ed0


--nextPart1760099.fd1tlJyCuR--

--nextPart1744716.kM5xPohOc1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIbBAABAgAGBQJS4un5AAoJEGIxC0Gvwa5adYEP+NUYTbN3B1iVEzkUL5Qrzxlu
nTaCbOudWbijY5RkRltnT+qmCl1T72mcWfo0cIdfHPUsFuv9bkex8k1XZmSKsmMs
PkJjoGINhJ5SQ/a3hJWb8pNiimi2Evw48/XdUXwN342mopRXC7xkGpiUZmYhsGEe
XUgQTznyfAfibA2TmrUiEEahy2u+KSAnERjr7hLEm1cNJF12rVadiDQWfNoQW0XJ
+iF/JYFSeeh7x4QSHXHEzrV7g/MmKSSYLU0tGISkMn/kiG8pj19+pt45LGRNdFnW
rA9lD+DIHYMgwL3jcsrq6XXb8hiDr9CuTUCFzmjovqGQ+OT+P3ODvgWmHlVj+raI
po2xGu696NlP7MC+T1WeEywcJUAsf4hBfRyxSABXv2fVzxyKVu3BWDf+BZl0wyC2
tOf87N/qWUriSxLRB+XJx65v6lmEPz08AokoOtop1SnLZbzwVF5hCanoYp42ZuM6
bUqKt/DSx/12tbTs1Fi0SWQzIhEqkjuWIVbb8sKb389G4TX/hOXmTWqp65SEqGoo
/Yv1jpb192Mq/6IUPyAc+pFgv9njG7kJw3y62VRCcIYbV+7hGlo7ZRxyS/etnHD6
NwgXHcNQzjNVbd/H94upwaGMB9geHp2pk40hWDpUq5R6zcEEd7+zI5Zqdm8tzMJB
fnahY6hxsJAf5TI8C6Q=
=0Wq2
-----END PGP SIGNATURE-----

--nextPart1744716.kM5xPohOc1--


From: Stefan Klein <stfn.klein@gmx.de>
Date: Thu, 04 Mar 2010 09:18:26 +0000
Subject: Problem with IDE drive in IA64 system
Message-Id: <4B8F7AE2.6050007@gmx.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050308030405010804080100"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050308030405010804080100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

I have got a problem using Linux with kernels newer than 2.6.30 on a IA64
system with an IDE hard drive.

Starting with version 2.6.30 the detection of the right IRQ for the IDE hard
drive has changed. Now on an IA64 system the IRQs 33 and 34 are used if the
system is in ide_pci_compatibility mode. In the versions before 2.6.30 the
IRQs were set by autoprobing in try_to_identify, a function indirectly called
from ide_pci_init_two. On my system the IRQ 50 was used. This value is also
used in ACPI table for the ide.

Now a function called pci_get_legacy_irq_device sets the IRQ to 34. But this
is not working on my system:
ide0: disabled, unable to get IRQ 34

Later in the boot process occurs a kernel panic, the output is:
VFS: Cannot open root device "hda2" or unknown-block(0,0)
Please append a correct "root=" boot option; here are the available partitions:
Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
(Find the complete output of the boot process attached to this mail.)

I have examined the function ide_pci_init_two and found out that the irq is
set by pci_get_legacy_irq_device. If I set the return value of this function
to the irq of the transferred structure of type pci_dev everything is working
fine, although I'm pretty sure that this is not a good solution.

Do you have any ideas that can help me?

Thanks in advance,
Stefan Klein


--------------050308030405010804080100
Content-Type: text/plain;
 name="output.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="output.txt"

[    0.000000] EFI v1.10 by INTEL: SALsystab=0xff1b0f70 ACPI 2.0=0xff1b8628 HCDP=0xff1b0e20 SMBIOS=0xff1b0e78
[    0.000000] booting generic kernel on platform dig
[    0.000000] PCDP: v1 at 0xff1b0e20
[    0.000000] No EFI ConOut variable?
[    0.000000] Early serial console at I/O port 0x3f8 (options '115200')
[    0.000000] bootconsole [uart8250] enabled
[    0.000000] ACPI: RSDP 00000000ff1b8628 00024 (v02  HOBVM)
[    0.000000] ACPI: XSDT 00000000ff1b864c 00034 (v01  HOBVM  HOBVM 1 00000001  HOB 00000001)
[    0.000000] ACPI: APIC 00000000ff1b8680 000FC (v01  HOBVM  HOBVM 1 00000001  HOB 00000001)
[    0.000000] ACPI: FACP 00000000ff1b877c 000F4 (v03  HOBVM  HOBVM 1 00000001  HOB 00000001)
[    0.000000] ACPI: DSDT 00000000ff1b88b0 000F2 (v02  HOBVM  HOBVM 1 00000001 INTL 20061109)
[    0.000000] ACPI: FACS 00000000ff1b8870 00040
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] 1 CPUs available, 16 CPUs total
[    0.000000] SAL 0.7: HOB VM version 0.2
[    0.000000] SAL Platform features: None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xfa
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] GSI 12 (level, low) -> CPU 0 (0x0000) vector 49
[    0.000000] Failed to register rendezvous interrupt with SAL (status -1)
[    0.000000] Virtual mem_map starts at 0xa07fffffffc80000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000100 -> 0x00010000
[    0.000000]   Normal   0x00010000 -> 0x00010000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000100 -> 0x00003fed
[    0.000000]     0: 0x00003ff4 -> 0x00004000
[    0.000000] pcpu-alloc: s32408 r8192 d24936 u65536 alloc=1*65536
[    0.000000] pcpu-alloc: [0] 0
[    0.000000] Built 1 zonelists in Node order, mobility grouping off.  Total pages: 16107
[    0.000000] Policy zone: DMA
[    0.000000] Kernel command line: BOOT_IMAGE=dev000:\efi\VMLINUX.GZ root=/dev/hda2 console=hcdp all_generic_ide=off irqpoll ro
[    0.000000] Misrouted IRQ fixup and polling support enabled
[    0.000000] This may significantly impact system performance
[    0.000000] PID hash table entries: 4096 (order: -1, 32768 bytes)
[    0.000000] Placing 64MB software IO TLB between e000000004d30000 - e000000008d30000
[    0.000000] software IO TLB at phys 0x4d30000 - 0x8d30000
[    0.000000] Memory: 948992k/1018112k available (7172k code, 82752k reserved, 4688k data, 1856k init)
[    0.000000] SLUB: Genslabs=18, HWalign=128, Order=0-3, MinObjects=0, CPUs=1, Nodes=1024
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU-based detection of stalled CPUs is enabled.
[    0.000000] NR_IRQS:768
[    0.000000] Console: colour dummy device 80x25
[    0.010000] Calibrating delay loop... 34.71 BogoMIPS (lpj=173568)
[    0.192553] Security Framework initialized
[    0.193561] Dentry cache hash table entries: 131072 (order: 4, 1048576 bytes)
[    0.224653] Inode-cache hash table entries: 65536 (order: 3, 524288 bytes)
[    0.239342] Mount-cache hash table entries: 4096
[    0.257512] ACPI: Core revision 20091214
[    0.266935] Boot processor id 0x0/0x0
[    0.267934] Brought up 1 CPUs
[    0.268188] Total of 1 processors activated (34.71 BogoMIPS).
[    0.315975] DMI 2.1 present.
[    0.322641] NET: Registered protocol family 16
[    0.329219] ACPI: bus type pci registered
[    0.427107] bio: create slab <bio-0> at 0
[    0.445644] ACPI: Interpreter enabled
[    0.445891] ACPI: (supports S0)
[    0.446273] ACPI: Using IOSAPIC for interrupt routing
[    0.472371] ACPI: No dock devices found.
[    0.473032] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.476484] pci 0000:00:02.0: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.497146] vgaarb: loaded
[    0.504033] SCSI subsystem initialized
[    0.514513] Switching to clocksource itc
[    0.515251] pnp: PnP ACPI init
[    0.515603] ACPI: bus type pnp registered
[    0.519008] GSI 4 (edge, high) -> CPU 0 (0x0000) vector 50
[    0.528323] pnp: PnP ACPI: found 1 devices
[    0.528609] ACPI: ACPI bus type pnp unregistered
[    0.543804] NET: Registered protocol family 2
[    0.548530] IP route cache hash table entries: 8192 (order: 0, 65536 bytes)
[    0.559868] TCP established hash table entries: 32768 (order: 3, 524288 bytes)
[    0.574819] TCP bind hash table entries: 32768 (order: 3, 524288 bytes)
[    0.592858] TCP: Hash tables configured (established 32768 bind 32768)
[    0.593267] TCP reno registered
[    0.593591] UDP hash table entries: 2048 (order: 0, 65536 bytes)
[    0.598355] UDP-Lite hash table entries: 2048 (order: 0, 65536 bytes)
[    0.603207] NET: Registered protocol family 1
[    0.603798] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.604227] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.604712] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.618517] PAL Information Facility v0.5
[    0.619200] Please use IA-32 EL for executing IA-32 binaries
[    0.627611] HugeTLB registered 256 MB page size, pre-allocated 0 pages
[    0.797567] msgmni has been set to 1852
[    0.813907] alg: No test for stdrng (krng)
[    1.734013] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    1.734665] io scheduler noop registered
[    1.734951] io scheduler deadline registered
[    1.739832] io scheduler cfq registered (default)
[    1.923203] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.938548] 00:00: ttyS0 at I/O 0x3f8 (irq = 50) is a 16450
[    1.992021] console [ttyS0] enabled
[    1.998467] Uniform Multi-Platform E-IDE driver
[    2.001212] piix 0000:00:03.0: IDE controller (0x8086:0x7010 rev 0x00)
[    2.002362] GSI 14 (level, low) -> CPU 0 (0x0000) vector 51
[    2.003118] pci 0000:00:03.0: PCI INT A -> GSI 14 (level, low) -> IRQ 51
[    2.004120] piix 0000:00:03.0: not 100% native mode: will probe irqs later
[    2.004954] IDE_PCI is in compatibility mode
[    2.007619]     ide0: BM-DMA at 0xc000-0xc007
[    2.008248]     ide1: BM-DMA at 0xc008-0xc00f
[    2.317460] hda: QEMU HARDDISK, ATA DISK drive
[    2.677187] hdb: QEMU HARDDISK, ATA DISK drive
[    2.679419] hda: MWDMA2 mode selected
[    2.680381] hdb: MWDMA2 mode selected
[    3.288469] ide0: disabled, unable to get IRQ 34
[    3.289065] ide0: failed to initialize IDE interface
[    3.289763] ide0: disabling port
[    3.290246] ide1: disabled, unable to get IRQ 33
[    3.290843] ide1: failed to initialize IDE interface
[    3.291541] ide1: disabling port
[    3.292300] piix 0000:00:03.0: IDE controller (0x8086:0x7010 rev 0x00)
[    3.293163] PIIX_IDE 0000:00:03.0: BAR 0: can't reserve [io  0x01f0-0x01f7]
[    3.294025] piix 0000:00:03.0: can't reserve resources
[    3.294744] PIIX_IDE: probe of 0000:00:03.0 failed with error -16
[    3.299621] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    3.300775] ide-gd driver 1.18
[    3.302101] ide-cd driver 5.00
[    3.317465] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    3.318224] e100: Copyright(c) 1999-2006 Intel Corporation
[    3.320231] Fusion MPT base driver 3.04.13
[    3.320758] Copyright (c) 1999-2008 LSI Corporation
[    3.321494] Fusion MPT SAS Host driver 3.04.13
[    3.328518] mice: PS/2 mouse device common for all mice
[    3.330586] NET: Registered protocol family 26
[    3.345145] IPv4 over IPv4 tunneling driver
[    3.361202] GRE over IPv4 tunneling driver
[    3.381012] TCP cubic registered
[    3.381441] Initializing XFRM netlink socket
[    3.382037] NET: Registered protocol family 17
[    3.382720] NET: Registered protocol family 15
[    3.383516] turn off boot console uart8250
[    3.393039] VFS: Cannot open root device "hda2" or unknown-block(0,0)
[    3.393594] Please append a correct "root=" boot option; here are the available partitions:
[    3.394329] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)


--------------050308030405010804080100--

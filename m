From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Tue, 31 Jul 2007 23:02:49 +0000
Subject: Re: "Add support for vector domain" breaks boot on x355
Message-Id: <20070731230249.GB31324@us.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731221356.GA31324@us.ibm.com> <617E1C2C70743745A92448908E030B2A020E40A6@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A020E40A6@scsmsx411.amr.corp.intel.com>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: isimatu.yasuaki@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com, torvalds@linux-foundation.org, ryhodges@us.ibm.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 31.07.2007 [15:38:39 -0700], Luck, Tony wrote:
> > The following commit (4994be1b3fe9120c88022ff5c0c33f6312b17adb) broke
> > Linus' Tree between 2.6.22-git15 and 2.6.22-git16 on a 2-node 8-way x455
> > (Madison procs). Thanks to Ryan Hodges for bisecting down to this
> > commit.
> 
> Thanks for taking the time to do the git bisect to identify the
> problem commit.

Not a problem. (As a side note, Ryan is an intern on our team who worked
out automatic git bisection for the harness that serves test.kernel.org
currently, so hopefully we'll be able to get these kind of outputs
quicker and regularly).

> Can you give some more details on the breakage please?  Does the
> system hang or panic?  How far does it get through the boot process?
> Are there any suspicious looking differences in the console output
> before getting to the failure point?

Hangs hard after

ELILO boot: Uncompressing Linux...done
Loading file
\EFI\debian\boot\initrd-autobench.img...done

So not far, presumably. Well to be fair, I'm assuming it's hung hard,
it's all automatic; it did sit there for at least 5 minutes after these
(looking at timestamps). So I don't have much output to give :(

In case it helps, given this is a IRQ thing, here is the demsg from a
working boot. .config is attached as well, in case it helps.

Thanks,
Nish

[    0.000000] Linux version 2.6.22-autokern1 (root@elm3a170) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 SMP Tue Jul 31 10:47:58 PDT 2007
[    0.000000] EFI v1.10 by INTEL: SALsystab=0x1eec2000 ACPI 2.0=0xf1100 SMBIOS=0xf1000
[    0.000000] booting generic kernel on platform dig
[    0.000000] ACPI: RSDP 000F1100, 0024 (r2 IBM   )
[    0.000000] ACPI: XSDT 1EF00050, 0064 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: APIC 1EF000C0, 02A8 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: SRAT 1EF00370, 0240 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: OEM0 1EF005B0, 00A0 (r1 IBM    RIOTABLE        3 IBM         1)
[    0.000000] ACPI: FACP 1EF006E0, 00F4 (r3 IBM    SERMOW          3 IBM         1)
[    0.000000] ACPI: DSDT 1EF00850, 8E0E (r32 IBM    SERMOWC0      100 INTL  2002041)
[    0.000000] ACPI: FACS 1EF1FD80, 0040
[    0.000000] ACPI: DBGP 1EF007E0, 0034 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: IPPT 1EF00820, 0028 (r1 IBM    SERMOW          3 IBM         1)
[    0.000000] ACPI: SSDT 1EF09660, 66B9 (r32 IBM    SERMOWC1      100 INTL  2002041)
[    0.000000] ACPI: SSDT 1EF0FD20, 10038 (r32 IBM    SERMOWVR        1 MSFT  100000E)
[    0.000000] Number of logical nodes in system = 2
[    0.000000] Number of memory chunks in system = 10
[    0.000000] Initial ramdisk at: 0xe00000001adc8000 (1851392 bytes)
[    0.000000] SAL 3.0:  IBM                              x455 (8688-xxx)                 version 3.0
[    0.000000] SAL Platform features: None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] No logical to physical processor mapping available
[    0.000000] iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] ACPI: [APIC:0x07] ignored 8 entries of 16 found
[    0.000000] PLATFORM int INIT (0x2): GSI 44 (edge, low) -> CPU 0 (0x0000) vector 48
[    0.000000] PLATFORM int PMI (0x1): GSI 46 (edge, low) -> CPU 0 (0x0000) vector 3
[    0.000000] PLATFORM int INIT (0x2): GSI 91 (edge, low) -> CPU 0 (0x0000) vector 49
[    0.000000] PLATFORM int INIT (0x2): GSI 92 (edge, low) -> CPU 0 (0x0000) vector 50
[    0.000000] PLATFORM int INIT (0x2): GSI 93 (edge, low) -> CPU 0 (0x0000) vector 51
[    0.000000] PLATFORM int INIT (0x2): GSI 94 (edge, low) -> CPU 0 (0x0000) vector 52
[    0.000000] PLATFORM int INIT (0x2): GSI 95 (edge, low) -> CPU 0 (0x0000) vector 53
[    0.000000] PLATFORM int INIT (0x2): GSI 96 (edge, low) -> CPU 0 (0x0000) vector 54
[    0.000000] PLATFORM int INIT (0x2): GSI 97 (edge, low) -> CPU 0 (0x0000) vector 55
[    0.000000] PLATFORM int INIT (0x2): GSI 98 (edge, low) -> CPU 0 (0x0000) vector 56
[    0.000000] Reassigning vector 3 to 57
[    0.000000] PLATFORM int PMI (0x1): GSI 136 (edge, low) -> CPU 8 (0x1000) vector 3
[    0.000000] PLATFORM int INIT (0x2): GSI 146 (edge, low) -> CPU 8 (0x1000) vector 58
[    0.000000] Reassigning vector 3 to 59
[    0.000000] PLATFORM int PMI (0x1): GSI 148 (edge, low) -> CPU 8 (0x1000) vector 3
[    0.000000] PLATFORM int INIT (0x2): GSI 193 (edge, low) -> CPU 8 (0x1000) vector 60
[    0.000000] PLATFORM int INIT (0x2): GSI 194 (edge, low) -> CPU 8 (0x1000) vector 61
[    0.000000] PLATFORM int INIT (0x2): GSI 195 (edge, low) -> CPU 8 (0x1000) vector 62
[    0.000000] PLATFORM int INIT (0x2): GSI 196 (edge, low) -> CPU 8 (0x1000) vector 63
[    0.000000] PLATFORM int INIT (0x2): GSI 197 (edge, low) -> CPU 8 (0x1000) vector 64
[    0.000000] PLATFORM int INIT (0x2): GSI 198 (edge, low) -> CPU 8 (0x1000) vector 65
[    0.000000] PLATFORM int INIT (0x2): GSI 199 (edge, low) -> CPU 8 (0x1000) vector 66
[    0.000000] PLATFORM int INIT (0x2): GSI 200 (edge, low) -> CPU 8 (0x1000) vector 67
[    0.000000] PLATFORM int CPEI (0x3): GSI 19 (edge, low) -> CPU 0 (0x0000) vector 30
[    0.000000] register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
[    0.000000] register_intr: changing vector 37 from IO-SAPIC-edge to IO-SAPIC-level
[    0.000000] 8 CPUs available, 8 CPUs total
[    0.000000] MCA related initialization done
[    0.000000] Virtual mem_map starts at 0xa0007fffef600000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA          1024 ->   262144
[    0.000000]   Normal     262144 ->  4980736
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0:     1024 ->    28548
[    0.000000]     0:    28576 ->    28631
[    0.000000]     0:    28672 ->    30720
[    0.000000]     0:    32768 ->   131072
[    0.000000]     0:   262144 ->  1703936
[    0.000000]     1:  4194304 ->  4980736
[    0.000000] Built 2 zonelists in Zone order.  Total pages: 2347647
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-autobench root=/dev/sda2 console=tty0 console=ttyS0,115200n8 ro autobench_args: root=/dev/sda2 ABAT:1185904095
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.822306] Console: colour VGA+ 80x25
[    0.822314] console [tty0] enabled
[    0.887043] Placing software IO TLB between 0x4d80000 - 0x8d80000
[    2.336853] Memory: 37485760k/37682784k available (7597k code, 212720k reserved, 4353k data, 1904k init)
[    2.337164] McKinley Errata 9 workaround not needed; disabling it
[    2.447116] Dentry cache hash table entries: 8388608 (order: 12, 67108864 bytes)
[    2.646633] Inode-cache hash table entries: 4194304 (order: 11, 33554432 bytes)
[    2.746128] Mount-cache hash table entries: 1024
[    2.747236] ACPI: Core revision 20070126
[    2.757087] Boot processor id 0x0/0x0
[    2.795173] Brought up 8 CPUs
[    2.795290] Total of 8 processors activated (19136.51 BogoMIPS).
[    2.797732] DMI 2.3 present.
[    2.798477] NET: Registered protocol family 16
[    2.798933] ACPI: bus type pci registered
[    3.948061] ACPI: Interpreter enabled
[    3.948178] ACPI: Using IOSAPIC for interrupt routing
[    3.966687] ACPI: PCI Root Bridge [P000] (0000:00)
[    3.972730] PCI quirk: region 0440-044f claimed by vt82c686 SMB
[    3.974483] ACPI: PCI Root Bridge [P001] (0000:01)
[    3.979383] ACPI: PCI Root Bridge [P002] (0000:02)
[    3.984068] ACPI: PCI Root Bridge [P010] (0000:05)
[    3.988658] ACPI: PCI Root Bridge [P011] (0000:07)
[    3.993138] ACPI: PCI Root Bridge [P012] (0000:09)
[    3.997777] ACPI: PCI Root Bridge [P100] (0000:40)
[    4.002952] PCI quirk: region 8440-844f claimed by vt82c686 SMB
[    4.003852] ACPI: PCI Root Bridge [P101] (0000:41)
[    4.009036] ACPI: PCI Root Bridge [P102] (0000:42)
[    4.013696] ACPI: PCI Root Bridge [P110] (0000:45)
[    4.018362] ACPI: PCI Root Bridge [P111] (0000:47)
[    4.022878] ACPI: PCI Root Bridge [P112] (0000:49)
[    4.027654] ACPI: PCI Interrupt Link [IDI0] (IRQs *14)
[    4.027929] ACPI: PCI Interrupt Link [IDI1] (IRQs *116)
[    4.028226] Linux Plug and Play Support v0.97 (c) Adam Belay
[    4.028396] pnp: PnP ACPI init
[    4.028521] ACPI: bus type pnp registered
[    4.052762] pnp: PnP ACPI: found 17 devices
[    4.052881] ACPI: ACPI bus type pnp unregistered
[    4.053897] SCSI subsystem initialized
[    4.054199] usbcore: registered new interface driver usbfs
[    4.054420] usbcore: registered new interface driver hub
[    4.054619] usbcore: registered new device driver usb
[    4.055845] pnp: 00:00: iomem range 0x80000000-0x82400000 could not be reserved
[    4.056068] pnp: 00:00: iomem range 0xfeb00000-0xfebfffff has been reserved
[    4.056202] pnp: 00:00: iomem range 0xfec00000-0xfeffffff has been reserved
[    4.056335] pnp: 00:00: iomem range 0xfff00000-0xffffffff has been reserved
[    4.056485] pnp: 00:0a: iomem range 0xa0000000-0xbfffffff could not be reserved
[    4.058529] NET: Registered protocol family 2
[    4.108720] IP route cache hash table entries: 2097152 (order: 10, 16777216 bytes)
[    4.135977] TCP established hash table entries: 8388608 (order: 13, 201326592 bytes)
[    5.292129] TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
[    5.298865] TCP: Hash tables configured (established 8388608 bind 65536)
[    5.299000] TCP reno registered
[    5.308319] checking if image is initramfs...it isn't (bad gzip magic numbers); looks like an initrd
[    5.312058] Freeing initrd memory: 1808kB freed
[    5.312233] perfmon: version 2.0 IRQ 238
[    5.312368] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
[    2.524596] perfmon: added sampling format default_format
[    2.524832] perfmon_default_smpl: default_format v2.0 registered
[    2.525040] Summit chipset: Starting Cyclone Counter.
[    2.550499] Total HugeTLB memory allocated, 0
[    2.554941] block layer sg (bsg) 0.4 loaded
[    2.555140] io scheduler noop registered
[    2.555329] io scheduler anticipatory registered
[    2.555521] io scheduler deadline registered
[    2.555916] io scheduler cfq registered (default)
[    2.556807] input: Power Button (FF) as /class/input/input0
[    2.557009] ACPI: Power Button (FF) [PWRF]
[    2.643910] mspec 4.0 initialized devices:  Cached, Uncached
[    2.644115] EFI Time Services Driver v0.4
[    2.644476] Serial: 8250/16550 driver $Revision: 1.90 $ 6 ports, IRQ sharing enabled
[    2.646817] 00:04: ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
[    2.647250] console [ttyS0] enabled
[    3.513204] RAMDISK driver initialized: 16 RAM disks of 32768K size 1024 blocksize
[    3.522570] loop: module loaded
[    3.526273] tg3.c:v3.78 (July 11, 2007)
[    3.530495] GSI 42 (level, low) -> CPU 0 (0x0000) vector 68
[    3.536271] ACPI: PCI Interrupt 0000:01:04.0[A] -> GSI 42 (level, low) -> IRQ 68
[    3.711564] eth0: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:1f:80:b0
[    3.723892] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    3.731723] eth0: dma_rwctrl[769f0000] dma_mask[64-bit]
[    3.737221] ACPI: PCI Interrupt 0000:01:04.1[B] -> GSI 11 (level, low) -> IRQ 37
[    4.016923] eth1: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:9f:80:b0
[    4.029244] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    4.037078] eth1: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.042597] GSI 144 (level, low) -> CPU 1 (0x0200) vector 69
[    4.048461] ACPI: PCI Interrupt 0000:41:04.0[A] -> GSI 144 (level, low) -> IRQ 69
[    4.230512] eth2: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:1f:80:e2
[    4.242834] eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    4.250665] eth2: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.256166] GSI 113 (level, low) -> CPU 2 (0x0400) vector 70
[    4.262035] ACPI: PCI Interrupt 0000:41:04.1[B] -> GSI 113 (level, low) -> IRQ 70
[    4.535119] eth3: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:9f:80:e2
[    4.547450] eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    4.555282] eth3: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.560988] netconsole: not configured, aborting
[    4.565816] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[    4.572380] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[    4.580912] VP_IDE: IDE controller at PCI slot 0000:00:05.1
[    4.586748] VP_IDE: chipset revision 6
[    4.590686] VP_IDE: not 100% native mode: will probe irqs later
[    4.596851] VP_IDE: VIA vt82c686b (rev 40) IDE UDMA100 controller on pci0000:00:05.1
[    4.604976]     ide0: BM-DMA at 0x0700-0x0707, BIOS settings: hda:DMA, hdb:DMA
[    5.143919] hda: HL-DT-STDVD-ROM GDR8081N, ATAPI CD/DVD-ROM drive
[    5.835012] ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
[   10.338663] hda: ATAPI 24X DVD-ROM drive, 512kB Cache, UDMA(33)
[   10.344980] Uniform CD-ROM driver Revision: 3.20
[   10.361283] Fusion MPT base driver 3.04.05
[   10.365506] Copyright (c) 1999-2007 LSI Logic Corporation
[   10.371042] Fusion MPT SPI Host driver 3.04.05
[   10.376021] GSI 40 (level, low) -> CPU 3 (0x0600) vector 71
[   10.381730] ACPI: PCI Interrupt 0000:01:03.0[A] -> GSI 40 (level, low) -> IRQ 71
[   10.389416] mptbase: Initiating ioc0 bringup
[   10.871742] ioc0: 53C1030: Capabilities={Initiator}
[   11.553182] scsi0 : ioc0: LSI53C1030, FwRev=01032821h, Ports=1, MaxQ=222, IRQ=71
[   12.988727] scsi 0:0:0:0: Direct-Access     IBM-ESXS DTN018C1UCDY10F  S25J PQ: 0 ANSI: 3
[   12.997062]  target0:0:0: Beginning Domain Validation
[   13.014720]  target0:0:0: Ending Domain Validation
[   13.019708]  target0:0:0: FAST-80 WIDE SCSI 160.0 MB/s DT (12.5 ns, offset 127)
[   13.028241] sd 0:0:0:0: [sda] 35548320 512-byte hardware sectors (18201 MB)
[   13.036119] sd 0:0:0:0: [sda] Write Protect is off
[   13.042005] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   13.052101] sd 0:0:0:0: [sda] 35548320 512-byte hardware sectors (18201 MB)
[   13.059982] sd 0:0:0:0: [sda] Write Protect is off
[   13.065866] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   13.075231]  sda: sda1 sda2
[   13.110155] sd 0:0:0:0: [sda] Attached SCSI disk
[   13.115181] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   14.623318] scsi 0:0:8:0: Processor         IBM      25P3495a S320  1 1    PQ: 0 ANSI: 2
[   14.631638]  target0:0:8: Beginning Domain Validation
[   14.637432]  target0:0:8: Ending Domain Validation
[   14.642415]  target0:0:8: asynchronous
[   14.646853] scsi 0:0:8:0: Attached scsi generic sg1 type 3
[   16.407990] GSI 41 (level, low) -> CPU 4 (0x1000) vector 72
[   16.413695] ACPI: PCI Interrupt 0000:01:03.1[B] -> GSI 41 (level, low) -> IRQ 72
[   16.421366] mptbase: Initiating ioc1 bringup
[   16.903740] ioc1: 53C1030: Capabilities={Initiator}
[   14.803474] scsi1 : ioc1: LSI53C1030, FwRev=01032821h, Ports=1, MaxQ=222, IRQ=72
[   20.000539] GSI 142 (level, low) -> CPU 5 (0x1200) vector 73
[   20.006411] ACPI: PCI Interrupt 0000:41:03.0[A] -> GSI 142 (level, low) -> IRQ 73
[   20.014308] mptbase: Initiating ioc2 bringup
[   20.498551] ioc2: 53C1030: Capabilities={Initiator}
[   21.179847] scsi2 : ioc2: LSI53C1030, FwRev=01032821h, Ports=1, MaxQ=222, IRQ=73
[   24.367805] scsi 2:0:8:0: Processor         IBM      25P3495a S320  1 1    PQ: 0 ANSI: 2
[   24.376268]  target2:0:8: Beginning Domain Validation
[   24.382141]  target2:0:8: Ending Domain Validation
[   24.387209]  target2:0:8: asynchronous
[   24.391691] scsi 2:0:8:0: Attached scsi generic sg2 type 3
[   26.153774] GSI 143 (level, low) -> CPU 6 (0x1400) vector 74
[   26.159645] ACPI: PCI Interrupt 0000:41:03.1[B] -> GSI 143 (level, low) -> IRQ 74
[   26.167539] mptbase: Initiating ioc3 bringup
[   26.650546] ioc3: 53C1030: Capabilities={Initiator}
[   27.339824] scsi3 : ioc3: LSI53C1030, FwRev=01032821h, Ports=1, MaxQ=222, IRQ=74
[   32.533598] USB Universal Host Controller Interface driver v3.0
[   32.540109] PCI: Enabling device 0000:00:05.2 (0000 -> 0001)
[   32.545990] GSI 18 (level, low) -> CPU 7 (0x1600) vector 75
[   32.551769] ACPI: PCI Interrupt 0000:00:05.2[D] -> GSI 18 (level, low) -> IRQ 75
[   32.559581] uhci_hcd 0000:00:05.2: UHCI Host Controller
[   32.565251] uhci_hcd 0000:00:05.2: new USB bus registered, assigned bus number 1
[   32.573047] uhci_hcd 0000:00:05.2: irq 75, io base 0x00000800
[   32.579543] usb usb1: configuration #1 chosen from 1 choice
[   32.585511] hub 1-0:1.0: USB hub found
[   32.589479] hub 1-0:1.0: 2 ports detected
[   32.695041] PCI: Enabling device 0000:00:05.3 (0000 -> 0001)
[   32.700917] ACPI: PCI Interrupt 0000:00:05.3[D] -> GSI 18 (level, low) -> IRQ 75
[   32.708715] uhci_hcd 0000:00:05.3: UHCI Host Controller
[   32.714330] uhci_hcd 0000:00:05.3: new USB bus registered, assigned bus number 2
[   32.722116] uhci_hcd 0000:00:05.3: irq 75, io base 0x00000820
[   32.728529] usb usb2: configuration #1 chosen from 1 choice
[   32.734446] hub 2-0:1.0: USB hub found
[   32.738402] hub 2-0:1.0: 2 ports detected
[   32.846986] PCI: Enabling device 0000:40:05.2 (0000 -> 0001)
[   32.852870] GSI 120 (level, low) -> CPU 0 (0x0000) vector 76
[   32.858731] ACPI: PCI Interrupt 0000:40:05.2[D] -> GSI 120 (level, low) -> IRQ 76
[   32.866624] uhci_hcd 0000:40:05.2: UHCI Host Controller
[   32.872182] uhci_hcd 0000:40:05.2: new USB bus registered, assigned bus number 3
[   32.879968] uhci_hcd 0000:40:05.2: irq 76, io base 0x00008840
[   32.886237] usb usb3: configuration #1 chosen from 1 choice
[   32.892181] hub 3-0:1.0: USB hub found
[   32.896153] hub 3-0:1.0: 2 ports detected
[   33.002976] PCI: Enabling device 0000:40:05.3 (0000 -> 0001)
[   33.008846] ACPI: PCI Interrupt 0000:40:05.3[D] -> GSI 120 (level, low) -> IRQ 76
[   33.016732] uhci_hcd 0000:40:05.3: UHCI Host Controller
[   33.022348] uhci_hcd 0000:40:05.3: new USB bus registered, assigned bus number 4
[   33.030121] uhci_hcd 0000:40:05.3: irq 76, io base 0x00008860
[   33.036531] usb usb4: configuration #1 chosen from 1 choice
[   33.042449] hub 4-0:1.0: USB hub found
[   33.046403] hub 4-0:1.0: 2 ports detected
[   33.154937] Initializing USB Mass Storage driver...
[   35.979754] usb 2-1: new full speed USB device using uhci_hcd and address 2
[   33.374412] usb 2-1: configuration #1 chosen from 1 choice
[   33.386261] hub 2-1:1.0: USB hub found
[   33.392175] hub 2-1:1.0: 3 ports detected
[   34.348161] usb 2-1.1: new full speed USB device using uhci_hcd and address 3
[   34.495509] usb 2-1.1: configuration #1 chosen from 1 choice
[   34.712158] usb 2-1.3: new low speed USB device using uhci_hcd and address 4
[   34.857465] usb 2-1.3: configuration #1 chosen from 1 choice
[   34.866670] usbcore: registered new interface driver usb-storage
[   34.872900] USB Mass Storage support registered.
[   34.878285] mice: PS/2 mouse device common for all mice
[   34.884404] i2c /dev entries driver
[   34.888840] vt596_smbus 0000:00:05.4: SMBUS: Error: Host SMBus controller not enabled! - upgrade BIOS or use force=1
[   34.899774] vt596_smbus 0000:40:05.4: SMBUS: Error: Host SMBus controller not enabled! - upgrade BIOS or use force=1
[   34.910868] via686a 0000:00:05.4: base address not set - upgrade BIOS or use force_addr=0xaddr
[   34.919850] via686a 0000:40:05.4: base address not set - upgrade BIOS or use force_addr=0xaddr
[   34.928832] EFI Variables Facility v0.08 2004-May-17
[   34.938782] usbcore: registered new interface driver hiddev
[   34.947592] input: Silitek IBM USB HUB KEYBOARD as /class/input/input1
[   34.954857] input: USB HID v1.10 Keyboard [Silitek IBM USB HUB KEYBOARD] on usb-0000:00:05.3-1.1
[   34.980435] input: Logitech Optical USB Mouse as /class/input/input2
[   34.987371] input: USB HID v1.10 Mouse [Logitech Optical USB Mouse] on usb-0000:00:05.3-1.3
[   34.996194] usbcore: registered new interface driver usbhid
[   35.001975] drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
[   35.008463] perfmon: added sampling format oprofile_format
[   35.014157] oprofile: using perfmon.
[   35.018008] TCP cubic registered
[   35.021534] NET: Registered protocol family 1
[   35.026093] NET: Registered protocol family 17
[   35.032624] RAMDISK: cramfs filesystem found at block 0
[   35.038068] RAMDISK: Loading 1808KiB [1 disk] into ram disk... |/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|done.
[   35.077274] VFS: Mounted root (cramfs filesystem) readonly.
[   35.132801] Freeing unused kernel memory: 1904kB freed

...

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elm3a170.config"

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.22-autokern1
# Tue Jul 31 10:46:16 2007
#
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# Code maturity level options
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32

#
# General setup
#
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
# CONFIG_TASKSTATS is not set
# CONFIG_USER_NS is not set
# CONFIG_AUDIT is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_CPUSETS=y
CONFIG_SYSFS_DEPRECATED=y
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
# CONFIG_EMBEDDED is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_RT_MUTEXES=y
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_KMOD=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_BLK_DEV_BSG=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"

#
# Processor type and features
#
CONFIG_IA64=y
CONFIG_64BIT=y
CONFIG_ZONE_DMA=y
CONFIG_QUICKLIST=y
CONFIG_MMU=y
CONFIG_SWIOTLB=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_TIME_INTERPOLATION=y
CONFIG_DMI=y
CONFIG_EFI=y
CONFIG_GENERIC_IOMAP=y
CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
CONFIG_IA64_UNCACHED_ALLOCATOR=y
CONFIG_AUDIT_ARCH=y
CONFIG_IA64_GENERIC=y
# CONFIG_IA64_DIG is not set
# CONFIG_IA64_HP_ZX1 is not set
# CONFIG_IA64_HP_ZX1_SWIOTLB is not set
# CONFIG_IA64_SGI_SN2 is not set
# CONFIG_IA64_HP_SIM is not set
# CONFIG_ITANIUM is not set
CONFIG_MCKINLEY=y
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
CONFIG_IA64_PAGE_SIZE_16KB=y
# CONFIG_IA64_PAGE_SIZE_64KB is not set
CONFIG_PGTABLE_3=y
# CONFIG_PGTABLE_4 is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_IA64_L1_CACHE_SHIFT=7
CONFIG_IA64_CYCLONE=y
CONFIG_IOSAPIC=y
# CONFIG_IA64_SGI_SN_XP is not set
CONFIG_FORCE_MAX_ZONEORDER=17
CONFIG_SMP=y
CONFIG_NR_CPUS=8
# CONFIG_HOTPLUG_CPU is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
# CONFIG_SCHED_SMT is not set
# CONFIG_PREEMPT is not set
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_DISCONTIGMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_DISCONTIGMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_NEED_MULTIPLE_NODES=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MIGRATION=y
CONFIG_RESOURCES_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_NR_QUICK=1
CONFIG_VIRT_TO_BUS=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
CONFIG_NUMA=y
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_VIRTUAL_MEM_MAP=y
CONFIG_HOLES_IN_ZONE=y
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
CONFIG_HAVE_ARCH_NODEDATA_EXTENSION=y
CONFIG_IA32_SUPPORT=y
CONFIG_COMPAT=y
# CONFIG_IA64_MCA_RECOVERY is not set
CONFIG_PERFMON=y
# CONFIG_IA64_PALINFO is not set
# CONFIG_IA64_MC_ERR_INJECT is not set
CONFIG_SGI_SN=y
# CONFIG_IA64_ESI is not set

#
# SN Devices
#
# CONFIG_SGI_IOC3 is not set

#
# Firmware Drivers
#
CONFIG_EFI_VARS=y
CONFIG_EFI_PCDP=y
CONFIG_DMIID=y
CONFIG_BINFMT_ELF=y
# CONFIG_BINFMT_MISC is not set

#
# Power management and ACPI
#
CONFIG_PM=y
# CONFIG_PM_LEGACY is not set
# CONFIG_PM_DEBUG is not set
# CONFIG_PM_SYSFS_DEPRECATED is not set

#
# ACPI (Advanced Configuration and Power Interface) Support
#
CONFIG_ACPI=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
CONFIG_ACPI_CONTAINER=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# Bus options (PCI, PCMCIA)
#
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_SYSCALL=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_HOTPLUG_PCI is not set

#
# PCCARD (PCMCIA/CardBus) support
#
# CONFIG_PCCARD is not set

#
# Networking
#
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_MMAP is not set
CONFIG_UNIX=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set

#
# QoS and/or fair queueing
#
# CONFIG_NET_SCHED is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_TCPPROBE is not set
# CONFIG_HAMRADIO is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set

#
# Wireless
#
# CONFIG_CFG80211 is not set
# CONFIG_WIRELESS_EXT is not set
# CONFIG_MAC80211 is not set
# CONFIG_IEEE80211 is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=32768
CONFIG_BLK_DEV_RAM_BLOCKSIZE=1024
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
# CONFIG_ATA_OVER_ETH is not set
CONFIG_MISC_DEVICES=y
# CONFIG_PHANTOM is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_IDE=y
CONFIG_IDE_MAX_HWIFS=4
CONFIG_BLK_DEV_IDE=y

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_BLK_DEV_IDEDISK is not set
# CONFIG_IDEDISK_MULTI_MODE is not set
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEFLOPPY is not set
# CONFIG_BLK_DEV_IDESCSI is not set
CONFIG_BLK_DEV_IDEACPI=y
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_OPTI621 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
# CONFIG_IDEDMA_ONLYDISK is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
CONFIG_BLK_DEV_VIA82CXXX=y
# CONFIG_BLK_DEV_TC86C001 is not set
# CONFIG_IDE_ARM is not set
CONFIG_BLK_DEV_IDEDMA=y
# CONFIG_IDEDMA_IVB is not set
# CONFIG_BLK_DEV_HD is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set

#
# SCSI low-level drivers
#
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_ATA is not set

#
# Multi-device support (RAID and LVM)
#
# CONFIG_MD is not set

#
# Fusion MPT device support
#
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
# CONFIG_FUSION_FC is not set
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_CTL is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
CONFIG_NETDEVICES=y
# CONFIG_NETDEVICES_MULTIQUEUE is not set
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_TIGON3=y
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
CONFIG_NETDEV_10000=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_IXGB is not set
# CONFIG_S2IO is not set
# CONFIG_MYRI10GE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET_MII is not set
# CONFIG_USB_USBNET is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_SHAPER is not set
CONFIG_NETCONSOLE=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y

#
# ISDN subsystem
#
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_TSDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_COMPUTONE is not set
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_DIGIEPCA is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_MOXA_SMARTIO_NEW is not set
# CONFIG_ISI is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_N_HDLC is not set
# CONFIG_SPECIALIX is not set
# CONFIG_SX is not set
# CONFIG_RIO is not set
# CONFIG_STALDRV is not set
# CONFIG_SGI_SNSC is not set
# CONFIG_SGI_TIOCX is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=6
CONFIG_SERIAL_8250_RUNTIME_UARTS=6
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_SGI_L1_CONSOLE is not set
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_IPMI_HANDLER is not set
# CONFIG_WATCHDOG is not set
# CONFIG_HW_RANDOM is not set
CONFIG_EFI_RTC=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_AGP is not set
# CONFIG_DRM is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_MMTIMER is not set
# CONFIG_TCG_TPM is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_CHARDEV=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
# CONFIG_I2C_ALGOPCA is not set

#
# I2C Hardware Bus support
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_I810 is not set
# CONFIG_I2C_PIIX4 is not set
CONFIG_I2C_ISA=y
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_PROSAVAGE is not set
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_TINY_USB is not set
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y
# CONFIG_I2C_VOODOO3 is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_SENSORS_DS1337 is not set
# CONFIG_SENSORS_DS1374 is not set
# CONFIG_DS1682 is not set
# CONFIG_SENSORS_EEPROM is not set
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_SENSORS_PCA9539 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set

#
# SPI support
#
# CONFIG_SPI is not set
# CONFIG_SPI_MASTER is not set
# CONFIG_W1 is not set
# CONFIG_POWER_SUPPLY is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_SM501 is not set

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_DVB_CORE is not set
CONFIG_DAB=y
# CONFIG_USB_DABUSB is not set

#
# Graphics support
#
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set
# CONFIG_VGASTATE is not set
# CONFIG_FB is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y

#
# Sound
#
# CONFIG_SOUND is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
# CONFIG_HID_DEBUG is not set

#
# USB Input Devices
#
CONFIG_USB_HID=y
# CONFIG_USB_HIDINPUT_POWERBOOK is not set
# CONFIG_HID_FF is not set
CONFIG_USB_HIDDEV=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
CONFIG_USB_DEVICE_CLASS=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_PERSIST is not set
# CONFIG_USB_OTG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_DPCM is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_MON is not set

#
# USB port drivers
#

#
# USB Serial Converter support
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set

#
# USB DSL modem support
#

#
# USB Gadget Support
#
# CONFIG_USB_GADGET is not set
# CONFIG_MMC is not set

#
# LED devices
#
# CONFIG_NEW_LEDS is not set

#
# LED drivers
#

#
# LED Triggers
#
# CONFIG_INFINIBAND is not set

#
# Real Time Clock
#
# CONFIG_RTC_CLASS is not set

#
# DMA Engine support
#
# CONFIG_DMA_ENGINE is not set

#
# DMA Clients
#

#
# DMA Devices
#
CONFIG_MSPEC=y

#
# File systems
#
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_MINIX_FS is not set
CONFIG_ROMFS_FS=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_QUOTA is not set
CONFIG_DNOTIFY=y
# CONFIG_AUTOFS_FS is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_RAMFS=y
# CONFIG_CONFIGFS_FS is not set

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
CONFIG_CRAMFS=y
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
CONFIG_NFS_DIRECTIO=y
# CONFIG_NFSD is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
# CONFIG_SUNRPC_BIND34 is not set
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_RPCSEC_GSS_SPKM3 is not set
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set

#
# Native Language Support
#
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
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
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=y

#
# Distributed Lock Manager
#
# CONFIG_DLM is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_CRC_CCITT is not set
# CONFIG_CRC16 is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
CONFIG_LIBCRC32C=y
CONFIG_ZLIB_INFLATE=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_PER_CPU=y

#
# HP Simulator drivers
#
# CONFIG_HP_SIMETH is not set
# CONFIG_HP_SIMSERIAL is not set
# CONFIG_HP_SIMSCSI is not set

#
# Instrumentation Support
#
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
CONFIG_KPROBES=y

#
# Kernel hacking
#
CONFIG_PRINTK_TIME=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_DETECT_SOFTLOCKUP=y
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_LIST is not set
CONFIG_FORCED_INLINING=y
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_IA64_GRANULE_16MB=y
# CONFIG_IA64_GRANULE_64MB is not set
CONFIG_IA64_PRINT_HAZARDS=y
# CONFIG_DISABLE_VHPT is not set
# CONFIG_IA64_DEBUG_CMPXCHG is not set
# CONFIG_IA64_DEBUG_IRQ is not set
CONFIG_SYSVIPC_COMPAT=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
CONFIG_CRYPTO=y
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_GF128MUL is not set
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_BLOWFISH=y
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_SERPENT is not set
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_DEFLATE is not set
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_CRC32C is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_HW=y

--PNTmBPCT7hxwcZjr--

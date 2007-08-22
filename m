From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Date: Wed, 22 Aug 2007 18:43:56 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory
Message-Id: <46CC811C.9010600@linux.vnet.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000600050809070101020203"
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com> <20070822091959.aa38fd3e.akpm@linux-foundation.org> <20070822172541.GA8058@bingen.suse.de>
In-Reply-To: <20070822172541.GA8058@bingen.suse.de>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

This is a multi-part message in MIME format.
--------------000600050809070101020203
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andi Kleen wrote:
>>> [   20.880366] DMA: Out of SW-IOMMU space for 263200 bytes at device ?
>>> [   20.886858] Kernel panic - not syncing: DMA: Memory would be corrupted
>>>       
>> Gad, never seen that before.  Andi, Tony: help?
>>     
>
> Either the driver is leaking or more likely something went 
> wrong with the swiotlb initialization. Earlier boot messages
> might tell
>
> -Andi
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>   
Attached the boot log and config file.

Thanks & Regards,
Kamalesh Babulal.

--------------000600050809070101020203
Content-Type: text/plain;
 name="boot_log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="boot_log"

Loading.: Debian GNU/Linux
Starting: Debian GNU/Linux

ELILO boot: Uncompressing Linux... done
Loading file \EFI\debian\boot\initrd-autobench.img... done
[    0.000000] Linux version 2.6.23-rc3-mm1-autokern1 (root@elm3a170) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 SMP Wed Aug 22 06:26:17 PDT 2007
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
[    0.000000] Initial ramdisk at: 0xe00000001adc6000 (1851392 bytes)
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
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0:     1024 ->    28548
[    0.000000]     0:    28576 ->    28631
[    0.000000]     0:    28672 ->    30720
[    0.000000]     0:    32768 ->   131072
[    0.000000]     0:   262144 ->  1703936
[    0.000000]     1:  4194304 ->  4980736
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 1563903
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-autobench root=/dev/sda2 console=tty0 console=ttyS0,115200n8 ro autobench_args: root=/dev/sda2 ABAT:1187789212 profile=2
[    0.000000] kernel profiling enabled (shift: 2)
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.959777] Console: colour VGA+ 80x25
[    0.959787] console [tty0] enabled
[    1.024972] Placing software IO TLB between 0x4f98000 - 0x8f98000
[    2.529799] Memory: 37474000k/37680640k available (9309k code, 224480k reserved, 4677k data, 1936k init)
[    2.530141] McKinley Errata 9 workaround not needed; disabling it
[    2.640958] Dentry cache hash table entries: 8388608 (order: 12, 67108864 bytes)
[    2.840232] Inode-cache hash table entries: 4194304 (order: 11, 33554432 bytes)
[    2.939862] Mount-cache hash table entries: 1024
[    2.941015] ACPI: Core revision 20070126
[    2.950892] Boot processor id 0x0/0x0
[    2.989385] Brought up 8 CPUs
[    2.989509] Total of 8 processors activated (19136.51 BogoMIPS).
[    2.992281] DMI 2.3 present.
[    2.993427] NET: Registered protocol family 16
[    2.993906] ACPI: bus type pci registered
[    4.141746] ACPI: Interpreter enabled
[    4.141866] ACPI: Using IOSAPIC for interrupt routing
[    4.152779] ACPI: PCI Root Bridge [P000] (0000:00)
[    4.158688] 0000:00:05.1: cannot adjust BAR0 (size 0)
[    4.158812] 0000:00:05.1: cannot adjust BAR1 (size 0)
[    4.158937] 0000:00:05.1: cannot adjust BAR2 (size 0)
[    4.159060] 0000:00:05.1: cannot adjust BAR3 (size 0)
[    4.160090] PCI quirk: region 0440-044f claimed by vt82c686 SMB
[    4.161193] ACPI: PCI Root Bridge [P001] (0000:01)
[    4.166591] ACPI: PCI Root Bridge [P002] (0000:02)
[    4.171395] ACPI: PCI Root Bridge [P010] (0000:05)
[    4.175953] ACPI: PCI Root Bridge [P011] (0000:07)
[    4.180642] ACPI: PCI Root Bridge [P012] (0000:09)
[    4.185415] ACPI: PCI Root Bridge [P100] (0000:40)
[    4.191304] PCI quirk: region 8440-844f claimed by vt82c686 SMB
[    4.192590] ACPI: PCI Root Bridge [P101] (0000:41)
[    4.198427] ACPI: PCI Root Bridge [P102] (0000:42)
[    4.203193] ACPI: PCI Root Bridge [P110] (0000:45)
[    4.207971] ACPI: PCI Root Bridge [P111] (0000:47)
[    4.212598] ACPI: PCI Root Bridge [P112] (0000:49)
[    4.217486] ACPI: PCI Interrupt Link [IDI0] (IRQs *14)
[    4.217755] ACPI: PCI Interrupt Link [IDI1] (IRQs *116)
[    4.218296] Linux Plug and Play Support v0.97 (c) Adam Belay
[    4.218471] pnp: PnP ACPI init
[    4.218597] ACPI: bus type pnp registered
[    4.242936] pnp: PnP ACPI: found 17 devices
[    4.243056] ACPI: ACPI bus type pnp unregistered
[    4.244082] SCSI subsystem initialized
[    4.244372] usbcore: registered new interface driver usbfs
[    4.244568] usbcore: registered new interface driver hub
[    4.244750] usbcore: registered new device driver usb
[    4.277412] Time: itc clocksource has been installed.
[    4.285532] pnp: 00:00: iomem range 0x80000000-0x82400000 could not be reserved
[    4.285756] pnp: 00:00: iomem range 0xfeb00000-0xfebfffff has been reserved
[    4.285890] pnp: 00:00: iomem range 0xfec00000-0xfeffffff has been reserved
[    4.286025] pnp: 00:00: iomem range 0xfff00000-0xffffffff has been reserved
[    4.286170] pnp: 00:0a: iomem range 0xa0000000-0xbfffffff could not be reserved
[    4.288157] NET: Registered protocol family 2
[    4.330524] IP route cache hash table entries: 2097152 (order: 10, 16777216 bytes)
[    4.358524] TCP established hash table entries: 8388608 (order: 13, 201326592 bytes)
[    5.514910] TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
[    5.521657] TCP: Hash tables configured (established 8388608 bind 65536)
[    5.521792] TCP reno registered
[    5.533988] checking if image is initramfs...it isn't (bad gzip magic numbers); looks like an initrd
[    5.537813] Freeing initrd memory: 1792kB freed
[    5.537996] perfmon: version 2.0 IRQ 238
[    5.538132] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
[    5.538368] sysctl table check failed: /kernel .1 Writable sysctl directory
[    5.538589] sysctl table check failed: /kernel/perfmon  Writable sysctl directory
[    2.556704] perfmon: added sampling format default_format
[    2.556936] perfmon_default_smpl: default_format v2.0 registered
[    2.557142] Summit chipset: Starting Cyclone Counter.
[    5.549422] Time: cyclone clocksource has been installed.
[    2.584021] Total HugeTLB memory allocated, 0
[    2.588619] JFS: nTxBlock = 8192, nTxLock = 65536
[    2.601338] SGI XFS with large block/inode numbers, no debug enabled
[    2.605224] io scheduler noop registered
[    2.605413] io scheduler anticipatory registered
[    2.605605] io scheduler deadline registered
[    2.606002] io scheduler cfq registered (default)
[    2.606893] input: Power Button (FF) as /class/input/input0
[    2.607101] ACPI: Power Button (FF) [PWRF]
[    2.701417] mspec 4.0 initialized devices:  Cached, Uncached
[    2.701621] EFI Time Services Driver v0.4
[    2.701908] Serial: 8250/16550 driver $Revision: 1.90 $ 6 ports, IRQ sharing enabled
[    2.703515] 00:04: ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
[    2.703879] console [ttyS0] enabled
[    3.634704] RAMDISK driver initialized: 16 RAM disks of 32768K size 1024 blocksize
[    3.643521] loop: module loaded
[    3.647396] tg3.c:v3.80 (August 2, 2007)
[    3.651784] GSI 42 (level, low) -> CPU 0 (0x0000) vector 68
[    3.657569] ACPI: PCI Interrupt 0000:01:04.0[A] -> GSI 42 (level, low) -> IRQ 68
[    3.835481] eth0: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:1f:80:b0
[    3.847814] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    3.855646] eth0: dma_rwctrl[769f0000] dma_mask[64-bit]
[    3.861145] ACPI: PCI Interrupt 0000:01:04.1[B] -> GSI 11 (level, low) -> IRQ 37
[    4.140637] eth1: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:9f:80:b0
[    4.152975] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    4.160811] eth1: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.166340] GSI 144 (level, low) -> CPU 1 (0x0200) vector 69
[    4.172204] ACPI: PCI Interrupt 0000:41:04.0[A] -> GSI 144 (level, low) -> IRQ 69
[    4.358415] eth2: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:1f:80:e2
[    4.152975] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    4.160811] eth1: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.166340] GSI 144 (level, low) -> CPU 1 (0x0200) vector 69
[    4.172204] ACPI: PCI Interrupt 0000:41:04.0[A] -> GSI 144 (level, low) -> IRQ 69
[    4.358415] eth2: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:1f:80:e2
[    4.370751] eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    4.378583] eth2: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.384083] GSI 113 (level, low) -> CPU 2 (0x0400) vector 70
[    4.389949] ACPI: PCI Interrupt 0000:41:04.1[B] -> GSI 113 (level, low) -> IRQ 70
[    4.662910] eth3: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:9f:80:e2
[    4.675246] eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    4.683080] eth3: dma_rwctrl[769f0000] dma_mask[64-bit]
[    4.688906] netconsole: not configured, aborting
[    4.693735] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[    4.700312] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[    4.708833] VP_IDE: IDE controller at PCI slot 0000:00:05.1
[    4.714674] VP_IDE: chipset revision 6
[    4.718610] VP_IDE: not 100% native mode: will probe irqs later
[    4.724780] VP_IDE: VIA vt82c686b (rev 40) IDE UDMA100 controller on pci0000:00:05.1
[    4.732911]     ide0: BM-DMA at 0x0700-0x0707, BIOS settings: hda:DMA, hdb:DMA
[    5.327594] hdb: IRQ probe failed (0xffffffe)
[    5.631590] hdb: IRQ probe failed (0xffffffe)
[    6.211928] hda: HL-DT-STDVD-ROM GDR8081N, ATAPI CD/DVD-ROM drive
[    6.229969] ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
[   10.928899] hda: ATAPI 24X DVD-ROM drive, 512kB Cache, UDMA(33)
[   10.935233] Uniform CD-ROM driver Revision: 3.20
[   10.951591] Fusion MPT base driver 3.04.05
[   10.955826] Copyright (c) 1999-2007 LSI Corporation
[   10.960835] Fusion MPT SPI Host driver 3.04.05
[   10.965871] GSI 40 (level, low) -> CPU 3 (0x0600) vector 71
[   10.971581] ACPI: PCI Interrupt 0000:01:03.0[A] -> GSI 40 (level, low) -> IRQ 71
[   10.979277] mptbase: Initiating ioc0 bringup
[   11.461417] ioc0: LSI53C1030 C0: Capabilities={Initiator}
[   12.142961] scsi0 : ioc0: LSI53C1030 C0, FwRev=01032821h, Ports=1, MaxQ=222, IRQ=71
[   13.578379] scsi 0:0:0:0: Direct-Access     IBM-ESXS DTN018C1UCDY10F  S25J PQ: 0 ANSI: 3
[   13.586719]  target0:0:0: Beginning Domain Validation
[   13.604410]  target0:0:0: Ending Domain Validation
[   13.609401]  target0:0:0: FAST-80 WIDE SCSI 160.0 MB/s DT (12.5 ns, offset 127)
[   13.617932] sd 0:0:0:0: [sda] 35548320 512-byte hardware sectors (18201 MB)
[   13.625810] sd 0:0:0:0: [sda] Write Protect is off
[   13.631696] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   13.641743] sd 0:0:0:0: [sda] 35548320 512-byte hardware sectors (18201 MB)
[   13.649625] sd 0:0:0:0: [sda] Write Protect is off
[   13.655483] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   13.664843]  sda: sda1 sda2
[   13.698603] sd 0:0:0:0: [sda] Attached SCSI disk
[   13.703622] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   15.212042] scsi 0:0:8:0: Processor         IBM      25P3495a S320  1 1    PQ: 0 ANSI: 2
[   15.220372]  target0:0:8: Beginning Domain Validation
[   15.226162]  target0:0:8: Ending Domain Validation
[   15.231146]  target0:0:8: asynchronous
[   15.235465] scsi 0:0:8:0: Attached scsi generic sg1 type 3
[   16.997430] GSI 41 (level, low) -> CPU 4 (0x1000) vector 72
[   17.003143] ACPI: PCI Interrupt 0000:01:03.1[B] -> GSI 41 (level, low) -> IRQ 72
[   17.010814] mptbase: Initiating ioc1 bringup
[   17.493416] ioc1: LSI53C1030 C0: Capabilities={Initiator}
[   15.210502] scsi1 : ioc1: LSI53C1030 C0, FwRev=01032821h, Ports=1, MaxQ=222, IRQ=72
[   20.410593] GSI 142 (level, low) -> CPU 5 (0x1200) vector 73
[   20.416465] ACPI: PCI Interrupt 0000:41:03.0[A] -> GSI 142 (level, low) -> IRQ 73
[   20.424417] mptbase: Initiating ioc2 bringup
[   20.908658] ioc2: LSI53C1030 C0: Capabilities={Initiator}
[   20.915497] DMA: Out of SW-IOMMU space for 263200 bytes at device ?
[   20.921982] Kernel panic - not syncing: DMA: Memory would be corrupted


--------------000600050809070101020203
Content-Type: text/plain;
 name="dotconfig"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dotconfig"

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.23-rc3-mm1-autokern1
# Wed Aug 22 06:13:16 2007
#
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_SWAP=y
CONFIG_SWAP_PREFETCH=y
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
# CONFIG_CONTAINERS is not set
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
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_KPAGEMAP=y
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
# CONFIG_BLK_DEV_BSG is not set

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
CONFIG_HUGETLB_PAGE_SIZE_VARIABLE=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_TIME_VSYSCALL=y
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
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_BKL=y
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_DISCONTIGMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_DISCONTIGMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_NEED_MULTIPLE_NODES=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MIGRATION=y
CONFIG_RESOURCES_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
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
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
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
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_IDEPNP is not set

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_OPTI621 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
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
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
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
# CONFIG_MD is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
# CONFIG_FUSION_FC is not set
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_CTL is not set
# CONFIG_FUSION_LOGGING is not set

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
# CONFIG_E1000E is not set
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
# CONFIG_NOZOMI is not set
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
# CONFIG_SENSORS_ABITUGURU3 is not set
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
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_THMC50 is not set
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
# CONFIG_WATCHDOG is not set

#
# Sonics Silicon Backplane
#
CONFIG_SSB_POSSIBLE=y
# CONFIG_SSB is not set

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
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
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
# CONFIG_HIDRAW is not set

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
# CONFIG_USB_GOTEMP is not set

#
# USB DSL modem support
#

#
# USB Gadget Support
#
# CONFIG_USB_GADGET is not set
# CONFIG_MMC is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_INFINIBAND is not set
# CONFIG_RTC_CLASS is not set

#
# Userspace I/O
#
# CONFIG_UIO is not set
CONFIG_MSPEC=y

#
# File systems
#
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
# CONFIG_EXT3_FS_POSIX_ACL is not set
# CONFIG_EXT3_FS_SECURITY is not set
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISER4_FS is not set
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
# CONFIG_FS_POSIX_ACL is not set
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
# CONFIG_XFS_SECURITY is not set
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
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
# Layered filesystems
#
# CONFIG_UNION_FS is not set

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
# CONFIG_CRC7 is not set
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
# CONFIG_PAGE_OWNER is not set
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
# CONFIG_UNWIND_INFO is not set
# CONFIG_PROFILE_LIKELY is not set
CONFIG_FORCED_INLINING=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DEBUG_SYNCHRO_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_WANT_EXTRA_DEBUG_INFORMATION is not set
# CONFIG_KGDB is not set
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
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
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
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_DEFLATE is not set
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_CRC32C is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_HW=y

--------------000600050809070101020203--

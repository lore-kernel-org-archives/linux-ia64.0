From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Wed, 04 Aug 2004 03:04:29 +0000
Subject: IA64 test report: 2.4.27-rc3 /tiger 2004-8-4: 9/9 pass, atapi ide floppy issue
Message-Id: <9DE394C12A921946AEECE1F71944ECD50F004C@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <6E0C289723A0564F9A8279E236E8565F07CB29CC@pdsmsx402.pd.intel.com>
In-Reply-To: <6E0C289723A0564F9A8279E236E8565F07CB29CC@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


ACPI Test Report  for 2.4 ia64 kernel=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DHardware Configuration:
------------------------------
System Name: ACPI-Tiger
System Type: 4 way 900 Itanium2, tiger
M/B revision: N/A
Processor version: N/A
Firmware Versions: N/A
I/O configuration summary:
	MPT scsi host driver
	Seagate ST318406LC boot drive
	IDE floppy and CDROM
	Serial console
	USB mouse=20
	USB keyboard
	Ethernet Pro 1000

Software Configuration:
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.4 on 8/3(Shanghai
time)
	2.bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.4.27on
8/3(Shanghai time)
=09
ACPI Features Tested: (prioritized).
----------------------------=09
1. Boot 					tested ok
2. serial console				tested ok
3. ATI (run X window system)			tested ok
4. usb keyboard				tested ok
5. USB mouse					tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)		tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off 				tested ok

Issue Highlight
-------------------
End request I/O error of ATAPI IDE floppy when doing partition check.=20
Mount test ok after boot up in normal use. Enable IDEFLOPPY_DEBUG_xx and
attach log below.

Logs:
------
Linux version 2.4.27-rc3 (root@tiger44) (gcc version 3.3.3 20040412 (Red
Hat Linux 3.3.3-7)) #10 SMP Wed Aug 4 10:19:11 EDT 2004
EFI v1.10 by INTEL: SALsystab=3D0x3fe4c8c0 ACPI=3D0x3ff84000 ACPI
2.0=3D0x3ff83000 MPS=3D0x3ff82000 SMBIOS=3D0xf0000
ACPI: RSDP (v002 INTEL                                     ) @
0x000000003ff83000
ACPI: XSDT (v001 INTEL  SR870BN4 0x01072002 MSFT 0x00010013) @
0x000000003ff83090
ACPI: FADT (v003 INTEL  SR870BN4 0x01072002 MSFT 0x00010013) @
0x000000003ff83138
ACPI: MADT (v001 INTEL  SR870BN4 0x01072002 MSFT 0x00010013) @
0x000000003ff83230
ACPI: DSDT (v001  Intel SR870BN4 0x00000000 MSFT 0x0100000d) @
0x0000000000000000
efi.trim_top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
efi.trim_top: ignoring 24KB of memory at 0x1000 due to granule hole at
0x0
efi.trim_top: ignoring 8KB of memory at 0x7000 due to granule hole at
0x0
efi.trim_top: ignoring 484KB of memory at 0x9000 due to granule hole at
0x0
efi.trim_top: ignoring 4KB of memory at 0x84000 due to granule hole at
0x0
efi.trim_top: ignoring 108KB of memory at 0x85000 due to granule hole at
0x0
efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule
hole at 0x0
SAL v3.01: oem=3DIntel Corp                      , product=3DSR870BN4

SAL: entry: pal_proc=3D0x3fe08010, sal_proc=3D0x3fe48020
SAL: Platform features BusLock IRQ_Redirection=20
SAL: AP wakeup using external interrupt vector 0xf0
booting generic kernel on platform dig
CPU 0: 61 virtual and 50 physical address bits
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address 0xc0000000fee00000
ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0xc6] lsapic_eid[0x18] enabled)
CPU 0 (0xc618) enabled (BSP)
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0xc0] lsapic_eid[0x18] enabled)
CPU 1 (0xc018) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0xc4] lsapic_eid[0x18] enabled)
CPU 2 (0xc418) enabled
ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0xc2] lsapic_eid[0x18] enabled)
CPU 3 (0xc218) enabled
ACPI: IOSAPIC (id[0x0] global_irq_base[0x0] address[00000000fec00000])
  IOSAPIC v2.0, address 0xfec00000, GSIs 0x0-0x17
ACPI: IOSAPIC (id[0x1] global_irq_base[0x18] address[00000000fec10000])
  IOSAPIC v2.0, address 0xfec10000, GSIs 0x18-0x2f
ACPI: IOSAPIC (id[0x2] global_irq_base[0x30] address[00000000fec20000])
  IOSAPIC v2.0, address 0xfec20000, GSIs 0x30-0x47
ACPI: IOSAPIC (id[0x3] global_irq_base[0x48] address[00000000fec30000])
  IOSAPIC v2.0, address 0xfec30000, GSIs 0x48-0x5f
ACPI: IOSAPIC (id[0x4] global_irq_base[0x60] address[00000000fec40000])
  IOSAPIC v2.0, address 0xfec40000, GSIs 0x60-0x77
ACPI: IOSAPIC (id[0x5] global_irq_base[0x78] address[00000000fec50000])
  IOSAPIC v2.0, address 0xfec50000, GSIs 0x78-0x8f
ACPI: IOSAPIC (id[0x6] global_irq_base[0x90] address[00000000fec60000])
  IOSAPIC v2.0, address 0xfec60000, GSIs 0x90-0xa7
ACPI: PLAT_INT_SRC (low level type[0x3] id[0x00c6] eid[0x18]
iosapic_vector[0x1e] global_irq[0x16]
PLATFORM int 0x3: GSI 0x16(low,level) -> CPU 0xc618 vector 30
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 4 CPUs total
MCA related initialization done
On node 0 totalpages: 63533
zone(0): 63533 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Building zonelist for node : 0
Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux-2.4-n
root=3D/dev/sda2 console=3DttyS1,9600 console=3Dtty0 ro
FPSWA interface at 0x3fa32010, revision 1.18
CPU 0: base freq=199.454MHz, ITC ratio=14/2, ITC freq=1396.182MHz
Console: colour VGA+ 80x25
Calibrating delay loop... 2089.76 BogoMIPS
Placing software IO TLB between 0xe0000000015a0000 - 0xe0000000017a0000
Memory: 1008688k/1016528k available (6635k code, 7872k reserved, 2350k
data, 224k init)
Dentry cache hash table entries: 65536 (order: 6, 1048576 bytes)
Inode cache hash table entries: 65536 (order: 6, 1048576 bytes)
Mount cache hash table entries: 1024 (order: 0, 16384 bytes)
Buffer cache hash table entries: 65536 (order: 5, 524288 bytes)
Page-cache hash table entries: 65536 (order: 5, 524288 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0xc618
SMP: starting up secondaries.
CPU 1: 61 virtual and 50 physical address bits
CPU 1: base freq=199.454MHz, ITC ratio=14/2, ITC freq=1396.182MHz
Calibrating delay loop... 2089.76 BogoMIPS
CPU 1: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 521
cycles)
CPU1: CPU has booted.
CPU 2: 61 virtual and 50 physical address bits
CPU 2: base freq=199.454MHz, ITC ratio=14/2, ITC freq=1396.182MHz
Calibrating delay loop... 2089.76 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 509
cycles)
CPU2: CPU has booted.
CPU 3: 61 virtual and 50 physical address bits
CPU 3: base freq=199.454MHz, ITC ratio=14/2, ITC freq=1396.182MHz
Calibrating delay loop... 2089.76 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 521
cycles)
CPU3: CPU has booted.
Before bogomips.
Total of 4 processors activated (8359.04 BogoMIPS).
Waiting on wait_init_idle (map =3D 0xe)
All processors have done init_idle
ACPI: Subsystem revision 20040326
PCI: Using SAL to access configuration space
 tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully
acquired
Parsing all Control
Methods:................................................................
........................................................................
..........................
Table [DSDT](id F004) - 1385 Objects with 110 Devices 162 Methods 40
Regions
ACPI Namespace successfully loaded at root e000000004d0ecb0
evxfevnt-0082 [04] acpi_enable           : System is already in ACPI
mode
evgpeblk-0867 [06] ev_create_gpe_block   : GPE 00 to 31 [_GPE] 4 regs at
0000000000000C28 on int 9
evgpeblk-0925 [06] ev_create_gpe_block   : Found 6 Wake, Enabled 1
Runtime GPEs in this block
Completing Region/Field/Buffer/Package
initialization:.........................................................
...............
Initialized 40/40 Regions 1/1 Fields 16/16 Buffers 15/15 Packages (1394
nodes)
Executing all Device _STA and_INI
methods:................................................................
........................................
104 Devices found containing: 104 _STA, 3 _INI methods
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: System [ACPI] (supports S0 S4 S5)
ACPI: PCI Root Bridge [PCI0] (00:00)
alloc 0x0-0x6fff from PCI IO for PCI Bus 00:00 failed
PCI: Ignoring BAR0-3 of IDE controller 00:1f.1
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.H2PB._PRT]
ACPI: PCI Root Bridge [PCI1] (00:02)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PB._PRT]
ACPI: PCI Root Bridge [PCI2] (00:07)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
ACPI: PCI Root Bridge [PCI3] (00:08)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PB._PRT]
ACPI: PCI Root Bridge [PCI4] (00:0e)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PB._PRT]
ACPI: PCI Root Bridge [CSFF] (00:ff)
PCI->APIC IRQ transform: (00:1d.0 INTA) -> CPU 0xc618 vector 48
PCI->APIC IRQ transform: (00:1d.1 INTB) -> CPU 0xc618 vector 49
PCI->APIC IRQ transform: (00:1d.7 INTD) -> CPU 0xc618 vector 50
PCI: no interrupt route for 00:00:1f pin A
PCI->APIC IRQ transform: (01:00.0 INTA) -> CPU 0xc618 vector 51
PCI->APIC IRQ transform: (03:1f.0 INTA) -> CPU 0xc618 vector 52
PCI->APIC IRQ transform: (06:01.0 INTA) -> CPU 0xc618 vector 53
PCI->APIC IRQ transform: (06:02.0 INTA) -> CPU 0xc618 vector 54
PCI->APIC IRQ transform: (06:02.1 INTB) -> CPU 0xc618 vector 55
PCI->APIC IRQ transform: (06:1f.0 INTA) -> CPU 0xc618 vector 56
PCI->APIC IRQ transform: (09:1f.0 INTA) -> CPU 0xc618 vector 57
PCI->APIC IRQ transform: (0b:1f.0 INTA) -> CPU 0xc618 vector 58
PCI->APIC IRQ transform: (0f:1f.0 INTA) -> CPU 0xc618 vector 59
PCI->APIC IRQ transform: (11:1f.0 INTA) -> CPU 0xc618 vector 60
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
perfmon: version 1.5 IRQ 238
perfmon: 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
EFI Variables Facility v0.06 2002-Dec-10
Total HugeTLB memory allocated, 0
Starting kswapd
Journalled Block Device driver loaded
Hugetlbfs mounted.
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
udf: registering filesystem
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU0] (supports C1)
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
i2c-core.o: i2c core module version 2.6.1 (20010830)
i2c-algo-bit.o: i2c bit algorithm module
initialize_kbd: Keyboard reset failed, no ACK
pty: 256 Unix98 ptys configured
keyboard: Timeout - AT keyboard not present?(ed)
keyboard: Timeout - AT keyboard not present?(f4)
Serial driver version 5.05c (2001-07-08) with MANY_PORTS SHARE_IRQ
DETECT_IRQ SERIAL_PCI SERIAL_ACPI enabled
ttyS00 at 0x03f8 (irq =3D 44) is a 16550A
ttyS01 at 0x02f8 (irq =3D 45) is a 16550A
acpi_serial_add: no iomem or port address in UAR1 _CRS
acpi_serial_add: no iomem or port address in UAR2 _CRS
EFI Time Services Driver v0.4
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.52-k3
Copyright (c) 1999-2004 Intel Corporation.
PCI: Found IRQ 51 for device 01:00.0
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Found IRQ 53 for device 06:01.0
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
Ethernet Channel Bonding Driver: v2.6.0 (January 14, 2004)
bonding: Warning: either miimon or arp_interval and arp_ip_target module
parameters must be specified, otherwise bonding will not detect link
failures! see bonding.txt for details.
Uniform Multi-Platform E-IDE driver Revision: 7.00beta4-2.4
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx
hda: MATSHITADVD-ROM SR-8177, ATAPI CD/DVD-ROM drive
hdb: LS-120/240 00 UHD Floppy, ATAPI FLOPPY drive
global_restore_flags: 10084a6010 (e000000004b78060)
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hda: attached ide-cdrom driver.
hda: ATAPI 24X DVD-ROM drive, 256kB Cache
Uniform CD-ROM driver Revision: 3.12
Partition check:
 hdb:end_request: I/O error, dev 03:40 (hdb), sector 0
end_request: I/O error, dev 03:40 (hdb), sector 1
end_request: I/O error, dev 03:40 (hdb), sector 2
end_request: I/O error, dev 03:40 (hdb), sector 3
end_request: I/O error, dev 03:40 (hdb), sector 4
end_request: I/O error, dev 03:40 (hdb), sector 5
end_request: I/O error, dev 03:40 (hdb), sector 6
end_request: I/O error, dev 03:40 (hdb), sector 7
end_request: I/O error, dev 03:40 (hdb), sector 8
end_request: I/O error, dev 03:40 (hdb), sector 9
end_request: I/O error, dev 03:40 (hdb), sector 10
end_request: I/O error, dev 03:40 (hdb), sector 11
end_request: I/O error, dev 03:40 (hdb), sector 12
end_request: I/O error, dev 03:40 (hdb), sector 13
end_request: I/O error, dev 03:40 (hdb), sector 14
end_request: I/O error, dev 03:40 (hdb), sector 15
end_request: I/O error, dev 03:40 (hdb), sector 16
end_request: I/O error, dev 03:40 (hdb), sector 17
end_request: I/O error, dev 03:40 (hdb), sector 18
end_request: I/O error, dev 03:40 (hdb), sector 19
end_request: I/O error, dev 03:40 (hdb), sector 20
end_request: I/O error, dev 03:40 (hdb), sector 21
end_request: I/O error, dev 03:40 (hdb), sector 22
end_request: I/O error, dev 03:40 (hdb), sector 23
end_request: I/O error, dev 03:40 (hdb), sector 24
end_request: I/O error, dev 03:40 (hdb), sector 25
end_request: I/O error, dev 03:40 (hdb), sector 26
end_request: I/O error, dev 03:40 (hdb), sector 27
end_request: I/O error, dev 03:40 (hdb), sector 28
end_request: I/O error, dev 03:40 (hdb), sector 29
end_request: I/O error, dev 03:40 (hdb), sector 30
end_request: I/O error, dev 03:40 (hdb), sector 31
end_request: I/O error, dev 03:40 (hdb), sector 0
end_request: I/O error, dev 03:40 (hdb), sector 1
end_request: I/O error, dev 03:40 (hdb), sector 2
end_request: I/O error, dev 03:40 (hdb), sector 3
end_request: I/O error, dev 03:40 (hdb), sector 4
end_request: I/O error, dev 03:40 (hdb), sector 5
end_request: I/O error, dev 03:40 (hdb), sector 6
end_request: I/O error, dev 03:40 (hdb), sector 7
end_request: I/O error, dev 03:40 (hdb), sector 8
end_request: I/O error, dev 03:40 (hdb), sector 9
end_request: I/O error, dev 03:40 (hdb), sector 10
end_request: I/O error, dev 03:40 (hdb), sector 11
end_request: I/O error, dev 03:40 (hdb), sector 12
end_request: I/O error, dev 03:40 (hdb), sector 13
end_request: I/O error, dev 03:40 (hdb), sector 14
end_request: I/O error, dev 03:40 (hdb), sector 15
end_request: I/O error, dev 03:40 (hdb), sector 16
end_request: I/O error, dev 03:40 (hdb), sector 17
end_request: I/O error, dev 03:40 (hdb), sector 18
end_request: I/O error, dev 03:40 (hdb), sector 19
end_request: I/O error, dev 03:40 (hdb), sector 20
end_request: I/O error, dev 03:40 (hdb), sector 21
end_request: I/O error, dev 03:40 (hdb), sector 22
end_request: I/O error, dev 03:40 (hdb), sector 23
end_request: I/O error, dev 03:40 (hdb), sector 24
end_request: I/O error, dev 03:40 (hdb), sector 25
end_request: I/O error, dev 03:40 (hdb), sector 26
end_request: I/O error, dev 03:40 (hdb), sector 27
end_request: I/O error, dev 03:40 (hdb), sector 28
end_request: I/O error, dev 03:40 (hdb), sector 29
end_request: I/O error, dev 03:40 (hdb), sector 30
end_request: I/O error, dev 03:40 (hdb), sector 31
end_request: I/O error, dev 03:40 (hdb), sector 2147483616
end_request: I/O error, dev 03:40 (hdb), sector 2147483617
end_request: I/O error, dev 03:40 (hdb), sector 2147483618
end_request: I/O error, dev 03:40 (hdb), sector 2147483619
end_request: I/O error, dev 03:40 (hdb), sector 2147483620
end_request: I/O error, dev 03:40 (hdb), sector 2147483621
end_request: I/O error, dev 03:40 (hdb), sector 2147483622
end_request: I/O error, dev 03:40 (hdb), sector 2147483623
end_request: I/O error, dev 03:40 (hdb), sector 2147483624
end_request: I/O error, dev 03:40 (hdb), sector 2147483625
end_request: I/O error, dev 03:40 (hdb), sector 2147483626
end_request: I/O error, dev 03:40 (hdb), sector 2147483627
end_request: I/O error, dev 03:40 (hdb), sector 2147483628
end_request: I/O error, dev 03:40 (hdb), sector 2147483629
end_request: I/O error, dev 03:40 (hdb), sector 2147483630
end_request: I/O error, dev 03:40 (hdb), sector 2147483631
end_request: I/O error, dev 03:40 (hdb), sector 2147483632
end_request: I/O error, dev 03:40 (hdb), sector 2147483633
end_request: I/O error, dev 03:40 (hdb), sector 2147483634
end_request: I/O error, dev 03:40 (hdb), sector 2147483635
end_request: I/O error, dev 03:40 (hdb), sector 2147483636
end_request: I/O error, dev 03:40 (hdb), sector 2147483637
end_request: I/O error, dev 03:40 (hdb), sector 2147483638
end_request: I/O error, dev 03:40 (hdb), sector 2147483639
end_request: I/O error, dev 03:40 (hdb), sector 2147483640
end_request: I/O error, dev 03:40 (hdb), sector 2147483641
end_request: I/O error, dev 03:40 (hdb), sector 2147483642
end_request: I/O error, dev 03:40 (hdb), sector 2147483643
end_request: I/O error, dev 03:40 (hdb), sector 2147483644
end_request: I/O error, dev 03:40 (hdb), sector 2147483645
end_request: I/O error, dev 03:40 (hdb), sector 2147483616
end_request: I/O error, dev 03:40 (hdb), sector 2147483617
end_request: I/O error, dev 03:40 (hdb), sector 2147483618
end_request: I/O error, dev 03:40 (hdb), sector 2147483619
end_request: I/O error, dev 03:40 (hdb), sector 2147483620
end_request: I/O error, dev 03:40 (hdb), sector 2147483621
end_request: I/O error, dev 03:40 (hdb), sector 2147483622
end_request: I/O error, dev 03:40 (hdb), sector 2147483623
end_request: I/O error, dev 03:40 (hdb), sector 2147483624
end_request: I/O error, dev 03:40 (hdb), sector 2147483625
end_request: I/O error, dev 03:40 (hdb), sector 2147483626
end_request: I/O error, dev 03:40 (hdb), sector 2147483627
end_request: I/O error, dev 03:40 (hdb), sector 2147483628
end_request: I/O error, dev 03:40 (hdb), sector 2147483629
end_request: I/O error, dev 03:40 (hdb), sector 2147483630
end_request: I/O error, dev 03:40 (hdb), sector 2147483631
end_request: I/O error, dev 03:40 (hdb), sector 2147483632
end_request: I/O error, dev 03:40 (hdb), sector 2147483633
end_request: I/O error, dev 03:40 (hdb), sector 2147483634
end_request: I/O error, dev 03:40 (hdb), sector 2147483635
end_request: I/O error, dev 03:40 (hdb), sector 2147483636
end_request: I/O error, dev 03:40 (hdb), sector 2147483637
end_request: I/O error, dev 03:40 (hdb), sector 2147483638
end_request: I/O error, dev 03:40 (hdb), sector 2147483639
end_request: I/O error, dev 03:40 (hdb), sector 2147483640
end_request: I/O error, dev 03:40 (hdb), sector 2147483641
end_request: I/O error, dev 03:40 (hdb), sector 2147483642
end_request: I/O error, dev 03:40 (hdb), sector 2147483643
end_request: I/O error, dev 03:40 (hdb), sector 2147483644
end_request: I/O error, dev 03:40 (hdb), sector 2147483645
end_request: I/O error, dev 03:40 (hdb), sector 0
end_request: I/O error, dev 03:40 (hdb), sector 2
end_request: I/O error, dev 03:40 (hdb), sector 4
end_request: I/O error, dev 03:40 (hdb), sector 6
end_request: I/O error, dev 03:40 (hdb), sector 8
end_request: I/O error, dev 03:40 (hdb), sector 10
end_request: I/O error, dev 03:40 (hdb), sector 12
end_request: I/O error, dev 03:40 (hdb), sector 14
end_request: I/O error, dev 03:40 (hdb), sector 16
end_request: I/O error, dev 03:40 (hdb), sector 18
end_request: I/O error, dev 03:40 (hdb), sector 20
end_request: I/O error, dev 03:40 (hdb), sector 22
end_request: I/O error, dev 03:40 (hdb), sector 24
end_request: I/O error, dev 03:40 (hdb), sector 26
end_request: I/O error, dev 03:40 (hdb), sector 28
end_request: I/O error, dev 03:40 (hdb), sector 30
end_request: I/O error, dev 03:40 (hdb), sector 0
end_request: I/O error, dev 03:40 (hdb), sector 2
end_request: I/O error, dev 03:40 (hdb), sector 4
end_request: I/O error, dev 03:40 (hdb), sector 6
end_request: I/O error, dev 03:40 (hdb), sector 8
end_request: I/O error, dev 03:40 (hdb), sector 10
end_request: I/O error, dev 03:40 (hdb), sector 12
end_request: I/O error, dev 03:40 (hdb), sector 14
end_request: I/O error, dev 03:40 (hdb), sector 16
end_request: I/O error, dev 03:40 (hdb), sector 18
end_request: I/O error, dev 03:40 (hdb), sector 20
end_request: I/O error, dev 03:40 (hdb), sector 22
end_request: I/O error, dev 03:40 (hdb), sector 24
end_request: I/O error, dev 03:40 (hdb), sector 26
end_request: I/O error, dev 03:40 (hdb), sector 28
end_request: I/O error, dev 03:40 (hdb), sector 30
 unable to read partition table
SCSI subsystem driver Revision: 1.00
megaraid: v1.18k (Release Date: Thu Aug 28 10:05:11 EDT 2003)
megaraid: no BIOS enabled.
kmod: failed to exec /sbin/modprobe -s -k scsi_hostadapter, errno =3D 2
kmod: failed to exec /sbin/modprobe -s -k scsi_hostadapter, errno =3D 2
kmod: failed to exec /sbin/modprobe -s -k scsi_hostadapter, errno =3D 2
kmod: failed to exec /sbin/modprobe -s -k scsi_hostadapter, errno =3D 2
kmod: failed to exec /sbin/modprobe -s -k scsi_hostadapter, errno =3D 2
Fusion MPT base driver 2.05.16
Copyright (c) 1999-2004 LSI Logic Corporation
PCI: Found IRQ 54 for device 06:02.0
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities=3D{Initiator}
PCI: Found IRQ 55 for device 06:02.1
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities=3D{Initiator}
mptbase: 2 MPT adapters found, 2 installed.
Fusion MPT SCSI Host driver 2.05.16
scsi0 : ioc0: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQT
scsi1 : ioc1: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQU
blk: queue e00000003c825930, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
  Vendor: MAXTOR    Model: ATLASU320_18_SCA  Rev: B120
  Type:   Direct-Access                      ANSI SCSI revision: 03
blk: queue e00000003c825730, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
  Vendor: ESG-SHV   Model: SCA HSBP M17      Rev: 0101
  Type:   Processor                          ANSI SCSI revision: 02
blk: queue e00000003c825530, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
Attached scsi generic sg1 at scsi0, channel 0, id 6, lun 0,  type 3
SCSI device sda: 35916548 512-byte hdwr sectors (18389 MB)
 sda: sda1 sda2 sda3
cs4281: version v1.30.64 time 10:22:09 Aug  4 2004
usb.c: registered new driver usbdevfs
usb.c: registered new driver hub
PCI: Found IRQ 50 for device 00:1d.7
ehci_hcd 00:1d.7: Intel Corp. 82801DB USB2
ehci_hcd 00:1d.7: irq 50, pci mem c0000000f9ff0000
usb.c: new USB bus registered, assigned bus number 1
ehci_hcd 00:1d.7: enabled 64bit PCI DMA
PCI: slot 00:1d.7 has incorrect PCI cache line size of 0 bytes,
correcting to 128
ehci_hcd 00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2003-Dec-29/2.4
hub.c: USB hub found
hub.c: 4 ports detected
host/usb-uhci.c: $Revision: 1.275 $ time 10:22:19 Aug  4 2004
host/usb-uhci.c: High bandwidth mode enabled
PCI: Found IRQ 48 for device 00:1d.0
host/usb-uhci.c: USB UHCI at I/O 0x5cc0, IRQ 48
host/usb-uhci.c: Detected 2 ports
usb.c: new USB bus registered, assigned bus number 2
hub.c: USB hub found
hub.c: 2 ports detected
PCI: Found IRQ 49 for device 00:1d.1
host/usb-uhci.c: USB UHCI at I/O 0x5ce0, IRQ 49
host/usb-uhci.c: Detected 2 ports
usb.c: new USB bus registered, assigned bus number 3
hub.c: USB hub found
hub.c: 2 ports detected
host/usb-uhci.c: v1.275:USB Universal Host Controller Interface driver
usb.c: registered new driver hiddev
usb.c: registered new driver hid
hid-core.c: v1.8.1 Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>
hid-core.c: USB HID support drivers
mice: PS/2 mouse device common for all mice
Initializing Cryptographic API
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP, IGMP
IP: routing cache hash table of 16384 buckets, 256Kbytes
TCP: Hash tables configured (established 131072 bind 65536)
arp_tables: (C) 2002 David S. Miller
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 224kB freed
hub.c: new USB device 00:1d.1-2, assigned address 2
hub.c: USB hub found
hub.c: 4 ports detected
hub.c: new USB device 00:1d.1-2.1, assigned address 3
input: USB HID v1.10 Keyboard [SOLIDTEK USB Composite Keyboard] on
usb3:3.0
host/usb-uhci.c: interrupt, status 2, frame# 137
EXT3 FS 2.4-0.9.19, 19 August 2002 on sd(8,2), internal journal
Adding Swap: 2047968k swap-space (priority -1)
Dumping ATAPI Identify Device floppy parameters
Protocol Type: ATAPI
Device Type: 0 - Direct-access Device
Removable: Yes
Command Packet DRQ Type: Microprocessor DRQ
Command Packet Size: 12 bytes
Model: LS-120/240 00 UHD Floppy
Firmware Revision: H050MA41
Serial Number: 2619MHA00072
Write buffer size(?): 0 bytes
DMA: Yes
LBA: Yes
IORDY can be disabled: Yes
IORDY supported: Yes
ATAPI overlap supported: No
PIO Cycle Timing Category: 2
DMA Cycle Timing Category: 0
Single Word DMA supported modes:
Multi Word DMA supported modes:
   Mode 0
   Mode 1
   Mode 2 (active)
Enhanced PIO Modes: Mode 3
Minimum Multi-word DMA cycle per word: 120 ns
Manufacturer's Recommended Multi-word cycle: 120 ns
Minimum PIO cycle without IORDY: 120 ns
Minimum PIO cycle with IORDY: 120 ns
hdb: attached ide-floppy driver.
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 44 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
hdb: 1440kB, 2880 blocks, 512 sector size
Descriptor 0 Code: 2
Descriptor 0: 1440kB, 2880 blocks, 512 sector size
Descriptor 1: 1440kB, 2880 blocks, 512 sector size
Descriptor 2: 1200kB, 2400 blocks, 512 sector size
Descriptor 3: 1232kB, 1232 blocks, 1024 sector size
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 40 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
hdb: 1440kB, 80/2/18 CHS, 312 kBps, 512 sector size, 1500 rpm
 hdb:<6>rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 2848, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 2848, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 2
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
 hdb1 hdb2 hdb4
Reached idefloppy_open
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 44 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
Descriptor 0 Code: 2
Descriptor 0: 1440kB, 2880 blocks, 512 sector size
Descriptor 1: 1440kB, 2880 blocks, 512 sector size
Descriptor 2: 1200kB, 2400 blocks, 512 sector size
Descriptor 3: 1232kB, 1232 blocks, 1024 sector size
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 40 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
ide-floppy: creating prevent removal command, prevent =3D 1
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
 hdb:<6>rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 2848, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 2848, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 2
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
 hdb1 hdb2 hdb4
Reached idefloppy_release
ide-floppy: creating prevent removal command, prevent =3D 0
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
usb_control/bulk_msg: timeout
usb_control/bulk_msg: timeout
host/usb-uhci.c: interrupt, status 2, frame# 1954
usb_control/bulk_msg: timeout
input,hiddev0: USB HID v1.10 Device [SOLIDTEK USB Composite Keyboard] on
usb3:3.1
e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex
Reached idefloppy_open
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 44 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
Descriptor 0 Code: 2
Descriptor 0: 1440kB, 2880 blocks, 512 sector size
Descriptor 1: 1440kB, 2880 blocks, 512 sector size
Descriptor 2: 1200kB, 2400 blocks, 512 sector size
Descriptor 3: 1232kB, 1232 blocks, 1024 sector size
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 40 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
ide-floppy: creating prevent removal command, prevent =3D 1
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
 hdb:<6>rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 2848, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 2848, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 2
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
 hdb1 hdb2 hdb4
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 2
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 32, nr_sectors: 128, current_nr_sectors: 2
create_rw10_cmd: block =3D 32, blocks =3D 128
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 65536 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 160, nr_sectors: 128, current_nr_sectors: 2
create_rw10_cmd: block =3D 160, blocks =3D 128
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 65536 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 288, nr_sectors: 96, current_nr_sectors: 2
create_rw10_cmd: block =3D 288, blocks =3D 96
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 49152 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
Reached idefloppy_release
ide-floppy: creating prevent removal command, prevent =3D 0
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
Reached idefloppy_open
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 44 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
Descriptor 0 Code: 2
Descriptor 0: 1440kB, 2880 blocks, 512 sector size
Descriptor 1: 1440kB, 2880 blocks, 512 sector size
Descriptor 2: 1200kB, 2400 blocks, 512 sector size
Descriptor 3: 1232kB, 1232 blocks, 1024 sector size
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 40 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
ide-floppy: creating prevent removal command, prevent =3D 1
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request
 hdb:<6>rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 2848, nr_sectors: 32, current_nr_sectors: 1
create_rw10_cmd: block =3D 2848, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 32, current_nr_sectors: 2
create_rw10_cmd: block =3D 0, blocks =3D 32
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
Reached idefloppy_end_request
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 16384 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
 hdb1 hdb2 hdb4
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 0, nr_sectors: 1, current_nr_sectors: 1
create_rw10_cmd: block =3D 0, blocks =3D 1
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 512 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
rq_status: 1, rq_dev: 832, cmd: 0, errors: 0
sector: 19, nr_sectors: 1, current_nr_sectors: 1
create_rw10_cmd: block =3D 19, blocks =3D 1
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 512 bytes transferred
ide-floppy: Reached idefloppy_rw_callback
Reached idefloppy_end_request
Reached idefloppy_release
ide-floppy: creating prevent removal command, prevent =3D 0
rq_status: 1, rq_dev: 832, cmd: 90, errors: 0
sector: 0, nr_sectors: 0, current_nr_sectors: 0
Retry number - 0
ide-floppy: Reached idefloppy_pc_intr interrupt handler
Packet command completed, 0 bytes transferred
ide-floppy: Reached idefloppy_pc_callback
Reached idefloppy_end_request

           CPU0       CPU1       CPU2       CPU3      =20
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 32:          2          0          0          4   IO-SAPIC-edge
keyboard
 34:         12          1          0        408   IO-SAPIC-edge  ide0
 39:          0          0          0          4  IO-SAPIC-level  acpi
 48:         78         12          1       5485  IO-SAPIC-level
usb-uhci
 49:        153         10          1      15536  IO-SAPIC-level
usb-uhci
 50:          0          0          0          0  IO-SAPIC-level
ehci_hcd
 51:         20          1          0        812  IO-SAPIC-level  eth0
 54:        380         26          4       8969  IO-SAPIC-level  ioc0
 55:          0          0          0         29  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC
mca_rdzv
238:          1          1          1          1          LSAPIC
perfmon
239:     286751     276766     285562     285165          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:         27         61         44         60          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

00:1d.0 USB Controller: Intel Corp. 82801DB (ICH4) USB UHCI #1 (rev 02)
(prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 48
	Region 4: I/O ports at 5cc0 [size2]

00:1d.1 USB Controller: Intel Corp. 82801DB (ICH4) USB UHCI #2 (rev 02)
(prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 49
	Region 4: I/O ports at 5ce0 [size2]

00:1d.7 USB Controller: Intel Corp. 82801DB (ICH4) USB2 EHCI Controller
(rev 02) (prog-if 20 [EHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin D routed to IRQ 50
	Region 0: Memory at 00000000f9ff0000 (32-bit, non-prefetchable)
[size=3D1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent75mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] #0a [2080]

00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB/ER Hub interface to PCI
Bridge (rev 82) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latencyd
	I/O behind bridge: 00006000-00006fff
	Memory behind bridge: fa000000-fbffffff
	BridgeCtl: Parity+ SERR+ NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corp. 82801DB (ICH4) LPC Bridge (rev 02)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:1f.1 IDE interface: Intel Corp. 82801DB (ICH4) Ultra ATA 100 Storage
Controller (rev 02) (prog-if 8a [Master SecP PriP])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 0
	Region 0: I/O ports at <unassigned>
	Region 1: I/O ports at <unassigned>
	Region 2: I/O ports at <unassigned>
	Region 3: I/O ports at <unassigned>
	Region 4: I/O ports at 1000 [size=16]
	Region 5: Memory at <unassigned> (32-bit, non-prefetchable)
[disabled] [size=3D1K]

01:00.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
Controller (rev 02)
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (63750ns min), Cache Line Size 20
	Interrupt: pin A routed to IRQ 51
	Region 0: Memory at 00000000fbfe0000 (32-bit, non-prefetchable)
[size=128K]
	Region 2: I/O ports at 6cc0 [sized]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=3D2 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D2, DMOST=3D0, DMCRS=3D1, RSCEM-
	Capabilities: [f0] Message Signalled Interrupts: 64bit+
Queue=3D0/0 Enable-
		Address: 0000000000000000  Data: 0000

01:01.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
(prog-if 00 [VGA])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (2000ns min), Cache Line Size 20
	Region 0: Memory at 00000000fa000000 (32-bit, non-prefetchable)
[size=16M]
	Region 1: I/O ports at 6800 [size%6]
	Region 2: Memory at 00000000fbfd0000 (32-bit, non-prefetchable)
[size=3D4K]
	Expansion ROM at 00000000fbfa0000 [disabled] [size=128K]
	Capabilities: [5c] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

02:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000f3ff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D2 Dev( Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

02:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 20
	Bus: primary=02, secondary=03, subordinate=05, sec-latencyd
	I/O behind bridge: 00007000-00008fff
	Memory behind bridge: f4000000-f8cfffff
	Prefetchable memory behind bridge:
00000000e8000000-00000000f2e00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X bridge device.
		Secondary Status: 64bit+, 133MHz+, SCD-, USC-, SCO-,
SRD- Freq=3D0
		Status: Bus=3D2 Dev) Func=3D0 64bit+ 133MHz+ SCD- USC-,
SCO-, SRD-
		: Upstream: Capacitye535, Commitment Limit=3D0
		: Downstream: Capacitye535, Commitment Limit=3D0

02:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000f3fe0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D2 Dev0 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

02:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 20
	Bus: primary=02, secondary=06, subordinate=06, sec-latencyd
	I/O behind bridge: 00009000-00009fff
	Memory behind bridge: f8d00000-f8ffffff
	Prefetchable memory behind bridge:
00000000f2f00000-00000000f2f00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X bridge device.
		Secondary Status: 64bit+, 133MHz+, SCD-, USC-, SCO-,
SRD- Freq=3D0
		Status: Bus=3D2 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
SCO-, SRD-
		: Upstream: Capacitye535, Commitment Limit=3D0
		: Downstream: Capacitye535, Commitment Limit=3D0

03:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 52
	Region 0: Memory at 00000000f2ef0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D3 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

06:01.0 Ethernet controller: Intel Corp. 82543GC Gigabit Ethernet
Controller (Copper) (rev 02)
	Subsystem: Intel Corp. PRO/1000 T Server Adapter
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (63750ns min), Cache Line Size 20
	Interrupt: pin A routed to IRQ 53
	Region 0: Memory at 00000000f8fe0000 (32-bit, non-prefetchable)
[size=128K]
	Region 1: Memory at 00000000f8fd0000 (32-bit, non-prefetchable)
[sizedK]
	Expansion ROM at 00000000f8fc0000 [disabled] [sizedK]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

06:02.0 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (4250ns min, 4500ns max), Cache Line Size 20
	Interrupt: pin A routed to IRQ 54
	Region 0: I/O ports at 9800 [size%6]
	Region 1: Memory at 00000000f8f90000 (64-bit, non-prefetchable)
[sizedK]
	Region 3: Memory at 00000000f8f80000 (64-bit, non-prefetchable)
[sizedK]
	Expansion ROM at 00000000f8d00000 [disabled] [size=3D1M]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] Message Signalled Interrupts: 64bit+
Queue=3D0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [68] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D2 OST=3D0
		Status: Bus%5 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D2, DMOST=3D4, DMCRS=3D1, RSCEM-

06:02.1 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (4250ns min, 4500ns max), Cache Line Size 20
	Interrupt: pin B routed to IRQ 55
	Region 0: I/O ports at 9c00 [size%6]
	Region 1: Memory at 00000000f8fb0000 (64-bit, non-prefetchable)
[sizedK]
	Region 3: Memory at 00000000f8fa0000 (64-bit, non-prefetchable)
[sizedK]
	Expansion ROM at 00000000f8e00000 [disabled] [size=3D1M]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [58] Message Signalled Interrupts: 64bit+
Queue=3D0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [68] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D2 OST=3D0
		Status: Bus%5 Dev1 Func=3D1 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D2, DMOST=3D4, DMCRS=3D1, RSCEM-

06:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 56
	Region 0: Memory at 00000000f2ff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D6 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

08:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000e1ff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D8 Dev( Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

08:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 20
	Bus: primary=08, secondary	, subordinate
, sec-latencyd
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: e2000000-e3ffffff
	Prefetchable memory behind bridge:
00000000d3f00000-00000000d7f00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X bridge device.
		Secondary Status: 64bit+, 133MHz+, SCD-, USC-, SCO-,
SRD- Freq=3D0
		Status: Bus=3D8 Dev) Func=3D0 64bit+ 133MHz+ SCD- USC-,
SCO-, SRD-
		: Upstream: Capacitye535, Commitment Limit=3D0
		: Downstream: Capacitye535, Commitment Limit=3D0

08:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000e1fe0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D8 Dev0 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

08:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 20
	Bus: primary=08, secondary=0B, subordinate
, sec-latencyd
	I/O behind bridge: 0000b000-0000cfff
	Memory behind bridge: e4000000-e7ffffff
	Prefetchable memory behind bridge:
00000000d8000000-00000000e0f00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X bridge device.
		Secondary Status: 64bit+, 133MHz+, SCD-, USC-, SCO-,
SRD- Freq=3D0
		Status: Bus=3D8 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
SCO-, SRD-
		: Upstream: Capacitye535, Commitment Limit=3D0
		: Downstream: Capacitye535, Commitment Limit=3D0

09:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 57
	Region 0: Memory at 00000000d3ff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D9 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

0b:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 58
	Region 0: Memory at 00000000e0ff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=11 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

0e:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000cdff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=14 Dev( Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

0e:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 20
	Bus: primary=0E, secondary=0F, subordinate=10, sec-latencyd
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: ce000000-cfffffff
	Prefetchable memory behind bridge:
00000000c3f00000-00000000c7f00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X bridge device.
		Secondary Status: 64bit+, 133MHz+, SCD-, USC-, SCO-,
SRD- Freq=3D0
		Status: Bus=14 Dev) Func=3D0 64bit+ 133MHz+ SCD- USC-,
SCO-, SRD-
		: Upstream: Capacitye535, Commitment Limit=3D0
		: Downstream: Capacitye535, Commitment Limit=3D0

0e:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000cdfe0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=14 Dev0 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

0e:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 20
	Bus: primary=0E, secondary=11, subordinate=12, sec-latencyd
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: d0000000-d2ffffff
	Prefetchable memory behind bridge:
00000000c8000000-00000000ccf00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X bridge device.
		Secondary Status: 64bit+, 133MHz+, SCD-, USC-, SCO-,
SRD- Freq=3D0
		Status: Bus=14 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
SCO-, SRD-
		: Upstream: Capacitye535, Commitment Limit=3D0
		: Downstream: Capacitye535, Commitment Limit=3D0

0f:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 59
	Region 0: Memory at 00000000c3ff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=15 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

11:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 60
	Region 0: Memory at 00000000ccff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=17 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

ff:18.0 Host bridge: Intel Corp.: Unknown device 0500 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:18.1 Host bridge: Intel Corp.: Unknown device 0501 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:18.2 Host bridge: Intel Corp.: Unknown device 0502 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:18.3 Host bridge: Intel Corp.: Unknown device 0503 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:1c.0 Host bridge: Intel Corp.: Unknown device 0510 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.1 Host bridge: Intel Corp.: Unknown device 0511 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.2 Host bridge: Intel Corp.: Unknown device 0512 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

ff:1c.3 Host bridge: Intel Corp.: Unknown device 0513 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.4 Host bridge: Intel Corp.: Unknown device 0514 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.5 Host bridge: Intel Corp.: Unknown device 0515 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:1c.6 Host bridge: Intel Corp.: Unknown device 0516 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-


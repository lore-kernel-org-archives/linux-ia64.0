From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Wed, 18 Aug 2004 08:23:53 +0000
Subject: IA64 test report: 2.6.8 /tiger 2004-8-18: 9/9 pass, SCI caused kernel unaligned access
Message-Id: <9DE394C12A921946AEECE1F71944ECD52194F5@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

=20
ACPI Test Report  for 2.6 ia64 kernel=20
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
-----------------------------
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.5 on 8/17(Shanghai
time)
	2.bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.6.8 on
8/17(Shanghai time)
=09
ACPI Features Tested: (prioritized).
-----------------------------=09
1. Boot 					tested ok
2. serial console				tested ok
3. ATI (run X window system)		 	tested ok
4. usb keyboard				tested ok
5. USB mouse					tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)		tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off 				tested ok

Issue Highlight:
-------------------
kernel unaligned access when pressing power button..see dmesg log below.

Logs:
-------
Linux version 2.6.8 (root@tiger42) (gcc version 3.4.1 20040702 (Red Hat
Linux 3.4.1-2)) #2 SMP Tue Aug 17 10:24:16 EDT 2004
EFI v1.10 by INTEL: SALsystab=3D0x3fe4c8c0 ACPI=3D0x3ff84000 ACPI
2.0=3D0x3ff83000 MPS=3D0x3ff82000 SMBIOS=3D0xf0000
booting generic kernel on platform dig
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
Warning: acpi_table_parse(ACPI_SRAT) returned 0!
Warning: acpi_table_parse(ACPI_SLIT) returned 0!
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
SAL 3.1: Intel Corp                       SR870BN4
version 3.0
SAL Platform features: BusLock IRQ_Redirection
SAL: AP wakeup using external interrupt vector 0xf0
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address 0xc0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0xc618) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 4 CPUs total
Registering legacy COM ports for serial console
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffc80000
On node 0 totalpages: 63422
  DMA zone: 63422 pages, LIFO batch:4
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
Built 1 zonelists
Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux-2.6
root=3D/dev/sda2 console=3DttyS1,9600n8 console=3Dtty0 ro
PID hash table entries: 4096 (order 12: 65536 bytes)
CPU 0: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.206MHz+/--1ppm
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 6, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 5, 524288 bytes)
Placing software IO TLB between 0xe000000001668000 - 0xe000000001868000
Memory: 1005760k/1014752k available (7785k code, 20032k reserved, 2941k
data, 368k init)
McKinley Errata 9 workaround not needed; disabling it
numa_policy_init: interleaving failed
Calibrating delay loop... 2089.76 BogoMIPS
Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)
 tbxface-0117 [02] acpi_load_tables      : ACPI Tables successfully
acquired
Parsing all Control
Methods:................................................................
........................................................................
..........................
Table [DSDT](id F004) - 1385 Objects with 110 Devices 162 Methods 40
Regions
ACPI Namespace successfully loaded at root a000000100acc2c0
evxfevnt-0082 [03] acpi_enable           : System is already in ACPI
mode
Boot processor id 0x0/0xc618
task migration cache decay timeout: 10 msecs.
CPU 1: synchronized ITC with CPU 0 (last diff 13 cycles, maxerr 520
cycles)
CPU 1: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.206MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff 13 cycles, maxerr 520
cycles)
CPU 2: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.206MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff 13 cycles, maxerr 520
cycles)
CPU 3: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.206MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS
Brought up 4 CPUs
Total of 4 processors activated (8359.04 BogoMIPS).
CPU0:  online
 domain 0: span 000f
  groups: 0001 0002 0004 0008
  domain 1: span 000f
   groups: 000f
CPU1:  online
 domain 0: span 000f
  groups: 0002 0004 0008 0001
  domain 1: span 000f
   groups: 000f
CPU2:  online
 domain 0: span 000f
  groups: 0004 0008 0001 0002
  domain 1: span 000f
   groups: 000f
CPU3:  online
 domain 0: span 000f
  groups: 0008 0001 0002 0004
  domain 1: span 000f
   groups: 000f
NET: Registered protocol family 16
ACPI: Subsystem revision 20040715
kernel unaligned access to 0xe00000003fef1f5f, ip=3D0xa000000100353320
kernel unaligned access to 0xe00000003fef1f6e, ip=3D0xa000000100353320
kernel unaligned access to 0xe00000003fef1f95, ip=3D0xa000000100353320
evgpeblk-0980 [07] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs at
0000000000000C28 on int 0x9
evgpeblk-0989 [07] ev_create_gpe_block   : Found 6 Wake, Enabled 1
Runtime GPEs in this block
Completing Region/Field/Buffer/Package
initialization:.........................................................
...............
Initialized 40/40 Regions 1/1 Fields 16/16 Buffers 15/15 Packages (1394
nodes)
Executing all Device _STA and_INI
methods:................................................................
.........................................
105 Devices found containing: 105 _STA, 3 _INI methods
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.H2PB._PRT]
ACPI: PCI Root Bridge [PCI1] (00:02)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PB._PRT]
ACPI: PCI Root Bridge [PCI3] (00:08)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PB._PRT]
ACPI: PCI Root Bridge [PCI4] (00:0e)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PB._PRT]
ACPI: Device [CSFF] status [00000008]: functional but not present;
setting present
ACPI: PCI Root Bridge [CSFF] (00:ff)
SCSI subsystem initialized
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
GSI 16 (level, low) -> CPU 0 (0xc618) vector 48
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 48
GSI 19 (level, low) -> CPU 0 (0xc618) vector 49
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
GSI 23 (level, low) -> CPU 0 (0xc618) vector 50
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 50
 pci_irq-0314 [31] acpi_pci_irq_derive   : Unable to derive IRQ for
device 0000:00:1f.1
ACPI: PCI interrupt 0000:00:1f.1[A]: no GSI
GSI 18 (level, low) -> CPU 0 (0xc618) vector 51
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 18 (level, low) -> IRQ 51
GSI 71 (level, low) -> CPU 0 (0xc618) vector 52
ACPI: PCI interrupt 0000:03:1f.0[A] -> GSI 71 (level, low) -> IRQ 52
GSI 24 (level, low) -> CPU 0 (0xc618) vector 53
ACPI: PCI interrupt 0000:06:01.0[A] -> GSI 24 (level, low) -> IRQ 53
GSI 28 (level, low) -> CPU 0 (0xc618) vector 54
ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 54
GSI 29 (level, low) -> CPU 0 (0xc618) vector 55
ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 55
GSI 47 (level, low) -> CPU 0 (0xc618) vector 56
ACPI: PCI interrupt 0000:06:1f.0[A] -> GSI 47 (level, low) -> IRQ 56
GSI 119 (level, low) -> CPU 0 (0xc618) vector 57
ACPI: PCI interrupt 0000:09:1f.0[A] -> GSI 119 (level, low) -> IRQ 57
GSI 95 (level, low) -> CPU 0 (0xc618) vector 58
ACPI: PCI interrupt 0000:0b:1f.0[A] -> GSI 95 (level, low) -> IRQ 58
GSI 167 (level, low) -> CPU 0 (0xc618) vector 59
ACPI: PCI interrupt 0000:0f:1f.0[A] -> GSI 167 (level, low) -> IRQ 59
GSI 143 (level, low) -> CPU 0 (0xc618) vector 60
ACPI: PCI interrupt 0000:11:1f.0[A] -> GSI 143 (level, low) -> IRQ 60
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Total HugeTLB memory allocated, 0
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
udf: registering filesystem
Initializing Cryptographic API
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU0] (supports C1)
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
EFI Time Services Driver v0.4
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing
disabled
acpi_serial_port: zero-length IO port range?
ttyS0 at I/O 0x3f8 (irq =3D 44) is a 16550A
acpi_serial_port: zero-length IO port range?
ttyS1 at I/O 0x2f8 (irq =3D 45) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.52-k4
Copyright (c) 1999-2004 Intel Corporation.
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 18 (level, low) -> IRQ 51
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt 0000:06:01.0[A] -> GSI 24 (level, low) -> IRQ 53
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
Ethernet Channel Bonding Driver: v2.6.0 (January 14, 2004)
bonding: Warning: either miimon or arp_interval and arp_ip_target module
parameters must be specified, otherwise bonding will not detect link
failures! see bonding.txt for details.
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx
hda: MATSHITADVD-ROM SR-8177, ATAPI CD/DVD-ROM drive
hdb: LS-120/240 00 UHD Floppy, ATAPI FLOPPY drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hda: ATAPI 24X DVD-ROM drive, 256kB Cache
Uniform CD-ROM driver Revision: 3.20
st: Version 20040403, fixed bufsize 32768, s/g segs 256
osst :I: Tape driver with OnStream support version 0.99.1
osst :I: $Id: osst.c,v 1.70 2003/12/23 14:22:12 wriede Exp $
Fusion MPT base driver 3.01.09
Copyright (c) 1999-2004 LSI Logic Corporation
ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 54
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities=3D{Initiator}
ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 55
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities=3D{Initiator}
Fusion MPT SCSI Host driver 3.01.09
scsi0 : ioc0: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQT
  Vendor: MAXTOR    Model: ATLASU320_18_SCA  Rev: B120
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sda: 35916548 512-byte hdwr sectors (18389 MB)
SCSI device sda: drive cache: write back
 sda: sda1 sda2 sda3
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0
  Vendor: ESG-SHV   Model: SCA HSBP M17      Rev: 0101
  Type:   Processor                          ANSI SCSI revision: 02
Attached scsi generic sg1 at scsi0, channel 0, id 6, lun 0,  type 3
scsi1 : ioc1: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQU
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 50
ehci_hcd 0000:00:1d.7: Intel Corp. 82801DB (ICH4) USB2 EHCI Controller
ehci_hcd 0000:00:1d.7: irq 50, pci mem c0000000f9ff0000
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
PCI: slot 0000:00:1d.7 has incorrect PCI cache line size of 0 bytes,
correcting to 128
ehci_hcd 0000:00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2004-May-10
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 4 ports detected
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ohci_hcd: block sizes: ed 80 td 96
USB Universal Host Controller Interface driver v2.2
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 48
uhci_hcd 0000:00:1d.0: Intel Corp. 82801DB (ICH4) USB UHCI #1
uhci_hcd 0000:00:1d.0: irq 48, io base 0000000000005cc0
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB (ICH4) USB UHCI #2
uhci_hcd 0000:00:1d.1: irq 49, io base 0000000000005ce0
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
usb 2-2: new full speed USB device using address 2
hub 2-2:1.0: USB hub found
hub 2-2:1.0: 4 ports detected
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
usb 2-2.1: new low speed USB device using address 3
input<6>NET: Registered protocol family 2
: USB HID v1.10 Keyboard [SOLIDTEK USB Composite Keyboard] on
usb-0000:00:1d.0-2.1
IP: routing cache hash table of 16384 buckets, 256Kbytes
drivers/usb/input/hid-core.c: ctrl urb status -32 received
drivers/usb/input/hid-core.c: ctrl urb status -32 received
drivers/usb/input/hid-core.c: ctrl urb status -32 received
input,hiddev96: USB HID v1.10 Device [SOLIDTEK USB Composite Keyboard]
on usb-0000:00:1d.0-2.1
TCP: Hash tables configured (established 131072 bind 65536)
arp_tables: (C) 2002 David S. Miller
NET: Registered protocol family 1
NET: Registered protocol family 17
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 368kB freed
EXT3 FS on sda2, internal journal
device-mapper: 4.1.0-ioctl (2003-12-10) initialised: dm@uk.sistina.com
hda: packet command error: status=3D0x51 { DriveReady SeekComplete Error }
hda: packet command error: error=3D0x54
cdrom: open failed.
Adding 2047968k swap on /dev/sda3.  Priority:-1 extents:1
e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex
hda: packet command error: status=3D0x51 { DriveReady SeekComplete Error }
hda: packet command error: error=3D0x54
cdrom: open failed.
hda: packet command error: status=3D0x51 { DriveReady SeekComplete Error }
hda: packet command error: error=3D0x54
cdrom: open failed.
ide-floppy driver 0.99.newide
hdb: 123264kB, 246528 blocks, 512 sector size
hdb: 123264kB, 963/8/32 CHS, 1416 kBps, 512 sector size, 1500 rpm
 hdb: unknown partition table
 hdb: unknown partition table
 hdb: unknown partition table
drivers/usb/input/hid-input.c: event field not found
drivers/usb/input/hid-input.c: event field not found
 hdb: unknown partition table
usb 3-2: new low speed USB device using address 2
drivers/usb/input/hid-core.c: ctrl urb status -32 received
input: USB HID v1.00 Mouse [04b3:310b] on usb-0000:00:1d.1-2
 hdb: unknown partition table
kernel unaligned access to 0xe00000003fef1f53, ip=3D0xa0000001003528e0
kernel unaligned access to 0xe00000003fef1f5f, ip=3D0xa0000001003528e0
kernel unaligned access to 0xe00000003fef1f53, ip=3D0xa00000010033a071
kernel unaligned access to 0xe00000003fef1f5f, ip=3D0xa00000010033a080
kernel unaligned access to 0xe00000003fef1f53, ip=3D0xa0000001003528e0
kernel unaligned access to 0xe00000003fef1f5f, ip=3D0xa0000001003528e0
kernel unaligned access to 0xe00000003fef1f53, ip=3D0xa00000010033a071
kernel unaligned access to 0xe00000003fef1f5f, ip=3D0xa00000010033a080

           CPU0       CPU1       CPU2       CPU3      =20
 28:          0          0          0          0          LSAPIC
cpe_poll
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 34:          2       1097         97         30   IO-SAPIC-edge  ide0
 39:          0          5          0          0  IO-SAPIC-level  acpi
 45:          0        599          6          0   IO-SAPIC-edge  serial
 48:          0       4755        154          0  IO-SAPIC-level
uhci_hcd
 49:          1       2265         59          1  IO-SAPIC-level
uhci_hcd
 50:          0          2          2          0  IO-SAPIC-level
ehci_hcd
 51:         36      60531      16298       1220  IO-SAPIC-level  eth0
 54:         72      29024       3505        326  IO-SAPIC-level  ioc0
 55:          0         29          0          0  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC
mca_rdzv
238:          0          0          0          0          LSAPIC
perfmon
239:   13022778   13018928   13018740   13018512          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:        799        643        784        918          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

00:1d.0 USB Controller: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)
USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 48
	Region 4: I/O ports at 5cc0 [size2]

00:1d.1 USB Controller: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)
USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 49
	Region 4: I/O ports at 5ce0 [size2]

00:1d.7 USB Controller: Intel Corp. 82801DB/DBM (ICH4/ICH4-M) USB 2.0
EHCI Controller (rev 02) (prog-if 20 [EHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin D routed to IRQ 50
	Region 0: Memory at 00000000f9ff0000 (32-bit, non-prefetchable)
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
	Expansion ROM at 0000000000006000 [disabled] [size=3D4K]
	BridgeCtl: Parity+ SERR+ NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corp. 82801DB/DBL (ICH4/ICH4-L) LPC Bridge
(rev 02)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:1f.1 IDE interface: Intel Corp. 82801DB/DBL (ICH4/ICH4-L)
UltraATA-100 IDE Controller (rev 02) (prog-if 8a [Master SecP PriP])
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
[size=00000000fbfa0000]
	Region 1: I/O ports at 6800 [size%6]
	Region 2: Memory at 00000000fbfd0000 (32-bit, non-prefetchable)
[size=3D4K]
	Expansion ROM at 0000000000020000 [disabled]
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
	Expansion ROM at 0000000000007000 [disabled] [size=3D8K]
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
	Expansion ROM at 0000000000009000 [disabled] [size=3D4K]
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
[size=00000000f8fc0000]
	Region 1: Memory at 00000000f8fd0000 (32-bit, non-prefetchable)
[sizedK]
	Expansion ROM at 0000000000010000 [disabled]
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
	Region 0: I/O ports at 9800 [size=00000000f8d00000]
	Region 1: Memory at 00000000f8f90000 (64-bit, non-prefetchable)
[sizedK]
	Region 3: Memory at 00000000f8f80000 (64-bit, non-prefetchable)
[sizedK]
	Expansion ROM at 0000000000100000 [disabled]
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
	Region 0: I/O ports at 9c00 [size=00000000f8e00000]
	Region 1: Memory at 00000000f8fb0000 (64-bit, non-prefetchable)
[sizedK]
	Region 3: Memory at 00000000f8fa0000 (64-bit, non-prefetchable)
[sizedK]
	Expansion ROM at 0000000000100000 [disabled]
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
	Expansion ROM at 000000000000a000 [disabled] [size=3D4K]
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
	Expansion ROM at 000000000000b000 [disabled] [size=3D8K]
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
	Expansion ROM at 000000000000d000 [disabled] [size=3D4K]
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
	Expansion ROM at 000000000000e000 [disabled] [size=3D4K]
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
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=17 Dev1 Func=3D0 64bit+ 133MHz+ SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-

ff:18.0 Host bridge: Intel Corp. E8870 Processor bus control (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:18.1 Host bridge: Intel Corp. E8870 Memory controller (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:18.2 Host bridge: Intel Corp. E8870 Scalability Port 0 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:18.3 Host bridge: Intel Corp. E8870 Scalability Port 1 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:1c.0 Host bridge: Intel Corp. E8870IO Hub Interface Port 0 registers
(8-bit compatibility port) (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.1 Host bridge: Intel Corp. E8870IO Hub Interface Port 1 registers
(rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.2 Host bridge: Intel Corp. E8870IO Hub Interface Port 2 registers
(rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

ff:1c.3 Host bridge: Intel Corp. E8870IO Hub Interface Port 3 registers
(rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.4 Host bridge: Intel Corp. E8870IO Hub Interface Port 4 registers
(rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0

ff:1c.5 Host bridge: Intel Corp. E8870IO General SIOH registers (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

ff:1c.6 Host bridge: Intel Corp. E8870IO RAS registers (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

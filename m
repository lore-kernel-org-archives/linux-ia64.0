From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Wed, 30 Jun 2004 09:14:26 +0000
Subject: IA64 test report: 2.6.7 /tiger 2004-6-30: 9/9 pass
Message-Id: <6E0C289723A0564F9A8279E236E8565F07AF494B@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

=20
ACPI Test Report  for 2.6 ia64 kernel=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DHardware Configuration:
-----------------------
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
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.5 on 6/2(Shanghai
time)
	2.bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.6.7 on
6/2(Shanghai time)
=09
ACPI Features Tested: (prioritized).
--------------------=09
1. Boot 					tested ok
2. serial console				tested ok
3. ATI (run X window system)		tested ok
4. usb keyboard				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off 			tested ok


Linux version 2.6.7 (root@acpi-tiger) (gcc version 3.2.3 20030502 (Red
Hat Linux 3.2.3-20)) #6 SMP Wed Jun 30 17:00:09 CST 2004
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
ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0xc6] lsapic_eid[0x18] enabled)
CPU 0 (0xc618) enabled (BSP)
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0xc0] lsapic_eid[0x18] enabled)
CPU 1 (0xc018) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0xc4] lsapic_eid[0x18] enabled)
CPU 2 (0xc418) enabled
ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0xc2] lsapic_eid[0x18] enabled)
CPU 3 (0xc218) enabled
ACPI: IOSAPIC (id[0x0] address[00000000fec00000] gsi_base[0])
ACPI: IOSAPIC (id[0x1] address[00000000fec10000] gsi_base[24])
ACPI: IOSAPIC (id[0x2] address[00000000fec20000] gsi_base[48])
ACPI: IOSAPIC (id[0x3] address[00000000fec30000] gsi_base[72])
ACPI: IOSAPIC (id[0x4] address[00000000fec40000] gsi_base[96])
ACPI: IOSAPIC (id[0x5] address[00000000fec50000] gsi_base[120])
ACPI: IOSAPIC (id[0x6] address[00000000fec60000] gsi_base[144])
ACPI: PLAT_INT_SRC (low level type[0x3] id[0x00c6] eid[0x18]
iosapic_vector[0x1e] global_irq[0x16]
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0xc618) vector 30
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 4 CPUs total
Registering legacy COM ports for serial console
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffc80000
On node 0 totalpages: 63335
  DMA zone: 63335 pages, LIFO batch:4
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
Built 1 zonelists
Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux.26
root=3D/dev/sda2 console=3DttyS1,9600n8 console=3Dtty0 ro
PID hash table entries: 4096 (order 12: 65536 bytes)
CPU 0: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.209MHz+/--1ppm
Console: colour VGA+ 80x25
Placing software IO TLB between 0xe0000000015ec000 - 0xe0000000017ec000
Memory: 1004864k/1013360k available (8402k code, 20688k reserved, 3505k
data, 656k init)
McKinley Errata 9 workaround not needed; disabling it
Calibrating delay loop... 2089.76 BogoMIPS
Dentry cache hash table entries: 131072 (order: 6, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 5, 524288 bytes)
Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)
Boot processor id 0x0/0xc618
task migration cache decay timeout: 10 msecs.
CPU 1: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 513
cycles)
CPU 1: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.209MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 513
cycles)
CPU 2: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.209MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 513
cycles)
CPU 3: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.209MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS
Brought up 4 CPUs
Total of 4 processors activated (8359.04 BogoMIPS).
CPU0:  online
 domain 0: span 0000000f
  groups: 00000001 00000002 00000004 00000008
  domain 1: span 0000000f
   groups: 0000000f
CPU1:  online
 domain 0: span 0000000f
  groups: 00000002 00000004 00000008 00000001
  domain 1: span 0000000f
   groups: 0000000f
CPU2:  online
 domain 0: span 0000000f
  groups: 00000004 00000008 00000001 00000002
  domain 1: span 0000000f
   groups: 0000000f
CPU3:  online
 domain 0: span 0000000f
  groups: 00000008 00000001 00000002 00000004
  domain 1: span 0000000f
   groups: 0000000f
NET: Registered protocol family 16
ACPI: Subsystem revision 20040615
 tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully
acquired
Parsing all Control
Methods:................................................................
........................................................................
..........................
Table [DSDT](id F004) - 1385 Objects with 110 Devices 162 Methods 40
Regions
ACPI Namespace successfully loaded at root a000000100bf2388
evxfevnt-0082 [04] acpi_enable           : System is already in ACPI
mode
kernel unaligned access to 0xe00000003f9ee207, ip=3D0xa000000100384360
kernel unaligned access to 0xe00000003f9ee216, ip=3D0xa000000100384360
kernel unaligned access to 0xe00000003f9ee23d, ip=3D0xa000000100384360
evgpeblk-0979 [06] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs at
0000000000000C28 on int 0x9
evgpeblk-0988 [06] ev_create_gpe_block   : Found 6 Wake, Enabled 1
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
ACPI: PCI Root Bridge [PCI3] (00:09)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PB._PRT]
ACPI: PCI Root Bridge [PCI4] (00:0f)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PB._PRT]
ACPI: Device [CSFF] status [00000008]: functional but not present;
setting present
ACPI: PCI Root Bridge [CSFF] (00:ff)
SCSI subsystem initialized
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
GSI 16 (level, low) -> CPU 2 (0xc418) vector 48
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 48
GSI 19 (level, low) -> CPU 2 (0xc418) vector 49
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
GSI 23 (level, low) -> CPU 2 (0xc418) vector 50
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 50
 pci_irq-0314 [24] acpi_pci_irq_derive   : Unable to derive IRQ for
device 0000:00:1f.1
ACPI: PCI interrupt 0000:00:1f.1[A]: no GSI
GSI 18 (level, low) -> CPU 2 (0xc418) vector 51
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 18 (level, low) -> IRQ 51
GSI 71 (level, low) -> CPU 2 (0xc418) vector 52
ACPI: PCI interrupt 0000:03:1f.0[A] -> GSI 71 (level, low) -> IRQ 52
GSI 28 (level, low) -> CPU 2 (0xc418) vector 53
ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 53
GSI 29 (level, low) -> CPU 2 (0xc418) vector 54
ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 54
GSI 47 (level, low) -> CPU 2 (0xc418) vector 55
ACPI: PCI interrupt 0000:06:1f.0[A] -> GSI 47 (level, low) -> IRQ 55
GSI 119 (level, low) -> CPU 2 (0xc418) vector 56
ACPI: PCI interrupt 0000:0a:1f.0[A] -> GSI 119 (level, low) -> IRQ 56
GSI 95 (level, low) -> CPU 2 (0xc418) vector 57
ACPI: PCI interrupt 0000:0c:1f.0[A] -> GSI 95 (level, low) -> IRQ 57
GSI 167 (level, low) -> CPU 2 (0xc418) vector 58
ACPI: PCI interrupt 0000:10:1f.0[A] -> GSI 167 (level, low) -> IRQ 58
GSI 120 (level, low) -> CPU 2 (0xc418) vector 59
ACPI: PCI interrupt 0000:12:01.0[A] -> GSI 120 (level, low) -> IRQ 59
GSI 143 (level, low) -> CPU 2 (0xc418) vector 60
ACPI: PCI interrupt 0000:12:1f.0[A] -> GSI 143 (level, low) -> IRQ 60
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Total HugeTLB memory allocated, 0
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
EFI Time Services Driver v0.4
Linux agpgart interface v0.100 (c) Dave Jones
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
acpi_serial_port: zero-length IO port range?
ttyS0 at I/O 0x3f8 (irq =3D 44) is a 16550A
acpi_serial_port: zero-length IO port range?
ttyS1 at I/O 0x2f8 (irq =3D 45) is a 16550A
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.52-k4
Copyright (c) 1999-2004 Intel Corporation.
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 18 (level, low) -> IRQ 51
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt 0000:12:01.0[A] -> GSI 120 (level, low) -> IRQ 59
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
Linux video capture interface: v1.00
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx
ICH4: IDE controller at PCI slot 0000:00:1f.1
PCI: Device 0000:00:1f.1 not available because of resource collisions
 pci_irq-0314 [24] acpi_pci_irq_derive   : Unable to derive IRQ for
device 0000:00:1f.1
ACPI: PCI interrupt 0000:00:1f.1[A]: no GSI
ICH4: BIOS configuration fixed.
ICH4: chipset revision 2
ICH4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:pio, hdd:pio
hda: MATSHITADVD-ROM SR-8177, ATAPI CD/DVD-ROM drive
hdb: LS-120/240 00 UHD Floppy, ATAPI FLOPPY drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hda: ATAPI 24X DVD-ROM drive, 256kB Cache
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
hdb: No disk in drive
hdb: 234752kB, 262/32/56 CHS, 2995 kBps, 512 sector size, 1500 rpm
Fusion MPT base driver 3.01.06
Copyright (c) 1999-2004 LSI Logic Corporation
ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 53
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities=3D{Initiator}
ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 54
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities=3D{Initiator}
Fusion MPT SCSI Host driver 3.01.06
scsi0 : ioc0: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQS
  Vendor: SEAGATE   Model: ST318406LC        Rev: 8A03
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sda: 35566478 512-byte hdwr sectors (18210 MB)
SCSI device sda: drive cache: write through
 sda: sda1 sda2 sda3
Attached scsi disk sda at scsi0, channel 0, id 1, lun 0
Attached scsi generic sg0 at scsi0, channel 0, id 1, lun 0,  type 0
  Vendor: ESG-SHV   Model: SCA HSBP M17      Rev: 0101
  Type:   Processor                          ANSI SCSI revision: 02
Attached scsi generic sg1 at scsi0, channel 0, id 6, lun 0,  type 3
scsi1 : ioc1: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQT
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
uhci_hcd 0000:00:1d.0: irq 48, io base 0000000000004cc0
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB (ICH4) USB UHCI #2
uhci_hcd 0000:00:1d.1: irq 49, io base 0000000000004ce0
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
usbcore: registered new driver kbtab
drivers/usb/input/kbtab.c: v0.0.2:USB KB Gear JamStudio Tablet driver
mice: PS/2 mouse device common for all mice
usbcore: registered new driver iforce
serio: i8042 AUX port at 0x60,0x64 irq 36
atkbd.c: keyboard reset failed on isa0060/serio1
usb 3-1: new full speed USB device using address 2
hub 3-1:1.0: USB hub found
hub 3-1:1.0: 7 ports detected
serio: i8042 KBD port at 0x60,0x64 irq 32
usb 3-1.1: new low speed USB device using address 3
atkbd.c: keyboard reset failed on isa0060/serio0
input: USB HID v1.10 Keyboard [SOLIDTEK USB Composite Keyboard] on
usb-0000:00:1d.1-1.1
drivers/usb/input/hid-core.c: ctrl urb status -32 received
EFI Variables Facility v0.08 2004-May-17
drivers/usb/input/hid-core.c: ctrl urb status -32 received
drivers/usb/input/hid-core.c: ctrl urb status -32 received
input,hiddev96: USB HID v1.10 Device [SOLIDTEK USB Composite Keyboard]
on usb-0000:00:1d.1-1.1
NET: Registered protocol family 2
IP: routing cache hash table of 16384 buckets, 256Kbytes
usb 3-1.3: new low speed USB device using address 4
TCP: Hash tables configured (established 131072 bind 65536)
input: USB HID v1.10 Mouse [Microsoft Microsoft 5-Button Mouse with
IntelliEye(TM)] on usb-0000:00:1d.1-1.3
NET: Registered protocol family 1
NET: Registered protocol family 17
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 656kB freed
usb 3-1.4: new low speed USB device using address 5
input: USB HID v1.00 Keyboard [Tangtop Generic KVM104UC] on
usb-0000:00:1d.1-1.4
input: USB HID v1.00 Mouse [Tangtop Generic KVM104UC] on
usb-0000:00:1d.1-1.4
EXT3 FS on sda2, internal journal
Adding 2024144k swap on /dev/sda3.  Priority:-1 extents:1
partx(220): unaligned access to 0x600000000000ca16,
ip=3D0x4000000000002ce1
partx(220): unaligned access to 0x600000000000ca26,
ip=3D0x4000000000002ce1
partx(220): unaligned access to 0x600000000000ca36,
ip=3D0x4000000000002ce1
partx(220): unaligned access to 0x600000000000ca46,
ip=3D0x4000000000002ce1
Unable to load NLS charset cp437
Unable to load NLS charset iso8859-1
Unable to load NLS charset iso8859-1
e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex
ACPI: Power Button (FF) [PWRF]
kernel unaligned access to 0xe00000003f9ee1fb, ip=3D0xa000000100383e01
kernel unaligned access to 0xe00000003f9ee207, ip=3D0xa000000100383e01
kernel unaligned access to 0xe00000003f9ee1fb, ip=3D0xa000000100369800
kernel unaligned access to 0xe00000003f9ee207, ip=3D0xa000000100369801
kernel unaligned access to 0xe00000003f9ee1fb, ip=3D0xa000000100383e01
kernel unaligned access to 0xe00000003f9ee207, ip=3D0xa000000100383e01
kernel unaligned access to 0xe00000003f9ee1fb, ip=3D0xa000000100369800
kernel unaligned access to 0xe00000003f9ee207, ip=3D0xa000000100369801

           CPU0       CPU1       CPU2       CPU3      =20
 28:          0          0          0          0          LSAPIC
cpe_poll
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 34:          0         27          1          0   IO-SAPIC-edge  ide0
 39:          0          7          0          1  IO-SAPIC-level  acpi
 45:          0       1048          0          7   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level
uhci_hcd
 49:          0       4658          9        242  IO-SAPIC-level
uhci_hcd
 50:          0          0          0          2  IO-SAPIC-level
ehci_hcd
 51:          0       1171          0         49  IO-SAPIC-level  eth0
 53:          0       4416          1         67  IO-SAPIC-level  ioc0
 54:          0         44          0          0  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC
mca_rdzv
238:          0          0          0          0          LSAPIC
perfmon
239:     536756     532388     532155     531922          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:         80         53         44         87          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

00:1d.0 USB Controller: Intel Corp. 82801DB USB (Hub #1) (rev 02)
(prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 48
	Region 4: I/O ports at 4cc0 [size2]

00:1d.1 USB Controller: Intel Corp. 82801DB USB (Hub #2) (rev 02)
(prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 49
	Region 4: I/O ports at 4ce0 [size2]

00:1d.7 USB Controller: Intel Corp. 82801DB USB2 (rev 02) (prog-if 20
[EHCI])
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

00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB PCI Bridge (rev 82)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latencyd
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: fa000000-fbffffff
	BridgeCtl: Parity+ SERR+ NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corp. 82801DB LPC Interface Controller (rev
02)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:1f.1 IDE interface: Intel Corp. 82801DB Ultra ATA Storage Controller
(rev 02) (prog-if 8a [Master SecP PriP])
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
	Latency: 64 (63750ns min), cache line size 20
	Interrupt: pin A routed to IRQ 51
	Region 0: Memory at 00000000fbfe0000 (32-bit, non-prefetchable)
[size=128K]
	Region 2: I/O ports at 5cc0 [sized]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=3D2 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-	Capabilities: [f0]
Message Signalled Interrupts: 64bit+ Queue=3D0/0 Enable-
		Address: 0000000000000000  Data: 0000

01:01.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
(prog-if 00 [VGA])
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (2000ns min), cache line size 20
	Region 0: Memory at 00000000fa000000 (32-bit, non-prefetchable)
[size=16M]
	Region 1: I/O ports at 5800 [size%6]
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
	Region 0: Memory at 00000000f1ff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
02:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, cache line size 20
	Bus: primary=02, secondary=03, subordinate=05, sec-latencyd
	I/O behind bridge: 00006000-00007fff
	Memory behind bridge: f2000000-f5ffffff
	Prefetchable memory behind bridge:
00000000e3f00000-00000000ebf00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE+ ERO+ RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
02:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000f1fe0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
02:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, cache line size 20
	Bus: primary=02, secondary=06, subordinate=07, sec-latencyd
	I/O behind bridge: 00008000-00009fff
	Memory behind bridge: f6000000-f8ffffff
	Prefetchable memory behind bridge:
00000000ec000000-00000000f0f00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE+ ERO+ RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
03:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 52
	Region 0: Memory at 00000000e3ff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
06:02.0 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (4250ns min, 4500ns max), cache line size 20
	Interrupt: pin A routed to IRQ 53
	Region 0: I/O ports at 8800 [size%6]
	Region 1: Memory at 00000000f8fd0000 (64-bit, non-prefetchable)
[sizedK]
	Region 3: Memory at 00000000f8fc0000 (64-bit, non-prefetchable)
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
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
06:02.1 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: Intel Corp.: Unknown device 3402
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (4250ns min, 4500ns max), cache line size 20
	Interrupt: pin B routed to IRQ 54
	Region 0: I/O ports at 8c00 [size%6]
	Region 1: Memory at 00000000f8ff0000 (64-bit, non-prefetchable)
[sizedK]
	Region 3: Memory at 00000000f8fe0000 (64-bit, non-prefetchable)
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
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
06:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 55
	Region 0: Memory at 00000000f0ff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
09:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000dbff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
09:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, cache line size 20
	Bus: primary	, secondary
, subordinate=0B, sec-latencyd
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: dc000000-ddffffff
	Prefetchable memory behind bridge:
00000000cbf00000-00000000cff00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE+ ERO+ RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
09:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000dbfe0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
09:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, cache line size 20
	Bus: primary	, secondary=0C, subordinate=0E, sec-latencyd
	I/O behind bridge: 0000b000-0000cfff
	Memory behind bridge: de000000-e2ffffff
	Prefetchable memory behind bridge:
00000000d0000000-00000000daf00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE+ ERO+ RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
0a:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 56
	Region 0: Memory at 00000000cbff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
0c:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 57
	Region 0: Memory at 00000000daff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
0f:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000c7ff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
0f:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, cache line size 20
	Bus: primary=0F, secondary=10, subordinate=11, sec-latencyd
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: c8000000-caefffff
	Prefetchable memory behind bridge:
00000000c0000000-00000000c6e00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE+ ERO+ RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
0f:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: Memory at 00000000c7fe0000 (32-bit, non-prefetchable)
[size=3D4K]
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
0f:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, cache line size 20
	Bus: primary=0F, secondary=12, subordinate=12, sec-latencyd
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: caf00000-caffffff
	Prefetchable memory behind bridge:
00000000c6f00000-00000000c6f00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE+ ERO+ RBC=3D0 OST=3D4
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
10:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 58
	Region 0: Memory at 00000000c6ef0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
12:01.0 Ethernet controller: Intel Corp. 82545EM Gigabit Ethernet
Controller (Copper) (rev 01)
	Subsystem: Intel Corp. PRO/1000 MT Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (63750ns min), cache line size 20
	Interrupt: pin A routed to IRQ 59
	Region 0: Memory at 00000000cafe0000 (64-bit, non-prefetchable)
[size=128K]
	Region 4: I/O ports at ecc0 [sized]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=3D2 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-	Capabilities: [f0]
Message Signalled Interrupts: 64bit+ Queue=3D0/0 Enable-
		Address: 0000000000000000  Data: 0000

12:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 60
	Region 0: Memory at 00000000c6ff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
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



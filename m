From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Wed, 30 Jun 2004 09:14:33 +0000
Subject: IA64 test report: 2.4.27-rc1 /tiger 2004-6-30: 9/9 pass
Message-Id: <6E0C289723A0564F9A8279E236E8565F07AF494C@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

=20
ACPI Test Report  for 2.4 ia64 kernel=20
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
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.4 on 6/2(Shanghai
time)
	2.bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.4.27on
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


Linux version 2.4.27-rc1 (root@acpi-tiger) (gcc version 3.2.3 20030502
(Red Hat Linux 3.2.3-20)) #3 SMP Wed Jun 30 15:56:37 CST 2004
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
ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0xc2] lsapic_eid[0x18] enabled)
CPU 0 (0xc218) enabled (BSP)
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0xc0] lsapic_eid[0x18] enabled)
CPU 1 (0xc018) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0xc4] lsapic_eid[0x18] enabled)
CPU 2 (0xc418) enabled
ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0xc6] lsapic_eid[0x18] enabled)
CPU 3 (0xc618) enabled
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
ACPI: PLAT_INT_SRC (low level type[0x3] id[0x00c2] eid[0x18]
iosapic_vector[0x1e] global_irq[0x16]
PLATFORM int 0x3: GSI 0x16(low,level) -> CPU 0xc218 vector 30
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 4 CPUs total
MCA related initialization done
On node 0 totalpages: 63456
zone(0): 63456 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Building zonelist for node : 0
Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux.24
root=3D/dev/sda2 console=3DttyS1,9600n8 console=3Dtty0 ro
FPSWA interface at 0x3ff22010, revision 1.18
CPU 0: base freq=199.458MHz, ITC ratio=14/2, ITC freq=1396.211MHz
Console: colour VGA+ 80x25
Calibrating delay loop... 2089.76 BogoMIPS
Placing software IO TLB between 0xe0000000015a0000 - 0xe0000000017a0000
Memory: 1007456k/1015296k available (7137k code, 7872k reserved, 2728k
data, 528k init)
Dentry cache hash table entries: 65536 (order: 6, 1048576 bytes)
Inode cache hash table entries: 65536 (order: 6, 1048576 bytes)
Mount cache hash table entries: 1024 (order: 0, 16384 bytes)
Buffer cache hash table entries: 65536 (order: 5, 524288 bytes)
Page-cache hash table entries: 65536 (order: 5, 524288 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0xc218
SMP: starting up secondaries.
CPU 1: 61 virtual and 50 physical address bits
CPU 1: base freq=199.458MHz, ITC ratio=14/2, ITC freq=1396.211MHz
Calibrating delay loop... 1607.96 BogoMIPS
CPU 1: synchronized ITC with CPU 0 (last diff -2 cycles, maxerr 527
cycles)
CPU1: CPU has booted.
CPU 2: 61 virtual and 50 physical address bits
CPU 2: base freq=199.458MHz, ITC ratio=14/2, ITC freq=1396.211MHz
Calibrating delay loop... 1607.96 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff -2 cycles, maxerr 527
cycles)
CPU2: CPU has booted.
CPU 3: 61 virtual and 50 physical address bits
CPU 3: base freq=199.458MHz, ITC ratio=14/2, ITC freq=1396.211MHz
Calibrating delay loop... 1607.96 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff -2 cycles, maxerr 527
cycles)
CPU3: CPU has booted.
Before bogomips.
Total of 4 processors activated (6912.64 BogoMIPS).
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
ACPI Namespace successfully loaded at root e000000004e025a0
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
alloc 0x0-0x5fff from PCI IO for PCI Bus 00:00 failed
PCI: Ignoring BAR0-3 of IDE controller 00:1f.1
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.H2PB._PRT]
ACPI: PCI Root Bridge [PCI1] (00:02)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PB._PRT]
ACPI: PCI Root Bridge [PCI2] (00:08)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
ACPI: PCI Root Bridge [PCI3] (00:09)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3.P2PB._PRT]
ACPI: PCI Root Bridge [PCI4] (00:0f)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4.P2PB._PRT]
ACPI: PCI Root Bridge [CSFF] (00:ff)
PCI->APIC IRQ transform: (00:1d.0 INTA) -> CPU 0xc218 vector 48
PCI->APIC IRQ transform: (00:1d.1 INTB) -> CPU 0xc218 vector 49
PCI->APIC IRQ transform: (00:1d.7 INTD) -> CPU 0xc218 vector 50
PCI: no interrupt route for 00:00:1f pin A
PCI->APIC IRQ transform: (01:00.0 INTA) -> CPU 0xc218 vector 51
PCI->APIC IRQ transform: (03:1f.0 INTA) -> CPU 0xc218 vector 52
PCI->APIC IRQ transform: (06:02.0 INTA) -> CPU 0xc218 vector 53
PCI->APIC IRQ transform: (06:02.1 INTB) -> CPU 0xc218 vector 54
PCI->APIC IRQ transform: (06:1f.0 INTA) -> CPU 0xc218 vector 55
PCI->APIC IRQ transform: (0a:1f.0 INTA) -> CPU 0xc218 vector 56
PCI->APIC IRQ transform: (0c:1f.0 INTA) -> CPU 0xc218 vector 57
PCI->APIC IRQ transform: (10:1f.0 INTA) -> CPU 0xc218 vector 58
PCI->APIC IRQ transform: (12:01.0 INTA) -> CPU 0xc218 vector 59
PCI->APIC IRQ transform: (12:1f.0 INTA) -> CPU 0xc218 vector 60
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
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.52-k3
Copyright (c) 1999-2004 Intel Corporation.
PCI: Found IRQ 51 for device 01:00.0
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
PCI: Found IRQ 59 for device 12:01.0
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
Linux agpgart interface v0.99 (c) Jeff Hartmann
agpgart: Maximum main memory to use for agp memory: 909M
agpgart: no supported devices found.
[drm] Initialized r128 2.2.0 20010917 on minor 0
[drm] Initialized radeon 1.7.0 20020828 on minor 1
Uniform Multi-Platform E-IDE driver Revision: 7.00beta4-2.4
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx
ICH4: IDE controller at PCI slot 00:1f.1
PCI: Device 00:1f.1 not available because of resource collisions
PCI: Found IRQ 0 for device 00:1f.1
ICH4: Not fully BIOS configured!
ICH4: chipset revision 2
ICH4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:pio, hdd:pio
hda: MATSHITADVD-ROM SR-8177, ATAPI CD/DVD-ROM drive
hdb: LS-120/240 00 UHD Floppy, ATAPI FLOPPY drive
global_restore_flags: 10084a6010 (e000000004bf8aa0)
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hda: attached ide-cdrom driver.
hda: ATAPI 24X DVD-ROM drive, 256kB Cache
Uniform CD-ROM driver Revision: 3.12
hdb: attached ide-floppy driver.
hdb: No disk in drive
hdb: 234752kB, 262/32/56 CHS, 2995 kBps, 512 sector size, 1500 rpm
SCSI subsystem driver Revision: 1.00
scsi0 : SCSI host adapter emulation for IDE ATAPI devices
Fusion MPT base driver 2.05.16
Copyright (c) 1999-2004 LSI Logic Corporation
PCI: Found IRQ 53 for device 06:02.0
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities=3D{Initiator}
PCI: Found IRQ 54 for device 06:02.1
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities=3D{Initiator}
mptbase: 2 MPT adapters found, 2 installed.
Fusion MPT SCSI Host driver 2.05.16
scsi1 : ioc0: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQS
scsi2 : ioc1: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQT
blk: queue e00000003f9fa330, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
  Vendor: SEAGATE   Model: ST318406LC        Rev: 8A03
  Type:   Direct-Access                      ANSI SCSI revision: 03
blk: queue e00000003f9fa130, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
  Vendor: ESG-SHV   Model: SCA HSBP M17      Rev: 0101
  Type:   Processor                          ANSI SCSI revision: 02
blk: queue e00000003f9f9d30, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
Attached scsi disk sda at scsi1, channel 0, id 1, lun 0
Attached scsi generic sg1 at scsi1, channel 0, id 6, lun 0,  type 3
SCSI device sda: 35566478 512-byte hdwr sectors (18210 MB)
Partition check:
 sda: sda1 sda2 sda3
cs4281: version v1.30.64 time 15:26:55 Jun 30 2004
cs4281: Unable to locate any cs4281 device with valid IDs 0x1013-0x6005
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
host/usb-uhci.c: $Revision: 1.275 $ time 15:56:45 Jun 30 2004
host/usb-uhci.c: High bandwidth mode enabled
PCI: Found IRQ 48 for device 00:1d.0
host/usb-uhci.c: USB UHCI at I/O 0x4cc0, IRQ 48
host/usb-uhci.c: Detected 2 ports
usb.c: new USB bus registered, assigned bus number 2
hub.c: USB hub found
hub.c: 2 ports detected
PCI: Found IRQ 49 for device 00:1d.1
host/usb-uhci.c: USB UHCI at I/O 0x4ce0, IRQ 49
host/usb-uhci.c: Detected 2 ports
usb.c: new USB bus registered, assigned bus number 3
hub.c: USB hub found
hub.c: 2 ports detected
host/usb-uhci.c: v1.275:USB Universal Host Controller Interface driver
usb.c: registered new driver hiddev
usb.c: registered new driver hid
hid-core.c: v1.8.1 Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>
hid-core.c: USB HID support drivers
usb.c: registered new driver kbtab
kbtab.c: v0.0.1 Josh Myer <josh@joshisanerd.com>
kbtab.c: KB Gear Jam Studio Tablet Driver
Linux video capture interface: v1.00
mice: PS/2 mouse device common for all mice
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 16384 buckets, 256Kbytes
TCP: Hash tables configured (established 131072 bind 65536)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 528kB freed
hub.c: new USB device 00:1d.1-1, assigned address 2
hub.c: USB hub found
hub.c: 7 ports detected
hub.c: new USB device 00:1d.1-1.1, assigned address 3
input: USB HID v1.10 Keyboard [SOLIDTEK USB Composite Keyboard] on
usb3:3.0
host/usb-uhci.c: interrupt, status 2, frame# 261
EXT3 FS 2.4-0.9.19, 19 August 2002 on sd(8,2), internal journal
Adding Swap: 2024144k swap-space (priority -1)
partx(184): unaligned access to 0x6000000000009ad6,
ip=3D0x4000000000002ce1
partx(184): unaligned access to 0x6000000000009ae6,
ip=3D0x4000000000002ce1
partx(184): unaligned access to 0x6000000000009af6,
ip=3D0x4000000000002ce1
partx(184): unaligned access to 0x6000000000009b06,
ip=3D0x4000000000002ce1
usb_control/bulk_msg: timeout
host/usb-uhci.c: interrupt, status 2, frame# 1171
keyboard: Timeout - AT keyboard not present?(f4)
usb_control/bulk_msg: timeout
host/usb-uhci.c: interrupt, status 2, frame# 32
usb_control/bulk_msg: timeout
input,hiddev0: USB HID v1.10 Device [SOLIDTEK USB Composite Keyboard] on
usb3:3.1
hub.c: new USB device 00:1d.1-1.3, assigned address 4
host/usb-uhci.c: interrupt, status 3, frame# 1451
input: USB HID v1.10 Mouse [Microsoft Microsoft 5-Button Mouse with
IntelliEye(TM)] on usb3:4.0
hub.c: new USB device 00:1d.1-1.4, assigned address 5
input: USB HID v1.00 Keyboard [Tangtop Generic KVM104UC] on usb3:5.0
input: USB HID v1.00 Mouse [Tangtop Generic KVM104UC] on usb3:5.1
e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex
ACPI: Power Button (FF) [PWRF]

           CPU0       CPU1       CPU2       CPU3      =20
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 32:          2          1          0          0   IO-SAPIC-edge
keyboard
 34:          2          9          0          0   IO-SAPIC-edge  ide0
 39:          0          0          0          0  IO-SAPIC-level  acpi
 45:          5        986          0          0   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level
usb-uhci
 49:        170      15268         27         12  IO-SAPIC-level
usb-uhci
 50:          0          0          0          0  IO-SAPIC-level
ehci_hcd
 51:          0        196          0          0  IO-SAPIC-level  eth0
 53:         32       3300          3          0  IO-SAPIC-level  ioc0
 54:          0         29          0          0  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC
mca_rdzv
238:          1          1          1          1          LSAPIC
perfmon
239:     146508     145452     145246     145034          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:         60         12         47         58          LSAPIC  IPI
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




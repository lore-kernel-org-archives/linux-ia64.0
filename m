From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Wed, 12 May 2004 10:45:00 +0000
Subject: IA64 test report: log out X failed: 2.4.26 /tiger 2004-5-12: 9/10  pass
Message-Id: <6E0C289723A0564F9A8279E236E8565F075DF31B@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ACPI Test Report  for 2.4 ia64 kernel + latest ACPI
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
	-----------------------
		1.Bk pull form lia64.bkbits.net/linux-ia64-2.4 on 5/12
(Shanghai time)
		2.Bk pull from
linux-acpi.bkbits.net/linux-acpi-test-2.4.26 on 5/12 (Shanghai time)
=09
ACPI Features Tested: (prioritized).
--------------------
1. Boot 					tested ok
2. serial console				tested ok
3. ATI (run X window system)		(Start X successfully; Log out
failed, forced to use Ctrl+Alt+Backspace)=09
4. usb keyboard				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off 			tested ok
10. cat /proc/acpi/event with power button  tested ok

Linux version 2.4.26 (root@acpi-tiger) (gcc version 3.2.3 20030502 (Red
Hat Linux 3.2.3-20)) #2 SMP Wed May 12 15:55:57 CST 2004
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
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0xc2] lsapic_eid[0x18] enabled)
CPU 1 (0xc218) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0xc0] lsapic_eid[0x18] enabled)
CPU 2 (0xc018) enabled
ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0xc4] lsapic_eid[0x18] enabled)
CPU 3 (0xc418) enabled
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
On node 0 totalpages: 63534
zone(0): 63534 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Building zonelist for node : 0
Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux.24
root=3D/dev/sda2 console=3DttyS1,9600n8 console=3Dtty0 ro
FPSWA interface at 0x3ff22010, revision 1.18
CPU 0: base freq=199.457MHz, ITC ratio=14/2, ITC freq=1396.204MHz
Console: colour VGA+ 80x25
Calibrating delay loop... 2089.76 BogoMIPS
Placing software IO TLB between 0xe000000001588000 - 0xe000000001788000
Memory: 1008800k/1016544k available (6104k code, 7776k reserved, 2577k
data, 528k init)
Dentry cache hash table entries: 65536 (order: 6, 1048576 bytes)
Inode cache hash table entries: 65536 (order: 6, 1048576 bytes)
Mount cache hash table entries: 1024 (order: 0, 16384 bytes)
Buffer cache hash table entries: 65536 (order: 5, 524288 bytes)
Page-cache hash table entries: 65536 (order: 5, 524288 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0xc618
SMP: starting up secondaries.
CPU 1: 61 virtual and 50 physical address bits
CPU 1: base freq=199.457MHz, ITC ratio=14/2, ITC freq=1396.204MHz
Calibrating delay loop... 1607.96 BogoMIPS
CPU 1: synchronized ITC with CPU 0 (last diff -2 cycles, maxerr 527
cycles)
CPU1: CPU has booted.
CPU 2: 61 virtual and 50 physical address bits
CPU 2: base freq=199.457MHz, ITC ratio=14/2, ITC freq=1396.204MHz
Calibrating delay loop... 1607.96 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff -2 cycles, maxerr 527
cycles)
CPU2: CPU has booted.
CPU 3: 61 virtual and 50 physical address bits
CPU 3: base freq=199.457MHz, ITC ratio=14/2, ITC freq=1396.204MHz
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
Table [DSDT](id F004) - 1388 Objects with 111 Devices 162 Methods 40
Regions
ACPI Namespace successfully loaded at root e000000004cc6580
evxfevnt-0082 [04] acpi_enable           : System is already in ACPI
mode
evgpeblk-0867 [06] ev_create_gpe_block   : GPE 00 to 31 [_GPE] 4 regs at
0000000000000C28 on int 9
evgpeblk-0925 [06] ev_create_gpe_block   : Found 6 Wake, Enabled 1
Runtime GPEs in this block
Completing Region/Field/Buffer/Package
initialization:.........................................................
................
Initialized 40/40 Regions 1/1 Fields 17/17 Buffers 15/15 Packages (1397
nodes)
Executing all Device _STA and_INI
methods:................................................................
.........................................
105 Devices found containing: 105 _STA, 3 _INI methods
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
PCI->APIC IRQ transform: (00:1d.0 INTA) -> CPU 0xc618 vector 48
PCI->APIC IRQ transform: (00:1d.1 INTB) -> CPU 0xc618 vector 49
PCI->APIC IRQ transform: (00:1d.7 INTD) -> CPU 0xc618 vector 50
PCI: no interrupt route for 00:00:1f pin A
PCI->APIC IRQ transform: (01:00.0 INTA) -> CPU 0xc618 vector 51
PCI->APIC IRQ transform: (03:1f.0 INTA) -> CPU 0xc618 vector 52
PCI->APIC IRQ transform: (06:02.0 INTA) -> CPU 0xc618 vector 53
PCI->APIC IRQ transform: (06:02.1 INTB) -> CPU 0xc618 vector 54
PCI->APIC IRQ transform: (06:1f.0 INTA) -> CPU 0xc618 vector 55
PCI->APIC IRQ transform: (0a:1f.0 INTA) -> CPU 0xc618 vector 56
PCI->APIC IRQ transform: (0c:1f.0 INTA) -> CPU 0xc618 vector 57
PCI->APIC IRQ transform: (10:1f.0 INTA) -> CPU 0xc618 vector 58
PCI->APIC IRQ transform: (12:1f.0 INTA) -> CPU 0xc618 vector 59
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
PAL Information Facility v0.5
EFI Variables Facility v0.06 2002-Dec-10
Total HugeTLB memory allocated, 0
Starting kswapd
Journalled Block Device driver loaded
Hugetlbfs mounted.
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU0] (supports C1)
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
initialize_kbd: Keyboard reset failed, no ACK
pty: 256 Unix98 ptys configured
keyboard: Timeout - AT keyboard not present?(ed)
keyboard: Timeout - AT keyboard not present?(f4)
Serial driver version 5.05c (2001-07-08) with MANY_PORTS SHARE_IRQ
DETECT_IRQ SERIAL_PCI ISAPNP SERIAL_ACPI enabled
ttyS00 at 0x03f8 (irq =3D 44) is a 16550A
ttyS01 at 0x02f8 (irq =3D 45) is a 16550A
acpi_serial_add: no iomem or port address in UAR1 _CRS
acpi_serial_add: no iomem or port address in UAR2 _CRS
EFI Time Services Driver v0.4
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.30.1-k1
Copyright (c) 1999-2004 Intel Corporation.
PCI: Found IRQ 51 for device 01:00.0
eth0: Intel(R) PRO/1000 Network Connection
Linux agpgart interface v0.99 (c) Jeff Hartmann
agpgart: Maximum main memory to use for agp memory: 910M
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
hda: MATSHITADVD-ROM SR-8176, ATAPI CD/DVD-ROM drive
hdb: LS-120/240 00 UHD Floppy, ATAPI FLOPPY drive
global_restore_flags: 10084a6010 (e000000004ae55e0)
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hda: attached ide-cdrom driver.
hda: ATAPI 24X DVD-ROM drive, 256kB Cache
Uniform CD-ROM driver Revision: 3.12
hdb: attached ide-floppy driver.
hdb: No disk in drive
hdb: 234752kB, 262/32/56 CHS, 2995 kBps, 512 sector size, 1500 rpm
SCSI subsystem driver Revision: 1.00
scsi0 : SCSI host adapter emulation for IDE ATAPI devices
Fusion MPT base driver 2.05.11.03
Copyright (c) 1999-2003 LSI Logic Corporation
PCI: Found IRQ 53 for device 06:02.0
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities=3D{Initiator}
PCI: Found IRQ 54 for device 06:02.1
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities=3D{Initiator}
mptbase: 2 MPT adapters found, 2 installed.
Fusion MPT SCSI Host driver 2.05.11.03
scsi1 : ioc0: LSI53C1030, FwRev=01030a00h, Ports=3D1, MaxQ%5, IRQS
scsi2 : ioc1: LSI53C1030, FwRev=01030a00h, Ports=3D1, MaxQ%5, IRQT
blk: queue e00000003f9da330, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
  Vendor: SEAGATE   Model: ST318406LC        Rev: 8A03
  Type:   Direct-Access                      ANSI SCSI revision: 03
blk: queue e00000003f9da130, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
  Vendor: ESG-SHV   Model: SCA HSBP M17      Rev: 1.0A
  Type:   Processor                          ANSI SCSI revision: 02
blk: queue e00000003f9d9d30, I/O limit 17592186044415Mb (mask
0xffffffffffffffff)
Attached scsi disk sda at scsi1, channel 0, id 0, lun 0
Attached scsi generic sg1 at scsi1, channel 0, id 6, lun 0,  type 3
SCSI device sda: 35566478 512-byte hdwr sectors (18210 MB)
Partition check:
 sda: sda1 sda2 sda3
cs4281: version v1.30.64 time 16:00:14 May 12 2004
cs4281: Unable to locate any cs4281 device with valid IDs 0x1013-0x6005
usb.c: registered new driver usbdevfs
usb.c: registered new driver hub
PCI: Found IRQ 50 for device 00:1d.7
ehci_hcd 00:1d.7: Intel Corp. 82801DB USB2
ehci_hcd 00:1d.7: irq 50, pci mem c0000000f9ff0000
usb.c: new USB bus registered, assigned bus number 1
ehci_hcd 00:1d.7: ehci_start hcs_params 0x102204 dbg=3D1 cc=3D2 pcc=3D2
ordered !ppc ports=3D4
ehci_hcd 00:1d.7: ehci_start hcc_params 6871 thresh 7 uframes 1024 64
bit addr
ehci_hcd 00:1d.7: capability 0001 at 68
ehci_hcd 00:1d.7: reset command 080002 (park)=3D0 ithresh=3D8 period=1024
Reset HALT
ehci_hcd 00:1d.7: enabled 64bit PCI DMA
PCI: slot 00:1d.7 has incorrect PCI cache line size of 0 bytes,
correcting to 128
ehci_hcd 00:1d.7: init command 010001 (park)=3D0 ithresh=3D1 period=1024 RUN
ehci_hcd 00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2003-Dec-29/2.4
hcd.c: 00:1d.7 root hub device address 1
usb.c: kmalloc IF e000000004df1280, numif 1
usb.c: new device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb.c: USB device number 1 default language ID 0x0
Manufacturer: Linux 2.4.26 ehci_hcd
Product: Intel Corp. 82801DB USB2
SerialNumber: 00:1d.7
hub.c: USB hub found
hub.c: 4 ports detected
hub.c: standalone hub
hub.c: ganged power switching
hub.c: individual port over-current protection
hub.c: Single TT
hub.c: TT requires at most 8 FS bit times
hub.c: Port indicators are not supported
hub.c: power on to power good time: 20ms
hub.c: hub controller current requirement: 0mA
hub.c: port removable status: RRRR
hub.c: local power source is good
hub.c: no over-current condition exists
hub.c: enabling power on all ports
usb.c: hub driver claimed interface e000000004df1280
host/uhci.c: USB Universal Host Controller Interface driver v1.1
PCI: Found IRQ 48 for device 00:1d.0
host/uhci.c: USB UHCI at I/O 0x4cc0, IRQ 48
usb.c: new USB bus registered, assigned bus number 2
host/uhci.c: detected 2 ports
hub.c: port 1, portstatus 100, change 0, 12 Mb/s
hub.c: port 2, portstatus 100, change 0, 12 Mb/s
hub.c: port 3, portstatus 100, change 0, 12 Mb/s
ehci_hcd 00:1d.7: GetStatus port 4 status 001803 POWER sig=3Dj  CSC
CONNECT
hub.c: port 4, portstatus 501, change 1, 480 Mb/s
hub.c: port 4 connection change
hub.c: port 4, portstatus 501, change 1, 480 Mb/s
usb.c: kmalloc IF e000000004df0e80, numif 1
usb.c: new device strings: Mfr=3D0, Product=3D2, SerialNumber=3D1
usb.c: USB device number 1 default language ID 0x0
Product: USB UHCI-alt Root Hub
SerialNumber: 4cc0
hub.c: USB hub found
hub.c: 2 ports detected
hub.c: standalone hub
hub.c: ganged power switching
hub.c: global over-current protection
hub.c: Port indicators are not supported
hub.c: power on to power good time: 2ms
hub.c: hub controller current requirement: 0mA
hub.c: port removable status: RR
hub.c: local power source is good
hub.c: no over-current condition exists
hub.c: enabling power on all ports
hub.c: port 4, portstatus 501, change 0, 480 Mb/s
usb.c: hub driver claimed interface e000000004df0e80
PCI: Found IRQ 49 for device 00:1d.1
host/uhci.c: USB UHCI at I/O 0x4ce0, IRQ 49
hub.c: port 4, portstatus 501, change 0, 480 Mb/s
usb.c: new USB bus registered, assigned bus number 3
host/uhci.c: detected 2 ports
hub.c: port 4, portstatus 501, change 0, 480 Mb/s
usb.c: kmalloc IF e000000004df0a80, numif 1
usb.c: new device strings: Mfr=3D0, Product=3D2, SerialNumber=3D1
usb.c: USB device number 1 default language ID 0x0
Product: USB UHCI-alt Root Hub
host/uhci.c: 4cc0: suspend_hc
SerialNumber: 4ce0
hub.c: USB hub found
hub.c: 2 ports detected
hub.c: standalone hub
hub.c: ganged power switching
hub.c: global over-current protection
hub.c: Port indicators are not supported
hub.c: power on to power good time: 2ms
hub.c: hub controller current requirement: 0mA
hub.c: port removable status: RR
hub.c: local power source is good
hub.c: no over-current condition exists
hub.c: enabling power on all ports
hub.c: port 4, portstatus 501, change 0, 480 Mb/s
usb.c: hub driver claimed interface e000000004df0a80
usb.c: registered new driver hiddev
usb.c: registered new driver hid
hid-core.c: v1.8.1 Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>
hid-core.c: USB HID support drivers
Linux video capture interface: v1.00
mice: PS/2 mouse device common for all mice
host/uhci.c: 4ce0: suspend_hc
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 16384 buckets, 256Kbytes
TCP: Hash tables configured (established 131072 bind 65536)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
ehci_hcd 00:1d.7: port 4 full speed --> companion
ehci_hcd 00:1d.7: GetStatus port 4 status 003801 POWER OWNER sig=3Dj
CONNECT
hub.c: port 4, portstatus 0, change 10, 12 Mb/s
host/uhci.c: 4ce0: wakeup_hc
ehci_hcd 00:1d.7: free_config  devnum 0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 528kB freed
host/uhci.c: root-hub INT complete: port1: 80 port2: 93 data: 4
hub.c: port 1, portstatus 100, change 0, 12 Mb/s
hub.c: port 2, portstatus 101, change 1, 12 Mb/s
hub.c: port 2 connection change
hub.c: port 2, portstatus 101, change 1, 12 Mb/s
hub.c: port 2, portstatus 101, change 0, 12 Mb/s
hub.c: port 2, portstatus 101, change 0, 12 Mb/s
hub.c: port 2, portstatus 101, change 0, 12 Mb/s
hub.c: port 2, portstatus 101, change 0, 12 Mb/s
hub.c: port 2, portstatus 103, change 0, 12 Mb/s
hub.c: new USB device 00:1d.1-2, assigned address 2
usb.c: kmalloc IF e00000003db7fd00, numif 1
usb.c: new device strings: Mfr=3D0, Product=3D1, SerialNumber=3D0
usb.c: USB device number 2 default language ID 0x409
Product: USB Hub
hub.c: USB hub found
hub.c: 7 ports detected
hub.c: standalone hub
hub.c: individual port power switching
hub.c: individual port over-current protection
hub.c: Port indicators are not supported
hub.c: power on to power good time: 100ms
hub.c: hub controller current requirement: 100mA
hub.c: port removable status: RRRRRRR
hub.c: local power source is good
hub.c: no over-current condition exists
hub.c: enabling power on all ports
usb.c: hub driver claimed interface e00000003db7fd00
hub.c: port 1, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 1 connection change
hub.c: port 1, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 1, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 1, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 1, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 1, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 1, portstatus 303, change 10, 1.5 Mb/s
hub.c: new USB device 00:1d.1-2.1, assigned address 3
usb.c: kmalloc IF e00000003df57e80, numif 2
usb.c: skipped 1 class/vendor specific interface descriptors
usb.c: skipped 1 class/vendor specific interface descriptors
usb.c: new device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
usb.c: USB device number 3 default language ID 0x409
Manufacturer: SOLIDTEK
Product: USB Composite Keyboard
input: USB HID v1.10 Keyboard [SOLIDTEK USB Composite Keyboard] on
usb3:3.0
usb.c: hid driver claimed interface e00000003df57e80
input,hiddev0: USB HID v1.10 Device [SOLIDTEK USB Composite Keyboard] on
usb3:3.1
usb.c: hid driver claimed interface e00000003df57ea8
hub.c: port 2, portstatus 100, change 0, 12 Mb/s
hub.c: port 3, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 3 connection change
hub.c: port 3, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 3, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 3, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 3, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 3, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 3, portstatus 303, change 10, 1.5 Mb/s
hub.c: new USB device 00:1d.1-2.3, assigned address 4
usb.c: kmalloc IF e00000003db7f380, numif 1
usb.c: skipped 1 class/vendor specific interface descriptors
usb.c: new device strings: Mfr=3D1, Product=3D3, SerialNumber=3D0
usb.c: USB device number 4 default language ID 0x409
Manufacturer: Microsoft
Product: Microsoft 5-Button Mouse with IntelliEye(TM)
input: USB HID v1.10 Mouse [Microsoft Microsoft 5-Button Mouse with
IntelliEye(TM)] on usb3:4.0
usb.c: hid driver claimed interface e00000003db7f380
hub.c: port 4, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 4 connection change
hub.c: port 4, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 4, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 4, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 4, portstatus 301, change 0, 1.5 Mb/s
EXT3 FS 2.4-0.9.19, 19 August 2002 on sd(8,2), internal journal
Adding Swap: 2024144k swap-space (priority -1)
hub.c: port 4, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 4, portstatus 303, change 10, 1.5 Mb/s
hub.c: new USB device 00:1d.1-2.4, assigned address 5
usb.c: kmalloc IF e00000003df57700, numif 2
usb.c: skipped 1 class/vendor specific interface descriptors
usb.c: skipped 1 class/vendor specific interface descriptors
usb.c: new device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
usb.c: USB device number 5 default language ID 0x409
Manufacturer: Tangtop
Product: Generic KVM104UC
input: USB HID v1.00 Keyboard [Tangtop Generic KVM104UC] on usb3:5.0
usb.c: hid driver claimed interface e00000003df57700
host/uhci.c: uhci_result_control() failed with status 500000
[e00000003db6c100] link (3db6c042) element (3db704b4)
  Depth traverse
 Element !=3D First TD
  0: [e00000003db70460] link (3db704b4) e3 LS Length=3D7 MaxLen=3D7 DT0
EndPt=3D0 Dev=3D5, PID-(SETUP) (buf=3Db7fb80)
  1: [e00000003db704b0] link (3db70504) e3 SPD LS Stalled Babble
Length=3D2 MaxLen=3D2 DT1 EndPt=3D0 Dev=3D5, PIDi(IN) (buf=3Dbcfdc0)
  2: [e00000003db70500] link (00000001) e3 LS IOC Active Length=3D0
MaxLen=7Ff DT1 EndPt=3D0 Dev=3D5, PID=E1(OUT) (buf=00000000)

host/uhci.c: uhci_result_control() failed with status 500000
[e00000003db6c100] link (3db6c042) element (3db704b4)
  Depth traverse
 Element !=3D First TD
  0: [e00000003db70460] link (3db704b4) e3 LS Length=3D7 MaxLen=3D7 DT0
EndPt=3D0 Dev=3D5, PID-(SETUP) (buf=3Db7fb80)
  1: [e00000003db704b0] link (3db70504) e3 SPD LS Stalled Babble
Length=3D1 MaxLen=3D1 DT1 EndPt=3D0 Dev=3D5, PIDi(IN) (buf=3Dbcfdc0)
  2: [e00000003db70500] link (00000001) e3 LS IOC Active Length=3D0
MaxLen=7Ff DT1 EndPt=3D0 Dev=3D5, PID=E1(OUT) (buf=00000000)

host/uhci.c: uhci_result_control() failed with status 500000
[e00000003db6c100] link (3db6c042) element (3db704b4)
  Depth traverse
 Element !=3D First TD
  0: [e00000003db70460] link (3db704b4) e3 LS Length=3D7 MaxLen=3D7 DT0
EndPt=3D0 Dev=3D5, PID-(SETUP) (buf=3Db7fb80)
  1: [e00000003db704b0] link (3db70504) e3 SPD LS Stalled Babble
Length=3D1 MaxLen=3D1 DT1 EndPt=3D0 Dev=3D5, PIDi(IN) (buf=3Dbcfdc0)
  2: [e00000003db70500] link (00000001) e3 LS IOC Active Length=3D0
MaxLen=7Ff DT1 EndPt=3D0 Dev=3D5, PID=E1(OUT) (buf=00000000)

input: USB HID v1.00 Mouse [Tangtop Generic KVM104UC] on usb3:5.1
usb.c: hid driver claimed interface e00000003df57728
hub.c: port 5, portstatus 100, change 0, 12 Mb/s
hub.c: port 6, portstatus 100, change 0, 12 Mb/s
hub.c: port 7, portstatus 100, change 0, 12 Mb/s
hub.c: port 1, portstatus 303, change 0, 1.5 Mb/s
hub.c: port 2, portstatus 100, change 0, 12 Mb/s
hub.c: port 3, portstatus 303, change 0, 1.5 Mb/s
hub.c: port 4, portstatus 303, change 0, 1.5 Mb/s
hub.c: port 5, portstatus 100, change 0, 12 Mb/s
hub.c: port 6, portstatus 100, change 0, 12 Mb/s
hub.c: port 7, portstatus 100, change 0, 12 Mb/s
partx(182): unaligned access to 0x6000000000009ad6,
ip=3D0x4000000000002ce1
partx(182): unaligned access to 0x6000000000009ae6,
ip=3D0x4000000000002ce1
partx(182): unaligned access to 0x6000000000009af6,
ip=3D0x4000000000002ce1
partx(182): unaligned access to 0x6000000000009b06,
ip=3D0x4000000000002ce1
keyboard: Timeout - AT keyboard not present?(f4)
e1000: eth0 NIC Link is Up 100 Mbps Full Duplex
ide-floppy: hdb: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  0
ide-floppy: hdb: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  0
hdb: No disk in drive
cdrom: This disc doesn't have any tracks I recognize!
cdrom: This disc doesn't have any tracks I recognize!
ide-floppy: hdb: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  0
ide-floppy: hdb: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  0
hdb: No disk in drive
cdrom: This disc doesn't have any tracks I recognize!

           CPU0       CPU1       CPU2       CPU3      =20
 32:          0          2          5          0   IO-SAPIC-edge
keyboard
 34:         16        264       1565         16   IO-SAPIC-edge  ide0
 39:          0          4          0          0  IO-SAPIC-level  acpi
 45:          0       1257          9        273   IO-SAPIC-edge  serial
 48:          0          0          0          0  IO-SAPIC-level
usb-uhci
 49:        122        548       3476        150  IO-SAPIC-level
usb-uhci
 50:          0          0          0          0  IO-SAPIC-level
ehci_hcd
 51:        221        166        676         12  IO-SAPIC-level  eth0
 53:        219        490       7407         72  IO-SAPIC-level  ioc0
 54:          0          0         44          0  IO-SAPIC-level  ioc1
239:     675251     674398     673978     673856          LSAPIC  timer
254:         45         80         62         56          LSAPIC  IPI
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
	Region 0: Memory at 00000000c5ff0000 (32-bit, non-prefetchable)
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
	Memory behind bridge: c6000000-c7ffffff
	Prefetchable memory behind bridge:
00000000bbf00000-00000000bff00000
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
	Region 0: Memory at 00000000c5fe0000 (32-bit, non-prefetchable)
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
	Bus: primary=0F, secondary=12, subordinate=13, sec-latencyd
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: c8000000-caffffff
	Prefetchable memory behind bridge:
00000000c0000000-00000000c4f00000
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] PCI-X non-bridge device.
		Command: DPERE+ ERO+ RBC=3D0 OST=3D0
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
	Region 0: Memory at 00000000bbff0000 (64-bit, prefetchable)
[size%6]
	Capabilities: [64] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=3D0 OST=3D0
		Status: Bus=3D0 Dev=3D0 Func=3D0 64bit- 133MHz- SCD- USC-,
DC=3Dsimple, DMMRBC=3D0, DMOST=3D0, DMCRS=3D0, RSCEM-
12:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 59
	Region 0: Memory at 00000000c4ff0000 (64-bit, prefetchable)
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
ParErr- Step
ping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort-
<MAbort- >SERR- <PERR-

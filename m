From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 02 Jun 2004 12:33:25 +0000
Subject: IA64 test report: USB mouse conflict with PS2 mouse 2.4.27-pre4 /Lion 2004-6-2: 10/10 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F840483B5BB@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ACPI Test Report  for 2.4 ia64 kernel=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DHardware Configuration:
-----------------------
System Name: ACPI-LION
System Type: 4 way 800M Itanium, Lion
M/B revision: N/A
Processor version: N/A
Firmware Versions: N/A
I/O configuration summary:
	QLogic QLA12160, Seagate ST39205LC boot drive
	IDE floppy and CDROM
	Serial console
	PS/2 keyboard and mouse
	USB mouse
	Ethernet Pro 100

Software Configuration:
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on
6/2(Shanghai time)
	2.bk pull from
http://linux-acpi.bkbits.net/linux-acpi-test-2.4.27 on 6/2(Shanghai
time)

ACPI Features Tested: (prioritized).
--------------------
1. Boot 				tested ok
2. PS/2 keyboard			tested ok
3. ATI (run X window system)	tested ok
4. PS/2 mouse				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)		tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)	tested ok
9. Soft Power off 			tested ok
10. serial console			tested ok


Linux version 2.4.27-pre4 (root@acpi-lion) (gcc version 3.2) #2 SMP Wed
Jun 2 18:08:40 CST 2004
EFI v1.02 by INTEL: SALsystab=3D0x5ff26170 ACPI=3D0x5fe963e8 ACPI
2.0=3D0x5fe96630 MPS=3D0x5ffd0000 SMBIOS=3D0xf00a0
ACPI: RSDP (v002  INTEL                                    ) @
0x000000005fe96630
ACPI: XSDT (v001  INTEL  SR460AC 0x00000003 MSFT 0x0100000a) @
0x000000005fe96658
ACPI: FADT (v003  INTEL  SR460AC 0x00000006 MSFT 0x0100000a) @
0x000000005fe96700
ACPI: MADT (v001  INTEL  SR460AC 0x0000000a MSFT 0x0100000a) @
0x000000005fe96838
ACPI: DSDT (v001  INTEL SR460AC4 0x00000006 MSFT 0x0100000a) @
0x0000000000000000
efi.trim_top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
efi.trim_top: ignoring 448KB of memory at 0x1000 due to granule hole at
0x0
efi.trim_top: ignoring 4KB of memory at 0x71000 due to granule hole at
0x0
efi.trim_top: ignoring 8KB of memory at 0x72000 due to granule hole at
0x0
efi.trim_top: ignoring 100KB of memory at 0x87000 due to granule hole at
0x0
efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule
hole at 0x0
SAL v3.00: oem=3DINTEL   MSL     REF     SAL     , productSAL: entry: pal_p=
roc=3D0x5ff48010, sal_proc=3D0x5feb53e0
SAL: Platform features BusLock IRQ_Redirection=20
SAL: AP wakeup using external interrupt vector 0xf0
booting generic kernel on platform dig
CPU 0: 51 virtual and 44 physical address bits
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address 0xc0000000fee00000
ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0x00] lsapic_eid[0x00] enabled)
CPU 0 (0x0000) enabled (BSP)
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0x02] lsapic_eid[0x00] enabled)
CPU 1 (0x0200) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0x03] lsapic_eid[0x00] enabled)
CPU 2 (0x0300) enabled
ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0x01] lsapic_eid[0x00] enabled)
CPU 3 (0x0100) enabled
ACPI: LSAPIC (acpi_id[0x04] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 4 (0xaa00) disabled
ACPI: LSAPIC (acpi_id[0x05] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 5 (0xaa00) disabled
ACPI: LSAPIC (acpi_id[0x06] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 6 (0xaa00) disabled
ACPI: LSAPIC (acpi_id[0x07] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
CPU 7 (0xaa00) disabled
ACPI: IOSAPIC (id[0x4] global_irq_base[0x0] address[00000000fec00000])
  IOSAPIC v2.1, address 0xfec00000, GSIs 0x0-0x3f
ACPI: PLAT_INT_SRC (low edge type[0x1] id[0x0001] eid[0x0]
iosapic_vector[0x2] global_irq[0x3d]
PLATFORM int 0x1: GSI 0x3d(low,edge) -> CPU 0x0100 vector 2
ACPI: PLAT_INT_SRC (low level type[0x3] id[0x0001] eid[0x0]
iosapic_vector[0x1e] global_irq[0x3c]
PLATFORM int 0x3: GSI 0x3c(low,level) -> CPU 0x0100 vector 30
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 8 CPUs total
On node 0 totalpages: 96477
zone(0): 96477 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Building zonelist for node : 0
Kernel command line: BOOT_IMAGE=3Dscsi0:EFI\redhat\vmlinux.24
root=3D/dev/sda2 console=3DttyS0,9600n8 console=3Dtty0 ro
FPSWA interface at 0x5fb34010, revision 1.12
CPU 0: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.001MHz
Console: colour VGA+ 80x25
Calibrating delay loop... 797.80 BogoMIPS
Placing software IO TLB between 0xe000000001848000 - 0xe000000001a48000
Memory: 1533088k/1543632k available (5918k code, 10576k reserved, 2883k
data, 512k init)
Dentry cache hash table entries: 131072 (order: 7, 2097152 bytes)
Inode cache hash table entries: 131072 (order: 7, 2097152 bytes)
Mount cache hash table entries: 1024 (order: 0, 16384 bytes)
Buffer cache hash table entries: 131072 (order: 6, 1048576 bytes)
Page-cache hash table entries: 131072 (order: 6, 1048576 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0x0
SMP: starting up secondaries.
CPU 1: 51 virtual and 44 physical address bits
CPU 1: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.001MHz
Calibrating delay loop... 797.80 BogoMIPS
CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
cycles)
CPU1: CPU has booted.
CPU 2: 51 virtual and 44 physical address bits
CPU 2: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.001MHz
Calibrating delay loop... 797.80 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
cycles)
CPU2: CPU has booted.
CPU 3: 51 virtual and 44 physical address bits
CPU 3: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.001MHz
Calibrating delay loop... 797.80 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
cycles)
CPU3: CPU has booted.
Before bogomips.
Total of 4 processors activated (3189.20 BogoMIPS).
Waiting on wait_init_idle (map =3D 0xe)
All processors have done init_idle
ACPI: Subsystem revision 20040326
PCI: Using SAL to access configuration space
 tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully
acquired
Parsing all Control
Methods:................................................................
........................................................................
......................................
Table [DSDT](id F004) - 934 Objects with 101 Devices 174 Methods 19
Regions
ACPI Namespace successfully loaded at root e000000004c1b758
evxfevnt-0093 [04] acpi_enable           : Transition to ACPI mode
successful
evgpeblk-0867 [06] ev_create_gpe_block   : GPE 00 to 15 [_GPE] 2 regs at
0000000000000C0C on int 9
evgpeblk-0925 [06] ev_create_gpe_block   : Found 2 Wake, Enabled 0
Runtime GPEs in this block
evgpeblk-0867 [06] ev_create_gpe_block   : GPE 16 to 31 [_GPE] 2 regs at
0000000000000C16 on int 9
evgpeblk-0925 [06] ev_create_gpe_block   : Found 0 Wake, Enabled 1
Runtime GPEs in this block
Completing Region/Field/Buffer/Package
initialization:.....................................................
Initialized 19/19 Regions 0/0 Fields 24/24 Buffers 10/12 Packages (943
nodes)
Executing all Device _STA and_INI
methods:................................................................
..................................
98 Devices found containing: 98 _STA, 7 _INI methods
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: System [ACPI] (supports S0 S4 S5)
ACPI: PCI Root Bridge [PCI0] (00:00)
alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: Power Resource [URP1] (off)
ACPI: Power Resource [URP2] (off)
ACPI: Power Resource [FDDP] (off)
ACPI: Power Resource [LPTP] (off)
ACPI: PCI Root Bridge [PCI1] (00:01)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
ACPI: PCI Root Bridge [PCI2] (00:04)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
ACPI: PCI Root Bridge [PCI3] (00:08)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3._PRT]
ACPI: PCI Root Bridge [PCI4] (00:0c)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4._PRT]
ACPI: PCI Root Bridge [PCI5] (00:0f)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI5._PRT]
ACPI: PCI Root Bridge [PCI6] (00:12)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI6._PRT]
ACPI: PCI Root Bridge [CBN] (00:15)
PCI->APIC IRQ transform: (00:03.2 INTD) -> CPU 0x0000 vector 48
PCI: no interrupt route for 00:00:03 pin B
PCI->APIC IRQ transform: (00:05.0 INTA) -> CPU 0x0000 vector 49
PCI->APIC IRQ transform: (00:06.0 INTA) -> CPU 0x0000 vector 50
PCI->APIC IRQ transform: (01:02.0 INTA) -> CPU 0x0000 vector 51
PCI->APIC IRQ transform: (01:0f.0 INTA) -> CPU 0x0000 vector 52
PCI->APIC IRQ transform: (04:0f.0 INTA) -> CPU 0x0000 vector 52
PCI->APIC IRQ transform: (08:0f.0 INTA) -> CPU 0x0000 vector 53
PCI->APIC IRQ transform: (0c:0f.0 INTA) -> CPU 0x0000 vector 53
PCI->APIC IRQ transform: (0f:0f.0 INTA) -> CPU 0x0000 vector 54
PCI->APIC IRQ transform: (12:0f.0 INTA) -> CPU 0x0000 vector 54
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
pty: 256 Unix98 ptys configured
Serial driver version 5.05c (2001-07-08) with MANY_PORTS SHARE_IRQ
DETECT_IRQ SERIAL_PCI SERIAL_ACPI enabled
ttyS00 at 0x03f8 (irq =3D 44) is a 16550A
ttyS01 at 0x02f8 (irq =3D 45) is a 16550A
ttyS00 at port 0x03f8 (irq =3D 44) is a 16550A
ttyS01 at port 0x02f8 (irq =3D 45) is a 16550A
EFI Time Services Driver v0.4
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.39-k1
Copyright (c) 1999-2004 Intel Corporation.
eepro100.c:v1.09j-t 9/29/99 Donald Becker
http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin
<saw@saw.sw.com.sg> and others
PCI: Found IRQ 49 for device 00:05.0
eth0: Intel Corp. 82557/8/9 [Ethernet Pro 100], 00:D0:B7:F9:F4:F6, IRQ
49.
  Board assembly 727095-004, Physical connectors present: RJ45
  Primary interface chip i82555 PHY #1.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x04f4518b).
Linux agpgart interface v0.99 (c) Jeff Hartmann
agpgart: Maximum main memory to use for agp memory: 1403M
agpgart: no supported devices found.
[drm] Initialized r128 2.2.0 20010917 on minor 0
[drm] Initialized radeon 1.7.0 20020828 on minor 1
Uniform Multi-Platform E-IDE driver Revision: 7.00beta4-2.4
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx
PIIX4: IDE controller at PCI slot 00:03.1
PCI: Found IRQ 0 for device 00:03.1
PIIX4: chipset revision 1
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:DMA, hdd:pio
hda: LS-120 S200 01 UHD Floppy, ATAPI FLOPPY drive
hdc: CD-224E, ATAPI CD/DVD-ROM drive
global_restore_flags: 10084a6010 (e000000004aace20)
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
global_restore_flags: 10084a2010 (e000000004aace20)
ide1 at 0x170-0x177,0x376 on irq 33
hdc: attached ide-cdrom driver.
hdc: ATAPI 24X CD-ROM drive, 128kB Cache
Uniform CD-ROM driver Revision: 3.12
hda: attached ide-floppy driver.
hda: No disk in drive
hda: 123264kB, 963/8/32 CHS, 533 kBps, 512 sector size, 720 rpm
SCSI subsystem driver Revision: 1.00
PCI: Found IRQ 51 for device 01:02.0
qla1280: QLA12160 found on PCI bus 1, dev 2
scsi(0): Reading NVRAM
scsi(0:0): Resetting SCSI BUS
scsi(0:1): Resetting SCSI BUS
PCI: Found IRQ 51 for device 01:02.0
scsi0 : QLogic QLA12160 PCI to SCSI Host Adapter: bus 1 device 2 irq 51
       Firmware version: 10.04.32, Driver version 3.23.37
  Vendor: SEAGATE   Model: ST39205LC         Rev: 5063
  Type:   Direct-Access                      ANSI SCSI revision: 03
scsi(0:0:0:0): Sync: period 9, offset 24, Wide, DT, Tagged queuing:
depth 255
scsi1 : SCSI host adapter emulation for IDE ATAPI devices
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
SCSI device sda: 17921835 512-byte hdwr sectors (9176 MB)
Partition check:
 sda: sda1 sda2 sda3
Fusion MPT base driver 2.05.16
Copyright (c) 1999-2004 LSI Logic Corporation
mptbase: 0 MPT adapters found, 0 installed.
Fusion MPT SCSI Host driver 2.05.16
cs4281: version v1.30.64 time 18:06:48 Jun  2 2004
cs4281: Unable to locate any cs4281 device with valid IDs 0x1013-0x6005
usb.c: registered new driver usbdevfs
usb.c: registered new driver hub
host/usb-uhci.c: $Revision: 1.275 $ time 18:07:37 Jun  2 2004
host/usb-uhci.c: High bandwidth mode enabled
PCI: Found IRQ 48 for device 00:03.2
host/usb-uhci.c: USB UHCI at I/O 0x6f80, IRQ 48
host/usb-uhci.c: Detected 2 ports
usb.c: new USB bus registered, assigned bus number 1
usb.c: kmalloc IF e00000005fa97bc0, numif 1
usb.c: new device strings: Mfr=3D0, Product=3D2, SerialNumber=3D1
usb.c: USB device number 1 default language ID 0x0
Product: USB UHCI Root Hub
SerialNumber: 6f80
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
usb.c: hub driver claimed interface e00000005fa97bc0
host/usb-uhci.c: v1.275:USB Universal Host Controller Interface driver
usb.c: registered new driver hiddev
usb.c: registered new driver hid
hid-core.c: v1.8.1 Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>
hid-core.c: USB HID support drivers
usb.c: registered new driver serial
usbserial.c: USB Serial Driver core v1.4
Linux video capture interface: v1.00
mice: PS/2 mouse device common for all mice
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 32768 buckets, 512Kbytes
TCP: Hash tables configured (established 262144 bind 65536)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 512kB freed
EXT3 FS 2.4-0.9.19, 19 August 2002 on sd(8,2), internal journal
Adding Swap: 2040208k swap-space (priority -1)
hub.c: port 1, portstatus 100, change 0, 12 Mb/s
hub.c: port 2, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 2 connection change
hub.c: port 2, portstatus 301, change 1, 1.5 Mb/s
hub.c: port 2, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 2, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 2, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 2, portstatus 301, change 0, 1.5 Mb/s
hub.c: port 2, portstatus 303, change 0, 1.5 Mb/s
hub.c: new USB device 00:03.2-2, assigned address 2
usb.c: kmalloc IF e00000005f4b1180, numif 1
usb.c: skipped 1 class/vendor specific interface descriptors
usb.c: new device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
usb.c: USB device number 2 default language ID 0x409
Manufacturer: Logitech
Product: USB-PS/2 Optical Mouse
input: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb1:2.0
usb.c: hid driver claimed interface e00000005f4b1180
           CPU0       CPU1       CPU2       CPU3      =20
 32:        498          1          0          3   IO-SAPIC-edge
keyboard
 33:        135          0          0          2   IO-SAPIC-edge  ide1
 34:          6          0          0          2   IO-SAPIC-edge  ide0
 39:          3          0          0          0  IO-SAPIC-level  acpi
 45:         14          0          0          4   IO-SAPIC-edge  serial
 48:        513          0          0          0  IO-SAPIC-level
usb-uhci
 49:      12717          1          0          7  IO-SAPIC-level  eth0
 51:       3335         21          3        209  IO-SAPIC-level
qla1280
239:    5804263    5812407    5812191    5811909          LSAPIC  timer
254:         48         47         55         18          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0
00:03.0 ISA bridge: Intel Corp. 82372FB PIIX5 ISA (rev 01)
	Flags: bus master, medium devsel, latency 0

00:03.1 IDE interface: Intel Corp. 82372FB PIIX5 IDE (rev 01) (prog-if
80 [Master])
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: bus master, medium devsel, latency 64
	I/O ports at 1000 [size=16]

00:03.2 USB Controller: Intel Corp. 82372FB PIIX5 USB (rev 01) (prog-if
00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: bus master, medium devsel, latency 64, IRQ 48
	I/O ports at 6f80 [size2]

00:03.3 SMBus: Intel Corp. 82372FB PIIX5 SMBus (rev 01)
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: medium devsel
	I/O ports at c000 [disabled] [size=16]

00:04.0 PIC: Intel Corp. 683053 Programmable Interrupt Device (rev 01)
(prog-if 20 [IO(X)-APIC])
	Flags: bus master, medium devsel, latency 0

00:05.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100]
(rev 08)
	Subsystem: Intel Corp. 82559 Fast Ethernet LAN on Motherboard
	Flags: bus master, medium devsel, latency 64, IRQ 49
	Memory at 00000000fafe0000 (32-bit, non-prefetchable) [size=3D4K]
	I/O ports at 6f00 [sized]
	Memory at 00000000fae00000 (32-bit, non-prefetchable) [size=3D1M]
	Capabilities: [dc] Power Management version 2

00:06.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
(prog-if 00 [VGA])
	Subsystem: Intel Corp.: Unknown device 414c
	Flags: bus master, stepping, medium devsel, latency 64, IRQ 50
	Memory at 00000000fb000000 (32-bit, non-prefetchable) [size=16M]
	I/O ports at 6800 [size%6]
	Memory at 00000000faff0000 (32-bit, non-prefetchable) [size=3D4K]
	Expansion ROM at 00000000fafc0000 [disabled] [size=128K]
	Capabilities: [5c] Power Management version 2

00:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

01:02.0 SCSI storage controller: QLogic Corp. ISP12160 Dual Channel
Ultra3 SCSI Processor (rev 06)
	Subsystem: QLogic Corp.: Unknown device 0007
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 51
	I/O ports at 8800 [size%6]
	Memory at 00000000f1ff0000 (32-bit, non-prefetchable) [size=3D4K]
	Expansion ROM at 00000000f1fc0000 [disabled] [size=128K]
	Capabilities: [44] Power Management version 1

01:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 52
	Memory at 00000000f1fe0000 (32-bit, non-prefetchable) [size%6]

04:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 52
	Memory at 00000000e7ff0000 (32-bit, non-prefetchable) [size%6]

08:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 53
	Memory at 00000000ddff0000 (32-bit, non-prefetchable) [size%6]

0c:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 53
	Memory at 00000000d5ff0000 (32-bit, non-prefetchable) [size%6]

0f:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 54
	Memory at 00000000cdff0000 (32-bit, non-prefetchable) [size%6]

12:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Flags: medium devsel, IRQ 54
	Memory at 00000000c5ff0000 (32-bit, non-prefetchable) [size%6]

15:00.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:00.1 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:00.2 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:00.3 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:00.4 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:00.5 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:00.6 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:00.7 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.1 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.2 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.3 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.4 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.5 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.6 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:01.7 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:04.0 Host bridge: Intel Corp. 460GX - 84460GX System Data Controller
(SDC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Data Controller
(SDC)
	Flags: fast devsel

15:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:10.1 Host bridge: Intel Corp. 450NX - 82454NX/84460GX PCI Expander
Bridge (rev 05)
	Subsystem: Intel Corp. 450NX - 82454NX/84460GX PCI Expander
Bridge
	Flags: bus master, medium devsel, latency 128

15:11.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:12.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:12.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:13.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:13.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:14.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:14.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:15.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:15.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:16.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:16.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2

15:17.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Flags: fast devsel

15:17.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Flags: bus master, 66Mhz, medium devsel, latency 32
	Capabilities: [90] Power Management version 2


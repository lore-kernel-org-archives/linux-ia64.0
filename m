From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 02 Jun 2004 12:33:28 +0000
Subject: IA64 test report: 2.6.7-rc1 /Lion 2004-6-2: 10/10 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F840483B5BC@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ACPI Test Report  for 2.6 ia64 kernel=20
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
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on
6/2(Shanghai time)
	2.bk pull from
http://linux-acpi.bkbits.net/linux-acpi-test-2.6.7 on 6/2(Shanghai time)
	3.  apply my workaround patch :

--- 2.6.new/fs/namespace.c      2004-05-20 02:03:21.838705977 +0800
+++ 2.6.new/fs/namespace.c.fixed        2004-05-20 02:04:00.072103946
+0800
@@ -346,6 +346,7 @@
                /* last instance - try to be smart */
                spin_unlock(&vfsmount_lock);
                lock_kernel();
+               mb();
                DQUOT_OFF(sb);
                acct_auto_close(sb);
                unlock_kernel();

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

Linux version 2.6.7-rc1 (root@acpi-lion) (gcc version 3.2) #1 SMP Wed
Jun 2 18:48:11 CST 2004
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
efi.trim_bottom: ignoring 64512KB of memory at 0x100000 due to granule
hole at 0x0
SAL 3.0: INTEL   MSL     REF     SAL      version 3.0
SAL Platform features: BusLock IRQ_Redirection
SAL: AP wakeup using external interrupt vector 0xf0
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
ACPI: IOSAPIC (id[0x4] address[00000000fec00000] gsi_base[0])
ACPI: PLAT_INT_SRC (low edge type[0x1] id[0x0001] eid[0x0]
iosapic_vector[0x2] global_irq[0x3d]
PLATFORM int PMI (0x1): GSI 61 (edge, low) -> CPU 64 (0x0100) vector 2
ACPI: PLAT_INT_SRC (low level type[0x3] id[0x0001] eid[0x0]
iosapic_vector[0x1e] global_irq[0x3c]
PLATFORM int CPEI (0x3): GSI 60 (level, low) -> CPU 64 (0x0100) vector
30
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 8 CPUs total
Registering legacy COM ports for serial console
MCA related initialization done
On node 0 totalpages: 93974
  DMA zone: 93974 pages, LIFO batch:4
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
Built 1 zonelists
Kernel command line: BOOT_IMAGE=3Dscsi0:EFI\redhat\vmlinux.26
root=3D/dev/sda2 console=3DttyS0,9600n8 console=3Dtty0 ro
PID hash table entries: 4096 (order 12: 65536 bytes)
CPU 0: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.000MHz+/--1ppm
Console: colour VGA+ 80x25
Placing software IO TLB between 0xe0000000050f8000 - 0xe0000000052f8000
Memory: 1483776k/1503584k available (5070k code, 19472k reserved, 2287k
data, 480k init)
McKinley Errata 9 workaround not needed; disabling it
Calibrating delay loop... 797.80 BogoMIPS
Dentry cache hash table entries: 262144 (order: 7, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0x0
task migration cache decay timeout: 10 msecs.
CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
cycles)
CPU 1: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.000MHz+/--1ppm
Calibrating delay loop... 797.80 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
cycles)
CPU 2: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.000MHz+/--1ppm
Calibrating delay loop... 797.80 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
cycles)
CPU 3: base freq=133.333MHz, ITC ratio=12/2, ITC freq=800.000MHz+/--1ppm
Calibrating delay loop... 797.80 BogoMIPS
Brought up 4 CPUs
Total of 4 processors activated (3189.20 BogoMIPS).
CPU0:  online
 domain 0: span 00000000,0000000f
  groups: 00000000,00000001 00000000,00000002 00000000,00000004
00000000,00000008
CPU1:  online
 domain 0: span 00000000,0000000f
  groups: 00000000,00000002 00000000,00000004 00000000,00000008
00000000,00000001
CPU2:  online
 domain 0: span 00000000,0000000f
  groups: 00000000,00000004 00000000,00000008 00000000,00000001
00000000,00000002
CPU3:  online
 domain 0: span 00000000,0000000f
  groups: 00000000,00000008 00000000,00000001 00000000,00000002
00000000,00000004
NET: Registered protocol family 16
ACPI: Subsystem revision 20040326
 tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully
acquired
Parsing all Control
Methods:................................................................
........................................................................
......................................
Table [DSDT](id F004) - 934 Objects with 101 Devices 174 Methods 19
Regions
ACPI Namespace successfully loaded at root a0000001006b05f8
evxfevnt-0093 [04] acpi_enable           : Transition to ACPI mode
successful
evgpeblk-0867 [06] ev_create_gpe_block   : GPE 00 to 15 [_GPE] 2 regs at
0000000000000C0C on int 9
evgpeblk-0925 [06] ev_create_gpe_block   : Found 0 Wake, Enabled 1
Runtime GPEs in this block
evgpeblk-0867 [06] ev_create_gpe_block   : GPE 16 to 31 [_GPE] 2 regs at
0000000000000C16 on int 9
evgpeblk-0925 [06] ev_create_gpe_block   : Found 0 Wake, Enabled 1
Runtime GPEs in this block
Completing Region/Field/Buffer/Package
initialization:.......................................................
Initialized 19/19 Regions 0/0 Fields 24/24 Buffers 12/12 Packages (943
nodes)
Executing all Device _STA and_INI
methods:................................................................
..................................
98 Devices found containing: 98 _STA, 7 _INI methods
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
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
ACPI: Device [CBN] status [00000008]: functional but not present;
setting present
ACPI: PCI Root Bridge [CBN] (00:15)
SCSI subsystem initialized
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
GSI 50 (level, low) -> CPU 1 (0x0200) vector 48
ACPI: PCI interrupt 0000:00:03.2[D] -> GSI 50 (level, low) -> IRQ 48
 pci_irq-0314 [02] acpi_pci_irq_derive   : Unable to derive IRQ for
device 0000:00:03.3
ACPI: PCI interrupt 0000:00:03.3[B]: no GSI
GSI 51 (level, low) -> CPU 1 (0x0200) vector 49
ACPI: PCI interrupt 0000:00:05.0[A] -> GSI 51 (level, low) -> IRQ 49
GSI 49 (level, low) -> CPU 1 (0x0200) vector 50
ACPI: PCI interrupt 0000:00:06.0[A] -> GSI 49 (level, low) -> IRQ 50
GSI 48 (level, low) -> CPU 1 (0x0200) vector 51
ACPI: PCI interrupt 0000:01:02.0[A] -> GSI 48 (level, low) -> IRQ 51
GSI 55 (level, low) -> CPU 1 (0x0200) vector 52
ACPI: PCI interrupt 0000:01:0f.0[A] -> GSI 55 (level, low) -> IRQ 52
ACPI: PCI interrupt 0000:04:0f.0[A] -> GSI 55 (level, low) -> IRQ 52
GSI 57 (level, low) -> CPU 1 (0x0200) vector 53
ACPI: PCI interrupt 0000:08:0f.0[A] -> GSI 57 (level, low) -> IRQ 53
ACPI: PCI interrupt 0000:0c:0f.0[A] -> GSI 57 (level, low) -> IRQ 53
GSI 59 (level, low) -> CPU 1 (0x0200) vector 54
ACPI: PCI interrupt 0000:0f:0f.0[A] -> GSI 59 (level, low) -> IRQ 54
ACPI: PCI interrupt 0000:12:0f.0[A] -> GSI 59 (level, low) -> IRQ 54
PAL Information Facility v0.5
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU0] (supports C1)
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
EFI Time Services Driver v0.4
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing
disabled
ttyS0 at I/O 0x3f8 (irq =3D 44) is a 16550A
ttyS1 at I/O 0x2f8 (irq =3D 45) is a 16550A
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.39-k2
Copyright (c) 1999-2004 Intel Corporation.
eepro100.c:v1.09j-t 9/29/99 Donald Becker
http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin
<saw@saw.sw.com.sg> and others
ACPI: PCI interrupt 0000:00:05.0[A] -> GSI 51 (level, low) -> IRQ 49
eth0: 0000:00:05.0, 00:D0:B7:F9:F4:F6, IRQ 49.
  Board assembly 727095-004, Physical connectors present: RJ45
  Primary interface chip i82555 PHY #1.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x04f4518b).
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx
PIIX4: IDE controller at PCI slot 0000:00:03.1
PIIX4: chipset revision 1
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:DMA, hdd:pio
hda: LS-120 S200 01 UHD Floppy, ATAPI FLOPPY drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hdc: CD-224E, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 33
hdc: ATAPI 24X CD-ROM drive, 128kB Cache
Uniform CD-ROM driver Revision: 3.20
qla1280: QLA12160 found on PCI bus 1, dev 2
ACPI: PCI interrupt 0000:01:02.0[A] -> GSI 48 (level, low) -> IRQ 51
scsi(0): Reading NVRAM
scsi(0:0): Resetting SCSI BUS
scsi(0:1): Resetting SCSI BUS
scsi0 : QLogic QLA12160 PCI to SCSI Host Adapter
       Firmware version: 10.04.32, Driver version 3.24.3
  Vendor: SEAGATE   Model: ST39205LC         Rev: 5063
  Type:   Direct-Access                      ANSI SCSI revision: 03
scsi(0:0:0:0): Sync: period 9, offset 24, Wide, DT, Tagged queuing:
depth 255
SCSI device sda: 17921835 512-byte hdwr sectors (9176 MB)
SCSI device sda: drive cache: write back
 sda: sda1 sda2 sda3
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0
Fusion MPT base driver 3.01.06
Copyright (c) 1999-2004 LSI Logic Corporation
Fusion MPT SCSI Host driver 3.01.06
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ohci_hcd: block sizes: ed 80 td 96
USB Universal Host Controller Interface driver v2.2
ACPI: PCI interrupt 0000:00:03.2[D] -> GSI 50 (level, low) -> IRQ 48
uhci_hcd 0000:00:03.2: Intel Corp. 82372FB PIIX5 USB
uhci_hcd 0000:00:03.2: irq 48, io base 0000000000006f80
uhci_hcd 0000:00:03.2: new USB bus registered, assigned bus number 1
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
serio: i8042 AUX port at 0x60,0x64 irq 36
usb 1-2: new low speed USB device using address 2
input: PS/2 Generic Mouse on isa0060/serio1
serio: i8042 KBD port at 0x60,0x64 irq 32
input: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on
usb-0000:00:03.2-2
input: AT Raw Set 2 keyboard on isa0060/serio0
EFI Variables Facility v0.08 2004-May-17
NET: Registered protocol family 2
IP: routing cache hash table of 32768 buckets, 512Kbytes
TCP: Hash tables configured (established 262144 bind 65536)
NET: Registered protocol family 1
NET: Registered protocol family 17
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 480kB freed
EXT3 FS on sda2, internal journal
Adding 2040208k swap on /dev/sda3.  Priority:-1 extents:1
           CPU0       CPU1       CPU2       CPU3      =20
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 32:        831          0          0         11   IO-SAPIC-edge  i8042
 33:         22          1          0          0   IO-SAPIC-edge  ide1
 34:          2          0          0          0   IO-SAPIC-edge  ide0
 36:        144          0         25         28   IO-SAPIC-edge  i8042
 39:          4          0          0          0  IO-SAPIC-level  acpi
 45:          7          0          0          8   IO-SAPIC-edge  serial
 48:        425          0          0         35  IO-SAPIC-level
uhci_hcd
 49:        143          0          0         15  IO-SAPIC-level  eth0
 51:       3334          8          1        164  IO-SAPIC-level
qla1280
232:          0          0          0          0          LSAPIC
mca_rdzv
239:     161700     157542     157317     157092          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:         41         30         68         68          LSAPIC  IPI
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




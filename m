From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Thu, 13 May 2004 08:04:33 +0000
Subject: IA64 test report:Umount cdrom oops : 2.6.6 /Lion 2004-5-13: 8/10  pass
Message-Id: <6E0C289723A0564F9A8279E236E8565F0766858E@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
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
	1. bk pull from http://lia64.bkbits.net:8080/linux-ia64-2.5=20
	2. bk pull from
http://linux-acpi.bkbits.net:8080/linux-acpi-test-2.6.6


ACPI Features Tested: (prioritized).
	--------------------
	1. Boot off SCSI disk				tested ok
	2. PS/2 keyboard				tested ok
	3. ATI (run X window system)			tested ok=20
	4. PS/2 mouse				tested ok
	5. USB mouse					tested ok
	6. NIC (eg. Ping or ftp)			tested ok
	7. IDE (eg. r/w floppy or CDROM)	Mount cdrom Ok; oops on
umount cdrom
	8. SCI (eg. Press power button)		tested ok
	9. Soft Power off			oops on umount fs ( see
the last part)
	10. serial console				tested ok

Linux version 2.6.6 (root@acpi-lion) (gcc version 3.2) #5 SMP Thu May 13
16:02:56 CST 2004
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
ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0x03] lsapic_eid[0x00] enabled)
CPU 1 (0x0300) enabled
ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0x02] lsapic_eid[0x00] enabled)
CPU 2 (0x0200) enabled
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
ACPI: PLAT_INT_SRC (low edge type[0x1] id[0x0001] eid[0x0]
iosapic_vector[0x2] global_irq[0x3d]
PLATFORM int 0x1: GSI 0x3d(low,edge) -> CPU 0x0100 vector 2
ACPI: PLAT_INT_SRC (low level type[0x3] id[0x0001] eid[0x0]
iosapic_vector[0x1e] global_irq[0x3c]
PLATFORM int 0x3: GSI 0x3c(low,level) -> CPU 0x0100 vector 30
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 8 CPUs total
Registering legacy COM ports for serial console
MCA related initialization done
On node 0 totalpages: 93973
  DMA zone: 93973 pages, LIFO batch:4
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
Built 1 zonelists
Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux.26
root=3D/dev/sda2 console=3DttyS0,9600n8 console=3Dtty0 ro
PID hash table entries: 4096 (order 12: 65536 bytes)
CPU 0: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz+/--1ppm
Console: colour VGA+ 80x25
Placing software IO TLB between 0xe00000000519c000 - 0xe00000000539c000
Memory: 1483072k/1503568k available (5075k code, 20144k reserved, 2179k
data, 176k init)
McKinley Errata 9 workaround not needed; disabling it
Calibrating delay loop... 797.80 BogoMIPS
Dentry cache hash table entries: 262144 (order: 7, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)
POSIX conformance testing by UNIFIX
Boot processor id 0x0/0x0
task migration cache decay timeout: 10 msecs.
CPU 1: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz+/--1ppm
Calibrating delay loop... 797.80 BogoMIPS
CPU 1: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 561
cycles)
CPU 2: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz+/--1ppm
Calibrating delay loop... 795.24 BogoMIPS
CPU 2: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 561
cycles)
CPU 3: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz+/--1ppm
Calibrating delay loop... 795.24 BogoMIPS
CPU 3: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 561
cycles)
Brought up 4 CPUs
Total of 4 processors activated (3185.08 BogoMIPS).
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
ACPI Namespace successfully loaded at root a000000100695b40
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
IOSAPIC: vector 54 -> CPU 0x0000, enabled
 pci_irq-0316 [03] acpi_pci_irq_derive   : Unable to derive IRQ for
device 0000:00:03.3
ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3
IOSAPIC: vector 55 -> CPU 0x0000, enabled
IOSAPIC: vector 56 -> CPU 0x0000, enabled
IOSAPIC: vector 61 -> CPU 0x0000, enabled
IOSAPIC: vector 62 -> CPU 0x0000, enabled
IOSAPIC: vector 62 -> CPU 0x0000, enabled
IOSAPIC: vector 77 -> CPU 0x0000, enabled
IOSAPIC: vector 77 -> CPU 0x0000, enabled
IOSAPIC: vector 84 -> CPU 0x0000, enabled
IOSAPIC: vector 84 -> CPU 0x0000, enabled
PCI: Using ACPI for IRQ routing
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
IOSAPIC: vector 55 -> CPU 0x0000, enabled
eth0: 0000:00:05.0, 00:D0:B7:F9:F4:F6, IRQ 55.
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
IOSAPIC: vector 61 -> CPU 0x0000, enabled
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
Fusion MPT base driver 3.01.03
Copyright (c) 1999-2004 LSI Logic Corporation
Fusion MPT SCSI Host driver 3.01.03
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ohci_hcd: block sizes: ed 80 td 96
USB Universal Host Controller Interface driver v2.2
IOSAPIC: vector 54 -> CPU 0x0000, enabled
uhci_hcd 0000:00:03.2: Intel Corp. 82372FB PIIX5 USB
uhci_hcd 0000:00:03.2: irq 54, io base 0000000000006f80
uhci_hcd 0000:00:03.2: new USB bus registered, assigned bus number 1
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
usbcore: registered new driver hiddev
usbcore: registered new driver hid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
serio: i8042 AUX port at 0x60,0x64 irq 36
input: PS/2 Generic Mouse on isa0060/serio1
serio: i8042 KBD port at 0x60,0x64 irq 32
input: AT Raw Set 2 keyboard on isa0060/serio0
EFI Variables Facility v0.07 2004-Apr-26
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
Freeing unused kernel memory: 176kB freed
EXT3 FS on sda2, internal journal
Adding 2040208k swap on /dev/sda3.  Priority:-1 extents:1
atkbd.c: Unknown key pressed (raw set 2, code 0x17a on isa0060/serio0).
atkbd.c: Use 'setkeycodes 7a <keycode>' to make it known.
atkbd.c: Unknown key pressed (raw set 2, code 0x17a on isa0060/serio0).
atkbd.c: Use 'setkeycodes 7a <keycode>' to make it known.
usb 1-2: new low speed USB device using address 2
drivers/usb/input/hid-core.c: ctrl urb status -32 received
input: USB HID v1.00 Mouse [413c:3010] on usb-0000:00:03.2-2
kernel BUG at include/linux/smp_lock.h:52!
umount[1961]: bugcheck! 0 [1]

Pid: 1961, CPU 3, comm:               umount
psr : 0000101008026018 ifs : 800000000000038b ip  : [<a0000001001395f0>]
Not tainted
ip is at do_umount+0x750/0x760
unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
rnat: a000000100738a93 bsps: 0000000000000320 pr  : 0000000005a66959
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001395f0 b6  : a0000001000090e0 b7  : a00000010006a6c0
f6  : 1003e0fc0fc0fc0fc0fc1 f7  : 0ffdbca80000000000000
f8  : 1003e0000000000000240 f9  : 1003e0000000000002490
f10 : 1003e000000000ea00000 f11 : 1003e00000000367b7ad0
r1  : a0000001009007a0 r2  : 0000000000004000 r3  : 0000000000004000
r8  : 000000000000002b r9  : 0000000000000000 r10 : 0000000000003000
r11 : 0000000000000300 r12 : e00000000f2ffe00 r13 : e00000000f2f8000
r14 : e00000000f2ffda0 r15 : a00000010064e200 r16 : 0000000000000300
r17 : a000000100648b50 r18 : a000000100631d38 r19 : 00000000000000fd
r20 : 0000000000000001 r21 : a000000100648b4c r22 : 0000000000000000
r23 : 00000000000000fd r24 : a000000100700918 r25 : 0000000000000004
r26 : 0000000000000000 r27 : 0000000000000004 r28 : e00000005fc20c74
r29 : 0000000000004000 r30 : e000000004755610 r31 : e000000007678038

Call Trace:
 [<a000000100015040>] show_stack+0x80/0xa0
                                sp=E00000000f2ff9d0 bsp=E00000000f2f8de0
 [<a000000100023d10>] die+0x1d0/0x280
                                sp=E00000000f2ffba0 bsp=E00000000f2f8db8
 [<a000000100024040>] ia64_bad_break+0x220/0x340
                                sp=E00000000f2ffba0 bsp=E00000000f2f8d98
 [<a00000010000df20>] ia64_leave_kernel+0x0/0x260
                                sp=E00000000f2ffc30 bsp=E00000000f2f8d98
 [<a0000001001395f0>] do_umount+0x750/0x760
                                sp=E00000000f2ffe00 bsp=E00000000f2f8d40
 [<a000000100139760>] sys_umount+0x160/0x180
                                sp=E00000000f2ffe00 bsp=E00000000f2f8cd8
 [<a00000010000dda0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000000f2ffe30 bsp=E00000000f2f8cd0
=20

           CPU0       CPU1       CPU2       CPU3      =20
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 32:       1394          0          0         12   IO-SAPIC-edge  i8042
 33:        316          1          5          3   IO-SAPIC-edge  ide1
 34:          0          0          0          2   IO-SAPIC-edge  ide0
 36:       3661          2         15        197   IO-SAPIC-edge  i8042
 39:          0          0          0          0  IO-SAPIC-level  acpi
 44:        903          0          0          6   IO-SAPIC-edge  serial
 45:         13          0          0          0   IO-SAPIC-edge  serial
 54:       3722          1          9         84  IO-SAPIC-level
uhci_hcd
 55:        638          0          1         26  IO-SAPIC-level  eth0
 61:       7657          3         27        224  IO-SAPIC-level
qla1280
232:          0          0          0          0          LSAPIC
mca_rdzv
239:     408197     404143     403918     401437          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:         44        132        123        142          LSAPIC  IPI
NMI:          0          0          0          0=20
ERR:          0

00:03.0 ISA bridge: Intel Corp. 82372FB PIIX5 ISA (rev 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:03.1 IDE interface: Intel Corp. 82372FB PIIX5 IDE (rev 01) (prog-if
80 [Master])
	Subsystem: Intel Corp.: Unknown device 414c
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Region 4: I/O ports at 1000 [size=16]

00:03.2 USB Controller: Intel Corp. 82372FB PIIX5 USB (rev 01) (prog-if
00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 414c
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Interrupt: pin D routed to IRQ 54
	Region 4: I/O ports at 6f80 [size2]

00:03.3 SMBus: Intel Corp. 82372FB PIIX5 SMBus (rev 01)
	Subsystem: Intel Corp.: Unknown device 414c
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 0
	Region 4: I/O ports at c000 [disabled] [size=16]

00:04.0 PIC: Intel Corp. 683053 Programmable Interrupt Device (rev 01)
(prog-if 20 [IO(X)-APIC])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (2000ns min, 2000ns max)

00:05.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100]
(rev 08)
	Subsystem: Intel Corp. 82559 Fast Ethernet LAN on Motherboard
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (2000ns min, 14000ns max), cache line size 10
	Interrupt: pin A routed to IRQ 55
	Region 0: Memory at 00000000fafe0000 (32-bit, non-prefetchable)
[size=3D4K]
	Region 1: I/O ports at 6f00 [sized]
	Region 2: Memory at 00000000fae00000 (32-bit, non-prefetchable)
[size=3D1M]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=3D0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D2 PME-

00:06.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
(prog-if 00 [VGA])
	Subsystem: Intel Corp.: Unknown device 414c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (2000ns min), cache line size 10
	Interrupt: pin A routed to IRQ 56
	Region 0: Memory at 00000000fb000000 (32-bit, non-prefetchable)
[size=16M]
	Region 1: I/O ports at 6800 [size%6]
	Region 2: Memory at 00000000faff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Expansion ROM at 00000000fafc0000 [disabled] [size=128K]
	Capabilities: [5c] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

00:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

01:02.0 SCSI storage controller: QLogic Corp. ISP12160 Dual Channel
Ultra3 SCSI Processor (rev 06)
	Subsystem: QLogic Corp.: Unknown device 0007
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (16000ns min), cache line size 10
	Interrupt: pin A routed to IRQ 61
	Region 0: I/O ports at 8800 [size%6]
	Region 1: Memory at 00000000f1ff0000 (32-bit, non-prefetchable)
[size=3D4K]
	Expansion ROM at 00000000f1fc0000 [disabled] [size=128K]
	Capabilities: [44] Power Management version 1
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

01:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 62
	Region 0: Memory at 00000000f1fe0000 (32-bit, non-prefetchable)
[size%6]

04:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 62
	Region 0: Memory at 00000000e7ff0000 (32-bit, non-prefetchable)
[size%6]

08:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 77
	Region 0: Memory at 00000000ddff0000 (32-bit, non-prefetchable)
[size%6]

0c:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 77
	Region 0: Memory at 00000000d5ff0000 (32-bit, non-prefetchable)
[size%6]

0f:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 84
	Region 0: Memory at 00000000cdff0000 (32-bit, non-prefetchable)
[size%6]

12:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX Integrated Hot-Plug
Controller (IHPC) (rev 01)
	Subsystem: Intel Corp.: Unknown device 012b
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 84
	Region 0: Memory at 00000000c5ff0000 (32-bit, non-prefetchable)
[size%6]

15:00.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:00.1 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:00.2 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:00.3 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:00.4 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:00.5 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:00.6 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:00.7 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.1 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.2 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.3 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.4 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.5 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.6 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:01.7 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:04.0 Host bridge: Intel Corp. 460GX - 84460GX System Data Controller
(SDC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Data Controller
(SDC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:10.1 Host bridge: Intel Corp. 450NX - 82454NX/84460GX PCI Expander
Bridge (rev 05)
	Subsystem: Intel Corp. 450NX - 82454NX/84460GX PCI Expander
Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 128, cache line size 10

15:11.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:12.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:12.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, cache line size 10
	Capabilities: [90] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

15:13.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:13.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32, cache line size 10
	Capabilities: [90] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

15:14.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:14.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, cache line size 10
	Capabilities: [90] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

15:15.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:15.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, cache line size 10
	Capabilities: [90] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

15:16.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:16.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, cache line size 10
	Capabilities: [90] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

15:17.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
Controller (SAC) (rev 03)
	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
(SAC)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
<TAbort- <MAbort- >SERR- <PERR-

15:17.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB) (rev 07)
	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
eXpander Bridge (WXB)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, cache line size 10
	Capabilities: [90] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
PME(D0-,D1-,D2-,D3hot
-,D3cold-)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-

Unmounting file systems: kernel BUG at include/linux/smp_lock.h:52!

umount[2078]: bugcheck! 0 [1]


Pid: 2078, CPU 1, comm:               umount

psr : 0000101008026018 ifs : 800000000000038b ip  : [<a0000001001395f0>]
Not tainted

ip is at do_umount+0x750/0x760

unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003

rnat: a000000100738a93 bsps: a000000100632210 pr  : 0000000005a66959

ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f

csd : 0000000000000000 ssd : 0000000000000000

b0  : a0000001001395f0 b6  : a0000001000090e0 b7  : a0000001002d5100

f6  : 1003e00000000000000a0 f7  : 0ffdbca80000000000000

f8  : 1003e00000000000000a0 f9  : 1003e0000000000000001

f10 : 0fffdfffffffffaf00000 f11 : 1003e0000000000000000

r1  : a0000001009007a0 r2  : ffffffffffffffb8 r3  : 0000000000002ff7

r8  : 000000000000002b r9  : 0000000000000001 r10 : 0000000000000000

r11 : a0000001007044c0 r12 : e00000005d777e00 r13 : e00000005d770000

r14 : 0000000000000001 r15 : a000000100715e64 r16 : a000000100715e88

r17 : 0000000000004000 r18 : 0000000000004000 r19 : 0000000000000000

r20 : a000000100713af0 r21 : a00000010064e200 r22 : a00000010064e200

r23 : a000000100700a68 r24 : 00000000000003f9 r25 : 0000000000ffffff

r26 : 00000000000003f9 r27 : 00000000000003f8 r28 : a000000100075bf0

r29 : a0000001000090e0 r30 : 0000000000000000 r31 : a000000100713ab8


Call Trace:

 [<a000000100015040>] show_stack+0x80/0xa0

                                sp=E00000005d7779d0 bsp=E00000005d770dd8

 [<a000000100023d10>] die+0x1d0/0x280

                                sp=E00000005d777ba0 bsp=E00000005d770db0

 [<a000000100024040>] ia64_bad_break+0x220/0x340

                                sp=E00000005d777ba0 bsp=E00000005d770d90

 [<a00000010000df20>] ia64_leave_kernel+0x0/0x260

                                sp=E00000005d777c30 bsp=E00000005d770d90

 [<a0000001001395f0>] do_umount+0x750/0x760

                                sp=E00000005d777e00 bsp=E00000005d770d38

 [<a000000100139760>] sys_umount+0x160/0x180
		        sp=E00000005d777e00 bsp=E00000005d770cd0
 [<a00000010000dda0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000005d777e30 bsp=E00000005d770cd0

                   =20

From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 02 Jun 2004 12:41:20 +0000
Subject: IA64 test report: 2.6.7-rc1 /tiger 2004-6-2: 9/9 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F840483B5C4@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ACPI Test Report  for 2.6 ia64 kernel 
============Hardware Configuration:
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
	USB mouse 
	USB keyboard
	Ethernet Pro 1000

Software Configuration:
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.5 on 6/2(Shanghai
time)
	2.bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.6.7 on
6/2(Shanghai time)
	
ACPI Features Tested: (prioritized).
--------------------	
1. Boot 					tested ok
2. serial console				tested ok
3. ATI (run X window system)		tested ok
4. usb keyboard				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)		tested ok
9. Soft Power off 			tested ok


 root a000000100ad8888
evxfevnt-0082 [04] acpi_enable           : System is already in ACPI
mode
evgpeblk-0867 [06] ev_create_gpe_block   : GPE 00 to 31 [_GPE] 4 regs at
0000000000000C28 on int 9
evgpeblk-0925 [06] ev_create_gpe_block   : Found 0 Wake, Enabled 7
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
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
GSI 16 (level, low) -> CPU 2 (0xc418) vector 48
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 48
GSI 19 (level, low) -> CPU 2 (0xc418) vector 49
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
GSI 23 (level, low) -> CPU 2 (0xc418) vector 50
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 50
 pci_irq-0314 [02] acpi_pci_irq_derive   : Unable to derive IRQ for
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
GSI 143 (level, low) -> CPU 2 (0xc418) vector 59
ACPI: PCI interrupt 0000:12:1f.0[A] -> GSI 143 (level, low) -> IRQ 59
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
ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
acpi_serial_port: zero-length IO port range?
ttyS1 at I/O 0x2f8 (irq = 45) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.2.39-k2
Copyright (c) 1999-2004 Intel Corporation.
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 18 (level, low) -> IRQ 51
eth0: Intel(R) PRO/1000 Network Connection
Ethernet Channel Bonding Driver: v2.6.0 (January 14, 2004)
bonding: Warning: either miimon or arp_interval and arp_ip_target module
parameters must be specified, otherwise bonding will not detect link
failures! see bonding.txt for details.
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=xx
hda: MATSHITADVD-ROM SR-8176, ATAPI CD/DVD-ROM drive
hdb: LS-120/240 00 UHD Floppy, ATAPI FLOPPY drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hda: ATAPI 24X DVD-ROM drive, 256kB Cache
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
hdb: No disk in drive
hdb: 234752kB, 262/32/56 CHS, 2995 kBps, 512 sector size, 1500 rpm
st: Version 20040403, fixed bufsize 32768, s/g segs 256
osst :I: Tape driver with OnStream support version 0.99.1
osst :I: $Id: osst.c,v 1.70 2003/12/23 14:22:12 wriede Exp $
Fusion MPT base driver 3.01.06
Copyright (c) 1999-2004 LSI Logic Corporation
ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 53
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities={Initiator}
ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 54
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities={Initiator}
Fusion MPT SCSI Host driver 3.01.06
scsi0 : ioc0: LSI53C1030, FwRev030a00h, Ports=1, MaxQ%5, IRQS
  Vendor: SEAGATE   Model: ST318406LC        Rev: 8A03
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sda: 35566478 512-byte hdwr sectors (18210 MB)
SCSI device sda: drive cache: write through
 sda: sda1 sda2 sda3
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0
  Vendor: ESG-SHV   Model: SCA HSBP M17      Rev: 1.0A
  Type:   Processor                          ANSI SCSI revision: 02
Attached scsi generic sg1 at scsi0, channel 0, id 6, lun 0,  type 3
scsi1 : ioc1: LSI53C1030, FwRev030a00h, Ports=1, MaxQ%5, IRQT
ehci_hcd: block sizes: qh 192 qtd 96 itd 192 sitd 96
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 50
ehci_hcd 0000:00:1d.7: Intel Corp. 82801DB (ICH4) USB2 EHCI Controller
ehci_hcd 0000:00:1d.7: reset hcs_params 0x102204 dbg=1 cc=2 pcc=2
ordered !ppc ports=4
ehci_hcd 0000:00:1d.7: reset hcc_params 6871 thresh 7 uframes 1024 64
bit addr
ehci_hcd 0000:00:1d.7: capability 0001 at 68
ehci_hcd 0000:00:1d.7: irq 50, pci mem c0000000f9ff0000
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: reset command 080002 (park)=0 ithresh=8
period24 Reset HALT
PCI: slot 0000:00:1d.7 has incorrect PCI cache line size of 0 bytes,
correcting to 128
ehci_hcd 0000:00:1d.7: init command 010001 (park)=0 ithresh=1
period24 RUN
ehci_hcd 0000:00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2004-May-10
ehci_hcd 0000:00:1d.7: supports USB remote wakeup
usb usb1: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: default language 0x0409
usb usb1: Product: Intel Corp. 82801DB (ICH4) USB2 EHCI Controller
usb usb1: Manufacturer: Linux 2.6.7-rc1 ehci_hcd
usb usb1: SerialNumber: 0000:00:1d.7
usb usb1: hotplug
usb usb1: adding 1-0:1.0 (config #1, interface 0)
usb 1-0:1.0: hotplug
hub 1-0:1.0: usb_probe_interface
hub 1-0:1.0: usb_probe_interface - got id
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 4 ports detected
hub 1-0:1.0: standalone hub
hub 1-0:1.0: ganged power switching
hub 1-0:1.0: individual port over-current protection
hub 1-0:1.0: Single TT
hub 1-0:1.0: TT requires at most 8 FS bit times
hub 1-0:1.0: power on to power good time: 20ms
hub 1-0:1.0: local power source is good
hub 1-0:1.0: enabling power on all ports
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ohci_hcd: block sizes: ed 80 td 96
USB Universal Host Controller Interface driver v2.2
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 48
uhci_hcd 0000:00:1d.0: Intel Corp. 82801DB (ICH4) USB UHCI #1
ehci_hcd 0000:00:1d.7: GetStatus port 4 status 001803 POWER sig=j  CSC
CONNECT
hub 1-0:1.0: port 4, status 0501, change 0001, 480 Mb/s
uhci_hcd 0000:00:1d.0: irq 48, io base 0000000000004cc0
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
hub 1-0:1.0: debounce: port 4: delay 100ms stable 4 status 0x501
uhci_hcd 0000:00:1d.0: detected 2 ports
hub 1-0:1.0: port 4 not reset yet, waiting 50ms
usb usb2: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: default language 0x0409
usb usb2: Product: Intel Corp. 82801DB (ICH4) USB UHCI #1
ehci_hcd 0000:00:1d.7: port 4 full speed --> companion
ehci_hcd 0000:00:1d.7: GetStatus port 4 status 003801 POWER OWNER sig=j
CONNECT
usb usb2: Manufacturer: Linux 2.6.7-rc1 uhci_hcd
usb usb2: SerialNumber: 0000:00:1d.0
usb usb2: hotplug
usb usb2: adding 2-0:1.0 (config #1, interface 0)
usb 2-0:1.0: hotplug
hub 2-0:1.0: usb_probe_interface
hub 2-0:1.0: usb_probe_interface - got id
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
hub 2-0:1.0: standalone hub
hub 2-0:1.0: no power switching (usb 1.0)
hub 2-0:1.0: individual port over-current protection
hub 2-0:1.0: power on to power good time: 2ms
hub 2-0:1.0: local power source is good
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB (ICH4) USB UHCI #2
uhci_hcd 0000:00:1d.1: irq 49, io base 0000000000004ce0
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.1: detected 2 ports
usb usb3: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: default language 0x0409
usb usb3: Product: Intel Corp. 82801DB (ICH4) USB UHCI #2
usb usb3: Manufacturer: Linux 2.6.7-rc1 uhci_hcd
usb usb3: SerialNumber: 0000:00:1d.1
usb usb3: hotplug
usb usb3: adding 3-0:1.0 (config #1, interface 0)
usb 3-0:1.0: hotplug
hub 3-0:1.0: usb_probe_interface
hub 3-0:1.0: usb_probe_interface - got id
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
hub 3-0:1.0: standalone hub
hub 3-0:1.0: no power switching (usb 1.0)
hub 3-0:1.0: individual port over-current protection
hub 3-0:1.0: power on to power good time: 2ms
hub 3-0:1.0: local power source is good
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
serio: i8042 AUX port at 0x60,0x64 irq 36
uhci_hcd 0000:00:1d.1: port 2 portsc 0093
hub 3-0:1.0: port 2, status 0101, change 0001, 12 Mb/s
atkbd.c: keyboard reset failed on isa0060/serio1
hub 3-0:1.0: debounce: port 2: delay 100ms stable 4 status 0x101
usb 3-2: new full speed USB device using address 2
usb 3-2: new device strings: Mfr=0, Product=1, SerialNumber=0
usb 3-2: default language 0x0409
usb 3-2: Product: USB Hub
usb 3-2: hotplug
usb 3-2: adding 3-2:1.0 (config #1, interface 0)
usb 3-2:1.0: hotplug
hub 3-2:1.0: usb_probe_interface
hub 3-2:1.0: usb_probe_interface - got id
hub 3-2:1.0: USB hub found
serio: i8042 KBD port at 0x60,0x64 irq 32
hub 3-2:1.0: 7 ports detected
hub 3-2:1.0: standalone hub
hub 3-2:1.0: individual port power switching
hub 3-2:1.0: individual port over-current protection
hub 3-2:1.0: power on to power good time: 100ms
hub 3-2:1.0: local power source is good
hub 3-2:1.0: enabling power on all ports
atkbd.c: keyboard reset failed on isa0060/serio0
hub 3-2:1.0: port 1, status 0301, change 0001, 1.5 Mb/s
hub 3-2:1.0: debounce: port 1: delay 100ms stable 4 status 0x301
EFI Variables Facility v0.08 2004-May-17
NET: Registered protocol family 2
IP: routing cache hash table of 16384 buckets, 256Kbytes
usb 3-2.1: new low speed USB device using address 3
usb 3-2.1: skipped 1 descriptor after interface
usb 3-2.1: skipped 1 descriptor after interface
usb 3-2.1: new device strings: Mfr=1, Product=2, SerialNumber=0
usb 3-2.1: default language 0x0409
usb 3-2.1: Product: USB Composite Keyboard
usb 3-2.1: Manufacturer: SOLIDTEK
usb 3-2.1: hotplug
usb 3-2.1: adding 3-2.1:1.0 (config #1, interface 0)
usb 3-2.1:1.0: hotplug
usbhid 3-2.1:1.0: usb_probe_interface
usbhid 3-2.1:1.0: usb_probe_interface - got id
input: USB HID v1.10 Keyboard [SOLIDTEK USB Composite Keyboard] on
usb-0000:00:1d.1-2.1
usb 3-2.1: adding 3-2.1:1.1 (config #1, interface 1)
usb 3-2.1:1.1: hotplug
usbhid 3-2.1:1.1: usb_probe_interface
usbhid 3-2.1:1.1: usb_probe_interface - got id
drivers/usb/input/hid-core.c: ctrl urb status -32 received
drivers/usb/input/hid-core.c: ctrl urb status -32 received
drivers/usb/input/hid-core.c: ctrl urb status -32 received
drivers/usb/core/file.c: looking for a minor, starting at 96
input,hiddev96: USB HID v1.10 Device [SOLIDTEK USB Composite Keyboard]
on usb-0000:00:1d.1-2.1
hub 3-2:1.0: port 3, status 0301, change 0001, 1.5 Mb/s
hub 3-2:1.0: debounce: port 3: delay 100ms stable 4 status 0x301
uhci_hcd 0000:00:1d.0: suspend_hc
usb 3-2.3: new low speed USB device using address 4
usb 3-2.3: skipped 1 descriptor after interface
usb 3-2.3: new device strings: Mfr=1, Product=3, SerialNumber=0
usb 3-2.3: default language 0x0409
usb 3-2.3: Product: Microsoft 5-Button Mouse with IntelliEye(TM)
TCP: Hash tables configured (established 131072 bind 65536)
arp_tables: (C) 2002 David S. Miller
NET: Registered protocol family 1
NET: Registered protocol family 17
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 240kB freed
usb 3-2.3: Manufacturer: Microsoft
usb 3-2.3: hotplug
usb 3-2.3: adding 3-2.3:1.0 (config #1, interface 0)
usb 3-2.3:1.0: hotplug
usbhid 3-2.3:1.0: usb_probe_interface
usbhid 3-2.3:1.0: usb_probe_interface - got id
input: USB HID v1.10 Mouse [Microsoft Microsoft 5-Button Mouse with
IntelliEye(TM)] on usb-0000:00:1d.1-2.3
hub 3-2:1.0: port 4, status 0301, change 0001, 1.5 Mb/s
hub 3-2:1.0: debounce: port 4: delay 100ms stable 4 status 0x301
usb 3-2.4: new low speed USB device using address 5
usb 3-2.4: skipped 1 descriptor after interface
usb 3-2.4: skipped 1 descriptor after interface
usb 3-2.4: new device strings: Mfr=1, Product=2, SerialNumber=0
usb 3-2.4: default language 0x0409
usb 3-2.4: Product: Generic KVM104UC
usb 3-2.4: Manufacturer: Tangtop
usb 3-2.4: hotplug
usb 3-2.4: adding 3-2.4:1.0 (config #1, interface 0)
usb 3-2.4:1.0: hotplug
usbhid 3-2.4:1.0: usb_probe_interface
usbhid 3-2.4:1.0: usb_probe_interface - got id
input: USB HID v1.00 Keyboard [Tangtop Generic KVM104UC] on
usb-0000:00:1d.1-2.4
usb 3-2.4: adding 3-2.4:1.1 (config #1, interface 1)
usb 3-2.4:1.1: hotplug
usbhid 3-2.4:1.1: usb_probe_interface
usbhid 3-2.4:1.1: usb_probe_interface - got id
input: USB HID v1.00 Mouse [Tangtop Generic KVM104UC] on
usb-0000:00:1d.1-2.4
EXT3 FS on sda2, internal journal
Adding 2024144k swap on /dev/sda3.  Priority:-1 extents:1
partx(743): unaligned access to 0x600000000000ca16,
ip=0x4000000000002ce1
partx(743): unaligned access to 0x600000000000ca1a,
ip=0x4000000000002d01
partx(743): unaligned access to 0x600000000000ca26,
ip=0x4000000000002ce1
partx(743): unaligned access to 0x600000000000ca2a,
ip=0x4000000000002d01
e1000: eth0 NIC Link is Up 100 Mbps Full Duplex
           CPU0       CPU1       CPU2       CPU3       
 29:          0          0          0          0          LSAPIC
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level
cpe_hndlr
 31:          0          0          0          0          LSAPIC
cmc_hndlr
 34:          0         73          1          0   IO-SAPIC-edge  ide0
 39:          0          3          0          0  IO-SAPIC-level  acpi
 48:          0          0          0          0  IO-SAPIC-level
uhci_hcd
 49:          2       1339         10        204  IO-SAPIC-level
uhci_hcd
 50:          0          0          0          2  IO-SAPIC-level
ehci_hcd
 51:          0        151          0          2  IO-SAPIC-level  eth0
 53:         25       3183         21        141  IO-SAPIC-level  ioc0
 54:          0         44          0          0  IO-SAPIC-level  ioc1
232:          0          0          0          0          LSAPIC
mca_rdzv
238:          0          0          0          0          LSAPIC
perfmon
239:     153721     149338     149122     148888          LSAPIC  timer
240:          0          0          0          0          LSAPIC
mca_wkup
254:         78         51         46         86          LSAPIC  IPI
NMI:          0          0          0          0 
ERR:          0
00:1d.0 USB Controller: Intel Corp. 82801DB USB (Hub #1) (rev 02)
(prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, medium devsel, latency 0, IRQ 48
	I/O ports at 4cc0 [size2]

00:1d.1 USB Controller: Intel Corp. 82801DB USB (Hub #2) (rev 02)
(prog-if 00 [UHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, medium devsel, latency 0, IRQ 49
	I/O ports at 4ce0 [size2]

00:1d.7 USB Controller: Intel Corp. 82801DB USB2 (rev 02) (prog-if 20
[EHCI])
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, medium devsel, latency 0, IRQ 50
	Memory at 00000000f9ff0000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] #0a [2080]

00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB PCI Bridge (rev 82)
(prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary , secondary, subordinate, sec-latencyd
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: fa000000-fbffffff

00:1f.0 ISA bridge: Intel Corp. 82801DB LPC Interface Controller (rev
02)
	Flags: bus master, medium devsel, latency 0

00:1f.1 IDE interface: Intel Corp. 82801DB Ultra ATA Storage Controller
(rev 02) (prog-if 8a [Master SecP PriP])
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, medium devsel, latency 0
	I/O ports at <unassigned>
	I/O ports at <unassigned>
	I/O ports at <unassigned>
	I/O ports at <unassigned>
	I/O ports at 1000 [size]
	Memory at <unassigned> (32-bit, non-prefetchable) [disabled]
[size=1K]

01:00.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
Controller (rev 02)
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 51
	Memory at 00000000fbfe0000 (32-bit, non-prefetchable)
[size8K]
	I/O ports at 5cc0 [sized]
	Capabilities: [dc] Power Management version 2
	Capabilities: [e4] PCI-X non-bridge device.
	Capabilities: [f0] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-

01:01.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
(prog-if 00 [VGA])
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, stepping, medium devsel, latency 64
	Memory at 00000000fa000000 (32-bit, non-prefetchable) [sizeM]
	I/O ports at 5800 [size%6]
	Memory at 00000000fbfd0000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at 00000000fbfa0000 [disabled] [size8K]
	Capabilities: [5c] Power Management version 2

02:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Flags: bus master, 66Mhz, fast devsel, latency 0
	Memory at 00000000f1ff0000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [50] PCI-X non-bridge device.

02:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 64
	Bus: primary, secondary, subordinate, sec-latencyd
	I/O behind bridge: 00006000-00007fff
	Memory behind bridge: f2000000-f5ffffff
	Prefetchable memory behind bridge:
00000000e3f00000-00000000ebf00000
	Capabilities: [50] PCI-X non-bridge device.

02:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Flags: bus master, 66Mhz, fast devsel, latency 0
	Memory at 00000000f1fe0000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [50] PCI-X non-bridge device.

02:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 64
	Bus: primary, secondary, subordinate, sec-latencyd
	I/O behind bridge: 00008000-00009fff
	Memory behind bridge: f6000000-f8ffffff
	Prefetchable memory behind bridge:
00000000ec000000-00000000f0f00000
	Capabilities: [50] PCI-X non-bridge device.

03:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 52
	Memory at 00000000e3ff0000 (64-bit, prefetchable) [size%6]
	Capabilities: [64] PCI-X non-bridge device.

06:02.0 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 53
	I/O ports at 8800 [size%6]
	Memory at 00000000f8fd0000 (64-bit, non-prefetchable) [sizedK]
	Memory at 00000000f8fc0000 (64-bit, non-prefetchable) [sizedK]
	Expansion ROM at 00000000f8d00000 [disabled] [size=1M]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
	Capabilities: [68] PCI-X non-bridge device.

06:02.1 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
	Subsystem: Intel Corp.: Unknown device 3402
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 54
	I/O ports at 8c00 [size%6]
	Memory at 00000000f8ff0000 (64-bit, non-prefetchable) [sizedK]
	Memory at 00000000f8fe0000 (64-bit, non-prefetchable) [sizedK]
	Expansion ROM at 00000000f8e00000 [disabled] [size=1M]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
	Capabilities: [68] PCI-X non-bridge device.

06:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 55
	Memory at 00000000f0ff0000 (64-bit, prefetchable) [size%6]
	Capabilities: [64] PCI-X non-bridge device.

09:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Flags: bus master, 66Mhz, fast devsel, latency 0
	Memory at 00000000dbff0000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [50] PCI-X non-bridge device.

09:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 64
	Bus: primary	, secondary
, subordinate, sec-latencyd
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: dc000000-ddffffff
	Prefetchable memory behind bridge:
00000000cbf00000-00000000cff00000
	Capabilities: [50] PCI-X non-bridge device.

09:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Flags: bus master, 66Mhz, fast devsel, latency 0
	Memory at 00000000dbfe0000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [50] PCI-X non-bridge device.

09:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 64
	Bus: primary	, secondary, subordinate, sec-latencyd
	I/O behind bridge: 0000b000-0000cfff
	Memory behind bridge: de000000-e2ffffff
	Prefetchable memory behind bridge:
00000000d0000000-00000000daf00000
	Capabilities: [50] PCI-X non-bridge device.

0a:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 56
	Memory at 00000000cbff0000 (64-bit, prefetchable) [size%6]
	Capabilities: [64] PCI-X non-bridge device.

0c:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03b0
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 57
	Memory at 00000000daff0000 (64-bit, prefetchable) [size%6]
	Capabilities: [64] PCI-X non-bridge device.

0f:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Flags: bus master, 66Mhz, fast devsel, latency 0
	Memory at 00000000c5ff0000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [50] PCI-X non-bridge device.

0f:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 64
	Bus: primary, secondary, subordinate, sec-latencyd
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: c6000000-c7ffffff
	Prefetchable memory behind bridge:
00000000bbf00000-00000000bff00000
	Capabilities: [50] PCI-X non-bridge device.

0f:1e.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20
[IO(X)-APIC])
	Flags: bus master, 66Mhz, fast devsel, latency 0
	Memory at 00000000c5fe0000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [50] PCI-X non-bridge device.

0f:1f.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04)
(prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, fast devsel, latency 64
	Bus: primary, secondary, subordinate, sec-latencyd
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: c8000000-caffffff
	Prefetchable memory behind bridge:
00000000c0000000-00000000c4f00000
	Capabilities: [50] PCI-X non-bridge device.

10:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 58
	Memory at 00000000bbff0000 (64-bit, prefetchable) [size%6]
	Capabilities: [64] PCI-X non-bridge device.

12:1f.0 PCI Hot-plug controller: Intel Corp. 82870P2 P64H2 Hot Plug
Controller (rev 04)
	Subsystem: Intel Corp.: Unknown device 03f0
	Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 59
	Memory at 00000000c4ff0000 (64-bit, prefetchable) [size%6]
	Capabilities: [64] PCI-X non-bridge device.

ff:18.0 Host bridge: Intel Corp.: Unknown device 0500 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: fast devsel

ff:18.1 Host bridge: Intel Corp.: Unknown device 0501 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: fast devsel

ff:18.2 Host bridge: Intel Corp.: Unknown device 0502 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: fast devsel

ff:18.3 Host bridge: Intel Corp.: Unknown device 0503 (rev 20)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: fast devsel

ff:1c.0 Host bridge: Intel Corp.: Unknown device 0510 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: bus master, fast devsel, latency 0

ff:1c.1 Host bridge: Intel Corp.: Unknown device 0511 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: bus master, fast devsel, latency 0

ff:1c.2 Host bridge: Intel Corp.: Unknown device 0512 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: bus master, fast devsel, latency 0

ff:1c.3 Host bridge: Intel Corp.: Unknown device 0513 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: bus master, fast devsel, latency 0

ff:1c.4 Host bridge: Intel Corp.: Unknown device 0514 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: bus master, fast devsel, latency 0

ff:1c.5 Host bridge: Intel Corp.: Unknown device 0515 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: fast devsel

ff:1c.6 Host bridge: Intel Corp.: Unknown device 0516 (rev 22)
	Subsystem: Intel Corp.: Unknown device 8086
	Flags: fast devsel




From: "Pu, Long" <long.pu@intel.com>
Date: Fri, 15 Oct 2004 01:50:55 +0000
Subject: IA64 ACPI test report: Almost all pass: 2.6.9-rc3 /tiger 2004-10-13
Message-Id: <3ACA40606221794F80A5670F0AF15F840546020F@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

----------------------------------------------
ACPI Test Report for 2.6 ia64 kernel 
============Hardware Configuration:
-----------------------
System Name: ACPI-Tiger
System Type: 4 way 1.4GHz Itanium2, tiger
M/B revision: N/A
Processor version: N/A
Firmware Versions: N/A
I/O configuration summary:
	SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
	IDE floppy and CDROM
	Serial console
	USB mouse 
	USB keyboard
	Ethernet Pro 1000

Software Configuration:
1.	bk pull http://lia64.bkbits.net:8080/linux-ia64-test-2.6.9 on
13/10 (Shanghai Time)
2.  bk http://linux-acpi.bkbits.net:8080/26-latest-test on
13/10(Shanghai Time)

ACPI Features Tested: (prioritized).
--------------------	
1. Boot 					tested ok
2. serial console				tested ok
3. ATI (run X window system)		tested ok
4. usb keyboard				tested ok
5. USB mouse				tested ok
6. NIC (eg. Ping or ftp)			tested ok
7. IDE (eg. r/w floppy or CDROM)	tested ok
8. SCI (eg. Press power button)	 failed
	There are some unaligned accesses from ACPI_DEBUG_PRINT in
acpi_hw_low_level_read(). 
	When CONFIG_ACPI_DEBUG is set, you will get some error message
like "
kernel unaligned access to 0xe0000002fff72553, ip=0xa00000010038df61
kernel unaligned access to 0xe0000002fff7255f, ip=0xa00000010038df61
kernel unaligned access to 0xe0000002fff72553, ip=0xa000000100373860
kernel unaligned access to 0xe0000002fff7255f, ip=0xa000000100373861" 
	after you stop the acpid service and press down power button 

The cause is that the last parameter of acpi_hw_low_level_read() passed
from acpi_ev_gpe_detect() is an unaligned pointer to a structure
acpi_generic_address. In cpi_hw_low_level_read(),ACPI_FORMAT_UINT64()
will access a member of that structure and the access is unaligned.

9. Soft Power off 			tested ok

Linux version 2.6.9-rc3-acpi (root@tiger43) (gcc version 3.4.1 20040831
(Red Hat 3.4.1-10)) #2 SMP Thu Oct 14 11:41:35 EDT 2004
EFI v1.10 by INTEL: SALsystab=0x3fe4c8c0 ACPI=0x3ff84000 ACPI
2.0=0x3ff83000 MPS=0x3ff82000 SMBIOS=0xf0000
booting generic kernel on platform dig
ACPI: RSDP (v002 INTEL                                 ) @
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
Initial ramdisk at: 0xe00000003c72e000 (1661999 bytes)
SAL 3.1: Intel Corp                       SR870BN4
version 3.0
SAL Platform features: BusLock IRQ_Redirection
SAL: AP wakeup using external interrupt vector 0xf0
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address c0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0xc618) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
4 CPUs available, 4 CPUs total
Registering legacy COM ports for serial console
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffc80000
On node 0 totalpages: 63281
  DMA zone: 63281 pages, LIFO batch:4
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
Built 1 zonelists
Kernel command line: BOOT_IMAGE=scsi0:EFI\redhat\vmlinuz-2.6.9-rc3-acpi
root=LABEL=/ hugepagesz=1M
PID hash table entries: 2048 (order: 11, 65536 bytes)
CPU 0: base freq9.458MHz, ITC ratio/2, ITC
freq96.207MHz+/--1ppm
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 6, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 5, 524288 bytes)
Placing software IO TLB between 0x4bbc000 - 0x8bbc000
Memory: 939840k/1012496k available (8252k code, 85984k reserved, 3099k
data, 384k init)
McKinley Errata 9 workaround not needed; disabling it
Calibrating delay loop... 2089.76 BogoMIPS (lpj19904)
Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)
Boot processor id 0x0/0xc618
task migration cache decay timeout: 10 msecs.
CPU 1: synchronized ITC with CPU 0 (last diff 13 cycles, maxerr 520
cycles)
CPU 1: base freq9.458MHz, ITC ratio/2, ITC
freq96.207MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS (lpj19904)
CPU 2: synchronized ITC with CPU 0 (last diff 13 cycles, maxerr 520
cycles)
CPU 2: base freq9.458MHz, ITC ratio/2, ITC
freq96.207MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS (lpj19904)
CPU 3: synchronized ITC with CPU 0 (last diff 13 cycles, maxerr 520
cycles)
CPU 3: base freq9.458MHz, ITC ratio/2, ITC
freq96.207MHz+/--1ppm
Calibrating delay loop... 2089.76 BogoMIPS (lpj19904)
Brought up 4 CPUs
Total of 4 processors activated (8359.04 BogoMIPS).
checking if image is initramfs... it is
Freeing initrd memory: 1600kB freed
NET: Registered protocol family 16
ACPI: Subsystem revision 20040816
kernel unaligned access to 0xe00000003feede5f, ip=0xa0000001003bedc0
kernel unaligned access to 0xe00000003feede6e, ip=0xa0000001003bedc0
kernel unaligned access to 0xe00000003feede95, ip=0xa0000001003bedc0
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
GSI 16 (level, low) -> CPU 1 (0xc218) vector 48
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 48
GSI 19 (level, low) -> CPU 1 (0xc218) vector 49
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
GSI 23 (level, low) -> CPU 1 (0xc218) vector 50
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 50
ACPI: PCI interrupt 0000:00:1f.1[A]: no GSI
GSI 18 (level, low) -> CPU 1 (0xc218) vector 51
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 18 (level, low) -> IRQ 51
GSI 71 (level, low) -> CPU 1 (0xc218) vector 52
ACPI: PCI interrupt 0000:03:1f.0[A] -> GSI 71 (level, low) -> IRQ 52
GSI 24 (level, low) -> CPU 1 (0xc218) vector 53
ACPI: PCI interrupt 0000:06:01.0[A] -> GSI 24 (level, low) -> IRQ 53
GSI 28 (level, low) -> CPU 1 (0xc218) vector 54
ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 54
GSI 29 (level, low) -> CPU 1 (0xc218) vector 55
ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 55
GSI 47 (level, low) -> CPU 1 (0xc218) vector 56
ACPI: PCI interrupt 0000:06:1f.0[A] -> GSI 47 (level, low) -> IRQ 56
GSI 119 (level, low) -> CPU 1 (0xc218) vector 57
ACPI: PCI interrupt 0000:09:1f.0[A] -> GSI 119 (level, low) -> IRQ 57
GSI 95 (level, low) -> CPU 1 (0xc218) vector 58
ACPI: PCI interrupt 0000:0b:1f.0[A] -> GSI 95 (level, low) -> IRQ 58
GSI 167 (level, low) -> CPU 1 (0xc218) vector 59
ACPI: PCI interrupt 0000:0f:1f.0[A] -> GSI 167 (level, low) -> IRQ 59
GSI 120 (level, low) -> CPU 1 (0xc218) vector 60
ACPI: PCI interrupt 0000:11:01.0[A] -> GSI 120 (level, low) -> IRQ 60
GSI 143 (level, low) -> CPU 1 (0xc218) vector 61
ACPI: PCI interrupt 0000:11:1f.0[A] -> GSI 143 (level, low) -> IRQ 61
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Total HugeTLB memory allocated, 0
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
Initializing Cryptographic API
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU0] (supports C1)
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
EFI Time Services Driver v0.4
Linux agpgart interface v0.100 (c) Dave Jones
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing
disabled
acpi_serial_port: zero-length IO port range?
ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
acpi_serial_port: zero-length IO port range?
ttyS1 at I/O 0x2f8 (irq = 45) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 5.3.19-k2
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
idebus=xx
ide-floppy driver 0.99.newide
ACPI: PCI interrupt 0000:11:01.0[A] -> GSI 120 (level, low) -> IRQ 60
(scsi0) <Adaptec AHA-294X Ultra2 SCSI host adapter> found at PCI 17/1/0
(scsi0) Wide Channel, SCSI ID=7, 32/255 SCBs
(scsi0) Downloading sequencer code... 398 instructions downloaded
scsi0 : Adaptec AHA274x/284x/294x (EISA/VLB/PCI-Fast SCSI) 5.2.6/5.2.0
       <Adaptec AHA-294X Ultra2 SCSI host adapter>
Using anticipatory io scheduler
st: Version 20040403, fixed bufsize 32768, s/g segs 256
osst :I: Tape driver with OnStream support version 0.99.1
osst :I: $Id: osst.c,v 1.70 2003/12/23 14:22:12 wriede Exp $
Fusion MPT base driver 3.01.16
Copyright (c) 1999-2004 LSI Logic Corporation
ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 54
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities={Initiator}
ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 55
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities={Initiator}
Fusion MPT SCSI Host driver 3.01.16
scsi1 : ioc0: LSI53C1030, FwRev030600h, Ports=1, MaxQ%5, IRQT
  Vendor: MAXTOR    Model: ATLASU320_18_SCA  Rev: B120
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sda: 35916548 512-byte hdwr sectors (18389 MB)
SCSI device sda: drive cache: write back
 sda: sda1 sda2 sda3
Attached scsi disk sda at scsi1, channel 0, id 1, lun 0
Attached scsi generic sg0 at scsi1, channel 0, id 1, lun 0,  type 0
  Vendor: QUANTUM   Model: ATLAS10K3_18_SCA  Rev: 120G
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sdb: 35566478 512-byte hdwr sectors (18210 MB)
SCSI device sdb: drive cache: write through
 sdb: sdb1 sdb2 sdb3
Attached scsi disk sdb at scsi1, channel 0, id 2, lun 0
Attached scsi generic sg1 at scsi1, channel 0, id 2, lun 0,  type 0
  Vendor: ESG-SHV   Model: SCA HSBP M17      Rev: 0101
  Type:   Processor                          ANSI SCSI revision: 02
Attached scsi generic sg2 at scsi1, channel 0, id 6, lun 0,  type 3
scsi2 : ioc1: LSI53C1030, FwRev030600h, Ports=1, MaxQ%5, IRQU
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 50
ehci_hcd 0000:00:1d.7: Intel Corp. 82801DB/DBM (ICH4/ICH4-M) USB 2.0
EHCI Controller
ehci_hcd 0000:00:1d.7: irq 50, pci mem c0000000f9ff0000
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
PCI: slot 0000:00:1d.7 has incorrect PCI cache line size of 0 bytes,
correcting to 128
ehci_hcd 0000:00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2004-May-10
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 4 ports detected
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
USB Universal Host Controller Interface driver v2.2
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 48
uhci_hcd 0000:00:1d.0: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)
USB UHCI Controller #1
uhci_hcd 0000:00:1d.0: irq 48, io base 0000000000005cc0
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 49
uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)
USB UHCI Controller #2
uhci_hcd 0000:00:1d.1: irq 49, io base 0000000000005ce0
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
NET: Registered protocol family 2
IP: routing cache hash table of 16384 buckets, 256Kbytes
TCP: Hash tables configured (established 131072 bind 65536)
arp_tables: (C) 2002 David S. Miller
NET: Registered protocol family 1
NET: Registered protocol family 17
Freeing unused kernel memory: 384kB freed
usb 2-2: new full speed USB device using address 2
hub 2-2:1.0: USB hub found
hub 2-2:1.0: 4 ports detected
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
usb 2-2.1: new low speed USB device using address 3
input: USB HID v1.00 Keyboard [USB Combi Keyboard] on
usb-0000:00:1d.0-2.1
input,hiddev96: USB HID v1.00 Device [USB Combi Keyboard] on
usb-0000:00:1d.0-2.1
EXT3 FS on sda2, internal journal
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
program scsi_unique_id is using a deprecated SCSI ioctl, please convert
it to SG_IO
Adding 4095968k swap on /dev/sda3.  Priority:-1 extents:1
                                                                  
 Pu Long


From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Tue, 20 Jul 2004 08:58:45 +0000
Subject: IA64 test report: 2.6.8-rc1 /tiger 2004-7-20: Boot Hang!
Message-Id: <6E0C289723A0564F9A8279E236E8565F07CB29D7@pdsmsx402.pd.intel.com>
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
	1.Bk pull form lia64.bkbits.net/linux-ia64-2.5 on 7/20(Shanghai
time)
	2.bk pull from linux-acpi.bkbits.net/linux-acpi-test-2.6.8 on
7/20(Shanghai time)
=09
Kernel Config file:
arch/ia64/defconfig=20

ACPI Features Tested: (prioritized).
--------------------=09
1. Boot 					_fail_
2. serial console			=09
3. ATI (run X window system)	=09
4. usb keyboard			=09
5. USB mouse			=09
6. NIC (eg. Ping or ftp)		=09
7. IDE (eg. r/w floppy or CDROM)=09
8. SCI (eg. Press power button)	=09
9. Soft Power off 		=09

Linux version 2.6.8-rc1 (root@acpi-tiger) (gcc version 3.2.3 20030502
(Red Hat Linux 3.2.3-20)) #1 SMP Tue Jul 20 15:52:29 CST 2004

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

SAL 3.1: Intel Corp                       SR870BN4
version 3.0

SAL Platform features: BusLock IRQ_Redirection

SAL: AP wakeup using external interrupt vector 0xf0

iosapic_system_init: Disabling PC-AT compatible 8259 interrupts

ACPI: Local APIC address 0xc0000000fee00000

PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0xc218) vector 30

register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level

4 CPUs available, 4 CPUs total

Registering legacy COM ports for serial console

MCA related initialization done

On node 0 totalpages: 64121

  DMA zone: 64121 pages, LIFO batch:4

  Normal zone: 0 pages, LIFO batch:1

  HighMem zone: 0 pages, LIFO batch:1

Built 1 zonelists

Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux.26
root=3D/dev/sda2 console=3DttyS1,9600n8 console=3Dtty0 ro

PID hash table entries: 2048 (order 11: 32768 bytes)

CPU 0: base freq=199.458MHz, ITC ratio=14/2, ITC
freq=1396.209MHz+/--1ppm

Console: colour VGA+ 80x25

Dentry cache hash table entries: 131072 (order: 6, 1048576 bytes)

Inode-cache hash table entries: 65536 (order: 5, 524288 bytes)

Memory: 1008192k/1025936k available (7281k code, 17360k reserved, 3306k
data, 208k init)

McKinley Errata 9 workaround not needed; disabling it

Calibrating delay loop... 2089.76 BogoMIPS

Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)

Boot processor id 0x0/0xc218

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

NET: Registered protocol family 16

ACPI: Subsystem revision 20040715

ACPI: Interpreter enabled

ACPI: Using IOSAPIC for interrupt routing

ACPI: PCI Root Bridge [PCI0] (00:00)

PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1

ACPI: PCI Root Bridge [PCI1] (00:02)

ACPI: PCI Root Bridge [PCI3] (00:09)

ACPI: PCI Root Bridge [PCI4] (00:0f)

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

ACPI: PCI interrupt 0000:12:01.0[A] -> GSI 120 (level, low) -> IRQ 59

e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection

Ethernet Channel Bonding Driver: v2.6.0 (January 14, 2004)

bonding: Warning: either miimon or arp_interval and arp_ip_target module
parameters must be specified, otherwise bonding will not detect link
failures! see bonding.txt for details.

Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2

ide: Assuming 33MHz system bus speed for PIO modes; override with
idebus=3Dxx

st: Version 20040403, fixed bufsize 32768, s/g segs 256

osst :I: Tape driver with OnStream support version 0.99.1

osst :I: $Id: osst.c,v 1.70 2003/12/23 14:22:12 wriede Exp $

Fusion MPT base driver 3.01.09

Copyright (c) 1999-2004 LSI Logic Corporation

ACPI: PCI interrupt 0000:06:02.0[A] -> GSI 28 (level, low) -> IRQ 53

mptbase: Initiating ioc0 bringup

ioc0: 53C1030: Capabilities=3D{Initiator}

ACPI: PCI interrupt 0000:06:02.1[B] -> GSI 29 (level, low) -> IRQ 54

mptbase: Initiating ioc1 bringup

ioc1: 53C1030: Capabilities=3D{Initiator}

Fusion MPT SCSI Host driver 3.01.09

scsi0 : ioc0: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQS

Using anticipatory io scheduler

  Vendor: SEAGATE   Model: ST318406LC        Rev: 8A03

  Type:   Direct-Access                      ANSI SCSI revision: 03

SCSI device sda: 35566478 512-byte hdwr sectors (18210 MB)

SCSI device sda: drive cache: write through

 sda: sda1 sda2 sda3

Attached scsi disk sda at scsi0, channel 0, id 0, lun 0

Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0

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

mice: PS/2 mouse device common for all mice

EFI Variables Facility v0.08 2004-May-17

NET: Registered protocol family 2

IP: routing cache hash table of 16384 buckets, 256Kbytes

TCP: Hash tables configured (established 131072 bind 65536)

arp_tables: (C) 2002 David S. Miller

NET: Registered protocol family 1

usb 3-1: new full speed USB device using address 2

hub 3-1:1.0: USB hub found

hub 3-1:1.0: 7 ports detected

NET: Registered protocol family 17

kjournald starting.  Commit interval 5 seconds

EXT3-fs: mounted filesystem with ordered data mode.

VFS: Mounted root (ext3 filesy>tem) r1.1:only.
owFspeid UuBudedike uelnm addre 208kB fhelper[221]: Unsupported data
reference 8821862825984 [1]

Modules linked in:


Pid: 221, CPU 3, comm:              khelper

psr : 00001010085a2010 ifs : 8000000000000813 ip  : [<a0000001005fed30>]
Not tainted

ip is at sba_alloc_range+0x50/0x1280

unat: 0000000000000000 pfs : 0000000000000814 rsc : 0000000000000003

rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000065995

ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f

csd : 0000000000000000 ssd : 0000000000000000

b0  : a000000100600f80 b6  : a000000100308d00 b7  : a00000010055e3a0

f6  : 1003e6db6db6db6db6db7 f7  : 1003e000000000000f763

f8  : 100059dfff62000000000 f9  : 1003e000000000006c3b5

f10 : 1003e0000000000001212 f11 : 1003e0000000000007e7e

r1  : a000000100c3e560 r2  : e000000004848000 r3  : 0000000000001212

r8  : 0000000000000000 r9  : 0000000000000000 r10 : a000000100a57e48

r11 : 0000000000000040 r12 : e00000003cfd7510 r13 : e00000003cfd0000

r14 : e000000001118000 r15 : 0000000000000040 r16 : e00000003cff8000

r17 : 0000000000001000 r18 : e000000004849000 r19 : 0000000000001000

r20 : e00000003dd99000 r21 : e00000000177af40 r22 : 0000000000000000

r23 : a000000100a7fce8 r24 : 0000000000000000 r25 : e00000003dd98fff

r26 : e00000000177af58 r27 : 0000000000000000 r28 : a0000001005fed20

r29 : e00000003dd98fff r30 : 0000000000000001 r31 : 0000000000000038


Call Trace:

 [<a000000100019600>] show_stack+0x80/0xa0

                                sp=E00000003cfd7070 bsp=E00000003cfd1b10

 [<a00000010003fd10>] die+0x1d0/0x280

                                sp=E00000003cfd7240 bsp=E00000003cfd1ae8

 [<a000000100040ae0>] ia64_fault+0x180/0xcc0

                                sp=E00000003cfd7240 bsp=E00000003cfd1aa8

 [<a000000100012180>] ia64_leave_kernel+0x0/0x260

                                sp=E00000003cfd7340 bsp=E00000003cfd1aa8

 [<a0000001005fed30>] sba_alloc_range+0x50/0x1280

                                sp=E00000003cfd7510 bsp=E00000003cfd1a10

 [<a000000100600f80>] sba_map_sg+0x380/0x740

                                sp=E00000003cfd7510 bsp=E00000003cfd1988

 [<a00000010055b010>] mptscsih_AddSGE+0xf0/0x740

                                sp=E00000003cfd7520 bsp=E00000003cfd1910

 [<a00000010055e9d0>] mptscsih_qcmd+0x630/0xba0

                                sp=E00000003cfd7530 bsp=E00000003cfd18a8

 [<a00000010048f2c0>] scsi_dispatch_cmd+0x480/0x6a0

                                sp=E00000003cfd7530 bsp=E00000003cfd1870

 [<a00000010049d800>] scsi_request_fn+0x5a0/0xac0

                                sp=E00000003cfd7540 bsp=E00000003cfd1750

 [<a0000001003ced00>] __generic_unplug_device+0xc0/0xe0

                                sp=E00000003cfd7540 bsp=E00000003cfd1730

 [<a0000001003ceda0>] generic_unplug_device+0x80/0xe0

                                sp=E00000003cfd7540 bsp=E00000003cfd1710

 [<a0000001003cee90>] blk_backing_dev_unplug+0x90/0xa0

                                sp=E00000003cfd7540 bsp=E00000003cfd16f0

 [<a00000010012a020>] sync_buffer+0x100/0x120

                                sp=E00000003cfd7540 bsp=E00000003cfd16d8

 [<a00000010012a480>] __wait_on_buffer+0x1e0/0x200

                                sp=E00000003cfd7540 bsp=E00000003cfd16b0

 [<a00000010012e230>] __bread_slow+0x150/0x1a0

                                sp=E00000003cfd75a0 bsp=E00000003cfd1690

 [<a00000010012eb00>] __bread+0x60/0x80

                                sp=E00000003cfd75a0 bsp=E00000003cfd1668

 [<a0000001001bb9e0>] ext3_get_branch+0xc0/0x2a0

                                sp=E00000003cfd75a0 bsp=E00000003cfd1620

 [<a0000001001bc8e0>] ext3_get_block_handle+0xc0/0x6a0

                                sp=E00000003cfd75a0 bsp=E00000003cfd1588

 [<a00000010017a390>] do_mpage_readpage+0x650/0x680

                                sp=E00000003cfd7620 bsp=E00000003cfd14e0

 [<a00000010017a4f0>] mpage_readpages+0x130/0x2a0

                                sp=E00000003cfd7780 bsp=E00000003cfd1478

 [<a0000001001bee50>] ext3_readpages+0x30/0x60

                                sp=E00000003cfd7820 bsp=E00000003cfd1448

 [<a0000001000ef460>] read_pages+0x280/0x2a0

                                sp=E00000003cfd7820 bsp=E00000003cfd13d0

 [<a0000001000efab0>] do_page_cache_readahead+0x210/0x440

                                sp=E00000003cfd78b0 bsp=E00000003cfd1350

 [<a0000001000efe40>] page_cache_readahead+0x160/0x520

                                sp=E00000003cfd78c0 bsp=E00000003cfd1300

 [<a0000001000deac0>] do_generic_mapping_read+0x1a0/0x800

                                sp=E00000003cfd78c0 bsp=E00000003cfd1258

 [<a0000001000df730>] __generic_file_aio_read+0x370/0x400

                                sp=E00000003cfd7920 bsp=E00000003cfd11e8

 [<a0000001000df820>] generic_file_aio_read+0x60/0xc0

                                sp=E00000003cfd7940 bsp=E00000003cfd11b8

 [<a000000100127130>] do_sync_read+0x110/0x160

                                sp=E00000003cfd7950 bsp=E00000003cfd1178

 [<a000000100127390>] vfs_read+0x210/0x2c0

                                sp=E00000003cfd79d0 bsp=E00000003cfd1130

 [<a000000100141200>] kernel_read+0x60/0xa0

                                sp=E00000003cfd79d0 bsp=E00000003cfd10f8

 [<a0000001001923f0>] load_script+0x550/0x580

                                sp=E00000003cfd79e0 bsp=E00000003cfd10b8

 [<a0000001001436a0>] search_binary_handler+0x400/0x7a0

                                sp=E00000003cfd7a70 bsp=E00000003cfd1038

 [<a000000100143d80>] do_execve+0x340/0x3e0

                                sp=E00000003cfd7a70 bsp=E00000003cfd0fc8

 [<a00000010001b250>] sys_execve+0x90/0xe0

                                sp=E00000003cfd7c60 bsp=E00000003cfd0f58

 [<a000000100011710>] ia64_execve+0x30/0x160

                                sp=E00000003cfd7c60 bsp=E00000003cfd0f30

 [<a000000100012000>] ia64_ret_from_syscall+0x0/0x20

                                sp=E00000003cfd7c60 bsp=E00000003cfd0f30

 [<a000000100011e20>] execve+0x0/0x20

                                sp=E00000003cfd7e30 bsp=E00000003cfd0f30

 [<a0000001000be7e0>] ____call_usermodehelper+0x160/0x1a0

                                sp=E00000003cfd7e30 bsp=E00000003cfd0f18

 [<a00000010001b5a0>] kernel_thread_helper+0xe0/0x100

                                sp=E00000003cfd7e30 bsp=E00000003cfd0ef0

 [<a000000100009060>] start_kernel_thread+0x20/0x40

                                sp=E00000003cfd7e30 bsp=E00000003cfd0ef0

=20

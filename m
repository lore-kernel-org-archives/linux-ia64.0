From: "Yu, Luming" <luming.yu@intel.com>
Date: Tue, 25 May 2004 12:07:12 +0000
Subject: RE: IA64 test report:USB mouse donesn't work : 2.4.26 /Lion 2004-5-12: 9/10  pass
Message-Id: <3ACA40606221794F80A5670F0AF15F8404737365@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <6E0C289723A0564F9A8279E236E8565F0766858F@pdsmsx402.pd.intel.com>
In-Reply-To: <6E0C289723A0564F9A8279E236E8565F0766858F@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


  After executing kudzu, and removing the PS/2 mouse configuration, the
USB mouse works pretty well.(I'm sorry for I diden't notice this point
beofre.)
So this issue is gone.=20

The interesting thing is that  PS/2 and USB mouse can work together
under  2.6. But 2.4 cannot. =20

Thanks,
Luming

>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org=20
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Wang, Zhenyu Z
>Sent: Thursday, May 13, 2004 4:05 PM
>To: linux-ia64@vger.kernel.org; Brown, Len
>Cc: linux-acpi
>Subject: IA64 test report:USB mouse donesn't work : 2.4.26=20
>/Lion 2004-5-12: 9/10 pass
>
>ACPI Test Report  for 2.4 ia64 kernel + latest ACPI
>	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>	Hardware Configuration:
>	-----------------------
>	System Name: ACPI-LION
>	System Type: 4 way 800M Itanium, Lion
>	M/B revision: N/A
>	Processor version: N/A
>	Firmware Versions: N/A
>	I/O configuration summary:
>		QLogic QLA12160, Seagate ST39205LC boot drive
>		IDE floppy and CDROM
>		Serial console
>		PS/2 keyboard and mouse
>		USB mouse
>		Ethernet Pro 100
>
>	Software Configuration:
>	-----------------------
>		1.Bk pull form lia64.bkbits.net/linux-ia64-2.4 on 4/28
>(Shanghai time)
>		2.Bk pull from
>linux-acpi.bkbits.net/linux-acpi-test-2.4.26 on 4/28 (Shanghai time)
>=09
>	ACPI Features Tested: (prioritized).
>	--------------------
>	1. Boot off SCSI disk			tested ok
>	2. PS/2 keyboard			tested ok
>	3. ATI (run X window system)		tested ok=20
>	4. PS/2 mouse				tested ok
>	5. USB mouse				Doesn't work (Both
>CONFIG_USB_UHCI_ALT and CONFIG_USB_UHCI failed)
>	6. NIC (eg. Ping or ftp)			tested ok
>	7. IDE (eg. r/w floppy or CDROM)		tested ok
>	8. SCI (eg. Press power button)		tested ok
>	9. Soft Power off				tested ok
>	10. serial console			tested ok=20
>
>Linux version 2.4.26 (root@acpi-lion) (gcc version 3.2) #3 SMP Wed May
>12 22:39:29 CST 2004
>EFI v1.02 by INTEL: SALsystab=3D0x5ff26170 ACPI=3D0x5fe963e8 ACPI
>2.0=3D0x5fe96630 MPS=3D0x5ffd0000 SMBIOS=3D0xf00a0
>ACPI: RSDP (v002  INTEL                                    ) @
>0x000000005fe96630
>ACPI: XSDT (v001  INTEL  SR460AC 0x00000003 MSFT 0x0100000a) @
>0x000000005fe96658
>ACPI: FADT (v003  INTEL  SR460AC 0x00000006 MSFT 0x0100000a) @
>0x000000005fe96700
>ACPI: MADT (v001  INTEL  SR460AC 0x0000000a MSFT 0x0100000a) @
>0x000000005fe96838
>ACPI: DSDT (v001  INTEL SR460AC4 0x00000006 MSFT 0x0100000a) @
>0x0000000000000000
>efi.trim_top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
>efi.trim_top: ignoring 448KB of memory at 0x1000 due to granule hole at
>0x0
>efi.trim_top: ignoring 4KB of memory at 0x71000 due to granule hole at
>0x0
>efi.trim_top: ignoring 8KB of memory at 0x72000 due to granule hole at
>0x0
>efi.trim_top: ignoring 100KB of memory at 0x87000 due to=20
>granule hole at
>0x0
>efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule
>hole at 0x0
>SAL v3.00: oem=3DINTEL   MSL     REF     SAL     , product>SAL: entry: pal=
_proc=3D0x5ff48010, sal_proc=3D0x5feb53e0
>SAL: Platform features BusLock IRQ_Redirection=20
>SAL: AP wakeup using external interrupt vector 0xf0
>booting generic kernel on platform dig
>CPU 0: 51 virtual and 44 physical address bits
>iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
>ACPI: Local APIC address 0xc0000000fee00000
>ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0x00] lsapic_eid[0x00] enabled)
>CPU 0 (0x0000) enabled (BSP)
>ACPI: LSAPIC (acpi_id[0x01] lsapic_id[0x03] lsapic_eid[0x00] enabled)
>CPU 1 (0x0300) enabled
>ACPI: LSAPIC (acpi_id[0x02] lsapic_id[0x01] lsapic_eid[0x00] enabled)
>CPU 2 (0x0100) enabled
>ACPI: LSAPIC (acpi_id[0x03] lsapic_id[0x02] lsapic_eid[0x00] enabled)
>CPU 3 (0x0200) enabled
>ACPI: LSAPIC (acpi_id[0x04] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
>CPU 4 (0xaa00) disabled
>ACPI: LSAPIC (acpi_id[0x05] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
>CPU 5 (0xaa00) disabled
>ACPI: LSAPIC (acpi_id[0x06] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
>CPU 6 (0xaa00) disabled
>ACPI: LSAPIC (acpi_id[0x07] lsapic_id[0xaa] lsapic_eid[0x00] disabled)
>CPU 7 (0xaa00) disabled
>ACPI: IOSAPIC (id[0x4] global_irq_base[0x0] address[00000000fec00000])
>  IOSAPIC v2.1, address 0xfec00000, GSIs 0x0-0x3f
>ACPI: PLAT_INT_SRC (low edge type[0x1] id[0x0002] eid[0x0]
>iosapic_vector[0x2] global_irq[0x3d]
>PLATFORM int 0x1: GSI 0x3d(low,edge) -> CPU 0x0200 vector 2
>ACPI: PLAT_INT_SRC (low level type[0x3] id[0x0002] eid[0x0]
>iosapic_vector[0x1e] global_irq[0x3c]
>PLATFORM int 0x3: GSI 0x3c(low,level) -> CPU 0x0200 vector 30
>ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
>register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
>4 CPUs available, 8 CPUs total
>On node 0 totalpages: 96473
>zone(0): 96473 pages.
>zone(1): 0 pages.
>zone(2): 0 pages.
>Building zonelist for node : 0
>Kernel command line: BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinux.24
>root=3D/dev/sda2 console=3DttyS0,9600n8 console=3Dtty0 ro
>FPSWA interface at 0x5fb34010, revision 1.12
>CPU 0: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz
>Console: colour VGA+ 80x25
>Calibrating delay loop... 797.80 BogoMIPS
>Placing software IO TLB between 0xe000000001848000 - 0xe000000001a48000
>Memory: 1533024k/1543568k available (5939k code, 10608k reserved, 2890k
>data, 512k init)
>Dentry cache hash table entries: 131072 (order: 7, 2097152 bytes)
>Inode cache hash table entries: 131072 (order: 7, 2097152 bytes)
>Mount cache hash table entries: 1024 (order: 0, 16384 bytes)
>Buffer cache hash table entries: 131072 (order: 6, 1048576 bytes)
>Page-cache hash table entries: 131072 (order: 6, 1048576 bytes)
>POSIX conformance testing by UNIFIX
>Boot processor id 0x0/0x0
>SMP: starting up secondaries.
>CPU 1: 51 virtual and 44 physical address bits
>CPU 1: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz
>Calibrating delay loop... 797.80 BogoMIPS
>CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
>cycles)
>CPU1: CPU has booted.
>CPU 2: 51 virtual and 44 physical address bits
>CPU 2: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz
>Calibrating delay loop... 797.80 BogoMIPS
>CPU 2: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
>cycles)
>CPU2: CPU has booted.
>CPU 3: 51 virtual and 44 physical address bits
>CPU 3: base freq=133.332MHz, ITC ratio=12/2, ITC freqy9.996MHz
>Calibrating delay loop... 797.80 BogoMIPS
>CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 558
>cycles)
>CPU3: CPU has booted.
>Before bogomips.
>Total of 4 processors activated (3189.20 BogoMIPS).
>Waiting on wait_init_idle (map =3D 0xe)
>All processors have done init_idle
>ACPI: Subsystem revision 20040326
>PCI: Using SAL to access configuration space
> tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully
>acquired
>Parsing all Control
>Methods:.......................................................
>.........
>...............................................................
>.........
>......................................
>Table [DSDT](id F004) - 934 Objects with 101 Devices 174 Methods 19
>Regions
>ACPI Namespace successfully loaded at root e000000004c23718
>evxfevnt-0093 [04] acpi_enable           : Transition to ACPI mode
>successful
>evgpeblk-0867 [06] ev_create_gpe_block   : GPE 00 to 15 [_GPE]=20
>2 regs at
>0000000000000C0C on int 9
>evgpeblk-0925 [06] ev_create_gpe_block   : Found 2 Wake, Enabled 0
>Runtime GPEs in this block
>evgpeblk-0867 [06] ev_create_gpe_block   : GPE 16 to 31 [_GPE]=20
>2 regs at
>0000000000000C16 on int 9
>evgpeblk-0925 [06] ev_create_gpe_block   : Found 0 Wake, Enabled 1
>Runtime GPEs in this block
>Completing Region/Field/Buffer/Package
>initialization:.....................................................
>Initialized 19/19 Regions 0/0 Fields 24/24 Buffers 10/12 Packages (943
>nodes)
>Executing all Device _STA and_INI
>methods:.......................................................
>.........
>..................................
>98 Devices found containing: 98 _STA, 7 _INI methods
>ACPI: Interpreter enabled
>ACPI: Using IOSAPIC for interrupt routing
>ACPI: System [ACPI] (supports S0 S4 S5)
>ACPI: PCI Root Bridge [PCI0] (00:00)
>alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed
>ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
>ACPI: Power Resource [URP1] (off)
>ACPI: Power Resource [URP2] (off)
>ACPI: Power Resource [FDDP] (off)
>ACPI: Power Resource [LPTP] (off)
>ACPI: PCI Root Bridge [PCI1] (00:01)
>ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
>ACPI: PCI Root Bridge [PCI2] (00:04)
>ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
>ACPI: PCI Root Bridge [PCI3] (00:08)
>ACPI: PCI Interrupt Routing Table [\_SB_.PCI3._PRT]
>ACPI: PCI Root Bridge [PCI4] (00:0c)
>ACPI: PCI Interrupt Routing Table [\_SB_.PCI4._PRT]
>ACPI: PCI Root Bridge [PCI5] (00:0f)
>ACPI: PCI Interrupt Routing Table [\_SB_.PCI5._PRT]
>ACPI: PCI Root Bridge [PCI6] (00:12)
>ACPI: PCI Interrupt Routing Table [\_SB_.PCI6._PRT]
>ACPI: PCI Root Bridge [CBN] (00:15)
>PCI->APIC IRQ transform: (00:03.2 INTD) -> CPU 0x0000 vector 48
>PCI: no interrupt route for 00:00:03 pin B
>PCI->APIC IRQ transform: (00:05.0 INTA) -> CPU 0x0000 vector 49
>PCI->APIC IRQ transform: (00:06.0 INTA) -> CPU 0x0000 vector 50
>PCI->APIC IRQ transform: (01:02.0 INTA) -> CPU 0x0000 vector 51
>PCI->APIC IRQ transform: (01:0f.0 INTA) -> CPU 0x0000 vector 52
>PCI->APIC IRQ transform: (04:0f.0 INTA) -> CPU 0x0000 vector 52
>PCI->APIC IRQ transform: (08:0f.0 INTA) -> CPU 0x0000 vector 53
>PCI->APIC IRQ transform: (0c:0f.0 INTA) -> CPU 0x0000 vector 53
>PCI->APIC IRQ transform: (0f:0f.0 INTA) -> CPU 0x0000 vector 54
>PCI->APIC IRQ transform: (12:0f.0 INTA) -> CPU 0x0000 vector 54
>Linux NET4.0 for Linux 2.4
>Based upon Swansea University Computer Society NET3.039
>Initializing RT netlink socket
>PAL Information Facility v0.5
>EFI Variables Facility v0.06 2002-Dec-10
>Total HugeTLB memory allocated, 0
>Starting kswapd
>Journalled Block Device driver loaded
>Hugetlbfs mounted.
>Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
>ACPI: Power Button (FF) [PWRF]
>ACPI: Processor [CPU0] (supports C1)
>ACPI: Processor [CPU1] (supports C1)
>ACPI: Processor [CPU2] (supports C1)
>ACPI: Processor [CPU3] (supports C1)
>pty: 256 Unix98 ptys configured
>Serial driver version 5.05c (2001-07-08) with MANY_PORTS SHARE_IRQ
>DETECT_IRQ SERIAL_PCI SERIAL_ACPI enabled
>ttyS00 at 0x03f8 (irq =3D 44) is a 16550A
>ttyS01 at 0x02f8 (irq =3D 45) is a 16550A
>ttyS00 at port 0x03f8 (irq =3D 44) is a 16550A
>ttyS01 at port 0x02f8 (irq =3D 45) is a 16550A
>EFI Time Services Driver v0.4
>loop: loaded (max 8 devices)
>Intel(R) PRO/1000 Network Driver - version 5.2.30.1-k1
>Copyright (c) 1999-2004 Intel Corporation.
>eepro100.c:v1.09j-t 9/29/99 Donald Becker
>http://www.scyld.com/network/eepro100.html
>eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V.=20
>Savochkin
><saw@saw.sw.com.sg> and others
>PCI: Found IRQ 49 for device 00:05.0
>eth0: Intel Corp. 82557/8/9 [Ethernet Pro 100], 00:D0:B7:F9:F4:F6, IRQ
>49.
>  Board assembly 727095-004, Physical connectors present: RJ45
>  Primary interface chip i82555 PHY #1.
>  General self-test: passed.
>  Serial sub-system self-test: passed.
>  Internal registers self-test: passed.
>  ROM checksum self-test: passed (0x04f4518b).
>Linux agpgart interface v0.99 (c) Jeff Hartmann
>agpgart: Maximum main memory to use for agp memory: 1403M
>agpgart: no supported devices found.
>[drm] Initialized r128 2.2.0 20010917 on minor 0
>[drm] Initialized radeon 1.7.0 20020828 on minor 1
>Uniform Multi-Platform E-IDE driver Revision: 7.00beta4-2.4
>ide: Assuming 33MHz system bus speed for PIO modes; override with
>idebus=3Dxx
>PIIX4: IDE controller at PCI slot 00:03.1
>PCI: Found IRQ 0 for device 00:03.1
>PIIX4: chipset revision 1
>PIIX4: not 100% native mode: will probe irqs later
>    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:pio, hdb:pio
>    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:DMA, hdd:pio
>hda: LS-120 S200 01 UHD Floppy, ATAPI FLOPPY drive
>hdc: CD-224E, ATAPI CD/DVD-ROM drive
>global_restore_flags: 10084a6010 (e000000004ab2490)
>ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
>global_restore_flags: 10084a2010 (e000000004ab2490)
>ide1 at 0x170-0x177,0x376 on irq 33
>hdc: attached ide-cdrom driver.
>hdc: ATAPI 24X CD-ROM drive, 128kB Cache
>Uniform CD-ROM driver Revision: 3.12
>hda: attached ide-floppy driver.
>hda: No disk in drive
>hda: 123264kB, 963/8/32 CHS, 533 kBps, 512 sector size, 720 rpm
>SCSI subsystem driver Revision: 1.00
>PCI: Found IRQ 51 for device 01:02.0
>qla1280: QLA12160 found on PCI bus 1, dev 2
>scsi(0): Reading NVRAM
>scsi(0:0): Resetting SCSI BUS
>scsi(0:1): Resetting SCSI BUS
>PCI: Found IRQ 51 for device 01:02.0
>scsi0 : QLogic QLA12160 PCI to SCSI Host Adapter: bus 1 device 2 irq 51
>       Firmware version: 10.04.32, Driver version 3.23.37
>  Vendor: SEAGATE   Model: ST39205LC         Rev: 5063
>  Type:   Direct-Access                      ANSI SCSI revision: 03
>scsi(0:0:0:0): Sync: period 9, offset 24, Wide, DT, Tagged queuing:
>depth 255
>scsi1 : SCSI host adapter emulation for IDE ATAPI devices
>Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
>SCSI device sda: 17921835 512-byte hdwr sectors (9176 MB)
>Partition check:
> sda: sda1 sda2 sda3
>Fusion MPT base driver 2.05.11.03
>Copyright (c) 1999-2003 LSI Logic Corporation
>mptbase: 0 MPT adapters found, 0 installed.
>Fusion MPT SCSI Host driver 2.05.11.03
>cs4281: version v1.30.64 time 22:37:08 May 12 2004
>cs4281: Unable to locate any cs4281 device with valid IDs 0x1013-0x6005
>usb.c: registered new driver usbdevfs
>usb.c: registered new driver hub
>host/usb-uhci.c: $Revision: 1.275 $ time 22:37:51 May 12 2004
>host/usb-uhci.c: High bandwidth mode enabled
>PCI: Found IRQ 48 for device 00:03.2
>host/usb-uhci.c: USB UHCI at I/O 0x6f80, IRQ 48
>host/usb-uhci.c: Detected 2 ports
>usb.c: new USB bus registered, assigned bus number 1
>hub.c: USB hub found
>hub.c: 2 ports detected
>host/usb-uhci.c: v1.275:USB Universal Host Controller Interface driver
>usb.c: registered new driver hiddev
>usb.c: registered new driver hid
>hid-core.c: v1.8.1 Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>
>hid-core.c: USB HID support drivers
>Linux video capture interface: v1.00
>mice: PS/2 mouse device common for all mice
>NET4: Linux TCP/IP 1.0 for NET4.0
>IP Protocols: ICMP, UDP, TCP
>IP: routing cache hash table of 32768 buckets, 512Kbytes
>TCP: Hash tables configured (established 262144 bind 65536)
>NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
>EXT3-fs: INFO: recovery required on readonly filesystem.
>EXT3-fs: write access will be enabled during recovery.
>hub.c: new USB device 00:03.2-2, assigned address 2
>host/usb-uhci.c: interrupt, status 2, frame# 1236
>input: USB HID v1.00 Mouse [413c:3010] on usb1:2.0
>(recovery.c, 256): journal_recover: JBD: recovery, exit status 0,
>recovered transactions 675565 to 675973
>(recovery.c, 258): journal_recover: JBD: Replayed 2841 and revoked 7/12
>blocks
>kjournald starting.  Commit interval 5 seconds
>EXT3-fs: recovery complete.
>EXT3-fs: mounted filesystem with ordered data mode.
>VFS: Mounted root (ext3 filesystem) readonly.
>Freeing unused kernel memory: 512kB freed
>EXT3 FS 2.4-0.9.19, 19 August 2002 on sd(8,2), internal journal
>Adding Swap: 2040208k swap-space (priority -1)
>ide-floppy: hda: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  0
>usb.c: USB disconnect on device 00:03.2-2 address 2
>ide-floppy: hda: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  0
>hda: No disk in drive
>hub.c: new USB device 00:03.2-1, assigned address 3
>host/usb-uhci.c: interrupt, status 2, frame# 792
>input: USB HID v1.00 Mouse [413c:3010] on usb1:3.0
>ide-floppy: hda: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  0
>ide-floppy: hda: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  0
>hda: No disk in drive
>usb.c: USB disconnect on device 00:03.2-1 address 3
>hub.c: new USB device 00:03.2-2, assigned address 4
>host/usb-uhci.c: interrupt, status 2, frame# 1899
>input: USB HID v1.00 Mouse [413c:3010] on usb1:4.0
>ide-floppy: hda: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  0
>ide-floppy: hda: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  0
>hda: No disk in drive
>ide-floppy: hda: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  0
>ide-floppy: hda: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  0
>hda: No disk in drive
>ide-floppy: hda: I/O error, pc =3D  0, key =3D  2, asc =3D 3a, ascq =3D  0
>ide-floppy: hda: I/O error, pc =3D 1b, key =3D  2, asc =3D 3a, ascq =3D  0
>hda: No disk in drive
>hda: 1440kB, 2880 blocks, 512 sector size
>hda: 1440kB, 80/2/18 CHS, 150 kBps, 512 sector size, 720 rpm
> hda:
> hda:
> hda:
> hda:
> hda:
>
>           CPU0       CPU1       CPU2       CPU3      =20
> 32:       2159          0         12          6   IO-SAPIC-edge
>keyboard
> 33:        988          2         30          6   IO-SAPIC-edge  ide1
> 34:        319         11         13          2   IO-SAPIC-edge  ide0
> 39:          0          0          0          0  IO-SAPIC-level  acpi
> 44:       5431          0         11          0  =20
>IO-SAPIC-edge  serial
> 45:         17          0          0          0  =20
>IO-SAPIC-edge  serial
> 48:         33          0          0          0  IO-SAPIC-level
>usb-uhci
> 49:       2413          9         60         16  IO-SAPIC-level  eth0
> 51:       7216          8        343         65  IO-SAPIC-level
>qla1280
>239:    1350648    1349963    1349429    1340144          LSAPIC  timer
>254:         58         18         55         37          LSAPIC  IPI
>NMI:          0          0          0          0=20
>ERR:          0
>
>00:03.0 ISA bridge: Intel Corp. 82372FB PIIX5 ISA (rev 01)
>	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
>ParErr- Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 0
>
>00:03.1 IDE interface: Intel Corp. 82372FB PIIX5 IDE (rev 01) (prog-if
>80 [Master])
>	Subsystem: Intel Corp.: Unknown device 414c
>	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 64
>	Region 4: I/O ports at 1000 [size=16]
>
>00:03.2 USB Controller: Intel Corp. 82372FB PIIX5 USB (rev 01) (prog-if
>00 [UHCI])
>	Subsystem: Intel Corp.: Unknown device 414c
>	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 64
>	Interrupt: pin D routed to IRQ 48
>	Region 4: I/O ports at 6f80 [size2]
>
>00:03.3 SMBus: Intel Corp. 82372FB PIIX5 SMBus (rev 01)
>	Subsystem: Intel Corp.: Unknown device 414c
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Interrupt: pin B routed to IRQ 0
>	Region 4: I/O ports at c000 [disabled] [size=16]
>
>00:04.0 PIC: Intel Corp. 683053 Programmable Interrupt Device (rev 01)
>(prog-if 20 [IO(X)-APIC])
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 0 (2000ns min, 2000ns max)
>
>00:05.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100]
>(rev 08)
>	Subsystem: Intel Corp. 82559 Fast Ethernet LAN on Motherboard
>	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 64 (2000ns min, 14000ns max), cache line size 10
>	Interrupt: pin A routed to IRQ 49
>	Region 0: Memory at 00000000fafe0000 (32-bit, non-prefetchable)
>[size=3D4K]
>	Region 1: I/O ports at 6f00 [sized]
>	Region 2: Memory at 00000000fae00000 (32-bit, non-prefetchable)
>[size=3D1M]
>	Capabilities: [dc] Power Management version 2
>		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=3D0mA
>PME(D0+,D1+,D2+,D3hot+,D3cold+)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D2 PME-
>
>00:06.0 VGA compatible controller: ATI Technologies Inc Rage=20
>XL (rev 27)
>(prog-if 00 [VGA])
>	Subsystem: Intel Corp.: Unknown device 414c
>	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping+ SERR- FastB2B-
>	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 64 (2000ns min), cache line size 10
>	Interrupt: pin A routed to IRQ 50
>	Region 0: Memory at 00000000fb000000 (32-bit, non-prefetchable)
>[size=16M]
>	Region 1: I/O ports at 6800 [size%6]
>	Region 2: Memory at 00000000faff0000 (32-bit, non-prefetchable)
>[size=3D4K]
>	Expansion ROM at 00000000fafc0000 [disabled] [size=128K]
>	Capabilities: [5c] Power Management version 2
>		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>00:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>01:02.0 SCSI storage controller: QLogic Corp. ISP12160 Dual Channel
>Ultra3 SCSI Processor (rev 06)
>	Subsystem: QLogic Corp.: Unknown device 0007
>	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 64 (16000ns min), cache line size 10
>	Interrupt: pin A routed to IRQ 51
>	Region 0: I/O ports at 8800 [size%6]
>	Region 1: Memory at 00000000f1ff0000 (32-bit, non-prefetchable)
>[size=3D4K]
>	Expansion ROM at 00000000f1fc0000 [disabled] [size=128K]
>	Capabilities: [44] Power Management version 1
>		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>01:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX=20
>Integrated Hot-Plug
>Controller (IHPC) (rev 01)
>	Subsystem: Intel Corp.: Unknown device 012b
>	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Interrupt: pin A routed to IRQ 52
>	Region 0: Memory at 00000000f1fe0000 (32-bit, non-prefetchable)
>[size%6]
>
>04:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX=20
>Integrated Hot-Plug
>Controller (IHPC) (rev 01)
>	Subsystem: Intel Corp.: Unknown device 012b
>	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Interrupt: pin A routed to IRQ 52
>	Region 0: Memory at 00000000e7ff0000 (32-bit, non-prefetchable)
>[size%6]
>
>08:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX=20
>Integrated Hot-Plug
>Controller (IHPC) (rev 01)
>	Subsystem: Intel Corp.: Unknown device 012b
>	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Interrupt: pin A routed to IRQ 53
>	Region 0: Memory at 00000000ddff0000 (32-bit, non-prefetchable)
>[size%6]
>
>0c:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX=20
>Integrated Hot-Plug
>Controller (IHPC) (rev 01)
>	Subsystem: Intel Corp.: Unknown device 012b
>	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Interrupt: pin A routed to IRQ 53
>	Region 0: Memory at 00000000d5ff0000 (32-bit, non-prefetchable)
>[size%6]
>
>0f:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX=20
>Integrated Hot-Plug
>Controller (IHPC) (rev 01)
>	Subsystem: Intel Corp.: Unknown device 012b
>	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Interrupt: pin A routed to IRQ 54
>	Region 0: Memory at 00000000cdff0000 (32-bit, non-prefetchable)
>[size%6]
>
>12:0f.0 PCI Hot-plug controller: Intel Corp. 82466GX=20
>Integrated Hot-Plug
>Controller (IHPC) (rev 01)
>	Subsystem: Intel Corp.: Unknown device 012b
>	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Interrupt: pin A routed to IRQ 54
>	Region 0: Memory at 00000000c5ff0000 (32-bit, non-prefetchable)
>[size%6]
>
>15:00.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:00.1 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:00.2 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:00.3 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:00.4 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:00.5 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:00.6 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:00.7 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.1 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.2 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.3 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.4 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.5 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.6 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:01.7 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:04.0 Host bridge: Intel Corp. 460GX - 84460GX System Data Controller
>(SDC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Data Controller
>(SDC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:10.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:10.1 Host bridge: Intel Corp. 450NX - 82454NX/84460GX PCI Expander
>Bridge (rev 05)
>	Subsystem: Intel Corp. 450NX - 82454NX/84460GX PCI Expander
>Bridge
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort+ >SERR- <PERR-
>	Latency: 128, cache line size 10
>
>15:11.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:12.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:12.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB) (rev 07)
>	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB)
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 32, cache line size 10
>	Capabilities: [90] Power Management version 2
>		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>15:13.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:13.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB) (rev 07)
>	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB)
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort+ >SERR- <PERR-
>	Latency: 32, cache line size 10
>	Capabilities: [90] Power Management version 2
>		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>15:14.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:14.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB) (rev 07)
>	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB)
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 32, cache line size 10
>	Capabilities: [90] Power Management version 2
>		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>15:15.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:15.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB) (rev 07)
>	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB)
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 32, cache line size 10
>	Capabilities: [90] Power Management version 2
>		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>15:16.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:16.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB) (rev 07)
>	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB)
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 32, cache line size 10
>	Capabilities: [90] Power Management version 2
>		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>15:17.0 Host bridge: Intel Corp. 460GX - 84460GX System Address
>Controller (SAC) (rev 03)
>	Subsystem: Intel Corp. 460GX - 84460GX System Address Controller
>(SAC)
>	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
>ParErr- Stepping- SERR- FastB2B-
>	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=FAst >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>
>15:17.1 Host bridge: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB) (rev 07)
>	Subsystem: Intel Corp. 460GX - 82466GX Wide and fast PCI
>eXpander Bridge (WXB)
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR+ FastB2B-
>	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
><TAbort- <MAbort- >SERR- <PERR-
>	Latency: 32, cache line size 10
>	Capabilities: [90] Power Management version 2
>		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>-
>To unsubscribe from this list: send the line "unsubscribe=20
>linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

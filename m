From: Len Brown <lenb@kernel.org>
Date: Thu, 01 Feb 2007 06:55:01 +0000
Subject: Re: 2.6.20-rc6-mm[2-3] ACPI issues
Message-Id: <200702010155.02119.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070131202532.GS30233@localhost>
In-Reply-To: <20070131202532.GS30233@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bob Picco <bob.picco@hp.com>
Cc: akpm@osdl.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wednesday 31 January 2007 15:25, Bob Picco wrote:
> Hi Len,
>=20
> On 2.6.20-rc6-mm2 my rx2600 wouldn't boot unless I reverted all changes
> to drivers/acpi/tables.c.

2.6.20-rc6-mm2 git-acpi.patch contained only the acpi_table_parse()
fix for bugzilla-7465.  The version of the patch that made -mm2 had a flaw
where if the HPET were not connfigured, it would BUG_ON() due to a NULL
handler it didn't expect -- and this generally happened before VGA was enab=
led.
That bug got fixed, and also bugzilla-7465 is not in -mm3 -- which explains
why it went away.

> Nearly all major early boot detected ACPI tables=20
> weren't discovered.

That part I can't explain.

> I never had time to resolve because 2.6.20-rc6-mm3=20
> showed up. The -mm2 problem appears corrected but the machine now crashes=
 in
> acpi_init for -mm3. 2.6.20-rc6 and 2.6.20-rc6-mm3 boot logs are included
> at end of email.
>=20
> For 2.6.20-rc6-mm3 the HP internal simualtor for a NUMA machine is
> getting a preposterous pxm value and subsequently MCAs in pxm_to_node
> because of large pxm. It seems like table parsing is being done
> incorrectly.
>=20
> Nope this is the issue:
>=20
> Index: linux-2.6.20-rc6-mm3/include/acpi/actbl1.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.20-rc6-mm3.orig/include/acpi/act=
bl1.h	2007-01-30 09:27:44.000000000 -0500
> +++ linux-2.6.20-rc6-mm3/include/acpi/actbl1.h	2007-01-31 14:41:32.000000=
000 -0500
> @@ -654,8 +654,8 @@ struct acpi_srat_cpu_affinity {
> =20
>  struct acpi_srat_mem_affinity {
>  	struct acpi_subtable_header header;
> -	u32 proximity_domain;
> -	u16 reserved;		/* Reserved, must be zero */
> +	u8  proximity_domain;
> +	u8  reserved[5];		/* Reserved, must be zero */
>  	u64 base_address;
>  	u64 length;
>  	u32 memory_type;	/* See acpi_address_range_id */
> Index: linux-2.6.20-rc6-mm3/arch/ia64/kernel/acpi.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.20-rc6-mm3.orig/arch/ia64/kernel=
/acpi.c	2007-01-30 13:55:08.000000000 -0500
> +++ linux-2.6.20-rc6-mm3/arch/ia64/kernel/acpi.c	2007-01-31 14:49:26.0000=
00000 -0500
> @@ -423,7 +423,7 @@ int get_memory_proximity_domain(struct a
> =20
>  	pxm =3D ma->proximity_domain;
>  	if (ia64_platform_is("sn2"))
> -		pxm +=3D ma->reserved << 8;
> +		pxm +=3D ma->reserved[0] << 8;
> =20
>  	return pxm;
>  }
>=20
> I doubt you'll want to apply this patch. It appears HP firmware has some
> of the reserved field not initialized to zero. This results in the huge
> pxm. Was the pxm size expanded with a recent ACPI spec revision?=20

Yep.
The original code was programmed to the Microsoft SRAT spec -- which
identifies itself as version 1.  The new code is talking to ACPI 3.0 SRAT s=
pec
which identifies itself as version 2.

In the SRAT memory affinity structure, the difference is that the proximity=
_domain
is now 4-bytes instead of 1.

We need to be checking for the SRAT revision and handling both revisions.

Might be safer to build w/o NUMA until we get the SRAT fixed.

> Well with this patch I can pursue the acpi_init panic on simulator.
>=20
> rx2600 (2 CPU MP) and NUMA simulator (1 node and 4 cpus)  boot successful=
ly
> on 2.6.20-rc6.
>=20
> bob
>=20
>=20
> Linux version 2.6.20-rc6 (root@localhost) (gcc version 3.4.1) #1 SMP Mon =
Jan 29 14:40:17 EST 2007
> EFI v1.10 by HP: SALsystab=3D0x3fb38000 ACPI 2.0=3D0x3fb2e000 SMBIOS=3D0x=
3fb3a000 HCDP=3D0x3fb2c000
> PCDP: v0 at 0x3fb2c000
> Early serial console at MMIO 0xf8030000 (options '9600n8')
> ACPI: RSDP (v002     HP                                ) @ 0x000000003fb2=
e000
> ACPI: XSDT (v001     HP   rx2600 0x00000000 HP 0x00000000) @ 0x000000003f=
b2e02c
> ACPI: FADT (v003     HP   rx2600 0x00000000 HP 0x00000000) @ 0x000000003f=
b369e0
> ACPI: SPCR (v001     HP   rx2600 0x00000000 HP 0x00000000) @ 0x000000003f=
b36b18
> ACPI: DBGP (v001     HP   rx2600 0x00000000 HP 0x00000000) @ 0x000000003f=
b36b68
> ACPI: MADT (v001     HP   rx2600 0x00000000 HP 0x00000000) @ 0x000000003f=
b36c28
> ACPI: SPMI (v004     HP   rx2600 0x00000000 HP 0x00000000) @ 0x000000003f=
b36ba0
> ACPI: CPEP (v001     HP   rx2600 0x00000000 HP 0x00000000) @ 0x000000003f=
b36bf0
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb33870
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb33a50
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb33da0
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb347c0
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb351e0
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb35c00
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb36620
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb36800
> ACPI: SSDT (v001     HP   rx2600 0x00000006 INTL 0x02012044) @ 0x00000000=
3fb368f0
> ACPI: DSDT (v001     HP   rx2600 0x00000007 INTL 0x02012044) @ 0x00000000=
00000000
> SAL 3.1: HP version 2.21
> SAL Platform features: None
> SAL: AP wakeup using external interrupt vector 0xff
> No logical to physical processor mapping available
> ACPI: Local APIC address c0000000fee00000
> GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
> 2 CPUs available, 2 CPUs total
> MCA related initialization done
> Entering add_active_range(0, 1025, 4096) 0 entries of 12800 used
> Entering add_active_range(0, 4825, 64889) 1 entries of 12800 used
> Entering add_active_range(0, 65216, 65227) 2 entries of 12800 used
> Entering add_active_range(0, 16842752, 17038305) 3 entries of 12800 used
> Entering add_active_range(0, 17038307, 17038312) 4 entries of 12800 used
> Entering add_active_range(0, 17038313, 17039193) 5 entries of 12800 used
> Entering add_active_range(0, 17039209, 17039236) 6 entries of 12800 used
> Entering add_active_range(0, 17039264, 17039343) 7 entries of 12800 used
> Zone PFN ranges:
>   DMA          1025 ->   262144
>   Normal     262144 -> 17039360
> early_node_map[8] active PFN ranges
>     0:     1025 ->     4096
>     0:     4825 ->    64889
>     0:    65216 ->    65227
>     0: 16842752 -> 17038305
>     0: 17038307 -> 17038312
>     0: 17038313 -> 17039193
>     0: 17039209 -> 17039236
>     0: 17039264 -> 17039343
> On node 0 totalpages: 259690
>   DMA zone: 892 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 62254 pages, LIFO batch:7
>   Normal zone: 57343 pages used for memmap
>   Normal zone: 139201 pages, LIFO batch:7
> Built 1 zonelists.  Total pages: 201455
> Kernel command line: BOOT_IMAGE=3Dscsi0:/EFI/debian/boot/vmlinux-2.6.20-r=
c6 root=3D/dev/sda3 installtype=DEbianInstall raid=3Dnoautodetect console=
=3Dhcdp devfs=3Dnomount nohalt kgdb8250=3Dmmio,0x0000000ff5e2000,115200,51 =
 debug loglevel=3D9 ro
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> CPU 0: base freq 0.000MHz, ITC ratio=10/2, ITC freq=1000.000MHz+/-500ppm
> Console: colour VGA+ 80x25
> Memory: 4137744k/4155040k available (8022k code, 29008k reserved, 3225k d=
ata, 720k init)
> Leaving McKinley Errata 9 workaround enabled
> Calibrating delay loop... 1499.13 BogoMIPS (lpj)98272)
> Dentry cache hash table entries: 524288 (order: 8, 4194304 bytes)
> Inode-cache hash table entries: 262144 (order: 7, 2097152 bytes)
> Mount-cache hash table entries: 1024
> ACPI: Core revision 20060707
> Boot processor id 0x0/0x0
> CPU 1: synchronized ITC with CPU 0 (last diff -4 cycles, maxerr 454 cycle=
s)
> CPU 1: base freq 0.000MHz, ITC ratio=10/2, ITC freq=1000.000MHz+/-500ppm
> Calibrating delay loop... 1499.13 BogoMIPS (lpj)98272)
> Brought up 2 CPUs
> Total of 2 processors activated (2998.27 BogoMIPS).
> migration_cost270
> DMI 2.3 present.
> NET: Registered protocol family 16
> ACPI: bus type pci registered
> ACPI: Interpreter enabled
> ACPI: Using IOSAPIC for interrupt routing
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> PCI: Firmware left 0000:00:03.0 e100 interrupts enabled, disabling
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI0._PRT]
> ACPI: PCI Root Bridge [PCI1] (0000:20)
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI1._PRT]
> ACPI: PCI Root Bridge [PCI2] (0000:40)
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI2._PRT]
> ACPI: PCI Root Bridge [PCI3] (0000:60)
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI3._PRT]
> ACPI: PCI Root Bridge [PCI4] (0000:80)
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI4._PRT]
> ACPI: PCI Root Bridge [PCI6] (0000:c0)
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI6._PRT]
> ACPI: PCI Root Bridge [PCI7] (0000:e0)
> Boot video device is 0000:e0:02.0
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI7._PRT]
> Linux Plug and Play Support v0.97 (c) Adam Belay
> pnp: PnP ACPI init
> GSI 34 (edge, high) -> CPU 1 (0x0100) vector 49
> GSI 35 (edge, high) -> CPU 0 (0x0000) vector 50
> pnp: PnP ACPI: found 11 devices
> SCSI subsystem initialized
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
> NET: Registered protocol family 2
> IP route cache hash table entries: 131072 (order: 6, 1048576 bytes)
> TCP established hash table entries: 524288 (order: 9, 8388608 bytes)
> TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
> TCP: Hash tables configured (established 524288 bind 65536)
> TCP reno registered
> perfmon: version 2.0 IRQ 238
> perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
> PAL Information Facility v0.5
> perfmon: added sampling format default_format
> perfmon_default_smpl: default_format v2.0 registered
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> io scheduler noop registered
> io scheduler anticipatory registered (default)
> io scheduler deadline registered
> io scheduler cfq registered
> GSI 83 (level, low) -> CPU 1 (0x0100) vector 51
> ACPI: PCI Interrupt 0000:e0:02.0[A] -> GSI 83 (level, low) -> IRQ 51
> radeonfb: Found Intel x86 BIOS ROM Image
> radeonfb: Retrieved PLL infos from BIOS
> radeonfb: Reference'.00 MHz (RefDiv`) Memory=166.00 Mhz, System=166.00 MHz
> radeonfb: PLL min 12000 max 35000
> i2c_adapter i2c-1: unable to read EDID block.
> i2c_adapter i2c-1: unable to read EDID block.
> i2c_adapter i2c-1: unable to read EDID block.
> i2c_adapter i2c-3: unable to read EDID block.
> i2c_adapter i2c-3: unable to read EDID block.
> i2c_adapter i2c-3: unable to read EDID block.
> i2c_adapter i2c-2: unable to read EDID block.
> i2c_adapter i2c-2: unable to read EDID block.
> i2c_adapter i2c-2: unable to read EDID block.
> i2c_adapter i2c-3: unable to read EDID block.
> i2c_adapter i2c-3: unable to read EDID block.
> i2c_adapter i2c-3: unable to read EDID block.
> radeonfb: Monitor 1 type CRT found
> radeonfb: Monitor 2 type no found
> Console: switching to colour frame buffer device 80x30
> radeonfb (0000:e0:02.0): ATI Radeon QY=20
> input: Power Button (FF) as /class/input/input0
> ACPI: Power Button (FF) [PWRF]
> input: Sleep Button (FF) as /class/input/input1
> ACPI: Sleep Button (FF) [SLPF]
> ACPI: Thermal Zone [THM0] (27 C)
> EFI Time Services Driver v0.4
> Linux agpgart interface v0.101 (c) Dave Jones
> [drm] Initialized drm 1.1.0 20060810
> [drm] Initialized radeon 1.25.0 20060524 on minor 0
> Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
> 00:04: ttyS0 at MMIO 0xff5e0000 (irq =3D 49) is a 16550A
> 00:05: ttyS1 at MMIO 0xff5e2000 (irq =3D 50) is a 16550A
> GSI 82 (level, low) -> CPU 0 (0x0000) vector 52
> ACPI: PCI Interrupt 0000:e0:01.0[A] -> GSI 82 (level, low) -> IRQ 52
> 0000:e0:01.0: ttyS2 at MMIO 0xf8031000 (irq =3D 52) is a 16550A
> ACPI: PCI Interrupt 0000:e0:01.1[A] -> GSI 82 (level, low) -> IRQ 52
> 0000:e0:01.1: ttyS3 at MMIO 0xf8030000 (irq =3D 52) is a 16550A
> Couldn't register serial port 0000:e0:01.1: -28
> RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
> loop: loaded (max 8 devices)
> Intel(R) PRO/1000 Network Driver - version 7.3.15-k2
> Copyright (c) 1999-2006 Intel Corporation.
> Ethernet Channel Bonding Driver: v3.1.1 (September 26, 2006)
> bonding: Warning: either miimon or arp_interval and arp_ip_target module =
parameters must be specified, otherwise bonding will not detect link failur=
es! see bonding.txt for details.
> eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/ee=
pro100.html
> eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin =
<saw@saw.sw.com.sg> and others
> GSI 20 (level, low) -> CPU 1 (0x0100) vector 53
> ACPI: PCI Interrupt 0000:00:03.0[A] -> GSI 20 (level, low) -> IRQ 53
> eth0: OEM i82557/i82558 10/100 Ethernet, 00:30:6E:4A:53:34, IRQ 53.
>   Board assembly 000000-000, Physical connectors present: RJ45
>   Primary interface chip i82555 PHY #1.
>     Secondary interface chip i82555.
>   General self-test: passed.
>   Serial sub-system self-test: passed.
>   Internal registers self-test: passed.
>   ROM checksum self-test: passed (0xb874c1d3).
> tg3.c:v3.72 (January 8, 2007)
> GSI 29 (level, low) -> CPU 0 (0x0000) vector 54
> ACPI: PCI Interrupt 0000:20:02.0[A] -> GSI 29 (level, low) -> IRQ 54
> eth1: Tigon3 [partno(BCM95700A6) rev 0105 PHY(5701)] (PCI:66MHz:64-bit) 1=
0/100/1000Base-T Ethernet 00:30:6e:4a:52:9a
> eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOc=
ap[0]=20
> eth1: dma_rwctrl[76ff2d0f] dma_mask[64-bit]
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=
=3Dxx
> CMD649: IDE controller at PCI slot 0000:00:02.0
> GSI 21 (level, low) -> CPU 1 (0x0100) vector 55
> ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 21 (level, low) -> IRQ 55
> CMD649: chipset revision 2
> CMD649: 100% native mode on irq 55
>     ide0: BM-DMA at 0x0d40-0x0d47, BIOS settings: hda:pio, hdb:pio
>     ide1: BM-DMA at 0x0d48-0x0d4f, BIOS settings: hdc:pio, hdd:pio
> Probing IDE interface ide0...
> hda: DW-224E, ATAPI CD/DVD-ROM drive
> ide0 at 0xd58-0xd5f,0xd66 on irq 55
> Probing IDE interface ide1...
> hda: ATAPI 24X DVD-ROM CD-R/RW drive, 1658kB Cache, UDMA(33)
> Uniform CD-ROM driver Revision: 3.20
> ide-floppy driver 0.99.newide
> st: Version 20061107, fixed bufsize 32768, s/g segs 256
> osst :I: Tape driver with OnStream support version 0.99.4
> osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
> Fusion MPT base driver 3.04.03
> Copyright (c) 1999-2007 LSI Logic Corporation
> Fusion MPT SPI Host driver 3.04.03
> GSI 27 (level, low) -> CPU 0 (0x0000) vector 56
> ACPI: PCI Interrupt 0000:20:01.0[A] -> GSI 27 (level, low) -> IRQ 56
> mptbase: Initiating ioc0 bringup
> ioc0: 53C1030: Capabilities=3D{Initiator}
> scsi0 : ioc0: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQV
> scsi 0:0:0:0: Direct-Access     HP 36.4G ST336753LC       HPC3 PQ: 0 ANSI=
: 3
>  target0:0:0: Beginning Domain Validation
>  target0:0:0: Ending Domain Validation
>  target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6=
.25 ns, offset 63)
> SCSI device sda: 71132960 512-byte hdwr sectors (36420 MB)
> sda: Write Protect is off
> sda: Mode Sense: d3 00 10 08
> SCSI device sda: write cache: disabled, read cache: enabled, supports DPO=
 and FUA
> SCSI device sda: 71132960 512-byte hdwr sectors (36420 MB)
> sda: Write Protect is off
> sda: Mode Sense: d3 00 10 08
> SCSI device sda: write cache: disabled, read cache: enabled, supports DPO=
 and FUA
>  sda: sda1 sda2 sda3
> sd 0:0:0:0: Attached scsi disk sda
> sd 0:0:0:0: Attached scsi generic sg0 type 0
> scsi 0:0:1:0: Direct-Access     HP 36.4G ST336753LC       HPC3 PQ: 0 ANSI=
: 3
>  target0:0:1: Beginning Domain Validation
>  target0:0:1: Ending Domain Validation
>  target0:0:1: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6=
.25 ns, offset 63)
> SCSI device sdb: 71132960 512-byte hdwr sectors (36420 MB)
> sdb: Write Protect is off
> sdb: Mode Sense: d3 00 10 08
> SCSI device sdb: write cache: disabled, read cache: enabled, supports DPO=
 and FUA
> SCSI device sdb: 71132960 512-byte hdwr sectors (36420 MB)
> sdb: Write Protect is off
> sdb: Mode Sense: d3 00 10 08
> SCSI device sdb: write cache: disabled, read cache: enabled, supports DPO=
 and FUA
>  sdb: sdb1 sdb2 sdb3
> sd 0:0:1:0: Attached scsi disk sdb
> sd 0:0:1:0: Attached scsi generic sg1 type 0
> GSI 28 (level, low) -> CPU 1 (0x0100) vector 57
> ACPI: PCI Interrupt 0000:20:01.1[B] -> GSI 28 (level, low) -> IRQ 57
> mptbase: Initiating ioc1 bringup
> ioc1: 53C1030: Capabilities=3D{Initiator}
> scsi1 : ioc1: LSI53C1030, FwRev=01030600h, Ports=3D1, MaxQ%5, IRQW
> GSI 18 (level, low) -> CPU 0 (0x0000) vector 58
> ACPI: PCI Interrupt 0000:00:01.2[C] -> GSI 18 (level, low) -> IRQ 58
> ehci_hcd 0000:00:01.2: EHCI Host Controller
> ehci_hcd 0000:00:01.2: new USB bus registered, assigned bus number 1
> ehci_hcd 0000:00:01.2: irq 58, io mem 0x80021000
> ehci_hcd 0000:00:01.2: USB 2.0 started, EHCI 0.95, driver 10 Dec 2004
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 5 ports detected
> ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver (PC=
I)
> GSI 16 (level, low) -> CPU 1 (0x0100) vector 59
> ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 59
> ohci_hcd 0000:00:01.0: OHCI Host Controller
> ohci_hcd 0000:00:01.0: new USB bus registered, assigned bus number 2
> ohci_hcd 0000:00:01.0: irq 59, io mem 0x80023000
> usb usb2: configuration #1 chosen from 1 choice
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 3 ports detected
> GSI 17 (level, low) -> CPU 0 (0x0000) vector 60
> ACPI: PCI Interrupt 0000:00:01.1[B] -> GSI 17 (level, low) -> IRQ 60
> ohci_hcd 0000:00:01.1: OHCI Host Controller
> ohci_hcd 0000:00:01.1: new USB bus registered, assigned bus number 3
> ohci_hcd 0000:00:01.1: irq 60, io mem 0x80022000
> usb usb3: configuration #1 chosen from 1 choice
> hub 3-0:1.0: USB hub found
> hub 3-0:1.0: 2 ports detected
> USB Universal Host Controller Interface driver v3.0
> usbcore: registered new interface driver hiddev
> usbcore: registered new interface driver usbhid
> drivers/usb/input/hid-core.c: v2.6:USB HID core driver
> mice: PS/2 mouse device common for all mice
> md: linear personality registered for level -1
> md: raid0 personality registered for level 0
> md: raid1 personality registered for level 1
> md: multipath personality registered for level -4
> device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@red=
hat.com
> EFI Variables Facility v0.08 2004-May-17
> TCP cubic registered
> NET: Registered protocol family 1
> NET: Registered protocol family 17
> Adding console on ttyS3 at MMIO 0xf8030000 (options '9600n8')
> md: Skipping autodetection of RAID arrays. (raid=3Dnoautodetect)
> kjournald starting.  Commit interval 5 seconds
> EXT3-fs: mounted filesystem with ordered data mode.
> VFS: Mounted root (ext3 filesystem) readonly.
> Freeing unused kernel memory: 720kB freed
> EXT3 FS on sda3, internal journal
> Adding 971744k swap on /dev/sda2.  Priority:-1 extents:1 across:971744k
>=20
>=20
> Linux version 2.6.20-rc6-mm3 (root@localhost) (gcc version 3.4.1) #2 SMP =
Tue Jan 30 09:51:25 EST 2007
> EFI v1.10 by HP: SALsystab=3D0x3fb38000 ACPI 2.0=3D0x3fb2e000 SMBIOS=3D0x=
3fb3a000 HCDP=3D0x3fb2c000
> PCDP: v0 at 0x3fb2c000
> Early serial console at MMIO 0xf8030000 (options '9600n8')
> ACPI: RSDP @ 0x000000003fb2e000/0x0028 (v002     HP)
> ACPI: XSDT @ 0x000000003fb2e02c/0x009C (v001     HP   rx2600 0x00000000  =
 HP 0x00000000)
> ACPI: FACP @ 0x000000003fb369e0/0x00F4 (v003     HP   rx2600 0x00000000  =
 HP 0x00000000)
> ACPI: DSDT @ 0x000000003fb2e0e0/0x5781 (v001     HP   rx2600 0x00000007 I=
NTL 0x02012044)
> ACPI: FACS @ 0x000000003fb36ad8/0x0040
> ACPI: SPCR @ 0x000000003fb36b18/0x0050 (v001     HP   rx2600 0x00000000  =
 HP 0x00000000)
> ACPI: DBGP @ 0x000000003fb36b68/0x0034 (v001     HP   rx2600 0x00000000  =
 HP 0x00000000)
> ACPI: APIC @ 0x000000003fb36c28/0x00C0 (v001     HP   rx2600 0x00000000  =
 HP 0x00000000)
> ACPI: SPMI @ 0x000000003fb36ba0/0x0050 (v004     HP   rx2600 0x00000000  =
 HP 0x00000000)
> ACPI: CPEP @ 0x000000003fb36bf0/0x0034 (v001     HP   rx2600 0x00000000  =
 HP 0x00000000)
> ACPI: SSDT @ 0x000000003fb33870/0x01D6 (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb33a50/0x0342 (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb33da0/0x0A16 (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb347c0/0x0A16 (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb351e0/0x0A16 (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb35c00/0x0A16 (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb36620/0x01D8 (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb36800/0x00EB (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> ACPI: SSDT @ 0x000000003fb368f0/0x00EF (v001     HP   rx2600 0x00000006 I=
NTL 0x02012044)
> SAL 3.1: HP version 2.21
> SAL Platform features: None
> SAL: AP wakeup using external interrupt vector 0xff
> No logical to physical processor mapping available
> ACPI: Local APIC address c0000000fee00000
> GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
> 2 CPUs available, 2 CPUs total
> MCA related initialization done
> Zone PFN ranges:
>   DMA          1024 ->   262144
>   Normal     262144 -> 17039360
> early_node_map[5] active PFN ranges
>     0:     1024 ->    64889
>     0:    65216 ->    65227
>     0: 16842752 -> 17039193
>     0: 17039209 -> 17039236
>     0: 17039264 -> 17039343
> Built 1 zonelists.  Total pages: 202188
> Kernel command line: BOOT_IMAGE=3Dscsi0:/EFI/debian/boot/vmlinux-2.6.20-r=
c6-mm3 root=3D/dev/sda3 installtype=DEbianInstall raid=3Dnoautodetect conso=
le=3Dhcdp devfs=3Dnomount nohalt kgdb8250=3Dmmio,0x0000000ff5e2000,115200,5=
1  debug loglevel=3D9 ro
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> CPU 0: base freq 0.000MHz, ITC ratio=10/2, ITC freq=1000.000MHz+/-500ppm
> Console: colour VGA+ 80x25
> Memory: 4137488k/4154784k available (8153k code, 29280k reserved, 3330k d=
ata, 736k init)
> Leaving McKinley Errata 9 workaround enabled
> Calibrating delay loop... 1499.13 BogoMIPS (lpj)98272)
> Dentry cache hash table entries: 524288 (order: 8, 4194304 bytes)
> Inode-cache hash table entries: 262144 (order: 7, 2097152 bytes)
> Mount-cache hash table entries: 1024
> ACPI: Core revision 20070126
> Boot processor id 0x0/0x0
> CPU 1: synchronized ITC with CPU 0 (last diff -19 cycles, maxerr 464 cycl=
es)
> CPU 1: base freq 0.000MHz, ITC ratio=10/2, ITC freq=1000.000MHz+/-500ppm
> Calibrating delay loop... 1499.13 BogoMIPS (lpj)98272)
> Brought up 2 CPUs
> Total of 2 processors activated (2998.27 BogoMIPS).
> migration_cost267
> DMI 2.3 present.
> NET: Registered protocol family 16
> ACPI: bus type pci registered
> Unable to handle kernel paging request at virtual address 00000000005c100a
> swapper[1]: Oops 8813272891392 [1]
>=20
> Pid: 1, CPU 0, comm:              swapper
> psr : 00001010085a2010 ifs : 8000000000000309 ip  : [<a0000001003b2980>] =
   Not tainted
> ip is at acpi_os_read_port+0x1a0/0x2e0
> unat: 0000000000000000 pfs : 000000000000030a rsc : 0000000000000003
> rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000011961
> ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a74433f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : a0000001003d5090 b6  : a0000001003d5250 b7  : a00000010000a880
> f6  : 1003e0000000000000000 f7  : 1003e20c49ba5e353f7cf
> f8  : 1003e0000000000000000 f9  : 1003e0000000000000338
> f10 : 1003e0000000000000c48 f11 : 1003e431bde82d7b634db
> r1  : a000000100d18ac0 r2  : e0000040fedbfdb7 r3  : e0000040fedbfdb6
> r8  : e0000040fedbfdb5 r9  : e0000040fedbfdb4 r10 : e0000040fedbfdb3
> r11 : e0000040fedbfdb2 r12 : e0000040fedbfd90 r13 : e0000040fedb8000
> r14 : e0000040fedbfda0 r15 : 00000000005c100a r16 : 0000000000000000
> r17 : 000000000000005c r18 : 00000000000000ff r19 : 0000000000000000
> r20 : 0000000000000000 r21 : a000000100b7aef4 r22 : 00000000005c100a
> r23 : 0000000000000000 r24 : a000000100b3c0b0 r25 : 00000000005c100a
> r26 : 0000000000000000 r27 : a000000100b3c0b8 r28 : 0000000000ffffff
> r29 : a000000100b3b0c0 r30 : 00000000000000ff r31 : a000000100b3b0c0
>=20
> Call Trace:
>  [<a000000100010470>] show_stack+0x50/0xa0
>                                 sp=E0000040fedbf940 bsp=E0000040fedb8e80
>  [<a000000100010d30>] show_regs+0x810/0x840
>                                 sp=E0000040fedbfb10 bsp=E0000040fedb8e38
>  [<a000000100032d10>] die+0x1d0/0x2c0
>                                 sp=E0000040fedbfb10 bsp=E0000040fedb8de8
>  [<a000000100051360>] ia64_do_page_fault+0x840/0x940
>                                 sp=E0000040fedbfb30 bsp=E0000040fedb8d88
>  [<a00000010000b060>] ia64_leave_kernel+0x0/0x280
>                                 sp=E0000040fedbfbc0 bsp=E0000040fedb8d88
>  [<a0000001003b2980>] acpi_os_read_port+0x1a0/0x2e0
>                                 sp=E0000040fedbfd90 bsp=E0000040fedb8d40
>  [<a0000001003d5090>] acpi_hw_low_level_read+0x190/0x200
>                                 sp=E0000040fedbfda0 bsp=E0000040fedb8d10
>  [<a0000001003d5270>] acpi_hw_register_read+0x170/0x400
>                                 sp=E0000040fedbfdb0 bsp=E0000040fedb8cc8
>  [<a0000001003d5d40>] acpi_set_register+0xc0/0x340
>                                 sp=E0000040fedbfdc0 bsp=E0000040fedb8c90
>  [<a0000001003be900>] acpi_ev_initialize_events+0x80/0x180
>                                 sp=E0000040fedbfdd0 bsp=E0000040fedb8c68
>  [<a0000001003ecfb0>] acpi_enable_subsystem+0xf0/0x180
>                                 sp=E0000040fedbfdd0 bsp=E0000040fedb8c38
>  [<a0000001009bdbc0>] acpi_init+0x80/0x460
>                                 sp=E0000040fedbfdd0 bsp=E0000040fedb8c10
>  [<a00000010098d520>] init+0x400/0x660
>                                 sp=E0000040fedbfe00 bsp=E0000040fedb8bc8
>  [<a000000100012450>] kernel_thread_helper+0x30/0x60
>                                 sp=E0000040fedbfe30 bsp=E0000040fedb8ba0
>  [<a000000100008d40>] start_kernel_thread+0x20/0x40
>                                 sp=E0000040fedbfe30 bsp=E0000040fedb8ba0
> Kernel panic - not syncing: Attempted to kill init!
>=20

Hmm, we seem to have touched a register that isn't there.

Assuming building w/o NUMA doesn't somehow magically fix this...
build with CONFIG_ACPI_DEBUG=3Dy and boot with acpi_dbg_level=3D0xffffffff
and acpi_dbg_layer=3D0x2 and that should tell us everything about ACPICA's
attempt to talk to hardware registers.

thanks,
-Len

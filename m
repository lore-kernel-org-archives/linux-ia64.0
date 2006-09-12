From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 12 Sep 2006 16:10:02 +0000
Subject: Re: Does 2.6.17.11 kernel work on HP zx6000?
Message-Id: <200609121010.02568.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060908232224.GA27087@lucon.org>
In-Reply-To: <20060908232224.GA27087@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Friday 08 September 2006 17:22, H. J. Lu wrote:
> Does 2.6.17.11 kernel work on HP zx6000? After uncompressing
> kernel and loading initrd, kernel stops.

2.6.17.11 has an ia64 build problem.  After I fixed that with
this patch:
  http://www.gelato.unsw.edu.au/archives/linux-ia64/0608/18861.html

I built a defconfig kernel and booted it on an rx2600 (basically
the same box as a zx6000).  The log is below.

My guess is that there's something wrong with your console.  Maybe
the kernel thinks you have a VGA console and you're looking at
serial, or vice versa.  EFI can use multiple console devices, but
the kernel generally only uses one.


Linux version 2.6.17.11 (helgaas@tiger) (gcc version 4.0.3 (Debian 4.0.3-1)=
) #1 SMP Tue Sep 12 09:23:48 MDT 2006
EFI v1.10 by HP: SALsystab=3D0x3fb38000 ACPI 2.0=3D0x3fb2e000 SMBIOS=3D0x3f=
b3a000 HCDP=3D0x3fb2c000
booting generic kernel on platform hpzx1
PCDP: v0 at 0x3fb2c000
Explicit "console=3D"; ignoring PCDP
Early serial console at MMIO 0xff5e0000 (options '115200')
SAL 3.1: HP version 2.31
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
No logical to physical processor mapping available
ACPI: Local APIC address c0000000fee00000
GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
2 CPUs available, 2 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffc7200000
SMP: Allowing 2 CPUs, 0 hotplug CPUs
Built 1 zonelists
Kernel command line: BOOT_IMAGE=3Dnet0:/helgaas/ia64/vmlinux.gz root=3D/dev=
/sda2 console=3Duart,mmio,0xff5e0000 debug ro
PID hash table entries: 4096 (order: 12, 32768 bytes)
CPU 0: base freq 0.000MHz, ITC ratio=3D9/2, ITC freq=900.000MHz+/-450ppm
Console: colour VGA+ 80x25
Memory: 4073600k/4154400k available (6992k code, 93184k reserved, 3331k dat=
a, 384k init)
Leaving McKinley Errata 9 workaround enabled
Calibrating delay loop... 1347.58 BogoMIPS (lpj&95168)
Dentry cache hash table entries: 524288 (order: 8, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 7, 2097152 bytes)
Mount-cache hash table entries: 1024
Boot processor id 0x0/0x0
Fixed BSP b0 value from CPU 1
CPU 1: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 431 cycles)
CPU 1: base freq 0.000MHz, ITC ratio=3D9/2, ITC freq=900.000MHz+/-450ppm
Calibrating delay loop... 1347.58 BogoMIPS (lpj&95168)
Brought up 2 CPUs
Total of 2 processors activated (2695.16 BogoMIPS).
migration_cost=1757
DMI 2.3 present.
NET: Registered protocol family 16
ACPI: bus type pci registered
ACPI: Subsystem revision 20060127
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
kernel unaligned access to 0xe0000040fed42e04, ip=3D0xa000000100415ee1
kernel unaligned access to 0xe0000040fed42e34, ip=3D0xa000000100415ee1
kernel unaligned access to 0xe0000040fed42e6c, ip=3D0xa000000100415ee1
kernel unaligned access to 0xe0000040fed42ebc, ip=3D0xa000000100415ee1
kernel unaligned access to 0xe0000040fed42dfc, ip=3D0xa000000100414c71
ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI0._PRT]
ACPI: PCI Root Bridge [PCI1] (0000:20)
ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI1._PRT]
ACPI: PCI Root Bridge [PCI2] (0000:40)
ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI2._PRT]
ACPI: PCI Root Bridge [PCI3] (0000:60)
ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI3._PRT]
ACPI: PCI Root Bridge [PCI4] (0000:80)
ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI4._PRT]
ACPI: PCI Root Bridge [PCI6] (0000:c0)
ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI6._PRT]
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
GSI 34 (edge, high) -> CPU 1 (0x0100) vector 49
GSI 35 (edge, high) -> CPU 0 (0x0000) vector 50
pnp: PnP ACPI: found 10 devices
SCSI subsystem initialized
IOC: zx1 2.2 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 6, 1048576 bytes)
TCP established hash table entries: 524288 (order: 9, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Total HugeTLB memory allocated, 0
SGI XFS with large block/inode numbers, no debug enabled
Initializing Cryptographic API
io scheduler noop registered
io scheduler anticipatory registered (default)
io scheduler deadline registered
io scheduler cfq registered
EFI Time Services Driver v0.4
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
00:04: ttyS0 at MMIO 0xff5e0000 (irq =3D 49) is a 16550A
00:05: ttyS1 at MMIO 0xff5e2000 (irq =3D 50) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
Intel(R) PRO/1000 Network Driver - version 7.0.33-k2
Copyright (c) 1999-2005 Intel Corporation.
tg3.c:v3.59 (June 8, 2006)
GSI 29 (level, low) -> CPU 1 (0x0100) vector 51
ACPI: PCI Interrupt 0000:20:02.0[A] -> GSI 29 (level, low) -> IRQ 51
eth0: Tigon3 [partno(BCM95700A6) rev 0105 PHY(5701)] (PCI:66MHz:64-bit) 10/=
100/1000BaseT Ethernet 00:30:6e:38:d9:67
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap=
[0]=20
eth0: dma_rwctrl[76ff2d0f] dma_mask[64-bit]
netconsole: not configured, aborting
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=3D=
xx
CMD649: IDE controller at PCI slot 0000:00:02.0
GSI 21 (level, low) -> CPU 0 (0x0000) vector 52
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 21 (level, low) -> IRQ 52
CMD649: chipset revision 2
CMD649: 100% native mode on irq 52
    ide0: BM-DMA at 0x0d40-0x0d47, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x0d48-0x0d4f, BIOS settings: hdc:pio, hdd:pio
Probing IDE interface ide0...
hda: DW-28E, ATAPI CD/DVD-ROM drive
ide0 at 0xd58-0xd5f,0xd66 on irq 52
Probing IDE interface ide1...
hda: ATAPI 24X DVD-ROM CD-R/RW drive, 1698kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
libata version 1.20 loaded.
Fusion MPT base driver 3.03.09
Copyright (c) 1999-2005 LSI Logic Corporation
Fusion MPT SPI Host driver 3.03.09
GSI 27 (level, low) -> CPU 1 (0x0100) vector 53
ACPI: PCI Interrupt 0000:20:01.0[A] -> GSI 27 (level, low) -> IRQ 53
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities=3D{Initiator,Target}
scsi0 : ioc0: LSI53C1030, FwRev=01032300h, Ports=3D1, MaxQ%5, IRQS
  Vendor: HP 36.4G  Model: ST336706LC        Rev: HP04
  Type:   Direct-Access                      ANSI SCSI revision: 02
 target0:0:0: Beginning Domain Validation
 target0:0:0: Ending Domain Validation
 target0:0:0: FAST-80 WIDE SCSI 160.0 MB/s DT (12.5 ns, offset 63)
SCSI device sda: 71132960 512-byte hdwr sectors (36420 MB)
sda: Write Protect is off
sda: Mode Sense: 9f 00 10 08
SCSI device sda: drive cache: write through w/ FUA
SCSI device sda: 71132960 512-byte hdwr sectors (36420 MB)
sda: Write Protect is off
sda: Mode Sense: 9f 00 10 08
SCSI device sda: drive cache: write through w/ FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: Attached scsi disk sda
  Vendor: HP 36.4G  Model: ST336706LC        Rev: HP04
  Type:   Direct-Access                      ANSI SCSI revision: 02
 target0:0:1: Beginning Domain Validation
 target0:0:1: Ending Domain Validation
 target0:0:1: FAST-80 WIDE SCSI 160.0 MB/s DT (12.5 ns, offset 63)
SCSI device sdb: 71132960 512-byte hdwr sectors (36420 MB)
sdb: Write Protect is off
sdb: Mode Sense: 9f 00 10 08
SCSI device sdb: drive cache: write through w/ FUA
SCSI device sdb: 71132960 512-byte hdwr sectors (36420 MB)
sdb: Write Protect is off
sdb: Mode Sense: 9f 00 10 08
SCSI device sdb: drive cache: write through w/ FUA
 sdb: sdb1 sdb2 sdb3
sd 0:0:1:0: Attached scsi disk sdb
GSI 28 (level, low) -> CPU 0 (0x0000) vector 54
ACPI: PCI Interrupt 0000:20:01.1[B] -> GSI 28 (level, low) -> IRQ 54
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities=3D{Initiator,Target}
scsi1 : ioc1: LSI53C1030, FwRev=01032300h, Ports=3D1, MaxQ%5, IRQT
  Vendor: HP 36.4G  Model: ST336732LC        Rev: HPE3
  Type:   Direct-Access                      ANSI SCSI revision: 02
 target1:0:2: Beginning Domain Validation
 target1:0:2: Ending Domain Validation
 target1:0:2: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.2=
5 ns, offset 63)
SCSI device sdc: 71132960 512-byte hdwr sectors (36420 MB)
sdc: Write Protect is off
sdc: Mode Sense: ab 00 10 08
SCSI device sdc: drive cache: write through w/ FUA
SCSI device sdc: 71132960 512-byte hdwr sectors (36420 MB)
sdc: Write Protect is off
sdc: Mode Sense: ab 00 10 08
SCSI device sdc: drive cache: write through w/ FUA
 sdc: sdc1
sd 1:0:2:0: Attached scsi disk sdc
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Adding console on ttyS0 at MMIO 0xff5e0000 (options '115200')
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 384kB freed
Failed to mount /selinux/: No such file or directory
INIT: version 2.86 booting
Starting the hotplug events dispatcher: udevd.
Synthesizing the initial hotplug events...done.
Waiting for /dev to be fully populated...done.
Activating swap...
Adding 1473632k swap on /dev/sda3.  Priority:-1 extents:1 across:1473632k
.
Checking root file system.../: clean, 63124/4251520 files, 648616/8498779 b=
locks
.
EXT3 FS on sda2, internal journal
Cleaning up ifupdown...done.
=1B[33m*=1B[39;49m Not running depmod because /lib/modules/2.6.17.11/ is no=
t writeable.
Loading modules...
    psmouse
FATAL: Could not load /lib/modules/2.6.17.11/modules.dep: No such file or d=
irectory
    sd_mod
FATAL: Could not load /lib/modules/2.6.17.11/modules.dep: No such file or d=
irectory
All modules loaded.
FATAL: Could not load /lib/modules/2.6.17.11/modules.dep: No such file or d=
irectory
Setting the System Clock using the Hardware Clock as reference
System Clock set. Local time: Tue Sep 12 16:31:40 UTC 2006
.
Checking all file systems....
Setting kernel variables ...
... done.
Mounting local filesystems... =1B[31mfailed!=1B[39;49m
Cleaning /tmp....
Cleaning /var/run ....
Cleaning /var/lock ....
Detecting hardware...Discovered hardware for these modules: e100 tg3 cmd64x=
 mptscsih usb_ohci ehci_hcd
=1B[33m*=1B[39;49m Skipping unavailable/built-in e100 module.
=1B[33m*=1B[39;49m Skipping unavailable/built-in tg3 module.
=1B[33m*=1B[39;49m Skipping unavailable/built-in cmd64x module.
=1B[33m*=1B[39;49m Skipping unavailable/built-in mptscsih module.
=1B[33m*=1B[39;49m Skipping unavailable/built-in ohci_hcd module.
=1B[33m*=1B[39;49m Skipping unavailable/built-in ehci_hcd module.
Setting up networking...done.
hostname: the specified hostname is invalid
=1B[33m*=1B[39;49m /etc/network/options is deprecated.
Setting up IP spoofing protection...done (rp_filter).
Configuring network interfaces...Internet Software Consortium DHCP Client 2=
.0pl5
Copyright 1995, 1996, 1997, 1998, 1999 The Internet Software Consortium.
All rights reserved.

Please contribute if you find this software useful.
For info, please visit http://www.isc.org/dhcp-contrib.html

PM: Writing back config space on device 0000:20:02.0 at offset b (was 16451=
4e4, writing 12a4103c)
PM: Writing back config space on device 0000:20:02.0 at offset 3 (was 0, wr=
iting c020)
PM: Writing back config space on device 0000:20:02.0 at offset 2 (was 20000=
00, writing 2000015)
PM: Writing back config space on device 0000:20:02.0 at offset 1 (was 2b000=
00, writing 2b00146)
Listening on LPF/eth0/00:30:6e:38:d9:67
Sending on   LPF/eth0/00:30:6e:38:d9:67
Sending on   Socket/fallback/fallback-net
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 5
tg3: eth0: Link is up at 100 Mbps, full duplex.
tg3: eth0: Flow control is off for TX and off for RX.
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 5
DHCPOFFER from 10.0.0.1
DHCPREQUEST on eth0 to 255.255.255.255 port 67
DHCPACK from 10.0.0.1
bound to 10.100.100.188 -- renewal in 129600 seconds.
done.
Starting portmap daemon: portmap.
Setting the System Clock using the Hardware Clock as reference
System Clock set. Local time: Tue Sep 12 16:31:53 UTC 2006
.
Initializing random number generator....
Recovering nvi editor sessions... done.
Setting up X server socket directory /tmp/.X11-unix...done.
Setting up ICE socket directory /tmp/.ICE-unix...done.
INIT: Entering runlevel: 2
Starting system log daemon: syslogd.
Starting kernel log daemon: klogd.
Not starting portmap daemon.  Already running.
Loading ACPI modules:
Starting Advanced Configuration and Power Interface daemon: acpid.
Starting system message bus: dbus-1.
Starting Hardware abstraction layer: hald.
Starting MTA: exim4.
Starting internet superserver: inetd.
Starting printer spooler: lpd .
Starting OpenBSD Secure Shell server: sshd.
Starting file alteration monitor: FAM.
Starting NFS common utilities: statd.
Starting deferred execution scheduler: atd.
Starting periodic command scheduler: cron.
Starting GNOME Display Manager: gdm.

Debian GNU/Linux testing/unstable lp.helgaas ttyS0

lp.helgaas login:=20

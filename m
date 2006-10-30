From: Horms <horms@verge.net.au>
Date: Mon, 30 Oct 2006 09:15:26 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061030091524.GC21894@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Mon, Oct 30, 2006 at 06:11:26PM +0900, Horms wrote:
> On Fri, Oct 27, 2006 at 10:15:16AM +0100, Andy Whitcroft wrote:
> > Hi,
> >=20
> > Mel and I spent a bit more time thinking about this.  If the efi map is
> > being modified such that the kernel area becomes loader data that may
> > well move up the start of conventional memory as far as the running
> > kernel is concerned.
> >=20
> > [Apologies in advance if Zou is not an appropriate name.]
> >=20
> > It would be helpful both to have a dump of the efi map and the start
> > address of the kernel from the affected machine (Horms) and if possible
> > the efi map and start address of the kernel from your working test
> > platform (Zou).  Also, if we could get the boot logs from a conventional
> > kernel and the kexec kernel from the working test platform (Zou).
>=20
> Below is a log of 05e0caad3b7bd0d0fbeff980bca22f186241a501 + kexec.
> It shows the initial successful boot and kdump with oopses. I enabled
> EFI_DEBUG which prints out the efi map. And just before that
> I added some code to print out the value of _start. If this is not
> what you need please let me know.
>=20
> I can also produce logs for 05e0caad3b7bd0d0fbeff980bca22f186241a501
> without kexec, or with 05e0caad3b7bd0d0fbeff980bca22f186241a501 reversed
> if you like.

Sorry, I forgot the log, here it is. I should mention that curiously
it seems to print out the EFI map twice when kexecing the crash kernel.
I am not sure why this is.

--=20
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

Starting: Network Boot/Pci(4|1|0)/Mac(000E0C9FA3AE)
ELILO
Uncompressing Linux... done
Loading initrd people/horms/initramfs_data.cpio.gz...done
Linux version 2.6.18-kexec-g05e0caad-dirty (horms@tabatha.lab.ultramonkey.o=
rg) (gcc version 3.4.5) #33 SMP Mon Oct 30 17:50:37 JST 2006
EFI v1.10 by INTEL: SALsystab=3D0x7fe54980 ACPI=3D0x7ff99000 ACPI 2.0=3D0x7=
ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
Kernel Start Address: _start=000000070300000b
mem00: type=3D4, attr=3D0x9, range=3D[0x0000000000000000-0x0000000000001000=
) (0MB)
mem01: type=3D7, attr=3D0x9, range=3D[0x0000000000001000-0x0000000000007000=
) (0MB)
mem02: type=3D4, attr=3D0x9, range=3D[0x0000000000007000-0x0000000000009000=
) (0MB)
mem03: type=3D7, attr=3D0x9, range=3D[0x0000000000009000-0x0000000000082000=
) (0MB)
mem04: type=3D6, attr=3D0x8000000000000009, range=3D[0x0000000000082000-0x0=
000000000084000) (0MB)
mem05: type=3D7, attr=3D0x9, range=3D[0x0000000000084000-0x0000000000085000=
) (0MB)
mem06: type=3D4, attr=3D0x9, range=3D[0x0000000000085000-0x00000000000a0000=
) (0MB)
mem07: type=3D5, attr=3D0x8000000000000009, range=3D[0x00000000000c0000-0x0=
000000000100000) (0MB)
mem08: type=3D7, attr=3D0xb, range=3D[0x0000000000100000-0x0000000004000000=
) (63MB)
mem09: type=3D2, attr=3D0xb, range=3D[0x0000000004000000-0x0000000004759000=
) (7MB)
mem10: type=3D7, attr=3D0xb, range=3D[0x0000000004759000-0x000000000ffc0000=
) (184MB)
mem11: type=3D4, attr=3D0xb, range=3D[0x000000000ffc0000-0x0000000010000000=
) (0MB)
mem12: type=3D7, attr=3D0xb, range=3D[0x0000000010000000-0x000000007af5e000=
) (1711MB)
mem13: type=3D2, attr=3D0xb, range=3D[0x000000007af5e000-0x000000007af64000=
) (0MB)
mem14: type=3D7, attr=3D0xb, range=3D[0x000000007af64000-0x000000007af65000=
) (0MB)
mem15: type=3D2, attr=3D0xb, range=3D[0x000000007af65000-0x000000007c8d2000=
) (25MB)
mem16: type=3D1, attr=3D0xb, range=3D[0x000000007c8d2000-0x000000007c92e000=
) (0MB)
mem17: type=3D2, attr=3D0xb, range=3D[0x000000007c92e000-0x000000007c938000=
) (0MB)
mem18: type=3D1, attr=3D0xb, range=3D[0x000000007c938000-0x000000007c97e000=
) (0MB)
mem19: type=3D7, attr=3D0xb, range=3D[0x000000007c97e000-0x000000007ce16000=
) (4MB)
mem20: type=3D4, attr=3D0xb, range=3D[0x000000007ce16000-0x000000007ce1c000=
) (0MB)
mem21: type=3D7, attr=3D0xb, range=3D[0x000000007ce1c000-0x000000007ce20000=
) (0MB)
mem22: type=3D4, attr=3D0xb, range=3D[0x000000007ce20000-0x000000007ce22000=
) (0MB)
mem23: type=3D7, attr=3D0xb, range=3D[0x000000007ce22000-0x000000007ce2a000=
) (0MB)
mem24: type=3D4, attr=3D0xb, range=3D[0x000000007ce2a000-0x000000007d001000=
) (1MB)
mem25: type=3D7, attr=3D0xb, range=3D[0x000000007d001000-0x000000007d002000=
) (0MB)
mem26: type=3D4, attr=3D0xb, range=3D[0x000000007d002000-0x000000007d004000=
) (0MB)
mem27: type=3D7, attr=3D0xb, range=3D[0x000000007d004000-0x000000007d026000=
) (0MB)
mem28: type=3D4, attr=3D0xb, range=3D[0x000000007d026000-0x000000007d068000=
) (0MB)
mem29: type=3D7, attr=3D0xb, range=3D[0x000000007d068000-0x000000007d069000=
) (0MB)
mem30: type=3D4, attr=3D0xb, range=3D[0x000000007d069000-0x000000007d37e000=
) (3MB)
mem31: type=3D7, attr=3D0xb, range=3D[0x000000007d37e000-0x000000007d700000=
) (3MB)
mem32: type=3D3, attr=3D0xb, range=3D[0x000000007d700000-0x000000007d77e000=
) (0MB)
mem33: type=3D7, attr=3D0xb, range=3D[0x000000007d77e000-0x000000007d8b4000=
) (1MB)
mem34: type=3D6, attr=3D0x8000000000000009, range=3D[0x000000007d8b4000-0x0=
00000007d900000) (0MB)
mem35: type=3D3, attr=3D0xb, range=3D[0x000000007d900000-0x000000007f980000=
) (32MB)
mem36: type=3D7, attr=3D0xb, range=3D[0x000000007f980000-0x000000007fa00000=
) (0MB)
mem37: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007fa00000-0x0=
00000007fe00000) (4MB)
mem38: type=13, attr=3D0x8000000000000009, range=3D[0x000000007fe00000-0x00=
0000007fe48000) (0MB)
mem39: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007fe48000-0x0=
00000007fea0000) (0MB)
mem40: type=3D7, attr=3D0xb, range=3D[0x000000007fea0000-0x000000007feda000=
) (0MB)
mem41: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007feda000-0x0=
00000007ff46000) (0MB)
mem42: type=3D6, attr=3D0x8000000000000009, range=3D[0x000000007ff46000-0x0=
000000080000000) (0MB)
mem43: type=11, attr=3D0x1, range=3D[0x00000000fe000000-0x00000000ff000000)=
 (16MB)
mem44: type=3D6, attr=3D0x8000000000000001, range=3D[0x00000000ff000000-0x0=
000000100000000) (16MB)
mem45: type=11, attr=3D0x8000000000000001, range=3D[0x00000ffff8000000-0x00=
000ffffc000000) (64MB)
mem46: type=12, attr=3D0x8000000000000001, range=3D[0x00000ffffc000000-0x00=
00100000000000) (64MB)
CPU 0: mapping PAL code [0x7fe00000-0x7fe48000) into [0xe00000007f000000-0x=
e000000080000000)
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200')
Initial ramdisk at: 0xe00000007af65000 (9839740 bytes)
SAL 3.20: Intel Corp                       SR870BH2                        =
 version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
No logical to physical processor mapping available
CPU 0: mapping PAL code [0x7fe00000-0x7fe48000) into [0xe00000007f000000-0x=
e000000080000000)
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address c0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0100) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
2 CPUs available, 2 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffff900000
Zone PFN ranges:
  DMA          1025 ->   262144
  Normal     262144 ->   262144
early_node_map[7] active PFN ranges
    0:     1025 ->     4096
    0:     4567 ->    16384
    0:    32768 ->   125911
    0:   126514 ->   127540
    0:   127541 ->   128557
    0:   128576 ->   130688
    0:   130984 ->   130998
SMP: Allowing 2 CPUs, 0 hotplug CPUs
Built 1 zonelists.  Total pages: 112199
Kernel command line: BOOT_IMAGE=3Dnet0:ia64/people/horms/vmlinux.gz  maxcpu=
s=3D1 console=3Duart,io,0x2f8,115200 crashkernel%6M@256M ro
PID hash table entries: 4096 (order: 12, 32768 bytes)
Console: colour VGA+ 80x25
Placing software IO TLB between 0x6764000 - 0xa764000
Memory: 1655792k/1795184k available (3297k code, 418752k reserved, 2286k da=
ta, 640k init)
McKinley Errata 9 workaround not needed; disabling it
Dentry cache hash table entries: 262144 (order: 7, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
Mount-cache hash table entries: 1024
ACPI: Core revision 20060707
Boot processor id 0x0/0x100
Brought up 1 CPUs
Total of 1 processors activated (1941.50 BogoMIPS).
migration_cost=3D0
checking if image is initramfs... it is
Freeing initrd memory: 9584kB freed
DMI 2.3 present.
ACPI: bus type pci registered
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI quirk: region 0c00-0c7f claimed by ICH4 ACPI/GPIO/TCO
PCI quirk: region 0500-053f claimed by ICH4 GPIO
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
ACPI: PCI Root Bridge [PCI1] (0000:02)
ACPI: PCI Root Bridge [PCI2] (0000:05)
ACPI: Device [CSFF] status [00000008]: functional but not present; setting =
present
ACPI: PCI Root Bridge [CSFF] (0000:ff)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 12 devices
SCSI subsystem initialized
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
io scheduler noop registered
io scheduler anticipatory registered (default)
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
00:08: ttyS0 at I/O 0x3f8 (irq =3D 44) is a 16550A
00:09: ttyS1 at I/O 0x2f8 (irq =3D 45) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
Adding console on ttyS1 at I/O port 0x2f8 (options '115200')
Freeing unused kernel memory: 640kB freed
init started:  BusyBox v1.2.1 (2006.09.23-05:46+0000) multi-call binary
Starting pid 776, console /dev/console: '/etc/init.d/rcS'
ifconfig: socket: Function not implemented
ifconfig: No usable address families found.
ifconfig: socket: Function not implemented
Starting pid 885, console /dev/console: '/bin/sh'


BusyBox v1.2.1 (2006.09.23-05:46+0000) Built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ # do_kdump=20
XEN=3D"" KDUMP=3D"yes"
ARCH=3D"ia64" KARCH=3D"ia64" UARCH=3D"ia64"
IMAGE=3D"vmlinux-ia64-kdump.gz" XEN_IMAGE=3D"xen-ia64.gz"
Create ramdisk
Load kernel and ramdisk
Kdump
SysRq : Trigger a crashdump
CPU 0: mapping PAL code [0x7fe00000-0x7fe48000) into [0xe00000007f000000-0x=
e000000080000000)
Linux version 2.6.18-kexec-g05e0caad-dirty (horms@tabatha.lab.ultramonkey.o=
rg) (gcc version 3.4.5) #33 SMP Mon Oct 30 17:50:37 JST 2006
Ignoring memory below 256MB
Ignoring memory above 512MB
EFI v1.10 by INTEL: SALsystab=3D0x7fe54980 ACPI=3D0x7ff99000 ACPI 2.0=3D0x7=
ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
Kernel Start Address: _start=000000070300000b
mem00: type=3D4, attr=3D0x9, range=3D[0x0000000000000000-0x0000000000001000=
) (0MB)
mem01: type=3D7, attr=3D0x9, range=3D[0x0000000000001000-0x0000000000007000=
) (0MB)
mem02: type=3D4, attr=3D0x9, range=3D[0x0000000000007000-0x0000000000009000=
) (0MB)
mem03: type=3D7, attr=3D0x9, range=3D[0x0000000000009000-0x0000000000082000=
) (0MB)
mem04: type=3D6, attr=3D0x8000000000000009, range=3D[0x0000000000082000-0x0=
000000000084000) (0MB)
mem05: type=3D7, attr=3D0x9, range=3D[0x0000000000084000-0x0000000000085000=
) (0MB)
mem06: type=3D4, attr=3D0x9, range=3D[0x0000000000085000-0x00000000000a0000=
) (0MB)
mem07: type=3D5, attr=3D0x8000000000000009, range=3D[0x00000000000c0000-0x0=
000000000100000) (0MB)
mem08: type=3D7, attr=3D0xb, range=3D[0x0000000000100000-0x0000000004000000=
) (63MB)
mem09: type=3D7, attr=3D0xb, range=3D[0x0000000004000000-0x0000000004759000=
) (7MB)
mem10: type=3D7, attr=3D0xb, range=3D[0x0000000004759000-0x000000000ffc0000=
) (184MB)
mem11: type=3D4, attr=3D0xb, range=3D[0x000000000ffc0000-0x0000000010000000=
) (0MB)
mem12: type=3D2, attr=3D0xb, range=3D[0x0000000010000000-0x00000000104b0000=
) (4MB)
mem13: type=3D2, attr=3D0xb, range=3D[0x00000000104b0000-0x00000000104c0000=
) (0MB)
mem14: type=3D2, attr=3D0xb, range=3D[0x00000000104c0000-0x0000000010760000=
) (2MB)
mem15: type=3D7, attr=3D0xb, range=3D[0x0000000010760000-0x000000001ffe4000=
) (248MB)
mem16: type=3D8, attr=3D0xb, range=3D[0x000000001ffe4000-0x000000001ffe5000=
) (0MB)
mem17: type=3D7, attr=3D0xb, range=3D[0x000000001ffe5000-0x000000007af5e000=
) (1455MB)
mem18: type=3D7, attr=3D0xb, range=3D[0x000000007af5e000-0x000000007af64000=
) (0MB)
mem19: type=3D7, attr=3D0xb, range=3D[0x000000007af64000-0x000000007af65000=
) (0MB)
mem20: type=3D7, attr=3D0xb, range=3D[0x000000007af65000-0x000000007c8d2000=
) (25MB)
mem21: type=3D1, attr=3D0xb, range=3D[0x000000007c8d2000-0x000000007c92e000=
) (0MB)
mem22: type=3D7, attr=3D0xb, range=3D[0x000000007c92e000-0x000000007c938000=
) (0MB)
mem23: type=3D1, attr=3D0xb, range=3D[0x000000007c938000-0x000000007c97e000=
) (0MB)
mem24: type=3D7, attr=3D0xb, range=3D[0x000000007c97e000-0x000000007ce16000=
) (4MB)
mem25: type=3D4, attr=3D0xb, range=3D[0x000000007ce16000-0x000000007ce1c000=
) (0MB)
mem26: type=3D7, attr=3D0xb, range=3D[0x000000007ce1c000-0x000000007ce20000=
) (0MB)
mem27: type=3D4, attr=3D0xb, range=3D[0x000000007ce20000-0x000000007ce22000=
) (0MB)
mem28: type=3D7, attr=3D0xb, range=3D[0x000000007ce22000-0x000000007ce2a000=
) (0MB)
mem29: type=3D4, attr=3D0xb, range=3D[0x000000007ce2a000-0x000000007d001000=
) (1MB)
mem30: type=3D7, attr=3D0xb, range=3D[0x000000007d001000-0x000000007d002000=
) (0MB)
mem31: type=3D4, attr=3D0xb, range=3D[0x000000007d002000-0x000000007d004000=
) (0MB)
mem32: type=3D7, attr=3D0xb, range=3D[0x000000007d004000-0x000000007d026000=
) (0MB)
mem33: type=3D4, attr=3D0xb, range=3D[0x000000007d026000-0x000000007d068000=
) (0MB)
mem34: type=3D7, attr=3D0xb, range=3D[0x000000007d068000-0x000000007d069000=
) (0MB)
mem35: type=3D4, attr=3D0xb, range=3D[0x000000007d069000-0x000000007d37e000=
) (3MB)
mem36: type=3D7, attr=3D0xb, range=3D[0x000000007d37e000-0x000000007d700000=
) (3MB)
mem37: type=3D3, attr=3D0xb, range=3D[0x000000007d700000-0x000000007d77e000=
) (0MB)
mem38: type=3D7, attr=3D0xb, range=3D[0x000000007d77e000-0x000000007d8b4000=
) (1MB)
mem39: type=3D6, attr=3D0x8000000000000009, range=3D[0x000000007d8b4000-0x0=
00000007d900000) (0MB)
mem40: type=3D3, attr=3D0xb, range=3D[0x000000007d900000-0x000000007f980000=
) (32MB)
mem41: type=3D7, attr=3D0xb, range=3D[0x000000007f980000-0x000000007fa00000=
) (0MB)
mem42: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007fa00000-0x0=
00000007fe00000) (4MB)
mem43: type=13, attr=3D0x8000000000000009, range=3D[0x000000007fe00000-0x00=
0000007fe48000) (0MB)
mem44: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007fe48000-0x0=
00000007fea0000) (0MB)
mem45: type=3D7, attr=3D0xb, range=3D[0x000000007fea0000-0x000000007feda000=
) (0MB)
mem46: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007feda000-0x0=
00000007ff46000) (0MB)
mem47: type=3D6, attr=3D0x8000000000000009, range=3D[0x000000007ff46000-0x0=
000000080000000) (0MB)
mem48: type=11, attr=3D0x1, range=3D[0x00000000fe000000-0x00000000ff000000)=
 (16MB)
mem49: type=3D6, attr=3D0x8000000000000001, range=3D[0x00000000ff000000-0x0=
000000100000000) (16MB)
mem50: type=11, attr=3D0x8000000000000001, range=3D[0x00000ffff8000000-0x00=
000ffffc000000) (64MB)
mem51: type=12, attr=3D0x8000000000000001, range=3D[0x00000ffffc000000-0x00=
00100000000000) (64MB)
CPU 0: mapping PAL code [0x7fe00000-0x7fe48000) into [0xe00000007f000000-0x=
e000000080000000)
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200n8')
Initial ramdisk at: 0xe00000001f580000 (10739200 bytes)
SAL 3.20: Intel Corp                       SR870BH2                        =
 version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
No logical to physical processor mapping available
CPU 0: mapping PAL code [0x7fe00000-0x7fe48000) into [0xe00000007f000000-0x=
e000000080000000)
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address c0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0100) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
2 CPUs available, 2 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffe40000
Zone PFN ranges:
  DMA         16855 ->   262144
  Normal     262144 ->   262144
early_node_map[7] active PFN ranges
    0:    16855 ->    16856
    0:    16857 ->    32096
    0:    32752 ->    32753
    0:    32754 ->    32755
    0:    32756 ->    32757
    0:    32758 ->    32761
    0:    32762 ->    32768
SMP: Allowing 2 CPUs, 0 hotplug CPUs
Built 1 zonelists.  Total pages: 15252
Kernel command line: phys_efi clock=3Dpit ip=3Don apm=3Dpower-off console=
=3Dtty0 console=3Duart,io,0x2f8,115200n8 init 1 irqpoll maxcpus=3D1 elfcore=
hdrR4176K max_addrQ2M min_addr%6M
Warning! clock=3D boot option is deprecated. Use clocksource=3Dxyz
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
PID hash table entries: 1024 (order: 10, 8192 bytes)
Console: colour VGA+ 80x25
Linux version 2.6.18-kexec-g05e0caad-dirty (horms@tabatha.lab.ultramonkey.o=
rg) (gcc version 3.4.5) #33 SMP Mon Oct 30 17:50:37 JST 2006
Ignoring memory below 256MB
Ignoring memory above 512MB
EFI v1.10 by INTEL: SALsystab=3D0x7fe54980 ACPI=3D0x7ff99000 ACPI 2.0=3D0x7=
ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
Kernel Start Address: _start=000000070300000b
mem00: type=3D4, attr=3D0x9, range=3D[0x0000000000000000-0x0000000000001000=
) (0MB)
mem01: type=3D7, attr=3D0x9, range=3D[0x0000000000001000-0x0000000000007000=
) (0MB)
mem02: type=3D4, attr=3D0x9, range=3D[0x0000000000007000-0x0000000000009000=
) (0MB)
mem03: type=3D7, attr=3D0x9, range=3D[0x0000000000009000-0x0000000000082000=
) (0MB)
mem04: type=3D6, attr=3D0x8000000000000009, range=3D[0x0000000000082000-0x0=
000000000084000) (0MB)
mem05: type=3D7, attr=3D0x9, range=3D[0x0000000000084000-0x0000000000085000=
) (0MB)
mem06: type=3D4, attr=3D0x9, range=3D[0x0000000000085000-0x00000000000a0000=
) (0MB)
mem07: type=3D5, attr=3D0x8000000000000009, range=3D[0x00000000000c0000-0x0=
000000000100000) (0MB)
mem08: type=3D7, attr=3D0xb, range=3D[0x0000000000100000-0x0000000004000000=
) (63MB)
mem09: type=3D7, attr=3D0xb, range=3D[0x0000000004000000-0x0000000004759000=
) (7MB)
mem10: type=3D7, attr=3D0xb, range=3D[0x0000000004759000-0x000000000ffc0000=
) (184MB)
mem11: type=3D4, attr=3D0xb, range=3D[0x000000000ffc0000-0x0000000010000000=
) (0MB)
mem12: type=3D2, attr=3D0xb, range=3D[0x0000000010000000-0x00000000104b0000=
) (4MB)
mem13: type=3D2, attr=3D0xb, range=3D[0x00000000104b0000-0x00000000104c0000=
) (0MB)
mem14: type=3D2, attr=3D0xb, range=3D[0x00000000104c0000-0x0000000010760000=
) (2MB)
mem15: type=3D7, attr=3D0xb, range=3D[0x0000000010760000-0x000000001ffe4000=
) (248MB)
mem16: type=3D8, attr=3D0xb, range=3D[0x000000001ffe4000-0x000000001ffe5000=
) (0MB)
mem17: type=3D7, attr=3D0xb, range=3D[0x000000001ffe5000-0x000000007af5e000=
) (1455MB)
mem18: type=3D7, attr=3D0xb, range=3D[0x000000007af5e000-0x000000007af64000=
) (0MB)
mem19: type=3D7, attr=3D0xb, range=3D[0x000000007af64000-0x000000007af65000=
) (0MB)
mem20: type=3D7, attr=3D0xb, range=3D[0x000000007af65000-0x000000007c8d2000=
) (25MB)
mem21: type=3D1, attr=3D0xb, range=3D[0x000000007c8d2000-0x000000007c92e000=
) (0MB)
mem22: type=3D7, attr=3D0xb, range=3D[0x000000007c92e000-0x000000007c938000=
) (0MB)
mem23: type=3D1, attr=3D0xb, range=3D[0x000000007c938000-0x000000007c97e000=
) (0MB)
mem24: type=3D7, attr=3D0xb, range=3D[0x000000007c97e000-0x000000007ce16000=
) (4MB)
mem25: type=3D4, attr=3D0xb, range=3D[0x000000007ce16000-0x000000007ce1c000=
) (0MB)
mem26: type=3D7, attr=3D0xb, range=3D[0x000000007ce1c000-0x000000007ce20000=
) (0MB)
mem27: type=3D4, attr=3D0xb, range=3D[0x000000007ce20000-0x000000007ce22000=
) (0MB)
mem28: type=3D7, attr=3D0xb, range=3D[0x000000007ce22000-0x000000007ce2a000=
) (0MB)
mem29: type=3D4, attr=3D0xb, range=3D[0x000000007ce2a000-0x000000007d001000=
) (1MB)
mem30: type=3D7, attr=3D0xb, range=3D[0x000000007d001000-0x000000007d002000=
) (0MB)
mem31: type=3D4, attr=3D0xb, range=3D[0x000000007d002000-0x000000007d004000=
) (0MB)
mem32: type=3D7, attr=3D0xb, range=3D[0x000000007d004000-0x000000007d026000=
) (0MB)
mem33: type=3D4, attr=3D0xb, range=3D[0x000000007d026000-0x000000007d068000=
) (0MB)
mem34: type=3D7, attr=3D0xb, range=3D[0x000000007d068000-0x000000007d069000=
) (0MB)
mem35: type=3D4, attr=3D0xb, range=3D[0x000000007d069000-0x000000007d37e000=
) (3MB)
mem36: type=3D7, attr=3D0xb, range=3D[0x000000007d37e000-0x000000007d700000=
) (3MB)
mem37: type=3D3, attr=3D0xb, range=3D[0x000000007d700000-0x000000007d77e000=
) (0MB)
mem38: type=3D7, attr=3D0xb, range=3D[0x000000007d77e000-0x000000007d8b4000=
) (1MB)
mem39: type=3D6, attr=3D0x8000000000000009, range=3D[0x000000007d8b4000-0x0=
00000007d900000) (0MB)
mem40: type=3D3, attr=3D0xb, range=3D[0x000000007d900000-0x000000007f980000=
) (32MB)
mem41: type=3D7, attr=3D0xb, range=3D[0x000000007f980000-0x000000007fa00000=
) (0MB)
mem42: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007fa00000-0x0=
00000007fe00000) (4MB)
mem43: type=13, attr=3D0x8000000000000009, range=3D[0x000000007fe00000-0x00=
0000007fe48000) (0MB)
mem44: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007fe48000-0x0=
00000007fea0000) (0MB)
mem45: type=3D7, attr=3D0xb, range=3D[0x000000007fea0000-0x000000007feda000=
) (0MB)
mem46: type=3D5, attr=3D0x8000000000000009, range=3D[0x000000007feda000-0x0=
00000007ff46000) (0MB)
mem47: type=3D6, attr=3D0x8000000000000009, range=3D[0x000000007ff46000-0x0=
000000080000000) (0MB)
mem48: type=11, attr=3D0x1, range=3D[0x00000000fe000000-0x00000000ff000000)=
 (16MB)
mem49: type=3D6, attr=3D0x8000000000000001, range=3D[0x00000000ff000000-0x0=
000000100000000) (16MB)
mem50: type=11, attr=3D0x8000000000000001, range=3D[0x00000ffff8000000-0x00=
000ffffc000000) (64MB)
mem51: type=12, attr=3D0x8000000000000001, range=3D[0x00000ffffc000000-0x00=
00100000000000) (64MB)
CPU 0: mapping PAL code [0x7fe00000-0x7fe48000) into [0xe00000007f000000-0x=
e000000080000000)
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200n8')
Initial ramdisk at: 0xe00000001f580000 (10739200 bytes)
SAL 3.20: Intel Corp                       SR870BH2                        =
 version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
No logical to physical processor mapping available
CPU 0: mapping PAL code [0x7fe00000-0x7fe48000) into [0xe00000007f000000-0x=
e000000080000000)
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address c0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0100) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
2 CPUs available, 2 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffe40000
Zone PFN ranges:
  DMA         16855 ->   262144
  Normal     262144 ->   262144
early_node_map[7] active PFN ranges
    0:    16855 ->    16856
    0:    16857 ->    32096
    0:    32752 ->    32753
    0:    32754 ->    32755
    0:    32756 ->    32757
    0:    32758 ->    32761
    0:    32762 ->    32768
SMP: Allowing 2 CPUs, 0 hotplug CPUs
Built 1 zonelists.  Total pages: 15252
Kernel command line: phys_efi clock=3Dpit ip=3Don apm=3Dpower-off console=
=3Dtty0 console=3Duart,io,0x2f8,115200n8 init 1 irqpoll maxcpus=3D1 elfcore=
hdrR4176K max_addrQ2M min_addr%6M
Warning! clock=3D boot option is deprecated. Use clocksource=3Dxyz
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
PID hash table entries: 1024 (order: 10, 8192 bytes)
Console: colour VGA+ 80x25
Placing software IO TLB between 0x148fc000 - 0x188fc000
Memory: 110912k/244032k available (3297k code, 146528k reserved, 2286k data=
, 640k init)
put_kernel_page: page at 0xe000000010484000 not in reserved memory
put_kernel_page: page at 0xe000000010484000 not in reserved memory
put_kernel_page: page at 0xe00000001047c000 not in reserved memory
put_kernel_page: page at 0xe00000001047c000 not in reserved memory
put_kernel_page: page at 0xe00000001047c000 not in reserved memory
put_kernel_page: page at 0xe00000001047c000 not in reserved memory
put_kernel_page: page at 0xe00000001047c000 not in reserved memory
put_kernel_page: page at 0xe00000001047c000 not in reserved memory
McKinley Errata 9 workaround not needed; disabling it
Dentry cache hash table entries: 32768 (order: 4, 262144 bytes)
Inode-cache hash table entries: 16384 (order: 3, 131072 bytes)
Mount-cache hash table entries: 1024
ACPI: Core revision 20060707
Boot processor id 0x0/0x100
Brought up 1 CPUs
Total of 1 processors activated (1941.50 BogoMIPS).
migration_cost=3D0
checking if image is initramfs... it is
Freeing initrd memory: 10480kB freed
DMI 2.3 present.
ACPI: bus type pci registered
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI quirk: region 0c00-0c7f claimed by ICH4 ACPI/GPIO/TCO
PCI quirk: region 0500-053f claimed by ICH4 GPIO
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
ACPI: PCI Root Bridge [PCI1] (0000:02)
ACPI: PCI Root Bridge [PCI2] (0000:05)
ACPI: Device [CSFF] status [00000008]: functional but not present; setting =
present
ACPI: PCI Root Bridge [CSFF] (0000:ff)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 12 devices
SCSI subsystem initialized
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
io scheduler noop registered
io scheduler anticipatory registered (default)
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
00:08: ttyS0 at I/O 0x3f8 (irq =3D 44) is a 16550A
00:09: ttyS1 at I/O 0x2f8 (irq =3D 45) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
Adding console on ttyS1 at I/O port 0x2f8 (options '115200n8')
Bad page state in process 'swapper'
page:a0007ffffff23598 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff235d0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23608 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23640 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23678 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff236b0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff236e8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23720 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23758 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23790 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff237c8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23800 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23838 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23870 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff238a8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff238e0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23918 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23950 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23988 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff239c0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff239f8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23a30 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23a68 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23aa0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23ad8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23b10 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23b48 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23b80 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23bb8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23bf0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23c28 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23c60 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23c98 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23cd0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23d08 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23d40 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23d78 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23db0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23de8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23e20 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f16c0>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f2940>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a0000001000603c0>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Freeing unused kernel memory: 640kB freed
Bad page state in process 'init'
page:a0007ffffff23ec8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a000000100012a10>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439528
 [<a000000100012a90>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439510
 [<a0000001000efaa0>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f4394e0
 [<a0000001000f1360>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f4394a0
 [<a0000001000f1630>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439480
 [<a0000001000f8830>] put_page+0x1b0/0x1e0
                                sp=E00000001f43fda0 bsp=E00000001f439450
 [<a000000100108c50>] do_wp_page+0x8f0/0x9c0
                                sp=E00000001f43fda0 bsp=E00000001f4393d0
 [<a00000010010af80>] __handle_mm_fault+0xe00/0xf00
                                sp=E00000001f43fda0 bsp=E00000001f439348
 [<a000000100060e40>] ia64_do_page_fault+0x1c0/0x8e0
                                sp=E00000001f43fda0 bsp=E00000001f4392e8
 [<a00000010000ca20>] ia64_leave_kernel+0x0/0x280
                                sp=E00000001f43fe30 bsp=E00000001f4392e8
init started:  BusyBox v1.2.1 (2006.09.23-05:46+0000) multi-call binary
Starting pid 776, console /dev/console: '/etc/init.d/rcS'
ifconfig: socket: Function not implemented
ifconfig: No usable address families found.
ifconfig: socket: Function not implemented
Starting pid 948, console /dev/console: '/bin/sh'


BusyBox v1.2.1 (2006.09.23-05:46+0000) Built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ #=20

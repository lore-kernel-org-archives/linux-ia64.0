From: Horms <horms@verge.net.au>
Date: Thu, 26 Oct 2006 07:59:54 +0000
Subject: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061026075951.GA30910@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

After doing a bit of research it seems that ia64 kdump is broken
by 05e0caad3b7bd0d0fbeff980bca22f186241a501, which appeared between
2.6.18 and 2.6.19-rc3. I can be more specific about the version if
need be, but here is the commit log from Linus' tree.

    commit 05e0caad3b7bd0d0fbeff980bca22f186241a501
    tree d213789aca5bf91b74bbf5946d428590e3e368b1
    parent 5cb248abf5ab65ab543b2d5fc16c738b28031fc0
    author Mel Gorman <mel@csn.ul.ie> 1159346994 -0700
    committer Linus Torvalds <torvalds@g5.osdl.org> 1159370771 -0700

    [PATCH] Have ia64 use add_active_range() and free_area_init_nodes

    Size zones and holes in an architecture independent manner for ia64.
   =20
    [bob.picco@hp.com: fix ia64 FLATMEM+VIRTUAL_MEM_MAP]
    Signed-off-by: Mel Gorman <mel@csn.ul.ie>
    Signed-off-by: Bob Picco <bob.picco@hp.com>
    Cc: Dave Hansen <haveblue@us.ibm.com>
    Cc: Andy Whitcroft <apw@shadowen.org>
    Cc: Andi Kleen <ak@muc.de>
    Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
    Cc: Paul Mackerras <paulus@samba.org>
    Cc: "Keith Mannthey" <kmannth@gmail.com>
    Cc: "Luck, Tony" <tony.luck@intel.com>
    Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
    Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
    Signed-off-by: Bob Picco <bob.picco@hp.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

Kdump is not currently in Linus' tree. But it is in the test
branch of Tony Luck's linux-2.6 git tree, on www.kernel.org.

You can also find an archive of the available patches=20
at http://www.vergenet.net/~horms/patches/ia64-kexec/kernel/
Though you will need to do some minor porting to get them=20
to apply to 05e0caad3b7bd0d0fbeff980bca22f186241a501.
I have been using patch 8 from this archive.

Below is a log of the first kernel booting successfully,
then the second kernel having a bit of difficulty.
Going from 05e0caad3b7bd0d0fbeff980bca22f186241a501 to the
previous revision in Linus' tree,
5cb248abf5ab65ab543b2d5fc16c738b28031fc0, makes this problem
go a way.

I have not had a chance to analyse the problem further than this.
And as of sending this email I will be off-line for a few days.
But I will be more than happy to investigate further or provide
additional information when I get back. Any pointers would
be greatly appreciated.

--=20
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

Starting: Network Boot/Pci(4|1|0)/Mac(000E0C9FA3AE)
ELILO
Uncompressing Linux... done
Loading initrd people/horms/initramfs_data.cpio.gz...done
Linux version 2.6.18-kexec-g05e0caad-dirty (horms@tabatha.lab.ultramonkey.o=
rg) (gcc version 3.4.5) #30 SMP Thu Oct 26 16:43:01 JST 2006
EFI v1.10 by INTEL: SALsystab=3D0x7fe54980 ACPI=3D0x7ff99000 ACPI 2.0=3D0x7=
ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200')
Initial ramdisk at: 0xe00000007af65000 (9838614 bytes)
SAL 3.20: Intel Corp                       SR870BH2                        =
 version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
No logical to physical processor mapping available
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
Kernel command line: BOOT_IMAGE=3Dnet0:ia64/people/horms/vmlinux.gz  phys_e=
fi maxcpus=3D1 console=3Duart,io,0x2f8,115200 crashkernel%6M ro
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
Starting pid 894, console /dev/console: '/bin/sh'


BusyBox v1.2.1 (2006.09.23-05:46+0000) Built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ #=20
/ # do_kdump=20
XEN=3D"" KDUMP=3D"yes"
ARCH=3D"ia64" KARCH=3D"ia64" UARCH=3D"ia64"
IMAGE=3D"vmlinux-ia64-kdump.gz" XEN_IMAGE=3D"xen-ia64.gz"
Create ramdisk
Load kernel and ramdisk
Kdump
SysRq : Trigger a crashdump
Linux version 2.6.18-kexec-g05e0caad-dirty (horms@tabatha.lab.ultramonkey.o=
rg) (gcc version 3.4.5) #30 SMP Thu Oct 26 16:43:01 JST 2006
Ignoring memory below 256MB
Ignoring memory above 512MB
EFI v1.10 by INTEL: SALsystab=3D0x7fe54980 ACPI=3D0x7ff99000 ACPI 2.0=3D0x7=
ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200n8')
Initial ramdisk at: 0xe00000001f580000 (10739712 bytes)
SAL 3.20: Intel Corp                       SR870BH2                        =
 version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
No logical to physical processor mapping available
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
rg) (gcc version 3.4.5) #30 SMP Thu Oct 26 16:43:01 JST 2006
Ignoring memory below 256MB
Ignoring memory above 512MB
EFI v1.10 by INTEL: SALsystab=3D0x7fe54980 ACPI=3D0x7ff99000 ACPI 2.0=3D0x7=
ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200n8')
Initial ramdisk at: 0xe00000001f580000 (10739712 bytes)
SAL 3.20: Intel Corp                       SR870BH2                        =
 version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
No logical to physical processor mapping available
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
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff235d0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23608 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23640 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23678 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff236b0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff236e8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23720 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23758 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23790 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff237c8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23800 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23838 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23870 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff238a8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff238e0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23918 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23950 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23988 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff239c0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff239f8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23a30 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23a68 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23aa0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23ad8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23b10 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23b48 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23b80 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23bb8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23bf0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23c28 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23c60 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23c98 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23cd0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23d08 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23d40 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23d78 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23db0 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23de8 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000001f43fe30 bsp=E00000001f438ff0
Bad page state in process 'swapper'
page:a0007ffffff23e20 flags:0x0000000000000000 mapping:0000000000000000 map=
count:1 count:0
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439188
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439170
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f439140
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f439100
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f4390e0
 [<a0000001000f1660>] __free_pages+0x60/0xa0
                                sp=E00000001f43fda0 bsp=E00000001f4390b8
 [<a0000001000f28e0>] free_pages+0x60/0x80
                                sp=E00000001f43fda0 bsp=E00000001f439090
 [<a000000100060360>] free_initmem+0x160/0x200
                                sp=E00000001f43fda0 bsp=E00000001f439060
 [<a000000100009fd0>] init+0x610/0x800
                                sp=E00000001f43fdb0 bsp=E00000001f439020
 [<a000000100014e30>] kernel_thread_helper+0xd0/0x100
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
 [<a0000001000129d0>] show_stack+0x50/0xa0
                                sp=E00000001f43fbd0 bsp=E00000001f439528
 [<a000000100012a50>] dump_stack+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439510
 [<a0000001000efa40>] bad_page+0xa0/0x120
                                sp=E00000001f43fda0 bsp=E00000001f4394e0
 [<a0000001000f1300>] free_hot_cold_page+0x100/0x300
                                sp=E00000001f43fda0 bsp=E00000001f4394a0
 [<a0000001000f15d0>] free_hot_page+0x30/0x60
                                sp=E00000001f43fda0 bsp=E00000001f439480
 [<a0000001000f87d0>] put_page+0x1b0/0x1e0
                                sp=E00000001f43fda0 bsp=E00000001f439450
 [<a000000100108bf0>] do_wp_page+0x8f0/0x9c0
                                sp=E00000001f43fda0 bsp=E00000001f4393d0
 [<a00000010010af20>] __handle_mm_fault+0xe00/0xf00
                                sp=E00000001f43fda0 bsp=E00000001f439348
 [<a000000100060de0>] ia64_do_page_fault+0x1c0/0x8e0
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

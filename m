From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Aug 2018 16:20:27 +0000
Subject: Re: [PATCH 0/5] System call table generation support
Message-Id: <20180810162026.GA14287@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1533791115-3681-1-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1533791115-3681-1-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Firoz Khan <firoz.khan@linaro.org>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, y2038@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, deepa.kernel@gmail.com, marcin.juszkiewicz@linaro.org

On Thu, Aug 09, 2018 at 10:35:10AM +0530, Firoz Khan wrote:
> The purpose of this patch series is:
> 1. We can easily add/modify/delete system call by changing entry=20
> in syscall.tbl file. No need to manually edit many files.

I tried applying this to latest upstream as it was yesterday
HEAD =3D fedb8da96355f5f64 ("parisc: Define mb() and add memory barriers to=
 assembler unlock sequences")

it built with no errors, but does not boot.  Init dies, so may be an
issue with not being able to make a system call???

Serial console log below.

-Tony


Linux version 4.18.0-rc8-generic-smp-9-g3484b4f4d494 (aegl@linux-bxb1) (gcc=
 version 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux)) #1 SMP Thu Au=
g 9 10:42:37 PDT 2018
EFI v2.10 by EDK II:
efi:  SALsystab=3D0x3e81e418  ACPI 2.0=3D0x3da42014  SMBIOS=3D0x3a3af000=20
booting generic kernel on platform dig
earlycon: uart0 at I/O port 0x3f8 (options '')
bootconsole [uart0] enabled
ACPI: Early table checksum verification disabled
ACPI: RSDP 0x000000003DA42014 000024 (v02 INTEL )
ACPI: XSDT 0x000000003DA42120 00004C (v01 INTEL  BXBIOH   00000002      010=
00013)
ACPI: FACP 0x000000003A3D2000 0000F4 (v04 INTEL  BXBIOH   00000002      000=
00000)
ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/PmTimerBlock: 32/24=
 (20180531/tbfadt-569)
ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe0Block: 128/64 (=
20180531/tbfadt-569)
ACPI BIOS Warning (bug): Invalid length for FADT/PmTimerBlock: 24, using de=
fault 32 (20180531/tbfadt-674)
ACPI: DSDT 0x000000003A3B0000 019928 (v01 INTEL  BXBIOH   00000002 INTL 200=
80926)
ACPI: FACS 0x000000003A4EA000 000040
ACPI: FACS 0x000000003A4EA000 000040
ACPI: APIC 0x000000003A3D0000 0002D0 (v01 INTEL  BXBIOH   00000002      000=
00000)
ACPI: SLIT 0x000000003A3CE000 00003C (v01 INTEL  BXBIOH   00000002      000=
00000)
ACPI: SPCR 0x000000003A3CC000 000050 (v01 INTEL  BXBIOH   00000002      000=
00000)
ACPI: SRAT 0x000000003A3CA000 000550 (v01 INTEL  BXBIOH   00000002      000=
00000)
ia64_native_iosapic_pcat_compat_init: Disabling PC-AT compatible 8259 inter=
rupts
ACPI: Local APIC address (____ptrval____)
32 CPUs available, 32 CPUs total
Number of logical nodes in system =3D 1
Number of memory chunks in system =3D 3
SMP: Allowing 32 CPUs, 0 hotplug CPUs
Initial ramdisk at: 0xe0000004faad3000 (5048585 bytes)
SAL 3.20:  version 0.0
SAL: AP wakeup using external interrupt vector 0xf0
MCA related initialization done
Virtual mem_map starts at 0x(____ptrval____)
Zone ranges:
  DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
  Normal   [mem 0x0000000100000000-0x00000004fbffffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x0000000001000000-0x000000003a39ffff]
  node   0: [mem 0x000000003a3e0000-0x000000003a4dffff]
  node   0: [mem 0x000000003a540000-0x000000003a59ffff]
  node   0: [mem 0x000000003a6c0000-0x000000003a6dffff]
  node   0: [mem 0x000000003a780000-0x000000003ac3ffff]
  node   0: [mem 0x000000003acb0000-0x000000003ad4ffff]
  node   0: [mem 0x000000003ad70000-0x000000003ad8ffff]
  node   0: [mem 0x000000003adb0000-0x000000003adcffff]
  node   0: [mem 0x000000003ae40000-0x000000003ae4ffff]
  node   0: [mem 0x000000003ae60000-0x000000003ae7ffff]
  node   0: [mem 0x000000003b280000-0x000000003b2dffff]
  node   0: [mem 0x000000003b2f0000-0x000000003b39ffff]
  node   0: [mem 0x000000003b3c0000-0x000000003b92ffff]
  node   0: [mem 0x000000003b960000-0x000000003b97ffff]
  node   0: [mem 0x000000003c0f0000-0x000000003c15ffff]
  node   0: [mem 0x000000003c180000-0x000000003c20ffff]
  node   0: [mem 0x000000003c230000-0x000000003c7dffff]
  node   0: [mem 0x000000003c7f0000-0x000000003c88ffff]
  node   0: [mem 0x000000003c8b0000-0x000000003c8bffff]
  node   0: [mem 0x000000003c8e0000-0x000000003ca4ffff]
  node   0: [mem 0x000000003ca60000-0x000000003caaffff]
  node   0: [mem 0x000000003cac0000-0x000000003cc7ffff]
  node   0: [mem 0x000000003cc90000-0x000000003cdcffff]
  node   0: [mem 0x000000003cde0000-0x000000003ce2ffff]
  node   0: [mem 0x000000003ce40000-0x000000003d9effff]
  node   0: [mem 0x000000003da00000-0x000000003da3ffff]
  node   0: [mem 0x000000003da50000-0x000000003e7fffff]
  node   0: [mem 0x000000003e820000-0x000000003f8cffff]
  node   0: [mem 0x000000003fdd0000-0x000000003fdeffff]
  node   0: [mem 0x0000000100000000-0x00000003ffffffff]
  node   0: [mem 0x0000000440000000-0x00000004faf9ffff]
  node   0: [mem 0x00000004fb010000-0x00000004fb0bffff]
  node   0: [mem 0x00000004fb0d0000-0x00000004fbffffff]
Initmem setup node 0 [mem 0x0000000001000000-0x00000004fbffffff]
Built 1 zonelists, mobility grouping on.  Total pages: 260199
Policy zone: Normal
Kernel command line: BOOT_IMAGE=3Dscsi0:\efi\SuSE\l-generic-smp.gz  console=
=3Dtty1 console=3Duart,io,0x3f8 intel_iommu=3Doff root=3D/dev/sda3
DMAR: IOMMU disabled
Sorting __ex_table...
software IO TLB [mem 0x060a0000-0x0a0a0000] (64MB) mapped at [(____ptrval__=
__)-(____ptrval____)]
Memory: 16541952K/16670656K available (15088K kernel code, 6042K rwdata, 20=
28K rodata, 1216K init, 7091K bss, 128704K reserved, 0K cma-reserved)
SLUB: HWalign=128, Order=3D0-3, MinObjects=3D0, CPUs2, Nodes=1024
Hierarchical RCU implementation.
	RCU event tracing is enabled.
	RCU restricting CPUs from NR_CPUS@96 to nr_cpu_ids2.
RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids2
NR_IRQS: 1024
ia64_native_iosapic_pcat_compat_init: Disabling PC-AT compatible 8259 inter=
rupts
ACPI: Local APIC address (____ptrval____)
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0000) vector 30
PLATFORM int PMI (0x1): GSI 23 (edge, low) -> CPU 0 (0x0000) vector 0
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level

clocksource: itc: mask: 0xffffffffffffffff max_cycles: 0xb881274fa3, max_id=
le_ns: 440795210636 ns
Console: colour VGA+ 80x25
console [tty1] enabled
ACPI: Core revision 20180531
Calibrating delay loop... 3641.34 BogoMIPS (lpjr82688)
pid_max: default: 32768 minimum: 301
Dentry cache hash table entries: 2097152 (order: 8, 16777216 bytes)
Inode-cache hash table entries: 1048576 (order: 7, 8388608 bytes)
Mount-cache hash table entries: 32768 (order: 2, 262144 bytes)
Mountpoint-cache hash table entries: 32768 (order: 2, 262144 bytes)
Boot processor id 0x0/0x0
Hierarchical SRCU implementation.
smp: Bringing up secondary CPUs ...
Fixed BSP b0 value from CPU 1
CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 61 cycles)

CPU 2: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 671 cycles)

CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 667 cycles)

CPU 4: synchronized ITC with CPU 0 (last diff 2 cycles, maxerr 670 cycles)

CPU 5: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 667 cycles)

CPU 6: synchronized ITC with CPU 0 (last diff 2 cycles, maxerr 671 cycles)

CPU 7: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 666 cycles)

CPU 8: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 756 cycles)

CPU 9: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 751 cycles)

CPU 10: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 758 cycles)

CPU 11: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 751 cycles)

CPU 12: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 757 cycles)

CPU 13: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 752 cycles)

CPU 14: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 758 cycles)

CPU 15: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 752 cycles)

CPU 16: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 713 cycles)

CPU 17: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 706 cycles)

CPU 18: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 712 cycles)

CPU 19: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 706 cycles)

CPU 20: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 708 cycles)

CPU 21: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 706 cycles)

CPU 22: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 708 cycles)

CPU 23: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 706 cycles)

CPU 24: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 765 cycles)

CPU 25: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 758 cycles)

CPU 26: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 764 cycles)

CPU 27: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 758 cycles)

CPU 28: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 763 cycles)

CPU 29: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 758 cycles)

CPU 30: synchronized ITC with CPU 0 (last diff -3 cycles, maxerr 768 cycles)

CPU 31: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 758 cycles)

smp: Brought up 1 node, 32 CPUs
Total of 32 processors activated (116523.00 BogoMIPS).
random: fast init done
random: get_random_u32 called from bucket_table_alloc+0x100/0x2e0 with crng=
_init=3D1
SMBIOS 2.4 present.
DMI: Supermicro I8QBH/I8QBH, BIOS I8QBH 15.006.004RAS 2010/05/10
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns:=
 7645041785100000 ns
futex hash table entries: 8192 (order: 4, 1048576 bytes)
NET: Registered protocol family 16
ACPI: bus type PCI registered
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
HugeTLB registered 256 MiB page size, pre-allocated 0 pages
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: Added _OSI(Linux-Dell-Video)
ACPI: 1 ACPI AML tables successfully acquired and loaded
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOSAPIC for interrupt routing
ACPI: Enabled 11 GPEs in block 00 to 3F
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-7f])
acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig Segments MSI]
acpi PNP0A08:00: PCIe port services disabled; not requesting _OSC control
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
pci_bus 0000:00: root bus resource [io  0x1000-0x8fff window]
pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000fffff]
pci_bus 0000:00: root bus resource [mem 0xfec00000-0xfec3ffff]
pci_bus 0000:00: root bus resource [mem 0xfed1c000-0xfed1c0ff]
pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedfffff]
pci_bus 0000:00: root bus resource [mem 0x50000000-0x9fffffff window]
pci_bus 0000:00: root bus resource [mem 0x10000000000-0x100fffffffe]
pci_bus 0000:00: root bus resource [mem 0x10100000000-0x101fffffffe]
pci_bus 0000:00: root bus resource [mem 0x10200000000-0x102fffffffe]
pci_bus 0000:00: root bus resource [mem 0x10300000000-0x103fffffffe]
pci_bus 0000:00: root bus resource [bus 00-7f]
pci 0000:00:01.0: enabling Extended Tags
pci 0000:00:03.0: enabling Extended Tags
pci 0000:00:05.0: enabling Extended Tags
pci 0000:00:07.0: enabling Extended Tags
pci 0000:00:01.0: PCI bridge to [bus 01]
pci 0000:01:00.0: can't claim BAR 6 [mem 0xfffe0000-0xffffffff pref]: no co=
mpatible bridge window
pci 0000:01:00.1: can't claim BAR 6 [mem 0xfffe0000-0xffffffff pref]: no co=
mpatible bridge window
pci 0000:00:03.0: PCI bridge to [bus 02]
pci 0000:03:00.0: enabling Extended Tags
pci 0000:00:05.0: PCI bridge to [bus 03]
pci 0000:03:00.0: can't claim BAR 6 [mem 0xffe00000-0xffffffff pref]: no co=
mpatible bridge window
pci 0000:00:07.0: PCI bridge to [bus 04]
pci 0000:00:1c.0: PCI bridge to [bus 05]
pci 0000:00:1c.1: PCI bridge to [bus 06]
pci 0000:00:1c.2: PCI bridge to [bus 07]
pci 0000:00:1c.3: PCI bridge to [bus 08]
pci 0000:00:1c.4: PCI bridge to [bus 09]
pci 0000:00:1c.5: PCI bridge to [bus 0a]
pci_bus 0000:0b: extended config space not accessible
pci 0000:00:1e.0: PCI bridge to [bus 0b] (subtractive decode)
pci 0000:0b:04.0: can't claim BAR 6 [mem 0xfffe0000-0xffffffff pref]: no co=
mpatible bridge window
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 *6 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 80-ff])
acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig Segments MSI]
acpi PNP0A08:01: PCIe port services disabled; not requesting _OSC control
PCI host bridge to bus 0000:80
pci_bus 0000:80: root bus resource [io  0x9000-0xffff window]
pci_bus 0000:80: root bus resource [mem 0xfec40000-0xfec7ffff]
pci_bus 0000:80: root bus resource [mem 0xa0000000-0xefffffff]
pci_bus 0000:80: root bus resource [mem 0x10400000000-0x104fffffffe]
pci_bus 0000:80: root bus resource [mem 0x10500000000-0x105fffffffe]
pci_bus 0000:80: root bus resource [mem 0x10600000000-0x106fffffffe]
pci_bus 0000:80: root bus resource [mem 0x10700000000-0x107fffffffe]
pci_bus 0000:80: root bus resource [bus 80-ff]
pci 0000:80:01.0: enabling Extended Tags
pci 0000:80:03.0: enabling Extended Tags
pci 0000:80:05.0: enabling Extended Tags
pci 0000:80:07.0: enabling Extended Tags
acpiphp: Slot [0] registered
pci 0000:80:01.0: PCI bridge to [bus 81]
pci 0000:81:00.0: can't claim BAR 6 [mem 0xfffe0000-0xffffffff pref]: no co=
mpatible bridge window
pci 0000:81:00.1: can't claim BAR 6 [mem 0xfffe0000-0xffffffff pref]: no co=
mpatible bridge window
acpiphp: Slot [0-1] registered
pci 0000:80:03.0: PCI bridge to [bus 82]
acpiphp: Slot [0-2] registered
pci 0000:83:00.0: enabling Extended Tags
pci 0000:80:05.0: PCI bridge to [bus 83]
pci 0000:83:00.0: can't claim BAR 6 [mem 0xffe00000-0xffffffff pref]: no co=
mpatible bridge window
acpiphp: Slot [0-3] registered
pci 0000:80:07.0: PCI bridge to [bus 84]
pci 0000:0b:04.0: vgaarb: setting as boot VGA device
pci 0000:0b:04.0: vgaarb: VGA device added: decodes=3Dio+mem,owns=3Dio+mem,=
locks=3Dnone
pci 0000:0b:04.0: vgaarb: bridge control possible
vgaarb: loaded
SCSI subsystem initialized
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giome=
tti@linux.it>
PTP clock support registered
Registered efivars operations
random: crng init done
clocksource: Switched to clocksource itc
pnp: PnP ACPI init
system 00:01: [io  0x0500-0x053f] has been reserved
system 00:01: [io  0x0400-0x047f] has been reserved
system 00:01: [io  0x0800-0x081f] has been reserved
system 00:01: [mem 0xfed1c000-0xfed8bffe] could not be reserved
system 00:01: [mem 0xff000000-0xffffffff] has been reserved
system 00:01: [mem 0xfee00000-0xfeefffff] has been reserved
system 00:01: [mem 0xfea00000-0xfea0001f] has been reserved
system 00:01: [mem 0xfed1b000-0xfed1bfff] has been reserved
pnp: PnP ACPI: found 4 devices
NET: Registered protocol family 2
tcp_listen_portaddr_hash hash table entries: 8192 (order: 1, 131072 bytes)
TCP established hash table entries: 131072 (order: 4, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
UDP hash table entries: 8192 (order: 2, 262144 bytes)
UDP-Lite hash table entries: 8192 (order: 2, 262144 bytes)
NET: Registered protocol family 1
GSI 16 (level, low) -> CPU 0 (0x0000) vector 49
GSI 16 (level, low) -> CPU 0 (0x0000) vector 49 unregistered
pci 0000:00:1a.0: quirk_usb_early_handoff+0x0/0x360 took 10857 usecs
GSI 17 (level, low) -> CPU 1 (0x0100) vector 49
GSI 17 (level, low) -> CPU 1 (0x0100) vector 49 unregistered
pci 0000:00:1a.1: quirk_usb_early_handoff+0x0/0x360 took 10689 usecs
GSI 18 (level, low) -> CPU 2 (0x0200) vector 49
GSI 18 (level, low) -> CPU 2 (0x0200) vector 49 unregistered
pci 0000:00:1a.2: quirk_usb_early_handoff+0x0/0x360 took 10682 usecs
GSI 18 (level, low) -> CPU 3 (0x0300) vector 49
GSI 18 (level, low) -> CPU 3 (0x0300) vector 49 unregistered
pci 0000:00:1a.7: quirk_usb_early_handoff+0x0/0x360 took 10698 usecs
GSI 16 (level, low) -> CPU 4 (0x0400) vector 49
GSI 16 (level, low) -> CPU 4 (0x0400) vector 49 unregistered
pci 0000:00:1d.0: quirk_usb_early_handoff+0x0/0x360 took 10697 usecs
GSI 17 (level, low) -> CPU 5 (0x0500) vector 49
GSI 17 (level, low) -> CPU 5 (0x0500) vector 49 unregistered
pci 0000:00:1d.1: quirk_usb_early_handoff+0x0/0x360 took 10686 usecs
GSI 18 (level, low) -> CPU 6 (0x0600) vector 49
GSI 18 (level, low) -> CPU 6 (0x0600) vector 49 unregistered
pci 0000:00:1d.2: quirk_usb_early_handoff+0x0/0x360 took 10696 usecs
GSI 16 (level, low) -> CPU 7 (0x0700) vector 49
GSI 16 (level, low) -> CPU 7 (0x0700) vector 49 unregistered
pci 0000:00:1d.7: quirk_usb_early_handoff+0x0/0x360 took 10690 usecs
pci 0000:0b:04.0: Video device with shadowed ROM at [mem 0x000c0000-0x000df=
fff]
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 4864kB freed
PAL Information Facility v0.5
workingset: timestamp_bitsR max_order=18 bucket_order=3D0
SGI XFS with security attributes, no debug enabled
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
io scheduler mq-deadline registered
io scheduler kyber registered
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
00:02: ttyS0 at I/O 0x3f8 (irq =3D 44, base_baud =3D 115200) is a 16550A
console [ttyS0] enabled
console [ttyS0] enabled
bootconsole [uart0] disabled
bootconsole [uart0] disabled
00:03: ttyS1 at I/O 0x2f8 (irq =3D 45, base_baud =3D 115200) is a 16550A
EFI Time Services Driver v0.4
brd: module loaded
Uniform Multi-Platform E-IDE driver
ide-gd driver 1.18
ide-cd driver 5.00
GSI 17 (level, low) -> CPU 8 (0x1000) vector 49
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
scsi host0: ata_piix
scsi host1: ata_piix
ata1: SATA max UDMA/133 cmd 0x4138 ctl 0x414c bmdma 0x4110 irq 50
ata2: SATA max UDMA/133 cmd 0x4130 ctl 0x4148 bmdma 0x4118 irq 50
ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
scsi host2: ata_piix
scsi host3: ata_piix
ata3: SATA max UDMA/133 cmd 0x4128 ctl 0x4144 bmdma 0x40f0 irq 50
ata4: SATA max UDMA/133 cmd 0x4120 ctl 0x4140 bmdma 0x40f8 irq 50
e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
e1000: Copyright (c) 1999-2006 Intel Corporation.
igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
igb: Copyright (c) 2007-2014 Intel Corporation.
GSI 28 (level, low) -> CPU 9 (0x1100) vector 50
igb 0000:01:00.0: added PHC on eth0
igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:30:48:fe:19:3a
igb 0000:01:00.0: eth0: PBA No: Unknown
igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
GSI 40 (level, low) -> CPU 10 (0x1200) vector 60
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata2.00: SATA link down (SStatus 0 SControl 300)
ata2.01: SATA link down (SStatus 0 SControl 300)
igb 0000:01:00.1: added PHC on eth1
igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
ata1.00: SATA link down (SStatus 0 SControl 300)
igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:30:48:fe:19:3b
ata1.01: SATA link down (SStatus 0 SControl 300)
igb 0000:01:00.1: eth1: PBA No: Unknown
igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
GSI 52 (level, low) -> CPU 11 (0x1300) vector 70
igb 0000:81:00.0: added PHC on eth2
igb 0000:81:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:81:00.0: eth2: (PCIe:2.5Gb/s:Width x4) 00:30:48:fe:19:b0
igb 0000:81:00.0: eth2: PBA No: Unknown
igb 0000:81:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
GSI 64 (level, low) -> CPU 12 (0x1400) vector 80
igb 0000:81:00.1: added PHC on eth3
igb 0000:81:00.1: Intel(R) Gigabit Ethernet Network Connection
igb 0000:81:00.1: eth3: (PCIe:2.5Gb/s:Width x4) 00:30:48:fe:19:b1
igb 0000:81:00.1: eth3: PBA No: Unknown
igb 0000:81:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
Fusion MPT base driver 3.04.20
Copyright (c) 1999-2008 LSI Corporation
Fusion MPT SPI Host driver 3.04.20
Fusion MPT SAS Host driver 3.04.20
GSI 26 (level, low) -> CPU 13 (0x1500) vector 90
mptbase: ioc0: Initiating bringup
ioc0: LSISAS1068E B3: Capabilities=3D{Initiator}
scsi host4: ioc0: LSISAS1068E B3, FwRev=011a0000h, Ports=3D1, MaxQG8, IRQ=92
mptsas: ioc0: attaching ssp device: fw_channel 0, fw_id 6, phy 6, sas_addr =
0x5000c5000ecb8f49
scsi 4:0:0:0: Direct-Access     SEAGATE  ST9146802SS      0003 PQ: 0 ANSI: 5
GSI 50 (level, low) -> CPU 14 (0x1600) vector 91
sd 4:0:0:0: [sda] 286749488 512-byte logical blocks: (147 GB/137 GiB)
mptbase: ioc1: Initiating bringup
sd 4:0:0:0: [sda] Write Protect is off
sd 4:0:0:0: [sda] Write cache: enabled, read cache: enabled, supports DPO a=
nd FUA
 sda: sda1 sda2 sda3
sd 4:0:0:0: [sda] Attached SCSI disk
ioc1: LSISAS1068E B3: Capabilities=3D{Initiator}
scsi host5: ioc1: LSISAS1068E B3, FwRev=011a0000h, Ports=3D1, MaxQG8, IRQ=93
mptsas: ioc1: attaching ssp device: fw_channel 0, fw_id 6, phy 6, sas_addr =
0x5000c5000ecada69
scsi 5:0:0:0: Direct-Access     SEAGATE  ST9146802SS      0003 PQ: 0 ANSI: 5
EFI Variables Facility v0.08 2004-May-17
sd 5:0:0:0: [sdb] 286749488 512-byte logical blocks: (147 GB/137 GiB)
sd 5:0:0:0: [sdb] Write Protect is off
sd 5:0:0:0: [sdb] Write cache: enabled, read cache: enabled, supports DPO a=
nd FUA
 sdb: sdb1 sdb2
sd 5:0:0:0: [sdb] Attached SCSI disk
NET: Registered protocol family 17
console [netcon0] enabled
netconsole: network logging started
Freeing unused kernel memory: 1216K
This architecture does not have kernel memory protection.
doing fast boot
Kernel panic - not syncing: Attempted to kill init! exitcode=3D0x0000000b

---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=3D0x0=
000000b
 ]---

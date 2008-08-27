From: "jidong xiao" <jidong.xiao@gmail.com>
Date: Wed, 27 Aug 2008 10:54:25 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <4104961b0808270354y267145e7l637b70ee4c8a384a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
	<20080827112728.51024582@halley.suse.de>
	<4104961b0808270251n1e7250dbn656ae77d2f8bc3d3@mail.gmail.com>
	<20080827121443.396d8bac@halley.suse.de>
In-Reply-To: <20080827121443.396d8bac@halley.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bernhard Walle <bwalle@suse.de>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org

On Wed, Aug 27, 2008 at 6:14 PM, Bernhard Walle <bwalle@suse.de> wrote:
> * jidong xiao [2008-08-27 17:51]:
>>
>> On Wed, Aug 27, 2008 at 5:27 PM, Bernhard Walle <bwalle@suse.de> wrote:
>> > Hi Jidong,
>> >
>> > * jidong xiao [2008-08-27 17:01]:
>> >>
>> >> I encountered the zero-size-vmcore issue on IA64. I remember last year
>> >> Nanhai submitted a patch which was intended to fix this issue, and I
>> >> noticed that patch is merged into mainline kernel. I am using
>> >> 2.6.27-rc2, which means that patch is included in my kernel.And after
>> >> the system
>> >> completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
>> >> me know if I need to provide more information.Thanks.
>> >
>> > Which version of kexec-tools do you use?
>> >
>> Well I am using SLES10SP2,(I tried the experiments on SLES10SP2
>> default kernel and also 2.6.27-rc2 mainline kernel, result is the
>> same.)
>
> With the SP2 default kernel, it should work. At lest /proc/vmcore
> should have a normal size. Can you set KDUMP_IMMEDIATE_REBOOT to "no",
> then log in in the serial console and execute
>
>        # ls -l /proc/vmcore
I am sorry to say, I tried to follow your instruction but finally the
out put is zero.
lfg-ia64:~ # ls -l /proc/vmcore
-r-------- 1 root root 0 2008-08-27 18:40 /proc/vmcore

>
> For 2.6.27 kernel on IA64, you have to update kexec-tools. I don't know
> the exact version when the change was included, but 2.0.0 is safe. :)
>
Okay I will try to update kexec-tools and do the experiment again then
report it.

In addition following I attached the dmesg info, among other things, I
saw one message: "Cannot locate EFI vmcore descriptor", this probably
implies that something is wrong, though I have no idea.

lfg-ia64:~ # dmesg
Linux version 2.6.27-rc2-test (root@lfg-ia64) (gcc version 4.1.2
20070115 (SUSE Linux)) #8 SMP Wed Aug 27 13:54:51 CST 2008
Ignoring memory below 256MB
Ignoring memory above 512MB
EFI v1.10 by INTEL: SALsystab=3D0x7fe4c8c0 ACPI=3D0x7ff99000 ACPI
2.0=3D0x7ff98000 MPS=3D0x7ff97000 SMBIOS=3D0xf0000
booting generic kernel on platform dig
ACPI: RSDP 7FF98000, 0024 (r2 INTEL )
ACPI: XSDT 7FF98090, 003C (r1 INTEL  SR870BH2  1072002 MSFT    10013)
ACPI: FACP 7FF98138, 00F4 (r3 INTEL  SR870BH2  1072002 MSFT    10013)
ACPI: DSDT 7FF9A000, 292B (r1  Intel SR870BH2        0 MSFT  100000D)
ACPI: FACS 7FF982E0, 0040
ACPI: APIC 7FF98230, 00AE (r1 INTEL  SR870BH2  1072002 MSFT    10013)
ACPI: SPCR 7FF98328, 0050 (r1 INTEL  SR870BH2  1072002 MSFT    10013)
Cannot locate EFI vmcore descriptor
Initial ramdisk at: 0xe00000001f598000 (10617709 bytes)
SAL 3.1: Intel Corp                       SR870BH2
    version 3.0
SAL Platform features: BusLock
SAL: AP wakeup using external interrupt vector 0xf0
TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should
be extended
ia64_native_iosapic_pcat_compat_init: Disabling PC-AT compatible 8259 inter=
rupts
ACPI: Local APIC address c0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0000) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
2 CPUs available, 2 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffc80000
Zone PFN ranges:
  DMA      0x00004000 -> 0x00040000
  Normal   0x00040000 -> 0x00040000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00004000 -> 0x00007ff8
    0: 0x00007ff9 -> 0x00008000
On node 0 totalpages: 16383
free_area_init_node: node 0, pgdat e000000011400000, node_mem_map
a0007fffffc80000
  DMA zone: 16327 pages, LIFO batch:3
SMP: Allowing 2 CPUs, 0 hotplug CPUs
Built 1 zonelists in Node order, mobility grouping off.  Total pages: 16327
Policy zone: DMA
Kernel command line: CRASH=3D1  root=3D/dev/sda2  insmod=3Dusbcore
insmod=3Duhci-hcd insmod=3Dohci-hcd insmod=3Dehci-hcd insmod=3Dhid   ro
elevator=DEadline sysrq=3D1 reset_devices irqpoll maxcpus=3D1  1
elfcorehdrR4160K max_addrQ2M min_addr%6M
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
PID hash table entries: 1024 (order: 10, 8192 bytes)
CPU 0: base freq=199.457MHz, ITC ratio=15/2, ITC freq=1495.930MHz
Console: colour VGA+ 80x25
console [tty0] enabled
Placing software IO TLB between 0x115d8000 - 0x155d8000
Memory: 163648k/233584k available (6640k code, 98480k reserved, 5825k
data, 2016k init)
Calibrating delay loop... 2211.84 BogoMIPS (lpjD23680)
kdb version 4.4 by Keith Owens, Scott Lurndal. Copyright SGI, All
Rights Reserved
Security Framework initialized
Dentry cache hash table entries: 32768 (order: 4, 262144 bytes)
Inode-cache hash table entries: 16384 (order: 3, 131072 bytes)
Mount-cache hash table entries: 1024
ACPI: Core revision 20080609
Boot processor id 0x0/0x0
Brought up 1 CPUs
Total of 1 processors activated (2211.84 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0 level NODE
  groups: 0
net_namespace: 1456 bytes
DMI 2.3 present.
NET: Registered protocol family 16
ACPI: bus type pci registered
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOSAPIC for interrupt routing
ACPI: Device [CSFF] status [00000008]: functional but not present;
setting present
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:1f.0: quirk: region 0c00-0c7f claimed by ICH4 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH4 GPIO
pci 0000:01:01.0: Boot video device
pci 0000:01:01.0: supports D1
pci 0000:01:01.0: supports D2
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.H2PB._PRT]
ACPI: PCI Root Bridge [PCI1] (0000:02)
pci 0000:03:01.0: supports D1
pci 0000:03:01.0: supports D2
pci 0000:03:01.1: supports D1
pci 0000:03:01.1: supports D2
pci 0000:04:01.0: PME# supported from D0 D3hot D3cold
pci 0000:04:01.0: PME# disabled
pci 0000:04:01.1: PME# supported from D0 D3hot D3cold
pci 0000:04:01.1: PME# disabled
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.P2PB._PRT]
ACPI: PCI Root Bridge [PCI2] (0000:05)
pci 0000:07:01.0: PME# supported from D0 D3hot D3cold
pci 0000:07:01.0: PME# disabled
pci 0000:07:01.1: PME# supported from D0 D3hot D3cold
pci 0000:07:01.1: PME# disabled
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2.P2PA._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2.P2PB._PRT]
ACPI: PCI Root Bridge [CSFF] (0000:ff)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:01: io resource (0xc00-0xc07) overlaps 0000:00:1f.0 BAR 7
(0xc00-0xc7f), disabling
pnp: PnP ACPI: found 13 devices
ACPI: ACPI bus type pnp unregistered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
system 00:01: ioport range 0x8a0-0x8a3 has been reserved
system 00:01: ioport range 0xcc0-0xccf has been reserved
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: iomem range 0xfec00000-0xfec0ffff has been reserved
system 00:01: iomem range 0xfee00000-0xfee00fff has been reserved
NET: Registered protocol family 2
IP route cache hash table entries: 2048 (order: 0, 16384 bytes)
TCP established hash table entries: 8192 (order: 3, 131072 bytes)
TCP bind hash table entries: 8192 (order: 3, 131072 bytes)
TCP: Hash tables configured (established 8192 bind 8192)
TCP reno registered
NET: Registered protocol family 1
checking if image is initramfs... it is
Freeing initrd memory: 10368kB freed
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
audit: initializing netlink socket (disabled)
type 00 audit(1219861958.724:1): initialized
HugeTLB registered 256 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
msgmni has been set to 339
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered (default)
io scheduler cfq registered
EFI Time Services Driver v0.4
Serial: 8250/16550 driver16 ports, IRQ sharing enabled
00:08: ttyS0 at I/O 0x3f8 (irq =3D 44) is a 16550A
00:09: ttyS1 at I/O 0x2f8 (irq =3D 45) is a 16550A
brd: module loaded
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
USB Universal Host Controller Interface driver v3.0
GSI 16 (level, low) -> CPU 0 (0x0000) vector 48
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 48
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:1d.0: irq 48, io base 0x00009cc0
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
GSI 19 (level, low) -> CPU 0 (0x0000) vector 49
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 49
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1d.1: irq 49, io base 0x00009ce0
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
usb 1-1: new low speed USB device using uhci_hcd and address 2
usb 1-1: configuration #1 chosen from 1 choice
usbcore: registered new interface driver hiddev
input: Dell Dell USB Keyboard as /class/input/input0
input: USB HID v1.10 Keyboard [Dell Dell USB Keyboard] on usb-0000:00:1d.0-1
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
registered taskstats version 1
Freeing unused kernel memory: 2016kB freed
Uniform Multi-Platform E-IDE driver
SCSI subsystem initialized
Driver 'sd' needs updating - please use bus_type methods
piix 0000:00:1f.1: IDE controller (0x8086:0x24cb rev 0x02)
PIIX_IDE 0000:00:1f.1: device not available because of BAR 5
[0x0-0x3ff] collisions
PIIX_IDE 0000:00:1f.1: can't derive routing for PCI INT A
piix 0000:00:1f.1: BIOS configuration fixed
piix 0000:00:1f.1: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007
    ide1: BM-DMA at 0x1008-0x100f
Probing IDE interface ide0...
hda: DW-224E-A, ATAPI CD/DVD-ROM drive
hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/33 mode selected
Probing IDE interface ide1...
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
ide1 at 0x170-0x177,0x376 on irq 33
Fusion MPT base driver 3.04.07
Copyright (c) 1999-2008 LSI Corporation
Fusion MPT SPI Host driver 3.04.07
GSI 48 (level, low) -> CPU 0 (0x0000) vector 50
mptspi 0000:03:01.0: PCI INT A -> GSI 48 (level, low) -> IRQ 50
mptbase: ioc0: Initiating bringup
ioc0: LSI53C1030 C0: Capabilities=3D{Initiator}
scsi0 : ioc0: LSI53C1030 C0, FwRev=01030a00h, Ports=3D1, MaxQ"2, IRQP
GSI 49 (level, low) -> CPU 0 (0x0000) vector 51
mptspi 0000:03:01.1: PCI INT B -> GSI 49 (level, low) -> IRQ 51
mptbase: ioc1: Initiating bringup
ioc1: LSI53C1030 C0: Capabilities=3D{Initiator}
scsi1 : ioc1: LSI53C1030 C0, FwRev=01030a00h, Ports=3D1, MaxQ"2, IRQQ
scsi 1:0:0:0: Direct-Access     LSILOGIC 1030          IM 1000 PQ: 0 ANSI: 2
sd 1:0:0:0: [sda] 287289344 512-byte hardware sectors (147092 MB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: 03 00 00 08
sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
sd 1:0:0:0: [sda] 287289344 512-byte hardware sectors (147092 MB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: 03 00 00 08
sd 1:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
 sda: sda1 sda2 sda3
sd 1:0:0:0: [sda] Attached SCSI disk
sd 1:0:0:0: Attached scsi generic sg0 type 0
scsi 1:0:6:0: Processor         ESG-SHV  SCA HSBP M24     1.0A PQ: 0 ANSI: 2
 target1:0:6: Beginning Domain Validation
 target1:0:6: Ending Domain Validation
 target1:0:6: asynchronous
scsi 1:0:6:0: Attached scsi generic sg1 type 3
scsi 1:1:1:0: Direct-Access     LANGCHAO ATLAS10K5_147SCA JNZ3 PQ: 0 ANSI: 3
mptbase: ioc1: RAID STATUS CHANGE for VolumeID 0
mptbase: ioc1:   volume is now degraded, enabled, quiesced
mptbase: ioc1: RAID STATUS CHANGE for PhysDisk 1 id=3D0
mptbase: ioc1:   PhysDisk is now missing, out of sync, quiesced
mptbase: ioc1: RAID STATUS CHANGE for PhysDisk 0 id=3D0
mptbase: ioc1:   PhysDisk is now online, quiesced
 target1:1:1: Beginning Domain Validation
 target1:1:1: Ending Domain Validation
mptbase: ioc1: RAID STATUS CHANGE for VolumeID 0
mptbase: ioc1:   volume is now degraded, enabled
mptbase: ioc1: RAID STATUS CHANGE for PhysDisk 1 id=3D0
mptbase: ioc1:   PhysDisk is now missing, out of sync
mptbase: ioc1: RAID STATUS CHANGE for PhysDisk 0 id=3D0
mptbase: ioc1:   PhysDisk is now online
 target1:1:1: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI (6.25 ns, offset =
127)
scsi 1:1:1:0: Attached scsi generic sg2 type 0
QLogic Fibre Channel HBA Driver: 8.02.01-k6
GSI 100 (level, low) -> CPU 0 (0x0000) vector 52
qla2xxx 0000:06:02.0: PCI INT A -> GSI 100 (level, low) -> IRQ 52
qla2xxx 0000:06:02.0: Found an ISP2312, irq 52, iobase 0xc0000000f8ee0000
qla2xxx 0000:06:02.0: Configuring PCI space...
qla2xxx 0000:06:02.0: Configure NVRAM parameters...
qla2xxx 0000:06:02.0: Verifying loaded RISC code...
firmware: requesting ql2300_fw.bin
qla2xxx 0000:06:02.0: Allocated (412 KB) for firmware dump...
scsi2 : qla2xxx
qla2xxx 0000:06:02.0: LOOP UP detected (2 Gbps).
isa bounce pool size: 16 pages
qla2xxx 0000:06:02.0:
 QLogic Fibre Channel HBA Driver: 8.02.01-k6
  QLogic QLA2342 - 133MHz PCI-X to 2Gb FC, Dual Channel
  ISP2312: PCI-X (100 MHz) @ 0000:06:02.0 hdma-, host#=3D2, fw=3D3.03.20 IPX
GSI 101 (level, low) -> CPU 0 (0x0000) vector 53
qla2xxx 0000:06:02.1: PCI INT B -> GSI 101 (level, low) -> IRQ 53
qla2xxx 0000:06:02.1: Found an ISP2312, irq 53, iobase 0xc0000000f8ef0000
qla2xxx 0000:06:02.1: Configuring PCI space...
qla2xxx 0000:06:02.1: Configure NVRAM parameters...
qla2xxx 0000:06:02.1: Verifying loaded RISC code...
scsi 2:0:0:0: Medium Changer    ADIC     Scalar 24        R210 PQ: 0 ANSI: 3
scsi 2:0:0:0: Attached scsi generic sg3 type 8
scsi 2:0:0:1: Sequential-Access IBM      ULTRIUM-TD3      57GA PQ: 0 ANSI: 3
scsi 2:0:0:1: Attached scsi generic sg4 type 1
st: Version 20080504, fixed bufsize 32768, s/g segs 256
Driver 'st' needs updating - please use bus_type methods
st 2:0:0:1: Attached scsi tape st0
st 2:0:0:1: st0: try direct i/o: yes (alignment 4 B)
scsi 2:0:0:2: Sequential-Access IBM      ULTRIUM-TD3      57GA PQ: 0 ANSI: 3
st 2:0:0:2: Attached scsi tape st1
st 2:0:0:2: st1: try direct i/o: yes (alignment 4 B)
st 2:0:0:2: Attached scsi generic sg5 type 1
scsi 2:0:0:3: Sequential-Access IBM      ULTRIUM-TD3      57GA PQ: 0 ANSI: 3
st 2:0:0:3: Attached scsi tape st2
st 2:0:0:3: st2: try direct i/o: yes (alignment 4 B)
st 2:0:0:3: Attached scsi generic sg6 type 1
qla2xxx 0000:06:02.1: Allocated (412 KB) for firmware dump...
scsi 2:0:0:4: Sequential-Access IBM      ULTRIUM-TD3      57GA PQ: 0 ANSI: 3
st 2:0:0:4: Attached scsi tape st3
st 2:0:0:4: st3: try direct i/o: yes (alignment 4 B)
st 2:0:0:4: Attached scsi generic sg7 type 1
scsi3 : qla2xxx
qla2xxx 0000:06:02.1:
 QLogic Fibre Channel HBA Driver: 8.02.01-k6
  QLogic QLA2342 - 133MHz PCI-X to 2Gb FC, Dual Channel
  ISP2312: PCI-X (100 MHz) @ 0000:06:02.1 hdma-, host#=3D3, fw=3D3.03.20 IPX
processor ACPI0007:00: registered as cooling_device0
processor ACPI0007:01: registered as cooling_device1
No dock devices found.
libata version 3.00 loaded.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
EXT3 FS on sda2, internal journal
Adding 9215968k swap on /dev/sda3.  Priority:-1 extents:1 across:9215968k
parport0: PC-style at 0x378 [PCSPP,TRISTATE,EPP]
lp0: using parport0 (polling).
Intel(R) PRO/1000 Network Driver - version 7.3.20-k3-NAPI
Copyright (c) 1999-2006 Intel Corporation.
GSI 24 (level, low) -> CPU 0 (0x0000) vector 54
e1000 0000:04:01.0: PCI INT A -> GSI 24 (level, low) -> IRQ 54
e1000: 0000:04:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:0e:0c:67:2c:2a
Fusion MPT misc device (ioctl) driver 3.04.07
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor=10,220)
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 25 (level, low) -> CPU 0 (0x0000) vector 55
e1000 0000:04:01.1: PCI INT B -> GSI 25 (level, low) -> IRQ 55
e1000: 0000:04:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:0e:0c:67:2c:2b
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 72 (level, low) -> CPU 0 (0x0000) vector 56
e1000 0000:07:01.0: PCI INT A -> GSI 72 (level, low) -> IRQ 56
e1000: 0000:07:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:04:23:ca:e9:f2
e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 73 (level, low) -> CPU 0 (0x0000) vector 57
e1000 0000:07:01.1: PCI INT B -> GSI 73 (level, low) -> IRQ 57
e1000: 0000:07:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:04:23:ca:e9:f3
e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
md: Autodetecting RAID arrays.
md: Scanned 0 and added 0 devices.
md: autorun ...
md: ... autorun DONE.
device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redha=
t.com
loop: module loaded
qla2xxx 0000:06:02.1: Cable is unplugged...
e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex,
Flow Control: RX/TX
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
eth0: no IPv6 routers present
lfg-ia64:~ #

Regards
Jason

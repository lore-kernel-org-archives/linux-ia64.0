From: Jonathan_Kwahk@Dell.com
Date: Fri, 15 Dec 2000 18:05:34 +0000
Subject: RE: [Linux-ia64] test11, test12 kernel vs. big sur: Unexpected ir
Message-Id: <marc-linux-ia64-105590678205857@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205850@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205850@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

For Big Sur, BIOS builds after I believe build 60 will have the correct
version in the BIOS string under the CM.  Builds before build 60 (I hope I'm
recalling the right build) will NOT contain the correct updated BIOS string.


"Ver" in the EFI shell is the most reliable way of obtaining SAL, PAL, and
EFI revisions.

If you can catch the date before the system gets the boot manager, you may
be able to infer the BIOS build combined with the SAL, PAL, and EFI version
information.

Jon

-----Original Message-----
From: Cook, Steven C [mailto:steven.c.cook@intel.com]
Sent: Friday, December 15, 2000 11:58 AM
To: Hall, Jenna S; 'Don Dugger'; John Kohl
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] test11, test12 kernel vs. big sur: Unexpected
ir q vector


John, Jenna,

If this is a Big Sur, you can enter Configuration Manager (CM) setup at boot
time, and one of the tabs has the complete BIOS build string.  One of the
subsections (I don't remember which offhand, but I believe it is the third
from the end) contains the build number (e.g., .0089. is build 89).

Hope this helps,
--steve cook--

-----Original Message-----
From: Hall, Jenna S [mailto:jenna.s.hall@intel.com]
Sent: Friday, December 15, 2000 09:52
To: 'Don Dugger'; John Kohl
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] test11, test12 kernel vs. big sur: Unexpected
ir q vector


John,

At the EFI prompt, type "ver" and that gives the SAL, PAL, and EFI version
numbers.  That is usually enough to figure out the overall firmware version
number (if you send me the above information, I can figure out what firmware
you have).

But like Don said, it is still recommended to upgrade your firmware and if
possible, your hardware.

Thanks,
Jenna

-----Original Message-----
From: Don Dugger [mailto:n0ano@valinux.com]
Sent: Friday, December 15, 2000 9:42 AM
To: John Kohl
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] test11, test12 kernel vs. big sur: Unexpected irq
vector

John-

I don't know of a way to discover the FW version, you just have to
keep good records :-)

If your FW is old you really should upgrade it.  You can get new
FW from QuAD, Intel's support web site (this is different from
`developer.intel.com').  Since you have a BigSur Intel should have
given you a QuAD account, I'd talk to your Intel rep about it.
I'd also talk to Intel about upgrading your machine to a B-step
processor, it's well worth the effort.

On Fri, Dec 15, 2000 at 12:11:18PM -0500, John Kohl wrote:
> >>>>> "D" =3D Don Dugger <n0ano@valinux.com> writes:
>
> D> John-
> D> Two questions:
>
> D> 1)  What version of the firmware are you running?
>
> How do I figure that out?  (Sorry, I'm new to ia64 work.)  It's probably
> old, these are relatively early Intel developer units.  We've tried to
> find new firmware through our Intel support web site with no success
> recently.
>
> D> 2)  Are you including ACPI support?  I found that most IRQ problems
> D> go away when you do this.
> =20
> Yes, I've got ACPI enabled:
>
> % grep ACPI include/linux/autoconf.h
> #define CONFIG_ACPI20 1
> #define CONFIG_ACPI_KERNEL_CONFIG 1
> #define CONFIG_ACPI 1
> #define CONFIG_ACPI_INTERPRETER 1
>
> I also recently looked at a boot trace of a working turbolinux test10
> kernel, and it displays this IRQ message once (then continues booting).
>
> Here's the boot trace from that kernel:
>
> Dec 15 10:03:32 yegua syslogd 1.3-3: restart.
> Dec 15 10:03:32 yegua syslog: syslogd startup succeeded
> Dec 15 10:03:32 yegua kernel: klogd 1.3-3, log source =3D /proc/kmsg
started.
> Dec 15 10:03:32 yegua kernel: Inspecting
/boot/System.map-2.4.0test10-001115-55
> Dec 15 10:03:32 yegua syslog: klogd startup succeeded
> Dec 15 10:03:32 yegua portmap: portmap startup succeeded
> Dec 15 10:03:32 yegua rpc.lockd: lockdsvc: Invalid argument
> Dec 15 10:03:32 yegua nfslock: rpc.lockd startup failed
> Dec 15 10:03:33 yegua nfslock: rpc.statd startup succeeded
> Dec 15 10:03:33 yegua kernel: Loaded 32121 symbols from
/boot/System.map-2.4.0test10-001115-55.
> Dec 15 10:03:33 yegua kernel: Symbols match kernel version 2.4.0.
> Dec 15 10:03:33 yegua kernel: No module symbols loaded.
> Dec 15 10:03:33 yegua kernel: Linux version 2.4.0test10-001115-55
(root@yegua) (gcc version 2.96-ia64-000717 snap 001117) #7 SMP Tue Dec 12
17:19:23 EST 2000
> Dec 15 10:03:33 yegua kernel: EFI v0.92 by INTEL: SALsystab=3D0x3ff202a0
ACPI=3D0x3ffd8e60 MPS=3D0x3ffd1000
> Dec 15 10:03:33 yegua kernel: CPU 0: mapping PAL code
[0x3ff40000-0x3ff7b000) into [0xe000000030000000-0xe000000040000000)
> Dec 15 10:03:33 yegua kernel: SAL v2.70: oem=3DINTEL   MSL     REF     SAL
, product> Dec 15 10:03:33 yegua kernel: sal[0] - entry: pal_proc=3D0x3ff48=
010,
sal_proc=3D0x3fe5a7f0
> Dec 15 10:03:33 yegua kernel: SAL: Platform features BusLock
> Dec 15 10:03:33 yegua kernel: sal[25] - wakeup type 0, 0xf0
> Dec 15 10:03:33 yegua kernel: SAL: AP wakeup using external interrupt
vector 0xf0
> Dec 15 10:03:33 yegua kernel: CPU 0: 51 virtual and 44 physical address
bits
> Dec 15 10:03:33 yegua kernel: ACPI: Intel    RSDT   0.0
> Dec 15 10:03:33 yegua kernel: Acpi cfg:bind to Boot time Acpi OSD
> Dec 15 10:03:33 yegua kernel:       CPU 0 (0000:0003): Available.
> Dec 15 10:03:33 yegua kernel:       CPU 1 (0000:0000): Available.
> Dec 15 10:03:33 yegua kernel: Acpi Cfg: get PRT pass
> Dec 15 10:03:33 yegua kernel: IOSAPIC: version 2.1, address 0xfec00000,
IRQs 0x00-0x3f
> Dec 15 10:03:33 yegua ypbind: ypbind startup succeeded
> Dec 15 10:03:33 yegua kernel:       2 CPUs available, 2 CPUs total
> Dec 15 10:03:33 yegua kernel: Acpi cfg:bind to Run time Acpi OSD
> Dec 15 10:03:33 yegua kernel: ia64_mca_init : begin
> Dec 15 10:03:33 yegua kernel: ia64_mca_init : registered mca rendezvous
spinloop and wakeup mech.
> Dec 15 10:03:33 yegua kernel: ia64_mca_init : correctable mca vector setup
done
> Dec 15 10:03:33 yegua kernel: ia64_mca_init : registered os mca handler
with SAL
> Dec 15 10:03:33 yegua kernel: ia64_mca_init : os init handler at 5477a0
> Dec 15 10:03:33 yegua kernel: ia64_mca_init : registered os init handler
with SAL
> Dec 15 10:03:33 yegua kernel: ia64_mca_init : platform-specific mca
handling setup done
> Dec 15 10:03:33 yegua kernel: Mca related initialization done
> Dec 15 10:03:33 yegua kernel: On node 0 totalpages: 64894
> Dec 15 10:03:33 yegua kernel: zone(0): 64894 pages.
> Dec 15 10:03:33 yegua kernel: zone(1): 0 pages.
> Dec 15 10:03:33 yegua random: Initializing random number generator:
succeeded
> Dec 15 10:03:33 yegua kernel: zone(2): 0 pages.
> Dec 15 10:03:33 yegua kernel: Placing software IO TLB between
0xe000000000100000 - 0xe000000000300000
> Dec 15 10:03:33 yegua kernel: Kernel command line:  root=3D/dev/sda2 ro
> Dec 15 10:03:33 yegua kernel: fpswa interface at 3f511110
> Dec 15 10:03:34 yegua kernel: CPU 0: base freq=99.804MHz, ITC ratio=10/2,
ITC freqI9.024MHz
> Dec 15 10:03:34 yegua kernel: Console: colour VGA+ 80x25
> Dec 15 10:03:34 yegua kernel: Unexpected irq vector 0x0 on CPU 0!
> Dec 15 10:03:34 yegua kernel: Calibrating delay loop... 494.93 BogoMIPS
> Dec 15 10:03:34 yegua kernel: Placing software IO TLB between
0xe000000000300000 - 0xe000000000500000
> Dec 15 10:03:34 yegua kernel: Memory: 1017312k/1038304k available (3884k
code, 19920k reserved, 2395k data, 320k init)
> Dec 15 10:03:34 yegua kernel: kdb version 1.2 by Scott Lurndal. Copyright
SGI, All Rights Reserved
> Dec 15 10:03:34 yegua kernel: perfmon: Initialized vector to 238
> Dec 15 10:03:34 yegua netfs: Mounting NFS filesystems:  succeeded
> Dec 15 10:03:34 yegua kernel: perfmon: Counters are 32 bits
> Dec 15 10:03:34 yegua kernel: perfmon: Maximum counter value 0xffffffff
> Dec 15 10:03:34 yegua netfs: Mounting other filesystems:  succeeded
> Dec 15 10:03:34 yegua kernel: Dentry-cache hash table entries: 65536
(order: 6, 1048576 bytes)
> Dec 15 10:03:34 yegua kernel: Buffer-cache hash table entries: 65536
(order: 5, 524288 bytes)
> Dec 15 10:03:34 yegua kernel: Page-cache hash table entries: 65536 (order:
5, 524288 bytes)
> Dec 15 10:03:34 yegua kernel: Inode-cache hash table entries: 65536
(order: 6, 1048576 bytes)
> Dec 15 10:03:34 yegua kernel: POSIX conformance testing by UNIFIX
> Dec 15 10:03:34 yegua identd: identd startup succeeded
> Dec 15 10:03:34 yegua kernel: SMP: starting up secondaries.
> Dec 15 10:03:35 yegua kernel: CPU 1: mapping PAL code
[0x3ff40000-0x3ff7b000) into [0xe000000030000000-0xe000000040000000)
> Dec 15 10:03:35 yegua kernel: CPU 1: 51 virtual and 44 physical address
bits
> Dec 15 10:03:35 yegua kernel: CPU 1: base freq=99.804MHz, ITC ratio=10/2,
ITC freqI9.024MHz
> Dec 15 10:03:23 yegua fsck: /dev/sda4: 76563/881280 files (5.2%
non-contiguous), 529290/1761792 blocks
> Dec 15 10:03:35 yegua kernel: Calibrating delay loop... 494.93 BogoMIPS
> Dec 15 10:03:23 yegua rc.sysinit: Checking filesystems succeeded
> Dec 15 10:03:23 yegua modprobe: modprobe: Can't locate module
nls_iso8859-1
> Dec 15 10:03:23 yegua modprobe: modprobe: Can't locate module
nls_iso8859-1
> Dec 15 10:03:35 yegua kernel: SMP: Total of 2 processors activated (989.86
BogoMIPS).
> Dec 15 10:03:35 yegua atd: atd startup succeeded
> Dec 15 10:03:23 yegua rc.sysinit: Mounting local filesystems:  succeeded
> Dec 15 10:03:35 yegua kernel: PCI: Probing PCI hardware
> Dec 15 10:03:23 yegua rc.sysinit: Turning on user and group quotas for
local filesystems:  succeeded
> Dec 15 10:03:35 yegua kernel: PCI->APIC IRQ transform: (B0,I1,P0) -> 0x30
> Dec 15 10:03:24 yegua rc.sysinit: Enabling swap space:  succeeded
> Dec 15 10:03:35 yegua kernel: PCI->APIC IRQ transform: (B0,I3,P3) -> 0x3d
> Dec 15 10:03:25 yegua init: Entering runlevel: 5
> Dec 15 10:03:35 yegua kernel: PCI->APIC IRQ transform: (B0,I3,P1) -> 0x3c
> Dec 15 10:03:30 yegua kudzu:  succeeded
> Dec 15 10:03:30 yegua sysctl: error: 'net.ipv4.ip_always_defrag' is an
unknown key
> Dec 15 10:03:30 yegua sysctl: net.ipv4.ip_forward =3D 0
> Dec 15 10:03:35 yegua kernel: PCI->APIC IRQ transform: (B0,I4,P0) -> 0x38
> Dec 15 10:03:35 yegua crond[503]: (CRON) STARTUP (fork ok)
> Dec 15 10:03:30 yegua sysctl: net.ipv4.conf.all.rp_filter =3D 1
> Dec 15 10:03:35 yegua kernel: PCI->APIC IRQ transform: (B1,I2,P0) -> 0x46
> Dec 15 10:03:30 yegua sysctl: kernel.sysrq =3D 0
> Dec 15 10:03:35 yegua kernel: Linux NET4.0 for Linux 2.4
> Dec 15 10:03:30 yegua network: Setting network parameters:  succeeded
> Dec 15 10:03:35 yegua kernel: Based upon Swansea University Computer
Society NET3.039
> Dec 15 10:03:31 yegua ifup: SIOCADDRT: No such device
> Dec 15 10:03:35 yegua kernel: Initializing RT netlink socket
> Dec 15 10:03:31 yegua network: Bringing up interface lo:  succeeded
> Dec 15 10:03:35 yegua kernel: PAL Information Facility v0.3
> Dec 15 10:03:32 yegua network: Bringing up interface eth0:  succeeded
> Dec 15 10:03:35 yegua kernel: Starting kswapd v1.8
> Dec 15 10:03:35 yegua kernel: pty: 256 Unix98 ptys configured
> Dec 15 10:03:35 yegua kernel: RAMDISK driver initialized: 16 RAM disks of
8192K size 1024 blocksize
> Dec 15 10:03:35 yegua kernel: loop: enabling 8 loop devices
> Dec 15 10:03:36 yegua crond: crond startup succeeded
> Dec 15 10:03:36 yegua kernel: Uniform Multi-Platform E-IDE driver
Revision: 6.31
> Dec 15 10:03:36 yegua kernel: ide: Assuming 33MHz system bus speed for PIO
modes; override with idebus=3Dxx
> Dec 15 10:03:36 yegua kernel: PIIX4: IDE controller on PCI bus 00 dev 19
> Dec 15 10:03:36 yegua kernel: PIIX4: chipset revision 0
> Dec 15 10:03:36 yegua kernel: PIIX4: not 100% native mode: will probe irqs
later
> Dec 15 10:03:36 yegua kernel:     ide0: BM-DMA at 0x1170-0x1177, BIOS
settings: hda:pio, hdb:pio
> Dec 15 10:03:36 yegua kernel: hda: LTN483, ATAPI CDROM drive
> Dec 15 10:03:36 yegua kernel: hdb: LS-120 F200 08 UHD Floppy, ATAPI FLOPPY
drive
> Dec 15 10:03:36 yegua kernel: ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
> Dec 15 10:03:36 yegua kernel: hda: ATAPI 48X CD-ROM drive, 120kB Cache,
UDMA(33)
> Dec 15 10:03:36 yegua kernel: Uniform CD-ROM driver Revision: 3.11
> Dec 15 10:03:36 yegua kernel: Partition check:
> Dec 15 10:03:36 yegua kernel:  hdb:<3>ide-scsi: hdb: unsupported command
in request queue (0)
> Dec 15 10:03:36 yegua kernel: end_request: I/O error, dev 03:40 (hdb),
sector 0
> Dec 15 10:03:36 yegua kernel:  unable to read partition table
> Dec 15 10:03:36 yegua kernel: NET4: Linux TCP/IP 1.0 for NET4.0
> Dec 15 10:03:36 yegua kernel: IP Protocols: ICMP, UDP, TCP, IGMP
> Dec 15 10:03:36 yegua kernel: IP: routing cache hash table of 16384
buckets, 256Kbytes
> Dec 15 10:03:36 yegua kernel: TCP: Hash tables configured (established
131072 bind 65536)
> Dec 15 10:03:36 yegua kernel: NET4: Unix domain sockets 1.0/SMP for Linux
NET4.0.
> Dec 15 10:03:36 yegua kernel: Serial driver version 5.02 (2000-08-09) with
MANY_PORTS SHARE_IRQ DETECT_IRQ SERIAL_PCI enabled
> Dec 15 10:03:36 yegua kernel: ttyS00 at 0x03f8 (irq =3D 44) is a 16550A
> Dec 15 10:03:36 yegua kernel: EFI Time Services Driver v0.2
> Dec 15 10:03:36 yegua kernel: eepro100.c:v1.09j-t 9/29/99 Donald Becker
http://cesdis.gsfc.nasa.gov/linux/drivers/eepro100.html
> Dec 15 10:03:36 yegua kernel: eepro100.c: $Revision: 1.33 $ 2000/05/24
Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
> Dec 15 10:03:36 yegua kernel: eth0: OEM i82557/i82558 10/100 Ethernet,
00:90:27:FE:20:44, IRQ 56.
> Dec 15 10:03:36 yegua kernel:   Receiver lock-up bug exists -- enabling
work-around.
> Dec 15 10:03:36 yegua kernel:   Board assembly 727095-004, Physical
connectors present: RJ45
> Dec 15 10:03:36 yegua kernel:   Primary interface chip i82555 PHY #1.
> Dec 15 10:03:36 yegua kernel:   General self-test: passed.
> Dec 15 10:03:36 yegua kernel:   Serial sub-system self-test: passed.
> Dec 15 10:03:36 yegua kernel:   Internal registers self-test: passed.
> Dec 15 10:03:36 yegua kernel:   ROM checksum self-test: passed
(0x04f4518b).
> Dec 15 10:03:36 yegua kernel: SCSI subsystem driver Revision: 1.00
> Dec 15 10:03:36 yegua kernel: qla1280: detect() found an HBA
> Dec 15 10:03:36 yegua kernel: qla1280: VID=1077 DID=1280 SSVID=1077
SSDID=3D6
> Dec 15 10:03:36 yegua kernel: scsi(0): Determining if RISC is loaded...
> Dec 15 10:03:36 yegua kernel: scsi(0): Verifying chip...
> Dec 15 10:03:37 yegua kernel: scsi(0): Setup chip...
> Dec 15 10:03:37 yegua kernel: scsi(0): Configure NVRAM parameters...
> Dec 15 10:03:37 yegua kernel: scsi(0): Resetting SCSI BUS (0)
> Dec 15 10:03:37 yegua kernel: scsi(0): Resetting SCSI BUS (1)
> Dec 15 10:03:37 yegua kernel: scsi0 : QLogic QLA1280  PCI to SCSI Host
Adapter: bus 1 device 2 irq 70
> Dec 15 10:03:37 yegua xinetd[518]: linuxconf disabled, removing
> Dec 15 10:03:37 yegua kernel:        Firmware version:  8.13.08, Driver
version 3.19 Beta
> Dec 15 10:03:37 yegua kernel:   Vendor: QUANTUM   Model: ATLAS IV 9 WLS
Rev: 0B0B
> Dec 15 10:03:37 yegua xinetd[518]: exec disabled, removing
> Dec 15 10:03:37 yegua kernel:   Type:   Direct-Access
ANSI SCSI revision: 03
> Dec 15 10:03:37 yegua kernel: scsi(0:0:0:0): Enabled tagged queuing, queue
depth 10.
> Dec 15 10:03:37 yegua xinetd[518]: tftp disabled, removing
> Dec 15 10:03:37 yegua kernel: scsi(0:0:0:0): Synchronous tranfer at period
10, offset 8.
> Dec 15 10:03:37 yegua kernel: scsi1 : SCSI host adapter emulation for IDE
ATAPI devices
> Dec 15 10:03:37 yegua kernel:   Vendor: MITBISHI  Model: LS-120 F200   08
Rev: 0220
> Dec 15 10:03:37 yegua kernel:   Type:   Direct-Access
ANSI SCSI revision: 00
> Dec 15 10:03:37 yegua xinetd[518]: xinetd Version 2.1.8.9pre9 started with
> Dec 15 10:03:37 yegua kernel: Detected scsi disk sda at scsi0, channel 0,
id 0, lun 0
> Dec 15 10:03:37 yegua xinetd[518]: libwrap
> Dec 15 10:03:37 yegua kernel: Detected scsi removable disk sdb at scsi1,
channel 0, id 0, lun 0
> Dec 15 10:03:37 yegua xinetd[518]: options compiled in.
> Dec 15 10:03:37 yegua kernel: SCSI device sda: 17942584 512-byte hdwr
sectors (9187 MB)
> Dec 15 10:03:37 yegua xinetd[518]: Started working: 7 available services
> Dec 15 10:03:37 yegua kernel:  sda: sda1 sda2 sda3 sda4
> Dec 15 10:03:37 yegua kernel: sdb : READ CAPACITY failed.
> Dec 15 10:03:37 yegua kernel: sdb : status =3D 0, message =3D 00, host =
=3D 0,
driver =3D 28
> Dec 15 10:03:37 yegua kernel: sdb : extended sense code =3D 2
> Dec 15 10:03:37 yegua kernel: sdb : block size assumed to be 512 bytes,
disk size 1GB.=20
> Dec 15 10:03:37 yegua kernel:  sdb: I/O error: dev 08:10, sector 0
> Dec 15 10:03:37 yegua kernel:  unable to read partition table
> Dec 15 10:03:37 yegua kernel: usb.c: registered new driver usbdevfs
> Dec 15 10:03:37 yegua kernel: usb.c: registered new driver hub
> Dec 15 10:03:37 yegua kernel: uhci.c: USB UHCI at I/O 0x1140, IRQ 61
> Dec 15 10:03:37 yegua kernel: uhci.c: detected 2 ports
> Dec 15 10:03:37 yegua kernel: usb.c: new USB bus registered, assigned bus
number 1
> Dec 15 10:03:37 yegua kernel: hub.c: USB hub found
> Dec 15 10:03:37 yegua kernel: hub.c: 2 ports detected
> Dec 15 10:03:37 yegua kernel: uhci.c: enabling Lion USB workaround
io_addr=1140
> Dec 15 10:03:37 yegua kernel: usb.c: registered new driver hid
> Dec 15 10:03:37 yegua kernel: mice: PS/2 mouse device common for all mice
> Dec 15 10:03:37 yegua kernel: kmem_create: Forcing size word alignment -
nfs_fh
> Dec 15 10:03:37 yegua kernel: VFS: Mounted root (ext2 filesystem)
readonly.
> Dec 15 10:03:37 yegua kernel: Freeing unused kernel memory: 320kB freed
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=CCf560a5a,itm=CCf5d60fb)
> Dec 15 10:03:37 yegua kernel: Adding Swap: 263136k swap-space (priority
-1)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=CDc1fa4f8,itm=CDc27002c)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=103bbe2bdd,itm=103bc56e7b)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=178060cd15,itm=178068197b)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=1843bf8ef6,itm=1843c6df3b)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=1847599993,itm=184760f0bb)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=1850c4ab42,itm=1850cbfb6c)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=18548b53f7,itm=185492aaac)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=1855349f11,itm=18553beddb)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=1859adbfa0,itm=1859b5141b)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=186912ddce,itm=18691a2d5b)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=186b248ebc,itm=186b2be6ec)
> Dec 15 10:03:37 yegua kernel: Oops: timer tick before it's due
(itc=1871da49e7,itm=1871e1a04c)
> Dec 15 10:03:38 yegua kernel: Oops: timer tick before it's due
(itc=187aaed8cd,itm=187ab62e4c)
> Dec 15 10:03:38 yegua kernel: Oops: timer tick before it's due
(itc=188058dbb6,itm=188060352c)
> Dec 15 10:03:38 yegua kernel: Oops: timer tick before it's due
(itc=1887b99e37,itm=1887c0f5ec)
> Dec 15 10:03:38 yegua kernel: Oops: timer tick before it's due
(itc=188af30177,itm=188afa5c4c)
> Dec 15 10:03:38 yegua kernel: Oops: timer tick before it's due
(itc=188cd49c50,itm=188cdbefbb)
> Dec 15 10:03:38 yegua kernel: NFS: NFSv3 not supported.
> Dec 15 10:03:38 yegua kernel: nfs warning: mount version older than kernel
> Dec 15 10:03:38 yegua last message repeated 11 times
> Dec 15 10:03:38 yegua kernel: Oops: timer tick before it's due
(itc=18c537b7d3,itm=18c53f0c0c)
> Dec 15 10:03:39 yegua xinetd: xinetd startup succeeded
> Dec 15 10:03:39 yegua kernel: Oops: timer tick before it's due
(itc=1958056aee,itm=19580cc4cc)
> Dec 15 10:03:40 yegua lpd: lpd startup succeeded
> Dec 15 10:03:40 yegua nfs: Starting NFS services:  succeeded
> Dec 15 10:03:40 yegua nfs: rpc.rquotad startup succeeded
> Dec 15 10:03:40 yegua kernel: Oops: timer tick before it's due
(itc=19757997a1,itm=197580e88c)
> Dec 15 10:03:41 yegua nfs: rpc.mountd startup succeeded
> Dec 15 10:03:41 yegua kernel: Oops: timer tick before it's due
(itc=1978524cdb,itm=197859a3cc)
> Dec 15 10:03:41 yegua nfs: rpc.nfsd startup succeeded
> Dec 15 10:03:41 yegua amd[599]: switched to logfile "syslog"
> Dec 15 10:03:41 yegua amd[599]: AM-UTILS VERSION INFORMATION:
> Dec 15 10:03:41 yegua amd[599]: Copyright (c) 1997-2000 Erez Zadok
> Dec 15 10:03:41 yegua amd[599]: Copyright (c) 1990 Jan-Simon Pendry
> Dec 15 10:03:41 yegua amd[599]: Copyright (c) 1990 Imperial College of
Science, Technology & Medicine
> Dec 15 10:03:41 yegua amd[599]: Copyright (c) 1990 The Regents of the
University of California.
> Dec 15 10:03:41 yegua amd[599]: am-utils version 6.0.4s5 (build 1).
> Dec 15 10:03:41 yegua amd[599]: Built by prospector@boris.devel.redhat.com
on date Sat Jul 15 13:50:30 EDT 2000.
> Dec 15 10:03:41 yegua amd[599]: cpu=3Dia64 (little-endian), arch=3Dia64,
karch=3Dia64.
> Dec 15 10:03:41 yegua amd[599]: full_os=3Dlinux, os=3Dlinux,
osver=3D2.4.0-0.5smp, vendor=3Dredhat.
> Dec 15 10:03:41 yegua amd[599]: Map support for: root, passwd, ldap,
union, nisplus, nis, ndbm, file, error.
> Dec 15 10:03:41 yegua amd[599]: AMFS: nfs, link, nfsx, nfsl, host, linkx,
program, union, inherit, ufs,
> Dec 15 10:03:41 yegua amd[599]:       cdfs, pcfs, auto, direct, toplvl,
error.
> Dec 15 10:03:41 yegua amd: Dec 15 10:03:41 yegua amd[599]/info:  using
configuration file /etc/amd.conf
> Dec 15 10:03:41 yegua amd[599]: FS: iso9660, nfs, vfat, ext2.
> Dec 15 10:03:41 yegua amd[599]: Network: wire=3D"172.21.0.0"
(netnumber=172.21).
> Dec 15 10:03:41 yegua amd[599]: My ip addr is 172.21.171.248
> Dec 15 10:03:42 yegua amd[601]: released controlling tty using setsid()
> Dec 15 10:03:42 yegua amd[601]: file server localhost type local starts up
> Dec 15 10:03:42 yegua amd[601]: /dev/sda2 restarted fstype ufs on /
> Dec 15 10:03:42 yegua amd[601]: none restarted fstype link on /proc
> Dec 15 10:03:42 yegua amd[601]: /dev/sda1 restarted fstype pcfs on
/boot/efi
> Dec 15 10:03:42 yegua amd[601]: /dev/sda4 restarted fstype ufs on /usr1
> Dec 15 10:03:42 yegua amd[601]: none restarted fstype link on /dev/pts
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
metta
> Dec 15 10:03:42 yegua amd[601]: start_ping: nfs_version: 2
> Dec 15 10:03:42 yegua amd[601]: metta:/usr1/qe_releases restarted fstype
nfs on /usr/src/releases4
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
sudden
> Dec 15 10:03:42 yegua amd[601]: sudden:/usr2/qe_releases restarted fstype
nfs on /usr/src/releases3
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
toaster
> Dec 15 10:03:42 yegua amd[601]: toaster:/usr1/releases2 restarted fstype
nfs on /usr/src/releases2
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
toaster
> Dec 15 10:03:42 yegua amd[601]: toaster:/usr2/releases restarted fstype
nfs on /usr/src/releases
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
blender
> Dec 15 10:03:42 yegua amd[601]: blender:/src.exports/bsdnetR2 restarted
fstype nfs on /usr/src/bsdnetR2
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
metta
> Dec 15 10:03:42 yegua amd[601]: metta:/usr1/qe_automation restarted fstype
nfs on /usr/src/automation
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
blender
> Dec 15 10:03:42 yegua amd[601]: blender:/src.exports/local restarted
fstype nfs on /usr/src/local
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
blender
> Dec 15 10:03:42 yegua amd[601]: blender:/src.exports/gnu/emacs restarted
fstype nfs on /usr/src/emacs
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
blender
> Dec 15 10:03:42 yegua amd[601]: blender:/exports/usr/atria restarted
fstype nfs on /usr/src/atria
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
sudden
> Dec 15 10:03:42 yegua amd[601]: sudden:/usr5/qe_automation_archive
restarted fstype nfs on /usr/src/automation_archive
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
metta
> Dec 15 10:03:42 yegua amd[601]: metta:/usr1/qe_automation restarted fstype
nfs on /usr/src/automation_nr
> Dec 15 10:03:42 yegua amd[601]: Using NFS version 2, protocol udp on host
blender
> Dec 15 10:03:42 yegua amd[601]: blender:/exports/ia64/usr/local restarted
fstype nfs on /usr/local
> Dec 15 10:03:42 yegua amd[601]: recompute_portmap: NFS version 2
> Dec 15 10:03:42 yegua amd[601]: Using MOUNT version: 1
> Dec 15 10:03:42 yegua amd[601]: recompute_portmap: NFS version 2
> Dec 15 10:03:42 yegua amd[601]: Using MOUNT version: 1
> Dec 15 10:03:42 yegua amd[601]: recompute_portmap: NFS version 2
> Dec 15 10:03:42 yegua amd[601]: Using MOUNT version: 1
> Dec 15 10:03:42 yegua amd[601]: recompute_portmap: NFS version 2
> Dec 15 10:03:42 yegua amd[601]: Using MOUNT version: 1
> Dec 15 10:03:42 yegua amd[601]: initializing amd conf map /etc/amd.net of
type file
> Dec 15 10:03:42 yegua amd[601]: first time load of map /etc/amd.net
succeeded
> Dec 15 10:03:42 yegua amd[601]: /etc/amd.net mounted fstype toplvl on /net
> Dec 15 10:03:42 yegua amd: amd startup succeeded
> Dec 15 10:03:43 yegua kernel: Oops: timer tick before it's due
(itc=19be8ea306,itm=19be95f90c)
> Dec 15 10:03:43 yegua automount[656]: starting automounter version 3.1.6,
path =3D /usr/src, maptype =3D file, mapname =3D /etc/auto_direct.nis
> Dec 15 10:03:43 yegua automount[656]: using kernel protocol version 3
> Dec 15 10:03:43 yegua automount[681]: starting automounter version 3.1.6,
path =3D /people, maptype =3D yp, mapname =3D auto.people
> Dec 15 10:03:43 yegua automount[681]: parse(sun): unknown option: -rw,hard
> Dec 15 10:03:43 yegua autofs: autofs startup succeeded
> Dec 15 10:03:43 yegua automount[681]: using kernel protocol version 3
> Dec 15 10:03:43 yegua keytable: Loading keymap:
> Dec 15 10:03:43 yegua keytable: Loading
/usr/lib/kbd/keymaps/i386/qwerty/us.kmap.gz
> Dec 15 10:03:43 yegua keytable: Loading system font:
> Dec 15 10:03:43 yegua rc: Starting keytable:  succeeded
> Dec 15 10:03:44 yegua atria: Unsupported operating system version
"2.4.0test10-001115-55"(2:1)
> Dec 15 10:03:44 yegua rc: Starting atria:  failed
> Dec 15 10:03:44 yegua sendmail: sendmail startup succeeded
> Dec 15 10:03:45 yegua kernel: Oops: timer tick before it's due
(itc=19f1195bf5,itm=19f120ac8c)
> Dec 15 10:03:45 yegua gpm: gpm startup succeeded
> Dec 15 10:03:45 yegua kernel: Oops: timer tick before it's due
(itc=1A037a9edc,itm=1A0381eafb)
> Dec 15 10:03:45 yegua kernel: Oops: timer tick before it's due
(itc=1A0b7015c3,itm=1A0b77643b)
> Dec 15 10:03:46 yegua kernel: Oops: timer tick before it's due
(itc=1A0d376fa8,itm=1A0d3ec18c)
> Dec 15 10:03:46 yegua httpd: httpd startup succeeded
> Dec 15 10:03:46 yegua kernel: Oops: timer tick before it's due
(itc=1A28c8379f,itm=1A28cf8dac)
> Dec 15 10:03:47 yegua kernel: Oops: timer tick before it's due
(itc=1A2a953a22,itm=1A2a9c966c)
> Dec 15 10:03:47 yegua kernel: Oops: timer tick before it's due
(itc=1A2c5ad6fa,itm=1A2c622f8c)
> Dec 15 10:03:47 yegua kernel: Oops: timer tick before it's due
(itc=1A3089a290,itm=1A3090f98c)
> Dec 15 10:03:47 yegua kernel: Oops: timer tick before it's due
(itc=1A30bdaf2a,itm=1A30c506ec)
> Dec 15 10:03:47 yegua kernel: Oops: timer tick before it's due
(itc=1A38e571ce,itm=1A38ecc95b)
> Dec 15 10:03:47 yegua xfs: xfs startup succeeded
> Dec 15 10:03:47 yegua kernel: Oops: timer tick before it's due
(itc=1A3ddec657,itm=1A3de61d6c)
> Dec 15 10:03:47 yegua anacron[944]: Anacron 2.3 started on 2000-12-15
> Dec 15 10:03:47 yegua anacron: anacron startup succeeded
> Dec 15 10:03:47 yegua anacron[944]: Normal exit (0 jobs run)
> Dec 15 10:03:48 yegua linuxconf: Running Linuxconf hooks: succeeded
> Dec 15 10:03:48 yegua kernel: Oops: timer tick before it's due
(itc=1A57401d8c,itm=1A5747717b)
> Dec 15 10:03:52 yegua modprobe: modprobe: Can't locate module
char-major-81
>
> --
> =3DJohn Kohl <jtk@rational.com>, Software Engineer
> Rational Software, Configuration Management Business Unit
> Mark your calendars!  Rational User Conference 2001, July 22-26, 2001
> in beautiful Denver, Colorado

--
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


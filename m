From: Jay Lan <jlan@sgi.com>
Date: Tue, 15 Aug 2006 19:15:56 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <44E21D6C.7020600@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai wrote:
> On Tue, 2006-08-15 at 09:56, Jay Lan wrote:
> 
>>Bob Montgomery wrote:
>>
>>>On Mon, 2006-08-14 at 14:47 +0800, Zou Nan hai wrote:
>>>
>>>
>>>>This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.
>>>
>>>
> 
>>...
> 
>   Jay,  
>   	Thanks very much, please try the following updated patch which
> simplify the device_shootdown code.
> 
> 
>   Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 
Since you did not indicate version number different from the previous
one, i would call it 2.6.18-rc4-v2.

With this version, the crash dump kernel tried to boot... and failed
at "exec of init()" for "No such file or directory".


Here is the output at the console:

SysRq : Trigger a crashdump
Linux version 2.6.18-rc4 (jlan@holism.engr.sgi.com) (gcc version 4.1.0 
200603046
Ignoring memory below 256MB
Ignoring memory above 384MB
EFI v1.10 by HP: SALsystab=0x3fb38000 ACPI 2.0=0x3fb2e000 
SMBIOS=0x3fb3a000 HCD0
PCDP: v0 at 0x3fb2c000
Explicit "console="; ignoring PCDP
efi_memmap start 17fd4000 17fd47e0
Initial ramdisk at: 0xe000000017e6c000 (1420052 bytes)
SAL 3.1: HP version 2.31
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
No logical to physical processor mapping available
ACPI: Local APIC address c0000000fee00000
GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
2 CPUs available, 2 CPUs total
MCA related initialization done
SMP: Allowing 2 CPUs, 0 hotplug CPUs
Built 1 zonelists.  Total pages: 8191
Kernel command line: root=LABEL=/ init 1 irqpoll console=ttyS0,38400n8 
maxcpus=M
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
PID hash table entries: 512 (order: 9, 4096 bytes)
irq 51, desc: a00000010082e380, depth: 1, count: 0, unhandled: 0
->handle_irq():  a0000001007bf9c0, __stop___param+0x3a70/0x1c0b0
->chip(): a000000100946468, no_irq_chip+0x0/0x80
->action(): 0000000000000000
   IRQ_DISABLED set
Unexpected irq vector 0x33 on CPU 0!
Console: colour dummy device 80x25
Dentry cache hash table entries: 16384 (order: 3, 131072 bytes)
Inode-cache hash table entries: 8192 (order: 2, 65536 bytes)
Placing software IO TLB between 0x11124000 - 0x15124000
Memory: 46144k/131056k available (6965k code, 84912k reserved, 2751k 
data, 256k)
McKinley Errata 9 workaround not needed; disabling it
Mount-cache hash table entries: 1024
ACPI: Core revision 20060707
Boot processor id 0x0/0x0
Brought up 1 CPUs
Total of 1 processors activated (1945.60 BogoMIPS).
migration_cost=0
checking if image is initramfs... it is
Freeing initrd memory: 1376kB freed
DMI 2.3 present.
NET: Registered protocol family 16
ACPI: bus type pci registered
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
ACPI: PCI Root Bridge [PCI1] (0000:20)
ACPI: PCI Root Bridge [PCI2] (0000:40)
ACPI: PCI Root Bridge [PCI3] (0000:60)
ACPI: PCI Root Bridge [PCI4] (0000:80)
ACPI: PCI Root Bridge [PCI6] (0000:c0)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
GSI 34 (edge, high) -> CPU 0 (0x0000) vector 49
GSI 35 (edge, high) -> CPU 0 (0x0000) vector 50
pnp: PnP ACPI: found 10 devices
SCSI subsystem initialized
usbcore: registered new driver usbfs
usbcore: registered new driver hub
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: -1, 8192 bytes)
TCP established hash table entries: 4096 (order: 2, 65536 bytes)
TCP bind hash table entries: 2048 (order: 1, 32768 bytes)
TCP: Hash tables configured (established 4096 bind 2048)
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
00:04: ttyS0 at MMIO 0xff5e0000 (irq = 49) is a 16550A
00:05: ttyS1 at MMIO 0xff5e2000 (irq = 50) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
Intel(R) PRO/1000 Network Driver - version 7.1.9-k4
Copyright (c) 1999-2006 Intel Corporation.
tg3.c:v3.64 (July 31, 2006)
GSI 29 (level, low) -> CPU 0 (0x0000) vector 51
ACPI: PCI Interrupt 0000:20:02.0[A] -> GSI 29 (level, low) -> IRQ 51
eth0: Tigon3 [partno(BCM95700A6) rev 0105 PHY(5701)] (PCI:66MHz:64-bit) 
10/100/e
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] 
TSOcap[0]
eth0: dma_rwctrl[76ff2d0f] dma_mask[64-bit]
netconsole: not configured, aborting
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
CMD649: IDE controller at PCI slot 0000:00:02.0
GSI 21 (level, low) -> CPU 0 (0x0000) vector 52
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 21 (level, low) -> IRQ 52
CMD649: chipset revision 2
CMD649: 100% native mode on irq 52
     ide0: BM-DMA at 0x0d40-0x0d47, BIOS settings: hda:DMA, hdb:pio
     ide1: BM-DMA at 0x0d48-0x0d4f, BIOS settings: hdc:pio, hdd:pio
hda: DV-28E-C, ATAPI CD/DVD-ROM drive
ide0 at 0xd58-0xd5f,0xd66 on irq 52
hda: ATAPI 24X DVD-ROM drive, 256kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
ide-floppy driver 0.99.newide
Fusion MPT base driver 3.04.01
Copyright (c) 1999-2005 LSI Logic Corporation
Fusion MPT SPI Host driver 3.04.01
GSI 27 (level, low) -> CPU 0 (0x0000) vector 53
ACPI: PCI Interrupt 0000:20:01.0[A] -> GSI 27 (level, low) -> IRQ 53
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities={Initiator,Target}
scsi0 : ioc0: LSI53C1030, FwRev032300h, Ports=1, MaxQ%5, IRQS
   Vendor: HP 73.4G  Model: MAS3735NC         Rev: HPC3
   Type:   Direct-Access                      ANSI SCSI revision: 03
  target0:0:0: Beginning Domain Validation
  target0:0:0: Ending Domain Validation
  target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI PCOMP (6.25 
ns, offse)
SCSI device sda: 143374738 512-byte hdwr sectors (73408 MB)
sda: Write Protect is off
SCSI device sda: drive cache: write through w/ FUA
SCSI device sda: 143374738 512-byte hdwr sectors (73408 MB)
sda: Write Protect is off
SCSI device sda: drive cache: write through w/ FUA
  sda: sda1 sda2 sda3
sd 0:0:0:0: Attached scsi disk sda
GSI 28 (level, low) -> CPU 0 (0x0000) vector 54
ACPI: PCI Interrupt 0000:20:01.1[B] -> GSI 28 (level, low) -> IRQ 54
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities={Initiator,Target}
scsi1 : ioc1: LSI53C1030, FwRev032300h, Ports=1, MaxQ%5, IRQT
Fusion MPT FC Host driver 3.04.01
Fusion MPT misc device (ioctl) driver 3.04.01
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor,220)
USB Universal Host Controller Interface driver v3.0
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Freeing unused kernel memory: 256kB freed
Red Hat nash version 5.0.32 starting
Mounting proc filesystem
Mounting sysfs filesystem
Creating /dev
Creating initial device nodes
Setting up hotplug.
Creating block device nodes.
Creating root device.
Mounting root filesystem.EXT3-fs: INFO: recovery required on readonly 
filesyste.

EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
Setting up other filesystems.
Setting up new root fs
Kernel panic - not syncing: Attempted to kill init!

Switching to ne w root and running init.
unmounting old /dev
unmounting old /proc
unmounting old /sys
WARNING: can't access
exec of init () failed!!!: No such file or directory


Regards,
  - jay

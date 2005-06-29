From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 29 Jun 2005 18:36:13 +0000
Subject: Re: problem booting -mm2 kernel on rx2600
Message-Id: <200506291236.14024.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

On Wednesday 29 June 2005 11:23 am, Stephane Eranian wrote:
> > softlockup thread 0 started up.
> > CPU 1: synchronized ITC with CPU 0 (last diff -4 cycles, maxerr 433 cycles)
> > Brought up 2 CPUs
> 
> Mine stops here. I did not enable that softlockup stuff.
> That leaves us with what is in between softlockup and the BogoMips
> stuff.

I should have mentioned that I was using defconfig.

> Tony Luck is also reporting that the latest GIT tree which includes
> lots of stuff from the -mm kernel does not boot either on his zx2000.

I did a mercurial pull this morning (should be the same as latest GIT,
I think), built defconfig, and it booted fine on my zx2000:

Linux version 2.6.13-rc1 (helgaas@tiger) (gcc version 3.3.5 (Debian 1:3.3.5-12)) #1 SMP Wed Jun 29 11:59:14 MDT 2005
EFI v1.10 by HP: SALsystab=0x3fb38000 ACPI 2.0=0x3fb2e000 SMBIOS=0x3fb3a000 HCDP=0x3fb2c000
booting generic kernel on platform hpzx1
PCDP: v0 at 0x3fb2c000
Early serial console at MMIO 0xff5e0000 (options '115200n8')
efi.trim_top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
efi.trim_top: ignoring 636KB of memory at 0x1000 due to granule hole at 0x0
efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule hole at 0x0
SAL 3.1: HP version 2.21
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
No logical to physical processor mapping available
ACPI: Local APIC address c0000000fee00000
GSI 47 (level, low) -> CPU 0 (0x0000) vector 48
1 CPUs available, 1 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffc7740000
Built 1 zonelists
Kernel command line: BOOT_IMAGE=net1:/helgaas/ia64/vmlinux.gz root=/dev/sda4 ro
PID hash table entries: 4096 (order: 12, 131072 bytes)
Console: colour VGA+ 80x25
Memory: 2511632k/2580560k available (6848k code, 82304k reserved, 3727k data, 352k init)
Leaving McKinley Errata 9 workaround enabled
Dentry cache hash table entries: 524288 (order: 8, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 7, 2097152 bytes)
Mount-cache hash table entries: 1024
Boot processor id 0x0/0x0
Brought up 1 CPUs
Total of 1 processors activated (1347.58 BogoMIPS).
NET: Registered protocol family 16
ACPI: Subsystem revision 20050309
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
ACPI: PCI Root Bridge [PCI4] (0000:80)
ACPI: PCI Root Bridge [PCI5] (0000:a0)
ACPI: PCI Root Bridge [PCI6] (0000:c0)
SCSI subsystem initialized
IOC: reserving 512Mb of IOVA space at 0x60000000 for agpgart
IOC: zx1 2.2 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Total HugeTLB memory allocated, 0
SGI XFS with large block/inode numbers, no debug enabled
Initializing Cryptographic API
EFI Time Services Driver v0.4
i8042.c: No controller found.
Serial: 8250/16550 driver $Revision: 1.90 $ 6 ports, IRQ sharing enabled
GSI 45 (edge, high) -> CPU 0 (0x0000) vector 49
ttyS0 at MMIO 0xff5e0000 (irq = 49) is a 16550A
GSI 46 (edge, high) -> CPU 0 (0x0000) vector 50
ttyS1 at MMIO 0xff5e2000 (irq = 50) is a 16550A
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
Intel(R) PRO/1000 Network Driver - version 6.0.60-k2
Copyright (c) 1999-2005 Intel Corporation.
GSI 42 (level, low) -> CPU 0 (0x0000) vector 51
ACPI: PCI Interrupt 0000:a0:03.0[A] -> GSI 42 (level, low) -> IRQ 51
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
netconsole: not configured, aborting
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
CMD649: IDE controller at PCI slot 0000:a0:02.0
GSI 43 (level, low) -> CPU 0 (0x0000) vector 52
ACPI: PCI Interrupt 0000:a0:02.0[A] -> GSI 43 (level, low) -> IRQ 52
CMD649: chipset revision 2
CMD649: 100% native mode on irq 52
    ide0: BM-DMA at 0xa0d0-0xa0d7, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0xa0d8-0xa0df, BIOS settings: hdc:pio, hdd:pio
hdc: Hewlett-Packard DVD Writer 100, ATAPI CD/DVD-ROM drive
hdd: HITACHI DVD-ROM GD-8000, ATAPI CD/DVD-ROM drive
ide1 at 0xa0e0-0xa0e7,0xa0f2 on irq 52
hdc: ATAPI 32X DVD-ROM CD-R/RW drive, 2048kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
hdd: ATAPI 40X DVD-ROM drive, 512kB Cache, UDMA(33)
ide-floppy driver 0.99.newide
GSI 29 (level, low) -> CPU 0 (0x0000) vector 53
ACPI: PCI Interrupt 0000:80:02.0[A] -> GSI 29 (level, low) -> IRQ 53
sym0: <1010-66> rev 0x1 at pci 0000:80:02.0 irq 53
sym0: Symbios NVRAM, ID 7, Fast-80, LVD, parity checking
sym0: open drain IRQ line driver, using on-chip SRAM
sym0: using LOAD/STORE-based firmware.
sym0: handling phase mismatch from SCRIPTS.
sym0: SCSI BUS has been reset.
scsi0 : sym-2.2.1
GSI 30 (level, low) -> CPU 0 (0x0000) vector 54
ACPI: PCI Interrupt 0000:80:02.1[B] -> GSI 30 (level, low) -> IRQ 54
sym1: <1010-66> rev 0x1 at pci 0000:80:02.1 irq 54
sym1: Symbios NVRAM, ID 7, Fast-80, LVD, parity checking
sym1: open drain IRQ line driver, using on-chip SRAM
sym1: using LOAD/STORE-based firmware.
sym1: handling phase mismatch from SCRIPTS.
sym1: SCSI BUS has been reset.
scsi1 : sym-2.2.1
  Vendor: HP 36.4G  Model: ST336706LW        Rev: HP03
  Type:   Direct-Access                      ANSI SCSI revision: 02
 target1:0:3: tagged command queuing enabled, command queue depth 16.
 target1:0:3: Beginning Domain Validation
 target1:0:3: asynchronous.
 target1:0:3: wide asynchronous.
 target1:0:3: FAST-80 WIDE SCSI 160.0 MB/s DT (12.5 ns, offset 62)
 target1:0:3: Ending Domain Validation
SCSI device sda: 71132960 512-byte hdwr sectors (36420 MB)
SCSI device sda: drive cache: write through
SCSI device sda: 71132960 512-byte hdwr sectors (36420 MB)
SCSI device sda: drive cache: write through
 sda: sda1 sda2 sda3 sda4 sda5 sda6
Attached scsi disk sda at scsi1, channel 0, id 3, lun 0
Fusion MPT base driver 3.03.02
Copyright (c) 1999-2005 LSI Logic Corporation
Fusion MPT SPI Host driver 3.03.02
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
NET: Registered protocol family 2
IP: routing cache hash table of 65536 buckets, 1024Kbytes
TCP established hash table entries: 2097152 (order: 11, 33554432 bytes)
TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
TCP: Hash tables configured (established 2097152 bind 65536)
TCP reno registered
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Adding console on ttyS0 at MMIO 0xff5e0000 (options '115200n8')
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 352kB freed
INIT: version 2.86 booting
Fixing console foreground/background
[0m[39m[49m
Activating swap.
Checking root file system...
fsck 1.35 (28-Feb-2004)
/dev/sda4 has gone 223 days without being checked, check forced.
/dev/sda4: |=                                                       |  1.8%   /dev/sda4: |=                                                      /  3.5%   /dev/sda4: |==                                                     -  5.2%   /dev/sda4: |==                                                    \  7.0%   /dev/sda4: |===                                                   |  8.8%   /dev/sda4: |===                                                  / 10.5%   /dev/sda4: |====                                                 - 12.2%   /dev/sda4: |====                                                \ 14.0%   /dev/sda4: |=====                                               | 15.8%   /dev/sda4: |=====                                              / 17.5%   /dev/sda4: |======                                             - 19.2%   /dev/sda4: |======                                            \ 21.0%   /dev/sda4: |=======                                          | 24.5%   /dev/sda4: |========                                         / 26.2%   /dev/sda4: |========                                        - 28.0%   /dev/sda4: |=========                                       \ 29.8%   /dev/sda4: |=========                                      | 31.5%   /dev/sda4: |==========                                     / 33.2%   /dev/sda4: |==========                                    - 35.0%   /dev/sda4: |===========                                   \ 36.8%   /dev/sda4: |===========                                  | 38.5%   /dev/sda4: |============                                 / 40.2%   /dev/sda4: |============                                - 42.0%   /dev/sda4: |=============                               \ 43.8%   /dev/sda4: |=============                               | 45.5%   /dev/sda4: |=============                              / 47.2%   /dev/sda4: |=============                             - 49.0%   /dev/sda4: |==============                            \ 50.8%   /dev/sda4: |===============                           | 52.5%   /dev/sda4: |===============                          / 54.2%   /dev/sda4: |================                        - 57.8%   /dev/sda4: |=================                       \ 59.5%   /dev/sda4: |=================                      | 61.2%   /dev/sda4: |==================                     / 63.0%   /dev/sda4: |==================                    - 64.8%   /dev/sda4: |===================                   \ 66.5%   /dev/sda4: |===================                  | 68.2%   /dev/sda4: |====================                 / 70.4%   /dev/sda4: |====================                - 71.0%   /dev/sda4: |====================                \ 71.6%   /dev/sda4: |====================                | 72.1%   /dev/sda4: |=====================               / 72.4%   /dev/sda4: |=====================               - 73.2%   /dev/sda4: |=====================               \ 73.6%   /dev/sda4: |=====================               | 74.0%   /dev/sda4: |=====================              / 74.6%   /dev/sda4: |=====================              - 75.0%   /dev/sda4: |=====================              \ 75.6%   /dev/sda4: |======================             | 76.2%   /dev/sda4: |======================             / 76.7%   /dev/sda4: |======================             - 77.5%   /dev/sda4: |======================            \ 78.0%   /dev/sda4: |=============
=========            | 79.1%   /dev/sda4: |=======================           / 80.0%   /dev/sda4: |=======================           - 80.7%   /dev/sda4: |=======================           \ 81.2%   /dev/sda4: |=======================          | 81.7%   /dev/sda4: |=======================          / 82.1%   /dev/sda4: |=======================          - 82.5%   /dev/sda4: |=======================          \ 83.0%   /dev/sda4: |========================         | 83.5%   /dev/sda4: |========================         / 83.9%   /dev/sda4: |========================         - 84.5%   /dev/sda4: |========================        \ 85.1%   /dev/sda4: |========================        | 85.4%   /dev/sda4: |========================        / 85.8%   /dev/sda4: |========================        - 86.3%   /dev/sda4: |=========================       \ 87.1%   /dev/sda4: |=========================       | 87.6%   /dev/sda4: |=========================       / 88.2%   /dev/sda4: |=========================      - 88.8%   /dev/sda4: |=========================      \ 89.3%   /dev/sda4: |=========================      | 89.6%   /dev/sda4: |==========================    / 92.4%   /dev/sda4: |===========================   - 95.1%   /dev/sda4: |============================ \ 97.9%   /dev/sda4: |============================| 100.0%                                                                                  /dev/sda4: 46543/640000 files (1.6% non-contiguous), 36
1332/1280000 blocks
EXT3 FS on sda4, internal journal
System time was Wed Jun 29 18:33:12 UTC 2005.
Setting the System Clock using the Hardware Clock as reference...
System Clock set. System local time is now Wed Jun 29 18:33:14 UTC 2005.
Cleaning up ifupdown...done.
Not running depmod because /lib/modules/2.6.13-rc1/ is not writeable.
Loading modules...
All modules loaded.
FATAL: Could not load /lib/modules/2.6.13-rc1/modules.dep: No such file or directory
Checking all file systems...
fsck 1.35 (28-Feb-2004)
Setting kernel variables ...
... done.
Mounting local filesystems...
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on sda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
/dev/sda5 on /home type ext3 (rw)
Cleaning /tmp /var/run /var/lock.
Discovering hardware: snd-fm801 sym53c8xx ohci-hcd cmd64x e100 e1000
FATAL: Could not load /lib/modules/2.6.13-rc1/modules.dep: No such file or directory
Skipping snd-fm801; assuming it is compiled into the kernel.
FATAL: Could not load /lib/modules/2.6.13-rc1/modules.dep: No such file or directory
Skipping sym53c8xx; assuming it is compiled into the kernel.
FATAL: Could not load /lib/modules/2.6.13-rc1/modules.dep: No such file or directory
Skipping ohci-hcd; assuming it is compiled into the kernel.
FATAL: Could not load /lib/modules/2.6.13-rc1/modules.dep: No such file or directory
Skipping cmd64x; assuming it is compiled into the kernel.
FATAL: Could not load /lib/modules/2.6.13-rc1/modules.dep: No such file or directory
Skipping e100; assuming it is compiled into the kernel.
FATAL: Could not load /lib/modules/2.6.13-rc1/modules.dep: No such file or directory
Skipping e1000; assuming it is compiled into the kernel.
Running 0dns-down to make sure resolv.conf is ok...done.
Initializing: /etc/network/ifstate.
Setting up IP spoofing protection: rp_filter.
Configuring network interfaces...Internet Software Consortium DHCP Client 2.0pl5
Copyright 1995, 1996, 1997, 1998, 1999 The Internet Software Consortium.
All rights reserved.

Please contribute if you find this software useful.
For info, please visit http://www.isc.org/dhcp-contrib.html

e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
Listening on LPF/eth0/00:30:6e:1e:be:58
Sending on   LPF/eth0/00:30:6e:1e:be:58
Sending on   Socket/fallback/fallback-net
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 7
DHCPOFFER from 10.0.0.1
DHCPREQUEST on eth0 to 255.255.255.255 port 67
DHCPACK from 10.0.0.1
bound to 10.36.62.103 -- renewal in 129600 seconds.
done.
Starting portmap daemon: portmap.
Loading the saved-state of the serial devices... 
/dev/ttyS0 at 0x0000 (irq = 49) is a 16550A
/dev/ttyS1 at 0x0000 (irq = 72) is a 16550A

Setting the System Clock using the Hardware Clock as reference...
System Clock set. Local time: Wed Jun 29 12:33:19 MDT 2005

Initializing random number generator...done.
Recovering nvi editor sessions... done.
Setting up X server socket directory /tmp/.X11-unix...done.
Setting up ICE socket directory /tmp/.ICE-unix...done.
INIT: Entering runlevel: 2
Starting system log daemon: syslogd.
Starting kernel log daemon: klogd.
Starting portmap daemon: portmap.
Starting internet superserver: inetd.
Starting printer spooler: lpd .
Starting OpenBSD Secure Shell server: sshd.
Starting NFS common utilities: statd.
Starting deferred execution scheduler: atd.
Starting periodic command scheduler: cron.

Debian GNU/Linux 3.1 wilson ttyS0

wilson login: 

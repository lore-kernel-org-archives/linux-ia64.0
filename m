From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Thu, 09 Nov 2006 13:22:59 +0000
Subject: Re: elilo.efi causing Kernel Panic
Message-Id: <5e0a1fd80611090510i794bb96h30d45787bae459f5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061109124221.GL16952@parisc-linux.org>
In-Reply-To: <20061109124221.GL16952@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I booted from the original elilo.efi binary, the console log was
a bit different. I have listed it below. My efi binary seems to have
detected some RAM Disk when this one doesn't. Hope this helps.

Initializing IPsec netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
Freeing unused kernel memory: 384kB freed
Red Hat nash version 4.2.1.6 starting
Mounted /proc filesystem
Mounting sysfs
Creating /dev
Starting udev
Loading scsi_mod.ko module
SCSI subsystem initialized
Loading sd_mod.ko module
Loading mptbase.ko module
Fusion MPT base driver 3.02.18


On 11/9/06, Karthik Gopalakrishnan <karthik.g.krishnan@gmail.com> wrote:
> Hi Matthew.
>
>     Here is the complete listing. Sorry about the verbose information.
>
> ----------------------------------
>
> fs0:\EFI\redhat> elilo
>
> ELILO boot: Uncompressing Linux... done
> Loading initrd initrd-2.6.9-22.EL.img...done
> Linux version 2.6.9-22.EL (bhcompile@boris.devel.redhat.com) (gcc
> version 3.4.4 20050721 (Red Hat 3.4.4-2)) #1 SMP Mon Sep 19 17:54:55
> EDT 2005
> EFI v1.10 by HP: SALsystab=0x743fcf1a938 ACPI 2.0=0x743fd310000
> HCDP=0x743fd341838 SMBIOS=0x7fffe000
> booting generic kernel on platform hpzx1
> Number of logical nodes in system = 2
> Number of memory chunks in system = 4
> warning: skipping physical page 0
> efi.trim_top: ignoring 1288KB of memory at 0x40febfe000 due to granule
> hole at 0x40ff000000
> efi.trim_top: ignoring 32KB of memory at 0x40ff142000 due to granule
> hole at 0x40ff000000
> efi.trim_top: ignoring 8KB of memory at 0x40ff14a000 due to granule
> hole at 0x40ff000000
> efi.trim_top: ignoring 4808KB of memory at 0x40ff14c000 due to granule
> hole at 0x40ff000000
> efi.trim_top: ignoring 2664KB of memory at 0x40ff5fe000 due to granule
> hole at 0x40ff000000
> efi.trim_top: ignoring 248KB of memory at 0x40ff898000 due to granule
> hole at 0x40ff000000
> efi.trim_top: ignoring 784KB of memory at 0x40ff912000 due to granule
> hole at 0x40ff000000
> efi.trim_top: ignoring 1368KB of memory at 0x40ffa7e000 due to granule
> hole at 0x40ff000000
> warning: skipping physical page 0
> warning: skipping physical page 0
> Initial ramdisk at: 0xe0000040fe9fb000 (1708032 bytes)
> SAL 3.20: HP Orca/IPF version 6.26
> SAL Platform features: None
> SAL: AP wakeup using external interrupt vector 0xff
> ACPI: Local APIC address c0000000fee00000
> GSI 16 (level, low) -> CPU 0 (0x0002) vector 48
> 8 CPUs available, 8 CPUs total
> PCDP: v3 at 0xe0000743fd341838
> PCDP: serial console at MMIO 0xf0200040000 (ttyS0, options 9600n8)
> MCA related initialization done
> warning: skipping physical page 0
> Virtual mem_map starts at 0xa0007fffc720c000
> Built 1 zonelists
> Kernel command line: BOOT_IMAGE=scsi0:\EFI\redhat\vmlinuz-2.6.9-22.EL
> console=ttyS0 rhgb root=LABEL=/ ro
> PID hash table entries: 4096 (order: 12, 131072 bytes)
> Console: colour dummy device 80x25
> Dentry cache hash table entries: 2097152 (order: 10, 16777216 bytes)
> Inode-cache hash table entries: 1048576 (order: 9, 8388608 bytes)
> Memory: 16593664k/16682912k available (5611k code, 101232k reserved,
> 2260k data, 384k init)
> McKinley Errata 9 workaround not needed; disabling it
> Security Scaffold v1.0.0 initialized
> SELinux:  Initializing.
> SELinux:  Starting in permissive mode
> There is already a security framework initialized, register_security failed.
> selinux_register_security:  Registering secondary module capability
> Capability LSM initialized as secondary
> Mount-cache hash table entries: 1024 (order: 0, 16384 bytes)
> Boot processor id 0x0/0x2
> task migration cache decay timeout: 10 msecs.
> CPU 1: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 443 cycles)
> CPU 2: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 763 cycles)
> CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 763 cycles)
> CPU 4: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 1764 cycles)
> CPU 5: synchronized ITC with CPU 0 (last diff 2 cycles, maxerr 1764 cycles)
> CPU 6: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 1764 cycles)
> CPU 7: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 1764 cycles)
> Brought up 8 CPUs
> Total of 8 processors activated (13160.32 BogoMIPS).
> checking if image is initramfs...it isn't (ungzip failed); looks like an initrd
> Freeing initrd memory: 1664kB freed
> NET: Registered protocol family 16
> ACPI: Subsystem revision 20040816
> ACPI: Interpreter enabled
> ACPI: Using IOSAPIC for interrupt routing
> ACPI: PCI Root Bridge [L000] (02:00)
> ACPI: PCI Root Bridge [L001] (02:15)
> ACPI: PCI Root Bridge [L002] (02:2a)
> ACPI: PCI Root Bridge [L003] (02:3f)
> ACPI: PCI Root Bridge [L004] (02:54)
> ACPI: PCI Root Bridge [L006] (02:69)
> ACPI: PCI Root Bridge [L008] (02:7e)
> ACPI: PCI Root Bridge [L009] (02:93)
> ACPI: PCI Root Bridge [L010] (02:a8)
> ACPI: PCI Root Bridge [L011] (02:be)
> ACPI: PCI Root Bridge [L012] (02:d4)
> ACPI: PCI Root Bridge [L014] (02:ea)
> usbcore: registered new driver usbfs
> usbcore: registered new driver hub
> PCI: Using ACPI for IRQ routing
> GSI 24 (level, low) -> CPU 1 (0x0102) vector 49
> ACPI: PCI interrupt 0002:00:00.0[A] -> GSI 24 (level, low) -> IRQ 49
> ACPI: PCI interrupt 0002:00:01.0[A] -> GSI 24 (level, low) -> IRQ 49
> GSI 35 (level, low) -> CPU 2 (0x0402) vector 50
> ACPI: PCI interrupt 0002:15:01.0[A] -> GSI 35 (level, low) -> IRQ 50
> GSI 36 (level, low) -> CPU 3 (0x0502) vector 51
> ACPI: PCI interrupt 0002:15:01.1[B] -> GSI 36 (level, low) -> IRQ 51
> GSI 57 (level, low) -> CPU 4 (0x0802) vector 52
> ACPI: PCI interrupt 0002:40:04.0[A] -> GSI 57 (level, low) -> IRQ 52
> GSI 58 (level, low) -> CPU 5 (0x0902) vector 53
> ACPI: PCI interrupt 0002:40:04.1[B] -> GSI 58 (level, low) -> IRQ 53
> GSI 59 (level, low) -> CPU 6 (0x0c02) vector 54
> ACPI: PCI interrupt 0002:40:06.0[A] -> GSI 59 (level, low) -> IRQ 54
> GSI 60 (level, low) -> CPU 7 (0x0d02) vector 55
> ACPI: PCI interrupt 0002:40:06.1[B] -> GSI 60 (level, low) -> IRQ 55
> GSI 90 (level, low) -> CPU 0 (0x0002) vector 56
> ACPI: PCI interrupt 0002:7e:01.0[A] -> GSI 90 (level, low) -> IRQ 56
> GSI 145 (level, low) -> CPU 1 (0x0102) vector 57
> ACPI: PCI interrupt 0002:eb:04.0[A] -> GSI 145 (level, low) -> IRQ 57
> GSI 146 (level, low) -> CPU 2 (0x0402) vector 58
> ACPI: PCI interrupt 0002:eb:04.1[B] -> GSI 146 (level, low) -> IRQ 58
> GSI 147 (level, low) -> CPU 3 (0x0502) vector 59
> ACPI: PCI interrupt 0002:eb:06.0[A] -> GSI 147 (level, low) -> IRQ 59
> GSI 148 (level, low) -> CPU 4 (0x0802) vector 60
> ACPI: PCI interrupt 0002:eb:06.1[B] -> GSI 148 (level, low) -> IRQ 60
> IOC: sx1000 0.1 HPA 0xf8220002000 IOVA space 1024Mb at 0x80000000
> IOC: sx1000 0.1 HPA 0xf8220003000 IOVA space 1024Mb at 0x80000000
> perfmon: version 2.0 IRQ 238
> perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
> PAL Information Facility v0.5
> perfmon: added sampling format default_format
> perfmon_default_smpl: default_format v2.0 registered
> audit: initializing netlink socket (disabled)
> audit(1163076642.940:1): initialized
> Total HugeTLB memory allocated, 0
> VFS: Disk quotas dquot_6.5.1
> Dquot-cache hash table entries: 2048 (order 0, 16384 bytes)
> SELinux:  Registering netfilter hooks
> Initializing Cryptographic API
> ksign: Installing public key data
> Loading keyring
> - Added public key 453B8631FE6159D3
> - User ID: Red Hat, Inc. (Kernel Module GPG key)
> pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> ACPI: Processor [P016] (supports C1)
> ACPI: Processor [P017] (supports C1)
> ACPI: Processor [P018] (supports C1)
> ACPI: Processor [P019] (supports C1)
> ACPI: Processor [P020] (supports C1)
> ACPI: Processor [P021] (supports C1)
> ACPI: Processor [P022] (supports C1)
> ACPI: Processor [P023] (supports C1)
> EFI Time Services Driver v0.4
> Linux agpgart interface v0.100 (c) Dave Jones
> i8042.c: No controller found.
> Serial: 8250/16550 driver $Revision: 1.90 $ 20 ports, IRQ sharing enabled
> tyS0 at MMIO 0xf0200040000 (irq = 49) is a 16550A
> ACPI: PCI interrupt 0002:00:00.0[A] -> GSI 24 (level, low) -> IRQ 49
> ttyS1 at MMIO 0xf0200040008 (irq = 49) is a 16550A
> ttyS2 at MMIO 0xf0200040010 (irq = 49) is a 16550A
> RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
> ide-floppy driver 0.99.newide
> usbcore: registered new driver hiddev
> usbcore: registered new driver usbhid
> drivers/usb/input/hid-core.c: v2.0:USB HID core driver
> mice: PS/2 mouse device common for all mice
> md: md driver 0.90.0 MAX_MD_DEVS%6, MD_SB_DISKS'
> EFI Variables Facility v0.08 2004-May-17
> NET: Registered protocol family 2
> IP: routing cache hash table of 262144 buckets, 4096Kbytes
> TCP: Hash tables configured (established 8388608 bind 65536)
> Initializing IPsec netlink socket
> NET: Registered protocol family 1
> NET: Registered protocol family 17
> md: Autodetecting RAID arrays.
> md: autorun ...
> md: ... autorun DONE.
> RAMDISK: Compressed image found at block 0
> Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
>
> ----------------------------------
>
> On 11/9/06, Matthew Wilcox <matthew@wil.cx> wrote:
> > On Thu, Nov 09, 2006 at 06:04:04PM +0530, Karthik Gopalakrishnan wrote:
> > > image=vmlinuz-2.6.9-22.EL
> > >        label=linux
> > >        initrd=initrd-2.6.9-22.EL.img
> > >        read-only
> > >        append="console=ttyS0 rhgb quiet root=LABEL=/"
> >
> > If you take the "quiet" out, you'll get a lot more information during
> > the boot, and we may be able to diagnose your problem.
> >
> > > fs0:\EFI\redhat> elilo
> > >
> > > ELILO boot: Uncompressing Linux... done
> > > Loading initrd initrd-2.6.9-22.EL.img...done
> > > i8042.c: No controller found.
> > > ernel panic - not syncing: VFS: Unable to mount root fs on
> > > unknown-block(0,0)
> > >
> > >    Any help will be greatly appreciated.
> > >
> > > Regards,
> > > Karthik
> > > -
> > > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>

From: Horms <horms@verge.net.au>
Date: Thu, 08 Feb 2007 07:36:35 +0000
Subject: Re: Zero size /proc/vmcore on ia64
Message-Id: <20070208073632.GD23574@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 08, 2007 at 12:21:02PM +0800, Zou Nan hai wrote:
> On Thu, 2007-02-08 at 13:34, Vivek Goyal wrote:
> > On Thu, Feb 08, 2007 at 12:06:53PM +0900, Horms wrote:
> > > On Thu, Feb 08, 2007 at 10:07:48AM +0800, Zou, Nanhai wrote:
> > > > 
> > > > When crash dump kernel tries to access memory of first kernel
> > > > above saved_max_pfn of him, read_from_oldmem will refuse that
> > > > read.
> > > > 
> > > > That result an empty vmcore file. change saved_max_pfn to
> > > > unsigned long(-1) will fix this issue.
> > > > 
> > > > However since memory ranges in vmcore is pre defined from
> > > > /proc/iomem of first kernel, why do we still need to add an
> > > > extra check in vmcore.c
> > > 
> > > Hi Nan-hai,
> > > 
> > > sorry that I did not get back to you about the information you
> > > requested about my system, I guess you have managed to reproduce
> > > the problem none the less.
> > > 
> > > I can confirm that removing the max_pfn check in vmcore.c does
> > > indeed give /proc/vmcore a non-zero (and presumably correct) size.
> > > 
> > > I wonder if the problem is that saved_max_pfn is being incorectly
> > > calculated on ia64. That it is being set to the max_pfn of the
> > > crash kernel (i.e. in the crashkernel=X@Y area), rather than the
> > > max_pfn of the physical memory of the system, which seems more
> > > sensible as the purpose of vmcore is to read memory outside of the
> > > crashkernel=X@Y area.
> > > 
> > 
> > Hi Horms/Nan-hai,
> > 
> > Horms, you are right. saved_max_pfn is needed to know that second
> > kernel is not trying to read any memory which is not present or was
> > not being used by the crashed kernel at all. That's why in
> > i386/x86_64, during early boot saved_max_pfn, is calculated the
> > memory map passed to the second kernel. This memory map is passed to
> > second kernel by kexec through parameter segment. So effectively
> > saved_max_pfn will be set to max_pfn of crashed kernel.
> > 
> > Now this memory map is overwritten with user defined one which is
> > basically the memory second kernel can use to boot and max_pfn now
> > will be maximum pfn crash kernel can use.
> > 
> > > You may be right that we can just remove the check all together,
> > > though perhaps it is there for the case where the range
> > > information in the vmcode are corrupted. Then again, should we
> > > care about this?
> > 
> > I think we should not remove this check because even to parse the
> > info passed in ELF headers, you need to first read the ELF headers
> > from crashed kernel's memory. So if some programming error has
> > passed wrong location of ELF headers (elfcoreheader= invalid
> > location) then we might try reading the elf header from a
> > non-existing physical page frame.
> > 
> > So the right way should be to set saved_max_pfn with right value
> > before it is memory map is over-written with user defined memory
> > map.
> > 
> 	This is reasonable.  
>       So please apply the following patch to make
> 	saved_max_pfn point to max_pfn of entire system.

Hi Nanhai,

Although I agree with the gist of your patch, unfortunately it does
not work on my system. Perhaps this is because I use discontig memory,
perhaps its todo with my map. But in any case /proc/vmcore remains zero.

read_from_oldmem: error: pfn (32761) > saved_max_pfn (31744)
Kdump: vmcore not initialized

Below is your patch rediffed for Linus latest tree.
And below that is the boot log for my first and crash kernels,
including the EFI map. Let me know if you need some more information
or would like me to run any additional tests.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

	Please apply the following patch to make saved_max_pfn point to
max_pfn of entire system.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Updated for recent changes in Linus' tree.
But it doesn't seem to work as desired on my system :(

Nacked-by: Simon Horman <horms@verge.net.au>
Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-02-08 16:06:02.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-02-08 16:06:40.000000000 +0900
@@ -21,6 +21,7 @@
  *	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/module.h>
+#include <linux/bootmem.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/types.h>
@@ -1010,6 +1011,11 @@
 		} else
 			ae = efi_md_end(md);
 
+#ifdef CONFIG_CRASH_DUMP
+		/* saved_max_pfn should ignore max_addr= command line arg */ 
+		if (saved_max_pfn < (ae >> PAGE_SHIFT))
+			saved_max_pfn = (ae >> PAGE_SHIFT);
+#endif
 		/* keep within max_addr= and min_addr= command line arg */
 		as = max(as, min_addr);
 		ae = min(ae, max_addr);
Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2007-02-08 16:06:02.000000000 +0900
+++ linux-2.6/arch/ia64/mm/contig.c	2007-02-08 16:06:40.000000000 +0900
@@ -197,11 +197,6 @@
 
 	find_initrd();
 
-#ifdef CONFIG_CRASH_DUMP
-	/* If we are doing a crash dump, we still need to know the real mem
-	 * size before original memory map is reset. */
-	saved_max_pfn = max_pfn;
-#endif
 }
 
 #ifdef CONFIG_SMP
Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2007-02-08 16:06:23.000000000 +0900
+++ linux-2.6/arch/ia64/mm/discontig.c	2007-02-08 16:06:40.000000000 +0900
@@ -478,12 +478,6 @@
 	max_pfn = max_low_pfn;
 
 	find_initrd();
-
-#ifdef CONFIG_CRASH_DUMP
-	/* If we are doing a crash dump, we still need to know the real mem
-	 * size before original memory map is reset. */
-        saved_max_pfn = max_pfn;
-#endif
 }
 
 #ifdef CONFIG_SMP

ELILO
Uncompressing Linux... done
Loading initrd people/horms/initramfs_data.cpio.gz...done
Linux version 2.6.20-kexec-g5331be09-dirty (horms@tabatha.lab.ultramonkey.org) (gcc version 3.4.5) #18 Thu Feb 8 16:26:47 JST 2007
EFI v1.10 by INTEL: SALsystab=0x7fe54980 ACPI=0x7ff99000 ACPI 2.0=0x7ff98000 MPS=0x7ff97000 SMBIOS=0xf0000
mem00: type=4, attr=0x9, range=[0x0000000000000000-0x0000000000001000) (0MB)
mem01: type=7, attr=0x9, range=[0x0000000000001000-0x0000000000007000) (0MB)
mem02: type=4, attr=0x9, range=[0x0000000000007000-0x0000000000009000) (0MB)
mem03: type=7, attr=0x9, range=[0x0000000000009000-0x0000000000082000) (0MB)
mem04: type=6, attr=0x8000000000000009, range=[0x0000000000082000-0x0000000000084000) (0MB)
mem05: type=7, attr=0x9, range=[0x0000000000084000-0x0000000000085000) (0MB)
mem06: type=4, attr=0x9, range=[0x0000000000085000-0x00000000000a0000) (0MB)
mem07: type=5, attr=0x8000000000000009, range=[0x00000000000c0000-0x0000000000100000) (0MB)
mem08: type=7, attr=0xb, range=[0x0000000000100000-0x0000000004000000) (63MB)
mem09: type=2, attr=0xb, range=[0x0000000004000000-0x0000000004644000) (6MB)
mem10: type=7, attr=0xb, range=[0x0000000004644000-0x000000000ffc0000) (185MB)
mem11: type=4, attr=0xb, range=[0x000000000ffc0000-0x0000000010000000) (0MB)
mem12: type=7, attr=0xb, range=[0x0000000010000000-0x000000007af6c000) (1711MB)
mem13: type=2, attr=0xb, range=[0x000000007af6c000-0x000000007c8d2000) (25MB)
mem14: type=1, attr=0xb, range=[0x000000007c8d2000-0x000000007c92e000) (0MB)
mem15: type=2, attr=0xb, range=[0x000000007c92e000-0x000000007c938000) (0MB)
mem16: type=1, attr=0xb, range=[0x000000007c938000-0x000000007c97e000) (0MB)
mem17: type=7, attr=0xb, range=[0x000000007c97e000-0x000000007ce16000) (4MB)
mem18: type=4, attr=0xb, range=[0x000000007ce16000-0x000000007ce1c000) (0MB)
mem19: type=7, attr=0xb, range=[0x000000007ce1c000-0x000000007ce20000) (0MB)
mem20: type=4, attr=0xb, range=[0x000000007ce20000-0x000000007ce22000) (0MB)
mem21: type=7, attr=0xb, range=[0x000000007ce22000-0x000000007ce2a000) (0MB)
mem22: type=4, attr=0xb, range=[0x000000007ce2a000-0x000000007d001000) (1MB)
mem23: type=7, attr=0xb, range=[0x000000007d001000-0x000000007d002000) (0MB)
mem24: type=4, attr=0xb, range=[0x000000007d002000-0x000000007d004000) (0MB)
mem25: type=7, attr=0xb, range=[0x000000007d004000-0x000000007d026000) (0MB)
mem26: type=4, attr=0xb, range=[0x000000007d026000-0x000000007d068000) (0MB)
mem27: type=7, attr=0xb, range=[0x000000007d068000-0x000000007d069000) (0MB)
mem28: type=4, attr=0xb, range=[0x000000007d069000-0x000000007d37e000) (3MB)
mem29: type=7, attr=0xb, range=[0x000000007d37e000-0x000000007d700000) (3MB)
mem30: type=3, attr=0xb, range=[0x000000007d700000-0x000000007d77e000) (0MB)
mem31: type=7, attr=0xb, range=[0x000000007d77e000-0x000000007d8b4000) (1MB)
mem32: type=6, attr=0x8000000000000009, range=[0x000000007d8b4000-0x000000007d900000) (0MB)
mem33: type=3, attr=0xb, range=[0x000000007d900000-0x000000007f980000) (32MB)
mem34: type=7, attr=0xb, range=[0x000000007f980000-0x000000007fa00000) (0MB)
mem35: type=5, attr=0x8000000000000009, range=[0x000000007fa00000-0x000000007fe00000) (4MB)
mem36: type, attr=0x8000000000000009, range=[0x000000007fe00000-0x000000007fe48000) (0MB)
mem37: type=5, attr=0x8000000000000009, range=[0x000000007fe48000-0x000000007fea0000) (0MB)
mem38: type=7, attr=0xb, range=[0x000000007fea0000-0x000000007feda000) (0MB)
mem39: type=5, attr=0x8000000000000009, range=[0x000000007feda000-0x000000007ff46000) (0MB)
mem40: type=6, attr=0x8000000000000009, range=[0x000000007ff46000-0x0000000080000000) (0MB)
mem41: type, attr=0x1, range=[0x00000000fe000000-0x00000000ff000000) (16MB)
mem42: type=6, attr=0x8000000000000001, range=[0x00000000ff000000-0x0000000100000000) (16MB)
mem43: type, attr=0x8000000000000001, range=[0x00000ffff8000000-0x00000ffffc000000) (64MB)
mem44: type, attr=0x8000000000000001, range=[0x00000ffffc000000-0x0000100000000000) (64MB)
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200')
Initial ramdisk at: 0xe00000007af72000 (9789052 bytes)
SAL 3.20: Intel Corp                       SR870BH2                         version 3.0
SAL Platform features: BusLock
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address c0000000fee00000
ACPI: [APIC:0x07] ignored 1 entries of 2 found
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0100) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
1 CPUs available, 1 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffff900000
Zone PFN ranges:
  DMA          1024 ->   262144
  Normal     262144 ->   262144
early_node_map[3] active PFN ranges
    0:     1024 ->   128557
    0:   128576 ->   130688
    0:   130984 ->   130998
Built 1 zonelists.  Total pages: 129215
Kernel command line: BOOT_IMAGE=net0:ia64/people/horms/vmlinux.gz  phys_efi console=uart,io,0x2f8,115200 crashkernel%6M loglevel=7 ro
PID hash table entries: 4096 (order: 12, 32768 bytes)
Console: colour VGA+ 80x25
Placing 64MB software IO TLB between 0x4644000 - 0x8644000
Memory: 1722416k/1796368k available (3010k code, 352128k reserved, 2124k data, 640k init)
McKinley Errata 9 workaround not needed; disabling it
Dentry cache hash table entries: 262144 (order: 7, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
Mount-cache hash table entries: 1024
ACPI: Core revision 20060707
DMI 2.3 present.
ACPI: bus type pci registered
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI quirk: region 0c00-0c7f claimed by ICH4 ACPI/GPIO/TCO
PCI quirk: region 0500-053f claimed by ICH4 GPIO
ACPI: PCI Root Bridge [PCI1] (0000:02)
ACPI: PCI Root Bridge [PCI2] (0000:05)
ACPI: Device [CSFF] status [00000008]: functional but not present; setting present
ACPI: PCI Root Bridge [CSFF] (0000:ff)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 12 devices
checking if image is initramfs... it is
Freeing initrd memory: 9536kB freed
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
io scheduler noop registered
io scheduler anticipatory registered (default)
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
00:08: ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
00:09: ttyS1 at I/O 0x2f8 (irq = 45) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
Adding console on ttyS1 at I/O port 0x2f8 (options '115200')
Freeing unused kernel memory: 640kB freed
init started:  BusyBox v1.2.1 (2006.09.23-05:46+0000) multi-call binary
Starting pid 772, console /dev/console: '/etc/init.d/rcS'
ifconfig: socket: Function not implemented
ifconfig: No usable address families found.
ifconfig: socket: Function not implemented
Starting pid 890, console /dev/console: '/bin/sh'


BusyBox v1.2.1 (2006.09.23-05:46+0000) Built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ # do_kdump
Create ramdisk
Load kernel and ramdisk
kexec -p "/boot/vmlinux-ia64-kdump.gz" --initrd=/tmp/initramfs_data.cpio \
    --append="phys_efi clock=pit ip=on apm=power-off console=tty0 loglevel=7 console=uart,io,0x2f8,115200n8 init 1 irqpoll maxcpus=1" 
Triggering KdumpSysRq : Trigger a crashdump
Linux version 2.6.20-kexec-g5331be09-dirty (horms@tabatha.lab.ultramonkey.org) (gcc version 3.4.5) #18 Thu Feb 8 16:26:47 JST 2007
Ignoring memory below 256MB
Ignoring memory above 512MB
EFI v1.10 by INTEL: SALsystab=0x7fe54980 ACPI=0x7ff99000 ACPI 2.0=0x7ff98000 MPS=0x7ff97000 SMBIOS=0xf0000
mem00: type=4, attr=0x9, range=[0x0000000000000000-0x0000000000001000) (0MB)
mem01: type=7, attr=0x9, range=[0x0000000000001000-0x0000000000007000) (0MB)
mem02: type=4, attr=0x9, range=[0x0000000000007000-0x0000000000009000) (0MB)
mem03: type=7, attr=0x9, range=[0x0000000000009000-0x0000000000082000) (0MB)
mem04: type=6, attr=0x8000000000000009, range=[0x0000000000082000-0x0000000000084000) (0MB)
mem05: type=7, attr=0x9, range=[0x0000000000084000-0x0000000000085000) (0MB)
mem06: type=4, attr=0x9, range=[0x0000000000085000-0x00000000000a0000) (0MB)
mem07: type=5, attr=0x8000000000000009, range=[0x00000000000c0000-0x0000000000100000) (0MB)
mem08: type=7, attr=0xb, range=[0x0000000000100000-0x0000000004000000) (63MB)
mem09: type=7, attr=0xb, range=[0x0000000004000000-0x0000000004644000) (6MB)
mem10: type=7, attr=0xb, range=[0x0000000004644000-0x000000000ffc0000) (185MB)
mem11: type=4, attr=0xb, range=[0x000000000ffc0000-0x0000000010000000) (0MB)
mem12: type=2, attr=0xb, range=[0x0000000010000000-0x0000000010490000) (4MB)
mem13: type=2, attr=0xb, range=[0x0000000010490000-0x00000000104a0000) (0MB)
mem14: type=2, attr=0xb, range=[0x00000000104a0000-0x0000000010650000) (1MB)
mem15: type=7, attr=0xb, range=[0x0000000010650000-0x000000001ffe4000) (249MB)
mem16: type=8, attr=0x5555555555555555, range=[0x000000001ffe4000-0x600000001fff2000) (6597069766656MB)
mem17: type=7, attr=0x5555555555555555, range=[0x600000001fff2350-0x5151515151514350) (16583222432533MB)
efi_get_pal_addr: no PAL-code memory-descriptor found
No I/O port range found in EFI memory map, falling back to AR.KR0 (0xffffc000000)
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200n8')
Initial ramdisk at: 0xe00000001f544000 (10977792 bytes)
SAL 3.20: Intel Corp                       SR870BH2                         version 3.0
SAL Platform features: BusLock
efi_get_pal_addr: no PAL-code memory-descriptor found
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address c0000000fee00000
ACPI: [APIC:0x07] ignored 1 entries of 2 found
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0100) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
1 CPUs available, 1 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffc80000
Zone PFN ranges:
  DMA         16384 ->   262144
  Normal     262144 ->   262144
early_node_map[1] active PFN ranges
    0:    16384 ->    31744
Built 1 zonelists.  Total pages: 15308
Kernel command line: phys_efi clock=pit ip=on apm=power-off console=tty0 loglevel=7 console=uart,io,0x2f8,115200n8 init 1 irqpoll maxcpus=1 elfcorehdrR4176K max_addrQ2M min_addr%6M
Warning! clock= boot option is deprecated. Use clocksource=xyz
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
PID hash table entries: 1024 (order: 10, 8192 bytes)
Console: colour dummy device 80x25
Linux version 2.6.20-kexec-g5331be09-dirty (horms@tabatha.lab.ultramonkey.org) (gcc version 3.4.5) #18 Thu Feb 8 16:26:47 JST 2007
Ignoring memory below 256MB
Ignoring memory above 512MB
EFI v1.10 by INTEL: SALsystab=0x7fe54980 ACPI=0x7ff99000 ACPI 2.0=0x7ff98000 MPS=0x7ff97000 SMBIOS=0xf0000
mem00: type=4, attr=0x9, range=[0x0000000000000000-0x0000000000001000) (0MB)
mem01: type=7, attr=0x9, range=[0x0000000000001000-0x0000000000007000) (0MB)
mem02: type=4, attr=0x9, range=[0x0000000000007000-0x0000000000009000) (0MB)
mem03: type=7, attr=0x9, range=[0x0000000000009000-0x0000000000082000) (0MB)
mem04: type=6, attr=0x8000000000000009, range=[0x0000000000082000-0x0000000000084000) (0MB)
mem05: type=7, attr=0x9, range=[0x0000000000084000-0x0000000000085000) (0MB)
mem06: type=4, attr=0x9, range=[0x0000000000085000-0x00000000000a0000) (0MB)
mem07: type=5, attr=0x8000000000000009, range=[0x00000000000c0000-0x0000000000100000) (0MB)
mem08: type=7, attr=0xb, range=[0x0000000000100000-0x0000000004000000) (63MB)
mem09: type=7, attr=0xb, range=[0x0000000004000000-0x0000000004644000) (6MB)
mem10: type=7, attr=0xb, range=[0x0000000004644000-0x000000000ffc0000) (185MB)
mem11: type=4, attr=0xb, range=[0x000000000ffc0000-0x0000000010000000) (0MB)
mem12: type=2, attr=0xb, range=[0x0000000010000000-0x0000000010490000) (4MB)
mem13: type=2, attr=0xb, range=[0x0000000010490000-0x00000000104a0000) (0MB)
mem14: type=2, attr=0xb, range=[0x00000000104a0000-0x0000000010650000) (1MB)
mem15: type=7, attr=0xb, range=[0x0000000010650000-0x000000001ffe4000) (249MB)
mem16: type=8, attr=0x5555555555555555, range=[0x000000001ffe4000-0x600000001fff2000) (6597069766656MB)
mem17: type=7, attr=0x5555555555555555, range=[0x600000001fff2350-0x5151515151514350) (16583222432533MB)
efi_get_pal_addr: no PAL-code memory-descriptor found
No I/O port range found in EFI memory map, falling back to AR.KR0 (0xffffc000000)
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200n8')
Initial ramdisk at: 0xe00000001f544000 (10977792 bytes)
SAL 3.20: Intel Corp                       SR870BH2                         version 3.0
SAL Platform features: BusLock
efi_get_pal_addr: no PAL-code memory-descriptor found
iosapic_system_init: Disabling PC-AT compatible 8259 interrupts
ACPI: Local APIC address c0000000fee00000
ACPI: [APIC:0x07] ignored 1 entries of 2 found
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0100) vector 30
register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
1 CPUs available, 1 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffffc80000
Zone PFN ranges:
  DMA         16384 ->   262144
  Normal     262144 ->   262144
early_node_map[1] active PFN ranges
    0:    16384 ->    31744
Built 1 zonelists.  Total pages: 15308
Kernel command line: phys_efi clock=pit ip=on apm=power-off console=tty0 loglevel=7 console=uart,io,0x2f8,115200n8 init 1 irqpoll maxcpus=1 elfcorehdrR4176K max_addrQ2M min_addr%6M
Warning! clock= boot option is deprecated. Use clocksource=xyz
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
PID hash table entries: 1024 (order: 10, 8192 bytes)
Console: colour dummy device 80x25
Placing 64MB software IO TLB between 0x107f8000 - 0x147f8000
Memory: 171664k/239328k available (3010k code, 74096k reserved, 2124k data, 640k init)
McKinley Errata 9 workaround not needed; disabling it
Dentry cache hash table entries: 32768 (order: 4, 262144 bytes)
Inode-cache hash table entries: 16384 (order: 3, 131072 bytes)
Mount-cache hash table entries: 1024
ACPI: Core revision 20060707
DMI 2.3 present.
ACPI: bus type pci registered
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI quirk: region 0c00-0c7f claimed by ICH4 ACPI/GPIO/TCO
PCI quirk: region 0500-053f claimed by ICH4 GPIO
ACPI: PCI Root Bridge [PCI1] (0000:02)
ACPI: PCI Root Bridge [PCI2] (0000:05)
ACPI: Device [CSFF] status [00000008]: functional but not present; setting present
ACPI: PCI Root Bridge [CSFF] (0000:ff)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
pnp: PnP ACPI: found 12 devices
checking if image is initramfs... it is
Freeing initrd memory: 10720kB freed
perfmon: version 2.0 IRQ 238
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
read_from_oldmem: error: pfn (32761) > saved_max_pfn (31744)
Kdump: vmcore not initialized
io scheduler noop registered
io scheduler anticipatory registered (default)
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
00:08: ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
00:09: ttyS1 at I/O 0x2f8 (irq = 45) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
Adding console on ttyS1 at I/O port 0x2f8 (options '115200n8')
Freeing unused kernel memory: 640kB freed
init started:  BusyBox v1.2.1 (2006.09.23-05:46+0000) multi-call binary
Starting pid 772, console /dev/console: '/etc/init.d/rcS'
ifconfig: socket: Function not implemented
ifconfig: No usable address families found.
ifconfig: socket: Function not implemented
Starting pid 953, console /dev/console: '/bin/sh'


BusyBox v1.2.1 (2006.09.23-05:46+0000) Built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ # ls -l /proc/vmcore 
-r--------    1 0        0               0 /proc/vmcore
/ # 

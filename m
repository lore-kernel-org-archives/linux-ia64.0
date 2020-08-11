From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 11 Aug 2020 16:35:11 +0000
Subject: "mm: consolidate pte_index() and pte_offset_*() definitions" broke ia64
Message-Id: <fa71f38e-b191-597a-6359-502cba197050@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Anatoly Pugachev <matorola@gmail.com>, Sergei Trofimovich <slyfox@gentoo.org>, jrtc27@jrtc27.com, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Frank Scheiner <frank.scheiner@web.de>

Hi Mike!

I just bisected a kernel issue on ia64 which leads to the kernel hanging very early
when booting on an HP RX2600 server (also verified to hang on other ia64 machines):

Loading Linux 5.8.0-12299-g00e4db51259a ...
Loading initial ramdisk ...
[    0.000000] Linux version 5.8.0-12299-g00e4db51259a (root@glendronach) (gcc (Debian 10.2.0-3) 10.2.0, GNU ld (GNU Binutils for Debian) 2.35) #5 SMP Tue Aug 11 15:33:11 CEST 2020
[    0.000000] efi: EFI v2.00 by HP
[    0.000000] efi: SALsystab=0x3ee7a000 ACPI 2.0=0x3fde4000 ESI=0x3ee7b000 SMBIOS=0x3ee7c000 HCDP=0x3fde2000 
[    0.000000] PCDP: v3 at 0x3fde2000
[    0.000000] earlycon: uart8250 at MMIO 0x0000000088033000 (options '115200n8')
[    0.000000] printk: bootconsole [uart8250] enabled
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000003FDE4000 000028 (v02 HP    )
[    0.000000] ACPI: XSDT 0x000000003FDE402C 0000A4 (v01 HP     rx2660   00000000 HP   00000000)
[    0.000000] ACPI: FACP 0x000000003FDF6A08 0000F4 (v03 HP     rx2660   00000000 HP   00000000)
[    0.000000] ACPI: DSDT 0x000000003FDE41C8 00E566 (v01 HP     rx2660   00000007 INTL 20050309)
[    0.000000] ACPI: FACS 0x000000003FDF6B00 000040
[    0.000000] ACPI: SPCR 0x000000003FDF6B40 000050 (v01 HP              00000000 HP   00000000)
[    0.000000] ACPI: DBGP 0x000000003FDF6B90 000034 (v01 HP     rx2660   00000000 HP   00000000)
[    0.000000] ACPI: APIC 0x000000003FDF6FB0 0000C8 (v01 HP     rx2660   00000000 HP   00000000)
[    0.000000] ACPI: SPMI 0x000000003FDF6BC8 000050 (v04 HP     rx2660   00000000 HP   00000000)
[    0.000000] ACPI: CPEP 0x000000003FDF6E80 000034 (v01 HP     rx2660   00000000 HP   00000000)
[    0.000000] ACPI: SSDT 0x000000003FDF2738 0004B3 (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF2BF8 000456 (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF3058 000EB8 (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF3F18 000EB8 (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF4DD8 000866 (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF5648 000EB8 (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF6508 000138 (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF6648 00013C (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF6788 00013C (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: SSDT 0x000000003FDF68C8 00013C (v01 HP     rx2660   00000006 INTL 20050309)
[    0.000000] ACPI: Local APIC address (____ptrval____)
[    0.000000] 4 CPUs available, 4 CPUs total
[    0.000000] SMP: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] Initial ramdisk at: 0xe00000002e368000 (9818100 bytes)
[    0.000000] SAL 3.20: HP version 4.4
[    0.000000] SAL Platform features:
[    0.000000]  None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] MCA related initialization done                                                                                                                
[    0.000000] Virtual mem_map starts at 0x(____ptrval____)                                                                                                   
[    0.000000] Zone ranges:                                                                                                                                   
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]                                                                                         
[    0.000000]   Normal   [mem 0x0000000100000000-0x000001007fffffff]                                                                                         
[    0.000000] Movable zone start for each node                                                                                                               
[    0.000000] Early memory node ranges                                                                                                                       
[    0.000000]   node   0: [mem 0x0000000001000000-0x000000003e67ffff]                                                                                        
[    0.000000]   node   0: [mem 0x000000003eaec000-0x000000003ee77fff]                                                                                        
[    0.000000]   node   0: [mem 0x000000003fc00000-0x000000003fd77fff]                                                                                        
[    0.000000]   node   0: [mem 0x000000003fddc000-0x000000003fddffff]                                                                                        
[    0.000000]   node   0: [mem 0x0000010040000000-0x000001007f1fbfff]                                                                                        
[    0.000000]   node   0: [mem 0x000001007f200000-0x000001007fffffff]                                                                                        
[    0.000000] Initmem setup node 0 [mem 0x0000000001000000-0x000001007fffffff]

Bisecting the problem lead to your change as mentioned in the topic:

974b9b2c68f3d35a65e80af9657fe378d2439b60 is the first bad commit
commit 974b9b2c68f3d35a65e80af9657fe378d2439b60
Author: Mike Rapoport <rppt@linux.ibm.com>
Date:   Mon Jun 8 21:33:10 2020 -0700

    mm: consolidate pte_index() and pte_offset_*() definitions
    
    All architectures define pte_index() as
    
            (address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)
    
    and all architectures define pte_offset_kernel() as an entry in the array
    of PTEs indexed by the pte_index().
    
    For the most architectures the pte_offset_kernel() implementation relies
    on the availability of pmd_page_vaddr() that converts a PMD entry value to
    the virtual address of the page containing PTEs array.
    
    Let's move x86 definitions of the PTE accessors to the generic place in
    <linux/pgtable.h> and then simply drop the respective definitions from the
    other architectures.
    
    The architectures that didn't provide pmd_page_vaddr() are updated to have
    that defined.
    
    The generic implementation of pte_offset_kernel() can be overridden by an
    architecture and alpha makes use of this because it has special ordering
    requirements for its version of pte_offset_kernel().

Any suggestions what could be the problem?

Thanks,
Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

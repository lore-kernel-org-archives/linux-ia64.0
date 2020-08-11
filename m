From: Jessica Clarke <jrtc27@jrtc27.com>
Date: Tue, 11 Aug 2020 17:20:14 +0000
Subject: Re: "mm: consolidate pte_index() and pte_offset_*() definitions" broke ia64
Message-Id: <AA5E212C-56ED-4DB9-9CC1-EB13745DD5AF@jrtc27.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <fa71f38e-b191-597a-6359-502cba197050@physik.fu-berlin.de>
In-Reply-To: <fa71f38e-b191-597a-6359-502cba197050@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Anatoly Pugachev <matorola@gmail.com>, Sergei Trofimovich <slyfox@gentoo.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Frank Scheiner <frank.scheiner@web.de>

On 11 Aug 2020, at 17:35, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
> 
> Hi Mike!
> 
> I just bisected a kernel issue on ia64 which leads to the kernel hanging very early
> when booting on an HP RX2600 server (also verified to hang on other ia64 machines):
> 
> Loading Linux 5.8.0-12299-g00e4db51259a ...
> Loading initial ramdisk ...
> [    0.000000] Linux version 5.8.0-12299-g00e4db51259a (root@glendronach) (gcc (Debian 10.2.0-3) 10.2.0, GNU ld (GNU Binutils for Debian) 2.35) #5 SMP Tue Aug 11 15:33:11 CEST 2020
> [    0.000000] efi: EFI v2.00 by HP
> [    0.000000] efi: SALsystab=0x3ee7a000 ACPI 2.0=0x3fde4000 ESI=0x3ee7b000 SMBIOS=0x3ee7c000 HCDP=0x3fde2000 
> [    0.000000] PCDP: v3 at 0x3fde2000
> [    0.000000] earlycon: uart8250 at MMIO 0x0000000088033000 (options '115200n8')
> [    0.000000] printk: bootconsole [uart8250] enabled
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x000000003FDE4000 000028 (v02 HP    )
> [    0.000000] ACPI: XSDT 0x000000003FDE402C 0000A4 (v01 HP     rx2660   00000000 HP   00000000)
> [    0.000000] ACPI: FACP 0x000000003FDF6A08 0000F4 (v03 HP     rx2660   00000000 HP   00000000)
> [    0.000000] ACPI: DSDT 0x000000003FDE41C8 00E566 (v01 HP     rx2660   00000007 INTL 20050309)
> [    0.000000] ACPI: FACS 0x000000003FDF6B00 000040
> [    0.000000] ACPI: SPCR 0x000000003FDF6B40 000050 (v01 HP              00000000 HP   00000000)
> [    0.000000] ACPI: DBGP 0x000000003FDF6B90 000034 (v01 HP     rx2660   00000000 HP   00000000)
> [    0.000000] ACPI: APIC 0x000000003FDF6FB0 0000C8 (v01 HP     rx2660   00000000 HP   00000000)
> [    0.000000] ACPI: SPMI 0x000000003FDF6BC8 000050 (v04 HP     rx2660   00000000 HP   00000000)
> [    0.000000] ACPI: CPEP 0x000000003FDF6E80 000034 (v01 HP     rx2660   00000000 HP   00000000)
> [    0.000000] ACPI: SSDT 0x000000003FDF2738 0004B3 (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF2BF8 000456 (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF3058 000EB8 (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF3F18 000EB8 (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF4DD8 000866 (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF5648 000EB8 (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF6508 000138 (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF6648 00013C (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF6788 00013C (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: SSDT 0x000000003FDF68C8 00013C (v01 HP     rx2660   00000006 INTL 20050309)
> [    0.000000] ACPI: Local APIC address (____ptrval____)
> [    0.000000] 4 CPUs available, 4 CPUs total
> [    0.000000] SMP: Allowing 4 CPUs, 0 hotplug CPUs
> [    0.000000] Initial ramdisk at: 0xe00000002e368000 (9818100 bytes)
> [    0.000000] SAL 3.20: HP version 4.4
> [    0.000000] SAL Platform features:
> [    0.000000]  None
> [    0.000000] SAL: AP wakeup using external interrupt vector 0xff
> [    0.000000] MCA related initialization done                                                                                                                
> [    0.000000] Virtual mem_map starts at 0x(____ptrval____)                                                                                                   
> [    0.000000] Zone ranges:                                                                                                                                   
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]                                                                                         
> [    0.000000]   Normal   [mem 0x0000000100000000-0x000001007fffffff]                                                                                         
> [    0.000000] Movable zone start for each node                                                                                                               
> [    0.000000] Early memory node ranges                                                                                                                       
> [    0.000000]   node   0: [mem 0x0000000001000000-0x000000003e67ffff]                                                                                        
> [    0.000000]   node   0: [mem 0x000000003eaec000-0x000000003ee77fff]                                                                                        
> [    0.000000]   node   0: [mem 0x000000003fc00000-0x000000003fd77fff]                                                                                        
> [    0.000000]   node   0: [mem 0x000000003fddc000-0x000000003fddffff]                                                                                        
> [    0.000000]   node   0: [mem 0x0000010040000000-0x000001007f1fbfff]                                                                                        
> [    0.000000]   node   0: [mem 0x000001007f200000-0x000001007fffffff]                                                                                        
> [    0.000000] Initmem setup node 0 [mem 0x0000000001000000-0x000001007fffffff]
> 
> Bisecting the problem lead to your change as mentioned in the topic:
> 
> 974b9b2c68f3d35a65e80af9657fe378d2439b60 is the first bad commit
> commit 974b9b2c68f3d35a65e80af9657fe378d2439b60
> Author: Mike Rapoport <rppt@linux.ibm.com>
> Date:   Mon Jun 8 21:33:10 2020 -0700
> 
>    mm: consolidate pte_index() and pte_offset_*() definitions
> 
>    All architectures define pte_index() as
> 
>            (address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)
> 
>    and all architectures define pte_offset_kernel() as an entry in the array
>    of PTEs indexed by the pte_index().
> 
>    For the most architectures the pte_offset_kernel() implementation relies
>    on the availability of pmd_page_vaddr() that converts a PMD entry value to
>    the virtual address of the page containing PTEs array.
> 
>    Let's move x86 definitions of the PTE accessors to the generic place in
>    <linux/pgtable.h> and then simply drop the respective definitions from the
>    other architectures.
> 
>    The architectures that didn't provide pmd_page_vaddr() are updated to have
>    that defined.
> 
>    The generic implementation of pte_offset_kernel() can be overridden by an
>    architecture and alpha makes use of this because it has special ordering
>    requirements for its version of pte_offset_kernel().
> 
> Any suggestions what could be the problem?

Yeah, so, this definitely looks broken on ia64. pgd_offset_k was:

> /* In the kernel's mapped region we completely ignore the region number		
>    (since we know it's in region number 5). */		
> #define pgd_offset_k(addr) \		
> 	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))

But now it's the generic:

> #define pgd_offset_k(address)		pgd_offset(&init_mm, (address))


and so will call ia64's pgd_index, and thus include the region number,
but presumably this causes surprises because the expectation is that
it's just an offset within region 5, whereas now it's got a 5 in the
high bits. Please try the patch below (not compile tested but WCPGW).

Jess

From 6c13e42cb95025e5f7ea3ac1a1262817bf3fcfec Mon Sep 17 00:00:00 2001
From: Jessica Clarke <jrtc27@jrtc27.com>
Date: Tue, 11 Aug 2020 19:18:28 +0200
Subject: [PATCH] arch/ia64: Restore arch-specific pgd_offset_k implementation

IA-64 is special and treats pgd_offset_k differently from pgd_offset by
not including the region number, and init_mm's PGD is such that it only
points to the kernel's region's PGD. This was broken in 974b9b2c68 which
unified the two and therfore included the region number, causing it to
index way out of bounds of the kernel's PGD and cause the kernel to hang
during early boot. Thus, permit pgd_offset_k to be overridden like the
other macros and override it on IA-64 with the old implementation. Also
update the comment to clarify that this is not just an optimisation but
a required implementation detail.

Fixes: 974b9b2c68 ("mm: consolidate pte_index() and pte_offset_*() definitions")
Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Signed-off-by: Jessica Clarke <jrtc27@jrtc27.com>
---
 arch/ia64/include/asm/pgtable.h | 8 ++++++++
 include/linux/pgtable.h         | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 10850897a91c..2ac2199d99ce 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -366,6 +366,14 @@ pgd_index (unsigned long address)
 }
 #define pgd_index pgd_index
 
+/*
+ * In the kernel's mapped region we know everything is in region number 5, so
+ * as an optimisation its PGD already points to the area for that region, but
+ * that means not adding the region here is required, not just an optimisation.
+ */
+#define pgd_offset_k(addr) \
+	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
+
 /* Look up a pgd entry in the gate area.  On IA-64, the gate-area
    resides in the kernel-mapped segment, hence we use pgd_offset_k()
    here.  */
diff --git a/include/linux/pgtable.h b/include/linux/pgtable.h
index 53e97da1e8e2..73c64fe098ba 100644
--- a/include/linux/pgtable.h
+++ b/include/linux/pgtable.h
@@ -117,7 +117,9 @@ static inline pgd_t *pgd_offset_pgd(pgd_t *pgd, unsigned long address)
  * a shortcut which implies the use of the kernel's pgd, instead
  * of a process's
  */
+#ifndef pgd_offset_k
 #define pgd_offset_k(address)		pgd_offset(&init_mm, (address))
+#endif
 
 /*
  * In many cases it is known that a virtual address is mapped at PMD or PTE
-- 
2.23.0

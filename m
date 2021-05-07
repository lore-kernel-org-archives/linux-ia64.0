From: Chen Li <chenli@uniontech.com>
Date: Fri, 07 May 2021 09:58:02 +0000
Subject: [PATCH] mm: update legacy flush_tlb_* to use vma
Message-Id: <87k0oaq311.wl-chenli@uniontech.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-m68k@lists.linux-m68k.org, Jonas Bonn <jonas@southpole.se>, openrisc@lists.librecores.org, Chris Zankel <chris@zankel.net>, linux-xtensa@linux-xtensa.org


1. These tlb flush functions  have been using vma instead mm long time ago, but there
is still some coments use mm as parameter.

2. the actual struct we use is vm_area_struct instead of vma_struct.

3. remove unused flush_kern_tlb_page.

Signed-off-by: Chen Li <chenli@uniontech.com>
---
 arch/arm/include/asm/tlbflush.h      | 13 +++----------
 arch/arm/mm/tlb-v6.S                 |  2 +-
 arch/arm/mm/tlb-v7.S                 |  2 +-
 arch/ia64/kernel/efi_stub.S          |  2 +-
 arch/m68k/include/asm/tlbflush.h     |  2 +-
 arch/openrisc/include/asm/tlbflush.h |  2 +-
 arch/xtensa/include/asm/tlbflush.h   |  4 ++--
 7 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/arch/arm/include/asm/tlbflush.h b/arch/arm/include/asm/tlbflush.h
index 24cbfc112dfa..0ccc985b90af 100644
--- a/arch/arm/include/asm/tlbflush.h
+++ b/arch/arm/include/asm/tlbflush.h
@@ -253,7 +253,7 @@ extern struct cpu_tlb_fns cpu_tlb;
  *		space.
  *		- mm	- mm_struct describing address space
  *
- *	flush_tlb_range(mm,start,end)
+ *	flush_tlb_range(vma,start,end)
  *
  *		Invalidate a range of TLB entries in the specified
  *		address space.
@@ -261,18 +261,11 @@ extern struct cpu_tlb_fns cpu_tlb;
  *		- start - start address (may not be aligned)
  *		- end	- end address (exclusive, may not be aligned)
  *
- *	flush_tlb_page(vaddr,vma)
+ *	flush_tlb_page(vma, uaddr)
  *
  *		Invalidate the specified page in the specified address range.
+ *		- vma	- vm_area_struct describing address range
  *		- vaddr - virtual address (may not be aligned)
- *		- vma	- vma_struct describing address range
- *
- *	flush_kern_tlb_page(kaddr)
- *
- *		Invalidate the TLB entry for the specified page.  The address
- *		will be in the kernels virtual memory space.  Current uses
- *		only require the D-TLB to be invalidated.
- *		- kaddr - Kernel virtual memory address
  */
 
 /*
diff --git a/arch/arm/mm/tlb-v6.S b/arch/arm/mm/tlb-v6.S
index 5335b9687297..74f4b383afe3 100644
--- a/arch/arm/mm/tlb-v6.S
+++ b/arch/arm/mm/tlb-v6.S
@@ -24,7 +24,7 @@
  *
  *	- start - start address (may not be aligned)
  *	- end   - end address (exclusive, may not be aligned)
- *	- vma   - vma_struct describing address range
+ *	- vma   - vm_area_struct describing address range
  *
  *	It is assumed that:
  *	- the "Invalidate single entry" instruction will invalidate
diff --git a/arch/arm/mm/tlb-v7.S b/arch/arm/mm/tlb-v7.S
index 1bb28d7db567..87bf4ab17721 100644
--- a/arch/arm/mm/tlb-v7.S
+++ b/arch/arm/mm/tlb-v7.S
@@ -23,7 +23,7 @@
  *
  *	- start - start address (may not be aligned)
  *	- end   - end address (exclusive, may not be aligned)
- *	- vma   - vma_struct describing address range
+ *	- vma   - vm_area_struct describing address range
  *
  *	It is assumed that:
  *	- the "Invalidate single entry" instruction will invalidate
diff --git a/arch/ia64/kernel/efi_stub.S b/arch/ia64/kernel/efi_stub.S
index 58233bb7976d..1fd61b78fb29 100644
--- a/arch/ia64/kernel/efi_stub.S
+++ b/arch/ia64/kernel/efi_stub.S
@@ -7,7 +7,7 @@
  *
  * This stub allows us to make EFI calls in physical mode with interrupts
  * turned off.  We need this because we can't call SetVirtualMap() until
- * the kernel has booted far enough to allow allocation of struct vma_struct
+ * the kernel has booted far enough to allow allocation of struct vm_area_struct
  * entries (which we would need to map stuff with memory attributes other
  * than uncached or writeback...).  Since the GetTime() service gets called
  * earlier than that, we need to be able to make physical mode EFI calls from
diff --git a/arch/m68k/include/asm/tlbflush.h b/arch/m68k/include/asm/tlbflush.h
index 5337bc2c262f..a6318ccd308f 100644
--- a/arch/m68k/include/asm/tlbflush.h
+++ b/arch/m68k/include/asm/tlbflush.h
@@ -263,7 +263,7 @@ static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long addr
 	BUG();
 }
 
-static inline void flush_tlb_range(struct mm_struct *mm,
+static inline void flush_tlb_range(struct vm_area_struct *vma,
 				   unsigned long start, unsigned long end)
 {
 	BUG();
diff --git a/arch/openrisc/include/asm/tlbflush.h b/arch/openrisc/include/asm/tlbflush.h
index 185dcd3731ed..dbf030365ab4 100644
--- a/arch/openrisc/include/asm/tlbflush.h
+++ b/arch/openrisc/include/asm/tlbflush.h
@@ -25,7 +25,7 @@
  *  - flush_tlb_all() flushes all processes TLBs
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(mm, start, end) flushes a range of pages
+ *  - flush_tlb_range(vma, start, end) flushes a range of pages
  */
 extern void local_flush_tlb_all(void);
 extern void local_flush_tlb_mm(struct mm_struct *mm);
diff --git a/arch/xtensa/include/asm/tlbflush.h b/arch/xtensa/include/asm/tlbflush.h
index 856e2da2e397..573df8cea200 100644
--- a/arch/xtensa/include/asm/tlbflush.h
+++ b/arch/xtensa/include/asm/tlbflush.h
@@ -26,8 +26,8 @@
  *
  *  - flush_tlb_all() flushes all processes TLB entries
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB entries
- *  - flush_tlb_page(mm, vmaddr) flushes a single page
- *  - flush_tlb_range(mm, start, end) flushes a range of pages
+ *  - flush_tlb_page(vma, page) flushes a single page
+ *  - flush_tlb_range(vma, vmaddr, end) flushes a range of pages
  */
 
 void local_flush_tlb_all(void);
-- 
2.31.1



From: Steffen Persvold <sp@scali.no>
Date: Sat, 05 Jan 2002 15:01:29 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------D0EE5E20C1A30E5579E24177"
Message-Id: <marc-linux-ia64-105590698805750@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805186@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805186@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------D0EE5E20C1A30E5579E24177
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David Mosberger wrote:
> 
> Steffen,
> 
> I looked at your patch and have a comment and a suggestion.  First, I
> do not think it's safe to define ioremap() as a way to install
> write-cached mappings.  There are plenty of drivers left that use
> ioremap() instead of ioremap_nocache() and we can't change the
> semantics of ioremap() underneath them.
> 
> Second, it seems to me it would be cleaner to extend
> remap_page_range() to allow remapping into the kernel mapped segment
> (region 5 in the case of ia64 linux).  This should work as is, except
> that in the kernel case, you need to use pgd_offset_k().  I think you
> could hack mm/memory.c to check whether "from" is in the range from
> VMALLOC_START to VMALLOC_END and, if so, use pgd_offset_k() instead of
> pgd_offset().  Can you try this and let me know if it works for your
> needs?
> 

I've had some time to look at it, and I decided to do what you said. I also changed ioremap on all
platforms that implements it so that they use remap_page_range()). I've tested the patch on IA64 and
i386.

I've attached the patch (I didn't post it on the lkml even though it affects more that the IA64
platform), it's against a vanilla 2.4.17 tree.

Please take a look and tell me what you think.

Regards,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best   
 mailto:sp@scali.no  |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.12.2 -         
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >300MBytes/s and <4uS latencyy
--------------D0EE5E20C1A30E5579E24177
Content-Type: text/plain; charset=us-ascii;
 name="linux-2.4.17-ioremap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.17-ioremap.patch"

--- linux-2.4.17/mm/memory.c.orig	Fri Dec 21 18:42:05 2001
+++ linux-2.4.17/mm/memory.c	Sat Jan  5 13:13:26 2002
@@ -791,6 +791,9 @@
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results
  * in null mappings (currently treated as "copy-on-access")
+ *
+ * For physical (or I/O) memory mapped into the kernel virtual space,
+ * the old mappings will not be removed.
  */
 static inline void remap_pte_range(pte_t * pte, unsigned long address, unsigned long size,
 	unsigned long phys_addr, pgprot_t prot)
@@ -802,14 +805,22 @@
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		struct page *page;
-		pte_t oldpage;
-		oldpage = ptep_get_and_clear(pte);
-
-		page = virt_to_page(__va(phys_addr));
-		if ((!VALID_PAGE(page)) || PageReserved(page))
- 			set_pte(pte, mk_pte_phys(phys_addr, prot));
-		forget_pte(oldpage);
+		if (address > VMALLOC_START && address < VMALLOC_END) {
+			if (!pte_none(*pte)) {
+				printk("remap_area_pte: page already exists\n");
+				BUG();
+			}
+			set_pte(pte, mk_pte_phys(phys_addr, prot));
+		} else {
+			struct page *page;
+			pte_t oldpage;
+			oldpage = ptep_get_and_clear(pte);
+
+			page = virt_to_page(__va(phys_addr));
+			if ((!VALID_PAGE(page)) || PageReserved(page))
+				set_pte(pte, mk_pte_phys(phys_addr, prot));
+			forget_pte(oldpage);
+		}
 		address += PAGE_SIZE;
 		phys_addr += PAGE_SIZE;
 		pte++;
@@ -844,10 +855,17 @@
 	pgd_t * dir;
 	unsigned long beg = from;
 	unsigned long end = from + size;
-	struct mm_struct *mm = current->mm;
+	struct mm_struct *mm;
 
 	phys_addr -= from;
-	dir = pgd_offset(mm, from);
+	/* Check if we're going to map into the kernel virtual addresses (ioremap) */
+	if (from > VMALLOC_START && end < VMALLOC_END) {
+		mm = &init_mm;
+		dir = pgd_offset_k(from);
+	} else {
+		mm = current->mm;
+		dir = pgd_offset(mm, from);
+	}
 	flush_cache_range(mm, beg, end);
 	if (from >= end)
 		BUG();
--- linux-2.4.17/arch/i386/mm/ioremap.c.orig	Tue Mar 20 17:13:33 2001
+++ linux-2.4.17/arch/i386/mm/ioremap.c	Sat Jan  5 14:02:31 2002
@@ -12,84 +12,6 @@
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PMD_MASK;
-	end = address + size;
-	if (end > PMD_SIZE)
-		end = PMD_SIZE;
-	if (address >= end)
-		BUG();
-	do {
-		if (!pte_none(*pte)) {
-			printk("remap_area_pte: page already exists\n");
-			BUG();
-		}
-		set_pte(pte, mk_pte_phys(phys_addr, __pgprot(_PAGE_PRESENT | _PAGE_RW | 
-					_PAGE_DIRTY | _PAGE_ACCESSED | flags)));
-		address += PAGE_SIZE;
-		phys_addr += PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-}
-
-static inline int remap_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	phys_addr -= address;
-	if (address >= end)
-		BUG();
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
-}
-
-static int remap_area_pages(unsigned long address, unsigned long phys_addr,
-				 unsigned long size, unsigned long flags)
-{
-	int error;
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	phys_addr -= address;
-	dir = pgd_offset(&init_mm, address);
-	flush_cache_all();
-	if (address >= end)
-		BUG();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
-		error = -ENOMEM;
-		if (!pmd)
-			break;
-		if (remap_area_pmd(pmd, address, end - address,
-					 phys_addr + address, flags))
-			break;
-		error = 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return error;
-}
-
 /*
  * Generic mapping function (not visible outside):
  */
@@ -108,6 +30,8 @@
 	void * addr;
 	struct vm_struct * area;
 	unsigned long offset, last_addr;
+	pgprot_t pgprot = __pgprot(_PAGE_PRESENT | _PAGE_RW
+				   | _PAGE_DIRTY | _PAGE_ACCESSED | flags);
 
 	/* Don't allow wraparound or zero size */
 	last_addr = phys_addr + size - 1;
@@ -149,7 +73,7 @@
 	if (!area)
 		return NULL;
 	addr = area->addr;
-	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
 		vfree(addr);
 		return NULL;
 	}
--- linux-2.4.17/arch/mips/mm/ioremap.c.orig	Wed Jul  4 20:50:39 2001
+++ linux-2.4.17/arch/mips/mm/ioremap.c	Sat Jan  5 14:07:02 2002
@@ -14,85 +14,6 @@
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-	pgprot_t pgprot = __pgprot(_PAGE_GLOBAL | _PAGE_PRESENT | __READABLE
-	                           | __WRITEABLE | flags);
-
-	address &= ~PMD_MASK;
-	end = address + size;
-	if (end > PMD_SIZE)
-		end = PMD_SIZE;
-	if (address >= end)
-		BUG();
-	do {
-		if (!pte_none(*pte)) {
-			printk("remap_area_pte: page already exists\n");
-			BUG();
-		}
-		set_pte(pte, mk_pte_phys(phys_addr, pgprot));
-		address += PAGE_SIZE;
-		phys_addr += PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-}
-
-static inline int remap_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	phys_addr -= address;
-	if (address >= end)
-		BUG();
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
-}
-
-static int remap_area_pages(unsigned long address, unsigned long phys_addr,
-				 unsigned long size, unsigned long flags)
-{
-	int error;
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	phys_addr -= address;
-	dir = pgd_offset(&init_mm, address);
-	flush_cache_all();
-	if (address >= end)
-		BUG();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
-		error = -ENOMEM;
-		if (!pmd)
-			break;
-		if (remap_area_pmd(pmd, address, end - address,
-					 phys_addr + address, flags))
-			break;
-		error = 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return error;
-}
-
 /*
  * Generic mapping function (not visible outside):
  */
@@ -114,6 +35,8 @@
 	void * addr;
 	struct vm_struct * area;
 	unsigned long offset, last_addr;
+	pgprot_t pgprot = __pgprot(_PAGE_GLOBAL | _PAGE_PRESENT | __READABLE
+	                           | __WRITEABLE | flags);
 
 	/* Don't allow wraparound or zero size */
 	last_addr = phys_addr + size - 1;
@@ -156,7 +79,7 @@
 	if (!area)
 		return NULL;
 	addr = area->addr;
-	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
 		vfree(addr);
 		return NULL;
 	}
@@ -171,6 +94,3 @@
 	if (!IS_KSEG1(addr))
 		return vfree((void *) (PAGE_MASK & (unsigned long) addr));
 }
-
-EXPORT_SYMBOL(__ioremap);
-EXPORT_SYMBOL(iounmap);
--- linux-2.4.17/arch/mips/kernel/mips_ksyms.c.orig	Sun Sep  9 19:43:01 2001
+++ linux-2.4.17/arch/mips/kernel/mips_ksyms.c	Sat Jan  5 14:07:57 2002
@@ -106,6 +106,9 @@
  */
 EXPORT_SYMBOL(mips_io_port_base);
 
+EXPORT_SYMBOL(__ioremap);
+EXPORT_SYMBOL(iounmap);
+
 /*
  * Architecture specific stuff.
  */
--- linux-2.4.17/arch/arm/mm/ioremap.c.orig	Thu Apr 12 21:20:31 2001
+++ linux-2.4.17/arch/arm/mm/ioremap.c	Sat Jan  5 13:36:38 2002
@@ -35,88 +35,6 @@
 #include <asm/pgalloc.h>
 #include <asm/io.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long phys_addr, pgprot_t pgprot)
-{
-	unsigned long end;
-
-	address &= ~PMD_MASK;
-	end = address + size;
-	if (end > PMD_SIZE)
-		end = PMD_SIZE;
-	if (address >= end)
-		BUG();
-	do {
-		if (!pte_none(*pte)) {
-			printk("remap_area_pte: page already exists\n");
-			BUG();
-		}
-		set_pte(pte, mk_pte_phys(phys_addr, pgprot));
-		address += PAGE_SIZE;
-		phys_addr += PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-}
-
-static inline int remap_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-	pgprot_t pgprot;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-
-	phys_addr -= address;
-	if (address >= end)
-		BUG();
-
-	pgprot = __pgprot(L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY | L_PTE_WRITE | flags);
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		remap_area_pte(pte, address, end - address, address + phys_addr, pgprot);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
-}
-
-static int remap_area_pages(unsigned long address, unsigned long phys_addr,
-				 unsigned long size, unsigned long flags)
-{
-	int error;
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	phys_addr -= address;
-	dir = pgd_offset(&init_mm, address);
-	flush_cache_all();
-	if (address >= end)
-		BUG();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
-		error = -ENOMEM;
-		if (!pmd)
-			break;
-		if (remap_area_pmd(pmd, address, end - address,
-					 phys_addr + address, flags))
-			break;
-		error = 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return error;
-}
-
 /*
  * Remap an arbitrary physical address space into the kernel virtual
  * address space. Needed when the kernel wants to access high addresses
@@ -134,6 +52,8 @@
 	void * addr;
 	struct vm_struct * area;
 	unsigned long offset, last_addr;
+	pgprot_t pgprot = __pgprot(L_PTE_PRESENT | L_PTE_YOUNG
+				   | L_PTE_DIRTY | L_PTE_WRITE | flags);
 
 	/* Don't allow wraparound or zero size */
 	last_addr = phys_addr + size - 1;
@@ -154,7 +74,7 @@
 	if (!area)
 		return NULL;
 	addr = area->addr;
-	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
 		vfree(addr);
 		return NULL;
 	}
--- linux-2.4.17/arch/sh/mm/ioremap.c.orig	Sat Sep  8 21:29:09 2001
+++ linux-2.4.17/arch/sh/mm/ioremap.c	Sat Jan  5 13:35:40 2002
@@ -13,86 +13,6 @@
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address,
-	unsigned long size, unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-	pgprot_t pgprot = __pgprot(_PAGE_PRESENT | _PAGE_RW |
-				   _PAGE_DIRTY | _PAGE_ACCESSED |
-				   _PAGE_HW_SHARED | _PAGE_FLAGS_HARD | flags);
-
-	address &= ~PMD_MASK;
-	end = address + size;
-	if (end > PMD_SIZE)
-		end = PMD_SIZE;
-	if (address >= end)
-		BUG();
-	do {
-		if (!pte_none(*pte)) {
-			printk("remap_area_pte: page already exists\n");
-			BUG();
-		}
-		set_pte(pte, mk_pte_phys(phys_addr, pgprot));
-		address += PAGE_SIZE;
-		phys_addr += PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-}
-
-static inline int remap_area_pmd(pmd_t * pmd, unsigned long address,
-	unsigned long size, unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	phys_addr -= address;
-	if (address >= end)
-		BUG();
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
-}
-
-int remap_area_pages(unsigned long address, unsigned long phys_addr,
-		     unsigned long size, unsigned long flags)
-{
-	int error;
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	phys_addr -= address;
-	dir = pgd_offset_k(address);
-	flush_cache_all();
-	if (address >= end)
-		BUG();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
-		error = -ENOMEM;
-		if (!pmd)
-			break;
-		if (remap_area_pmd(pmd, address, end - address,
-					phys_addr + address, flags))
-			break;
-		error = 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return error;
-}
-
 /*
  * Generic mapping function (not visible outside):
  */
@@ -111,6 +31,9 @@
 	void * addr;
 	struct vm_struct * area;
 	unsigned long offset, last_addr;
+	pgprot_t pgprot = __pgprot(_PAGE_PRESENT | _PAGE_RW |
+				   _PAGE_DIRTY | _PAGE_ACCESSED |
+				   _PAGE_HW_SHARED | _PAGE_FLAGS_HARD | flags);
 
 	/* Don't allow wraparound or zero size */
 	last_addr = phys_addr + size - 1;
@@ -143,7 +66,7 @@
 	if (!area)
 		return NULL;
 	addr = area->addr;
-	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
 		vfree(addr);
 		return NULL;
 	}
--- linux-2.4.17/arch/ia64/kernel/ia64_ksyms.c.orig	Fri Nov  9 23:26:17 2001
+++ linux-2.4.17/arch/ia64/kernel/ia64_ksyms.c	Sat Jan  5 14:06:11 2002
@@ -43,6 +43,8 @@
 EXPORT_SYMBOL(ip_fast_csum);
 
 #include <asm/io.h>
+EXPORT_SYMBOL(__ioremap);
+EXPORT_SYMBOL(iounmap);
 EXPORT_SYMBOL(__ia64_memcpy_fromio);
 EXPORT_SYMBOL(__ia64_memcpy_toio);
 EXPORT_SYMBOL(__ia64_memset_c_io);
--- linux-2.4.17/arch/ia64/mm/ioremap.c.orig	Sat Jan  5 13:59:40 2002
+++ linux-2.4.17/arch/ia64/mm/ioremap.c	Sat Jan  5 13:43:41 2002
@@ -0,0 +1,70 @@
+/*
+ *  arch/ia64/mm/ioremap.c
+ *
+ *  IA64 version
+ *    Copyright (C) 2001 Scali AS
+ *    Author(s): Steffen Persvold (sp@scali.com)
+ *
+ *  Derived from "arch/i386/mm/ioremap.c"
+ *    (C) Copyright 1995 1996 Linus Torvalds
+ *
+ * Re-map IO memory to kernel address space so that we can access it.
+ */
+
+#include <linux/vmalloc.h>
+#include <asm/io.h>
+#include <asm/pgalloc.h>
+
+/*
+ * Generic mapping function (not visible outside):
+ */
+
+/*
+ * Remap an arbitrary physical address space into the kernel virtual
+ * address space. Needed when the kernel wants to access high addresses
+ * directly.
+ *
+ * NOTE! We need to allow non-page-aligned mappings too: we will obviously
+ * have to convert them into an offset in a page-aligned mapping, but the
+ * caller shouldn't need to know that small detail.
+ */
+void * __ioremap(unsigned long phys_addr, unsigned long size, unsigned long flags)
+{
+	void * addr;
+	struct vm_struct * area;
+	unsigned long offset, last_addr;
+	pgprot_t pgprot = __pgprot(__DIRTY_BITS | _PAGE_PL_0
+				   | _PAGE_AR_RWX | flags);
+
+	/* Don't allow wraparound */
+	last_addr = phys_addr + size - 1;
+	if (!size || last_addr < phys_addr)
+		return NULL;
+
+	/*
+	 * Mappings have to be page-aligned
+	 */
+	offset = phys_addr & ~PAGE_MASK;
+	phys_addr &= PAGE_MASK;
+	size = PAGE_ALIGN(last_addr) - phys_addr;
+
+	/*
+	 * Ok, go for it..
+	 */
+	area = get_vm_area(size, VM_IOREMAP);
+	if (!area)
+		return NULL;
+	addr = area->addr;
+
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
+		vfree(addr);
+		return NULL;
+	}
+	return (void *) (offset + (char *)addr);
+}
+
+void iounmap(void *addr)
+{
+	if ((unsigned long)addr > VMALLOC_START && (unsigned long)addr < VMALLOC_END)
+		vfree((void *) (PAGE_MASK & (unsigned long) addr));
+}
--- linux-2.4.17/arch/s390/mm/ioremap.c.orig	Thu Apr 12 04:02:27 2001
+++ linux-2.4.17/arch/s390/mm/ioremap.c	Sat Jan  5 13:41:05 2002
@@ -17,84 +17,6 @@
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
-        unsigned long phys_addr, unsigned long flags)
-{
-        unsigned long end;
-
-        address &= ~PMD_MASK;
-        end = address + size;
-        if (end > PMD_SIZE)
-                end = PMD_SIZE;
-	if (address >= end)
-		BUG();
-        do {
-                if (!pte_none(*pte)) {
-                        printk("remap_area_pte: page already exists\n");
-			BUG();
-		}
-                set_pte(pte, mk_pte_phys(phys_addr,
-                                         __pgprot(_PAGE_PRESENT | flags)));
-                address += PAGE_SIZE;
-                phys_addr += PAGE_SIZE;
-                pte++;
-        } while (address && (address < end));
-}
-
-static inline int remap_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size,
-        unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	phys_addr -= address;
-	if (address >= end)
-		BUG();
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
-}
-
-static int remap_area_pages(unsigned long address, unsigned long phys_addr,
-				 unsigned long size, unsigned long flags)
-{
-	int error;
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	phys_addr -= address;
-	dir = pgd_offset(&init_mm, address);
-	flush_cache_all();
-	if (address >= end)
-		BUG();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
-		error = -ENOMEM;
-		if (!pmd)
-			break;
-		if (remap_area_pmd(pmd, address, end - address,
-					 phys_addr + address, flags))
-			break;
-		error = 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return 0;
-}
-
 /*
  * Generic mapping function (not visible outside):
  */
@@ -108,7 +30,8 @@
 {
 	void * addr;
 	struct vm_struct * area;
-
+	pgprot_t pgprot = __pgprot(_PAGE_PRESENT | flags);
+	
 	if (phys_addr < virt_to_phys(high_memory))
 		return phys_to_virt(phys_addr);
 	if (phys_addr & ~PAGE_MASK)
@@ -120,7 +43,7 @@
 	if (!area)
 		return NULL;
 	addr = area->addr;
-	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
 		vfree(addr);
 		return NULL;
 	}
--- linux-2.4.17/arch/cris/mm/ioremap.c.orig	Wed May  2 01:04:56 2001
+++ linux-2.4.17/arch/cris/mm/ioremap.c	Sat Jan  5 13:40:24 2002
@@ -13,85 +13,6 @@
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PMD_MASK;
-	end = address + size;
-	if (end > PMD_SIZE)
-		end = PMD_SIZE;
-	if (address >= end)
-		BUG();
-	do {
-		if (!pte_none(*pte)) {
-			printk("remap_area_pte: page already exists\n");
-			BUG();
-		}
-		set_pte(pte, mk_pte_phys(phys_addr, __pgprot(_PAGE_PRESENT | __READABLE | 
-							     __WRITEABLE | _PAGE_GLOBAL |
-							     _PAGE_KERNEL | flags)));
-		address += PAGE_SIZE;
-		phys_addr += PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-}
-
-static inline int remap_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size,
-	unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	phys_addr -= address;
-	if (address >= end)
-		BUG();
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
-}
-
-static int remap_area_pages(unsigned long address, unsigned long phys_addr,
-				 unsigned long size, unsigned long flags)
-{
-	int error;
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	phys_addr -= address;
-	dir = pgd_offset(&init_mm, address);
-	flush_cache_all();
-	if (address >= end)
-		BUG();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
-		error = -ENOMEM;
-		if (!pmd)
-			break;
-		if (remap_area_pmd(pmd, address, end - address,
-				   phys_addr + address, flags))
-			break;
-		error = 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return error;
-}
-
 /*
  * Generic mapping function (not visible outside):
  */
@@ -110,7 +31,9 @@
 	void * addr;
 	struct vm_struct * area;
 	unsigned long offset, last_addr;
-
+	pgprot_t pgprot = __pgprot(_PAGE_PRESENT | __READABLE | __WRITEABLE
+				   | _PAGE_GLOBAL | _PAGE_KERNEL | flags);
+	
 	/* Don't allow wraparound or zero size */
 	last_addr = phys_addr + size - 1;
 	if (!size || last_addr < phys_addr)
@@ -155,7 +78,7 @@
 	if (!area)
 		return NULL;
 	addr = area->addr;
-	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
 		vfree(addr);
 		return NULL;
 	}
--- linux-2.4.17/arch/s390x/mm/ioremap.c.orig	Thu Apr 12 04:02:30 2001
+++ linux-2.4.17/arch/s390x/mm/ioremap.c	Sat Jan  5 13:42:15 2002
@@ -17,84 +17,6 @@
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 
-static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
-        unsigned long phys_addr, unsigned long flags)
-{
-        unsigned long end;
-
-        address &= ~PMD_MASK;
-        end = address + size;
-        if (end > PMD_SIZE)
-                end = PMD_SIZE;
-	if (address >= end)
-		BUG();
-        do {
-                if (!pte_none(*pte)) {
-                        printk("remap_area_pte: page already exists\n");
-			BUG();
-		}
-                set_pte(pte, mk_pte_phys(phys_addr,
-                                         __pgprot(_PAGE_PRESENT | flags)));
-                address += PAGE_SIZE;
-                phys_addr += PAGE_SIZE;
-                pte++;
-        } while (address && (address < end));
-}
-
-static inline int remap_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size,
-        unsigned long phys_addr, unsigned long flags)
-{
-	unsigned long end;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	phys_addr -= address;
-	if (address >= end)
-		BUG();
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
-}
-
-static int remap_area_pages(unsigned long address, unsigned long phys_addr,
-				 unsigned long size, unsigned long flags)
-{
-	int error;
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	phys_addr -= address;
-	dir = pgd_offset(&init_mm, address);
-	flush_cache_all();
-	if (address >= end)
-		BUG();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
-		error = -ENOMEM;
-		if (!pmd)
-			break;
-		if (remap_area_pmd(pmd, address, end - address,
-					 phys_addr + address, flags))
-			break;
-		error = 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return 0;
-}
-
 /*
  * Generic mapping function (not visible outside):
  */
@@ -108,6 +30,7 @@
 {
 	void * addr;
 	struct vm_struct * area;
+	pgprot_t pgprot = __pgprot(_PAGE_PRESENT | flags);
 
 	if (phys_addr < virt_to_phys(high_memory))
 		return phys_to_virt(phys_addr);
@@ -120,7 +43,7 @@
 	if (!area)
 		return NULL;
 	addr = area->addr;
-	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+	if (remap_page_range(VMALLOC_VMADDR(addr), phys_addr, size, pgprot)) {
 		vfree(addr);
 		return NULL;
 	}
--- linux-2.4.17/include/asm-ia64/io.h.orig	Fri Nov  9 23:26:17 2001
+++ linux-2.4.17/include/asm-ia64/io.h	Sat Jan  5 13:46:26 2002
@@ -37,6 +37,7 @@
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
+#include <asm/pgtable.h>
 
 /*
  * Change virtual addresses to physical addresses and vv.
@@ -378,19 +379,23 @@
  * accept both, thus the casts.
  *
  * On ia-64, we access the physical I/O memory space through the uncached kernel region.
+ *
+ * Which is not a good idea if we want speed on large PIO operations. It is now possible
+ * to map dynamically so that we can use the page table attributes to decide the caching.
+ * ioremap_wrcomb() does this and uses Write Coalescing attribute.
  */
+
+extern void * __ioremap(unsigned long offset, unsigned long size, unsigned long flags);
+extern void iounmap(void *addr);
+
 static inline void *
 ioremap (unsigned long offset, unsigned long size)
 {
 	return (void *) (__IA64_UNCACHED_OFFSET | (offset));
 }
 
-static inline void
-iounmap (void *addr)
-{
-}
-
 #define ioremap_nocache(o,s)	ioremap(o,s)
+#define ioremap_wrcomb(o,s)	__ioremap(o,s,_PAGE_MA_WC)
 
 # ifdef __KERNEL__
 
--- linux-2.4.17/include/asm-ia64/pgtable.h.orig	Sat Jan  5 13:55:06 2002
+++ linux-2.4.17/include/asm-ia64/pgtable.h	Sat Jan  5 14:20:13 2002
@@ -125,7 +125,6 @@
 # ifndef __ASSEMBLY__
 
 #include <asm/bitops.h>
-#include <asm/mmu_context.h>
 #include <asm/processor.h>
 
 /*
@@ -329,11 +328,7 @@
 
 /* The offset in the 1-level directory is given by the 3 region bits
    (61..63) and the seven level-1 bits (33-39).  */
-static inline pgd_t*
-pgd_offset (struct mm_struct *mm, unsigned long address)
-{
-	return mm->pgd + pgd_index(address);
-}
+#define pgd_offset(mm, address) ((mm)->pgd+pgd_index(address))
 
 /* In the kernel's mapped region we have a full 43 bit space available and completely
    ignore the region number (since we know its in region number 5). */


--------------D0EE5E20C1A30E5579E24177--



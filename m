From: Steffen Persvold <sp@scali.no>
Date: Sat, 15 Sep 2001 12:36:34 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------AC339179474D5777E08517A4"
Message-Id: <marc-linux-ia64-105590698805187@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805186@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805186@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------AC339179474D5777E08517A4
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David Mosberger wrote:
> 
> >>>>> On Fri, 14 Sep 2001 23:57:03 +0200, Steffen Persvold <sp@scali.no> said:
> 
>   Steffen> So, how about that patch guys ? Any chance you'll put it
>   Steffen> into the mainstream IA64 kernel ???
> 
> I haven't looked at it yet, but am planning to do so as part of the
> 2.4.10 patch.
> 

I just discovered that several files in arch/ia64/kernel (more specifically acpi.c, efi.c and iosapic.c) calls ioremap with 0 as
size argument. This is ok with the current ioremap implementation which always uses region 6 and therefore in theory doesn't need a
size since it's mapped all the time. However with my patch you will get a NULL pointer in return if you specify size as 0. Because
of this I've modified my original patch to accept 0 as size argument and return the region 6 address when this is the case. This
means that we cannot get rid of region 6 yet since some of the source files seem to depend on it.

Attached is my new version of the patch. (Please note that the old ioremap() methods in asm/io.h is just disabled with '#if 0')

Regards,
-- 
  Steffen Persvold   |  Scali Computer AS   |   Try out the world's best   
 mailto:sp@scali.no  | http://www.scali.com | performing MPI implementation:
Tel: (+47) 2262 8950 |  Olaf Helsets vei 6  |      - ScaMPI 1.12.2 -         
Fax: (+47) 2262 8951 |  N0621 Oslo, NORWAY  | >300MBytes/s and <4uS latency
--------------AC339179474D5777E08517A4
Content-Type: text/plain; charset=us-ascii;
 name="ia64-ioremap3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64-ioremap3.patch"

--- linux-2.4.4/arch/ia64/mm/Makefile.~1~	Thu Jan  4 21:50:17 2001
+++ linux-2.4.4/arch/ia64/mm/Makefile	Sat Aug 11 21:20:03 2001
@@ -9,6 +9,6 @@
 
 O_TARGET := mm.o
 
-obj-y	 := init.o fault.o tlb.o extable.o
+obj-y	 := init.o fault.o ioremap.o tlb.o extable.o
 
 include $(TOPDIR)/Rules.make
--- linux-2.4.4/arch/ia64/mm/ioremap.c.~1~	Tue May  5 22:32:27 1998
+++ linux-2.4.4/arch/ia64/mm/ioremap.c	Sat Sep 15 13:20:25 2001
@@ -0,0 +1,162 @@
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
+static inline void remap_area_pte(pte_t * pte, unsigned long address, unsigned long size,
+        unsigned long phys_addr, unsigned long flags)
+{
+        unsigned long end;
+
+        address &= ~PMD_MASK;
+        end = address + size;
+        if (end > PMD_SIZE)
+                end = PMD_SIZE;
+	if (address >= end)
+		BUG();
+        do {
+                if (!pte_none(*pte)) {
+                        printk("remap_area_pte: page already exists\n");
+			BUG();
+		}
+                set_pte(pte, mk_pte_phys(phys_addr, __pgprot(__DIRTY_BITS | _PAGE_PL_0 |
+					 _PAGE_AR_RWX | (flags & _PAGE_MA_MASK))));
+                address += PAGE_SIZE;
+                phys_addr += PAGE_SIZE;
+                pte++;
+        } while (address && (address < end));
+}
+
+static inline int remap_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size,
+        unsigned long phys_addr, unsigned long flags)
+{
+	unsigned long end;
+
+	address &= ~PGDIR_MASK;
+	end = address + size;
+	if (end > PGDIR_SIZE)
+		end = PGDIR_SIZE;
+	phys_addr -= address;
+	if (address >= end)
+		BUG();
+	do {
+		pte_t * pte = pte_alloc(&init_mm, pmd, address);
+		if (!pte)
+			return -ENOMEM;
+		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
+		address = (address + PMD_SIZE) & PMD_MASK;
+		pmd++;
+	} while (address && (address < end));
+	return 0;
+}
+
+static int remap_area_pages(unsigned long address, unsigned long phys_addr,
+				 unsigned long size, unsigned long flags)
+{
+	int error;
+	pgd_t * dir;
+	unsigned long end = address + size;
+
+	phys_addr -= address;
+	dir = pgd_offset_k(address);
+	flush_cache_all();
+	if (address >= end)
+		BUG();
+	spin_lock(&init_mm.page_table_lock);
+	do {
+		pmd_t *pmd;
+		pmd = pmd_alloc(&init_mm, dir, address);
+		error = -ENOMEM;
+		if (!pmd)
+			break;
+		if (remap_area_pmd(pmd, address, end - address,
+					 phys_addr + address, flags))
+			break;
+		error = 0;
+		address = (address + PGDIR_SIZE) & PGDIR_MASK;
+		dir++;
+	} while (address && (address < end));
+	spin_unlock(&init_mm.page_table_lock);
+	flush_tlb_all();
+	return error;
+}
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
+void * __ia64_ioremap(unsigned long phys_addr, unsigned long size, unsigned long flags)
+{
+	void * addr;
+	struct vm_struct * area;
+	unsigned long offset, last_addr;
+
+	/* If size is zero we can't set up a dynamic map,
+	 * use the uncached region.
+	 */
+	if (!size)
+		return (void *) (__IA64_UNCACHED_OFFSET | (phys_addr));
+	
+	/* Don't allow wraparound */
+	last_addr = phys_addr + size - 1;
+	if (last_addr < phys_addr)
+		return NULL;
+
+	/*
+	 * Don't allow anybody to remap normal RAM that we're using..
+	 */
+	if (phys_addr < virt_to_phys(high_memory))
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
+	if ((flags & _PAGE_MA_MASK) == 0)
+		flags = _PAGE_MA_UC;
+
+	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
+		vfree(addr);
+		return NULL;
+	}
+	return (void *) (offset + (char *)addr);
+}
+
+void __ia64_iounmap(void *addr)
+{
+	/* We can't do vfree() on addresses in the uncached region */
+	if ((unsigned long)addr < __IA64_UNCACHED_OFFSET)
+		return vfree(addr);
+}
--- linux-2.4.4/arch/ia64/kernel/ia64_ksyms.c.~1~	Thu Apr  5 21:51:47 2001
+++ linux-2.4.4/arch/ia64/kernel/ia64_ksyms.c	Sat Aug 11 23:57:12 2001
@@ -39,6 +39,8 @@
 EXPORT_SYMBOL(ip_fast_csum);
 
 #include <asm/io.h>
+EXPORT_SYMBOL(__ia64_ioremap);
+EXPORT_SYMBOL(__ia64_iounmap);
 EXPORT_SYMBOL(__ia64_memcpy_fromio);
 EXPORT_SYMBOL(__ia64_memcpy_toio);
 EXPORT_SYMBOL(__ia64_memset_c_io);
--- linux-2.4.4/include/asm-ia64/io.h.~1~	Thu Apr  5 21:51:47 2001
+++ linux-2.4.4/include/asm-ia64/io.h	Sat Sep 15 13:25:50 2001
@@ -32,6 +32,7 @@
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
+#include <asm/pgtable.h>
 
 /*
  * Change virtual addresses to physical addresses and vv.
@@ -372,7 +373,15 @@
  * accept both, thus the casts.
  *
  * On ia-64, we access the physical I/O memory space through the uncached kernel region.
+ *
+ * Which is not a good idea if we want speed on large PIO operations. This is now changed
+ * to map dynamically so that we can use the page table attributes to decide the caching.
  */
+
+extern void * __ia64_ioremap(unsigned long offset, unsigned long size, unsigned long flags);
+extern void __ia64_iounmap(void *addr);
+
+#if 0
 static inline void *
 ioremap (unsigned long offset, unsigned long size)
 {
@@ -385,6 +394,25 @@
 }
 
 #define ioremap_nocache(o,s)	ioremap(o,s)
+#else
+static inline void *
+ioremap (unsigned long offset, unsigned long size)
+{
+	return __ia64_ioremap(offset, size, _PAGE_MA_WC);
+}
+
+static inline void *
+ioremap_nocache (unsigned long offset, unsigned long size)
+{
+	return __ia64_ioremap(offset, size, _PAGE_MA_UC);
+}
+
+static inline void
+iounmap (void *addr)
+{
+	__ia64_iounmap(addr);
+}
+#endif
 
 # ifdef __KERNEL__
 
--- linux-2.4.4/include/asm-ia64/pgtable.h.~1~	Thu Apr  5 21:51:47 2001
+++ linux-2.4.4/include/asm-ia64/pgtable.h	Sat Aug 11 23:59:36 2001
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

--------------AC339179474D5777E08517A4--



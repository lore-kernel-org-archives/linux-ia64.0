From: Steffen Persvold <sp@scali.no>
Date: Mon, 10 Sep 2001 19:29:17 +0000
Subject: Re: [Linux-ia64] Re: Write Combining (Write Coalescing) on memory mapped
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------928874364022458C7784A02F"
Message-Id: <marc-linux-ia64-105590698805158@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805106@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805106@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------928874364022458C7784A02F
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David Mosberger wrote:
> 
> >>>>> On Mon, 10 Sep 2001 17:26:47 +0200, Steffen Persvold <sp@scali.no> said:
> 
>   Steffen> This is what my original post (which included a patch)
>   Steffen> tried to do, but I didn't get it too work. I know you gave
>   Steffen> me feedback on this David, saying that it just may need
>   Steffen> some debugging. Does anyone on the list have the time to
>   Steffen> just look through the patch and try to analyze what's going
>   Steffen> wrong (or maybe just give me some hints on what to look
>   Steffen> for) ?
> 
> I don't, not in the near future at least.
> 
> There is nothing magical about debugging on ia64.  Just use the normal
> techniques: try to narrow down what's triggering the problem, e.g.,
> via binary search, printk, etc.  A kdb patch is also available.
> 

Yep, I know. But I managed to solve it without the use of kdb. It was just a
question of using the right __pgprot flags. I've attached a new patch, it's made
against 2.4.4 but it also applies cleanly to a vanilla 2.4.9 tree. I guess this
means that we don't have to use the uncached region 6 anymore; ioremap() could
be modified to use __ia64_ioremap() with the _PAGE_MA_WC attribute and
ioremap_nocache() to with the _PAGE_MA_UC attribute. Any comments ?

I sure hope that this is patch that you would consider going into the main ia64
tree.

Regards,
-- 
  Steffen Persvold   |  Scali Computer AS   |   Try out the world's best   
 mailto:sp@scali.no  | http://www.scali.com | performing MPI implementation:
Tel: (+47) 2262 8950 |  Olaf Helsets vei 6  |      - ScaMPI 1.12.2 -         
Fax: (+47) 2262 8951 |  N0621 Oslo, NORWAY  | >300MBytes/s and <4uS latency
--------------928874364022458C7784A02F
Content-Type: text/plain; charset=us-ascii;
 name="ia64-ioremap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64-ioremap.patch"

--- linux-2.4.4/arch/ia64/mm/Makefile.~1~	Thu Jan  4 21:50:17 2001
+++ linux-2.4.4/arch/ia64/mm/Makefile	Sat Aug 11 21:20:03 2001
@@ -9,6 +9,6 @@
 
 O_TARGET := mm.o
 
-obj-y	 := init.o fault.o tlb.o extable.o
+obj-y	 := init.o fault.o ioremap.o tlb.o extable.o
 
 include $(TOPDIR)/Rules.make
--- linux-2.4.4/arch/ia64/mm/ioremap.c.~1~	Tue May  5 22:32:27 1998
+++ linux-2.4.4/arch/ia64/mm/ioremap.c	Sat Aug 11 23:57:31 2001
@@ -0,0 +1,154 @@
+/*
+ *  arch/s390/mm/ioremap.c
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
+	/* Don't allow wraparound or zero size */
+	last_addr = phys_addr + size - 1;
+	if (!size || last_addr < phys_addr)
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
+	return vfree(addr);
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
+++ linux-2.4.4/include/asm-ia64/io.h	Sat Aug 11 23:59:36 2001
@@ -386,6 +386,9 @@
 
 #define ioremap_nocache(o,s)	ioremap(o,s)
 
+extern void * __ia64_ioremap(unsigned long offset, unsigned long size, unsigned long flags);
+extern void __ia64_iounmap(void *addr);
+
 # ifdef __KERNEL__
 
 /*

--------------928874364022458C7784A02F--



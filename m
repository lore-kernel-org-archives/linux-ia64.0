From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 19 Jan 2005 22:16:28 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <200501191416.28659.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_8wt7B1+JnV4ZQvt"
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_8wt7B1+JnV4ZQvt
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday, January 19, 2005 2:07 pm, David Mosberger wrote:
> >>>>> On Wed, 19 Jan 2005 13:51:45 -0800, Jesse Barnes <jbarnes@sgi.com>
> >>>>> said:
>
>   Jesse> Something like this then?
>
> Shouldn't the #ifdef test be for CONFIG_EFI rather than ia64?

No, it still depends on pgprot_writecombined, which is ia64 specific.  x86 has 
its own way to set the wc bit and afaik doesn't have the same aliasing issues 
that ia64 has.

This one fixes the loop stride Tony pointed out.

Jesse

--Boundary-00=_8wt7B1+JnV4ZQvt
Content-Type: text/plain;
  charset="iso-8859-1";
  name="efi-check-wc-range-4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="efi-check-wc-range-4.patch"

===== arch/ia64/pci/pci.c 1.65 vs edited =====
--- 1.65/arch/ia64/pci/pci.c	2005-01-12 10:08:48 -08:00
+++ edited/arch/ia64/pci/pci.c	2005-01-19 11:09:32 -08:00
@@ -539,7 +539,8 @@
 	 */
 	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO);
 
-	if (write_combine)
+	if (write_combine && efi_range_is_wc(vma->vm_start,
+					     vma->vm_end - vma->vm_start))
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 	else
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
===== drivers/video/fbmem.c 1.148 vs edited =====
--- 1.148/drivers/video/fbmem.c	2005-01-05 15:46:41 -08:00
+++ edited/drivers/video/fbmem.c	2005-01-19 14:15:41 -08:00
@@ -35,6 +35,7 @@
 #include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/device.h>
+#include <linux/efi.h>
 
 #if defined(__mc68000__) || defined(CONFIG_APUS)
 #include <asm/setup.h>
@@ -950,9 +951,13 @@
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 #elif defined(__hppa__)
 	pgprot_val(vma->vm_page_prot) |= _PAGE_NO_CACHE;
-#elif defined(__ia64__) || defined(__arm__) || defined(__sh__) || \
-      defined(__m32r__)
+#elif defined(__arm__) || defined(__sh__) || defined(__m32r__)
 	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+#elif defined(__ia64)
+	if (efi_range_is_wc(vma->vm_start, vma->vm_end - vma->vm_start))
+		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+	else
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 #else
 #warning What do we have to do here??
 #endif
===== include/linux/efi.h 1.12 vs edited =====
--- 1.12/include/linux/efi.h	2004-11-18 23:03:10 -08:00
+++ edited/include/linux/efi.h	2005-01-19 14:04:14 -08:00
@@ -305,6 +305,27 @@
 extern int __init efi_set_rtc_mmss(unsigned long nowtime);
 extern struct efi_memory_map memmap;
 
+/**
+ * efi_range_is_wc - check the WC bit on an address range
+ * @start: starting kvirt address
+ * @len: length of range
+ *
+ * Consult the EFI memory map and make sure it's ok to set this range WC.
+ * Returns true or false.
+ */
+static inline int efi_range_is_wc(unsigned long start, unsigned long len)
+{
+	int i;
+
+	for (i = 0; i < len; i += (1UL << EFI_PAGE_SHIFT)) {
+		unsigned long paddr = __pa(start + i);
+		if (!(efi_mem_attributes(paddr) & EFI_MEMORY_WC))
+			return 0;
+	}
+	/* The range checked out */
+	return 1;
+}
+
 #ifdef CONFIG_EFI_PCDP
 extern int __init efi_setup_pcdp_console(char *);
 #endif

--Boundary-00=_8wt7B1+JnV4ZQvt--

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 30 Mar 2007 16:33:11 +0000
Subject: [patch 1/5] ia64: rename ioremap variables to match i386
Message-Id: <200703301033.11492.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211621.33943.bjorn.helgaas@hp.com>
In-Reply-To: <200703211621.33943.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No functional change, just use the same names as i386.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm10/arch/ia64/mm/ioremap.c
=================================--- work-mm10.orig/arch/ia64/mm/ioremap.c	2007-03-16 14:03:11.000000000 -0700
+++ work-mm10/arch/ia64/mm/ioremap.c	2007-03-16 14:04:21.000000000 -0700
@@ -14,13 +14,13 @@
 #include <asm/meminit.h>
 
 static inline void __iomem *
-__ioremap (unsigned long offset, unsigned long size)
+__ioremap (unsigned long phys_addr, unsigned long size)
 {
-	return (void __iomem *) (__IA64_UNCACHED_OFFSET | offset);
+	return (void __iomem *) (__IA64_UNCACHED_OFFSET | phys_addr);
 }
 
 void __iomem *
-ioremap (unsigned long offset, unsigned long size)
+ioremap (unsigned long phys_addr, unsigned long size)
 {
 	u64 attr;
 	unsigned long gran_base, gran_size;
@@ -30,31 +30,31 @@
 	 * as the rest of the kernel.  For more details, see
 	 * Documentation/ia64/aliasing.txt.
 	 */
-	attr = kern_mem_attribute(offset, size);
+	attr = kern_mem_attribute(phys_addr, size);
 	if (attr & EFI_MEMORY_WB)
-		return (void __iomem *) phys_to_virt(offset);
+		return (void __iomem *) phys_to_virt(phys_addr);
 	else if (attr & EFI_MEMORY_UC)
-		return __ioremap(offset, size);
+		return __ioremap(phys_addr, size);
 
 	/*
 	 * Some chipsets don't support UC access to memory.  If
 	 * WB is supported for the whole granule, we prefer that.
 	 */
-	gran_base = GRANULEROUNDDOWN(offset);
-	gran_size = GRANULEROUNDUP(offset + size) - gran_base;
+	gran_base = GRANULEROUNDDOWN(phys_addr);
+	gran_size = GRANULEROUNDUP(phys_addr + size) - gran_base;
 	if (efi_mem_attribute(gran_base, gran_size) & EFI_MEMORY_WB)
-		return (void __iomem *) phys_to_virt(offset);
+		return (void __iomem *) phys_to_virt(phys_addr);
 
-	return __ioremap(offset, size);
+	return __ioremap(phys_addr, size);
 }
 EXPORT_SYMBOL(ioremap);
 
 void __iomem *
-ioremap_nocache (unsigned long offset, unsigned long size)
+ioremap_nocache (unsigned long phys_addr, unsigned long size)
 {
-	if (kern_mem_attribute(offset, size) & EFI_MEMORY_WB)
+	if (kern_mem_attribute(phys_addr, size) & EFI_MEMORY_WB)
 		return NULL;
 
-	return __ioremap(offset, size);
+	return __ioremap(phys_addr, size);
 }
 EXPORT_SYMBOL(ioremap_nocache);

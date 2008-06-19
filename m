From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 12:16:22 +0000
Subject: Re: [PATCH 09/27] ia64/xen: implement the arch specific part of xencomm.
Message-Id: <20080619121622.GQ11378%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840434082-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840434082-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2008 at 01:39:02PM -0700, Luck, Tony wrote:
> > On ia64/xen, pointer argument for the hypercall is passed
> > by pseudo physical address (guest phsysical address.)
> s/phsysical/physical/
> 
> > So it is necessary to convert virtual address into pseudo physical
> > address rigth before issuing hypercall. The frame work is called
> s/rigth/right/
> 
> 
> 
> +#ifdef HAVE_XEN_PLATFORM_COMPAT_H
> +#include <xen/platform-compat.h>
> +#endif
> 
> What is this for?  This patch series doesn't make this file.

Eliminated.


> +static unsigned long kernel_start_pa;
> +
> +void
> +xencomm_initialize(void)
> +{
> +       kernel_start_pa = KERNEL_START - ia64_tpa(KERNEL_START);
> +}
> 
> "kernel_start_pa" is an unhelpful name ... this variable doesn't
> contain the starting physical address (which is what the name
> sounds like).  Perhaps "kernel_virtual_offset" is better?

renamed.


> +       if (vaddr > TASK_SIZE) {
> +               /* kernel address */
> +               return __pa(vaddr);
> +       }
> 
> Can this routine ever be given the address of a percpu variable?
> This will return the wrong value if someone does.
> 
> +#define is_kernel_addr(x)                                      \
> +       ((PAGE_OFFSET <= (x) &&                                 \
> +         (x) < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) || \
> +        (KERNEL_START <= (x) &&                                \
> +         (x) < KERNEL_START + KERNEL_TR_PAGE_SIZE))
> 
> Misleading name.  What does it consider a "kernel_addr"? Just
> region 7 (up to physical address limit) and the piece of region
> 5 that is mapped by itr[0]/dtr[0].  Preferebly pick a better name
> or add a comment here saying what this is testing for.

How about xencomm_is_phys_contiguous()?
Renaming it requires patches to drivers/xen/xencomm.c.
If okay, I'll also send the patch to common files.

From 073c9b5b24b26d3e5cac175c8bc42ad880cb9b82 Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 19:56:28 +0900
Subject: [PATCH] ia64/xen: implement the arch specific part of xencomm.

On ia64/xen, pointer argument for the hypercall is passed
by pseudo physical address (guest physical address.)
So it is necessary to convert virtual address into pseudo physical
address right before issuing hypercall. The frame work is called
xencomm. This patch implements arch specific part.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
---
 arch/ia64/xen/Makefile         |    2 +-
 arch/ia64/xen/xencomm.c        |   94 ++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/xen/xencomm.h |   43 ++++++++++++++++++
 3 files changed, 138 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/xencomm.c
 create mode 100644 include/asm-ia64/xen/xencomm.h

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index c200704..ad0c9f7 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -2,4 +2,4 @@
 # Makefile for Xen components
 #
 
-obj-y := hypercall.o
+obj-y := hypercall.o xencomm.o
diff --git a/arch/ia64/xen/xencomm.c b/arch/ia64/xen/xencomm.c
new file mode 100644
index 0000000..2a57058
--- /dev/null
+++ b/arch/ia64/xen/xencomm.c
@@ -0,0 +1,94 @@
+/*
+ * Copyright (C) 2006 Hollis Blanchard <hollisb@us.ibm.com>, IBM Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#include <linux/mm.h>
+
+static unsigned long kernel_virtual_offset;
+
+void
+xencomm_initialize(void)
+{
+	kernel_virtual_offset = KERNEL_START - ia64_tpa(KERNEL_START);
+}
+
+/* Translate virtual address to physical address.  */
+unsigned long
+xencomm_vtop(unsigned long vaddr)
+{
+	struct page *page;
+	struct vm_area_struct *vma;
+
+	if (vaddr = 0)
+		return 0;
+
+	if (REGION_NUMBER(vaddr) = 5) {
+		pgd_t *pgd;
+		pud_t *pud;
+		pmd_t *pmd;
+		pte_t *ptep;
+
+		/* On ia64, TASK_SIZE refers to current.  It is not initialized
+		   during boot.
+		   Furthermore the kernel is relocatable and __pa() doesn't
+		   work on  addresses.  */
+		if (vaddr >= KERNEL_START
+		    && vaddr < (KERNEL_START + KERNEL_TR_PAGE_SIZE))
+			return vaddr - kernel_virtual_offset;
+
+		/* In kernel area -- virtually mapped.  */
+		pgd = pgd_offset_k(vaddr);
+		if (pgd_none(*pgd) || pgd_bad(*pgd))
+			return ~0UL;
+
+		pud = pud_offset(pgd, vaddr);
+		if (pud_none(*pud) || pud_bad(*pud))
+			return ~0UL;
+
+		pmd = pmd_offset(pud, vaddr);
+		if (pmd_none(*pmd) || pmd_bad(*pmd))
+			return ~0UL;
+
+		ptep = pte_offset_kernel(pmd, vaddr);
+		if (!ptep)
+			return ~0UL;
+
+		return (pte_val(*ptep) & _PFN_MASK) | (vaddr & ~PAGE_MASK);
+	}
+
+	if (vaddr > TASK_SIZE) {
+		/* percpu variables */
+		if (REGION_NUMBER(vaddr) = 7 &&
+		    REGION_OFFSET(vaddr) >= (1ULL << IA64_MAX_PHYS_BITS))
+			ia64_tpa(vaddr);
+
+		/* kernel address */
+		return __pa(vaddr);
+	}
+
+	/* XXX double-check (lack of) locking */
+	vma = find_extend_vma(current->mm, vaddr);
+	if (!vma)
+		return ~0UL;
+
+	/* We assume the page is modified.  */
+	page = follow_page(vma, vaddr, FOLL_WRITE | FOLL_TOUCH);
+	if (!page)
+		return ~0UL;
+
+	return (page_to_pfn(page) << PAGE_SHIFT) | (vaddr & ~PAGE_MASK);
+}
diff --git a/include/asm-ia64/xen/xencomm.h b/include/asm-ia64/xen/xencomm.h
new file mode 100644
index 0000000..2ef31ae
--- /dev/null
+++ b/include/asm-ia64/xen/xencomm.h
@@ -0,0 +1,43 @@
+/*
+ * Copyright (C) 2006 Hollis Blanchard <hollisb@us.ibm.com>, IBM Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#ifndef _ASM_IA64_XEN_XENCOMM_H
+#define _ASM_IA64_XEN_XENCOMM_H
+
+#include <xen/xencomm.h>
+#include <asm/pgtable.h>
+
+/* Must be called before any hypercall.  */
+extern void xencomm_initialize(void);
+
+/* Check if virtual contiguity means physical contiguity.
+ * On ia64, identity mapping area in region 7 or the piece of region 5
+ * that is mapped by itr[IA64_TR_KERNEL]/dtr[IA64_TR_KERNEL]
+ */
+static inline int xencomm_is_phys_contiguous(unsigned long addr)
+{
+	if ((PAGE_OFFSET <= addr &&
+	     addr < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) ||
+	    (KERNEL_START <= addr &&
+	     addr < KERNEL_START + KERNEL_TR_PAGE_SIZE))
+		return 1;
+
+	return 0;
+}
+
+#endif /* _ASM_IA64_XEN_XENCOMM_H */
-- 
1.5.3
-- 
yamahata

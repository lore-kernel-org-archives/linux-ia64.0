From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:58:22 +0000
Subject: [PATCH 10/30] ia64/xen: implement the arch specific part of xencomm.
Message-Id: <1219730322-11687-11-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On ia64/xen, pointer argument for the hypercall is passed
by pseudo physical address (guest physical address.)
So it is necessary to convert virtual address into pseudo physical
address right before issuing hypercall. The frame work is called
xencomm. This patch implements arch specific part.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Akio Takebe <takebe_akio@jp.fujitsu.com>
---
 arch/ia64/include/asm/xen/xencomm.h |   41 +++++++++++++++
 arch/ia64/xen/Makefile              |    2 +-
 arch/ia64/xen/xencomm.c             |   94 +++++++++++++++++++++++++++++++++++
 3 files changed, 136 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/include/asm/xen/xencomm.h
 create mode 100644 arch/ia64/xen/xencomm.c

diff --git a/arch/ia64/include/asm/xen/xencomm.h b/arch/ia64/include/asm/xen/xencomm.h
new file mode 100644
index 0000000..28732cd
--- /dev/null
+++ b/arch/ia64/include/asm/xen/xencomm.h
@@ -0,0 +1,41 @@
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
+/* Check if virtual contiguity means physical contiguity
+ * where the passed address is a pointer value in virtual address.
+ * On ia64, identity mapping area in region 7 or the piece of region 5
+ * that is mapped by itr[IA64_TR_KERNEL]/dtr[IA64_TR_KERNEL]
+ */
+static inline int xencomm_is_phys_contiguous(unsigned long addr)
+{
+	return (PAGE_OFFSET <= addr &&
+		addr < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) ||
+		(KERNEL_START <= addr &&
+		 addr < KERNEL_START + KERNEL_TR_PAGE_SIZE);
+}
+
+#endif /* _ASM_IA64_XEN_XENCOMM_H */
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
index 0000000..3dc307f
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
+		return 0UL;
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
-- 
1.6.0.rc0.42.g186458


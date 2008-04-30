From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:30:38 +0000
Subject: [PATCH 07/23] ia64/xen: implement the arch specific part of xencomm.
Message-Id: <1209558654549-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077166302641-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077166302641-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On ia64/xen, pointer argument for the hypercall is passed
by pseudo physical address (guest phsysical address.)
So it is necessary to convert virtual address into pseudo physical
address rigth before issuing hypercall. The frame work is called
xencomm. This patch implements arch specific part.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile         |    2 +-
 arch/ia64/xen/xencomm.c        |   95 ++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/xen/xencomm.h |   33 ++++++++++++++
 3 files changed, 129 insertions(+), 1 deletions(-)
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
index 0000000..659d98f
--- /dev/null
+++ b/arch/ia64/xen/xencomm.c
@@ -0,0 +1,95 @@
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
+#ifdef HAVE_XEN_PLATFORM_COMPAT_H
+#include <xen/platform-compat.h>
+#endif
+
+static unsigned long kernel_start_pa;
+
+void
+xencomm_initialize(void)
+{
+	kernel_start_pa = KERNEL_START - ia64_tpa(KERNEL_START);
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
+#ifdef __ia64__
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
+			return vaddr - kernel_start_pa;
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
+#endif
+
+	if (vaddr > TASK_SIZE) {
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
index 0000000..e95db51
--- /dev/null
+++ b/include/asm-ia64/xen/xencomm.h
@@ -0,0 +1,33 @@
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
+#define is_kernel_addr(x)					\
+	((PAGE_OFFSET <= (x) &&					\
+	  (x) < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) ||	\
+	 (KERNEL_START <= (x) &&				\
+	  (x) < KERNEL_START + KERNEL_TR_PAGE_SIZE))
+
+/* Must be called before any hypercall.  */
+extern void xencomm_initialize(void);
+
+#include <xen/xencomm.h>
+
+#endif /* _ASM_IA64_XEN_XENCOMM_H */
-- 
1.5.3


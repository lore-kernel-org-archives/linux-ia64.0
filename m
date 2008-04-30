From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:30:36 +0000
Subject: [PATCH 05/23] ia64/xen: define helper functions for xen related address conversion.
Message-Id: <1209558654780-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077166302402-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077166302402-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xen needs some address conversions between pseudo physical
address (guest phsyical address), guest machine address
(real machine address) and dma address.
Define helper functions for those address conversion.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/xen/page.h |   65 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/xen/page.h

diff --git a/include/asm-ia64/xen/page.h b/include/asm-ia64/xen/page.h
new file mode 100644
index 0000000..c3c18f9
--- /dev/null
+++ b/include/asm-ia64/xen/page.h
@@ -0,0 +1,65 @@
+/******************************************************************************
+ * include/asm-ia64/xen/page.h
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _ASM_IA64_XEN_PAGE_H
+#define _ASM_IA64_XEN_PAGE_H
+
+#define INVALID_P2M_ENTRY	(~0UL)
+
+static inline unsigned long mfn_to_pfn(unsigned long mfn)
+{
+	return mfn;
+}
+
+static inline unsigned long pfn_to_mfn(unsigned long pfn)
+{
+	return pfn;
+}
+
+#define phys_to_machine_mapping_valid(_x)	(1)
+
+static inline void *mfn_to_virt(unsigned long mfn)
+{
+	return __va(mfn << PAGE_SHIFT);
+}
+
+static inline unsigned long virt_to_mfn(void *virt)
+{
+	return __pa(virt) >> PAGE_SHIFT;
+}
+
+/* for tpmfront.c */
+static inline unsigned long virt_to_machine(void *virt)
+{
+	return __pa(virt);
+}
+
+static inline void set_phys_to_machine(unsigned long pfn, unsigned long mfn)
+{
+	/* nothing */
+}
+
+#define pte_mfn(_x)	pte_pfn(_x)
+#define mfn_pte(_x, _y)	__pte_ma(0)		/* unmodified use */
+#define __pte_ma(_x)	((pte_t) {(_x)})        /* unmodified use */
+
+#endif /* _ASM_IA64_XEN_PAGE_H */
-- 
1.5.3


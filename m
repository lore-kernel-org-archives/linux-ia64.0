From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:19:01 +0000
Subject: [PATCH 46/50] ia64/xen: define xen related address conversion helper functions for domU
Message-Id: <12047411464035-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/page.h     |    8 ++++++++
 include/asm-ia64/xen/page.h |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/xen/page.h

diff --git a/include/asm-ia64/page.h b/include/asm-ia64/page.h
index 4999a6c..5508dc2 100644
--- a/include/asm-ia64/page.h
+++ b/include/asm-ia64/page.h
@@ -227,4 +227,12 @@ get_order (unsigned long size)
 					 (((current->personality & READ_IMPLIES_EXEC) != 0)	\
 					  ? VM_EXEC : 0))
 
+/*
+ * XXX: to compile
+ * after pv_ops'fication of xen paravirtualization, this should be removed.
+ */
+#if !defined(__ASSEMBLY__) && defined(CONFIG_XEN)
+#include <asm/xen/page.h>
+#endif /* !__ASSEMBLY__ && CONFIG_XEN */
+
 #endif /* _ASM_IA64_PAGE_H */
diff --git a/include/asm-ia64/xen/page.h b/include/asm-ia64/xen/page.h
new file mode 100644
index 0000000..c562036
--- /dev/null
+++ b/include/asm-ia64/xen/page.h
@@ -0,0 +1,41 @@
+#ifndef _ASM_IA64_XEN_PAGE_H
+#define _ASM_IA64_XEN_PAGE_H
+
+#include <linux/kernel.h>
+#include <asm/xen/hypervisor.h>
+#include <asm/xen/hypercall.h>
+#include <xen/features.h>
+#include <xen/interface/xen.h>
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
+#endif /* _ASM_IA64_XEN_PAGE_H */
-- 
1.5.3


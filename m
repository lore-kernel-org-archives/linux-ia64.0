From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:07:46 +0000
Subject: [PATCH 09/11] xen: make grant table arch portable.
Message-Id: <1203656869264-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036568683779-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036568683779-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, yamahata@valinux.co.jp

split out x86 specific part from grant-table.c

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/x86/xen/Makefile      |    2 +-
 arch/x86/xen/grant-table.c |   91 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/xen/grant-table.c  |   35 +---------------
 include/xen/grant_table.h  |    6 +++
 4 files changed, 101 insertions(+), 33 deletions(-)
 create mode 100644 arch/x86/xen/grant-table.c

diff --git a/arch/x86/xen/Makefile b/arch/x86/xen/Makefile
index 95c5926..3d8df98 100644
--- a/arch/x86/xen/Makefile
+++ b/arch/x86/xen/Makefile
@@ -1,4 +1,4 @@
 obj-y		:= enlighten.o setup.o multicalls.o mmu.o \
-			time.o manage.o xen-asm.o
+			time.o manage.o xen-asm.o grant-table.o
 
 obj-$(CONFIG_SMP)	+= smp.o
diff --git a/arch/x86/xen/grant-table.c b/arch/x86/xen/grant-table.c
new file mode 100644
index 0000000..49ba9b5
--- /dev/null
+++ b/arch/x86/xen/grant-table.c
@@ -0,0 +1,91 @@
+/******************************************************************************
+ * grant_table.c
+ * x86 specific part
+ *
+ * Granting foreign access to our memory reservation.
+ *
+ * Copyright (c) 2005-2006, Christopher Clark
+ * Copyright (c) 2004-2005, K A Fraser
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan. Split out x86 specific part.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+
+#include <xen/interface/xen.h>
+#include <xen/page.h>
+#include <xen/grant_table.h>
+
+#include <asm/pgtable.h>
+
+static int map_pte_fn(pte_t *pte, struct page *pmd_page,
+		      unsigned long addr, void *data)
+{
+	unsigned long **frames = (unsigned long **)data;
+
+	set_pte_at(&init_mm, addr, pte, mfn_pte((*frames)[0], PAGE_KERNEL));
+	(*frames)++;
+	return 0;
+}
+
+static int unmap_pte_fn(pte_t *pte, struct page *pmd_page,
+			unsigned long addr, void *data)
+{
+
+	set_pte_at(&init_mm, addr, pte, __pte(0));
+	return 0;
+}
+
+int arch_gnttab_map_shared(unsigned long *frames, unsigned long nr_gframes,
+			   unsigned long max_nr_gframes,
+			   struct grant_entry **__shared)
+{
+	int rc;
+	struct grant_entry *shared = *__shared;
+
+	if (shared = NULL) {
+		struct vm_struct *area +			xen_alloc_vm_area(PAGE_SIZE * max_nr_gframes);
+		BUG_ON(area = NULL);
+		shared = area->addr;
+		*__shared = shared;
+	}
+
+	rc = apply_to_page_range(&init_mm, (unsigned long)shared,
+				 PAGE_SIZE * nr_gframes,
+				 map_pte_fn, &frames);
+	return rc;
+}
+
+void arch_gnttab_unmap_shared(struct grant_entry *shared,
+			      unsigned long nr_gframes)
+{
+	apply_to_page_range(&init_mm, (unsigned long)shared,
+			    PAGE_SIZE * nr_gframes, unmap_pte_fn, NULL);
+}
diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index 9fcde20..22f5104 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -435,24 +435,6 @@ static inline unsigned int max_nr_grant_frames(void)
 	return xen_max;
 }
 
-static int map_pte_fn(pte_t *pte, struct page *pmd_page,
-		      unsigned long addr, void *data)
-{
-	unsigned long **frames = (unsigned long **)data;
-
-	set_pte_at(&init_mm, addr, pte, mfn_pte((*frames)[0], PAGE_KERNEL));
-	(*frames)++;
-	return 0;
-}
-
-static int unmap_pte_fn(pte_t *pte, struct page *pmd_page,
-			unsigned long addr, void *data)
-{
-
-	set_pte_at(&init_mm, addr, pte, __pte(0));
-	return 0;
-}
-
 static int gnttab_map(unsigned int start_idx, unsigned int end_idx)
 {
 	struct gnttab_setup_table setup;
@@ -476,17 +458,9 @@ static int gnttab_map(unsigned int start_idx, unsigned int end_idx)
 
 	BUG_ON(rc || setup.status);
 
-	if (shared = NULL) {
-		struct vm_struct *area;
-		area = xen_alloc_vm_area(PAGE_SIZE * max_nr_grant_frames());
-		BUG_ON(area = NULL);
-		shared = area->addr;
-	}
-	rc = apply_to_page_range(&init_mm, (unsigned long)shared,
-				 PAGE_SIZE * nr_gframes,
-				 map_pte_fn, &frames);
+	rc = arch_gnttab_map_shared(frames, nr_gframes, max_nr_grant_frames(),
+				    &shared);
 	BUG_ON(rc);
-	frames -= nr_gframes; /* adjust after map_pte_fn() */
 
 	kfree(frames);
 
@@ -502,10 +476,7 @@ static int gnttab_resume(void)
 
 static int gnttab_suspend(void)
 {
-	apply_to_page_range(&init_mm, (unsigned long)shared,
-			    PAGE_SIZE * nr_grant_frames,
-			    unmap_pte_fn, NULL);
-
+	arch_gnttab_unmap_shared(shared, nr_grant_frames);
 	return 0;
 }
 
diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
index 761c834..50ca16e 100644
--- a/include/xen/grant_table.h
+++ b/include/xen/grant_table.h
@@ -102,6 +102,12 @@ void gnttab_grant_foreign_access_ref(grant_ref_t ref, domid_t domid,
 void gnttab_grant_foreign_transfer_ref(grant_ref_t, domid_t domid,
 				       unsigned long pfn);
 
+int arch_gnttab_map_shared(unsigned long *frames, unsigned long nr_gframes,
+			   unsigned long max_nr_gframes,
+			   struct grant_entry **__shared);
+void arch_gnttab_unmap_shared(struct grant_entry *shared,
+			      unsigned long nr_gframes);
+
 #define gnttab_map_vaddr(map) ((void *)(map.host_virt_addr))
 
 #endif /* __ASM_GNTTAB_H__ */
-- 
1.5.3


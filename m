From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 11 Jul 2022 07:17:36 +0000
Subject: [PATCH V7 02/26] mm/mmap: Define DECLARE_VM_GET_PAGE_PROT
Message-Id: <20220711070600.2378316-3-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220711070600.2378316-1-anshuman.khandual@arm.com>
In-Reply-To: <20220711070600.2378316-1-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: hch@infradead.org, christophe.leroy@csgroup.eu, Anshuman Khandual <anshuman.khandual@arm.com>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

This just converts the generic vm_get_page_prot() implementation into a new
macro i.e DECLARE_VM_GET_PAGE_PROT which later can be used across platforms
when enabling them with ARCH_HAS_VM_GET_PAGE_PROT. This does not create any
functional change.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Reviewed-by: Christophe Leroy <christophe.leroy@csgroup.eu>
Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/pgtable.h | 28 ++++++++++++++++++++++++++++
 mm/mmap.c               | 26 +-------------------------
 2 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/include/linux/pgtable.h b/include/linux/pgtable.h
index 3cdc16cfd867..014ee8f0fbaa 100644
--- a/include/linux/pgtable.h
+++ b/include/linux/pgtable.h
@@ -1689,4 +1689,32 @@ typedef unsigned int pgtbl_mod_mask;
 #define MAX_PTRS_PER_P4D PTRS_PER_P4D
 #endif
 
+/* description of effects of mapping type and prot in current implementation.
+ * this is due to the limited x86 page protection hardware.  The expected
+ * behavior is in parens:
+ *
+ * map_type	prot
+ *		PROT_NONE	PROT_READ	PROT_WRITE	PROT_EXEC
+ * MAP_SHARED	r: (no) no	r: (yes) yes	r: (no) yes	r: (no) yes
+ *		w: (no) no	w: (no) no	w: (yes) yes	w: (no) no
+ *		x: (no) no	x: (no) yes	x: (no) yes	x: (yes) yes
+ *
+ * MAP_PRIVATE	r: (no) no	r: (yes) yes	r: (no) yes	r: (no) yes
+ *		w: (no) no	w: (no) no	w: (copy) copy	w: (no) no
+ *		x: (no) no	x: (no) yes	x: (no) yes	x: (yes) yes
+ *
+ * On arm64, PROT_EXEC has the following behaviour for both MAP_SHARED and
+ * MAP_PRIVATE (with Enhanced PAN supported):
+ *								r: (no) no
+ *								w: (no) no
+ *								x: (yes) yes
+ */
+#define DECLARE_VM_GET_PAGE_PROT					\
+pgprot_t vm_get_page_prot(unsigned long vm_flags)			\
+{									\
+		return protection_map[vm_flags &			\
+			(VM_READ | VM_WRITE | VM_EXEC | VM_SHARED)];	\
+}									\
+EXPORT_SYMBOL(vm_get_page_prot);
+
 #endif /* _LINUX_PGTABLE_H */
diff --git a/mm/mmap.c b/mm/mmap.c
index b01f0280bda2..b46d5e931bb3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -81,26 +81,6 @@ static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
 
-/* description of effects of mapping type and prot in current implementation.
- * this is due to the limited x86 page protection hardware.  The expected
- * behavior is in parens:
- *
- * map_type	prot
- *		PROT_NONE	PROT_READ	PROT_WRITE	PROT_EXEC
- * MAP_SHARED	r: (no) no	r: (yes) yes	r: (no) yes	r: (no) yes
- *		w: (no) no	w: (no) no	w: (yes) yes	w: (no) no
- *		x: (no) no	x: (no) yes	x: (no) yes	x: (yes) yes
- *
- * MAP_PRIVATE	r: (no) no	r: (yes) yes	r: (no) yes	r: (no) yes
- *		w: (no) no	w: (no) no	w: (copy) copy	w: (no) no
- *		x: (no) no	x: (no) yes	x: (no) yes	x: (yes) yes
- *
- * On arm64, PROT_EXEC has the following behaviour for both MAP_SHARED and
- * MAP_PRIVATE (with Enhanced PAN supported):
- *								r: (no) no
- *								w: (no) no
- *								x: (yes) yes
- */
 #ifdef __P000
 pgprot_t protection_map[16] __ro_after_init = {
 	[VM_NONE]					= __P000,
@@ -123,11 +103,7 @@ pgprot_t protection_map[16] __ro_after_init = {
 #endif
 
 #ifndef CONFIG_ARCH_HAS_VM_GET_PAGE_PROT
-pgprot_t vm_get_page_prot(unsigned long vm_flags)
-{
-	return protection_map[vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
-}
-EXPORT_SYMBOL(vm_get_page_prot);
+DECLARE_VM_GET_PAGE_PROT
 #endif	/* CONFIG_ARCH_HAS_VM_GET_PAGE_PROT */
 
 static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
-- 
2.25.1

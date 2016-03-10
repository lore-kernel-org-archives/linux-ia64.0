From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 10 Mar 2016 14:43:16 +0000
Subject: [PATCH v3 4/4] ia64/extable: use generic search and sort routines
Message-Id: <1457620996-462-5-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org

Replace the arch specific versions of search_extable() and sort_extable()
with calls to the generic ones, which now support relative exception
tables as well.

Acked-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/ia64/include/asm/uaccess.h |  8 +-
 arch/ia64/mm/extable.c          | 97 +-------------------
 2 files changed, 4 insertions(+), 101 deletions(-)

diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index 4f3fb6ccbf21..2189d5ddc1ee 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -341,13 +341,11 @@ extern unsigned long __strnlen_user (const char __user *, long);
 	__su_ret;						\
 })
 
-/* Generic code can't deal with the location-relative format that we use for compactness.  */
-#define ARCH_HAS_SORT_EXTABLE
-#define ARCH_HAS_SEARCH_EXTABLE
+#define ARCH_HAS_RELATIVE_EXTABLE
 
 struct exception_table_entry {
-	int addr;	/* location-relative address of insn this fixup is for */
-	int cont;	/* location-relative continuation addr.; if bit 2 is set, r9 is set to 0 */
+	int insn;	/* location-relative address of insn this fixup is for */
+	int fixup;	/* location-relative continuation addr.; if bit 2 is set, r9 is set to 0 */
 };
 
 extern void ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
diff --git a/arch/ia64/mm/extable.c b/arch/ia64/mm/extable.c
index c99a41e29fe8..8f70bb2d0c37 100644
--- a/arch/ia64/mm/extable.c
+++ b/arch/ia64/mm/extable.c
@@ -5,107 +5,12 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-#include <linux/sort.h>
-
 #include <asm/uaccess.h>
-#include <linux/module.h>
-
-static int cmp_ex(const void *a, const void *b)
-{
-	const struct exception_table_entry *l = a, *r = b;
-	u64 lip = (u64) &l->addr + l->addr;
-	u64 rip = (u64) &r->addr + r->addr;
-
-	/* avoid overflow */
-	if (lip > rip)
-		return 1;
-	if (lip < rip)
-		return -1;
-	return 0;
-}
-
-static void swap_ex(void *a, void *b, int size)
-{
-	struct exception_table_entry *l = a, *r = b, tmp;
-	u64 delta = (u64) r - (u64) l;
-
-	tmp = *l;
-	l->addr = r->addr + delta;
-	l->cont = r->cont + delta;
-	r->addr = tmp.addr - delta;
-	r->cont = tmp.cont - delta;
-}
-
-/*
- * Sort the exception table. It's usually already sorted, but there
- * may be unordered entries due to multiple text sections (such as the
- * .init text section). Note that the exception-table-entries contain
- * location-relative addresses, which requires a bit of care during
- * sorting to avoid overflows in the offset members (e.g., it would
- * not be safe to make a temporary copy of an exception-table entry on
- * the stack, because the stack may be more than 2GB away from the
- * exception-table).
- */
-void sort_extable (struct exception_table_entry *start,
-		   struct exception_table_entry *finish)
-{
-	sort(start, finish - start, sizeof(struct exception_table_entry),
-	     cmp_ex, swap_ex);
-}
-
-static inline unsigned long ex_to_addr(const struct exception_table_entry *x)
-{
-	return (unsigned long)&x->addr + x->addr;
-}
-
-#ifdef CONFIG_MODULES
-/*
- * Any entry referring to the module init will be at the beginning or
- * the end.
- */
-void trim_init_extable(struct module *m)
-{
-	/*trim the beginning*/
-	while (m->num_exentries &&
-	       within_module_init(ex_to_addr(&m->extable[0]), m)) {
-		m->extable++;
-		m->num_exentries--;
-	}
-	/*trim the end*/
-	while (m->num_exentries &&
-	       within_module_init(ex_to_addr(&m->extable[m->num_exentries-1]),
-				  m))
-		m->num_exentries--;
-}
-#endif /* CONFIG_MODULES */
-
-const struct exception_table_entry *
-search_extable (const struct exception_table_entry *first,
-		const struct exception_table_entry *last,
-		unsigned long ip)
-{
-	const struct exception_table_entry *mid;
-	unsigned long mid_ip;
-	long diff;
-
-        while (first <= last) {
-		mid = &first[(last - first)/2];
-		mid_ip = (u64) &mid->addr + mid->addr;
-		diff = mid_ip - ip;
-                if (diff = 0)
-                        return mid;
-                else if (diff < 0)
-                        first = mid + 1;
-                else
-                        last = mid - 1;
-        }
-        return NULL;
-}
 
 void
 ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e)
 {
-	long fix = (u64) &e->cont + e->cont;
+	long fix = (u64) &e->fixup + e->fixup;
 
 	regs->r8 = -EFAULT;
 	if (fix & 4)
-- 
1.9.1


From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 10 Mar 2016 14:43:13 +0000
Subject: [PATCH v3 1/4] alpha/extable: use generic search and sort routines
Message-Id: <1457620996-462-2-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org

Replace the arch specific versions of search_extable() and sort_extable()
with calls to the generic ones, which now support relative exception
tables as well.

Acked-by: Richard Henderson <rth@twiddle.net>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/alpha/include/asm/uaccess.h | 10 ++-
 arch/alpha/mm/Makefile           |  2 +-
 arch/alpha/mm/extable.c          | 92 --------------------
 3 files changed, 9 insertions(+), 95 deletions(-)

diff --git a/arch/alpha/include/asm/uaccess.h b/arch/alpha/include/asm/uaccess.h
index 9b0d40093c9a..c419b43c461d 100644
--- a/arch/alpha/include/asm/uaccess.h
+++ b/arch/alpha/include/asm/uaccess.h
@@ -483,7 +483,13 @@ struct exception_table_entry
 	(pc) + (_fixup)->fixup.bits.nextinsn;			\
 })
 
-#define ARCH_HAS_SORT_EXTABLE
-#define ARCH_HAS_SEARCH_EXTABLE
+#define ARCH_HAS_RELATIVE_EXTABLE
+
+#define swap_ex_entry_fixup(a, b, tmp, delta)			\
+	do {							\
+		(a)->fixup.unit = (b)->fixup.unit;		\
+		(b)->fixup.unit = (tmp).fixup.unit;		\
+	} while (0)
+
 
 #endif /* __ALPHA_UACCESS_H */
diff --git a/arch/alpha/mm/Makefile b/arch/alpha/mm/Makefile
index c993d3f93cf6..5a9807936411 100644
--- a/arch/alpha/mm/Makefile
+++ b/arch/alpha/mm/Makefile
@@ -4,6 +4,6 @@
 
 ccflags-y := -Werror
 
-obj-y	:= init.o fault.o extable.o
+obj-y	:= init.o fault.o
 
 obj-$(CONFIG_DISCONTIGMEM) += numa.o
diff --git a/arch/alpha/mm/extable.c b/arch/alpha/mm/extable.c
deleted file mode 100644
index 813c9b63c0e1..000000000000
--- a/arch/alpha/mm/extable.c
+++ /dev/null
@@ -1,92 +0,0 @@
-/*
- * linux/arch/alpha/mm/extable.c
- */
-
-#include <linux/module.h>
-#include <linux/sort.h>
-#include <asm/uaccess.h>
-
-static inline unsigned long ex_to_addr(const struct exception_table_entry *x)
-{
-	return (unsigned long)&x->insn + x->insn;
-}
-
-static void swap_ex(void *a, void *b, int size)
-{
-	struct exception_table_entry *ex_a = a, *ex_b = b;
-	unsigned long addr_a = ex_to_addr(ex_a), addr_b = ex_to_addr(ex_b);
-	unsigned int t = ex_a->fixup.unit;
-
-	ex_a->fixup.unit = ex_b->fixup.unit;
-	ex_b->fixup.unit = t;
-	ex_a->insn = (int)(addr_b - (unsigned long)&ex_a->insn);
-	ex_b->insn = (int)(addr_a - (unsigned long)&ex_b->insn);
-}
-
-/*
- * The exception table needs to be sorted so that the binary
- * search that we use to find entries in it works properly.
- * This is used both for the kernel exception table and for
- * the exception tables of modules that get loaded.
- */
-static int cmp_ex(const void *a, const void *b)
-{
-	const struct exception_table_entry *x = a, *y = b;
-
-	/* avoid overflow */
-	if (ex_to_addr(x) > ex_to_addr(y))
-		return 1;
-	if (ex_to_addr(x) < ex_to_addr(y))
-		return -1;
-	return 0;
-}
-
-void sort_extable(struct exception_table_entry *start,
-		  struct exception_table_entry *finish)
-{
-	sort(start, finish - start, sizeof(struct exception_table_entry),
-	     cmp_ex, swap_ex);
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
-search_extable(const struct exception_table_entry *first,
-	       const struct exception_table_entry *last,
-	       unsigned long value)
-{
-        while (first <= last) {
-		const struct exception_table_entry *mid;
-		unsigned long mid_value;
-
-		mid = (last - first) / 2 + first;
-		mid_value = ex_to_addr(mid);
-                if (mid_value = value)
-                        return mid;
-                else if (mid_value < value)
-                        first = mid+1;
-                else
-                        last = mid-1;
-        }
-
-        return NULL;
-}
-- 
1.9.1


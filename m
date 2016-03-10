From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 10 Mar 2016 14:43:15 +0000
Subject: [PATCH v3 3/4] x86/extable: use generic search and sort routines
Message-Id: <1457620996-462-4-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-s390@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

Replace the arch specific versions of search_extable() and sort_extable()
with calls to the generic ones, which now support relative exception
tables as well.

Acked-by: H. Peter Anvin <hpa@linux.intel.com>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/x86/include/asm/uaccess.h |   5 +-
 arch/x86/mm/extable.c          | 108 --------------------
 2 files changed, 2 insertions(+), 111 deletions(-)

diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 88bff6dd23ad..a969ae607be8 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -105,9 +105,8 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 struct exception_table_entry {
 	int insn, fixup, handler;
 };
-/* This is not the generic standard exception_table_entry format */
-#define ARCH_HAS_SORT_EXTABLE
-#define ARCH_HAS_SEARCH_EXTABLE
+
+#define ARCH_HAS_RELATIVE_EXTABLE
 
 extern int fixup_exception(struct pt_regs *regs, int trapnr);
 extern bool ex_has_fault_handler(unsigned long ip);
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index 9dd7e4b7fcde..82447b3fba38 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -1,17 +1,10 @@
 #include <linux/module.h>
-#include <linux/spinlock.h>
-#include <linux/sort.h>
 #include <asm/uaccess.h>
 
 typedef bool (*ex_handler_t)(const struct exception_table_entry *,
 			    struct pt_regs *, int);
 
 static inline unsigned long
-ex_insn_addr(const struct exception_table_entry *x)
-{
-	return (unsigned long)&x->insn + x->insn;
-}
-static inline unsigned long
 ex_fixup_addr(const struct exception_table_entry *x)
 {
 	return (unsigned long)&x->fixup + x->fixup;
@@ -110,104 +103,3 @@ int __init early_fixup_exception(unsigned long *ip)
 	*ip = new_ip;
 	return 1;
 }
-
-/*
- * Search one exception table for an entry corresponding to the
- * given instruction address, and return the address of the entry,
- * or NULL if none is found.
- * We use a binary search, and thus we assume that the table is
- * already sorted.
- */
-const struct exception_table_entry *
-search_extable(const struct exception_table_entry *first,
-	       const struct exception_table_entry *last,
-	       unsigned long value)
-{
-	while (first <= last) {
-		const struct exception_table_entry *mid;
-		unsigned long addr;
-
-		mid = ((last - first) >> 1) + first;
-		addr = ex_insn_addr(mid);
-		if (addr < value)
-			first = mid + 1;
-		else if (addr > value)
-			last = mid - 1;
-		else
-			return mid;
-        }
-        return NULL;
-}
-
-/*
- * The exception table needs to be sorted so that the binary
- * search that we use to find entries in it works properly.
- * This is used both for the kernel exception table and for
- * the exception tables of modules that get loaded.
- *
- */
-static int cmp_ex(const void *a, const void *b)
-{
-	const struct exception_table_entry *x = a, *y = b;
-
-	/*
-	 * This value will always end up fittin in an int, because on
-	 * both i386 and x86-64 the kernel symbol-reachable address
-	 * space is < 2 GiB.
-	 *
-	 * This compare is only valid after normalization.
-	 */
-	return x->insn - y->insn;
-}
-
-void sort_extable(struct exception_table_entry *start,
-		  struct exception_table_entry *finish)
-{
-	struct exception_table_entry *p;
-	int i;
-
-	/* Convert all entries to being relative to the start of the section */
-	i = 0;
-	for (p = start; p < finish; p++) {
-		p->insn += i;
-		i += 4;
-		p->fixup += i;
-		i += 4;
-		p->handler += i;
-		i += 4;
-	}
-
-	sort(start, finish - start, sizeof(struct exception_table_entry),
-	     cmp_ex, NULL);
-
-	/* Denormalize all entries */
-	i = 0;
-	for (p = start; p < finish; p++) {
-		p->insn -= i;
-		i += 4;
-		p->fixup -= i;
-		i += 4;
-		p->handler -= i;
-		i += 4;
-	}
-}
-
-#ifdef CONFIG_MODULES
-/*
- * If the exception table is sorted, any referring to the module init
- * will be at the beginning or the end.
- */
-void trim_init_extable(struct module *m)
-{
-	/*trim the beginning*/
-	while (m->num_exentries &&
-	       within_module_init(ex_insn_addr(&m->extable[0]), m)) {
-		m->extable++;
-		m->num_exentries--;
-	}
-	/*trim the end*/
-	while (m->num_exentries &&
-	       within_module_init(ex_insn_addr(&m->extable[m->num_exentries-1]), m))
-		m->num_exentries--;
-}
-#endif /* CONFIG_MODULES */
-- 
1.9.1


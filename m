From: "Jan Beulich" <JBeulich@novell.com>
Date: Thu, 17 Feb 2011 17:04:15 +0000
Subject: [PATCH 3/3] ia64: drop custom exception table implementation
Message-Id: <4D5D631F0200007800032802@vpn.id2.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: mingo@elte.hu, tglx@linutronix.de, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

Now that the common extable implementation can deal with the needs
ia64 has, drop its custom implementation.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 arch/ia64/Kconfig               |    1 
 arch/ia64/include/asm/uaccess.h |    9 ---
 arch/ia64/mm/extable.c          |   98 ----------------------------------------
 3 files changed, 4 insertions(+), 104 deletions(-)

--- 2.6.38-rc5-extable.orig/arch/ia64/Kconfig
+++ 2.6.38-rc5-extable/arch/ia64/Kconfig
@@ -12,6 +12,7 @@ config IA64
 	select ARCH_SUPPORTS_MSI
 	select HAVE_UNSTABLE_SCHED_CLOCK
 	select HAVE_IDE
+	select EXTABLE_RELATIVE_POINTERS
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
--- 2.6.38-rc5-extable.orig/arch/ia64/include/asm/uaccess.h
+++ 2.6.38-rc5-extable/arch/ia64/include/asm/uaccess.h
@@ -340,14 +340,7 @@ extern unsigned long __strnlen_user (con
 	__su_ret;						\
 })
 
-/* Generic code can't deal with the location-relative format that we use for compactness.  */
-#define ARCH_HAS_SORT_EXTABLE
-#define ARCH_HAS_SEARCH_EXTABLE
-
-struct exception_table_entry {
-	int addr;	/* location-relative address of insn this fixup is for */
-	int cont;	/* location-relative continuation addr.; if bit 2 is set, r9 is set to 0 */
-};
+#include <asm-generic/extable.h>
 
 extern void ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
 extern const struct exception_table_entry *search_exception_tables (unsigned long addr);
--- 2.6.38-rc5-extable.orig/arch/ia64/mm/extable.c
+++ 2.6.38-rc5-extable/arch/ia64/mm/extable.c
@@ -5,107 +5,13 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-#include <linux/sort.h>
-
+#include <asm/ptrace.h>
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
+	unsigned long fix = ex_fixup(e);
 
 	regs->r8 = -EFAULT;
 	if (fix & 4)



From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 05 Jan 2016 15:19:35 +0000
Subject: [PATCH v2 1/6] extable: add support for relative extables to search and sort routines
Message-Id: <1452007180-27411-2-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452007180-27411-1-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1452007180-27411-1-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, hpa@zytor.com, mingo@redhat.com, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, mattst88@gmail.com, ink@jurassic.park.msu.ru, rth@twiddle.net, tony.luck@intel.com, fenghua.yu@intel.com, catalin.marinas@arm.com, will.deacon@arm.com, arnd@arndb.de
Cc: deller@gmx.de, mark.rutland@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This adds support to the generic search_extable() and sort_extable()
implementations for dealing with exception table entries whose fields
contain relative offsets rather than absolute addresses.

Acked-by: Helge Deller <deller@gmx.de>
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Acked-by: H. Peter Anvin <hpa@linux.intel.com>
Acked-by: Tony Luck <tony.luck@intel.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 lib/extable.c | 50 ++++++++++++++++----
 1 file changed, 41 insertions(+), 9 deletions(-)

diff --git a/lib/extable.c b/lib/extable.c
index 4cac81ec225e..0be02ad561e9 100644
--- a/lib/extable.c
+++ b/lib/extable.c
@@ -14,7 +14,37 @@
 #include <linux/sort.h>
 #include <asm/uaccess.h>
 
+#ifndef ARCH_HAS_RELATIVE_EXTABLE
+#define ex_to_insn(x)	((x)->insn)
+#else
+static inline unsigned long ex_to_insn(const struct exception_table_entry *x)
+{
+	return (unsigned long)&x->insn + x->insn;
+}
+#endif
+
 #ifndef ARCH_HAS_SORT_EXTABLE
+#ifndef ARCH_HAS_RELATIVE_EXTABLE
+#define swap_ex		NULL
+#else
+static void swap_ex(void *a, void *b, int size)
+{
+	struct exception_table_entry *x = a, *y = b, tmp;
+	int delta = b - a;
+
+	tmp = *x;
+	x->insn = y->insn + delta;
+	y->insn = tmp.insn - delta;
+
+#ifdef swap_ex_entry_fixup
+	swap_ex_entry_fixup(x, y, tmp, delta);
+#else
+	x->fixup = y->fixup + delta;
+	y->fixup = tmp.fixup - delta;
+#endif
+}
+#endif /* ARCH_HAS_RELATIVE_EXTABLE */
+
 /*
  * The exception table needs to be sorted so that the binary
  * search that we use to find entries in it works properly.
@@ -26,9 +56,9 @@ static int cmp_ex(const void *a, const void *b)
 	const struct exception_table_entry *x = a, *y = b;
 
 	/* avoid overflow */
-	if (x->insn > y->insn)
+	if (ex_to_insn(x) > ex_to_insn(y))
 		return 1;
-	if (x->insn < y->insn)
+	if (ex_to_insn(x) < ex_to_insn(y))
 		return -1;
 	return 0;
 }
@@ -37,7 +67,7 @@ void sort_extable(struct exception_table_entry *start,
 		  struct exception_table_entry *finish)
 {
 	sort(start, finish - start, sizeof(struct exception_table_entry),
-	     cmp_ex, NULL);
+	     cmp_ex, swap_ex);
 }
 
 #ifdef CONFIG_MODULES
@@ -48,13 +78,15 @@ void sort_extable(struct exception_table_entry *start,
 void trim_init_extable(struct module *m)
 {
 	/*trim the beginning*/
-	while (m->num_exentries && within_module_init(m->extable[0].insn, m)) {
+	while (m->num_exentries &&
+	       within_module_init(ex_to_insn(&m->extable[0]), m)) {
 		m->extable++;
 		m->num_exentries--;
 	}
 	/*trim the end*/
 	while (m->num_exentries &&
-		within_module_init(m->extable[m->num_exentries-1].insn, m))
+	       within_module_init(ex_to_insn(&m->extable[m->num_exentries - 1]),
+				  m))
 		m->num_exentries--;
 }
 #endif /* CONFIG_MODULES */
@@ -81,13 +113,13 @@ search_extable(const struct exception_table_entry *first,
 		 * careful, the distance between value and insn
 		 * can be larger than MAX_LONG:
 		 */
-		if (mid->insn < value)
+		if (ex_to_insn(mid) < value)
 			first = mid + 1;
-		else if (mid->insn > value)
+		else if (ex_to_insn(mid) > value)
 			last = mid - 1;
 		else
 			return mid;
-        }
-        return NULL;
+	}
+	return NULL;
 }
 #endif
-- 
2.5.0


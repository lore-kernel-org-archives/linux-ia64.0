From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 Jan 2005 00:09:19 +0000
Subject: [PATCH] long line, codingstyle, & include file cleanup for extable.c
Message-Id: <200501061609.20040.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_wMd3BQT77KVPGP1"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_wMd3BQT77KVPGP1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This small patch fixes long lines in extable.c, corrects function definitions 
and removes a few unnecessary #includes.

 extable.c |   46 ++++++++++++++++++++++------------------------
 1 files changed, 22 insertions(+), 24 deletions(-)

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_wMd3BQT77KVPGP1
Content-Type: text/plain;
  charset="us-ascii";
  name="extable-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="extable-cleanup.patch"

===== arch/ia64/mm/extable.c 1.10 vs edited =====
--- 1.10/arch/ia64/mm/extable.c	2004-10-05 11:19:51 -07:00
+++ edited/arch/ia64/mm/extable.c	2005-01-06 15:54:10 -08:00
@@ -1,17 +1,15 @@
 /*
- * Kernel exception handling table support.  Derived from arch/alpha/mm/extable.c.
+ * Kernel exception handling table support. Derived from
+ * arch/alpha/mm/extable.c.
  *
  * Copyright (C) 1998, 1999, 2001-2002, 2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
-
-#include <linux/config.h>
-
+#include <linux/types.h>
 #include <asm/uaccess.h>
-#include <asm/module.h>
 
-static inline int
-compare_entries (struct exception_table_entry *l, struct exception_table_entry *r)
+static inline int compare_entries(struct exception_table_entry *l,
+				  struct exception_table_entry *r)
 {
 	u64 lip = (u64) &l->addr + l->addr;
 	u64 rip = (u64) &r->addr + r->addr;
@@ -24,8 +22,8 @@
 		return 1;
 }
 
-static inline void
-swap_entries (struct exception_table_entry *l, struct exception_table_entry *r)
+static inline void swap_entries(struct exception_table_entry *l,
+				struct exception_table_entry *r)
 {
 	u64 delta = (u64) r - (u64) l;
 	struct exception_table_entry tmp;
@@ -38,15 +36,16 @@
 }
 
 /*
- * Sort the exception table.  It's usually already sorted, but there may be unordered
- * entries due to multiple text sections (such as the .init text section).  Note that the
- * exception-table-entries contain location-relative addresses, which requires a bit of
- * care during sorting to avoid overflows in the offset members (e.g., it would not be
- * safe to make a temporary copy of an exception-table entry on the stack, because the
- * stack may be more than 2GB away from the exception-table).
+ * Sort the exception table.  It's usually already sorted, but there may be
+ * unordered entries due to multiple text sections (such as the .init text
+ * section).  Note that the exception-table-entries contain location-relative
+ * addresses, which requires a bit of care during sorting to avoid overflows in
+ * the offset members (e.g., it would not be safe to make a temporary copy of
+ * an exception-table entry on the stack, because the stack may be more than
+ * 2GB away from the exception-table).
  */
-void
-sort_extable (struct exception_table_entry *start, struct exception_table_entry *finish)
+void sort_extable(struct exception_table_entry *start,
+		  struct exception_table_entry *finish)
 {
 	struct exception_table_entry *p, *q;
 
@@ -57,10 +56,9 @@
 			swap_entries(&q[0], &q[-1]);
 }
 
-const struct exception_table_entry *
-search_extable (const struct exception_table_entry *first,
-		const struct exception_table_entry *last,
-		unsigned long ip)
+const struct exception_table_entry *search_extable(
+	const struct exception_table_entry *first,
+	const struct exception_table_entry *last, unsigned long ip)
 {
 	const struct exception_table_entry *mid;
 	unsigned long mid_ip;
@@ -80,8 +78,8 @@
         return NULL;
 }
 
-void
-ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e)
+void ia64_handle_exception(struct pt_regs *regs,
+			   const struct exception_table_entry *e)
 {
 	long fix = (u64) &e->cont + e->cont;
 
@@ -89,5 +87,5 @@
 	if (fix & 4)
 		regs->r9 = 0;
 	regs->cr_iip = fix & ~0xf;
-	ia64_psr(regs)->ri = fix & 0x3;		/* set continuation slot number */
+	ia64_psr(regs)->ri = fix & 0x3; /* set continuation slot number */
 }

--Boundary-00=_wMd3BQT77KVPGP1--

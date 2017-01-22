From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 22 Jan 2017 16:32:25 +0000
Subject: [PATCH 01/20] ia64: move ia64_done_with_exception out of asm/uaccess.h
Message-Id: <20170122163244.11740-2-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170122163244.11740-1-paul.gortmaker@windriver.com>
In-Reply-To: <20170122163244.11740-1-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org

Move ia64_done_with_exception out of asm/uaccess.h (which is widely
used) and into asm/exception.h (like ARM has) and then ensure the
few callers of it include this new header.

Most of the other C content in asm files is implemented in macro form.
So we do that conversion at the same time as the move.

There are two C exception prototypes that move along with the macro.
One of them will become redundant when we switch over to using the
<linux/extable.h> instead of <linux/module.h> header in a subsequent
commit.

Also relocate a couple of the automated asm --> linux uaccess
conversions to preserve the linux and asm independent grouping, since
we are in the file at that location anyway.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/ia64/include/asm/exception.h | 36 ++++++++++++++++++++++++++++++++++++
 arch/ia64/include/asm/uaccess.h   | 15 ---------------
 arch/ia64/kernel/kprobes.c        |  2 +-
 arch/ia64/kernel/traps.c          |  3 ++-
 arch/ia64/kernel/unaligned.c      |  3 ++-
 arch/ia64/mm/fault.c              |  1 +
 6 files changed, 42 insertions(+), 18 deletions(-)
 create mode 100644 arch/ia64/include/asm/exception.h

diff --git a/arch/ia64/include/asm/exception.h b/arch/ia64/include/asm/exception.h
new file mode 100644
index 000000000000..d90236090e8c
--- /dev/null
+++ b/arch/ia64/include/asm/exception.h
@@ -0,0 +1,36 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+#ifndef __ASM_EXCEPTION_H
+#define __ASM_EXCEPTION_H
+
+struct pt_regs;
+struct exception_table_entry;
+
+extern void ia64_handle_exception(struct pt_regs *regs,
+				  const struct exception_table_entry *e);
+extern const struct exception_table_entry *search_exception_tables(unsigned long addr);
+
+#define ia64_done_with_exception(regs)					  \
+({									  \
+	int __ex_ret = 0;						  \
+	const struct exception_table_entry *e;				  \
+	e = search_exception_tables((regs)->cr_iip + ia64_psr(regs)->ri); \
+	if (e) {							  \
+		ia64_handle_exception(regs, e);				  \
+		__ex_ret = 1;						  \
+	}								  \
+	__ex_ret;							  \
+})
+
+#endif	/* __ASM_EXCEPTION_H */
diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index bfe13196f770..471044be2a3b 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -353,21 +353,6 @@ struct exception_table_entry {
 	int fixup;	/* location-relative continuation addr.; if bit 2 is set, r9 is set to 0 */
 };
 
-extern void ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
-extern const struct exception_table_entry *search_exception_tables (unsigned long addr);
-
-static inline int
-ia64_done_with_exception (struct pt_regs *regs)
-{
-	const struct exception_table_entry *e;
-	e = search_exception_tables(regs->cr_iip + ia64_psr(regs)->ri);
-	if (e) {
-		ia64_handle_exception(regs, e);
-		return 1;
-	}
-	return 0;
-}
-
 #define ARCH_HAS_TRANSLATE_MEM_PTR	1
 static __inline__ void *
 xlate_dev_mem_ptr(phys_addr_t p)
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 45ff27e9edbb..55b18e1b67a8 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -33,7 +33,7 @@
 
 #include <asm/pgtable.h>
 #include <asm/sections.h>
-#include <linux/uaccess.h>
+#include <asm/exception.h>
 
 extern void jprobe_inst_return(void);
 
diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index 095bfaff82d0..d3e1f1ee465f 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -17,11 +17,12 @@
 #include <linux/kprobes.h>
 #include <linux/delay.h>		/* for ssleep() */
 #include <linux/kdebug.h>
+#include <linux/uaccess.h>
 
 #include <asm/fpswa.h>
 #include <asm/intrinsics.h>
 #include <asm/processor.h>
-#include <linux/uaccess.h>
+#include <asm/exception.h>
 #include <asm/setup.h>
 
 fpswa_interface_t *fpswa_interface;
diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index 9cd01c2200ee..e697403b0ec1 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -18,11 +18,12 @@
 #include <linux/sched.h>
 #include <linux/tty.h>
 #include <linux/ratelimit.h>
+#include <linux/uaccess.h>
 
 #include <asm/intrinsics.h>
 #include <asm/processor.h>
 #include <asm/rse.h>
-#include <linux/uaccess.h>
+#include <asm/exception.h>
 #include <asm/unaligned.h>
 
 extern int die_if_kernel(char *str, struct pt_regs *regs, long err);
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index fa6ad95e992e..52b41dad9704 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -15,6 +15,7 @@
 
 #include <asm/pgtable.h>
 #include <asm/processor.h>
+#include <asm/exception.h>
 
 extern int die(char *, struct pt_regs *, long);
 
-- 
2.11.0


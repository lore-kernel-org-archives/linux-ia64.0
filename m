From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 16 Aug 2016 15:14:43 +0000
Subject: [PATCH 2/2] ia64: ensure exception table search users include extable.h
Message-Id: <20160816151443.31082-3-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160816151443.31082-1-paul.gortmaker@windriver.com>
In-Reply-To: <20160816151443.31082-1-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

We start with a delete of a duplicate prototype in asm/uaccess.h
that doesn't need to exist, as it duplicates content in extable.h
and since that header is so small, there is no point trying to
avoid using it.

Then we make sure anyone using search_exception_tables directly or
via the ia64_done_with_exception macro has included extable.h

In the process, we remove an include of moduleloader.h that was
apparently not really required; it would have been fetching in
module.h and hence the previous location of the exception search
function prototypes, but we need not rely on that anymore.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/ia64/include/asm/uaccess.h | 4 ++--
 arch/ia64/kernel/kprobes.c      | 2 +-
 arch/ia64/kernel/traps.c        | 3 ++-
 arch/ia64/kernel/unaligned.c    | 1 +
 arch/ia64/mm/fault.c            | 1 +
 5 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index 4b52b79213a3..647e43d0a157 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -360,8 +360,8 @@ struct exception_table_entry {
 	int fixup;	/* location-relative continuation addr.; if bit 2 is set, r9 is set to 0 */
 };
 
-extern void ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
-extern const struct exception_table_entry *search_exception_tables (unsigned long addr);
+extern void ia64_handle_exception(struct pt_regs *regs,
+				  const struct exception_table_entry *e);
 
 #define ia64_done_with_exception(regs)					  \
 ({									  \
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index c7c51445c3be..671389430e90 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -28,7 +28,7 @@
 #include <linux/string.h>
 #include <linux/slab.h>
 #include <linux/preempt.h>
-#include <linux/moduleloader.h>
+#include <linux/extable.h>
 #include <linux/kdebug.h>
 
 #include <asm/pgtable.h>
diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index 77edd68c5161..f36d3c9e1961 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -12,7 +12,8 @@
 #include <linux/sched.h>
 #include <linux/tty.h>
 #include <linux/vt_kern.h>		/* For unblank_screen() */
-#include <linux/module.h>       /* for EXPORT_SYMBOL */
+#include <linux/export.h>
+#include <linux/extable.h>
 #include <linux/hardirq.h>
 #include <linux/kprobes.h>
 #include <linux/delay.h>		/* for ssleep() */
diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index 7f0d31656b4d..7224890ea311 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -17,6 +17,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/tty.h>
+#include <linux/extable.h>
 #include <linux/ratelimit.h>
 
 #include <asm/intrinsics.h>
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index fa6ad95e992e..702f4b0845ab 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -7,6 +7,7 @@
 #include <linux/sched.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/extable.h>
 #include <linux/interrupt.h>
 #include <linux/kprobes.h>
 #include <linux/kdebug.h>
-- 
2.8.4


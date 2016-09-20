From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 20 Sep 2016 02:29:24 +0000
Subject: [PATCH 2/2] ia64: ensure exception table search users include extable.h
Message-Id: <20160920022924.9537-3-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160920022924.9537-1-paul.gortmaker@windriver.com>
In-Reply-To: <20160920022924.9537-1-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>

We start with a delete of a duplicate prototype in asm/exception.h
that no longer needs to exist, as it duplicates content in extable.h
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
 arch/ia64/include/asm/exception.h | 1 -
 arch/ia64/kernel/kprobes.c        | 2 +-
 arch/ia64/kernel/traps.c          | 3 ++-
 arch/ia64/kernel/unaligned.c      | 1 +
 arch/ia64/mm/fault.c              | 1 +
 5 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/include/asm/exception.h b/arch/ia64/include/asm/exception.h
index d90236090e8c..6bb246dcdaeb 100644
--- a/arch/ia64/include/asm/exception.h
+++ b/arch/ia64/include/asm/exception.h
@@ -19,7 +19,6 @@ struct exception_table_entry;
 
 extern void ia64_handle_exception(struct pt_regs *regs,
 				  const struct exception_table_entry *e);
-extern const struct exception_table_entry *search_exception_tables(unsigned long addr);
 
 #define ia64_done_with_exception(regs)					  \
 ({									  \
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 55b18e1b67a8..f5f3a5e6fcd1 100644
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
index 539745351a53..0db2fcd8a766 100644
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
index 64b096d52947..10fa50fabce3 100644
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
index 52b41dad9704..7f2feb21753c 100644
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
2.10.0


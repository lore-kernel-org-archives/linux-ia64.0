From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:24 +0000
Subject: [PATCH 12/13] lib: do not use print_symbol()
Message-Id: <20171211125025.2270-13-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

print_symbol() uses extra stack space to sprintf() symbol
information and then to feed that buffer to printk()

  char buffer[KSYM_SYMBOL_LEN];

  sprint_symbol(buffer, address);
  printk(fmt, buffer);

Replace print_symbol() with a direct printk("%pS") call.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 lib/smp_processor_id.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/smp_processor_id.c b/lib/smp_processor_id.c
index 835cc6df2776..85925aaa4fff 100644
--- a/lib/smp_processor_id.c
+++ b/lib/smp_processor_id.c
@@ -5,7 +5,6 @@
  * DEBUG_PREEMPT variant of smp_processor_id().
  */
 #include <linux/export.h>
-#include <linux/kallsyms.h>
 #include <linux/sched.h>
 
 notrace static unsigned int check_preemption_disabled(const char *what1,
@@ -43,7 +42,7 @@ notrace static unsigned int check_preemption_disabled(const char *what1,
 	printk(KERN_ERR "BUG: using %s%s() in preemptible [%08x] code: %s/%d\n",
 		what1, what2, preempt_count() - 1, current->comm, current->pid);
 
-	print_symbol("caller is %s\n", (long)__builtin_return_address(0));
+	printk("caller is %pS\n", __builtin_return_address(0));
 	dump_stack();
 
 out_enable:
-- 
2.15.1


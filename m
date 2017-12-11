From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:15 +0000
Subject: [PATCH 03/13] c6x: do not use print_symbol()
Message-Id: <20171211125025.2270-4-sergey.senozhatsky@gmail.com>
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
Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <jacquiot.aurelien@gmail.com>
---
 arch/c6x/kernel/traps.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/c6x/kernel/traps.c b/arch/c6x/kernel/traps.c
index 09b8a40d5680..4c1d4b84dd2b 100644
--- a/arch/c6x/kernel/traps.c
+++ b/arch/c6x/kernel/traps.c
@@ -11,7 +11,6 @@
 #include <linux/module.h>
 #include <linux/ptrace.h>
 #include <linux/sched/debug.h>
-#include <linux/kallsyms.h>
 #include <linux/bug.h>
 
 #include <asm/soc.h>
@@ -375,8 +374,7 @@ static void show_trace(unsigned long *stack, unsigned long *endstack)
 			if (i % 5 = 0)
 				pr_debug("\n	    ");
 #endif
-			pr_debug(" [<%08lx>]", addr);
-			print_symbol(" %s\n", addr);
+			pr_debug(" [<%08lx>] %pS\n", addr, (void *)addr);
 			i++;
 		}
 	}
-- 
2.15.1


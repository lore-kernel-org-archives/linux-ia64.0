From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:17 +0000
Subject: [PATCH 05/13] mn10300: do not use print_symbol()
Message-Id: <20171211125025.2270-6-sergey.senozhatsky@gmail.com>
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
Cc: David Howells <dhowells@redhat.com>
---
 arch/mn10300/kernel/traps.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/mn10300/kernel/traps.c b/arch/mn10300/kernel/traps.c
index 800fd0801969..72d1015b2ae7 100644
--- a/arch/mn10300/kernel/traps.c
+++ b/arch/mn10300/kernel/traps.c
@@ -22,7 +22,6 @@
 #include <linux/delay.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
-#include <linux/kallsyms.h>
 #include <linux/pci.h>
 #include <linux/kdebug.h>
 #include <linux/bug.h>
@@ -262,8 +261,7 @@ void show_trace(unsigned long *sp)
 				raslot = ULONG_MAX;
 			else
 				printk(" ?");
-			print_symbol(" %s", addr);
-			printk("\n");
+			printk(" %pS\n", (void *)addr);
 		}
 	}
 
-- 
2.15.1


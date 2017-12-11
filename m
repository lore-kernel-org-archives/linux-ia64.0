From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:14 +0000
Subject: [PATCH 02/13] arm64: do not use print_symbol()
Message-Id: <20171211125025.2270-3-sergey.senozhatsky@gmail.com>
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
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/kernel/process.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 6b7dcf4310ac..44bed43814e2 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -35,7 +35,6 @@
 #include <linux/delay.h>
 #include <linux/reboot.h>
 #include <linux/interrupt.h>
-#include <linux/kallsyms.h>
 #include <linux/init.h>
 #include <linux/cpu.h>
 #include <linux/elfcore.h>
@@ -221,8 +220,8 @@ void __show_regs(struct pt_regs *regs)
 
 	show_regs_print_info(KERN_DEFAULT);
 	print_pstate(regs);
-	print_symbol("pc : %s\n", regs->pc);
-	print_symbol("lr : %s\n", lr);
+	printk("pc : %pS\n", (void *)regs->pc);
+	printk("lr : %pS\n", (void *)lr);
 	printk("sp : %016llx\n", sp);
 
 	i = top_reg;
-- 
2.15.1


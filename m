From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:13 +0000
Subject: [PATCH 01/13] arm: do not use print_symbol()
Message-Id: <20171211125025.2270-2-sergey.senozhatsky@gmail.com>
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
Cc: Russell King <linux@armlinux.org.uk>
---
 arch/arm/kernel/process.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index d96714e1858c..db004f6f547a 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -21,7 +21,6 @@
 #include <linux/unistd.h>
 #include <linux/user.h>
 #include <linux/interrupt.h>
-#include <linux/kallsyms.h>
 #include <linux/init.h>
 #include <linux/elfcore.h>
 #include <linux/pm.h>
@@ -121,8 +120,8 @@ void __show_regs(struct pt_regs *regs)
 
 	show_regs_print_info(KERN_DEFAULT);
 
-	print_symbol("PC is at %s\n", instruction_pointer(regs));
-	print_symbol("LR is at %s\n", regs->ARM_lr);
+	printk("PC is at %pS\n", instruction_pointer(regs));
+	printk("LR is at %pS\n", (void *)regs->ARM_lr);
 	printk("pc : [<%08lx>]    lr : [<%08lx>]    psr: %08lx\n",
 	       regs->ARM_pc, regs->ARM_lr, regs->ARM_cpsr);
 	printk("sp : %08lx  ip : %08lx  fp : %08lx\n",
-- 
2.15.1


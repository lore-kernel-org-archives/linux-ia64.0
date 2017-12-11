From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:19 +0000
Subject: [PATCH 07/13] unicore32: do not use print_symbol()
Message-Id: <20171211125025.2270-8-sergey.senozhatsky@gmail.com>
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
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
---
 arch/unicore32/kernel/process.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
index ddaf78ae6854..9a9d49bccc02 100644
--- a/arch/unicore32/kernel/process.c
+++ b/arch/unicore32/kernel/process.c
@@ -23,7 +23,6 @@
 #include <linux/delay.h>
 #include <linux/reboot.h>
 #include <linux/interrupt.h>
-#include <linux/kallsyms.h>
 #include <linux/init.h>
 #include <linux/cpu.h>
 #include <linux/elfcore.h>
@@ -139,8 +138,8 @@ void __show_regs(struct pt_regs *regs)
 	char buf[64];
 
 	show_regs_print_info(KERN_DEFAULT);
-	print_symbol("PC is at %s\n", instruction_pointer(regs));
-	print_symbol("LR is at %s\n", regs->UCreg_lr);
+	printk("PC is at %pS\n", instruction_pointer(regs));
+	printk("LR is at %pS\n", (void *)regs->UCreg_lr);
 	printk(KERN_DEFAULT "pc : [<%08lx>]    lr : [<%08lx>]    psr: %08lx\n"
 	       "sp : %08lx  ip : %08lx  fp : %08lx\n",
 		regs->UCreg_pc, regs->UCreg_lr, regs->UCreg_asr,
-- 
2.15.1


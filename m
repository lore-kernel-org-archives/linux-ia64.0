From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:16 +0000
Subject: [PATCH 04/13] ia64: do not use print_symbol()
Message-Id: <20171211125025.2270-5-sergey.senozhatsky@gmail.com>
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

Additionally ia64_do_show_stack() had extra buffer [128
bytes on stack], which we also can drop now.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/kernel/process.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index dda0082056b3..968b5f33e725 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -13,7 +13,6 @@
 #include <linux/pm.h>
 #include <linux/elf.h>
 #include <linux/errno.h>
-#include <linux/kallsyms.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
@@ -69,7 +68,6 @@ void
 ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 {
 	unsigned long ip, sp, bsp;
-	char buf[128];			/* don't make it so big that it overflows the stack! */
 
 	printk("\nCall Trace:\n");
 	do {
@@ -79,11 +77,9 @@ ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 
 		unw_get_sp(info, &sp);
 		unw_get_bsp(info, &bsp);
-		snprintf(buf, sizeof(buf),
-			 " [<%016lx>] %%s\n"
+		printk(" [<%016lx>] %pS\n"
 			 "                                sp=%016lx bsp=%016lx\n",
-			 ip, sp, bsp);
-		print_symbol(buf, ip);
+			 ip, (void *)ip, sp, bsp);
 	} while (unw_unwind(info) >= 0);
 }
 
@@ -111,7 +107,7 @@ show_regs (struct pt_regs *regs)
 	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]    %s (%s)\n",
 	       regs->cr_ipsr, regs->cr_ifs, ip, print_tainted(),
 	       init_utsname()->release);
-	print_symbol("ip is at %s\n", ip);
+	printk("ip is at %pS\n", (void *)ip);
 	printk("unat: %016lx pfs : %016lx rsc : %016lx\n",
 	       regs->ar_unat, regs->ar_pfs, regs->ar_rsc);
 	printk("rnat: %016lx bsps: %016lx pr  : %016lx\n",
-- 
2.15.1


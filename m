From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:20 +0000
Subject: [PATCH 08/13] x86: do not use print_symbol()
Message-Id: <20171211125025.2270-9-sergey.senozhatsky@gmail.com>
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
Cc: Tony Luck <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/kernel/cpu/mcheck/mce.c | 3 +--
 arch/x86/mm/mmio-mod.c           | 5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index b1d616d08eee..8ca8f6eb32db 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -14,7 +14,6 @@
 #include <linux/capability.h>
 #include <linux/miscdevice.h>
 #include <linux/ratelimit.h>
-#include <linux/kallsyms.h>
 #include <linux/rcupdate.h>
 #include <linux/kobject.h>
 #include <linux/uaccess.h>
@@ -235,7 +234,7 @@ static void __print_mce(struct mce *m)
 			m->cs, m->ip);
 
 		if (m->cs = __KERNEL_CS)
-			print_symbol("{%s}", m->ip);
+			pr_cont("{%pS}", (void *)m->ip);
 		pr_cont("\n");
 	}
 
diff --git a/arch/x86/mm/mmio-mod.c b/arch/x86/mm/mmio-mod.c
index 4d434ddb75db..2c1ecf4763c4 100644
--- a/arch/x86/mm/mmio-mod.c
+++ b/arch/x86/mm/mmio-mod.c
@@ -29,7 +29,6 @@
 #include <linux/slab.h>
 #include <linux/uaccess.h>
 #include <linux/io.h>
-#include <linux/kallsyms.h>
 #include <asm/pgtable.h>
 #include <linux/mmiotrace.h>
 #include <asm/e820/api.h> /* for ISA_START_ADDRESS */
@@ -123,8 +122,8 @@ static void die_kmmio_nesting_error(struct pt_regs *regs, unsigned long addr)
 	pr_emerg("unexpected fault for address: 0x%08lx, last fault for address: 0x%08lx\n",
 		 addr, my_reason->addr);
 	print_pte(addr);
-	print_symbol(KERN_EMERG "faulting IP is at %s\n", regs->ip);
-	print_symbol(KERN_EMERG "last faulting IP was at %s\n", my_reason->ip);
+	pr_emerg("faulting IP is at %pS\n", (void *)regs->ip);
+	pr_emerg("last faulting IP was at %pS\n", (void *)my_reason->ip);
 #ifdef __i386__
 	pr_emerg("eax: %08lx   ebx: %08lx   ecx: %08lx   edx: %08lx\n",
 		 regs->ax, regs->bx, regs->cx, regs->dx);
-- 
2.15.1


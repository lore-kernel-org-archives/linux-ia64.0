From: Joshua Aas <josha@sgi.com>
Date: Wed, 14 Jul 2004 21:50:32 +0000
Subject: print CPU number when warning of hazards
Message-Id: <40F5AAA8.5020500@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

The following patch would be useful for diagnostics. Please apply.

Signed-off-by: Josh Aas <josha@sgi.com>

-----------------------------------
--- a/arch/ia64/kernel/traps.c       2004-06-16 00:20:04.000000000 -0500
+++ b/arch/ia64/kernel/traps.c  2004-07-14 15:39:58.000000000 -0500
@@ -427,9 +427,9 @@ ia64_fault (unsigned long vector, unsign
                                       ? " (RSE access)" : " (data access)") : "");
                if (code = 8) {
 # ifdef CONFIG_IA64_PRINT_HAZARDS
-                       printk("%s[%d]: possible hazard @ ip=%016lx (pr = %016lx)\n",
+                       printk("%s[%d]: possible hazard @ ip=%016lx (pr = %016lx) on CPU %d\n",
                               current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri,
-                              regs->pr);
+                              regs->pr, smp_processor_id());
 # endif
                        return;
                }
-----------------------------------

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068

From: ddaney.cavm@gmail.com
Date: Mon, 17 Jun 2013 15:46:07 +0000
Subject: [PATCH v2] mn10300: Fix include dependency in irqflags.h et al.
Message-Id: <1371483967-22527-1-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1371413189-2568-3-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1371413189-2568-3-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com
Cc: david.s.daney@gmail.com, David Daney <david.daney@cavium.com>

From: David Daney <david.daney@cavium.com>

We need to pick up the definition of raw_smp_processor_id() from
asm/smp.h.  For the !SMP case, we need to supply a definition of
raw_smp_processor_id().

Because of the include dependencies we cannot use smp_call_func_t in
asm/smp.h, but we do need linux/thread_info.h

Signed-off-by: David Daney <david.daney@cavium.com>
---

Changes from v1: Remove redundant #ifndef __ASSEMBLY__, fix SMP case.


 arch/mn10300/include/asm/irqflags.h | 5 ++---
 arch/mn10300/include/asm/smp.h      | 4 +++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/mn10300/include/asm/irqflags.h b/arch/mn10300/include/asm/irqflags.h
index 678f68d..8730c0a 100644
--- a/arch/mn10300/include/asm/irqflags.h
+++ b/arch/mn10300/include/asm/irqflags.h
@@ -13,9 +13,8 @@
 #define _ASM_IRQFLAGS_H
 
 #include <asm/cpu-regs.h>
-#ifndef __ASSEMBLY__
-#include <linux/smp.h>
-#endif
+/* linux/smp.h <- linux/irqflags.h needs asm/smp.h first */
+#include <asm/smp.h>
 
 /*
  * interrupt control
diff --git a/arch/mn10300/include/asm/smp.h b/arch/mn10300/include/asm/smp.h
index 6745dbe..56c4241 100644
--- a/arch/mn10300/include/asm/smp.h
+++ b/arch/mn10300/include/asm/smp.h
@@ -24,6 +24,7 @@
 #ifndef __ASSEMBLY__
 #include <linux/threads.h>
 #include <linux/cpumask.h>
+#include <linux/thread_info.h>
 #endif
 
 #ifdef CONFIG_SMP
@@ -85,7 +86,7 @@ extern cpumask_t cpu_boot_map;
 extern void smp_init_cpus(void);
 extern void smp_cache_interrupt(void);
 extern void send_IPI_allbutself(int irq);
-extern int smp_nmi_call_function(smp_call_func_t func, void *info, int wait);
+extern int smp_nmi_call_function(void (*func)(void *), void *info, int wait);
 
 extern void arch_send_call_function_single_ipi(int cpu);
 extern void arch_send_call_function_ipi_mask(const struct cpumask *mask);
@@ -100,6 +101,7 @@ extern void __cpu_die(unsigned int cpu);
 #ifndef __ASSEMBLY__
 
 static inline void smp_init_cpus(void) {}
+#define raw_smp_processor_id() 0
 
 #endif /* __ASSEMBLY__ */
 #endif /* CONFIG_SMP */
-- 
1.7.11.7


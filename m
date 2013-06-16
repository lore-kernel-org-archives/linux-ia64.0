From: ddaney.cavm@gmail.com
Date: Sun, 16 Jun 2013 20:06:29 +0000
Subject: [PATCH 2/2] mn10300: Fix include dependency in irqflags.h
Message-Id: <1371413189-2568-3-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com
Cc: david.s.daney@gmail.com, David Daney <david.daney@cavium.com>

From: David Daney <david.daney@cavium.com>

We need to pick up the definition of raw_smp_processor_id() from
asm/smp.h.  For the !SMP case, we need to supply a definition of
raw_smp_processor_id().

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mn10300/include/asm/irqflags.h | 3 ++-
 arch/mn10300/include/asm/smp.h      | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/mn10300/include/asm/irqflags.h b/arch/mn10300/include/asm/irqflags.h
index 678f68d..06e0a17 100644
--- a/arch/mn10300/include/asm/irqflags.h
+++ b/arch/mn10300/include/asm/irqflags.h
@@ -14,7 +14,8 @@
 
 #include <asm/cpu-regs.h>
 #ifndef __ASSEMBLY__
-#include <linux/smp.h>
+/* linux/smp.h <- linux/irqflags.h needs asm/smp.h first */
+#include <asm/smp.h>
 #endif
 
 /*
diff --git a/arch/mn10300/include/asm/smp.h b/arch/mn10300/include/asm/smp.h
index 6745dbe..498e5ab 100644
--- a/arch/mn10300/include/asm/smp.h
+++ b/arch/mn10300/include/asm/smp.h
@@ -100,6 +100,7 @@ extern void __cpu_die(unsigned int cpu);
 #ifndef __ASSEMBLY__
 
 static inline void smp_init_cpus(void) {}
+#define raw_smp_processor_id() 0
 
 #endif /* __ASSEMBLY__ */
 #endif /* CONFIG_SMP */
-- 
1.7.11.7


From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 09 Apr 2008 04:48:56 +0000
Subject: [PATCH 03/15] ia64/pv_ops: preparation: introduce ia64_get_psr_i() to make kernel paravirtualization
Message-Id: <12077165483611-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

__local_irq_save() and local_save_flags() are used to mask interruptions.
They read all psr bits that requres whole bit emulation.
On the other hand, reading only psr.i, the single bit, can be virtualized
cheaply.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/intrinsics.h |    2 ++
 include/asm-ia64/system.h     |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/asm-ia64/intrinsics.h b/include/asm-ia64/intrinsics.h
index 72f0383..aae6013 100644
--- a/include/asm-ia64/intrinsics.h
+++ b/include/asm-ia64/intrinsics.h
@@ -18,6 +18,8 @@
 # include <asm/gcc_intrin.h>
 #endif
 
+#define ia64_get_psr_i()	(ia64_getreg(_IA64_REG_PSR) & IA64_PSR_I)
+
 #define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
 do {								\
 	ia64_set_rr(0x0000000000000000UL, (val0));		\
diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
index 595112b..2bca73e 100644
--- a/include/asm-ia64/system.h
+++ b/include/asm-ia64/system.h
@@ -125,7 +125,7 @@ extern struct ia64_boot_param {
 #define __local_irq_save(x)			\
 do {						\
 	ia64_stop();				\
-	(x) = ia64_getreg(_IA64_REG_PSR);	\
+	(x) = ia64_get_psr_i();			\
 	ia64_stop();				\
 	ia64_rsm(IA64_PSR_I);			\
 } while (0)
@@ -173,7 +173,7 @@ do {								\
 #endif /* !CONFIG_IA64_DEBUG_IRQ */
 
 #define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I); ia64_srlz_d(); })
-#define local_save_flags(flags)	({ ia64_stop(); (flags) = ia64_getreg(_IA64_REG_PSR); })
+#define local_save_flags(flags)	({ ia64_stop(); (flags) = ia64_get_psr_i(); })
 
 #define irqs_disabled()				\
 ({						\
-- 
1.5.3


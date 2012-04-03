From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 03 Apr 2012 16:18:03 +0000
Subject: [PATCH] ia64: fix halt build fallout from deeper C state support.
Message-Id: <1333469883-20509-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Commit 1a022e3f1be11730bd8747b1af96a0274bf6356e

   "idle, x86: Allow off-lined CPU to enter deeper C states"

causes ia64 defconfig to fail with:

drivers/acpi/processor_idle.c:789:4: error: implicit declaration of function 'halt' [-Werror=implicit-function-declaration]

For i386 we have:

  halt
	--> native_halt
		--> asm hlt

  arch_safe_halt
	--> native_safe_halt
		--> asm sti; hlt

On ia64, we just have:

  arch_safe_halt
	--> ia64_pal_halt_light

but there is no equivalent to just plain "halt"

The comments for ia64_pal_halt_light in arch/ia64/include/asm/pal.h indicate:

   Cause the processor to enter LIGHT HALT state, where prefetching
   and execution are suspended, but cache and TLB coherency is
   maintained.

Based on that, it seems reasonable to make halt point to that.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Boris Ostrovsky <boris.ostrovsky@amd.com>
Cc: Len Brown <len.brown@intel.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[Tony - I dont know enough about ia64 to be sure this makes sense,
 so feel free to junk this patch and treat the mail as just a build
 failure regression report if there is a better fix.]

diff --git a/arch/ia64/include/asm/irqflags.h b/arch/ia64/include/asm/irqflags.h
index 2b68d85..30590c9 100644
--- a/arch/ia64/include/asm/irqflags.h
+++ b/arch/ia64/include/asm/irqflags.h
@@ -92,5 +92,9 @@ static inline void arch_safe_halt(void)
 	ia64_pal_halt_light();	/* PAL_HALT_LIGHT */
 }
 
+static inline void halt(void)
+{
+	arch_safe_halt();
+}
 
 #endif /* _ASM_IA64_IRQFLAGS_H */
-- 
1.7.9.1


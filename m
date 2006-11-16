From: akpm@osdl.org
Date: Thu, 16 Nov 2006 08:43:07 +0000
Subject: [patch 3/4] ia64: use generic_handle_irq()
Message-Id: <200611160843.kAG8h7pb017746@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>

Use generic_handle_irq() to handle mixed-type irq handling.

[akm@osdl.org: add missing conversion]
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 arch/ia64/kernel/irq.c      |    2 +-
 arch/ia64/kernel/irq_ia64.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN arch/ia64/kernel/irq.c~ia64-use-generic_handle_irq arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c~ia64-use-generic_handle_irq
+++ a/arch/ia64/kernel/irq.c
@@ -197,7 +197,7 @@ void fixup_irqs(void)
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 
 			vectors_in_migration[irq]=0;
-			__do_IRQ(irq);
+			generic_handle_irq(irq);
 			set_irq_regs(old_regs);
 		}
 	}
diff -puN arch/ia64/kernel/irq_ia64.c~ia64-use-generic_handle_irq arch/ia64/kernel/irq_ia64.c
--- a/arch/ia64/kernel/irq_ia64.c~ia64-use-generic_handle_irq
+++ a/arch/ia64/kernel/irq_ia64.c
@@ -186,7 +186,7 @@ ia64_handle_irq (ia64_vector vector, str
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
-			__do_IRQ(local_vector_to_irq(vector));
+			generic_handle_irq(local_vector_to_irq(vector));
 
 			/*
 			 * Disable interrupts and send EOI:
@@ -242,7 +242,7 @@ void ia64_process_pending_intr(void)
 			 * Probably could shared code.
 			 */
 			vectors_in_migration[local_vector_to_irq(vector)]=0;
-			__do_IRQ(local_vector_to_irq(vector));
+			generic_handle_irq(local_vector_to_irq(vector));
 			set_irq_regs(old_regs);
 
 			/*
_

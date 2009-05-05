From: "Jan Beulich" <jbeulich@novell.com>
Date: Tue, 05 May 2009 12:57:52 +0000
Subject: [PATCH] ia64/xen: fix build issues
Message-Id: <4A0053F0.76EA.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

- drivers/xen/events.c did not compile
- xen_setup_hook caused a modpost section warning
- the use of u64 (instead of unsigned long long) together with a %llu
  in drivers/xen/balloon.c caused a compiler warning

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 arch/ia64/include/asm/idle.h       |    7 +++++++
 arch/ia64/include/asm/xen/events.h |    7 +------
 arch/ia64/xen/xensetup.S           |    2 --
 drivers/xen/balloon.c              |    3 ++-
 4 files changed, 10 insertions(+), 9 deletions(-)

--- linux-2.6.30-rc4/arch/ia64/include/asm/idle.h	1970-01-01 01:00:00.000000000 +0100
+++ 2.6.30-rc4-ia64-xen-build/arch/ia64/include/asm/idle.h	2009-05-05 14:00:51.000000000 +0200
@@ -0,0 +1,7 @@
+#ifndef _ASM_IA64_IDLE_H
+#define _ASM_IA64_IDLE_H
+
+static inline void enter_idle(void) { }
+static inline void exit_idle(void) { }
+
+#endif /* _ASM_IA64_IDLE_H */
--- linux-2.6.30-rc4/arch/ia64/include/asm/xen/events.h	2008-12-25 00:26:37.000000000 +0100
+++ 2.6.30-rc4-ia64-xen-build/arch/ia64/include/asm/xen/events.h	2009-05-05 14:02:35.000000000 +0200
@@ -36,14 +36,9 @@ static inline int xen_irqs_disabled(stru
 	return !(ia64_psr(regs)->i);
 }
 
-static inline void xen_do_IRQ(int irq, struct pt_regs *regs)
+static inline void handle_irq(int irq, struct pt_regs *regs)
 {
-	struct pt_regs *old_regs;
-	old_regs = set_irq_regs(regs);
-	irq_enter();
 	__do_IRQ(irq);
-	irq_exit();
-	set_irq_regs(old_regs);
 }
 #define irq_ctx_init(cpu)	do { } while (0)
 
--- linux-2.6.30-rc4/arch/ia64/xen/xensetup.S	2008-12-25 00:26:37.000000000 +0100
+++ 2.6.30-rc4-ia64-xen-build/arch/ia64/xen/xensetup.S	2009-05-05 14:08:18.000000000 +0200
@@ -54,8 +54,6 @@ END(startup_xen)
 
 #define isBP	p3	// are we the Bootstrap Processor?
 
-	.text
-
 GLOBAL_ENTRY(xen_setup_hook)
 	mov r8=XEN_PV_DOMAIN_ASM
 (isBP)	movl r9=xen_domain_type;;
--- linux-2.6.30-rc4/drivers/xen/balloon.c	2009-03-24 00:12:14.000000000 +0100
+++ 2.6.30-rc4-ia64-xen-build/drivers/xen/balloon.c	2009-05-05 14:14:37.000000000 +0200
@@ -513,7 +513,8 @@ static ssize_t show_target(struct sys_de
 			      char *buf)
 {
 	return sprintf(buf, "%llu\n",
-		       (u64)balloon_stats.target_pages << PAGE_SHIFT);
+		       (unsigned long long)balloon_stats.target_pages
+		       << PAGE_SHIFT);
 }
 
 static ssize_t store_target(struct sys_device *dev,




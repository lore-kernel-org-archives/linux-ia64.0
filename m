From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 18:23:37 +0000
Subject: [patch] move machvec_noop from inline to c file
Message-Id: <200603121823.k2CINZg10902@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There are 9 copy of these thing when compile with CONFIG_IA64_GENERIC
because it is declared as inline function but called through function
pointer.  gcc makes 9 copy of these empty function around.  Move it
into machvec.c file.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/machvec.c.orig	2006-01-02 19:21:10.000000000 -0800
+++ ./arch/ia64/kernel/machvec.c	2006-03-12 10:54:23.311711322 -0800
@@ -41,6 +41,13 @@ machvec_init (const char *name)
 	printk(KERN_INFO "booting generic kernel on platform %s\n", name);
 }
 
+void machvec_noop (void)
+{
+}
+
+void machvec_noop_mm (struct mm_struct *mm)
+{
+}
 #endif /* CONFIG_IA64_GENERIC */
 
 void
--- ./include/asm-ia64/machvec.h.orig	2006-01-02 19:21:10.000000000 -0800
+++ ./include/asm-ia64/machvec.h	2006-03-12 11:07:24.618342376 -0800
@@ -75,6 +75,10 @@ typedef unsigned short ia64_mv_readw_rel
 typedef unsigned int ia64_mv_readl_relaxed_t (const volatile void __iomem *);
 typedef unsigned long ia64_mv_readq_relaxed_t (const volatile void __iomem *);
 
+#if defined (CONFIG_IA64_GENERIC)
+extern void machvec_noop (void);
+extern void machvec_noop_mm (struct mm_struct *mm);
+#else
 static inline void
 machvec_noop (void)
 {
@@ -84,6 +88,7 @@ static inline void
 machvec_noop_mm (struct mm_struct *mm)
 {
 }
+#endif
 
 extern void machvec_setup (char **);
 extern void machvec_timer_interrupt (int, void *, struct pt_regs *);


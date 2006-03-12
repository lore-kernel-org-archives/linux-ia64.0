From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 19:10:00 +0000
Subject: [patch] cleanup dig_irq_init
Message-Id: <200603121909.k2CJ9xg11359@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

dig_irq_init is equivalent to machvec_noop, no need to define
another empty function.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

---

Hack, I start to sense that I must be extremely bored and have
too much free time ....

Next target: machvec_setup() and machvec_timer_interrupt().
Q: How many empty function does one need to implement for linux kernel?
A: apparently many :-(



--- ./arch/ia64/dig/setup.c.orig	2006-03-12 11:52:28.953270185 -0800
+++ ./arch/ia64/dig/setup.c	2006-03-12 11:53:04.583152561 -0800
@@ -69,8 +69,3 @@ dig_setup (char **cmdline_p)
 	screen_info.orig_video_isVGA = 1;	/* XXX fake */
 	screen_info.orig_video_ega_bx = 3;	/* XXX fake */
 }
-
-void __init
-dig_irq_init (void)
-{
-}
--- ./include/asm-ia64/machvec_dig.h.orig	2006-03-12 11:51:07.238427436 -0800
+++ ./include/asm-ia64/machvec_dig.h	2006-03-12 11:58:19.316547143 -0800
@@ -2,7 +2,6 @@
 #define _ASM_IA64_MACHVEC_DIG_h
 
 extern ia64_mv_setup_t dig_setup;
-extern ia64_mv_irq_init_t dig_irq_init;
 
 /*
  * This stuff has dual use!
@@ -13,6 +12,5 @@ extern ia64_mv_irq_init_t dig_irq_init;
  */
 #define platform_name		"dig"
 #define platform_setup		dig_setup
-#define platform_irq_init	dig_irq_init
 
 #endif /* _ASM_IA64_MACHVEC_DIG_h */


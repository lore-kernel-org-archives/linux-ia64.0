From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 19:25:26 +0000
Subject: [patch] add init declaration to machvec.c
Message-Id: <200603121925.k2CJPPg11482@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add init declaration to machvec initialization functions.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

---

Now I'm totally convinced that Ken is extremely bored at the moment ;-)


--- ./arch/ia64/kernel/machvec.c.orig	2006-03-12 12:17:01.700322457 -0800
+++ ./arch/ia64/kernel/machvec.c	2006-03-12 12:17:23.556767502 -0800
@@ -14,7 +14,7 @@
 struct ia64_machine_vector ia64_mv;
 EXPORT_SYMBOL(ia64_mv);
 
-static struct ia64_machine_vector *
+static struct ia64_machine_vector * __init
 lookup_machvec (const char *name)
 {
 	extern struct ia64_machine_vector machvec_start[];
@@ -28,7 +28,7 @@ lookup_machvec (const char *name)
 	return 0;
 }
 
-void
+void __init
 machvec_init (const char *name)
 {
 	struct ia64_machine_vector *mv;



From: Russ Anderson <rja@sgi.com>
Date: Fri, 22 Apr 2005 23:08:28 +0000
Subject: [patch] MCA recovery module undefined symbol fix
Message-Id: <200504222308.j3MN8Sdw509401@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The patch "MCA recovery improvements" (http://marc.theaimsgroup.com/?l=linux-ia64&m1274241707975&w=2)
added do_exit to mca_drv.c.  That's fine when the mca recovery code
is built in the kernel (CONFIG_IA64_MCA_RECOVERY=y) but breaks 
building the mca recovery code as a module (CONFIG_IA64_MCA_RECOVERY=m).

This patch exports do_exit, so mca_drv.c can build as a module.

Signed-off-by: Russ Anderson (rja@sgi.com)

-------------------------------------------------------------------
Index: linux/kernel/exit.c
=================================--- linux.orig/kernel/exit.c	2005-04-01 09:34:10.848943143 -0600
+++ linux/kernel/exit.c	2005-04-22 17:30:32.517590141 -0500
@@ -845,6 +845,8 @@
 	for (;;) ;
 }
 
+EXPORT_SYMBOL(do_exit);
+
 NORET_TYPE void complete_and_exit(struct completion *comp, long code)
 {
 	if (comp)

From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 30 Sep 2003 00:28:40 +0000
Subject: [PATCH] early sn setup fix
Message-Id: <marc-linux-ia64-106488185618597@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Small fix to build early_sn_setup even if early printk is turned off.

Jesse

diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/sn/kernel/setup.c	Mon Sep 29 17:06:17 2003
@@ -147,7 +147,6 @@
  * Sets up an initial console to aid debugging.  Intended primarily
  * for bringup.  See start_kernel() in init/main.c.
  */
-#if defined(CONFIG_IA64_EARLY_PRINTK_SGI_SN) || defined(CONFIG_IA64_SGI_SN_SIM)
 
 void __init
 early_sn_setup(void)
@@ -189,7 +188,6 @@
 		printk(KERN_DEBUG "early_sn_setup: setting master_node_bedrock_address to 0x%lx\n", master_node_bedrock_address);
 	}
 }
-#endif /* CONFIG_IA64_EARLY_PRINTK_SGI_SN */
 
 #ifdef CONFIG_IA64_MCA
 extern int platform_intr_list[];

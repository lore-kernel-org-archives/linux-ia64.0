From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 17 Sep 2003 22:13:56 +0000
Subject: [PATCH] fix early printk for sn2
Message-Id: <marc-linux-ia64-106383685618920@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Quick fix for the early printk function name for sn2.  Goes along with a
patch I'm about to send to Andrew.

Thanks,
Jesse


diff -Nru a/kernel/printk.c b/kernel/printk.c
--- a/kernel/printk.c	Wed Sep 17 15:10:58 2003
+++ b/kernel/printk.c	Wed Sep 17 15:10:58 2003
@@ -790,7 +790,7 @@
 # endif /* CONFIG_IA64_EARLY_PRINTK_UART */
 
 #ifdef CONFIG_IA64_EARLY_PRINTK_SGI_SN
-extern int sn_sal_console_out(const char *str, int len);
+extern int early_printk_sn_sal(const char *str, int len);
 #endif
 
 void early_printk(const char *str, size_t len)
@@ -802,7 +802,7 @@
 	early_printk_vga(str, len);
 #endif
 #ifdef CONFIG_IA64_EARLY_PRINTK_SGI_SN
- 	sn_sal_console_out(str, len);
+ 	early_printk_sn_sal(str, len);
 #endif
 }
 

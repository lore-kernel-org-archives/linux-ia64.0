From: Keith Owens <kaos@sgi.com>
Date: Mon, 23 Feb 2004 03:46:34 +0000
Subject: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <4545.1077507994@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The unwind code in 2.6.3 is missing a debug patch.  This patch is in
2.4.25 and makes it much easier to diagnose unwind problems.  printk
output does not appear when in_interrupt(), kdb_printf output does.
This brings 2.6.3 unwind closer to 2.4.25.


Index: 3.1/arch/ia64/kernel/unwind.c
--- 3.1/arch/ia64/kernel/unwind.c Sun, 08 Feb 2004 22:59:56 +1100 kaos (linux-2.6/Z/c/10_unwind.c 1.1.1.2 644)
+++ 3.1(w)/arch/ia64/kernel/unwind.c Mon, 23 Feb 2004 14:44:05 +1100 kaos (linux-2.6/Z/c/10_unwind.c 1.1.1.2 644)
@@ -60,9 +60,16 @@
 
 #ifdef UNW_DEBUG
   static unsigned int unw_debug_level = UNW_DEBUG;
-#  define UNW_DEBUG_ON(n)	unw_debug_level >= n
-   /* Do not code a printk level, not all debug lines end in newline */
-#  define UNW_DPRINT(n, ...)  if (UNW_DEBUG_ON(n)) printk(__VA_ARGS__)
+#  ifdef CONFIG_KDB
+#    include <linux/kdb.h>
+#    define UNW_DEBUG_ON(n)	(unw_debug_level >= n && !KDB_IS_RUNNING())
+#    define UNW_DPRINT(n, ...)	if (UNW_DEBUG_ON(n)) kdb_printf(__VA_ARGS__)
+#  else	/* !CONFIG_KDB */
+#    define UNW_DEBUG_ON(n)	unw_debug_level >= n
+     /* Do not code a printk level, not all debug lines end in newline */
+#    define UNW_DPRINT(n, ...)  if (UNW_DEBUG_ON(n)) printk(__VA_ARGS__)
+#  endif /* CONFIG_KDB */
+#  undef inline
 #  define inline
 #else /* !UNW_DEBUG */
 #  define UNW_DEBUG_ON(n)  0


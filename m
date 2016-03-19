From: Helge Deller <deller@gmx.de>
Date: Sat, 19 Mar 2016 16:54:10 +0000
Subject: [PATCH] parisc,metag: Implement CONFIG_DEBUG_STACK_USAGE option
Message-Id: <20160319165410.GA31630@p100.box>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-parisc@vger.kernel.org, James Bottomley <James.Bottomley@HansenPartnership.com>, John David Anglin <dave.anglin@bell.net>, James Hogan <james.hogan@imgtec.com>, linux-metag@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On parisc and metag the stack grows upwards, so for those we need to
scan the stack downwards in order to calculate how much stack a process
has used.

Tested on a 64bit parisc kernel.

Signed-off-by: Helge Deller <deller@gmx.de>

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 084ed9f..71591f3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2859,10 +2859,18 @@ static inline unsigned long stack_not_used(struct task_struct *p)
 	unsigned long *n = end_of_stack(p);
 
 	do { 	/* Skip over canary */
+# ifdef CONFIG_STACK_GROWSUP
+		n--;
+# else
 		n++;
+# endif
 	} while (!*n);
 
+# ifdef CONFIG_STACK_GROWSUP
+	return (unsigned long)end_of_stack(p) - (unsigned long)n;
+# else
 	return (unsigned long)n - (unsigned long)end_of_stack(p);
+# endif
 }
 #endif
 extern void set_task_stack_end_magic(struct task_struct *tsk);
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index f28f7fa..901f96c 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -546,7 +546,7 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
 
 config DEBUG_STACK_USAGE
 	bool "Stack utilization instrumentation"
-	depends on DEBUG_KERNEL && !IA64 && !PARISC && !METAG
+	depends on DEBUG_KERNEL && !IA64
 	help
 	  Enables the display of the minimum amount of free stack which each
 	  task has ever had available in the sysrq-T and sysrq-P debug output.

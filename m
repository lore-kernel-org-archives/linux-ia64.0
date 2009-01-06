From: Doug Chapman <doug.chapman@hp.com>
Date: Tue, 06 Jan 2009 17:36:03 +0000
Subject: [PATCH] ia64: dump stack on kernel unaligned warnings
Message-Id: <1231263363.21571.13.camel@oberon>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[IA64] dump stack on kernel unaligned warnings

Often the cause of kernel unaligned access warnings is not 
obvious from just the ip displayed in the warning.  This adds
the option via proc to dump the stack in addition to the warning.
The default is off (just display the 1 line warning).  To enable
the stack to be shown: echo 1 > /proc/sys/kernel/unaligned-dump-stack

Signed-off-by: Doug Chapman <doug.chapman@hp.com>

----

diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index ff0e7c1..6db0859 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -59,6 +59,7 @@ dump (const char *str, void *vp, size_t len)
  *  (i.e. don't allow attacker to fill up logs with unaligned accesses).
  */
 int no_unaligned_warning;
+int unaligned_dump_stack;
 static int noprint_warning;
 
 /*
@@ -1371,9 +1372,12 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 			}
 		}
 	} else {
-		if (within_logging_rate_limit())
+		if (within_logging_rate_limit()) {
 			printk(KERN_WARNING "kernel unaligned access to 0x%016lx, ip=0x%016lx\n",
 			       ifa, regs->cr_iip + ipsr->ri);
+			if (unaligned_dump_stack)
+				dump_stack();
+		}
 		set_fs(KERNEL_DS);
 	}
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ff6d45c..3c4950c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -144,6 +144,7 @@ extern int acct_parm[];
 
 #ifdef CONFIG_IA64
 extern int no_unaligned_warning;
+extern int unaligned_dump_stack;
 #endif
 
 #ifdef CONFIG_RT_MUTEXES
@@ -781,6 +782,14 @@ static struct ctl_table kern_table[] = {
 	 	.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "unaligned-dump-stack",
+		.data		= &unaligned_dump_stack,
+		.maxlen		= sizeof (int),
+	 	.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #endif
 #ifdef CONFIG_DETECT_SOFTLOCKUP
 	{



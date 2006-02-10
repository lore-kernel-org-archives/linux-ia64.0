From: Jes Sorensen <jes@sgi.com>
Date: Fri, 10 Feb 2006 16:21:44 +0000
Subject: [patch] option to quite unaligned trap warnings
Message-Id: <yq0hd772nhj.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This patch is an attempt to find a good compromise to the somewhat
contentious issue of the unaligned usertrap warnings.

Every engineer obviously agrees that these warnings should be taken
serious and acted upon. However there are cases where systems are
running applications where they do not have control of the
applications or simply don't care, ie. if you're running some Java app
and the JVM is spitting out a ton of these warnings (yes, I've seen
this in system logs - no, I didn't run the Java apps ;-). In these
situations administrators at times get really annoyed with these
warnings chewing up their syslog.

What this patch does is to provide an option for the system
administrator to switch off the warnings system wide, overruling the
prctl setting. By doing so he/she will get a single warning in the
syslog strongly recommending that they reenable it and have the users
fix their apps since it will lead to improved performance.

Note that the default setting in this patch is the same as we have
right now. Admins needs to take action to disable the messages.

IMHO this seems a reasonable compromise - anybody have objections
against this going into the tree?

Cheers,
Jes

Some sites have no option to recompile their applications or do not
care to spend time fixing them to eliminate unaligned accesses and
therefore find the kernel's warnings highly annoying.

This patch will allow a site to disable the unaligned warnings for all
userland apps as an alternative to the individual user using prctl to
do so. It does however print a strong encouragement to the syslog for
the site administrator to re-enable and fix the applications on the
first occurrence of such a trap.

Sample message as it would be found in the syslog:

test-unaligned(13233) encountered an unaligned exception which required
kernel assistance, which degrades the performance of the application.
Unaligned exception warnings have been disabled by the system administrator
and you will see no more of these messages. It is recommend that the
warnings be re-enabled and the information used to fix the applications
which will lead to better performance of the applications in question!
echo 0 > /proc/sys/kernel/ignore-unaligned-usertrap to re-enable!

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 arch/ia64/kernel/unaligned.c |   38 +++++++++++++++++++++++++++++++++++---
 include/linux/sysctl.h       |    1 +
 kernel/sysctl.c              |   14 ++++++++++++++
 3 files changed, 50 insertions(+), 3 deletions(-)

Index: linux-2.6/arch/ia64/kernel/unaligned.c
=================================--- linux-2.6.orig/arch/ia64/kernel/unaligned.c
+++ linux-2.6/arch/ia64/kernel/unaligned.c
@@ -53,6 +53,15 @@
 #define SIGN_EXT9		0xffffffffffffff00ul
 
 /*
+ *  sysctl settable hook which tells the kernel whether to honor the
+ *  IA64_THREAD_UAC_NOPRINT prctl.  Because this is user settable, we want
+ *  to allow the super user to enable/disable this for security reasons
+ *  (i.e. don't allow attacker to fill up logs with unaligned accesses).
+ */
+int no_unaligned_warning;
+static int noprint_warning;
+
+/*
  * For M-unit:
  *
  *  opcode |   m  |   x6    |
@@ -1324,8 +1333,9 @@
 		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) != 0)
 			goto force_sigbus;
 
-		if (!(current->thread.flags & IA64_THREAD_UAC_NOPRINT)
-		    && within_logging_rate_limit())
+		if (!no_unaligned_warning &&
+		    !(current->thread.flags & IA64_THREAD_UAC_NOPRINT) &&
+		    within_logging_rate_limit())
 		{
 			char buf[200];	/* comm[] is at most 16 bytes... */
 			size_t len;
@@ -1340,7 +1350,29 @@
 			if (user_mode(regs))
 				tty_write_message(current->signal->tty, buf);
 			buf[len-1] = '\0';	/* drop '\r' */
-			printk(KERN_WARNING "%s", buf);	/* watch for command names containing %s */
+			/* watch for command names containing %s */
+			printk(KERN_WARNING "%s", buf);
+		} else {
+			if (no_unaligned_warning && !noprint_warning) {
+				noprint_warning = 1;
+				printk(KERN_WARNING "%s(%d) encountered an "
+				       "unaligned exception which required\n"
+				       "kernel assistance, which degrades "
+				       "the performance of the application.\n"
+				       "Unaligned exception warnings have "
+				       "been disabled by the system "
+				       "administrator\n"
+				       "and you will see no more of these "
+				       "messages. It is recommend that the\n"
+				       "warnings be re-enabled and the "
+				       "information used to fix the "
+				       "applications\n"
+				       "which will lead to better performance "
+				       "of the applications in question!\n"
+				       "echo 0 > /proc/sys/kernel/ignore-"
+				       "unaligned-usertrap to re-enable!\n",
+				       current->comm, current->pid);
+			}
 		}
 	} else {
 		if (within_logging_rate_limit())
Index: linux-2.6/include/linux/sysctl.h
=================================--- linux-2.6.orig/include/linux/sysctl.h
+++ linux-2.6/include/linux/sysctl.h
@@ -146,6 +146,7 @@
 	KERN_RANDOMIZEh, /* int: randomize virtual address space */
 	KERN_SETUID_DUMPABLEi, /* int: behaviour of dumps for setuid core */
 	KERN_SPIN_RETRYp,	/* int: number of spinlock retries */
+	KERN_IA64_UNALIGNEDq,	/* int: ia64 unaligned userland trap enable */
 };
 
 
Index: linux-2.6/kernel/sysctl.c
=================================--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -126,6 +126,10 @@
 extern int acct_parm[];
 #endif
 
+#ifdef CONFIG_IA64
+extern int no_unaligned_warning;
+#endif
+
 int randomize_va_space = 1;
 
 static int parse_table(int __user *, int, void __user *, size_t __user *, void __user *, size_t,
@@ -658,6 +662,16 @@
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
+#ifdef CONFIG_IA64
+	{
+		.ctl_name	= KERN_IA64_UNALIGNED,
+		.procname	= "ignore-unaligned-usertrap",
+		.data		= &no_unaligned_warning,
+		.maxlen		= sizeof (int),
+	 	.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+#endif
 	{ .ctl_name = 0 }
 };
 

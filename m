From: "Kenneth Chen" <kenneth.w.chen@intel.com>
Date: Thu, 18 Mar 2004 00:31:26 +0000
Subject: add lowpower_idle sysctl
Message-Id: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org

On ia64, we need runtime control to manage CPU power state in the idle
loop.  Logically it means a sysctl entry in /proc/sys/kernel.  Even
though this sysctl entry doesn't exist today, lots of arch already has
some sort of API to dynamically enable/disable low power idle state.
Looking at linux-2.6.4, arm, arm26, cris, i386, parisc, sh, um, x86-64
all has very much the same code in each arch.  So instead of replicate
another set under arch/ia64, we are proposing these API to be abstracted
out in the generic code.  And also add a sysctl entry under /proc/sys/kernel.

Would this be useful to all architecture who wants this features?  It
would be a lot less code duplication.

- Ken


diff -Nur linux-2.6.4/include/linux/sysctl.h linux-2.6.4.halt/include/linux/sysctl.h
--- linux-2.6.4/include/linux/sysctl.h	2004-03-10 18:55:28.000000000 -0800
+++ linux-2.6.4.halt/include/linux/sysctl.h	2004-03-17 15:33:30.000000000 -0800
@@ -131,6 +131,7 @@
 	KERN_PRINTK_RATELIMIT_BURSTa,	/* int: tune printk ratelimiting */
 	KERN_PTYb,		/* dir: pty driver */
 	KERN_NGROUPS_MAXc,	/* int: NGROUPS_MAX */
+	KERN_LOWPOWER_IDLEd,	/* int: low power idle */
 };


diff -Nur linux-2.6.4/kernel/cpu.c linux-2.6.4.halt/kernel/cpu.c
--- linux-2.6.4/kernel/cpu.c	2004-03-10 18:55:44.000000000 -0800
+++ linux-2.6.4.halt/kernel/cpu.c	2004-03-17 15:36:32.000000000 -0800
@@ -64,3 +64,15 @@
 	up(&cpucontrol);
 	return ret;
 }
+
+atomic_t halt_counter;
+void enable_halt(void)
+{
+	atomic_dec(&halt_counter);
+}
+void disable_halt(void)
+{
+	atomic_inc(&halt_counter);
+}
+EXPORT_SYMBOL(enable_halt);
+EXPORT_SYMBOL(disable_halt);
diff -Nur linux-2.6.4/kernel/sysctl.c linux-2.6.4.halt/kernel/sysctl.c
--- linux-2.6.4/kernel/sysctl.c	2004-03-10 18:55:22.000000000 -0800
+++ linux-2.6.4.halt/kernel/sysctl.c	2004-03-17 15:34:52.000000000 -0800
@@ -64,6 +64,7 @@
 extern int min_free_kbytes;
 extern int printk_ratelimit_jiffies;
 extern int printk_ratelimit_burst;
+extern atomic_t halt_counter;

 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -615,6 +616,14 @@
 		.mode		= 0444,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= KERN_LOWPOWER_IDLE,
+		.procname	= "lowpower_idle",
+		.data		= &halt_counter,
+		.maxlen		= sizeof (int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };




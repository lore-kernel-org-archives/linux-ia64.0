From: "Kenneth Chen" <kenneth.w.chen@intel.com>
Date: Thu, 18 Mar 2004 21:59:44 +0000
Subject: RE: add lowpower_idle sysctl
Message-Id: <200403182159.i2ILxhF12208@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040317192821.1fe90f24.akpm@osdl.org>
References: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
In-Reply-To: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Andrew Morton' <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> Andrew Morton wrote on Wed, March 17, 2004 7:28 PM
> > "Kenneth Chen" <kenneth.w.chen@intel.com> wrote:
> >
> >  Writing to sysctl should be a bool, reading the value can be number of
> >  module currently disabled low power idle.  I think the original intent
> >  is to use ref count for enabling/disabling.  (granted, we copied the
> >  code from other arch).
>
> OK, so why not give us:
>
> #define IDLE_HALT			0
> #define IDLE_POLL			1
> #define IDLE_SUPER_LOW_POWER_HALT	2
>
> and so forth (are there any others?).
>
> Set some system-wide integer via a sysctl and let the particular
> architecture decide how best to implement the currently-selected
> idle mode?


Sounds good, Thanks for the suggestion. I just coded it up:


diff -Nur linux-2.6.4/include/linux/cpu.h linux-2.6.4.halt/include/linux/cpu.h
--- linux-2.6.4/include/linux/cpu.h	2004-03-10 18:55:23.000000000 -0800
+++ linux-2.6.4.halt/include/linux/cpu.h	2004-03-18 13:47:43.000000000 -0800
@@ -52,6 +52,12 @@

 #endif /* CONFIG_SMP */
 extern struct sysdev_class cpu_sysdev_class;
+extern int idle_mode;
+
+#define IDLE_NOOP	0
+#define IDLE_HALT	1
+#define IDLE_POLL	2
+#define IDLE_ACPI	3

 #ifdef CONFIG_HOTPLUG_CPU
 /* Stop CPUs going up and down. */
diff -Nur linux-2.6.4/include/linux/sysctl.h linux-2.6.4.halt/include/linux/sysctl.h
--- linux-2.6.4/include/linux/sysctl.h	2004-03-10 18:55:28.000000000 -0800
+++ linux-2.6.4.halt/include/linux/sysctl.h	2004-03-18 12:00:40.000000000 -0800
@@ -131,6 +131,7 @@
 	KERN_PRINTK_RATELIMIT_BURSTa,	/* int: tune printk ratelimiting */
 	KERN_PTYb,		/* dir: pty driver */
 	KERN_NGROUPS_MAXc,	/* int: NGROUPS_MAX */
+	KERN_IDLE_MODEd,	/* int: arch specific cpu idle mode */
 };


diff -Nur linux-2.6.4/kernel/cpu.c linux-2.6.4.halt/kernel/cpu.c
--- linux-2.6.4/kernel/cpu.c	2004-03-10 18:55:44.000000000 -0800
+++ linux-2.6.4.halt/kernel/cpu.c	2004-03-18 13:29:28.000000000 -0800
@@ -64,3 +64,5 @@
 	up(&cpucontrol);
 	return ret;
 }
+
+int idle_mode = IDLE_HALT;
diff -Nur linux-2.6.4/kernel/sysctl.c linux-2.6.4.halt/kernel/sysctl.c
--- linux-2.6.4/kernel/sysctl.c	2004-03-10 18:55:22.000000000 -0800
+++ linux-2.6.4.halt/kernel/sysctl.c	2004-03-18 13:52:27.000000000 -0800
@@ -39,6 +39,7 @@
 #include <linux/initrd.h>
 #include <linux/times.h>
 #include <linux/limits.h>
+#include <linux/cpu.h>
 #include <asm/uaccess.h>

 #ifdef CONFIG_ROOT_NFS
@@ -615,6 +616,14 @@
 		.mode		= 0444,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= KERN_IDLE_MODE,
+		.procname	= "idle_mode",
+		.data		= &idle_mode,
+		.maxlen		= sizeof (int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };




From: John Levon <levon@movementarian.org>
Date: Tue, 14 Oct 2003 20:04:37 +0000
Subject: [PATCH] ia64 perfmon OProfile support
Message-Id: <marc-linux-ia64-106616192023718@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Here's the kernel patch OProfile needs for perfmon support. The rest of
the changes are all in userspace now, I think.

regards
john

Index: linux-cvs//arch/ia64/oprofile/Makefile
=================================RCS file: /home/cvs/linux-2.5/arch/ia64/oprofile/Makefile,v
retrieving revision 1.2
diff -u -a -p -r1.2 Makefile
--- linux-cvs//arch/ia64/oprofile/Makefile	9 Sep 2003 16:07:11 -0000	1.2
+++ linux-cvs//arch/ia64/oprofile/Makefile	14 Oct 2003 19:57:51 -0000
@@ -7,3 +7,4 @@ DRIVER_OBJS := $(addprefix ../../../driv
 		timer_int.o )
 
 oprofile-y := $(DRIVER_OBJS) init.o
+oprofile-$(CONFIG_PERFMON) += perfmon.o
Index: linux-cvs//arch/ia64/oprofile/init.c
=================================RCS file: /home/cvs/linux-2.5/arch/ia64/oprofile/init.c,v
retrieving revision 1.2
diff -u -a -p -r1.2 init.c
--- linux-cvs//arch/ia64/oprofile/init.c	9 Sep 2003 16:07:11 -0000	1.2
+++ linux-cvs//arch/ia64/oprofile/init.c	14 Oct 2003 19:57:51 -0000
@@ -12,14 +12,21 @@
 #include <linux/init.h>
 #include <linux/errno.h>
  
-extern void timer_init(struct oprofile_operations ** ops);
+extern int perfmon_init(struct oprofile_operations ** ops);
+extern void perfmon_exit(void);
 
 int __init oprofile_arch_init(struct oprofile_operations ** ops)
 {
+#ifdef CONFIG_PERFMON
+	return perfmon_init(ops);
+#endif
 	return -ENODEV;
 }
 
 
 void oprofile_arch_exit(void)
 {
+#ifdef CONFIG_PERFMON
+	perfmon_exit();
+#endif
 }
--- /dev/null	Thu Aug 21 13:36:33 2003
+++ linux-cvs/arch/ia64/oprofile/perfmon.c	Mon Oct 13 21:43:04 2003
@@ -0,0 +1,82 @@
+/**
+ * @file perfmon.c
+ *
+ * @remark Copyright 2003 OProfile authors
+ * @remark Read the file COPYING
+ *
+ * @author John Levon <levon@movementarian.org>
+ */
+
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/oprofile.h>
+#include <linux/sched.h>
+#include <asm/perfmon.h>
+#include <asm/ptrace.h>
+#include <asm/errno.h>
+
+static int
+perfmon_handler(struct task_struct * task, void * buf, pfm_ovfl_arg_t * arg,
+                struct pt_regs * regs, unsigned long stamp)
+{
+	int cpu = smp_processor_id();
+	unsigned long eip = instruction_pointer(regs);
+	int event = arg->pmd_eventid;
+ 
+	oprofile_add_sample(eip, !user_mode(regs), event, cpu);
+	arg->ovfl_ctrl.bits.reset_ovfl_pmds = 1;
+	return 0;
+}
+
+
+#define OPROFILE_FMT_UUID { \
+	0x77, 0x7a, 0x6e, 0x61, 0x20, 0x65, 0x73, 0x69, 0x74, 0x6e, 0x72, 0x20, 0x61, 0x65, 0x0a, 0x6c }
+
+static pfm_buffer_fmt_t oprofile_fmt = {
+ 	.fmt_name 	    = "oprofile_format",
+ 	.fmt_uuid	    = OPROFILE_FMT_UUID,
+ 	.fmt_handler	    = perfmon_handler,
+};
+
+
+static char * get_cpu_type(void)
+{
+	__u8 family = local_cpu_data->family;
+
+	switch (family) {
+		case 0x07:
+			return "ia64/itanium";
+		case 0x1f:
+			return "ia64/itanium2";
+		default:
+			return "ia64/ia64";
+	}
+}
+
+
+/* all the ops are handled via userspace for IA64 perfmon */
+static struct oprofile_operations perfmon_ops;
+
+static int using_perfmon;
+
+int perfmon_init(struct oprofile_operations ** ops)
+{
+	int ret = pfm_register_buffer_fmt(&oprofile_fmt);
+	if (ret)
+		return -ENODEV;
+
+	perfmon_ops.cpu_type = get_cpu_type();
+	*ops = &perfmon_ops;
+	using_perfmon = 1;
+	printk(KERN_INFO "oprofile: using perfmon.\n");
+	return 0;
+}
+
+
+void perfmon_exit(void)
+{
+	if (!using_perfmon)
+		return;
+
+	pfm_unregister_buffer_fmt(oprofile_fmt.fmt_uuid);
+}
Index: linux-cvs//drivers/oprofile/oprof.c
=================================RCS file: /home/cvs/linux-2.5/drivers/oprofile/oprof.c,v
retrieving revision 1.9
diff -u -a -p -r1.9 oprof.c
--- linux-cvs//drivers/oprofile/oprof.c	12 Jun 2003 03:28:40 -0000	1.9
+++ linux-cvs//drivers/oprofile/oprof.c	14 Oct 2003 19:58:04 -0000
@@ -88,7 +88,7 @@ int oprofile_start(void)
  
 	oprofile_reset_stats();
 
-	if ((err = oprofile_ops->start()))
+	if (oprofile_ops->start && (err = oprofile_ops->start()))
 		goto out;
 
 	oprofile_started = 1;
@@ -104,7 +104,8 @@ void oprofile_stop(void)
 	down(&start_sem);
 	if (!oprofile_started)
 		goto out;
-	oprofile_ops->stop();
+	if (oprofile_ops->stop)
+		oprofile_ops->stop();
 	oprofile_started = 0;
 	/* wake up the daemon to read what remains */
 	wake_up_buffer_waiter();

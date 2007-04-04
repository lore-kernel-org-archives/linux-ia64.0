From: Jay Lan <jlan@sgi.com>
Date: Wed, 04 Apr 2007 00:53:42 +0000
Subject: Re: [PATCH] IA64 kdump on INIT needs multi-nodes sync-up (v.2)
Message-Id: <4612F716.4010900@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040709060009070207090701"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040709060009070207090701
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This v.2 version puts acess to kdump_in_progress in the
default_monarch_init_process() function inside #ifdef CONFIG_KEXEC.

Regards,
 - jay


The current implementation of kdump on INIT events would enter
kdump processing on DIE_INIT_MONARCH_ENTER and DIE_INIT_SLAVE_ENTER
events. Thus, the monarch cpu would go ahead and boot up the kdump

On SN shub2 systems, this out-of-sync situation causes some slave
cpus on different nodes to enter POD.

This patch moves kdump entry points to DIE_INIT_MONARCH_LEAVE and
DIE_INIT_SLAVE_LEAVE. It also sets kdump_in_progress variable in
the DIE_INIT_MONARCH_PROCESS event to not dump all active stack
traces to the console in the case of kdump.

I have tested this patch on an SN machine and a HP RX2600.

Signed-off-by: Jay Lan <jlan@sgi.com>

--------------040709060009070207090701
Content-Type: text/plain;
 name="nmi-multi-nodes-sync-up"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nmi-multi-nodes-sync-up"

Index: linux/arch/ia64/kernel/crash.c
===================================================================
--- linux.orig/arch/ia64/kernel/crash.c	2007-03-25 15:56:23.000000000 -0700
+++ linux/arch/ia64/kernel/crash.c	2007-03-29 11:33:08.324517309 -0700
@@ -156,24 +156,30 @@ kdump_init_notifier(struct notifier_bloc
 	if (!kdump_on_init)
 		return NOTIFY_DONE;
 
-	if (val != DIE_INIT_MONARCH_ENTER &&
-	    val != DIE_INIT_SLAVE_ENTER &&
+	if (val != DIE_INIT_MONARCH_LEAVE &&
+	    val != DIE_INIT_SLAVE_LEAVE &&
+	    val != DIE_INIT_MONARCH_PROCESS &&
 	    val != DIE_MCA_RENDZVOUS_LEAVE &&
 	    val != DIE_MCA_MONARCH_LEAVE)
 		return NOTIFY_DONE;
 
 	nd = (struct ia64_mca_notify_die *)args->err;
 	/* Reason code 1 means machine check rendezous*/
-	if ((val == DIE_INIT_MONARCH_ENTER || val == DIE_INIT_SLAVE_ENTER) &&
-		 nd->sos->rv_rc == 1)
+	if ((val == DIE_INIT_MONARCH_LEAVE || val == DIE_INIT_SLAVE_LEAVE
+	    || val == DIE_INIT_MONARCH_PROCESS) && nd->sos->rv_rc == 1)
 		return NOTIFY_DONE;
 
 	switch (val) {
-		case DIE_INIT_MONARCH_ENTER:
+		case DIE_INIT_MONARCH_PROCESS:
+			atomic_set(&kdump_in_progress, 1);
+			*(nd->monarch_cpu) = -1;
+			break;
+		case DIE_INIT_MONARCH_LEAVE:
 			machine_kdump_on_init();
 			break;
-		case DIE_INIT_SLAVE_ENTER:
-			unw_init_running(kdump_cpu_freeze, NULL);
+		case DIE_INIT_SLAVE_LEAVE:
+			if (atomic_read(&kdump_in_progress))
+				unw_init_running(kdump_cpu_freeze, NULL);
 			break;
 		case DIE_MCA_RENDZVOUS_LEAVE:
 			if (atomic_read(&kdump_in_progress))
@@ -215,8 +221,10 @@ static ctl_table sys_table[] = {
 static int
 machine_crash_setup(void)
 {
+	/* be notified before default_monarch_init_process */
 	static struct notifier_block kdump_init_notifier_nb = {
 		.notifier_call = kdump_init_notifier,
+		.priority = 1,
 	};
 	int ret;
 	if((ret = register_die_notifier(&kdump_init_notifier_nb)) != 0)
Index: linux/arch/ia64/kernel/mca.c
===================================================================
--- linux.orig/arch/ia64/kernel/mca.c	2007-03-25 15:56:23.000000000 -0700
+++ linux/arch/ia64/kernel/mca.c	2007-04-03 17:34:44.967380241 -0700
@@ -1476,6 +1476,10 @@ default_monarch_init_process(struct noti
 	struct task_struct *g, *t;
 	if (val != DIE_INIT_MONARCH_PROCESS)
 		return NOTIFY_DONE;
+#ifdef CONFIG_KEXEC
+	if (atomic_read(&kdump_in_progress))
+		return NOTIFY_DONE;
+#endif
 
 	/*
 	 * FIXME: mlogbuf will brim over with INIT stack dumps.

--------------040709060009070207090701--

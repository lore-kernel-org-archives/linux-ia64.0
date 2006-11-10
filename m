From: Jay Lan <jlan@sgi.com>
Date: Fri, 10 Nov 2006 23:59:59 +0000
Subject: [PATCH 2/2] IA64 kdump: MCA notify_die events
Message-Id: <455512AF.30603@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030200040505020602070109"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030200040505020602070109
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Add DIE_MCA_MONARCH_LEAVE and DIE_MCA_RENDZVOUS_LEAVE
events handling in kdump_init_notifier().

We let ia64_mca_handler() and ia64_mca_rendez_int_handler()
to perform the MCA handling. The slave cpus will be sent to the
SAL slave loop on the DIE_MCA_RENDZVOUS_LEAVE event, and the
monarch will start the kdump kernel on the DIE_MCA_MONARCH_LEAVE
event.

I initially created a machine_kdump_on_mca() but decided
to simply use machine_kdump_on_init() in the case of
DIE_MCA_MONARCH_LEAVE since no special handling is needed.


signed-Off-By:  Jay Lan <jlan@sgi.com>






--------------030200040505020602070109
Content-Type: text/plain;
 name="MCA-event-notifier"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="MCA-event-notifier"

Index: linux/arch/ia64/kernel/crash.c
===================================================================
--- linux.orig/arch/ia64/kernel/crash.c	2006-11-10 14:48:53.033147572 -0800
+++ linux/arch/ia64/kernel/crash.c	2006-11-10 14:50:24.014240287 -0800
@@ -24,6 +24,7 @@
 int kdump_status[NR_CPUS];
 atomic_t kdump_cpu_freezed;
 int kdump_on_init = 1;
+extern int kdump_in_progress;
 
 ssize_t
 copy_oldmem_page(unsigned long pfn, char *buf,
@@ -165,12 +166,16 @@ kdump_init_notifier(struct notifier_bloc
 	if (!kdump_on_init)
 		return NOTIFY_DONE;
 
-	if (val != DIE_INIT_MONARCH_ENTER && val != DIE_INIT_SLAVE_ENTER)
+	if (val != DIE_INIT_MONARCH_ENTER &&
+	    val != DIE_INIT_SLAVE_ENTER &&
+	    val != DIE_MCA_RENDZVOUS_LEAVE &&
+	    val != DIE_MCA_MONARCH_LEAVE)
 		return NOTIFY_DONE;
 
 	nd = (struct ia64_mca_notify_die *)args->err;
 	/* Reason code 1 means machine check rendezous*/
-	if (nd->sos->rv_rc == 1)
+	if ((val==DIE_INIT_MONARCH_ENTER || val==DIE_INIT_SLAVE_ENTER) &&
+	    nd->sos->rv_rc == 1)
 		return NOTIFY_DONE;
 
 	if (kdump_sending_init)
@@ -183,6 +188,15 @@ kdump_init_notifier(struct notifier_bloc
 		case DIE_INIT_SLAVE_ENTER:
 			unw_init_running(kdump_cpu_freeze, NULL);
 			break;
+		case DIE_MCA_RENDZVOUS_LEAVE:
+			if (kdump_in_progress)
+				unw_init_running(kdump_cpu_freeze, NULL);
+			break;
+		case DIE_MCA_MONARCH_LEAVE:
+			/* die_register->signr indicate if MCA is recoverable */
+			if (!args->signr)
+				machine_kdump_on_init();
+			break;
 	}
 	return NOTIFY_DONE;
 }
Index: linux/arch/ia64/kernel/mca.c
===================================================================
--- linux.orig/arch/ia64/kernel/mca.c	2006-11-10 14:48:41.773012428 -0800
+++ linux/arch/ia64/kernel/mca.c	2006-11-10 15:17:22.018866761 -0800
@@ -92,6 +92,11 @@
 # define IA64_MCA_DEBUG(fmt...)
 #endif
 
+#ifdef CONFIG_KEXEC
+/* Used by arch/ia64/kernel/crash.c */
+int kdump_in_progress;
+#endif
+
 /* Used by mca_asm.S */
 u32				ia64_mca_serialize;
 DEFINE_PER_CPU(u64, ia64_mca_data); /* == __per_cpu_mca[smp_processor_id()] */
@@ -1066,6 +1071,15 @@ ia64_mca_handler(struct pt_regs *regs, s
 		rh->severity = sal_log_severity_corrected;
 		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
 		sos->os_status = IA64_MCA_CORRECTED;
+#ifdef CONFIG_KEXEC
+	} else {
+		kdump_in_progress = 1;
+		/* In the case of (!recover), notify_die(DIE_MCA_MONARCH_LEAVE)
+		   will not return. A dump kernel will be booted. Need to set
+		   nonarch_cpu here to get slave cpus out of looping in OS.
+		 */
+		monarch_cpu = -1;
+#endif
 	}
 	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
 			== NOTIFY_STOP)


--------------030200040505020602070109--

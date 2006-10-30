From: Jay Lan <jlan@engr.sgi.com>
Date: Mon, 30 Oct 2006 20:36:13 +0000
Subject: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010000010702030401010900"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010000010702030401010900
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This patch is to fix a problem of interrupts being sent to cpus
that can not respond.

This patch would return slave cpus to SAL slave loop, at time of
crash, except cpu0. The cpu0 is a special case as there is no way
to return it to SAL, so cpu0 is better handled in firmware.

Signed-off-by: Jay Lan <jlan@sgi.com>



--------------010000010702030401010900
Content-Type: text/plain;
 name="send-cpus-to-slave-loop"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="send-cpus-to-slave-loop"

Index: linux/arch/ia64/kernel/crash.c
===================================================================
--- linux.orig/arch/ia64/kernel/crash.c	2006-10-17 17:09:45.662734380 -0700
+++ linux/arch/ia64/kernel/crash.c	2006-10-30 12:27:12.080526026 -0800
@@ -146,14 +146,21 @@ machine_kdump_on_init(void)
 void
 kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
 {
+	int cpuid = smp_processor_id();
+
 	local_irq_disable();
 	crash_save_this_cpu();
 	current->thread.ksp = (__u64)info->sw - 16;
 	atomic_inc(&kdump_cpu_freezed);
-	kdump_status[smp_processor_id()] = 1;
+	kdump_status[cpuid] = 1;
 	mb();
-	for (;;)
-		cpu_relax();
+        /* return cpus (except cpu0) to SAL slave loop */
+        if (cpuid == 0) {
+                for (;;)
+                        cpu_relax();
+        } else {
+                ia64_jump_to_sal(&sal_boot_rendez_state[cpuid]);
+        }
 }
 
 static int

--------------010000010702030401010900--

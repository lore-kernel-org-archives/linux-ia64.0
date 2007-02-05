From: Horms <horms@verge.net.au>
Date: Mon, 05 Feb 2007 01:18:00 +0000
Subject: [PATCH] [IA64] kexec: Move machine_shutdown from machine_kexec.c to process.c
Message-Id: <20070205011758.GD31046@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This moves the ia64 implementation of machine_shutdown() from
machine_kexec.c to process.c, which is in keeping with the implelmentation
on other architectures, and seems like a much more appropriate home for it.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-12-18 12:56:04.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2006-12-18 12:56:52.000000000 +0900
@@ -69,17 +69,6 @@
 {
 }
 
-void machine_shutdown(void)
-{
-	int cpu;
-
-	for_each_online_cpu(cpu) {
-		if (cpu != smp_processor_id())
-			cpu_down(cpu);
-	}
-	kexec_disable_iosapic();
-}
-
 /*
  * boot_param is used inside purgatory and purgatory runs
  * in physical mode, so translate the addresses that purgatory
Index: linux-2.6/arch/ia64/kernel/process.c
=================================--- linux-2.6.orig/arch/ia64/kernel/process.c	2006-12-18 12:56:10.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/process.c	2006-12-18 12:56:18.000000000 +0900
@@ -797,6 +797,17 @@
 		ia64_pal_halt(min_power_state);
 }
 
+void machine_shutdown(void)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		if (cpu != smp_processor_id())
+			cpu_down(cpu);
+	}
+	kexec_disable_iosapic();
+}
+
 void
 machine_restart (char *restart_cmd)
 {

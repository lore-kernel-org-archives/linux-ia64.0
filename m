From: Jay Lan <jlan@sgi.com>
Date: Mon, 11 Dec 2006 23:39:23 +0000
Subject: [PATCH] Do not call SN_SAL_SET_CPU_NUMBER twice on cpu 0
Message-Id: <457DEC2B.3060104@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050202070107000404080908"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050202070107000404080908
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This is an SN specific patch.

Architectually, cpu_init is always called twice on cpu 0
and thus resulted in two SN_SAL_SET_CPU_NUMBER calls.

This was harmless in production kernel; however, it can
cause problem on booting up a crashdump kernel at Altix.

Here is the patch that detects the second sn_cpu_init
call and skips the second call to SN_SAL_SET_CPU_NUMBER.

Signed-Off-By: Jay Lan <jlan@sgi.com>

The patch is created off 2.6.19.


--------------050202070107000404080908
Content-Type: text/plain;
 name="dont-set-cpu0-number-twice"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dont-set-cpu0-number-twice"

Index: linux/arch/ia64/sn/kernel/setup.c
===================================================================
--- linux.orig/arch/ia64/sn/kernel/setup.c	2006-11-29 13:57:37.000000000 -0800
+++ linux/arch/ia64/sn/kernel/setup.c	2006-12-11 15:31:16.700848251 -0800
@@ -562,7 +562,7 @@ void __cpuinit sn_cpu_init(void)
 	int slice;
 	int cnode;
 	int i;
-	static int wars_have_been_checked;
+	static int wars_have_been_checked, set_cpu0_number;
 
 	cpuid = smp_processor_id();
 	if (cpuid == 0 && IS_MEDUSA()) {
@@ -587,8 +587,16 @@ void __cpuinit sn_cpu_init(void)
 	/*
 	 * Don't check status. The SAL call is not supported on all PROMs
 	 * but a failure is harmless.
+	 * Architechtuallly, cpu_init is always called twice on cpu 0. We
+	 * should set cpu_number on cpu 0 once.
 	 */
-	(void) ia64_sn_set_cpu_number(cpuid);
+	if (cpuid == 0) {
+		if (!set_cpu0_number) {
+			(void) ia64_sn_set_cpu_number(cpuid);
+			set_cpu0_number = 1;
+		}
+	} else
+		(void) ia64_sn_set_cpu_number(cpuid);
 
 	/*
 	 * The boot cpu makes this call again after platform initialization is

--------------050202070107000404080908--

From: Jack Steiner <steiner@sgi.com>
Date: Fri, 28 Apr 2006 01:01:05 +0000
Subject: Re: [PATCH] - Pass OS logical cpu number to the SN prom (bios)
Message-Id: <20060428010104.GA30251@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060427220857.GA14901@sgi.com>
In-Reply-To: <20060427220857.GA14901@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Pass the OS logical cpu number to the PROM. This allows PROM
to log the OS logical cpu number in error records viewed thru POD.


	Signed-off-by: Jack Steiner <steiner@sgi.com>

---
Add change suggested by Keith...


Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2006-04-22 08:50:14.567000831 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2006-04-27 19:58:16.633858645 -0500
@@ -577,7 +577,8 @@ void __init sn_cpu_init(void)
 	int i;
 	static int wars_have_been_checked;
 
-	if (smp_processor_id() = 0 && IS_MEDUSA()) {
+	cpuid = smp_processor_id();
+	if (cpuid = 0 && IS_MEDUSA()) {
 		if (ia64_sn_is_fake_prom())
 			sn_prom_type = 2;
 		else
@@ -597,6 +598,12 @@ void __init sn_cpu_init(void)
 	sn_hub_info->as_shift = sn_hub_info->nasid_shift - 2;
 
 	/*
+	 * Don't check status. The SAL call is not supported on all PROMs
+	 * but a failure is harmless.
+	 */
+	(void) ia64_sn_set_cpu_number(cpuid);
+
+	/*
 	 * The boot cpu makes this call again after platform initialization is
 	 * complete.
 	 */
@@ -607,7 +614,6 @@ void __init sn_cpu_init(void)
 		if (ia64_sn_get_prom_feature_set(i, &sn_prom_features[i]) != 0)
 			break;
 
-	cpuid = smp_processor_id();
 	cpuphyid = get_sapicid();
 
 	if (ia64_sn_get_sapic_info(cpuphyid, &nasid, &subnode, &slice))
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2006-04-22 08:50:19.858482442 -0500
+++ linux/include/asm-ia64/sn/sn_sal.h	2006-04-27 17:02:24.654672135 -0500
@@ -85,6 +85,7 @@
 
 #define  SN_SAL_GET_PROM_FEATURE_SET		   0x02000065
 #define  SN_SAL_SET_OS_FEATURE_SET		   0x02000066
+#define  SN_SAL_SET_CPU_NUMBER			   0x02000068
 
 /*
  * Service-specific constants
@@ -1140,4 +1141,13 @@ ia64_sn_set_os_feature(int feature)
 	return rv.status;
 }
 
+static inline int
+ia64_sn_set_cpu_number(int cpu)
+{
+	struct ia64_sal_retval rv;
+
+	SAL_CALL_NOLOCK(rv, SN_SAL_SET_CPU_NUMBER, cpu, 0, 0, 0, 0, 0, 0);
+	return rv.status;
+}
+
 #endif /* _ASM_IA64_SN_SN_SAL_H */

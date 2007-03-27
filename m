From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Mar 2007 13:29:54 +0000
Subject: [PATCH] - Speed up boot - skip unnecessary clock calibration
Message-Id: <20070327132953.GA14401@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Skip clock calibration if cpu being brought online is exactly the same
speed, stepping, etc., as the previous cpu. This significantly reduces
the time to boot very large systems. 

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/kernel/smpboot.c
=================================--- linux.orig/arch/ia64/kernel/smpboot.c	2007-03-26 15:04:29.322256475 -0500
+++ linux/arch/ia64/kernel/smpboot.c	2007-03-27 08:26:41.914042190 -0500
@@ -424,7 +424,19 @@ smp_callin (void)
 	 * Get our bogomips.
 	 */
 	ia64_init_itm();
-	calibrate_delay();
+
+	/*
+	 * Delay calibration can be skipped if new processor is identical to the
+	 * previous processor.
+	 */
+	if (local_cpu_data->itc_freq != per_cpu(cpu_info, cpuid - 1).itc_freq ||
+			local_cpu_data->proc_freq != per_cpu(cpu_info, cpuid - 1).proc_freq ||
+	    		local_cpu_data->features != per_cpu(cpu_info, cpuid - 1).features ||
+	    		local_cpu_data->revision != per_cpu(cpu_info, cpuid - 1).revision ||
+	    		local_cpu_data->family != per_cpu(cpu_info, cpuid - 1).family ||
+	    		local_cpu_data->archrev != per_cpu(cpu_info, cpuid - 1).archrev ||
+	    		local_cpu_data->model != per_cpu(cpu_info, cpuid - 1).model)
+		calibrate_delay();
 	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
 
 #ifdef CONFIG_IA32_SUPPORT

From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Mar 2007 19:30:19 +0000
Subject: Re: [PATCH] - Speed up boot - skip unnecessary clock calibration
Message-Id: <20070327193019.GA24749@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327132953.GA14401@sgi.com>
In-Reply-To: <20070327132953.GA14401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Skip clock calibration if cpu being brought online is exactly the same
speed, stepping, etc., as the previous cpu. This significantly reduces
the time to boot very large systems. 

	Signed-off-by: Jack Steiner <steiner@sgi.com>

----
Add suggestion from Matthew Wilcox to use local variables to shorten lines.




Index: linux/arch/ia64/kernel/smpboot.c
=================================--- linux.orig/arch/ia64/kernel/smpboot.c	2007-03-27 10:08:13.664475719 -0500
+++ linux/arch/ia64/kernel/smpboot.c	2007-03-27 14:20:44.070836177 -0500
@@ -375,6 +375,7 @@ static void __devinit
 smp_callin (void)
 {
 	int cpuid, phys_id, itc_master;
+	struct cpuinfo_ia64 *last_cpuinfo, *this_cpuinfo;
 	extern void ia64_init_itm(void);
 	extern volatile int time_keeper_id;
 
@@ -424,7 +425,21 @@ smp_callin (void)
 	 * Get our bogomips.
 	 */
 	ia64_init_itm();
-	calibrate_delay();
+
+	/*
+	 * Delay calibration can be skipped if new processor is identical to the
+	 * previous processor.
+	 */
+	last_cpuinfo = cpu_data(cpuid - 1);
+	this_cpuinfo = local_cpu_data;
+	if (last_cpuinfo->itc_freq != this_cpuinfo->itc_freq ||
+	    last_cpuinfo->proc_freq != this_cpuinfo->proc_freq ||
+	    last_cpuinfo->features != this_cpuinfo->features ||
+	    last_cpuinfo->revision != this_cpuinfo->revision ||
+	    last_cpuinfo->family != this_cpuinfo->family ||
+	    last_cpuinfo->archrev != this_cpuinfo->archrev ||
+	    last_cpuinfo->model != this_cpuinfo->model)
+		calibrate_delay();
 	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
 
 #ifdef CONFIG_IA32_SUPPORT

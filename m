From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 13 Aug 2007 21:49:46 +0000
Subject: [PATCH] Fix processor_get_freq
Message-Id: <1187041786.6306.53.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   The core cpufreq code doesn't appear to understand returning -EAGAIN
for the get() function of the cpufreq_driver.  If PAL_GET_PSTATE returns
-1, such as when running on Xen, scaling_cur_freq is happy to return
4294967285 kHz (ie. (unsigned)-11).  The other drivers appear to return
0 for a failure, and doing so gives me the max frequency from
scaling_cur_frequency and "<unknown>" from cpuinfo_cur_frequency.  I
believe that's the desired behavior.  Thanks,

	Alex

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

diff -r 1559df81a153 arch/ia64/kernel/cpufreq/acpi-cpufreq.c
--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c	Mon Aug 13 05:00:33 2007 +0000
+++ b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c	Mon Aug 13 15:41:29 2007 -0600
@@ -113,10 +113,8 @@ processor_get_freq (
 
 	saved_mask = current->cpus_allowed;
 	set_cpus_allowed(current, cpumask_of_cpu(cpu));
-	if (smp_processor_id() != cpu) {
-		ret = -EAGAIN;
+	if (smp_processor_id() != cpu)
 		goto migrate_end;
-	}
 
 	/* processor_get_pstate gets the instantaneous frequency */
 	ret = processor_get_pstate(&value);
@@ -125,7 +123,7 @@ processor_get_freq (
 		set_cpus_allowed(current, saved_mask);
 		printk(KERN_WARNING "get performance failed with error %d\n",
 		       ret);
-		ret = -EAGAIN;
+		ret = 0;
 		goto migrate_end;
 	}
 	clock_freq = extract_clock(data, value, cpu);



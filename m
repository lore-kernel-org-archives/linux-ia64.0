From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Wed, 15 Aug 2007 02:25:35 +0000
Subject: RE: [PATCH] Fix processor_get_freq
Message-Id: <653FFBB4508B9042B5D43DC9E18836F501450D7A@scsmsx415.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1187041786.6306.53.camel@lappy>
In-Reply-To: <1187041786.6306.53.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Ack.

Thanks,
Venki 

>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org 
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Alex Williamson
>Sent: Monday, August 13, 2007 2:50 PM
>To: Pallipadi, Venkatesh
>Cc: linux-ia64
>Subject: [PATCH] Fix processor_get_freq
>
>
>   The core cpufreq code doesn't appear to understand returning -EAGAIN
>for the get() function of the cpufreq_driver.  If 
>PAL_GET_PSTATE returns
>-1, such as when running on Xen, scaling_cur_freq is happy to return
>4294967285 kHz (ie. (unsigned)-11).  The other drivers appear to return
>0 for a failure, and doing so gives me the max frequency from
>scaling_cur_frequency and "<unknown>" from cpuinfo_cur_frequency.  I
>believe that's the desired behavior.  Thanks,
>
>	Alex
>
>Signed-off-by: Alex Williamson <alex.williamson@hp.com>
>---
>
>diff -r 1559df81a153 arch/ia64/kernel/cpufreq/acpi-cpufreq.c
>--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c	Mon Aug 13 
>05:00:33 2007 +0000
>+++ b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c	Mon Aug 13 
>15:41:29 2007 -0600
>@@ -113,10 +113,8 @@ processor_get_freq (
> 
> 	saved_mask = current->cpus_allowed;
> 	set_cpus_allowed(current, cpumask_of_cpu(cpu));
>-	if (smp_processor_id() != cpu) {
>-		ret = -EAGAIN;
>+	if (smp_processor_id() != cpu)
> 		goto migrate_end;
>-	}
> 
> 	/* processor_get_pstate gets the instantaneous frequency */
> 	ret = processor_get_pstate(&value);
>@@ -125,7 +123,7 @@ processor_get_freq (
> 		set_cpus_allowed(current, saved_mask);
> 		printk(KERN_WARNING "get performance failed 
>with error %d\n",
> 		       ret);
>-		ret = -EAGAIN;
>+		ret = 0;
> 		goto migrate_end;
> 	}
> 	clock_freq = extract_clock(data, value, cpu);
>
>
>-
>To unsubscribe from this list: send the line "unsubscribe 
>linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

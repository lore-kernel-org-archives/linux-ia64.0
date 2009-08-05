From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Wed, 05 Aug 2009 23:22:06 +0000
Subject: RE: [PATCH 3/15] arch/ia64: Use DIV_ROUND_CLOSEST
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B38E494C@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0908021044540.15557@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.0908021044540.15557@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Julia Lawall' <julia@diku.dk>, "Luck, Tony" <tony.luck@intel.com>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'kernel-janitors@vger.kernel.org'" <kernel-janitors@vger.kernel.org>

>-----Original Message-----
>From: Julia Lawall [mailto:julia@diku.dk]
>Sent: Sunday, August 02, 2009 1:45 AM
>To: Yu, Fenghua; Luck, Tony; linux-ia64@vger.kernel.org; linux-
>kernel@vger.kernel.org; kernel-janitors@vger.kernel.org
>Subject: [PATCH 3/15] arch/ia64: Use DIV_ROUND_CLOSEST
>
>From: Julia Lawall <julia@diku.dk>
>
>The kernel.h macro DIV_ROUND_CLOSEST performs the computation (x + d/2)/d
>but is perhaps more readable.
>
>The semantic patch that makes this change is as follows:
>(http://www.emn.fr/x-info/coccinelle/)
>
>// <smpl>
>@haskernel@
>@@
>
>#include <linux/kernel.h>
>
>@depends on haskernel@
>expression x,__divisor;
>@@
>
>- (((x) + ((__divisor) / 2)) / (__divisor))
>+ DIV_ROUND_CLOSEST(x,__divisor)
>// </smpl>
>
>Signed-off-by: Julia Lawall <julia@diku.dk>
>
>---
> arch/ia64/kernel/time.c             |   10 ++++++----
> 1 files changed, 6 insertions(+), 4 deletions(-)
>
>diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
>index 4990495..aaa6651 100644
>--- a/arch/ia64/kernel/time.c
>+++ b/arch/ia64/kernel/time.c
>@@ -314,7 +314,7 @@ ia64_init_itm (void)
>
> 	itc_freq = (platform_base_freq*itc_ratio.num)/itc_ratio.den;
>
>-	local_cpu_data->itm_delta = (itc_freq + HZ/2) / HZ;
>+	local_cpu_data->itm_delta = DIV_ROUND_CLOSEST(itc_freq, HZ);
> 	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%u/%u, "
> 	       "ITC freq=%lu.%03luMHz", smp_processor_id(),
> 	       platform_base_freq / 1000000, (platform_base_freq / 1000) %
>1000,
>@@ -330,9 +330,11 @@ ia64_init_itm (void)
>
> 	local_cpu_data->proc_freq >(platform_base_freq*proc_ratio.num)/proc_ratio.den;
> 	local_cpu_data->itc_freq = itc_freq;
>-	local_cpu_data->cyc_per_usec = (itc_freq + USEC_PER_SEC/2) /
>USEC_PER_SEC;
>-	local_cpu_data->nsec_per_cyc >((NSEC_PER_SEC<<IA64_NSEC_PER_CYC_SHIFT)
>-					+ itc_freq/2)/itc_freq;
>+	local_cpu_data->cyc_per_usec >+		DIV_ROUND_CLOSEST(itc_freq, USEC_PER_SEC);
>+	local_cpu_data->nsec_per_cyc >+		DIV_ROUND_CLOSEST(NSEC_PER_SEC << IA64_NSEC_PER_CYC_SHIFT,
>+				  itc_freq);
>
> 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
> #ifdef CONFIG_SMP

Acked-by: Fenghua Yu <Fenghua.yu@intel.com>


From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Tue, 27 Mar 2007 19:17:17 +0000
Subject: RE: [PATCH] - Speed up boot - skip unnecessary clock calibration
Message-Id: <A29F7A5700A7EA4380E08C1F68C3B6D8026FE7B2@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327132953.GA14401@sgi.com>
In-Reply-To: <20070327132953.GA14401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>+	 */
>+	if (local_cpu_data->itc_freq != per_cpu(cpu_info, cpuid -
1).itc_freq >||
>+			local_cpu_data->proc_freq != per_cpu(cpu_info,
cpuid - >1).proc_freq ||

BSP (cupid=0) should always calibrate delay. Otherwise the patch won't
work.

if (cupid=0)
 calibrate_delay()
else
 your patch.

Thanks.

-Fenghua

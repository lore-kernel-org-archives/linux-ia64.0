From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Fri, 07 Aug 2009 20:41:26 +0000
Subject: RE: [PATCH] acpi-cpufreq: Read buffer overflow?
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B3991918@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A7C8AB5.90503@gmail.com>
In-Reply-To: <4A7C8AB5.90503@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>If `data->acpi_data.state_count' is 0, we read from data-
>>acpi_data.states[-1].
>
>Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>---
>Unsure whether this can happen.
>
>diff --git a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
>b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
>index 7b43545..7cdd1f6 100644
>--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
>+++ b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
>@@ -95,7 +95,7 @@ extract_clock (
> 		if (value = data->acpi_data.states[i].status)
> 			return data->acpi_data.states[i].core_frequency;
> 	}
>-	return data->acpi_data.states[i-1].core_frequency;
>+	return i ? data->acpi_data.states[i-1].core_frequency : 0;
> }
>
>
If state_count<=1, cpufreq driver initialization acpi_cpufreq_cpu_init will fail since there is no P-states to switch to. Other cpufreq functions won't be called if initialization fails. So it's unnecessary to do sanity check for state_count in here again or in other related functions.

Thanks.

-Fenghua

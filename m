From: Hanjun Guo <guohanjun@huawei.com>
Date: Wed, 10 Apr 2013 10:33:11 +0000
Subject: Re: [PATCH 0/4] ACPI and PM patches for Euler stable from mainline v3.6
Message-Id: <51653FE7.6040902@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
In-Reply-To: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Toshi Kani <toshi.kani@hp.com>
Cc: linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I made a mistake in sending email, sorry for the bothering, please ignore it.

On 2013/4/10 18:22, Hanjun Guo wrote:
> Hi Zefan,
> 
> These four patches are bugfix for ACPI and power management from mainline 
> v3.6, comments are welcomed!
> 
> Thanks
> Hanjun Guo
> 
> 
> Colin Cross (1):
>   cpuidle: fix error handling in __cpuidle_register_device
> 
> Stephen Boyd (1):
>   cpufreq: Fix sysfs deadlock with concurrent hotplug/frequency switch
> 
> Thomas Renninger (2):
>   ACPI: Untangle a return statement for better readability
>   ACPI: Only count valid srat memory structures
> 
>  arch/ia64/kernel/acpi.c   |    5 +++--
>  arch/x86/mm/srat.c        |   16 +++++++++-------
>  drivers/acpi/numa.c       |   12 ++++++++----
>  drivers/cpufreq/cpufreq.c |   35 +++++++++++++++++++++++++++--------
>  drivers/cpuidle/cpuidle.c |   13 +++++++++----
>  include/linux/acpi.h      |    2 +-
>  6 files changed, 57 insertions(+), 26 deletions(-)
> 
> 
> _______________________________________________
> Kernel.openeuler mailing list
> Kernel.openeuler@huawei.com
> http://rnd-openeuler.huawei.com/mailman/listinfo/kernel.openeuler
> 
> 



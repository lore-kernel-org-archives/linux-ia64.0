From: Mike Travis <travis@sgi.com>
Date: Fri, 25 Apr 2008 12:50:49 +0000
Subject: Re: [2.6 patch] ia64: let NUMA select SMP
Message-Id: <4811D3A9.4060602@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC012F9EF0@orsmsx424.amr.corp.intel.com> <20080425001652.GD18854@cs181133002.pp.htv.fi> <1FE6DD409037234FAB833C420AA843EC012F9F55@orsmsx424.amr.corp.intel.com> <20080425004139.GE18854@cs181133002.pp.htv.fi>
In-Reply-To: <20080425004139.GE18854@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@kernel.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Russ Anderson <rja@sgi.com>

Adrian Bunk wrote:
> On Thu, Apr 24, 2008 at 05:25:06PM -0700, Luck, Tony wrote:
>>>>       Build fix for CONFIG_NUMA=y && CONFIG_SMP=n
>>>> ...
>>> Why is this an allowed configuration on ia64?
>> It shows up in allnoconfig ... probably because some
>> bit of Kconfig forces NUMA=y.
> 
> allnoconfig results in CONFIG_IA64_GENERIC=y, which in turn selects NUMA.
> 
> What about the patch below instead?
> 
>> I can't imagine that it is ever a useful combination ... except to
>> find places in the code where people have:

Though highly unlikely, it is possible to have multiple memory nodes
without having multiple cpus -- at least in theory.  In this specific
case it's nonsensical because the scheduler is grouping cpus by node.

Thanks,
Mike

>>
>> #if defined(CONFIG_SMP)
>>  ...
>> #else
>>
>> #if defined(CONFIG_NUMA) // !!! SMP=n, NUMA code???
>>   ...
>> #endif
>> #endif
>>
>>
>> Which is what happened, and is being fixed, here.
> 
> If it isn't a useful combination such code makes no sense.
> 
>> -Tony
> 
> cu
> Adrian
> 
> 
> <--  snip  -->
> 
> 
> CONFIG_NUMA=y, CONFIG_SMP=n isn't a useful combination, so let NUMA 
> select SMP.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> a94d43a82a3c5a95c82b9688e5adebca6dcb7acb diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index cd13e13..19e8167 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -387,6 +387,7 @@ config NUMA
>  	bool "NUMA support"
>  	depends on !IA64_HP_SIM && !FLATMEM
>  	default y if IA64_SGI_SN2
> +	select SMP
>  	select ACPI_NUMA if ACPI
>  	help
>  	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
> 


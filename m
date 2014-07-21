From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 21 Jul 2014 17:19:54 +0000
Subject: Re: [PATCH v2 1/7] memory-hotplug: add zone_for_memory() for selecting zone for new memory
Message-Id: <53CD4BBA.1050706@cogentembedded.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405914402-66212-1-git-send-email-wangnan0@huawei.com> <1405914402-66212-2-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405914402-66212-2-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wang Nan <wangnan0@huawei.com>, Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

Hello.

On 07/21/2014 07:46 AM, Wang Nan wrote:

    Some grammar nitpicking.

> This patch introduces a zone_for_memory function in arch independent
> code for arch_add_memory() using.

    s/ using/'s use/.

> Many arch_add_memory() function simply selects ZONE_HIGHMEM or

    Plural needed with "many".

> ZONE_NORMAL and add new memory into it. However, with the existance of
> ZONE_MOVABLE, the selection method should be carefully considered: if
> new, higher memory is added after ZONE_MOVABLE is setup, the default
> zone and ZONE_MOVABLE may overlap each other.

> should_add_memory_movable() checks the status of ZONE_MOVABLE. If it has
> already contain memory, compare the address of new memory and movable
> memory. If new memory is higher than movable, it should be added into
> ZONE_MOVABLE instead of default zone.

> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
[...]

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 469bbf5..348fda7 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1156,6 +1156,34 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>   	return 0;
>   }
>
> +/*
> + * If movable zone has already been setup, newly added memory should be check.

    Checked.

WBR, Sergei


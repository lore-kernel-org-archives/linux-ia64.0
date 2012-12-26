From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 03:30:34 +0000
Subject: Re: [PATCH v5 04/14] memory-hotplug: remove /sys/firmware/memmap/X sysfs
Message-Id: <50DA6F5A.2070601@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-5-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/24 21:09), Tang Chen wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
> sysfs files are created. But there is no code to remove these files. The patch
> implements the function to remove them.
> 
> Note: The code does not free firmware_map_entry which is allocated by bootmem.
>        So the patch makes memory leak. But I think the memory leak size is
>        very samll. And it does not affect the system.
> 
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>   drivers/firmware/memmap.c    |   98 +++++++++++++++++++++++++++++++++++++++++-
>   include/linux/firmware-map.h |    6 +++
>   mm/memory_hotplug.c          |    5 ++-
>   3 files changed, 106 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
> index 90723e6..49be12a 100644
> --- a/drivers/firmware/memmap.c
> +++ b/drivers/firmware/memmap.c
> @@ -21,6 +21,7 @@
>   #include <linux/types.h>
>   #include <linux/bootmem.h>
>   #include <linux/slab.h>
> +#include <linux/mm.h>
>   
>   /*
>    * Data types ------------------------------------------------------------------
> @@ -41,6 +42,7 @@ struct firmware_map_entry {
>   	const char		*type;	/* type of the memory range */
>   	struct list_head	list;	/* entry for the linked list */
>   	struct kobject		kobj;   /* kobject for each entry */
> +	unsigned int		bootmem:1; /* allocated from bootmem */
>   };

Can't we detect from which the object is allocated from, slab or bootmem ?

Hm, for example,

    PageReserved(virt_to_page(address_of_obj)) ?
    PageSlab(virt_to_page(address_of_obj)) ?

Thanks,
-Kame


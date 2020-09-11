From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 11 Sep 2020 14:01:00 +0000
Subject: Re: [PATCH 3/3] mm: don't panic when links can't be created in sysfs
Message-Id: <20200911140100.GA3812164@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-4-ldufour@linux.ibm.com>
In-Reply-To: <20200911134831.53258-4-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 11, 2020 at 03:48:31PM +0200, Laurent Dufour wrote:
> At boot time, or when doing memory hot-add operations, if the links in
> sysfs can't be created, the system is still able to run, so just report the
> error in the kernel log.
> 
> Since the number of memory blocks managed could be high, the messages are
> rate limited.
> 
> As a consequence, link_mem_sections() has no status to report anymore.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/node.c  | 25 +++++++++++++++++--------
>  include/linux/node.h | 17 ++++++++---------
>  mm/memory_hotplug.c  |  5 ++---
>  3 files changed, 27 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 862516c5a5ae..749a1c8ea992 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -811,12 +811,21 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>  		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>  					&mem_blk->dev.kobj,
>  					kobject_name(&mem_blk->dev.kobj));
> -		if (ret)
> -			return ret;
> +		if (ret && ret != -EEXIST)
> +			pr_err_ratelimited(
> +				"can't create %s to %s link in sysfs (%d)\n",
> +				kobject_name(&node_devices[nid]->dev.kobj),
> +				kobject_name(&mem_blk->dev.kobj), ret);

dev_err_ratelimited()?

Same elsewhere in this patch.

thanks,

greg k-h

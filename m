From: Michal Hocko <mhocko@suse.com>
Date: Mon, 14 Sep 2020 08:49:04 +0000
Subject: Re: [PATCH 1/3] mm: replace memmap_context by memplug_context
Message-Id: <20200914084904.GA16999@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-2-ldufour@linux.ibm.com>
In-Reply-To: <20200911134831.53258-2-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 11-09-20 15:48:29, Laurent Dufour wrote:
> The memmap_context is used to detect whether a memory operation is due to a
> hot-add operation or happening at boot time.
> 
> Makes it general to the hotplug operation, renaming it at memplug_context
> and move its define in the corresponding header.
> 
> There is no functional change introduced by this patch

I do not want to nit picking on naming but we want to look at this from
the initialization POV rather than hotplug. So....
> 
> Suggested-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
[...]
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 375515803cd8..cd2bd21d3a4d 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -15,6 +15,15 @@ struct memory_block;
>  struct resource;
>  struct vmem_altmap;
>  
> +/*
> + * Memory plugin context, use to differentiate memory added at boot time and
> + * hot-plugged memory.
> + */
> +enum memplug_context {
> +	MEMPLUG_EARLY,
> +	MEMPLUG_HOTPLUG,
> +};

/*
 * Memory initialization context, use to differentiate memory added by
 * the platform statically or via memory hotplug interface.
 */
enum meminit_context {
	MEMINIT_EARLY,
	MEMINIT_HOTPLUG
}

-- 
Michal Hocko
SUSE Labs

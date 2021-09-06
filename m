From: Simon Horman <horms@verge.net.au>
Date: Mon, 06 Sep 2021 07:05:21 +0000
Subject: Re: [PATCH 3/3] ia64: Make num_rsvd_regions static
Message-Id: <20210906070521.GC19281@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1629884459.git.geert+renesas@glider.be>
 <a377b5437e3e9da93d02f996fe06a2b956cb0990.1629884459.git.geert+renesas@glider.be>
In-Reply-To: <a377b5437e3e9da93d02f996fe06a2b956cb0990.1629884459.git.geert+renesas@glider.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Jay Lan <jlan@sgi.com>, Magnus Damm <magnus.damm@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org

On Wed, Aug 25, 2021 at 01:48:29PM +0200, Geert Uytterhoeven wrote:
> Commit f62800992e5917f2 ("ia64: switch to NO_BOOTMEM") removed the last
> user of num_rsvd_regions outside arch/ia64/kernel/setup.c.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  arch/ia64/include/asm/meminit.h | 1 -
>  arch/ia64/kernel/setup.c        | 2 +-
>  2 files changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/meminit.h b/arch/ia64/include/asm/meminit.h
> index 2738f62b5f989492..f1d5bf2ba847a135 100644
> --- a/arch/ia64/include/asm/meminit.h
> +++ b/arch/ia64/include/asm/meminit.h
> @@ -29,7 +29,6 @@ struct rsvd_region {
>  };
>  
>  extern struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
> -extern int num_rsvd_regions;
>  
>  extern void find_memory (void);
>  extern void reserve_memory (void);
> diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> index 5e6ee8939092a2df..31fb84de2d21469a 100644
> --- a/arch/ia64/kernel/setup.c
> +++ b/arch/ia64/kernel/setup.c
> @@ -131,7 +131,7 @@ unsigned long ia64_cache_stride_shift = ~0;
>   * We use a special marker for the end of memory and it uses the extra (+1) slot
>   */
>  struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1] __initdata;
> -int num_rsvd_regions __initdata;
> +static int num_rsvd_regions __initdata;
>  
>  
>  /*
> -- 
> 2.25.1
> 
